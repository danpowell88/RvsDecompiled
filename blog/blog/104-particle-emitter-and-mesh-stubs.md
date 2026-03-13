---
slug: 104-particle-emitter-and-mesh-stubs
title: "104. Breathing Life into Particles and Meshes"
authors: [dan]
date: 2026-03-14T06:30
tags: [decompilation, particles, emitters, mesh, stubs, ghidra]
---

Some stubs are three lines. Some are three hundred. This post covers a batch that
skewed heavily toward the latter — the particle emitter hierarchy and several mesh
utility functions, all pulled from Ghidra and wired back into the build.

<!-- truncate -->

## What's a Stub, Again?

In a decompilation project, you don't always have the luxury of implementing
everything at once. When you reverse-engineer a DLL you're building a **skeleton**:
the right types, the right function signatures, the right vtable layout — but most
bodies start as:

```cpp
int SomeClass::SomeFunction(float) { return 0; }
```

These are **stubs**. They compile. They link. The game might crash if it calls them,
but the build stays green while you work through things in order. Gradually you
replace each stub with a real implementation derived from the Ghidra decompilation
output.

Today was a big stub-replacement day.

## The Particle Emitter Hierarchy

Ravenshield uses Unreal Engine 2.5's particle system. The class hierarchy looks like:

```
UObject
  └── UParticleEmitter    (base: manages particle pool, timing, bounding box)
        ├── UBeamEmitter   (lightning-style beams between points)
        ├── UMeshEmitter   (spawns copies of a mesh at each particle)
        ├── USparkEmitter  (spark trails, like ricochet effects)
        └── USpriteEmitter (flat quads, the bread-and-butter particle)
```

`AEmitter` is the actor container — it sits in the world, holds an array of
`UParticleEmitter*` objects, and drives the whole show each tick.

### The Tick Loop: Where the Magic Happens

`AEmitter::Tick` is the main update function. At nearly 200 lines reconstructed,
it's one of the meatier single functions we've implemented so far. The rough flow:

1. **Call the base `AActor::Tick`** — handles physics, networking, standard actor
   update. If it returns 0 (the actor is inactive or paused), bail out.

2. **Initialize if needed** — the first time through, call `Initialize()` via
   vtable to set up the emitter list.

3. **Loop over all sub-emitters** — for each `UParticleEmitter*` in the array,
   skipping disabled ones (flag `0x1000` in the property DWORD at offset `0x64`).

4. **Update particles** — call `UpdateParticles(DeltaTime)` via vtable slot 25 if
   the emitter isn't frozen.

5. **Handle spawning vs. inactive state** — the flag at `em + 0x2dc` tracks whether
   the emitter is active (flag `0x8u == 0`) or waiting to respawn. In the active
   branch, we call `SpawnParticle()` and accumulate a "blocking" flag if this
   emitter has collision. In the inactive branch, we count down a respawn timer.

6. **Collision cylinder update** — if any emitter is "blocking" (can be hit by
   traces), compute the bounding box extents and grow the actor's collision cylinder
   to match. This is what lets players actually shoot particle effects in the game.

7. **Master bounding box** — each active sub-emitter's bbox gets folded into the
   actor's master bbox for renderer culling.

Here's a small taste of the vtable dispatch pattern that's used throughout:

```cpp
// Call UpdateParticles via vtable slot 25 (byte offset 100 = 0x64 from vtable start)
typedef void(__thiscall* UpdateFn)(void*, FLOAT);
UpdateFn upFn = *(UpdateFn*)((*(INT*)em) + 100);
upFn((void*)em, DeltaTime);
```

This is raw C++ vtable dispatch — the style Ghidra generates when it can't resolve
virtual calls cleanly. We read the vtable pointer from the object, add the slot's
byte offset, and call through a function-pointer typedef. It's ugly but honest.

### Pointer Arithmetic Gotcha: The `em + 0x19` Trap

One thing worth noting for anyone following along: in the Ghidra output, the
per-emitter pointer `em` is typed as `INT*`. This means `em + 0x19` is
**INT-pointer arithmetic** — it advances by `0x19 * 4 = 100 = 0x64` bytes, not
19 bytes.

To keep the code readable and avoid accidents, all offset math in our implementation
uses explicit byte casts like `*(DWORD*)(em + 0x64)` throughout. The Ravenshield
engine's existing `AEmitter::Kill` function (already implemented) uses the same
`BYTE*` style, so we follow that convention.

### UpdateParticles Family

Each subclass overrides `UpdateParticles(float DeltaTime)` to do its own geometry
work, then usually calls `UParticleEmitter::UpdateParticles` as the base:

- **`UParticleEmitter::UpdateParticles`** — initialises the bounding box, clamps
  the target actor index, then sets up for the particle loop (TODO: the main
  loop body involves `SpawnParticles`, which is its own large function).

- **`UBeamEmitter::UpdateParticles`** — sums beam widths, syncs render arrays, then
  calls the base and expands the bbox by querying each colour range's `Size()`.
  Uses `FRange::Size()` which we exposed in `EngineDecls.h` (along with
  `GetCenter()` and `GetMax()`):

  ```cpp
  FLOAT sizeR = ((FRange*)((BYTE*)this + 0x3a4))->Size();
  ```

- **`USpriteEmitter::UpdateParticles`** — reads the max height/width from `FRange`
  parameters and calls `FBox::ExpandBy(fMaxH)` to grow the bbox:

  ```cpp
  FBox expanded = ((FBox*)((BYTE*)this + 0x304))->ExpandBy(fMaxH);
  *(FBox*)((BYTE*)this + 0x304) = expanded;
  ```

### The FRange Extension

`FRange` is a Ubisoft-custom type (not standard UE2) that represents a random range
with a min and max. It lives in `Core.dll`. Our `EngineDecls.h` stub only declared
`GetRand()` and `GetSRand()`. Today we added the three missing methods that the
emitter code needs:

```cpp
class CORE_API FRange
{
public:
    FLOAT Min;
    FLOAT Max;
    FLOAT GetRand() const;
    FLOAT GetSRand() const;
    FLOAT GetCenter() const;  // (Min + Max) / 2
    FLOAT GetMax() const;     // returns Max
    FLOAT Size() const;       // Max - Min
};
```

These are declared `CORE_API` so they resolve to the actual `Core.dll` exports at
link time — we never need to write the bodies.

## Mesh Stubs

On the mesh side, several functions went from placeholder to real:

### `UVertMesh::RenderPreProcess`

This builds a lookup table used by the renderer — it groups mesh faces by material
section, filling in a `_WORD*` array of section descriptors. One subtlety: if the
output array already has entries (non-zero count), we skip processing. This is the
classic "do-once" guard you see throughout the mesh pipeline.

The function uses `_WORD` (Ravenshield's `unsigned short`) rather than the Windows
`WORD` macro, since the engine's core headers define `_WORD` not `WORD`. Worth
remembering if you ever write engine code from scratch.

### `USkeletalMesh::LineCheck` and `R6LineCheck`

Both are collision detection entry points:

- **`LineCheck`** — checks whether the actor is in ragdoll physics mode
  (`PHYS_KarmaRagDoll = 14`). If not ragdoll, delegate to the base
  `UPrimitive::LineCheck`. If ragdoll, there's a TODO for the Karma physics
  collision path (not yet reverse-engineered).

- **`R6LineCheck`** — a Ravenshield-specific variant that additionally checks a
  hit-detection flag (`0x10000`) and an actor's bitmask property at `+0xa8`. If
  both are set, we'd do per-bone skeletal hit detection. For now, also a TODO.

### `CBoneDescData::fn_bInitFromLbpFile`

LBP files are Ubisoft's custom text-based bone-descriptor format. This function:

1. Loads the whole file into an `FString` via `appLoadFileToString`
2. Splits it by newline using `FString::ParseIntoArray`
3. Reads bone count from line 0, frame count from later lines
4. Allocates raw memory grids: `frameCount` arrays of `boneCount * 0x1c` bytes
5. Calls `m_vProcessLbpLine` for each frame/bone combination to parse the
   per-frame bone transform data

```cpp
for (INT frame = 0; frame < frameCount; frame++)
    for (INT bone = 0; bone < boneCount; bone++)
    {
        INT lineIdx = boneCount * (frame + 1) + 5 + bone;
        m_vProcessLbpLine(frame, bone, lines(lineIdx));
    }
```

The `m_vProcessLbpLine` function was already implemented in a previous session —
it parses position and quaternion fields from whitespace-separated tokens on each
line, including axis flips to match Ravenshield's coordinate space.

### `CCompressedLipDescData::m_bReadCompressedFileFromMemory`

Lip sync data is stored as a compact binary blob. The function reads fields via
`appMemcpy` (avoiding alignment issues on the unstructured data), then allocates
a heap array of `count << 4` bytes (16 bytes per entry) for the main data, and
per-entry sub-arrays for the curve sample data.

One small quirk: reading a `SWORD` (signed 16-bit) value uses a 4-byte `appMemcpy`
into a 2-byte variable — this copies a DWORD's worth of bytes but only the first
two matter. This matches the Ghidra disassembly exactly.

## Why Not Just Leave Them as Stubs?

Fair question. A few reasons:

1. **Future correctness** — stubs that return 0 can silently suppress game
   behaviour in subtle ways. Implementing them faithfully means the game loads
   closer to the original.

2. **Build documentation** — the implementations serve as inline Ghidra references.
   The TODOs mark exactly what's missing; the implemented parts show what we know.

3. **Progress is satisfying** — watching 22KB grow to 28KB in a source file because
   you filled in real logic feels good.

## What's Next?

The main particle loop bodies (`SpawnParticles`, the per-particle update loop in
`UpdateParticles`) are the next large targets. The beam and sprite rendering
functions are each 500–700 lines of Ghidra output — complex enough to warrant
their own session. The Karma ragdoll line check path also needs work when the
physics integration matures.

For now: the build is green, the stubs are gone, and 23 more functions are closer
to byte accuracy.
