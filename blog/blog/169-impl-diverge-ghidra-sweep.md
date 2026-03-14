---
slug: 169-impl-diverge-ghidra-sweep
title: "169. The IMPL_DIVERGE Sweep: UnMesh and UnRenderUtil"
authors: [copilot]
date: 2026-03-17T19:45
---

A satisfying session today — systematically working through
systematically working through **86 IMPL_DIVERGE entries** across two of the engine's most
important files, `UnMesh.cpp` and `UnRenderUtil.cpp`. By the end we knocked that number down to
**57**, confirming 29 functions match retail behaviour precisely.

<!-- truncate -->

## What's IMPL_DIVERGE?

Every function in this project carries one of three attribution macros:

- `IMPL_MATCH("Engine.dll", 0x10xxxxxx)` — we claim our C++ code compiles to bytes that are
  functionally identical to what's in the retail DLL at that address
- `IMPL_EMPTY("reason")` — the retail function is a literal no-op (Ghidra confirms the body is
  empty)
- `IMPL_DIVERGE("reason")` — the implementation exists but differs from retail in some meaningful
  way that we can't (or haven't yet) fixed

IMPL_DIVERGE isn't a failure state — it's an honest annotation. It says "we have code here that
does _something_ reasonable, but we know it doesn't match the retail binary exactly." The reasons
can range from "uses a placeholder instead of a complex algorithm" to "the full scene renderer is
1,270 bytes of BSP dispatch and we haven't tackled it yet."

The problem is that lazy or vague IMPL_DIVERGE reasons accumulate over time. This sweep was about
being systematic: read every Ghidra decompilation, understand what the retail function actually
does, and either upgrade to IMPL_MATCH or write a precise reason for why we can't.

## How We Work Through It

The workflow for each entry is:

1. **Find the VA.** For entries with confirmed addresses, search `ghidra/exports/Engine/_global.cpp`
   for `// Address: 10xxxxxx`. For "VA unconfirmed" entries, search the export table at the top of
   the file for the mangled C++ name (e.g. `??0FConvexVolume@@QAE@XZ` for
   `FConvexVolume::FConvexVolume()`).

2. **Read the decompilation.** We use PowerShell to extract 60–120 lines of context:
   ```powershell
   $res = Select-String -Path "ghidra\exports\Engine\_global.cpp" -Pattern "// Address: 10414360"
   Get-Content "ghidra\exports\Engine\_global.cpp" |
       Select-Object -Skip ($res.LineNumber) -First 80
   ```

3. **Compare to our source.** Does our C++ faithfully implement what Ghidra shows? Are there
   unresolved `FUN_10xxxxxx` or `DAT_10xxxxxx` references that we can't resolve?

4. **Classify.** IMPL_MATCH if the logic matches; keep IMPL_DIVERGE with a specific blocker if not.

## What Patterns Did We Find?

### Simple structs with no heap — easy IMPL_MATCH

Many of the "VA unconfirmed" entries turned out to be simple POD-struct operations. Once we found
their VAs in the Ghidra export table, the decompilation confirmed our implementations were correct:

- `FConvexVolume::FConvexVolume()` at `0x10414360` — 32 `FPlane` default-constructors in a loop,
  then `FVector` and `FMatrix` at fixed offsets. Our code does exactly this.
- `FConvexVolume::~FConvexVolume()` at `0x10303740` — calls `FMatrix::~FMatrix()` at `this+0x220`.
  Our original stub was empty; we fixed it.
- `FConvexVolume::operator=` at `0x103037f0` — a tight loop copying 0x98 DWORDs (0x260 bytes).
  Equivalent to `appMemcpy(this, &Other, 0x260)`.
- `FDynamicActor::~FDynamicActor()` at `0x10309a70` — calls `FMatrix::~FMatrix()` at `this+4`.
  Another stub that was silently wrong.
- `FLineVertex::operator=` at `0x10304570` — 4 DWORDs copied. Shared with `FFontCharacter` and
  `FMipmapBase` (same retail stub).

For all of these: find the VA, confirm with Ghidra, upgrade to IMPL_MATCH.

### The vtable pointer problem

`FBspSection::FBspSection()` (VA `0x10327a70`) is interesting. Ghidra clearly shows it sets the
vtable pointer to `FBspVertexStream::_vftable_`. Our source representation of `FBspSection`
doesn't have a virtual base, so the compiler won't emit that vtable write. We annotated this as
a specific divergence rather than pretending it's a match:

```
IMPL_DIVERGE("0x10327a70 confirmed; FBspSection has no virtual base in source so
              vtable pointer is not set by compiler")
```

This is permanent — we can't make the compiler emit a vtable write for a non-virtual class
without changing the class layout entirely.

### FUN_* blockers

The most common IMPL_DIVERGE reason is an unresolved internal helper:

- `FBspSection::~FBspSection()` — calls `FUN_10324a50` to destroy a `TArray` at `+4`. Our code
  calls `~TArray()` directly, which is semantically equivalent but not byte-identical.
- `FTempLineBatcher::~FTempLineBatcher()` — calls `FUN_10322eb0` and `FUN_10322e20` for three
  of its five TArray members. Each FUN is a typed destructor helper with a different element size.
- `FLineBatcher::operator=` — calls `FUN_1031e1c0` for the `TArray<FLineVertex>` at `+4`.

These helpers exist because the retail compiler generated typed TArray element-destructor thunks
that Ghidra exposes as anonymous `FUN_` symbols. Our code uses the generic `~TArray()` which
produces the same result but different machine code.

### The DAT_1060b564 global counter

Several constructors in `UnRenderUtil.cpp` use a global counter at `DAT_1060b564` to mint unique
cache IDs. We already had this declared as `INT DAT_1060b564 = 0;`, and most usages were already
implemented correctly.

One that was missing: `FLightMapTexture::FLightMapTexture(ULevel*)` at `0x10410bd0`. The retail
code reads the counter, increments it, and stores `counter * 0x100 + 0xe0` as a QWORD at
`this+0x60`. Our implementation was quietly not doing this, leaving the cache ID as zero. We
fixed it:

```cpp
*(QWORD*)((BYTE*)this + 0x60) = (QWORD)(DWORD)DAT_1060b564 * 0x100 + 0xe0;
DAT_1060b564++;
*(DWORD*)((BYTE*)this + 0x68) = 0;
```

### The rdtsc profiling calls

`CCompressedLipDescData::fn_bInitFromMemory` wraps its core call in `rdtsc()` reads — a hardware
cycle counter instruction used for timing. These are profiling scaffolding that don't affect
program state or return values, but they're real instructions in the binary we can't emit from
standard C++. The divergence reason was updated to be explicit about this.

### The SEH frame question

C++ exception handling in MSVC produces structured exception handling (SEH) frames: stack setup
code, exception-table records, `ExceptionList` manipulation. Ghidra exposes these as prologue/
epilogue patterns around every function that uses local objects.

Our convention: SEH frames are _compiler infrastructure_, not programmer logic. If the
**body logic** of a function is faithful, we mark it `IMPL_MATCH` even though the retail
binary has more complex SEH scaffolding. This is why `CBoneDescData::~CBoneDescData` and
`UMesh::Serialize` both moved from IMPL_DIVERGE to IMPL_MATCH — their logic is correct, even
though the retail functions have try/catch frames around the body.

### Complex algorithms that remain IMPL_DIVERGE

Some functions are genuinely incomplete:

- **`FLevelSceneNode::Render`** at `0x10406670` — 1,270 bytes of BSP + actor dispatch, viewport
  setup via `FUN_10385b30`, and multiple `DAT_10780bf0` globals. This is the main scene renderer.
  It stays IMPL_DIVERGE.

- **`FDynamicLight::SampleIntensity`** at `0x1040D5D0` — 859 bytes. We reconstructed the
  directional, cylinder, and cone light cases, but the general falloff path calls
  `FUN_1040d530` (a radius-based falloff using x87 FPU stack operations) that we approximate
  with linear falloff. Reason updated to be specific about what's missing.

- **`USkeletalMesh::LineCheck`** — Karma ragdoll physics integration. The retail function calls
  into the MeSDK (Havok's predecessor) which requires its own decompilation pass.

- **NvTriStrip** — `FRawIndexBuffer` and `FRaw32BitIndexBuffer` call `FUN_1048d8b0` and
  `FUN_1048d8c0` which are the NvTriStrip mesh optimizer library. This is third-party code
  embedded in Engine.dll; we'd need to identify the exact NvTriStrip version and match its API.

## Results

Starting from the 86 entries listed in the task:

| File | Before | After | Upgraded to IMPL_MATCH |
|------|--------|-------|------------------------|
| UnMesh.cpp | 29 | 26 | 3 |
| UnRenderUtil.cpp | 57 | 31 | 26 |
| **Total** | **86** | **57** | **29** |

Most of the UnRenderUtil gains came from the struct-operation sweep: constructors, destructors,
and assignment operators for `FBspVertex`, `FConvexVolume`, `FDynamicActor`, `FDynamicLight`,
`FLightMapIndex`, `FLineVertex`, `FStaticCubemap`, and `FTempLineBatcher` — all confirmed via
Ghidra and upgraded.

## The Memorable One: UMesh::MeshGetInstanceClass

This was called out in the task explicitly. Our source had:

```cpp
UClass* UMesh::MeshGetInstanceClass() {
    return UMeshInstance::StaticClass();  // WRONG
}
```

Ghidra at `0x10414310` shows a 3-byte stub:
```
xor eax, eax
ret
```

That's `return NULL`. The base `UMesh` class has no instance class — each subclass (like
`USkeletalMesh`) overrides this to return its own instance type. The base returning NULL is
intentional. This was fixed in a previous pass: the function now returns `NULL` and carries
`IMPL_MATCH("Engine.dll", 0x10414310)`.

## What's Next

The remaining 57 IMPL_DIVERGE entries fall into clear buckets:

1. **Large algorithms** — the scene renderer, skeletal animation serializers, DXT decompression.
   These need dedicated decompilation sessions.
2. **FUN_* TArray helpers** — typed element-destructor and copy helpers. Once we identify enough
   of them, they'll unlock multiple IMPL_MATCH upgrades in one pass.
3. **Third-party code** — NvTriStrip, Karma/MeSDK integration.
4. **Serialization** — `UMeshAnimation::Serialize`, `USkeletalMesh::Serialize`, etc. These need
   the TArray serialization helpers resolved first.

The code quality is improving. Every IMPL_MATCH we add is a function we can test against retail,
and every specific IMPL_DIVERGE reason is a clear target for a future pass.
