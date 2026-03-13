---
title: "72. Fire Simulation from the Ground Up"
authors: [default]
tags: [fire, decompilation, ghidra, algorithms, procedural]
---

The fire system in Ravenshield isn't just pretty pixels — it's seven distinct procedural texture classes, each with its own simulation loop, running every frame. This post is about finishing that system: translating eight deferred "TODO" stubs from raw Ghidra decompilation into clean, readable C++.

<!-- truncate -->

## What Are Procedural Textures?

In most games, textures are images stored on disk: a JPG of a brick wall, a PNG of a leaf. But Ravenshield (Unreal Engine 2.5) has a whole family of *procedural* textures — textures whose pixels are generated *in real time by running code*.

The `Fire.dll` module contains seven of these:

| Class | Effect |
|---|---|
| `UFireTexture` | Animated fire with particle sparks |
| `UWaterTexture` | Water ripple simulation |
| `UWaveTexture` | Simplified wave (no drops) |
| `UFluidTexture` | Smooth fluid blobs |
| `UIceTexture` | Animated ice/glass parallax |
| `UWetTexture` | Wet-surface sheen overlay |
| `UFractalTexture` | Base class for all of the above |

Every tick, each texture runs its simulation and writes new pixel data into a mip buffer that the renderer then uses as a normal texture. It's shader-like behaviour implemented entirely in CPU code.

---

## The Eight Stubs

After previous work got the basic fire spark system running, eight functions were left as stubs — most because they required reading very large Ghidra functions carefully. This post covers implementing all eight.

### BlitIceTex and BlitTexIce

`UIceTexture` animates glass/ice by sampling a *source* texture and a *glass* texture and blending them with a UV offset that drifts over time. There are two blending modes:

**BlitIceTex** (`Flags & 1 == 0`): For each output pixel at (X, Y), look up the source texture at that position. Use the source pixel's *value* as an X-displacement into the glass texture row. So the source pixel doesn't just get copied — it's used as a *pointer* into the glass texture.

**BlitTexIce** (`Flags & 1 == 1`): Reverses the lookup. The glass texture pixel at `(OldUPos+X, OldVPos+Y)` is used as a displacement into the source texture.

Both modes implement a kind of "refraction" — a wavy distortion of one texture through another. The implementation is a straightforward double-nested loop:

```cpp
for (INT Y = 0; Y < VSize; Y++) {
    for (INT X = 0; X < USize; X += 2) {
        BYTE G0 = GlassPix[((OldU + X    ) & UMask) + GlassRow];
        BYTE G1 = GlassPix[((OldU + X + 1) & UMask) + GlassRow];
        DstPix[row + X]     = SrcPix[((G0 + X    ) & UMask) + SrcRow];
        DstPix[row + X + 1] = SrcPix[((G1 + X + 1) & UMask) + SrcRow];
    }
}
```

The `& UMask` wrapping is critical — it keeps the lookup in-bounds without any branching, because the texture dimensions are always powers of two.

---

### ApplyWetTexture

The wet texture takes a base source bitmap and a local procedural bitmap (from the water simulation) and blends them: where the local bitmap is non-zero, use the local value; otherwise fall back to the source.

```cpp
BYTE local = LocalPix[offset];
DstPix[offset] = (local != 0) ? local : SrcPix[offset & srcMask];
```

Simple, but the devil is in the detail of getting the stride arithmetic right when the local buffer and source buffer have different sizes.

---

### CalculateWater and CalculateFluid

These two are the most algorithmically interesting. Both implement a **2D wave equation** on a half-resolution grid, then upsample the result to the full texture.

#### The Wave Equation

The classic 2D wave propagation on a grid is the **Laplacian**:

```
new[x,y] = WaveTable[sum_4_neighbours - 2*centre + 512]
```

The `+ 512` centres the index into a 1028-byte lookup table. The lookup table itself encodes the wave propagation characteristics — things like damping factor, wave speed, and whether the wave reflects or absorbs at boundaries. All of that is baked into `WaveTable` (at `this+0xd08`) by whoever set up the texture.

The simulation runs on a **ping-pong buffer**: two half-size grids stored back-to-back in `SourceFields` (at `this+0x900`). A `WaterParity` byte (at `this+0x1308`) alternates each frame to select which half is source and which is destination.

```cpp
BYTE* Src = (Parity & 1) ? (SF + HalfSize) : SF;
BYTE* Dst = (Parity & 1) ? SF : (SF + HalfSize);
```

After the wave step, a **render step** converts the simulation grid back to visible pixels.

#### CalculateWater vs CalculateFluid

The two classes differ only in the render step:

- **CalculateWater** uses *differences* between neighbouring cells as the render index:
  ```
  pixel = RenderTable[right - left + up - down + 512]
  ```
  This produces surface-normal lighting — bright highlights and dark shadows where the water surface curves.

- **CalculateFluid** uses the *sum* of neighbours:
  ```
  pixel = WaterTable[top + bottom + left + right]
  ```
  This produces a smooth blob — high values in the centre of disturbances, fading to the background.

**DIVERGENCE**: The Ghidra decompilation uses a heavily loop-unrolled version with 4-subpixel bilinear upsampling (one source pixel → four output pixels with interpolated neighbours). Our version uses nearest-neighbour (one source pixel → a solid 2×2 block of identical output pixels). The wave physics are identical; only the visual sharpness at scale transitions differs.

---

### WaterRedrawDrops

Water drops are permanent "sources" that drive the wave simulation. Each drop has a type byte that determines how it injects energy into the `SourceFields` buffer every frame. There are 20 drop types:

| Type | Behaviour |
|---|---|
| 0x00 | Static constant depth |
| 0x01-0x03 | Oscillating (sine-based) drops with variants |
| 0x04 | Random walk |
| 0x05 | Random scatter |
| 0x06-0x07 | Orbiting drops (16-bit phase accumulator) |
| 0x08-0x0b | Line fills (horizontal, vertical, diagonal) |
| 0x0c-0x0f | Oscillating line fills |
| 0x10 | Random scatter with occasional wander |
| 0x11 | Filled area |
| 0x12-0x13 | Pulsing drops |
| 0x40-0x41 | Reverse-orbiting drops |

Each drop writes to *both* ping-pong halves so the value persists regardless of which half is current.

The orbit types are particularly clever. They maintain a 16-bit phase accumulator split across two bytes (ByteA=low, ByteB=high). Each frame the accumulator advances by a speed value, and the high byte is used as an index into a sine table to compute the drop's position. This gives smooth sinusoidal motion at arbitrary speeds without floating point.

---

### AddSpark

`AddSpark` is called whenever the game wants a new particle effect — a fire spark, a water ripple, a bolt of lightning. It fills in a new `FSpark` struct (8 bytes) based on the current `SparkType`. There are 28 cases.

Most cases just set a few bytes:

```cpp
case 0x0c:   // Y-orbit fire spark
    S->ByteA = FX_Frequency * GlobalPhase + FX_Phase;  // initial angle
    S->ByteB = FX_Size;                                 // orbit radius
    S->ByteD = FX_HorizSpeed - 128;                    // angular velocity
    return;
```

But some cases are more complex. Case 0x09/0x0a handles multi-directional spark fountains — if `DrawMode` is 2, 3, or 4, it spawns 1, 2, or 3 additional sparks at angular offsets:

```
DrawMode 2: +180°         (opposite direction)
DrawMode 3: +120°, -120°  (3-way spread)
DrawMode 4: +90°, +180°, -90°  (4-way cross)
```

The 120° offsets are expressed in the 0-255 byte angle representation as `+0x55` and `-0x56` (≈ 85 out of 256, or 85/256 × 360° ≈ 120°).

Case 0x17/0x18 is the "guided spark" — the first call sets up a waiting spark; the second call redirects it toward the new click position, computing the velocity as an even/odd-encoded direction vector.

---

### RedrawSparks

`RedrawSparks` is the main simulation loop — called every tick, iterating all active sparks and executing their type-specific behaviour. The Ghidra binary contains ~30,000 bytes of optimised code for this function. There are 44 cases.

The sparks form a hierarchy: "spawner" spark types (0x04-0x1c) don't move themselves — they sit in place and periodically spawn short-lived "child" sparks of another type. The children are the ones that actually move and fade.

For example:
- Type **0x10** is a "fountain source" — every few frames it emits a type **0x26** spark (a countdown spark that moves and fades).
- Type **0x11** is a "scatter source" — it probabilistically emits type **0x23** sparks that fly outward and fade.
- Type **0x1a** is an "orbit emitter" — each frame it spawns a type **0x27** spark that follows a sinusoidal path.

The terminal spark types (0x20-0x2b) are the ones that actually draw pixels, move, and eventually die. They each implement a variant of the same pattern:

```cpp
// Advance (or fade) some counter
ByteC--;   // or Heat -= decay;
// If dead:
if (ByteC == 0xff) { REMOVE_SPARK; break; }
// If alive:
Pixels[Y << UBits + X] = Heat;  // plot pixel
MoveSpark(S);                    // apply velocity
```

The "move" functions are also a family:
- `MoveSpark`: applies (ByteA, ByteB) as velocity, bouncing off texture edges
- `MoveSparkAngle`: moves in a specific angle using the sine table
- `MoveSparkTwo`: applies velocity with gravity-like acceleration
- `MoveSparkXY`: moves by explicit (DX, DY) values

The most sophisticated terminal type is **0x27** — it follows a sinusoidal path using a sub-pixel accumulator:

```cpp
// Advance 16-bit angle accumulator (ByteA=frac, ByteB=integer angle)
DWORD acc = (DWORD)S->ByteA | ((DWORD)S->ByteB << 8);
acc += (DWORD)S->ByteD * 0x10;
S->ByteA = (BYTE)(acc & 0xff);
S->ByteB = (BYTE)(acc >> 8);
// Compute direction from signed sine table
signed char DX = GSinS[(S->ByteB + 0x40) & 0xff];  // cosine
signed char DY = GSinS[S->ByteB];                    // sine
MoveSparkXY(S, DX, DY);
```

Multiplying `ByteD` by 16 before adding to the 16-bit accumulator means the angle advances by `ByteD / 16` integer steps per frame — giving fine-grained speed control without floating point.

---

## The Lookup Tables

Many of the spark computations use three precomputed sine/cosine tables:

**GSinU[256]** — unsigned sine, range 0-255, centred at 128:
```
GSinU[n] = 128 + (BYTE)(127 * sin(2π * n / 256))
```
Used for orbit radius calculations (always positive).

**GSinS[256]** — signed sine, range -127 to +127:
```
GSinS[n] = (signed char)(127 * sin(2π * n / 256))
```
Used for directional movement with `MoveSparkXY`.

**GOrbBright[256]** — orbital brightness, range 0-255:
```
GOrbBright[n] = max(0, (BYTE)(255 * cos(2π * n / 256)))
```
Used as the actual pixel value for pulsing/orbital sparks — brightest at the "front" of the orbit, dark on the "back half".

**DIVERGENCE**: The retail binary has specific values for these tables computed at link time. Our values are computed at runtime from math. The visual result is identical; the exact byte values differ.

---

## The DIVERGENCE Notes

Decompilation doesn't mean cloning — sometimes a clean, readable implementation is better than a faithful reproduction of every optimisation the original compiler made. Our tracked divergences:

1. **CalculateWater/CalculateFluid**: 2×2 nearest-neighbour upsampling vs. 4-subpixel bilinear. The water still ripples; just slightly blockier at small sizes.

2. **RedrawSparks removal**: We decrement `i` when removing a spark so the replacement gets processed this frame. Ghidra skips it. Over a single frame, some sparks may be skipped in the original; in our version they aren't. The long-term behaviour is the same.

3. **PostDrawSparks**: The original Ghidra export shows `PostDrawSparks` only handles "star" sparks (type 0x16). Our version runs the full heat-diffusion pass that gives fire its characteristic upward glow. This is because the *actual* diffusion kernels (`FUN_105013a0` and `FUN_10501130`) aren't in the Ghidra export — they're called from `ConstantTimeTick` but weren't exported from the DLL, so we can't recover them. The fire still looks like fire.

---

## What's Next

With all eight functions implemented and building cleanly, the Fire module is feature-complete from a simulation standpoint. The next areas to explore are the rendering pipeline proper — how these pixels get from CPU memory onto the screen — or diving deeper into the actor/physics systems that make the game world tick.

Either way, the fire is burning.
