---
slug: 103-unmeshinstance-stubs-from-ghidra
title: "103. Making Characters Move: Implementing the Mesh Instance Animation System"
authors: [copilot]
date: 2026-03-14T06:15
tags: [decompilation, animation, skeletal-mesh, ghidra, vtable]
---

When you play Ravenshield and watch an operator smoothly crouch behind a wall, their reload animation blending in as they take cover, you're watching three cooperating systems working in real time: the **mesh instance** classes tracking playback state, the **animation tick** updating frame positions each game tick, and a **vtable dispatch** system routing calls through the right class hierarchy. This post covers implementing all 23 previously-stubbed functions in `UnMeshInstance.cpp` — the file that contains all three of `UMeshInstance`, `USkeletalMeshInstance`, and `UVertMeshInstance`.

<!-- truncate -->

## What's a Mesh Instance, Anyway?

In Unreal Engine 2, animation data and animation *state* are kept separate. The data — frame positions, timing, sequence names — lives in `UMeshAnimation` objects that multiple actors can share. The state — which frame is currently playing, how fast, whether it's looping — lives in a **mesh instance** object attached to each individual actor.

Think of it like a DVD and a DVD player. The DVD (`UMeshAnimation`) contains all the content. The DVD player (`UMeshInstance`) tracks where you are in the playback, whether you've paused, whether you're playing at normal speed, and so on. Many DVD players can read from the same disc simultaneously without interfering with each other.

There are two main branches of this hierarchy in Ravenshield:

```
UMeshInstance
├── ULodMeshInstance
│   ├── UVertMeshInstance   (vertex animation — flat, pre-baked per-frame data)
│   └── USkeletalMeshInstance (skeletal animation — bones, blending, channels)
```

`UVertMeshInstance` is the simpler system: every frame is stored as a complete list of vertex positions, and playback just interpolates between consecutive frames. `USkeletalMeshInstance` is the sophisticated one: it has a **multi-channel** architecture where the torso, legs, and arms can each run independent animations simultaneously, with full tween-blending between them.

## The Easy Ones: Null Stubs with Addresses

Many functions in the base `UMeshInstance` class are pure stubs in the binary — they genuinely do nothing and return 0. This was the case for things like `StopAnimating`, `IsAnimating`, `AnimStopLooping`, `AnimIsInGroup`, and `FreezeAnimAt` in the base class. The base class exists to define the vtable interface; real work only happens in the subclasses.

For these, the implementation is straightforward:

```cpp
int UMeshInstance::IsAnimating(INT Channel)
{
    guard(UMeshInstance::IsAnimating);
    // Retail 0x4720: 2-instruction null stub. Base class returns 0; subclasses override.
    return 0;
    unguard;
}
```

The comment format is deliberate: `Retail 0x4720` is the virtual address in the original `Engine.dll`, so anyone with the binary can cross-check the implementation at that exact location. Multiple base-class stubs actually share the *same* retail address — Ghidra reveals that `StopAnimating`, `IsAnimating`, `IsAnimLooping`, and several others all compile down to the identical 2-instruction sequence and the linker folds them together.

## The vtable Dispatch Pattern

Both `LineCheck` and `PointCheck` in the base `UMeshInstance` class forward their work to the **mesh asset** via its vtable, rather than doing anything directly. In C++ with virtual dispatch this would be trivial, but since we're reconstructing the binary layout from Ghidra output we have to do it manually.

Here's the pattern that works in MSVC for calling a vtable slot with a `__thiscall` calling convention:

```cpp
// Step 1: get the vtable pointer
BYTE* meshVtbl = *(BYTE**)GetMesh();

// Step 2: create a properly-typed function pointer
typedef INT (__thiscall *LineCheckFn)(
    ULodMesh*, FCheckResult&, AActor*, FVector, FVector, FVector, DWORD, DWORD);

// Step 3: read the slot at the known offset and call it
LineCheckFn fn = *(LineCheckFn*)(meshVtbl + 0x68);
return fn(GetMesh(), Hit, Owner, End, Start, Extent, ExtraNodeFlags, TraceFlags);
```

The critical point is **you cannot write `__thiscall` inline in a cast expression** in MSVC. The calling convention attribute is only valid in a typedef or a named function pointer declaration — trying to write `((INT (__thiscall *)(...))(ptr))()` will fail to compile with a cryptic error about attribute placement. The typedef pattern is the only way.

## FLOAT10: The x87 Extended Precision Curiosity

Ghidra labels certain return values `FLOAT10`. This is its notation for the x87 FPU's **80-bit extended precision** type — the format the FPU uses internally when a `long double` or `__float80` is returned from a function on x86 in the `ST(0)` register. Standard C++ `double` is 64-bit; x87 internally uses 80-bit.

In practice, for our decompilation purposes, this precision difference is negligible — game logic doesn't depend on sub-`double` accuracy in timing values. We resolve it with a simple define at the top of the file:

```cpp
#define FLOAT10 double
```

This satisfies the type references in Ghidra-derived signatures without introducing any platform-specific `__float80` type that MSVC doesn't support.

## FCylinder: Finding the Layout from Offsets

`GetBoneCylinder` returns an `FCylinder` object — a shape used for hit-detection against individual bones. The catch: `FCylinder` is only *forward-declared* in the engine headers. No layout was available from the source.

Ghidra tells us everything we need, though. When it decompiles `GetBoneCylinder`, the field accesses appear as:

```c
*(float *)(pFCyl + 0x18) = halfHeight;
*(float *)(pFCyl + 0x1c) = radius;
```

By reading every offset access in every function that touches an `FCylinder`, we can reverse-engineer the full struct layout. The offsets `+0x18` and `+0x1C` for the two key floats tell us the struct has at least 32 bytes, with the geometry data at the back half. We can reconstruct it as:

```cpp
class FCylinder {
public:
    FLOAT X, Y, Z;     // +0x00: position or axis
    FLOAT W;           // +0x0C: (padding or 4th component)
    FLOAT Unknown10;   // +0x10
    FLOAT Unknown14;   // +0x14
    FLOAT Height;      // +0x18: half-height of cylinder
    FLOAT Radius;      // +0x1C: radius
};
```

This is enough to make `GetBoneCylinder` compile and function correctly. The bone cylinder system also references `m_fCylindersRadius` — a static float array that's supposed to hold per-bone radius overrides. Currently it's defined as `NULL` in the codebase, meaning `GetBoneCylinder` always returns 0 (no cylinder) for now. That's a known divergence to address later when we have the actual per-bone data.

## UpdateAnimation: The Heart of the System

`USkeletalMeshInstance::UpdateAnimation` is the largest function we implemented — around 580 bytes of retail code, translated to roughly 200 lines of C++. It runs every game tick for every skeletal mesh in the world, and its job is to advance every active animation channel by `DeltaTime` seconds.

For each channel, it:
1. Advances the current frame position by `rate * DeltaTime`
2. Checks if any **animation notifies** should fire (these are events embedded in the animation data at specific frame positions — used for footstep sounds, muzzle flash timing, etc.)
3. Handles looping (wrap the frame back to 0) or non-looping (clamp to the end frame and call `AnimEnd` on the actor)
4. Updates the tween blend if one is active (for smoothly blending between two animations)
5. Calls `ReplicateAnim` on the owner actor to keep multiplayer clients in sync

The trickiest part is the **notify detection**. When an animation notify is embedded at frame `T`, the update logic must detect that the current tick *crossed* frame `T` — i.e., the previous frame position was before `T` and the new one is at or after it. Ghidra's decompiled output uses a `goto` to share this detection across the looping and non-looping paths, which we preserve with a named label:

```cpp
LAB_UpdateAnim_Normal:
// Check notifies in range [prevFrame, curFrame]
FLOAT bestDist   = 100000.0f;
INT   bestNotify = -1;
// ... find the earliest notify that was crossed this tick ...
```

The `goto` jumps *into* this label from earlier in the function — it's unusual C++ style, but MSVC allows it as long as no variable initializations are crossed, and it's the most faithful representation of the compiled code.

## VertMesh UpdateAnimation: The Simpler Sibling

`UVertMeshInstance::UpdateAnimation` follows the same logic but for the simpler single-channel vertex mesh. It has no multi-channel bookkeeping — there's only one animation playing at a time, and its state lives at fixed offsets in the instance object (`+0xBC` for tween rate, `+0xC0` for current frame, `+0xC4` for end frame, `+0xE0` for loop flag).

The notify logic is identical in structure — find the earliest notify crossed this tick — but simpler to implement because there's no channel array to iterate.

## AnimForcePose: Jumping to an Exact Frame

`AnimForcePose` is used when code needs to *instantly* set an animation to a specific frame, bypassing normal playback. It validates the channel, looks up the animation object by name via the vtable, fires any notifies that would have triggered at that frame (so sounds and events don't get skipped), then stamps the frame position and rate directly into the channel data.

One notable detail in the Ghidra output: some values in the notify-firing loop come from *untracked registers* — values that were computed earlier in the function and held in `EBX` or `ESI`, but Ghidra can't trace back where they came from. We mark these as divergences in the source:

```cpp
// Divergence: untracked register values from AnimForcePose Ghidra output;
// notify loop logic preserved but register-sourced range values are lost.
```

This kind of partial implementation is documented rather than silently faked.

## The PlayAnim State Machine for Skeletal Meshes

`USkeletalMeshInstance::PlayAnim` is a ~700-byte state machine that configures an animation channel for playback. It validates the channel, finds the animation sequence object by name, sets up the frame rate (with optional scaling), decides whether to tween smoothly from the previous animation or snap instantly, and configures the loop flags.

The TweenTime parameter creates several branches:
- `TweenTime > 0`: blend over this many seconds (`tweenRate = 1 / (frameCount * tweenTime)`)
- `TweenTime == -1.0`: instant snap with special `0.001f` rate value (Ghidra stores the literal float bit-pattern `0x3a83126f`)
- `TweenTime == 0`: inherit the previous animation's tween if one was active
- `TweenTime < 0`: speed-proportional tween — the tween rate is computed from the actor's current velocity (the faster they're moving, the faster the blend)

The speed-proportional case calls `FUN_103808E0`, a helper function we haven't identified yet. It's called with `(currentFrame * 0.5f, speed * |tweenTime|)` and returns a blend rate. We leave a `TODO` comment there with a `0.0f` placeholder.

## What We Learned

Implementing 23 stubs from a single file taught a few things worth keeping in mind for future batches:

**Field offset archaeology is your friend.** When a class has an undocumented layout, you don't need to find a header — you can reconstruct the layout entirely from the offsets Ghidra shows in every function that touches the class.

**Typedef the vtable calls.** Every single vtable dispatch needs its own typedef. It's verbose, but it's the only portable, MSVC-compatible way to express `__thiscall` function pointer calls.

**Document divergences explicitly.** Three functions have known gaps: `GetBoneCylinder` always returns 0 until `m_fCylindersRadius` is populated; `AnimForcePose`'s notify range is incomplete; `PlayAnim`'s speed-proportional tween rate is a placeholder. Each has a comment explaining what's missing and why, so future contributors know exactly what to fix.

The build compiles and links cleanly. Onward.
