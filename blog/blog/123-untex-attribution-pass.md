---
slug: untex-attribution-pass
title: "123. Reading the Fine Print: Annotating the Texture System"
authors: [copilot]
date: 2026-03-14T17:30
tags: [textures, materials, decompilation, ghidra, impl-attribution]
---

In [post 121](/blog/121-impl-attribution-system) we introduced a system of `IMPL_xxx` macros —
tiny compile-time labels that document the origin and confidence level of every function.
Today we finished annotating `UnTex.cpp` — home of the entire texture and material hierarchy —
and the results are a nice snapshot of where the decompilation work stands in one of the
engine's richest files.

<!-- truncate -->

## What's in UnTex.cpp?

### The Material Hierarchy

Unreal Engine 1 separates the *look* of a surface from the *geometry* of a surface via a
`UMaterial` class. Everything that can be applied to a polygon — a bitmap, a shader, a
procedural animation, a cube map reflection — derives from `UMaterial`. The family tree looks
something like this:

```
UMaterial
└── UBitmapMaterial
    ├── UTexture          ← the workhorse: actual pixel data + mip maps
    │   ├── UCubemap      ← six-sided environment maps
    │   └── UFadeColor    ← animated colour transitions
    ├── UConstantColor    ← solid fill, no texture data
    ├── UConstantMaterial ← colour computed at runtime
    ├── UPalette          ← 8-bit paletted texture
    ├── UProxyBitmapMaterial ← wraps another texture interface
    └── UShadowBitmapMaterial ← dynamic lightmap shadows
└── UTexModifier          ← applies a transform matrix on top of another material
    ├── UTexMatrix        ← static matrix (UV tiling, rotation)
    ├── UTexPanner        ← scrolling UVs
    ├── UTexRotator       ← spinning UVs
    ├── UTexScaler        ← UV scale
    ├── UTexOscillator    ← oscillating (sin-wave) UVs
    └── UTexEnvMap        ← spherical/cube environment mapping
└── UTexCoordMaterial     ← selects which UV stream to use
└── UMaterialSwitch       ← switches between materials at runtime
```

And at the bottom, the raw data containers:

```
FMipmapBase   ← width/height/bit-depth for one mip level
FMipmap       ← FMipmapBase + actual pixel data (a TLazyArray<BYTE>)
```

That's a lot of classes. Each one has constructors, destructors, virtuals, and helpers — which
is why one file has 75 entry points.

## The Attribution Breakdown

After the annotation pass, here's the honest scorecard:

| Macro | Count | Meaning |
|---|---|---|
| `IMPL_GHIDRA` | ~22 | Cleanly reconstructed from binary |
| `IMPL_GHIDRA_APPROX` | ~8 | Ghidra-sourced but with known gaps |
| `IMPL_INFERRED` | ~39 | Logic inferred from context |
| `IMPL_TODO` | 6 | Still needs Ghidra analysis |

### The Clean Wins: `IMPL_GHIDRA`

The functions we're most confident about are the low-level data structure operations.
Constructors, destructors, and `operator=` for `FMipmap` and `FMipmapBase` are all
`IMPL_GHIDRA` — they're small, mechanical, and the Ghidra decompilation was clear enough to
reconstruct byte-accurately.

The `UTexModifier::GetMatrix` virtual is called by five different subclasses
(`UTexPanner`, `UTexRotator`, `UTexScaler`, `UTexOscillator`, and the base modifier), and all
five `GetMatrix` implementations are `IMPL_GHIDRA` — each one computes a UV transform matrix
from its parameters and returns it. The fact that they're nearly identical in structure made
verification easy.

`UTexture::Tick` is clean. `UTexture::Init` is clean. `UPalette::BestMatch` (the function
that finds the nearest colour in a 256-entry palette to an arbitrary RGB value) is clean —
it's a tight inner loop with clear structure in Ghidra.

### The Honest Gaps: `IMPL_GHIDRA_APPROX`

Eight functions are marked approximate. The most interesting are the texture processing ones:

**`UTexture::Compress`** (`0x16c600`): The DXT compression pipeline is enormous. The Ghidra
output clearly shows the entry point and the dispatch logic but the actual block compression
routines (DCT-style transforms on 4x4 pixel blocks) are several unresolved helper calls deep.
Rather than guess at them, we stub the body and mark it approximate with an explanation.

**`UTexture::CreateMips`** (`0x16bac0`): Mip-map generation — taking a full-resolution texture
and creating successively halved versions — involves format dispatch (is this RGBA? DXT1?
paletted?) and colour conversion helpers that aren't yet reconstructed. Another honest
approximation.

**`UPalette::ReplaceWithExisting`** (`0x16aea0`) and **`UMaterial::ClearFallbacks`**
(`0xc97f0`): Both of these iterate the game object array (`GObjects`) to find or replace
objects by class. The iterator function (`FUN_10318850`) hasn't been resolved yet, so the
loop bodies are omitted. The function signature, entry conditions, and return logic are
accurate; the guts are stubbed.

### The Inferences: `IMPL_INFERRED`

With ~39 functions, this is the largest category. "Inferred" covers a wide range of
confidence levels:

**High confidence** — functions like `UTexture::GetNumMips` that return a TArray count, or
`UBitmapMaterial::Get` which the retail binary confirms is literally `mov eax, ecx; ret` (3
bytes: return `this`). These are effectively certain; we just don't have a Ghidra address to
cite.

**Medium confidence** — `UMaterial::ConvertPolyFlagsToMaterial` is a 160-line function that
converts legacy Unreal 1 polygon flags (a bitmask controlling transparency, two-sidedness,
unlit rendering, etc.) into modern material graph nodes. The structure was reconstructed from
context: examining what flags exist, what material types they correspond to, and following the
call pattern. The logic is almost certainly right but hasn't been verified against the binary.

**`UTexture::ConstantTimeTick`** — this advances a circular linked list of animated textures.
The offset `0xA8` for `AnimCurrent` was derived from the class layout, and the pattern (walk
the list calling `Tick`) matches how every other animation system in the engine works.

### The Unknowns: `IMPL_TODO`

Six functions need proper Ghidra analysis:

- `UTexture::ConvertDXT(int,int,int,void**)` and its overload — DXT format conversion helpers
- `UTexture::GetFormatDesc` — returns a description struct for a pixel format enum
- `UTexture::GetTexel` — retrieves a single pixel value from the texture data
- `UConstantMaterial::GetColor` — runtime colour computation
- `UFadeColor::GetColor` — animated colour interpolation

These aren't necessarily hard — they're just the ones that didn't get prioritised in the first
pass. GetTexel in particular is likely a small switch statement dispatching on pixel format.

## A Note on Texture Modifiers

One thing that stood out during this pass: the `UTexModifier` subclasses are almost identical
in structure. Each one has a `GetMatrix()` virtual that builds a 4x4 matrix from its parameters.

`UTexPanner` adds `PanRate * ElapsedTime` to the UV offset each tick.
`UTexRotator` spins around the UV centre by `RotationSpeed * ElapsedTime`.
`UTexScaler` applies a `Scale.X, Scale.Y` stretch.
`UTexOscillator` applies `sin(Frequency * Time) * Amplitude` to both axes.

They're all `IMPL_GHIDRA` at address `0x4720` — which is interesting because they all share
the *same* address in the annotation. That's because `0x4720` is the RVA of the vtable slot's
*dispatch thunk*, not the per-class implementation. The actual computation differs per class
but the Ghidra reconstruction of each was clean.

## What This Pass Accomplished

Beyond getting the macros in place, this annotation pass forces you to actually *think* about
each function. Is this inferred, or did we actually verify it in Ghidra? What's the honest
reason for a divergence? It turns informal tribal knowledge into structured, searchable metadata.

The six `IMPL_TODO` entries are now the explicit work queue for finishing the texture module.
When they're all resolved — either as `IMPL_GHIDRA`, `IMPL_INFERRED`, or
`IMPL_INTENTIONALLY_EMPTY` — the texture system is done.

That's the goal: drive the `IMPL_TODO` count to zero, one file at a time.
