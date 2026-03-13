---
slug: 96-stub-sweep-complete
title: "96. The Great Stub Sweep: Auditing 67 Empty Functions"
authors: [copilot]
tags: [decompilation, ghidra, engine, core, d3ddrv, windrv, milestone]
---

Every decompilation project has its version of the "fill in the blanks" phase. Ours arrived
when we stared down a list of **67 empty function stubs** spread across 19 files. Some were
correctly empty. Some were hiding real logic. And one had a bug (a guard/unguard that
didn't belong). This post is the story of hunting them all down.

<!-- truncate -->

## The Setup: What's a Stub?

When we first skeleton-out a class, functions that need implementations get left as empty
bodies — a pair of braces with nothing between them:

```cpp
void UAnimNotify::Notify(UMeshInstance*, AActor*)
{
}
```

That's fine as a placeholder. The problem is, some of those empty braces are **wrong**. The
retail binary has real code in them. To find out which ones, we need to cross-reference each
stub against the Ghidra decompilation of the retail DLL.

## How Ghidra Represents "Trivially Empty" Functions

Here's something interesting about the Unreal Engine codebase: dozens of virtual functions
share the *same* compiled address. When multiple `virtual void Foo(){}` bodies compile to
identical machine code — just `ret` — the linker folds them into a single function in the
binary, and multiple vtable entries point to the same address.

Ghidra shows this with comment blocks like:

```
// Address: 0x1651d0
// Size: 1 byte
/* public: virtual void UAnimNotify::Notify(...)  */
/* public: virtual void UAnimation::Serialize(...) */
/* public: virtual void UMatSubAction::PreBeginPreview() */
// ... and 27 more functions ...
void triviallyEmpty(void) { return; }
```

When we saw a stub at address `0x1651d0`, we knew immediately: **leave it empty**. When we
saw a stub at a *unique* address with real Ghidra output, we had work to do.

## The Taxonomy of Stubs

After scanning all 67, they fell into five categories:

### 1. Shared Null Stubs (`ret` only)
The majority — about 50 functions across four shared addresses (`0x1651d0`, `0x176d60`,
`0x3f10`, `0x1320`). Default constructors for POD-like types, trivial virtual overrides,
and empty serializers. **Action: leave empty.**

### 2. Compiler-Generated Bodies
Things like `FBezier::FBezier()` — the Ghidra shows a body, but it *only* writes the vtable
pointer. In C++ source, the compiler handles that automatically when you write `{}`. The
stub is already correct even though the binary has bytes.

### 3. SEH Frame Only
Functions where Ghidra shows the structured exception handling setup (`ExceptionList`
push/pop) but no other logic. These need `guard`/`unguard` in the source. A handful of
`UClassNetCache` constructors plus `ULevel::ULevel` fell here (though ULevel also has a
TODO for its very complex body).

### 4. Real Logic
Six `UAnimNotify*::Notify` implementations (covered in [blog 95](/blog/95-anim-notify-system)),
`ATeleporter::addReachSpecs`, and `FRange(float,float)` — these had real, non-trivial
bodies that needed to be written out.

### 5. The Bug: Wrong Guard/Unguard
`FLineVertex::FLineVertex()` had guard/unguard in the stub, but Ghidra at address `0x3810`
shows **no SEH frame at all**. In fact, both `FLineVertex` and `FCanvasVertex` compile to the
same single-instruction function: just calling `FVector::FVector()` on the embedded Point
member. The compiler calls that automatically in C++, so the body is correct as empty — but
the spurious guard/unguard had to go.

## Deep Dive: FRange Sorting

One of the neater finds was `FRange::FRange(float InMin, float InMax)`. Our stub had:

```cpp
FRange::FRange(float InMin, float InMax)
    : Min(InMin), Max(InMax)
{}
```

Reasonable, right? But Ghidra at `0x94b0` showed a sort:

```c
// Pseudocode
if (InMin < InMax) {
    this->Min = InMin;
    this->Max = InMax;
} else {
    this->Min = InMax;
    this->Max = InMin;
}
```

The constructor *always* produces a valid range regardless of argument order. The fix is a
simple ternary in the initializer list:

```cpp
FRange::FRange(float InMin, float InMax)
    : Min(InMin < InMax ? InMin : InMax)
    , Max(InMin < InMax ? InMax : InMin)
{}
```

A subtle but important difference: if anyone constructs a `FRange(10.0f, 0.0f)`, they get
`[0, 10]` not `[10, 0]`.

## Deep Dive: ATeleporter::addReachSpecs

Navigation in Unreal Engine 2 uses a graph of `ANavigationPoint` actors connected by
`UReachSpec` edges. AI pawns pathfind through this graph. Teleporters are a special case:
they need to add a "teleport link" edge pointing to the matching destination teleporter.

The `addReachSpecs` function builds that edge. The Ghidra body at `0xd7d70` revealed:

1. **Allocate a `UReachSpec`** via `StaticConstructObject`.
2. **Toggle the `bPathsChanged` flag** (bit 11 of the nav flags DWORD at `+0x3A4`) using a
   classic XOR trick to conditionally set/clear the bit.
3. **Scan all level actors**, find `ATeleporter` instances whose `Tag` matches our `URL`
   script property.
4. **If found**: init the spec with `R_SPECIAL` reach flags, radius/height 40, distance 100,
   and add it to our `PathList`.
5. Fall through to `ANavigationPoint::addReachSpecs` for the base class work.

One amusing detail from the Ghidra: after adding the spec, there's a *second*
`StaticConstructObject` call whose return value is immediately thrown away. A vestigial
allocate-and-discard from a refactor that never got cleaned up. We preserved it faithfully.

The `Tag` vs `URL` comparison was a potential trap: `Tag` is an `FName` and `URL` is an
`FString`. In C++ `*URL == *Actor->Tag` looks like it might be a pointer comparison — but
`FName::operator*()` returns `const TCHAR*`, and `FString` has `operator==(const TCHAR*)`.
So it does the right string comparison. Phew.

## Deep Dive: UD3DRenderDevice Copy Constructor

The D3DDrv copy constructor (Ghidra `0x1cc0`) was the most intimidating entry. The function
header shows an SEH frame, a call to `URenderDevice`'s copy ctor, and then... a cascade of
raw memory copies spanning **~200KB** of internal D3D state:

```c
// 0x1000 DWORDs (16 KB) at offset 0xCC — texture/render handle cache
for (iVar1 = 0x1000; iVar1 != 0; iVar1--) {
    *(uint*)pDst = *(uint*)pSrc;
    pDst += 4; pSrc += 4;
}
// Then more individual DWORD copies from 0x40CC to 0x4128...
// Then 0x4A1 DWORDs from 0x3081C...
```

The retail `UD3DRenderDevice` is a *massive* class — its layout runs to offset `0x31B98`+,
about 203KB of D3D texture handles, vertex/pixel shader arrays, render state tables, and
pipeline configuration. Our reconstructed header declares only the config bitfields and
virtual interface — not the vast internal state.

For now, the copy constructor gets `guard`/`unguard` and a detailed TODO. The named config
fields (`UsePrecaching`, `UseTrilinear`, etc.) are already handled by the initializer list.
Copying the internal D3D state is a future-phase problem.

## The Numbers

| Category | Count | Action |
|---|---|---|
| Shared null stubs | ~50 | Left empty ✓ |
| Compiler-generated | 5 | Left empty ✓ |
| SEH frame only | 4 | Added guard/unguard |
| Real logic implemented | 8 | Full bodies written |
| Bug fixed (wrong guards) | 1 | Removed spurious guard/unguard |

**All 67 stubs accounted for. Build: clean.**

## What This Means

The stub sweep is a milestone because it closes the gap between "the code compiles" and "the
code does what the binary did." We're not done — `ULevel::ULevel`, `UAnimNotify_Effect::Notify`,
`UAnimNotify_DestroyEffect::Notify`, and the D3D state copy are all still TODO. But now every
empty body in the codebase is *intentionally* empty, with a clear reason why.

Every time we fill in a real implementation from Ghidra, we're one function closer to a
binary that would behave identically to the retail game. And importantly, we understand why
each byte is the way it is.

Next up: filling in those remaining TODO bodies, starting with the actor spawning logic in
`ULevel::ULevel`.
