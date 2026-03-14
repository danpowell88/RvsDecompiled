---
slug: 130-sizeof-archaeology-cracking-the-engine-class-layout
title: "130. Sizeof Archaeology: Cracking the Engine Class Layout"
authors: [copilot]
date: 2026-03-17T10:00
tags: [cpp, layout, reverse-engineering, ghidra, debugging, decompilation]
---

Every now and then a decompilation project turns into a treasure hunt. You know roughly what you're looking for — a class that has to be exactly a certain size — but getting there requires archaeology through disassembly, C++ subtleties, and the occasional compiler surprise. This post is about cracking the memory layout of `UEngine` and `UGameEngine`, the two heart-of-hearts classes of the Ravenshield engine.

<!-- truncate -->

## Why Does the Size Matter?

When you decompile a game, you're not just writing code that *does* the same thing — you need code that *is* the same thing, byte for byte. C++ lays out your class members in memory sequentially (with some padding for alignment), and if you get that layout wrong, every field access in every function becomes a bug.

Imagine a function in the retail binary that does `engine->GLevel = someLevel`. At the machine-code level that looks something like:

```asm
mov ecx, [ebp+8]         ; load 'engine' pointer
mov [ecx+0x458], eax     ; store someLevel at offset 0x458
```

If your `UGameEngine` struct has `GLevel` at offset `0x460` instead of `0x458`, that store goes to the wrong place. Your code compiles, it runs, and it silently corrupts memory. That's the nightmare scenario.

So we need `sizeof(UGameEngine) == 0x4D0` and every named field at its exact retail offset.

## The Starting Point: Ghidra's sizeof Assert

Ghidra is our decompilation ground truth. When you decompile a function that uses a class, Ghidra infers the layout from how the binary actually accesses memory. And for `UGameEngine::Init()`, Ghidra helpfully noted:

```cpp
// sizeof(UGameEngine) == 0x4D0
```

That's the target. Now, how do we fill 0x4D0 bytes?

### The Inheritance Chain

`UGameEngine` inherits from `UEngine`, which inherits from `USubsystem`, which inherits from both `UObject` and `FExec`. Let's work from the bottom up.

`UObject` is the base of everything in Unreal — every actor, texture, sound, and level is a `UObject`. Its layout is well-established: a vtable pointer, an index, flags, an outer pointer, a name, and a few more fields. Total: **0x30 bytes**.

`FExec` is an interface class — it has a virtual `Exec()` method and nothing else. No data members, just a vtable entry. And here's where C++ gets interesting.

## The Empty-Base Optimisation

In C++, even an object with no data members still needs a unique address — its size is technically at least 1 byte. But when you *inherit* from an empty class, most compilers (including MSVC) apply the **Empty-Base Optimisation (EBO)**. The empty base takes up *zero* additional space in the derived class.

So `USubsystem` inherits from `UObject` (0x30 bytes) and `FExec` (empty). With EBO:

```
sizeof(USubsystem) == sizeof(UObject) == 0x30
```

No padding, no extra pointer — `FExec`'s vtable merges with `UObject`'s in MSVC's multiple-inheritance vtable layout. This surprised me at first. You'd expect `sizeof(USubsystem)` to be at least `0x34` to accommodate a second vtable pointer for `FExec`. But EBO means the compiler is smarter than that.

`UEngine` then inherits from `USubsystem`, so its data starts at offset `0x30`.

## Mapping UEngine Field by Field

Here's where the archaeology gets fun. `UEngine::Serialize()` in the Ghidra output touches specific offsets:

- Offset `0x40`: serializes a `UObject*` pointer (some cached object reference)
- Offset `0x44`: `Client` — the `UClient*` pointer to the windowing system
- Offset `0x48`: `Audio` — the `UAudioSubsystem*`
- Offset `0x4C`: `GRenDev` — the `URenderDevice*` for rendering

That means there are `0x14` bytes between the end of `UObject` (at `0x30`) and the `Client` field (at `0x44`). We call that `_ue_pre[0x14]` — a padding array for fields we haven't named yet.

After `GRenDev` at `0x4C`, there's a big stretch of fields we haven't fully decoded: configuration values, pointers to game systems, counters. Ghidra gives us landmarks — `CacheSizeMegs` is at `0x84`, `UseSound` is at `0x88` — but the rest is an `_ue_unk[0x408]` blob for now.

That brings us to:

```
0x30 + 0x14 (pre) + 0x04 (Client) + 0x04 (Audio) + 0x04 (GRenDev) + 0x408 (unk) = 0x458
```

`sizeof(UEngine) == 0x458`. ✓

## Mapping UGameEngine

`UGameEngine` adds its own fields on top of `UEngine`. The ones we can confirm from Ghidra:

- Offset `0x458`: `GLevel` — the `ULevel*` for the currently-loaded map
- Offset `0x45C`: `GEntry` — the `ULevel*` for the entry (menu) level  

Then there are more fields we haven't decoded — `GPendingLevel`, server URLs, network state. For now, `_uge_unk[0x70]` fills the gap from `0x460` to `0x4CF`.

```
0x458 + 0x04 (GLevel) + 0x04 (GEntry) + 0x70 (unk) = 0x4D0
```

`sizeof(UGameEngine) == 0x4D0`. ✓

## Verifying with static_assert

One of the best tools in decompilation work is the compile-time assertion. We added these to `Engine.cpp`:

```cpp
static_assert(sizeof(UEngine)     == 0x458, "UEngine layout wrong");
static_assert(sizeof(UGameEngine) == 0x4D0, "UGameEngine layout wrong");
```

If the layout ever drifts — someone adds a field, reorders things, changes inheritance — the build fails immediately with a clear error. No runtime corruption, no mysterious crashes. The compiler tells you exactly what's wrong before a single line of code runs.

## The Bugs That Were Hiding

Fixing the class layouts forced a full recompilation of the Engine module. That's `~80` source files all being reprocessed from scratch. And that's when we found some pre-existing bugs that had been dormant in the object cache.

### The Unicode Interloper

`UnPhysic.cpp` had a constructor signature that looked like this in the raw file:

```
FZoneProperties::FZoneProperties()(53 bytes): zeroes offsets 0x08–0x44 (16 DWORDs).
```

Someone had copy-pasted a decompilation note directly into the constructor signature. The text contained an en-dash (`–`, Unicode U+2013) and a smart-quote — characters that MSVC's C3872 error helpfully flags: "character is not allowed in an identifier". The code probably compiled before because this translation unit wasn't being recompiled. The moment the cache was busted, the bug surfaced.

Fix: remove the garbage text and put the documentation comment inside the function body where it belongs.

### The Missing Brace

`UnRenderUtil.cpp` had an equally subtle problem:

```cpp
FAnimMeshVertexStream::FAnimMeshVertexStream()
    // zero-initialise by calling the placement constructor
    memset(this, 0, sizeof(*this));
}
```

See it? There's no opening `{`. This is another case of a corrupted decompilation note — the `{` was on the same line as some comment that got deleted, taking the brace with it. Again, only caught when the file was freshly compiled.

## The Lesson: Cache Invalidation as a Test

The interesting meta-lesson here is that when you change a widely-included header, you get a "free" audit of every file that includes it. Files that had stale cached objects had been hiding syntax bugs and encoding issues for potentially hundreds of builds.

In a project like this one — where we're reconstructing code from disassembly — there's always a risk that a file looks right to the human but has invisible corruption from copy-paste or character encoding. Forcing a full recompile by touching a core header is a crude but effective way to surface those issues.

## What's Next

With the layout verified, the `UGameEngine::Init()` implementation we wrote earlier now sits at the correct offsets. The entry-level and main-level pointers live where the retail binary expects them. One more piece of the engine puzzle clicks into place.

The next challenge: the remaining `_ue_unk` and `_uge_unk` blobs. They're not magic — they're real fields with real names that we just haven't decoded yet. As we implement more functions that touch those offsets, the fog will lift.

The build is green. Onwards.
