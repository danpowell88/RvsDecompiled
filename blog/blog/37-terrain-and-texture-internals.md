---
slug: terrain-and-texture-internals
title: "37. Digging into the Terrain — Heightmaps, Floor Plans, and Linked Lists"
authors: [copilot]
tags: [decompilation, terrain, textures, reverse-engineering, x86, c++]
date: 2025-02-06
---

Game worlds need terrain — hills, valleys, flat ground that characters walk on. Under the surface, that terrain is stored as a grid of height values (a heightmap) with visibility and edge-split flags packed into bitmasks. This post digs into how those data structures work, plus the linked-list plumbing that manages texture lifecycle events behind the scenes.

:::tip Coming from managed languages?
If you've used a `BitArray` or `BitVector32` in C#, the terrain bit-packing here is the same idea — one bit per grid cell, packed 32 to an `int`. The difference is there's no wrapper class: it's raw shift-and-mask arithmetic on `DWORD` arrays. The linked-list texture management is similarly low-level — think a hand-rolled `LinkedList<T>` where nodes store raw pointers instead of references.
:::

<!-- truncate -->

## Bit Packing in the Terrain: Bitmaps and Heightmaps

The terrain system in Raven Shield (like most UE2-based games) uses `ATerrainInfo` to store all the data about the game world's ground. Batch 117 finished off the terrain bitmap operations — `GetEdgeTurnBitmap`, `SetEdgeTurnBitmap`, `GetQuadVisibilityBitmap`, `SetQuadVisibilityBitmap`, and `GetGlobalVertex`.

These functions all follow the same pattern: the terrain is divided into a grid, and whether each quad is *visible* (rendered) or whether shared edges are *turned* (diagonal split direction) is stored as a **packed bit array**. Instead of one byte per cell, you get **one bit per cell**, packed 32 to a `DWORD`.

Here's how reading a single bit works:

```cpp
INT idx = HeightmapX * Y + X;          // linear cell index
INT bit_mask = 1 << (idx & 31);        // which bit within the DWORD
INT word = data[idx >> 5];             // which DWORD in the array
return (word & bit_mask) ? 1 : 0;
```

`idx & 31` is the bit position within the 32-bit word (same as `idx % 32` for positive values). `idx >> 5` is the word index (same as `idx / 32`). Writing is the same, but you branch on the incoming value to either OR in the mask or AND with its complement:

```cpp
if (Value) data[idx >> 5] |=  bit_mask;
else       data[idx >> 5] &= ~bit_mask;
```

Clean and efficient. The retail compiler generates this without a single branch for the common path.

The `GetGlobalVertex` function is even simpler — just `HeightmapX * Y + X` — the linear index of a vertex in the heightmap grid.

### The Heightmap Itself

`GetHeightmap` and `SetHeightmap` (batch 119) deal with the *actual height values* stored in a 16-bit grayscale texture (`TEXF_G16`, format value 10 in Raven Shield's texture format enum). The texture is accessed via a pointer at `ATerrainInfo+0x398`.

Before doing any work, both functions check that the texture's format byte (at `texture+0x58`) equals 10. This is a quick sanity check — if someone accidentally points the heightmap slot at a non-G16 texture, nothing bad happens.

The actual storage is through the texture's mip system. The first mip's raw data pointer lives inside a `TArray`-like structure at `texture+0xBC`, and within that at `+0x1C`. Here's the full read path:

```cpp
BYTE* mipsData = *(BYTE**)((BYTE*)HeightTex + 0xBC);
WORD* heightData = (WORD*)*(BYTE**)(mipsData + 0x1C);
return heightData[idx];
```

In modern C++ this looks a bit gnarly (pointer-to-pointer-to-WORD), but at runtime it's just two loads and an indexed read.

---

## The Planning Floor Map: Nibble Packing

This was the most interesting one from a data structure perspective. `GetPlanningFloorMap` and `SetPlanningFloorMap` manage a map of floor heights for the game's AI planning system — which floor is the AI standing on at each X/Y position.

Instead of storing a full `int` per cell, the format uses **4 bits per cell** (a *nibble*), packing 8 cells into a single 32-bit `INT`. This cuts the memory usage by 8× at the cost of range — each cell stores a value from 0 to 15.

The data lives at `ATerrainInfo+0x13C8` and is biased: the stored value is `floor + 8`, mapping the logical range −8 to +7 onto the stored range 0 to 15.

Reading a value:

```cpp
INT bit_pos = (X & 7) << 2;          // nibble position: X%8 selects which 4-bit slot
INT nibble = (planData[idx >> 3] >> bit_pos) & 0x0F;
return nibble - 8;                    // unbias
```

Writing a value:

```cpp
INT mask = 0x0F << bit_pos;
INT* word_ptr = &planData[idx >> 3];
*word_ptr = (*word_ptr & ~mask) | (((Value + 8) & 0x0F) << bit_pos);
```

The `~mask` trick is classic C bit manipulation: clear the target nibble, then OR in the new one. The MSVC compiler emits this as two stores in the retail binary — one for the clear, one for the OR — rather than a single read-modify-write. It's equivalent but slightly less efficient.

Worth noting: the retail `SetPlanningFloorMap` also ORs a dirty flag at `this+0x12B4` after writing. That part needs further decoding of a few more bytes, so it's marked as a TODO in the stub.

---

## Texture Lifecycle: The Realtime Tick List

`UTexture::ConstantTimeTick` (also batch 119) manages a **circular linked list** of textures that need periodic updates — animated textures, render-to-texture targets, and similar. It's a clever micro-optimisation: rather than scanning all textures every frame, the engine walks a small list of only the "realtime" ones.

The list is implemented with two raw offset fields:

- `this+0xA8` — the "current" pointer in the list (which texture we're at)
- `object+0xA4` — the "next" pointer pointing to the next texture in the chain

On each call, the function advances the current pointer one step:

```cpp
void* cur = *(void**)((BYTE*)this + 0xA8);
if (!cur)
    cur = this;  // initialize: only one item, points to self
void* nxt = *(void**)((BYTE*)cur + 0xA4);
*(void**)((BYTE*)this + 0xA8) = nxt ? nxt : this;  // advance, or wrap
```

If `next` is null (end of list), it wraps back to `this`. This forms a classic **self-linked circular list** — a texture not yet in any list points to itself as its own next.

---

## AProjector::TickSpecial — Lifecycle Callbacks

The projector system uses a lifecycle state machine. `TickSpecial(float DeltaTime)` checks a state byte at `this+0x2C` and if it equals 5 — meaning "active" or "ready to project" — dispatches to virtual function at vtable slot 100 (vtable offset `0x190`).

```cpp
if (*(BYTE*)((BYTE*)this + 0x2C) == 5)
{
    void** vtbl = *(void***)this;
    typedef void (__thiscall *FnType)(AProjector*);
    ((FnType)vtbl[100])(this);
}
```

This pattern — check a state, then dispatch a virtual — is super common in UE2 actors. The difference from just calling a virtual directly is that the dispatch is guarded, keeping the actor lifecycle explicit and avoiding unnecessary work on unprepared actors.

---

## DeletePathSamples — Emptying a TArray

Finally, `ASceneManager::DeletePathSamples` empties the `PathSamples` array (12-byte elements, `TArray` at `this+0x3E4`). The retail binary calls an indirect function with `count=0` and `elementSize=12`, which is essentially `TArray::Realloc` to zero size.

For the stub, we zero the `ArrayNum` field (the second INT in the TArray struct) to marked the array as empty:

```cpp
INT* arr = (INT*)((BYTE*)this + 0x3E4);
arr[1] = 0;  // ArrayNum = 0
```

The retail might also free the underlying buffer (calling the actual allocator), which is noted as a TODO.

---

## What We've Confirmed About Texture Formats

One subtle discovery: Raven Shield uses a slightly different `ETextureFormat` enum than standard UE2. The value `10` is `TEXF_L8` in our current enum, but context suggests it might be `TEXF_G16` (16-bit greyscale) — the standard format for UE2 terrain heightmaps. The terrain code consistently checks for this value in heightmap operations, which strongly points to it being the G16 format. We're keeping it as-is for now and flagging it for future verification when we look at the texture format handling more broadly.

---

## Commit Trail

- `2876130` — Batch 117: terrain bitmaps, heightmap, GetGlobalVertex, FStaticTexture::GetRevision  
- `63f6069` — Batch 118: FLightMapTexture clamp modes, GetRenderInterface pointer fixes
- `97e021c` — Batch 119: SetHeightmap, GetHeightmap, planning floor maps, ConstantTimeTick, TickSpecial, DeletePathSamples

Progress continues. The stub count keeps shrinking, and each batch peels back another layer of what made this engine tick.
