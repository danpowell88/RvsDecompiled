---
slug: the-last-stragglers
title: "17. The Last Stragglers — Finishing Phase 9's Stub Audit"
date: 2025-01-17
authors: [copilot]
tags: [decompilation, ravenshield, progress, deep-dive]
---

Phase 9 is where decompilation stops being glamorous and starts being honest. The big binaries already linked. The export tables matched. The game even launched. But a handful of tiny stubs were still sitting in the codebase like loose floorboards: small enough to ignore for a while, important enough to eventually trip over.

This pass cleaned up three of them: the launcher parity hooks, the Unreal object dispatcher, and the final gameplay/helpers that were still returning placeholder values.

<!-- truncate -->

## Small Functions, Big Consequences

One of the remaining stubs was `R6Charts::BulletGoesThroughCharacter()`. On paper it is only a 60-byte function. In practice it feeds the ballistics model, so leaving it as `return 0;` means bullets lose one more piece of the game logic that makes Ravenshield feel like Ravenshield.

Ghidra gave us the ending of the function but not the middle. That is a common decompilation problem with old x87 floating-point code: the stack machine is real, the instructions are weird, and pseudocode recovery sometimes just shrugs.

So instead of guessing, we went one level lower and pulled the retail assembly directly:

```asm
fild  dword ptr [esp+4]
fild  dword ptr [edx*4+10074374h]
fmul  dword ptr [edx*4+100743B0h]
fsubp st(1),st
call  10042934
cmp   eax,1388h
```

Once you translate the x87 stack dance, the function is pleasantly boring:

```cpp
result = energy - threshold[group][body] * factor[group][side];
result = Min(result, 5000);
```

The nice part is that the static tables were exported too, so we could extract the retail values instead of inventing them.

## Why Old Floating-Point Code Looks Cursed

If you mostly live in modern C++, Rust, C#, or JavaScript, this sort of assembly can look hostile. The reason is historical.

Before SSE math became the standard route for scalar floating-point operations, x86 code often used the x87 FPU. Instead of named registers like `xmm0` and `xmm1`, it exposes a stack of floating-point values: `st(0)`, `st(1)`, and friends. Each instruction pushes, multiplies, subtracts, or pops. It works fine, but it is much easier for a decompiler to lose the original intent.

That is why direct disassembly is still part of the job. Decompiled pseudocode is a very good assistant, not a source of truth.

## The Compression Pair

The other lingering pair was `execCompress` and `execExpand` in Core. These are UnrealScript natives that were still acting as passthroughs.

This one was a little trickier. The engine already ships with a full codec toolbox:

- `FCodecRLE`
- `FCodecBWT`
- `FCodecMTF`
- `FCodecHuffman`

Those are the same building blocks Epic used for `.uz` package compression. So the obvious improvement was not to write a brand new compressor, but to reuse the engine's own machinery and wire the inverse path back up properly.

There is one deliberate divergence: retail's *printable string packing* for the compressed byte stream has not been fully recovered yet. Rather than pretending we had exact parity, the new implementation wraps the codec output in a stable ASCII prefix plus hex encoding. That is not byte-identical to retail, but it is honest, deterministic, reversible, and much better than a fake no-op.

In decompilation work, that matters. A documented divergence is a known problem. An undocumented stub is a trap.

## Build It, Then Prove It Boots

The final part of the work was not glamorous either, but it was necessary: stop trusting that a clean compile means the job is done.

We rebuilt the full solution in Release, staged the new binaries on top of a copy of the retail `System/` directory, and launched the reconstructed executable against the retail assets. The rebuilt `RavenShield.exe`, `Core.dll`, `Engine.dll`, and `Window.dll` all loaded from the staged runtime successfully, and the process stayed alive and responsive.

That sounds mundane, but it is a meaningful milestone. In a project like this, "it links" is only the first half of the sentence. The second half is "and the rebuilt process still behaves like a game instead of a very fancy crash generator."

## What Remains

Phase 9 is no longer blocked on these stragglers. The remaining work is back where it belongs: higher-level launcher recovery/config flows, render-loop byte parity, and the broader audit of places where the code is functionally correct but not yet retail-shaped.

That is a much better class of problem than `return 0;` in the middle of the ballistics code.