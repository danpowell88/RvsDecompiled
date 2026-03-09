---
slug: reading-the-bones
title: "27. Reading the Bones — Decoding Unreal's Serialization System"
date: 2025-01-27
authors: [rvs-team]
tags: [decompilation, engine, ghidra, reverse-engineering, unreal-engine, serialization]
---

We spent the last few batches implementing serialization operators — the code that reads and writes game data to disk. What started as mechanical stub-filling turned into detective work when we discovered the engine's virtual function table doesn't match the SDK headers.

<!-- truncate -->

## What Is Serialization?

Every game needs to save and load data: maps, meshes, textures, saved games. Unreal Engine 2 uses a system built around `FArchive` — an abstract stream that can read or write depending on context. The same code handles both directions:

```cpp
FArchive& operator<<(FArchive& Ar, FPoly& V) {
    Ar << V.NumVertices;
    Ar << V.Base << V.Normal;
    // ... and so on
}
```

When `Ar` is loading, `<<` reads data from the stream into the variable. When saving, it writes the variable to the stream. One function, two behaviors. This "serialize in both directions" pattern is elegant and common in game engines — you write the serialization code once and it works for loading, saving, network replication, and copy-on-write.

## The Vtable Mystery

FArchive supports different data types through virtual functions. For basic types like `INT` and `FLOAT`, there are inline helper functions that call `ByteOrderSerialize()`. But for complex types like object references (`UObject*`) and name indices (`FName`), FArchive uses **virtual dispatch** — the actual serialization behavior depends on which *kind* of archive you're using (file, network, memory buffer, etc.).

In the decompiled Ghidra output, virtual calls look like this:

```c
(**(code **)(*(int *)param_1 + 0x18))(param_2);     // vtable offset 0x18
(**(code **)(*(int *)param_1 + 0x04))(param_2, 1);  // vtable offset 0x04
```

That second one is easy to identify: vtable offset 0x04 takes a pointer and a length, so it's `Serialize(void*, INT)` — the raw byte serializer. You see it everywhere as `Serialize(addr, 1)` for individual bytes.

But vtable offset 0x18 was the puzzle. Looking at the SDK header, the FArchive virtual functions are declared in this order:

```cpp
virtual ~FArchive();                                    // vtable[0] = 0x00
virtual void Serialize(void* V, INT Length);            // vtable[1] = 0x04
virtual void SerializeBits(void* V, INT LengthBits);   // vtable[2] = 0x08
virtual void SerializeInt(DWORD& Value, DWORD Max);    // vtable[3] = 0x0C
virtual void Preload(UObject* Object);                  // vtable[4] = 0x10
virtual void CountBytes(SIZE_T InNum, SIZE_T InMax);    // vtable[5] = 0x14
virtual FArchive& operator<<(FName& N);                 // vtable[6] = 0x18 ???
virtual FArchive& operator<<(UObject*& Res);            // vtable[7] = 0x1C ???
```

According to this, vtable offset 0x18 should be `operator<<(FName&)` and 0x1C should be `operator<<(UObject*&)`.

## The Evidence Says Otherwise

We tested this against `FBspSurf` — a well-documented structure from the UT99 public source code. FBspSurf's first field is `UTexture* Texture` (a UObject pointer) and near offset 0x1C it has `ABrush* Actor` (also a UObject pointer). The Ghidra decompilation shows:

```c
(**(code **)(*(int *)param_1 + 0x18))(param_2);        // serialize Texture at offset 0
(**(code **)(*(int *)this + 0x18))(pFVar1 + 0x1c);     // serialize Actor at offset 0x1C
```

Both use vtable offset 0x18. Both are UObject pointers. Then in FPoly, which has `FName ItemName` at offset 0xFC:

```c
(**(code **)(*piVar3 + 0x1c))(pFVar2 + 0xfc);          // serialize ItemName at offset 0xFC
```

That uses vtable offset 0x1C for an FName. So the actual layout is:

- **vtable[6] = 0x18 → `operator<<(UObject*&)`** — serializes object references
- **vtable[7] = 0x1C → `operator<<(FName&)`** — serializes name indices

**The SDK header has them backwards.** The Ravenshield binary swaps the order of these two virtual functions compared to the public Unreal Engine 2 headers.

## Why Does This Matter?

Getting the vtable wrong means every serialization function that handles object references or names would silently read/write the wrong format. A UObject reference would be decoded as an FName index and vice versa. Maps wouldn't load, meshes would be garbage, and the game would crash — or worse, appear to work but subtly corrupt data.

This kind of discrepancy is a reminder that decompilation is archaeological work. The "documentation" (SDK headers) describes what the authors *intended*, but the binary is what actually shipped. When they disagree, the binary wins.

## Decoding FPoly — The Most Important Polygon

With the vtable figured out, we could tackle `FPoly` — the BSP polygon structure that's fundamental to Unreal's level geometry. FPoly serialization is one of the most complex in the engine because it has:

1. **A variable-length vertex array** — up to 16 vertices per polygon
2. **Object references** for the owning brush actor and material
3. **Version-gated legacy code** for old map formats
4. **Ravenshield-specific extensions** with their own versioning

The serialization order from Ghidra:

```cpp
Ar << *(FCompactIndex*)&V.NumVertices;       // How many vertices?
// 4 FVectors: Base, Normal, TextureU, TextureV
for (INT i = 0; i < 12; i++)
    Ar.ByteOrderSerialize((BYTE*)&V.Base + i * 4, 4);
// Variable-length vertex array
for (INT i = 0; i < V.NumVertices; i++) {
    Ar.ByteOrderSerialize(&V.Vertex[i].X, 4);
    Ar.ByteOrderSerialize(&V.Vertex[i].Y, 4);
    Ar.ByteOrderSerialize(&V.Vertex[i].Z, 4);
}
Ar.ByteOrderSerialize(&V.PolyFlags, 4);
Ar << *(UObject**)&V.Actor;                  // Brush actor ref (vtable 0x18)
Ar << *(UObject**)&V.Material;               // Material ref (vtable 0x18)
Ar << V.ItemName;                            // Name index (vtable 0x1C)
Ar << *(FCompactIndex*)&V.iLink;
Ar << *(FCompactIndex*)&V.iBrushPoly;
```

Then Ravenshield adds its own extensions, gated by `LicenseeVer()`:

```cpp
if (Ar.LicenseeVer() > 5) {
    // Additional surface properties
    Ar.ByteOrderSerialize(&V._RvsExtra[0x38], 4);
    Ar.Serialize(&V._RvsExtra[0x40], 1);   // Individual bytes —
    Ar.Serialize(&V._RvsExtra[0x46], 1);   // probably flags for
    Ar.Serialize(&V._RvsExtra[0x45], 1);   // collision, visibility,
    Ar.Serialize(&V._RvsExtra[0x44], 1);   // and rendering options
    Ar.Serialize(&V._RvsExtra[0x47], 1);
    Ar.Serialize(&V._RvsExtra[0x48], 1);
}
if (Ar.Ver() > 0x69) {
    Ar.ByteOrderSerialize(&V._RvsExtra[0x34], 4);  // LightMapScale
} else if (Ar.IsLoading()) {
    *(FLOAT*)&V._RvsExtra[0x34] = 32.0f;           // Default: 32.0
}
```

The `LicenseeVer()` gating is how Epic Games allowed licensees to extend structures without conflicting with base engine version changes. Ravenshield uses licensee versions 4-7 for its custom BSP surface and polygon extensions.

## Struct Sizes from Shared Code

Another discovery technique: the MSVC linker sometimes merges **identical functions**. If two operator= functions compile to the same byte sequence, the linker points both symbols at the same address. This gives us size information for free:

- `FStaticMeshTriangle::operator=` and `FSortedPathList::operator=` share the same address → both copy exactly 260 bytes (65 dwords)
- `FStaticMeshUV::operator=` and `FPathBuilder::operator=` share → both are 8 bytes
- `FStaticMeshMaterial::operator=`, `FPointRegion::operator=`, and `FRotatorF::operator=` share → all 12 bytes
- `ECLipSynchData::operator=`, `FCanvasVertex::operator=`, and `FStaticMeshVertex::operator=` share → all 24 bytes

When Ghidra shows the same function address in a comment like `/* 0x3890 1569 ??4ECLipSynchData@@ ... */`, those ordinal numbers map to different .def exports. Same code, different names — because the structs happen to be the same size with the same trivial copy pattern.

## The Score

Across batches 42-43, we implemented 14 serialization functions and 2 operator= methods:

| Function | Complexity |
|----------|-----------|
| FStaticMeshBatcherVertex | Empty (matches original) |
| FStaticMeshUV, FUV2Data | 2 floats each |
| FStaticMeshCollisionTriangle | 16 floats + 4 indices |
| FStaticMeshVertex, FBspVertex | 6-10 floats + version gates |
| FStaticMeshCollisionNode | 4 indices + FBox |
| FUntransformedVertex, FPosNormTexData, FSkinVertex | 10-16 raw floats |
| FTerrainVertex | Mixed floats + individual bytes |
| FPoly | Full implementation with vertex loop |
| FStaticMeshMaterial | Object ref + 2 compact indices |
| FCollisionOctree::operator= | 272-byte flat copy |
| ECLipSynchData::operator= | 24-byte flat copy |

That leaves 22 dummy stubs — all blocked by unknown internal functions (`FUN_xxx`) that are likely template instantiations of `TArray` serialization for various element types. These functions aren't exported from the DLL, so we can't call them directly. Implementing them would require either finding the template source or reverse-engineering each one from scratch.

## What's Next

The remaining stubs are the hardest kind: stream serializers (`FBspVertexStream`, `FSkinVertexStream`, etc.) that depend on internal TArray serialization code, and complex structures like `FBspNode` and `FBspSurf` with extensive version branching. These are the functions that actually load maps and meshes from disk.

Getting these right is critical for the game to load any level at all. But each one requires understanding not just the struct layout, but the entire serialization pipeline — array allocation, element-by-element deserialization, and version migration for formats spanning 5+ engine versions.

The bones of the serialization system are now visible. Reading them correctly is the next challenge.
