---
title: "54. Fire — Procedural Textures from the '90s"
authors: [rvs-team]
tags: [fire, textures, procedural-generation, unreal-engine, decompilation]
---

Every time you light a torch in Rainbow Six Ravenshield, you're looking at a procedural texture — pixels that aren't loaded from a file but *calculated in real time* on the CPU. The `Fire.dll` module is a self-contained universe of fire, water, ice, and wet-surface effects inherited from the original Unreal Engine. Today we replaced 63 lines of empty stubs with over 1,000 lines of real implementation.

<!-- truncate -->

## What Are Procedural Textures?

Before GPUs had shaders, game engines needed dynamic visual effects that couldn't be pre-baked into static images. Procedural textures solve this: the engine allocates a pixel buffer (usually 128×128 or 256×256) and *rewrites every pixel every frame* using software algorithms.

Fire.dll provides seven classes, all inheriting from `UFractalTexture`:

| Class | What It Does |
|---|---|
| `UFractalTexture` | Base class — shared Init/PostLoad/Prime logic |
| `UFireTexture` | Fire & lightning via "spark" particles |
| `UWaterTexture` | Ripples & waves via "drop" particles |
| `UWaveTexture` | Simplified 2D wave simulation |
| `UFluidTexture` | Full 2D fluid dynamics |
| `UIceTexture` | Panning ice refraction overlay |
| `UWetTexture` | Wet-surface distortion via refraction table |

All of them work by poking values into a flat byte array that the engine then uploads as a texture.

## The Spark System — Fire's Heart

The fire effect doesn't simulate heat transfer or fluid dynamics. It's much simpler and much cleverer. Fire uses **sparks** — tiny particles that walk around the texture, leaving heat behind.

Each spark is a compact 8-byte struct:

```cpp
struct FSpark {
    BYTE Type;    // What kind of spark (0x00–0x2b)
    BYTE Heat;    // How "hot" this pixel burns (brightness)
    BYTE X;       // Horizontal position in the texture
    BYTE Y;       // Vertical position in the texture
    BYTE ByteA;   // Multipurpose (lifetime, direction, etc.)
    BYTE ByteB;
    BYTE ByteC;
    BYTE ByteD;
};
```

Every frame, `RedrawSparks` iterates through the spark array and calls specialised movement functions based on the spark's type. Some spark types wander randomly, others follow straight lines, and some draw expanding rings or flash ramps. After all sparks have stamped their heat into the texture, `PostDrawSparks` runs a **heat diffusion pass** — each pixel averages its value with its neighbours, and the whole image drifts upward by one row. This is what creates the classic "rising flame" look:

```
Frame N:       Frame N+1 (after diffusion + scroll):
..........     ..........
..........     ....##....
....##....     ...####...
...####...     ..######..
..######..  →  .########.
.########.     ..........  ← old bottom row replaced by new spark heat
```

The diffusion pass is beautifully simple — for each pixel, average itself with its four cardinal neighbours and the pixel below. Gravity "pulls" heat downward by biasing the average, but scrolling the whole image up one row each frame makes the flames appear to rise.

## Random Walks and Table-Based Trig

Spark movement uses probabilistic random walks. Here's how `MoveSpark` works:

```cpp
void UFireTexture::MoveSpark(FSpark* S) {
    BYTE RandByte = (BYTE)appRand();
    if (RandByte < S->Heat) {
        // Hotter sparks move more often
        BYTE Direction = (BYTE)appRand();
        if (Direction < 64)       S->Y--;   // up
        else if (Direction < 128) S->X++;   // right
        else if (Direction < 192) S->Y++;   // down
        else                      S->X--;   // left
    }
}
```

Hotter sparks are more likely to pass the random threshold check, so they move more aggressively. Cooler sparks tend to stay put and fade.

The retail DLL uses a custom table-based PRNG — a 64-entry DWORD table with an XOR-shift feedback loop. We approximate this with Unreal's `appRand()`. The random *sequences* differ from retail, but the *algorithm* is identical. This is a documented divergence — the fire won't look frame-identical to the original, but it will look the same *kind* of random.

## The Water Drop System

Water textures work similarly to fire but with **drops** instead of sparks:

```cpp
struct FDrop {
    BYTE Type;   // Drop behaviour (rain, tap, splash, etc.)
    BYTE Depth;  // How "deep" this disturbance is
    BYTE X;      // Position in texture
    BYTE Y;
    BYTE ByteA;  // Direction, speed, lifetime...
    BYTE ByteB;
    BYTE ByteC;
    BYTE ByteD;
};
```

Drops are stored *inline* in the `UWaterTexture` object — a fixed 256-slot array baked directly into the object's memory layout at offset `0x100`. This means no heap allocation, no pointer chasing: the engine just stamps disturbance values into a source field buffer, then the wave simulator reads those disturbances and propagates ripples.

The wave simulation itself (`CalculateWater`) is one of the most complex functions in the entire module — roughly 4,400 lines of Ghidra output. It uses a double-buffered approach, alternating between two halves of the water table via a `WaterParity` flag each frame. This is classic 2D wave equation:

> new_height = 2 × current - previous + dampened(neighbour_average - current)

We've left `CalculateWater` as a documented stub for now. At 4,400 lines of loop-unrolled, pointer-aliased assembly, it deserves its own dedicated translation pass.

## Ice and Wet — Refraction Effects

`UIceTexture` and `UWetTexture` take a different approach. Instead of generating pixels from scratch, they *distort* an existing source texture through a refraction table. Think of looking at a tiled floor through a sheet of warped glass.

The ice texture slowly pans across the source image, and `RenderIce` builds a per-pixel offset table that shifts which source texel gets sampled. The wet texture computes a static refraction table in `SetRefractionTable` using Snell's-law-inspired angle calculations:

```cpp
void UWetTexture::SetRefractionTable() {
    BYTE* Pixels = GetMipPixels(this);
    BYTE UBitsVal = BYTE_AT(this, 0x5b);
    INT USize = INT_AT(this, 0x60);
    INT VSize = INT_AT(this, 0x64);

    for (INT Y = 0; Y < VSize; Y++) {
        for (INT X = 0; X < USize; X++) {
            FLOAT Angle = 6.2832f * (FLOAT)X / (FLOAT)USize;
            FLOAT SinVal = (FLOAT)appSin(Angle);
            FLOAT CosVal = (FLOAT)appCos(Angle);
            INT OffsetX = appRound(SinVal * 4.0f);
            INT OffsetY = appRound(CosVal * 4.0f);
            Pixels[(Y << UBitsVal) + X] = /* encoded offset */;
        }
    }
}
```

This pre-computes per-pixel displacement vectors, which the (currently stubbed) `ApplyWetTexture` function uses each frame to warp the source image.

## Memory Layout Archaeology

One of the trickiest parts of this module was figuring out which bytes at which offsets correspond to which fields. The Ghidra output gives us code like:

```
*(int *)(this + 0x60)    // USize
*(int *)(this + 0x64)    // VSize
*(byte *)(this + 0x5b)   // UBits (log2 of USize)
```

These offsets correspond to UTexture base class fields, but since Unreal's property system manages memory layout rather than C++ member declarations, the headers don't declare them as normal members. We access them through pointer arithmetic wrapped in macros:

```cpp
#define BYTE_AT(obj, off)  (*(BYTE*)((BYTE*)(obj) + (off)))
#define INT_AT(obj, off)   (*(INT*)((BYTE*)(obj) + (off)))
#define FLOAT_AT(obj, off) (*(FLOAT*)((BYTE*)(obj) + (off)))
#define PTR_AT(obj, off)   (*(BYTE**)((BYTE*)(obj) + (off)))
```

This pattern is common in decompiled Unreal code. The engine's reflection system means the "real" layout lives in the property metadata, not in C++ structs.

## What's Left

The big remaining items are the heavy algorithmic kernels:

- **CalculateWater / CalculateFluid** — thousands of lines of 2D wave/fluid simulation with hand-unrolled loops
- **WaterRedrawDrops** — 20+ drop type behaviours in a giant switch statement
- **BlitIceTex / BlitTexIce / ApplyWetTexture** — cross-texture refraction blits

These are all left as documented TODO stubs. The game compiles, links, and runs without them — you just won't see water ripples or ice distortion until they're implemented. Fire and basic sparks *do* work though, which is the most visible of the procedural effects.

## Stats

| Metric | Value |
|---|---|
| Lines replaced | 63 stubs → 1,040 lines |
| Functions implemented | ~50 |
| Spark types (partial) | 10 of 44 |
| Drop types (stub) | 0 of 20+ |
| Documented divergences | 1 (PRNG) |

The Fire module is a reminder that games from this era ran *everything* on the CPU. Every pixel of every flame was calculated in software, every frame, with hand-tuned algorithms designed to look good at 320×240. It's clever, it's hacky, and it works.
