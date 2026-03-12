---
slug: geometry-and-delegation
title: "Post 38: The Box, The Matrix, and the Chain of Delegation"
authors: [dan]
tags: [decompilation, geometry, math, x86, reverse-engineering, c++, meshes, patterns]
---

Batches 122 through 127 cover a lot of ground — literally. We fixed terrain coordinate transforms, collision bounding boxes, virtual render delegation, an inverted null check, and a coordinate system function that copies from a global identity matrix. Sounds random? There's actually a set of beautiful recurring patterns hiding in all of it.

<!-- truncate -->

## The REP MOVSD Pattern: Struct Returns Without a Copy Constructor

Let's start with the most common pattern in this session. A lot of binary operations return structs like `FBox`, `FSphere`, or `FVector` by value. If you wrote that code in modern C++ you might use a copy constructor or `std::copy`. But in the retail Raven Shield engine (compiled with MSVC 7.1 in 2003), the compiler has a preferred idiom for copying structs to a return buffer:

```asm
MOV ECX, 7           ; 7 DWORDS = 28 bytes = FBox (Min+Max+IsValid)
LEA ESI, [this+0x2C] ; source: cached bounds in the object
MOV EDI, retbuf      ; destination: caller's FBox storage
REP MOVSD            ; copy 4 bytes × 7 = 28 bytes
```

This is `REP MOVSD` — the x86 *repeat move doubleword* instruction. It copies `ECX` 32-bit words from `[ESI]` to `[EDI]`, advancing both pointers automatically. For returning a struct, the caller passes a hidden extra argument (usually via `[ESP+4]`) that's a pointer to space it allocated. The callee fills that space.

Once you see this pattern once, you'll spot it everywhere:
- `UStaticMesh::GetRenderBoundingBox` — 7 DWORDs from `this+0x2C`
- `UConvexVolume::GetRenderBoundingBox` — 7 DWORDs from `this+0x70`
- `UProjectorPrimitive::GetCollisionBoundingBox` — 7 DWORDs from `this+0x470`
- `UFluidSurfacePrimitive::GetCollisionBoundingBox` — 7 DWORDs from dereferenced `*(this+0x58)+0x448`

All of these look the same in the disassembly. The only thing that changes is the source offset and how we get there (direct field vs. pointer indirection).

## FBox and FSphere: The Bounding Volume Structs

An `FBox` is Unreal's axis-aligned bounding box: a `Min` vector, a `Max` vector, and a 4-byte validity flag — 7 `DWORD`s = 28 bytes. Our default stub was `return FBox()` which creates an invalid, zero-sized box. The retail code copies a *pre-computed cached* box from the object's fields.

An `FSphere` is a center point plus a radius — 4 floats = 16 bytes — and some functions copy it using a different method (via an import thunk calling FCore's copy constructor). The retail stubs for `UStaticMesh::GetRenderBoundingSphere` and `USkeletalMeshInstance::GetRenderBoundingSphere` load a cached `FSphere` from `this+0x48`.

For objects that don't cache their bounds directly — like `USkeletalMesh` — the pattern is different. Those delegate upward.

## The Delegation Chain: When Meshes Don't Hold Their Own Bounds

One of the more interesting patterns in batches 126 and 127 was the insight that *not all mesh types own their bounds*. In Raven Shield's object hierarchy:

- A **mesh definition** (like `USkeletalMesh`) knows how to create instances, but doesn't render itself
- A **mesh instance** (like `USkeletalMeshInstance`) holds the runtime state for a specific actor

So what does `USkeletalMesh::GetRenderBoundingBox(Actor*)` look like in retail? Let's decode:

```asm
MOV EAX, [ECX]              ; vtable of this (USkeletalMesh)
PUSH ESI
MOV ESI, [ESP+0xC]          ; Actor* arg
PUSH ESI                    ; push Actor* for the call
CALL [EAX+0x88]             ; vtable[34] = MeshGetInstance(Actor*)
; EAX now = UMeshInstance*
MOV EDX, [EAX]              ; vtable of the returned instance
PUSH ESI                    ; Actor* again
LEA ESI, [ESP+?]; ... PUSH   ; push retbuf
MOV ECX, EAX               ; ECX = the instance
CALL [EDX+0x6C]             ; vtable[27] = GetRenderBoundingBox on the instance
```

In clean C++ this is:

```cpp
FBox USkeletalMesh::GetRenderBoundingBox(const AActor* Owner) {
    return MeshGetInstance(Owner)->GetRenderBoundingBox(Owner);
}
```

The mesh delegates to its per-actor instance, which in turn can look up the cached bounds. This is the "delegation chain": the static asset knows nothing about runtime bounding; only the live instance does.

`UMeshInstance::GetRenderBoundingBox` in turn delegates inward:

```cpp
FBox UMeshInstance::GetRenderBoundingBox(const AActor* Owner) {
    return GetMesh()->GetRenderBoundingBox(Owner);  // vtable[27] on the mesh
}
```

And `USkeletalMeshInstance::GetRenderBoundingBox` short-circuits the chain by reading directly from the mesh's cached bounds:

```cpp
FBox USkeletalMeshInstance::GetRenderBoundingBox(const AActor*) {
    return *(FBox*)((BYTE*)GetMesh() + 0x2C);  // REP MOVSD 7 DWORDs again
}
```

Three classes, three implementations, one logical answer — wherever you ask for bounds, you eventually get the cached `FBox` at mesh+0x2C.

## Coordinate Transforms: FCoords and TransformPointBy

`ATerrainInfo` stores the terrain grid in *heightmap space* (a regular grid of height values) but operates in *world space* (the game's 3D coordinate system). To convert between them, it stores two pre-computed `FCoords` matrices:

- At `this+0x1300`: the *heightmap-to-world* transform
- At `this+0x1330`: the *world-to-heightmap* transform  

(Note: 0x1330 − 0x1300 = 0x30 = 48 bytes = exactly `sizeof(FCoords)`. These two live side by side.)

The retail code uses `FVector::TransformPointBy(const FCoords&)` which is an import from Core.dll. In our C++ code:

```cpp
FVector ATerrainInfo::WorldToHeightmap(FVector In) {
    return In.TransformPointBy(*(FCoords*)((BYTE*)this + 0x1330));
}

FVector ATerrainInfo::HeightmapToWorld(FVector In) {
    return In.TransformPointBy(*(FCoords*)((BYTE*)this + 0x1300));
}
```

A `FCoords` is Unreal's coordinate frame struct: an origin point plus three axis vectors (X, Y, Z). `TransformPointBy` takes a point in one space and re-expresses it in another, using the axes and origin of the target frame. It's the classic basis-change multiplication from linear algebra — just done with Unreal's left-handed coordinate system.

## The FMatrix::Identity Pattern

`UMeshInstance::MeshToWorld()` returns an `FMatrix` — the base-class default mesh-to-world transform. The retail code doesn't compute anything; it copies 16 DWORDs (64 bytes = a 4×4 float matrix) from a global address in the import table. That global is `FMatrix::Identity` — the multiplicative identity, equivalent to "no transformation at all":

```asm
MOV ESI, [0x10529050]   ; IAT entry: address of FMatrix::Identity in Core.dll
MOV ECX, 16             ; 16 doubles = 64 bytes
MOV EDI, retbuf
REP MOVSD               ; copy the identity matrix
```

In C++: `return FMatrix::Identity;`

The `MOV ESI, [IAT_entry]` idiom is the indirect access pattern for cross-DLL global variables. MSVC emits `MOV EAX, [__imp__FMatrix_Identity]` → EAX = address of the variable → REP MOVSD from there. Our C++ just says `FMatrix::Identity` and the compiler handles the rest.

## The Inverted Null Check Bug

Batch 123 caught a subtle logical inversion in `UDemoRecConnection::FlushNet`:

```cpp
// WRONG (what we had):
if (Driver->ServerConnection == NULL) UNetConnection::FlushNet();

// CORRECT (retail):
if (Driver->ServerConnection != NULL) UNetConnection::FlushNet();
```

When does a demo recording connection have a non-null `ServerConnection`? When it's playing back a recorded demo — the machine is acting as a "demo client" connected to a fake server. In that case, flushing the net buffer makes sense. The null case is when there's no server connection yet (probably during setup), and you shouldn't flush nothing.

This was just one instruction difference: the retail uses `JNZ` (jump if not equal) and our stub had `JZ` (jump if equal). Easy to miss but meaningfully wrong in gameplay.

## The Cross-Function-Jump: The "Else That Isn't There"

One other pattern worth calling out from batch 123 is what we call the *cross-function-jump*. Several `FTerrainTools` setters looked like this:

```cpp
// WRONG:
void FTerrainTools::SetAdjust(int Value) {
    if (*(INT**)(&Pad[0]))
        *(INT*)((BYTE*)(*(INT**)&Pad[0x50]) + 0x60) = Value;
    else
        *(some_fallback) = Value;  // else branch didn't exist in retail!
}
```

The retail disassembly showed a `JZ +offset` that jumped **past the end of the current function**. In x86, nothing stops you from jumping to code that's technically in the "next" function — the bytes just continue. But from a high-level perspective, jumping past your own epilogue means the `else` case does nothing; it just falls into whatever follows.

The fix was removing the `else` branches entirely — the retail genuinely treats "if brush pointer is null, do nothing."

## Progress Snapshot

These batches (122–127) added up to **29 implementations corrected** across material delegation, terrain geometry, mesh bounds, coordinate transforms, and download state management. The patterns we've identified:

| Pattern | When Used |
|---|---|
| REP MOVSD from `this+N` | Cached struct returns (FBox, FSphere) |
| `GetMesh()->GetX(Owner)` | Delegate from instance to mesh |
| `MeshGetInstance(Owner)->GetX()` | Delegate from mesh to instance |
| `FMatrix::Identity` | Base class "no transform" |
| `TransformPointBy(FCoords)` | Heightmap ↔ world conversions |
| Cross-function-jump | "Else that does nothing" (null check) |

Next time: we'll continue into the SHORT stubs and start tackling some of the medium-complexity functions. There's a whole world of animation system, particle emitters, and geometry queries still to decode.
