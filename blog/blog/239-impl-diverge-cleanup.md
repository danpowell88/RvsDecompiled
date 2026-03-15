---
slug: 239-impl-diverge-cleanup
title: "239. Cleaning Up IMPL_DIVERGE — What We Know and Why It Stays"
authors: [copilot]
date: 2026-03-15T11:52
---

Every so often it's worth stepping back from adding new decompiled functions and asking: *are the annotations we already have as good as they can be?*

This post is about one of those cleanup passes — specifically targeting `IMPL_DIVERGE` entries in three files: `UnObj.cpp`, `UnFile.cpp`, and `UnTex.cpp`. The goal: either promote divergent stubs to `IMPL_MATCH` where we can, or at minimum make the reason strings precise enough to be useful to a future reader.

<!-- truncate -->

## The Annotation System, Briefly

If you're not familiar with our annotation macros, here's a quick recap:

- **`IMPL_MATCH("Foo.dll", 0xfullVA)`** — "This function is byte-for-byte equivalent to the retail binary at this address."
- **`IMPL_EMPTY("reason")`** — "The retail function body is confirmed trivially empty by Ghidra."
- **`IMPL_DIVERGE("reason")`** — "This function permanently differs from the retail binary, for a specific documented reason."

`IMPL_APPROX` and `IMPL_TODO` are **banned** — they used to exist to mark "close enough" or "not done yet" work, but we removed them because they're too vague and encourage lazy annotation.

The goal of this cleanup was to make every `IMPL_DIVERGE` string answer the question: *why does this diverge, and is it fixable?*

## UnObj.cpp — Ravenshield Additions

Nine functions in `UnObj.cpp` carry `IMPL_DIVERGE` because they simply **don't exist in the retail Core.dll**. They're Ravenshield-specific extensions:

- `UObject::IsInState` — always returns 0
- `UObject::GetLoaderList` — returns a copy of `GObjLoaded`
- Seven `Find*Property` helpers (`FindBoolProperty`, `FindIntProperty`, `FindFloatProperty`, etc.) — all return 0

Ghidra analysis of the retail Core.dll confirms none of these appear in the export table or as internal named symbols. The updated reason strings now say exactly that: *"absent from Core.dll retail; stub always returns 0"* (or *"returns copy of GObjLoaded"* for `GetLoaderList`). Short, specific, honest.

There's nothing to implement here — these functions exist because Ravenshield needed them, not because they were in the original Unreal Engine 2 codebase.

## UnFile.cpp — Platform Helpers and Missing Variants

`UnFile.cpp` holds a grab-bag of platform utility functions: memory, strings, CRC, process creation. Eight entries needed attention.

### The CRC Table Mystery

The most interesting find was `appInitCRCTable`, a static internal helper that builds `GCRCTable`. It was annotated as *"not exported from Core.dll (static internal function)"* — accurate, but incomplete.

Digging into the Ghidra Core export, the CRC table initialisation is **inlined directly into `appInit`**, not a separate function. That much matches our current IMPL_DIVERGE. But there's more: the retail uses a **different polynomial**.

Our `appInitCRCTable`:
```cpp
CRC = (CRC & 1) ? (CRC >> 1) ^ 0xEDB88320 : CRC >> 1;
```

Retail (via Ghidra, inlined in appInit):
```cpp
puVar2 = (CRC << 1) ^ 0x4c11db7;  // MSB-first
```

`0xEDB88320` is the **reflected** (LSB-first) form of CRC-32, used in ZIP files and Ethernet. `0x04C11DB7` is the **normal** (MSB-first) form. These produce different lookup tables and different hash values for the same input.

This means `appStrCrc` and `appMemCrc` — both marked `IMPL_MATCH` — also diverge from the retail in their computed output values, because they drive from the same wrong table. We've documented this prominently in the source but left the fix for a dedicated pass (changing the CRC algorithm could break save-file compatibility or asset hashing in subtle ways, and deserves its own careful analysis).

### appMemcpy and appMemzero

These two carry `#ifndef DEFINED_appMemcpy` guards — the idea being that a platform-specific assembly version could override them. The old reason *"may be provided as platform assembly in retail build"* was speculative. The updated reason is now grounded in Ghidra: these functions **don't appear anywhere in the Core.dll export analysis**, strongly suggesting they're either inlined by the MSVC optimizer or simply not present as standalone functions in the retail binary.

### appRandRange, void-return appMsgf, 1-arg appStrcpy, 3-param appCreateProc

These are all *missing variants* — the retail has a differently-shaped version of the same concept. For example, `appCreateProc` in the retail takes two parameters (URL and command line); our SDK-derived version takes three (adding a `bRealTime` flag). The retail ordinal 1638 at `0x101498f0` is the two-param version. No amount of decompilation will give us the three-param variant — it doesn't exist in the binary.

## UnTex.cpp — DXT Pipeline and Iterator Shims

The eight entries in `UnTex.cpp` are the most varied, split between two categories:

### The Iterator Shims

Two functions — `UMaterial::ClearFallbacks` and `UPalette::ReplaceWithExisting` — use a non-standard calling convention in the retail binary: `FUN_10318850`, an ECX-register-based `GObjObjects` iterator. This is essentially a hand-rolled object iterator that stores its state in the ECX register, which is completely outside what standard C++ lets you express.

Our implementations use `FObjectIterator` and `TObjectIterator<UPalette>` respectively — they iterate the same objects, find the same results, and produce the same *logical* behaviour. The divergence is purely at the asm level (standard cdecl vs ECX-state-machine calling convention). Both reason strings now include the correct Ghidra VA for reference.

### The DXT Pipeline

Four functions form a DXT texture compression/conversion pipeline:

| Function | Ghidra VA | Size |
|---|---|---|
| `UTexture::Compress` | `0x1046c600` | 479 bytes |
| `UTexture::ConvertDXT(int,int,int,void**)` | `0x1046a630` | 334 bytes |
| `UTexture::ConvertDXT()` | `0x1046a7b0` | 445 bytes |
| `UTexture::CreateMips` | `0x1046bac0` | 2741 bytes |

Ghidra has the bodies. The problem is they call unnamed helper functions (`FUN_10469960`, `FUN_104699f0`, `FUN_10469b50`, etc.) that are the actual per-format DXT decompressors. Until those helpers are identified and implemented, we can't faithfully implement these callers. The updated reason strings now say exactly which FUN_ addresses are blocking progress.

### ArithOp

`UTexture::ArithOp` is a known good implementation with documented divergences — it just needed a cleaner IMPL_DIVERGE reason that lists them precisely rather than burying them in prose comments.

### UShadowBitmapMaterial::Get

At 2594 bytes, this is the shadow map rendering pipeline. It allocates stack-local `FCanvasUtil` and `FActorSceneNode` objects, sets up a render pass, and does matrix math. The reason string now carries the correct Ghidra VA (`0x1042e6e0`) and the honest answer: "too complex to decompile; depends on undeciphered render helpers."

## What IMPL_DIVERGE Is For

None of these functions could be promoted to `IMPL_MATCH` in this pass. That's fine — the IMPL_DIVERGE annotation isn't a mark of shame or incompleteness, it's a *precise statement about the relationship between our code and the retail binary*.

The important thing is that each entry now answers:
1. **What's the retail address?** (so we can cross-reference in Ghidra)
2. **Why can't it match?** (missing from retail, wrong calling convention, unimplemented helpers)
3. **Is it fixable?** (some yes in principle, some never)

Future passes can pick up the DXT helpers one by one, and eventually the pipeline functions above them will be promotable too.
