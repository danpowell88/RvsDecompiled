---
slug: 42-color-archaeology-and-byte-accuracy
title: "42. Color Archaeology and the Joy of Being Wrong"
authors: [danpo]
tags: [decompilation, fcolor, bgra, retail-accuracy, batches-153-155]
---

Sometimes the most interesting discoveries in decompilation aren't new features — they're realising your assumptions about *existing* code were quietly wrong. This week's sessions (batches 153–155) were full of those moments.

<!-- truncate -->

## Zone Audibility: The Bitmask Beneath

The first target was `ALevelInfo::IsSoundAudibleFromZone`. Our stub returned `1` unconditionally — "everything is always audible, from everywhere." Functional for loading the level, not great for stealth gameplay.

The retail function is more interesting. Each zone in a level has an 8-byte entry in a bitmask array (at `this + 0x650`). Each zone stores two DWORDs — a low bitmask for zones 0–30 and a high bitmask for zone 31. The function checks:

```
if (Zone1 == Zone2) return 1;  // same zone = always audible
bit = 1 << Zone2;
lo = bit & ZoneAudibility[Zone1 * 2];     // bit in low DWORD
hi = CDQ(bit) & ZoneAudibility[Zone1 * 2 + 1]; // CDQ trick for bit 31
return (lo | hi) ? 1 : 0;
```

The `CDQ` instruction (Convert Doubleword to Quadword) sign-extends `EAX` into `EDX`. If `Zone2 == 31`, the bit is `0x80000000` which is negative as a signed 32-bit integer, so CDQ gives `EDX = -1 = 0xFFFFFFFF`. That means the high DWORD is checked in full. Neat trick — two DWORDs form a 64-bit mask, but only zone 31 can activate the second half.

:::tip What's CDQ doing here?
`CDQ` is a relic of x87/older x86 code. It extends EAX's sign bit into EDX, giving you a 64-bit "signed" representation of EAX. In this context, it's used as a cheap branch-free way to create an all-zeros or all-ones mask for the upper DWORD — without needing a separate comparison.
:::

## The FColor RGBA vs BGRA Mystery

This is the one that took the most analysis, and it's a good lesson in how assumptions compound.

Our `FColor` struct was declared as `BYTE R, G, B, A` — the "logical" RGBA order. But Unreal Engine uses **BGRA** layout for D3D compatibility, meaning `B` lives at byte offset 0, `G` at 1, `R` at 2, and `A` at 3. Since we were on Intel little-endian, a DWORD load of FColor gives `0xAARRGGBB`.

This mattered because several functions operate on the raw DWORD:

### FColor::HiColor565 (R5G6B5)

The retail function packs a 16-bit colour by:
- Shifting the DWORD right by 8, masking bits 11–15: `(d >> 8) & 0xF800` — extracts `R[7:3]` at the right position
- Shifting right by 5, masking bits 5–10: `(d >> 5) & 0x07E0` — extracts `G[7:2]`
- Masking the low byte: `d & 0xF8` — extracts `B[7:3]` (but at bits 3–7, not 0–4 — this is a quirk of the retail)

With our old RGBA layout, "R" was at byte 0 so these shifts produced B's bits at the R position and vice versa. Not what we wanted.

### FBrightness: Not What We Expected

Another casualty of the layout mix-up. The standard UE2 header declares `FBrightness()` as `Max(Max(R/255, G/255), B/255)` — highest channel wins. But the retail computes a *weighted sum*:

```cpp
return (2.f * R + 3.f * G + B) / 1536.f;
```

Where the weights are `R: 2/6 ≈ 0.333, G: 3/6 = 0.5, B: 1/6 ≈ 0.167`. The constant `1/1536 = 1/(3 × 512)` shows up in the floating-point immediate.

The FPU load sequence (`FILD`, `FADD st0,st0`, `FILD`, `FMUL 3.0`, `FADDP`, `FIADD`, `FMUL 1/1536`) was a compact way to compute this without loading all three constants — instead the "double" trick handles the `2x` weight inline.

There's a constant lookup table in the DLL's `.rdata` section. Our new [`tools/read_rdata.py`](../tools/read_rdata.py) now lets you look up floats at known retail addresses — handy for any future constants.

### FColor::operator FVector()

Same story: with BGRA, byte 2 is R, so loading `[this+2]` onto the FPU last means it ends up at `FVector.X` (the last FSTP pops first). The result: `FVector(R/255, G/255, B/255)` — which is correct with BGRA, wrong with RGBA.

Fixing the struct layout from `BYTE R,G,B,A` to `BYTE B,G,R,A` (for Intel) immediately made all the DWORD-based functions correct. We also added out-of-line exports for `FBrightness`, `HiColor565`, `HiColor555`, and `operator FVector`.

## Small But Wrong: Three Subtle Bugs

Batches 154–155 caught three quiet correctness issues:

**`AActor::WorldLightRadius()`**: The old impl was `25 * (int(LightRadius) + 1)`. The retail is just `25.0 * LightRadius` — a direct floating-point multiplication. No +1.

**`UModifier::RequiredUVStreams()`**: When the modifier's base material is null, the retail returns 0 (via `XOR EAX, EAX; RET`). Our version returned 1.

**`UCombiner::RequiredUVStreams()`**: A `UCombiner` blends two materials. If Material1 is null, the default is 1. If Material2 is null, the default is 0 (the second material's absence contributes nothing). Our version defaulted both to 1. The asymmetry matters because the combiner ORs both results together.

## What This Tells Us About Correctness

The interesting meta-lesson here: "the code compiles and the game starts" is a much weaker test than "the code is byte-accurate." None of these bugs would obviously crash the game. Zone audibility might just result in everything being inaudible in gameplay. The colour ops might produce slightly wrong shading. But they *all* represent divergence from the retail binary's actual behaviour.

The further we get into decompilation, the more these small divergences matter — especially for functions called from many other functions we're trying to reconstruct.

## Commits This Session

- `8b4f806` — Batch 153: IsSoundAudibleFromZone, FBrightness, HiColor565/555
- `a704363` — Batch 154: FColor BGRA layout fix + operator FVector
- `9e95bcf` — Batch 155: WorldLightRadius, UModifier/UCombiner RequiredUVStreams

We're at **batch 155** of 500. Progress continues.
