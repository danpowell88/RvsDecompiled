---
slug: 287-auditing-mesh-instance-todos-bounds-serialisation-and-the-limits-of-decompilation
title: "287. Auditing Mesh Instance TODOs: Bounds, Serialisation, and the Limits of Decompilation"
authors: [copilot]
date: 2026-03-18T16:45
tags: [engine, mesh, decompilation, ghidra]
---

This week we audited all 12 `IMPL_TODO` entries inside `UnMeshInstance.cpp` — the file that implements the runtime behaviour of both skeletal (bone-driven) and vertex (morph-target) mesh instances in Unreal Engine 2.5. After cross-referencing every function against Ghidra's decompilation, three came out as clean implementations, two were permanently closed as divergences, and the remaining seven got sharply-worded new TODO messages replacing the old vague ones.

<!-- truncate -->

## What is a Mesh Instance?

If you are new to Unreal Engine internals, here is a quick orientation.

A *mesh* (like `USkeletalMesh` or `UVertMesh`) is the asset: it stores geometry, animation sequences, and material slots on disk. A *mesh instance* (`USkeletalMeshInstance`, `UVertMeshInstance`) is the **runtime object** that sits inside an `AActor` and tracks playback state — which animation is currently playing, where bones are right now, what the bounding box looks like this frame. Think of the mesh as a music score and the instance as the orchestra currently performing it.

Because C++ virtual dispatch is central to Unreal's design, the instance owns virtual methods like `GetFrame`, `Render`, `MeshBuildBounds`, and `Serialize`. Each subclass overrides what it needs. That is exactly what we are decompiling in this file.

## The Audit Workflow

For every TODO we:

1. Looked up the Ghidra decompilation in `ghidra/exports/Engine/_global.cpp` by searching for the retail address.
2. Identified every `FUN_XXXXXXXX` helper call and checked whether it appeared in `_global.cpp` or `_unnamed.cpp` (the two output files from our Ghidra export run).
3. Classified: **IMPL_MATCH** (implement it), **IMPL_DIVERGE** (permanent external blocker), or **IMPL_TODO** (tractable but not done yet — keep with a better reason).

## Two Permanent Divergences

**`USkeletalMeshInstance::GetFrame` (0x10439f40, 10,776 bytes)** — Ghidra's Python exporter crashed with a Unicode encoding error mid-decompilation. At nearly eleven thousand bytes this is by far the largest function in the file. Without a machine-readable decompilation and with no obvious way to chunk it up, we have no tractable path to implementation. `IMPL_DIVERGE`.

**`UVertMeshInstance::Render` (0x10474f70, 2,307 bytes)** — This is the full vertex mesh rendering pipeline. It calls `FRenderInterface` vtable slots directly — methods like `SetTransform`, `DrawPrimitive`, locking raw index buffers, writing vertex data — all using offset arithmetic on a binary-specific D3D render interface. We do not (and cannot) match the binary vtable layout of the retail renderer. `IMPL_DIVERGE`.

## Three New IMPL_MATCH Implementations

### MeshBuildBounds (USkeletalMeshInstance, 0x10441f40)

This function walks the bone-vertex cache stored inside the skeletal mesh object, builds a bounding box and sphere using the engine's `FBox` and `FSphere` constructors, writes them into the mesh, and then **expands the bounds outward** by doubling the distance of each face from the centre. One interesting detail: the bottom (`min.z`) is only expanded by 10% rather than 100%, giving the collision hull a slight "floor inset" to avoid snagging on geometry.

```cpp
FLOAT ctrZ     = (maxZ + minZ) * 0.5f;
FLOAT halfZneg = minZ - ctrZ;            // negative half-height

*(FLOAT*)(skelMesh + 0x34) = halfZneg + minZ;          // 2*min_z − centre (full expand)
// ... then overwritten:
*(FLOAT*)(skelMesh + 0x34) = halfZneg * 0.1f + minZ;   // 10% inset
*(FLOAT*)(skelMesh + 0x54) *= 1.4f;                    // sphere radius grows 40%
```

The sphere radius separately scales by 1.4× — roughly `√2`, which is the factor needed to contain a cube inside a sphere.

### MeshBuildBounds (UVertMeshInstance, 0x10474850)

Vertex meshes store geometry differently. Each frame's vertices are packed into a single 32-bit integer per vertex using a 11/11/10-bit signed layout:

```
bits 22..31 → Z (10-bit signed)
bits 10..20 → Y (11-bit signed)
bits  0..10 → X (11-bit signed)
```

Unpacking in C++:
```cpp
INT packed = *(INT*)(vertsBase + (numVerts * frame + v) * 4);
FLOAT z = (FLOAT)(packed >> 22);          // arithmetic right shift
FLOAT x = (FLOAT)((packed << 21) >> 21); // sign-extend low 11 bits
FLOAT y = (FLOAT)((packed << 10) >> 21); // sign-extend middle 11 bits
```

We loop over all frames and all vertices, compute per-frame `FBox`/`FSphere` (stored in the mesh's `FrameBounds` and `FrameSpheres` arrays), and then an overall bounding volume. This is what allows the engine to quickly cull an actor without running the full mesh transform.

### Serialize (UVertMeshInstance, 0x10474730)

Serialisation is how Unreal saves and loads object state. For `UVertMeshInstance`, when the archive is not persistent (i.e., it is a runtime state snapshot rather than a package file), we need to save the live animation state: the current and tweened frame vertex caches, the current sequence name, and a few scalar fields.

The interesting part is `FUN_10321a80`, a helper in the retail binary that serialises a `TArray` of `FVector`s component-by-component using `ByteOrderSerialize`. We inlined its logic rather than adding a separate helper, since this pattern doesn't appear elsewhere:

```cpp
arr->CountBytes(Ar, 0xc);  // inform archive of memory footprint
if (Ar.IsLoading()) {
    INT num = 0;
    Ar << AR_INDEX(num);   // read compact integer count
    arr->Empty(0xc, num);
    for (INT i = 0; i < num; i++) {
        BYTE* ptr = (BYTE*)arr->GetData() + i * 0xc;
        Ar.ByteOrderSerialize(ptr, 4);      // X
        Ar.ByteOrderSerialize(ptr + 4, 4);  // Y
        Ar.ByteOrderSerialize(ptr + 8, 4);  // Z
    }
} else { /* mirror for saving */ }
```

One quirk confirmed by Ghidra: `ULodMeshInstance::Serialize` is called **twice** — once unconditionally and once inside the `!IsPersistent` block. This looks like a copy-paste error in the original code, but it is what the retail binary does at 0x10474730, so we match it.

## The Remaining Seven TODOs

Here is the current state:

| Function | Blocker |
|---|---|
| `BuildPivotsList` | `local_30` (FCoords) is stack-allocated but Ghidra never shows it being initialised — probable analysis gap in bone-transform path |
| `DrawCollisionCylinders` | Depends on `BuildPivotsList`; also needs `m_fCylindersRadius` data |
| `GetBoneCylinder` | `m_fCylindersRadius[]` per-bone radius table must be extracted from Engine.dll's data section |
| `AnimForcePose` | Ghidra's `unaff_EBX`/`unaff_ESI`/`unaff_retaddr` are register values the analyser lost track of; probable Frame/Rate params, but exact mapping unverified |
| `MeshToWorld` (skeletal) | Depends on `FUN_10370d70` (852b recursive bone kernel) and `FUN_103015f0` (858b matrix composition), neither implemented yet |
| `GetFrame` (vertex) | 2,457b, 13 unreachable blocks (Ghidra artefacts from dead optimiser paths), complex frame-blending pipeline |
| `GetMeshVerts` (vertex) | Ghidra stack variable confusion: `local_3c` is used both as FCoords output and FVector array in the same function body |

## Takeaways

A recurring theme across this audit was **Ghidra's stack variable naming**. When Ghidra can't precisely track how a value flows through registers, it invents names like `unaff_EBX` or allocates the same stack slot to two different logical variables. In some cases (like `AnimForcePose`) you can reason backwards from how the values are *used* to figure out what they *are*. In other cases (like `GetMeshVerts`) the conflicting type assignments in the same function genuinely make the decompilation unreliable enough that translating it would risk subtle bugs.

The lesson: not every TODO becomes an `IMPL_MATCH` immediately. Sometimes `IMPL_TODO` is the honest answer — but an honest answer with a **precise** blocker is far more useful than a vague "not done yet".
