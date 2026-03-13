---
slug: 57-lighting-visibility-and-bone-blending
title: "57. Lighting, Visibility, and Bone Blending"
authors: [dan]
tags: [decompilation, engine, rendering, animation, lighting]
---

We've been pushing through the Engine stub backlog — those `return 0` or `return NULL`
bodies scattered across five key source files.  This post covers the most interesting
ones we implemented this session, along with a lightning tour of *why* they're designed
the way they are.

<!-- truncate -->

## What Is a "Stub"?

When we first reconstructed a source file, we needed the C++ to compile.  That meant
every function had to *exist*.  For functions we hadn't reverse-engineered yet we wrote
placeholders:

```cpp
float FDynamicLight::SampleIntensity(FVector, FVector) { return 0.0f; }
int   UConvexVolume::IsPointInside(FVector, FMatrix)   { return 0;    }
```

These compile, they link, they even run — they just return a useless constant instead of
the real answer.  The goal of this session was to replace as many of them as possible with
the real logic from Ghidra.

## How Ghidra Export Works

Ghidra is a free reverse-engineering tool from the NSA (yes, really).  We point it at the
retail `Engine.dll`, let it analyse the binary, then export a C-like pseudo-code file —
`ghidra/exports/Engine/_global.cpp` — about 258,000 lines long.  It's *not* valid C++, but
it's close enough to read:

```c
/* public: int __thiscall UConvexVolume::IsPointInside(class FVector, class FMatrix) */
int __thiscall UConvexVolume::IsPointInside(UConvexVolume *this) {
  ...
  if (0.0 < fVar4) {
    return 0;    /* outside */
  }
  ...
  return 1;      /* inside */
}
```

Our job is to translate that into clean, buildable C++.

---

## Bone Channel Blend Parameters

`USkeletalMeshInstance::SetBlendParams` controls how an animation *channel* is blended
into the final pose.  A "channel" is one layer of animation — channel 0 is the base pose,
channel 1 might be an aim overlay, channel 2 a facial expression, and so on.

```cpp
int USkeletalMeshInstance::SetBlendParams(
    INT Channel, FLOAT Alpha, FLOAT UScale, FLOAT VScale,
    FName BoneRef, INT bBlend)
```

What Ghidra reveals:

1. **Validate the channel** — `ValidateAnimChannel` grows the TArray at `this+0x10C` so
   the slot exists.
2. **Channel 0 is special** — it's the base pose and can't have blend params.  The retail
   binary logs a warning; we return 0.
3. **Resolve the bone reference** — `MatchRefBone(BoneRef)` walks `mesh->RefBoneNames` to
   turn a name like `"Spine"` into an integer index.  If not found, default to 0.
4. **Clamp UV scales to `>= 1.0`** — UV scale less than 1.0 would produce sub-texel
   sampling, which the original engine treated as an error.
5. **Write into the channel slot** — each channel element is 0x74 bytes (116 bytes).
   Fields at `+0x50` (alpha), `+0x54` / `+0x58` (UV scales), `+0x68` (bone index),
   `+0x4C` (blend flag).

The raw-offset access pattern looks ugly but it's faithful: the retail binary was compiled
from the same class layout we're reconstructing, so the byte offsets are ground truth.

---

## Actor Visibility Filtering

`FLevelSceneNode::FilterActor` decides whether an actor gets submitted to the renderer.
It's called thousands of times per frame — once for every actor in the world.  The retail
function is about 220 bytes of conditional branches.

The logic, condensed:

```
if (!GIsEditor && actor is fully hidden) → cull
if zone limits fail for actor's LOD group → cull
if ShowFlags has BSP-only bit but actor isn't ABrush or AStaticMeshActor → cull
if Karma body is invisible by flag → cull
// In-game path:
if bHidden → cull
if bHiddenEdTemporary → cull
if actor has a Tag filter and name doesn't match → cull
if actor should only be seen by its owner and current camera isn't the owner → cull
```

There's also a subtle "owned actor" visibility case.  Some props are parented to a Pawn
and should only be rendered from that Pawn's camera.  The function checks
`Actor->IsOwnedBy(cameraActor)` and cross-references a `ShowOwnedActors` flag from the
level info.

The editor path (when `GIsEditor != 0`) is separate — it applies different show/hide
rules based on the editor viewport's ShowFlags bitmask rather than in-game bHidden flags.

We also needed to add an `extern` declaration for `GHideHiddenInEditor` — a Core.dll
global that Ghidra references as `GHideHiddenInEditor_exref` (its import thunk).  It
wasn't in the SDK headers but *is* exported from `Core.dll`, so a plain `extern CORE_API
UBOOL` declaration does the job.

---

## Lightmap Texture Lookup

`FLightMapTexture::GetChild(int Index, int* OutWidth, int* OutHeight)` is the plumbing
behind Unreal's precomputed lighting.  At runtime, the renderer asks the lightmap for
individual face textures — one per BSP face.

The Ghidra decompilation showed a compact 56-byte function:

```c
iVar2 = *(int *)(*(int *)(this + 8) + param_1 * 4);   // face index from array
iVar1 = *(int *)(*(int *)(*(int *)(this + 4) + 0x90) + 0xF4); // level's tex base
pFVar3 = (FTexture *)(iVar2 + iVar1);                  // tex element = base + offset
*param_2 = *(int *)(pFVar3 + 0x14);                    // USize
*param_3 = *(int *)(pFVar3 + 0x18);                    // VSize
*(int *)(pFVar3 + 4) = *(int *)(this + 4);             // write back level ptr
return pFVar3;
```

Each "child" is a static lightmap texture element: a flat struct of 0xA4 (164) bytes
inside a ULevel-managed array.  The level pointer is written back into element+4 each
time the child is fetched — a lazy initialisation trick to avoid storing it twice.

---

## Dynamic Light Sampling

`FDynamicLight::SampleIntensity(FVector Point, FVector Normal)` computes how much
intensity a single point on a surface receives from a dynamic light.  It's used by the
CPU-side lighting path (not the shader path) for things like radiosity precomputation
and lightmap generation.

The function is type-dispatched via a byte stored 0x37 bytes into the vtable descriptor:

```cpp
BYTE lightType = *(BYTE*)(*(BYTE**)this + 0x37);
```

Three light types are clearly decompiled:

### Directional Light (type 0x14)

```cpp
// Lambert: N·L, return |2 * dot| when surface faces light
FLOAT dot = Normal.X * Dir.X + Normal.Y * Dir.Y + Normal.Z * Dir.Z;
if (dot < 0.0f) return dot * -2.0f;
```

The factor of 2 is an intensity normalisation specific to UE2's precomputed lighting scale.

### Cylinder Light (type 0x11)

```cpp
// 3D distance check, but 2D (XY) falloff
FLOAT dist3D = appSqrt(dx*dx + dy*dy + dz*dz);
if (dist3D < Radius) {
    FLOAT r_sq   = dx*dx + dy*dy;             // XY only
    FLOAT falloff = 1.0f - r_sq / (R * R);
    return falloff + falloff;                  // *2 for same scale
}
```

The cylinder light illuminates a vertical column — think street lamps or ceiling strips.
The height (Z) only matters for the range check, not the falloff.

### Cone Light (type 0x0D)

```cpp
FLOAT dot = dot(delta, Normal);
if (dot > 0 && dist < Radius)
    return appSqrt(1.02f - dist / Radius) * 2.0f;
```

The `1.02f` offset prevents the falloff hitting exactly zero at the edge and creating a
sharp discontinuity.

### The Mystery of FUN_1040d530

The remaining light types use an internal helper `FUN_1040d530` that Ghidra can't name.
It's called *without arguments* — relying on the x87 FPU register stack to pass the
distance value.  This is a common trick in hand-optimised x86: `appSqrt` leaves its
result in `st(0)`, and the next function call consumes it directly without a `push`.

Since we can't replicate x87 FPU stack passing in C++, we approximate with:

```cpp
// DIVERGENCE: FUN_1040d530 not identified; linear falloff substituted
FLOAT baseFalloff = (Radius > 0.0f) ? (1.0f - dist / Radius) : 0.0f;
```

This gives the *correct shape* of the falloff (zero at the edge, 1.0 at the origin) but
may differ from the retail quadratic/custom curve.  It's good enough for now.

---

## Convex Volume Point Test

`UConvexVolume::IsPointInside(FVector Point, FMatrix Matrix)` checks whether a world-space
point lies inside a convex shape.  The shape is stored as an array of planes
(`FPlane`, 16 bytes each, with 12 bytes of padding = 28 bytes per element).

The algorithm is the classic half-space test:

```cpp
for each plane {
    FPlane transformed = plane.TransformBy(Matrix);
    if (transformed.PlaneDot(Point) > 0.0f)
        return 0;  // outside this plane → outside the volume
}
return 1;           // all planes pass → inside
```

The matrix transform converts the planes from object space to world space before testing.
If the point is on the *positive* side of any plane, it's outside the convex hull.

One subtlety from Ghidra: `count = planes->Num()` is re-fetched inside the loop.  This
is unusual but matches the retail pattern — probably a defensive guard against someone
modifying the array during iteration (though that shouldn't happen in practice).

---

## What Stayed As Stubs

Not everything was implementable this session:

| Function | Reason |
|---|---|
| `FRawIndexBuffer::Stripify` | Calls `FUN_1048d8b0/c0` — these are the NvTriStrip library functions for converting triangle lists to strips. External dependency. |
| `USkeletalMeshInstance::UpdateAnimation` | 200+ lines of complex blending, bone transforms, and root motion. Needs its own session. |
| `USkeletalMeshInstance::LineCheck` | Per-bone cylinder intersection test — depends on `GetBoneCylinder` being fully implemented first. |
| `USkeletalMeshInstance::AnimForcePose` | Involves FPU stack tricks and complex vtable dispatch chains. |
| `UMeshInstance` base class stubs | Confirmed as genuine `return 0` thunks in the retail binary (all share RVA 0x4720). No implementation needed. |

The `UMeshInstance` base class stubs deserve a note: Ghidra confirms that **all**
of `StopAnimating`, `UpdateAnimation`, `LineCheck`, `PlayAnim`, `PointCheck`,
`AnimForcePose`, `GetMesh`, `GetStatus`, etc. — the entire base class — shares a
single RVA.  Every one of these is a pure virtual thunk that returns 0/NULL.
The actual implementations live in `USkeletalMeshInstance`, `UVertMeshInstance`,
and `ULodMeshInstance`.  Our stubs are already correct.

---

## Numbers

- **6 functions implemented** with real logic (from 0 before)
- **`return 0` stubs preserved**: ~30 confirmed correct via Ghidra
- **Build**: 0 errors, 15206 linker warnings (pre-existing, unrelated to this session)
- **Lines added**: +238 across 2 files

Progress is incremental but measurable.  Each implemented function is one fewer
approximation between our source and the retail binary.
