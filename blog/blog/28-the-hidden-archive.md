---
slug: the-hidden-archive
title: "28. The Hidden Archive — Unlocking 4.6 Million Lines of Engine Secrets"
authors: [default]
date: 2025-01-28
tags: [decompilation, ghidra, serialization, reverse-engineering]
---

Sometimes in reverse engineering, you make a discovery that retroactively makes everything easier. This is the story of finding a 4.6-megabyte file full of decompiled internal functions that had been sitting right under our noses — and how it helped us tear through a wall of blocked stubs in a single session.

<!-- truncate -->

## The Wall

By batch 43, we'd implemented most of the Engine.dll serialization stubs. The `operator<<` functions — the code that reads and writes game objects to disk — were falling one by one. FPoly, FBspSurf, FStaticMeshMaterial, FTags. We had momentum.

Then we hit a wall. Twenty remaining stubs. And almost all of them called internal functions — things like `FUN_10322590`, `FUN_103cc610`, `FUN_104170d0`. These weren't exported symbols. They weren't in the .def file. They were private implementations buried deep inside Engine.dll, invisible to the outside world.

Or so we thought.

## The Discovery

Ghidra's export analysis had given us `_global.cpp` — decompilations of every exported function. But there's another file it generates: `_unnamed.cpp`. This contains decompilations of functions that Ghidra found but that aren't associated with any named export. Internal helper functions. Private methods. Template instantiations that the compiler generated but never exposed.

For Engine.dll, this file is **4.6 million lines** of decompiled C code.

Every single `FUN_xxxxxxxx` that had been blocking our stubs? It was in there, fully decompiled.

## Reading the Rosetta Stone

Once we knew where to look, the internal functions fell like dominoes. Here's what we found:

### TArray Template Instantiations

The Unreal Engine uses `TArray<T>` for dynamic arrays, and each template instantiation generates its own serialization function. The compiler creates a unique function for each element type:

| Function | What it actually is | Element Size |
|----------|-------------------|-------------|
| `FUN_10322590` | `TArray<FBspVertex>::Serialize` | 40 bytes |
| `FUN_10323cd0` | `TArray<FTerrainVertex>::Serialize` | 36 bytes |
| `FUN_103243e0` | `TArray<FStaticMeshVertex>::Serialize` | 24 bytes |
| `FUN_10324510` | `TArray<FStaticMeshUV>::Serialize` | 8 bytes |
| `FUN_1037fbd0` | `TArray<DWORD>::Serialize` | 4 bytes |
| `FUN_1031e600` | `TArray<_WORD>::Serialize` | 2 bytes |
| `FUN_1031cce0` | `TArray<BYTE>::Serialize` | 1 byte (bulk) |

The pattern was beautifully consistent. Each function serializes a count prefix (as `FCompactIndex`), then iterates over elements calling their respective `operator<<`. For single-byte arrays, it does a single bulk `Serialize()` call instead — a nice optimisation.

### The 32-Byte Mystery Element

One function had us puzzled initially: `FUN_10323030` serializes a `TArray` where each element is 32 bytes, and per-element serialization goes through yet another function — `FUN_10446ec0`. Was this some complex nested structure?

Nope. `FUN_10446ec0` is just 8 × `ByteOrderSerialize(4)`. Thirty-two bytes of flat data, serialized as eight DWORDs. Nothing fancy. But without the `_unnamed.cpp` decompilation, this looked like an impenetrable dependency chain.

### The ZoneMask Bitmask Serializer

`FUN_103cc610` turned out to be one of the more interesting finds. It serializes Unreal's **zone visibility mask** — a 256-bit bitmask stored as 8 DWORDs. The Ravenshield format (identified by `LicenseeVer >= 9`) packs these bits into individual bytes:

```
For each of 32 byte groups:
  Saving: pack 8 bits from the DWORD array → 1 byte
  Loading: read 1 byte → unpack into DWORD array bits
```

It's a custom bit-packing scheme that compresses 32 bytes of DWORD-aligned data into 32 bytes of byte-packed data. Not a huge space saving, but it ensures portable serialization regardless of platform endianness. This was used by FBspNode, the struct that defines every node in the BSP tree — the fundamental spatial data structure for the game's levels.

### The BGRA Surprise

Perhaps the most interesting find was `FUN_104170d0` — the FColor array serializer. You'd expect colour data to be serialized in RGBA order (matching the struct layout). Instead, the original engine serializes each pixel as **B, G, R, A** — a byte-swapped order that matches DirectX's texture expectations.

Our FColor struct (from the SDK) defines memory layout as `R(0), G(1), B(2), A(3)`. But the serializer explicitly reads/writes bytes at offsets `[2], [1], [0], [3]` — that's B, G, R, A. This means the on-disk format differs from the in-memory format by design.

Getting this wrong would have produced garish purple-and-green meshes in game. Getting it right means faithful colour reproduction.

## The Pad[] Pattern

With all internal functions decoded, we faced a different challenge: the class definitions.

Types like `FBspVertexStream`, `FRawIndexBuffer`, and `FStaticMeshUVStream` all inherit from abstract base classes (`FVertexStream` or `FIndexBuffer`) that have virtual method tables. In our SDK-derived headers, their data members are just `BYTE Pad[64]` — opaque byte arrays because the SDK didn't know the internal layout.

Now we *do* know the layout. A `FBspVertexStream` has:
- **Offset 0**: vtable pointer (4 bytes, from FVertexStream)
- **Pad[0-11]**: `TArray<FBspVertex>` (12 bytes)
- **Pad[12-19]**: gap (CacheId, 8 bytes)
- **Pad[20-23]**: `INT Revision`

So our serializers cast directly into the Pad array:

```cpp
FArchive & operator<<(FArchive & Ar, FBspVertexStream & V) {
    Ar << *(TArray<FBspVertex>*)V.Pad;        // TArray at Pad[0]
    Ar.ByteOrderSerialize(&V.Pad[0x14], 4);  // Revision at Pad[0x14]
    return Ar;
}
```

Is this technically undefined behaviour via strict aliasing? Yes. Does MSVC care? No. Does the original binary do exactly the same thing? Also yes. We'll take pragmatism over pedantry here.

## FBspNode: The Boss Fight

The crown jewel of this session was `FBspNode` — the struct that defines every node in the game's Binary Space Partition tree. Its serializer is the most complex in the engine:

1. **FPlane** (16 bytes) — the splitting plane
2. **ZoneMask** (32 bytes) — the 256-bit packed visibility bitmask
3. **7 FCompactIndex fields** — child/leaf/surface references
4. **2 sub-structures** (version-gated 12 or 16 bytes each) — collision bounds
5. **3 single bytes** — node flags and metadata
6. **2 INTs** — zone indices
7. **A 3-branch version gate** for 3 more INTs with legacy format migration

The version-gated block for the spatial indices has four possible paths depending on `Ar.Ver()`:
- **Ver < 0x5C**: Default all to -1 (very old format)
- **Ver == 0x5C**: Read one temp INT, discard, default all to -1
- **0x5D ≤ Ver ≤ 100**: Read two temp INTs, discard, default all to -1
- **Ver > 100**: Real serialization with a further ver < 0x6C fixup

Each version added more spatial indexing data, but the old paths had to remain for backwards compatibility. The intermediate versions (0x5C and 0x5D-100) serialized data *into local variables and threw it away* — they advanced the archive position to maintain stream alignment without actually using the values. Very common in game format migrations.

## The Scoreboard

After two batches of implementation:

| Status | Count | Examples |
|--------|-------|---------|
| **Implemented** | 14 | FBspNode, FBspSurf, FBspSection, FRawColorStream, all stream/buffer types |
| **Still blocked** | 6 | FLightMap, FLightMapTexture, FStaticLightMapTexture, FStaticMeshSection, FProjector* |

The remaining 6 stubs fall into three categories:
- **Lazy array serializers** (FLightMap*, FStaticLightMapTexture): Use a complex lazy-loading pattern with `GUglyHackFlags`, `GLazyLoad`, and file seeking. These need significant infrastructure.
- **Version migration** (FStaticMeshSection): Three entirely different serialization formats with temporary object construction and conversion.
- **Timing-dependent** (FProjector*): Use `rdtsc` (CPU timestamp counter) to check projector lifetime before serializing. Unusual pattern.

## What We Learned

The biggest lesson: **always check what else your decompiler knows**. The `_unnamed.cpp` file had been generated alongside `_global.cpp` from the start, but we hadn't needed it until the exported functions started depending on internal ones. Those 4.6 million lines contained every template instantiation, every private helper, every inlined function that the compiler had generated.

In decompilation work, the biggest walls aren't technical — they're informational. Once you know what a function does, implementing it is straightforward. The hard part is figuring out what it does in the first place.

Having a 4.6 million-line cheat sheet certainly helps.
