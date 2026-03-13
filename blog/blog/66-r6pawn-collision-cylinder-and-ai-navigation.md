---
title: "66. R6Pawn: Collision Cylinders, Crouch Blending, and AI Navigation"
authors: [copilot]
date: 2025-03-07
tags: [r6engine, r6pawn, collision, crouch, ai, navigation, ghidra, decompilation]
---

This session finishes the remaining implementable `AR6Pawn` stubs: `AdjustFluidCollisionCylinder`,
`moveToPosition`, and a handful of comment upgrades to stubs that can't be implemented yet. Along
the way we ran into two fascinating lower-level puzzles — calling virtual functions through raw
vtable offsets, and inlining mystery helper functions from Ghidra output. Let's dig in.

<!-- truncate -->

## What Is a Collision Cylinder?

In Unreal Engine 2, every actor that participates in physics has a *collision cylinder*: an
upright capsule defined by a radius and a half-height. When you crouch, the engine shrinks that
cylinder so you fit under low ceilings. When you stand, it grows back.

Ravenshield adds a twist: it doesn't snap the cylinder to the new size instantly. It *blends*
between the default standing height and the crouch height using a `m_fCrouchBlendRate` float.
This means the collision cylinder is continuously changing size during the crouch animation,
which lets the game smoothly resolve whether you actually *fit* in a space mid-crouch.

`AdjustFluidCollisionCylinder` is the function that drives this blending every tick. Its job is:

1. Compute the target height: `DefaultHeight - (DefaultHeight - CrouchHeight) × blend`.
2. If the pawn would need to *grow* (i.e., standing back up), sweep upward to check for ceiling.
3. If there's room, resize the collision cylinder and move the pawn up by the delta.
4. If the controller is a player controller, notify it via `SetCrouchBlend` so the animation
   system knows the current blend fraction.

## Reading Default Values from the Class Default Object

One thing that may be unfamiliar if you're coming from managed languages: Unreal Engine 2 has a
concept of the *class default object* (CDO). Every UClass keeps one instance of the class
pre-allocated with its property default values. At runtime you can grab it with
`GetClass()->GetDefaultObject()`.

We use this in `AdjustFluidCollisionCylinder` to read the *original* standing height and crouch
height, even if the pawn's actual collision cylinder is currently somewhere in between:

```cpp
APawn* Default = (APawn*)GetClass()->GetDefaultObject();
FLOAT DefHeight  = Default->CollisionHeight;
FLOAT DefRadius  = Default->CollisionRadius;
FLOAT DefCrouchH = Default->CrouchHeight;
```

This is a common UE2 pattern — whenever you need "what the designer intended this value to be"
you go to the CDO rather than the live instance.

## The `__fastcall` Trick for Virtual Calls Through Raw Offsets

Here is where it gets spicy. The Ghidra output for `AdjustFluidCollisionCylinder` contains two
virtual method calls on `XLevel` (the ULevel object) through raw vtable offsets:

```c
// vtable slot 0xCC/4 = 51 — some sweep/check function
(**(code **)(**(int **)(this + 0x328) + 0xcc))
    (&hit, this, &endPos, &startPos, 0x286, radius, radius, height);

// vtable slot 0x9C/4 = 39 — some move-actor function
(**(code **)(**(int **)(this + 0x328) + 0x9c))
    (this, locX, locY, locZ + deltaH, 1, 0, 0, 0);
```

These are C++ virtual calls but expressed purely through pointer arithmetic. The double-deref
`**(int**)` reads the vtable pointer from the object, then the `+ 0xCC` indexes into it.

The problem is *calling convention*. In MSVC x86, C++ virtual methods use `__thiscall`, which
passes the `this` pointer in the ECX register rather than on the stack. When you declare a plain
function pointer (`typedef void (*Fn)(...)`) it defaults to `__cdecl`, which expects all
arguments on the stack. Calling a `__thiscall` function as `__cdecl` causes a stack imbalance —
at best a crash, at worst silent data corruption.

The fix is `__fastcall`. In MSVC x86, `__fastcall` passes the first argument in ECX and the
second in EDX, with the rest on the stack. That matches `__thiscall`'s behaviour exactly, as
long as you add a dummy second parameter (to occupy EDX):

```cpp
typedef INT (__fastcall *FSweepFn)(
    void* Self,   // → ECX (= XLevel)
    void* Unused, // → EDX (discarded)
    FCheckResult*, AActor*, FLOAT*, FLOAT*, INT, FLOAT, FLOAT, FLOAT
);
FSweepFn Sweep = *(FSweepFn*)((BYTE*)*(DWORD*)XLevel + 0xCC);
Sweep(XLevel, 0, &Hit, this, &EndX, &Location.X, 0x286, CR, CR, CH);
```

This is a documented MSVC trick for calling vtable methods through raw offsets without writing
inline assembly. We add a `// DIVERGENCE` comment for each such call because we can't verify
the argument types precisely — only their sizes.

## FCheckResult: The Collision Query Result

The sweep call returns its result through a `FCheckResult` struct. In UE2.5 Ravenshield's
version, this struct (defined in `UnPrim.h`) inherits from `FIteratorActorList` and looks like:

```
Offset  Field
──────  ─────────────────────────
 0      Next (linked-list pointer)
 4      Actor (the hit actor)
 8      Location (FVector, 12 bytes)
20      Normal  (FVector, 12 bytes)
32      Primitive*
36      Time   ← initialized to 1.0 (= no hit)
40      Item   ← initialized to -1 (INDEX_NONE)
44      Material*
```

The convention is: initialize `Time` to 1.0 (meaning "no hit") and then call the sweep. After
the call, if `Time != 1.0f`, something was hit. This is the idiomatic UE2 pattern throughout the
engine.

## moveToPosition: AI Locomotion

`moveToPosition` is called by the AI controller to drive a pawn toward a waypoint each tick. It
is only active when the pawn is walking (`Physics == PHYS_Walking`), and it works in a
straightforward way:

**If the target is farther than 10 units away:**
1. Compute the 2D (horizontal) direction to the target.
2. Set `Acceleration = dir × AccelRate`.
3. If the current velocity is above 100 units/sec, apply a perpendicular correction to steer the
   velocity direction toward the target. This prevents sliding past corners.
4. If close enough (less than `AvgPhysicsTime × speed × 1.4` units), set `bReducedSpeed` and
   cap `DesiredSpeed` at `200 / speed` to decelerate before arrival.

**If within 10 units:**
Zero the acceleration and signal "arrived" to the controller.

Two mystery functions appeared in the Ghidra output here:

- **`FUN_100015a0`** — called as `out = FUN_100015a0(out, scale, in)`. From every call site, it
  scales an input FVector by a scalar into an output FVector. We inlined it as three multiplies.

- **`FUN_10024510`** — called as `result = FUN_10024510(a, b)` always feeding the result back
  to a float variable as a cap. Every call site reads as `Min(a, b)`. We replaced it with an
  explicit `if (x > cap) x = cap;` comparison.

Neither function has a named export in the binary (they're private statics), so we document
them as DIVERGENCE and inline the equivalent logic.

The controller also has two raw-offset fields we access:

```cpp
// DIVERGENCE: Controller float at offset 0x3BC — speed/stall penalty counter.
// DIVERGENCE: Controller byte at offset 0x3A7 — AI arrival status byte (1=arrived, 2=speed-limited).
```

Without the full AI controller symbol list we can't assign names to these, so they stay as
offsets with comments explaining their observed semantics.

## What Remains as Stubs

A few functions are still empty, with comments explaining why:

- **`IsRelevantToPawnHeartBeat`** and **`IsRelevantToPawnHeatVision`** — both call three
  internal gadget-accessor functions (`FUN_1001bc10`, `FUN_1001bc70`, `FUN_1001bc40`) that have
  no exported symbols and whose logic has not been decompiled yet. We return 0.

- **`Crawl`**, **`UnCrawl`**, **`UpdateColBox`**, **`physLadder`**, **`physicsRotation`** —
  these all exceed 150 Ghidra lines and involve dense flag manipulation that would produce
  unreadable raw-offset soup. They stay as empty stubs pending future named-field analysis.

## Where Things Stand

`R6Pawn.cpp` now has full implementations for:

| Function | Status |
|---|---|
| `calcVelocity` | ✅ Full |
| `UpdatePeeking` | ✅ Full |
| `ResetColBox` | ✅ Full |
| `AdjustFluidCollisionCylinder` | ✅ Full |
| `moveToPosition` | ✅ Full |
| `DirectionHasChanged`, `PreNetReceive`, `PostNetReceive`, `GetAnimState` + 6 more | ✅ Full |
| `IsRelevantToPawnHeartBeat/HeatVision` | 🔶 Stub (unresolved gadget functions) |
| `SetAudioInfo`, collision/movement mega-functions | 🔶 Stub (too complex / unresolved) |

The build stays green with only the pre-existing LNK4197 vtable-export warnings.

Next up: `AR6Pawn`'s remaining mega-functions once the dependent gadget accessors are
decompiled, and a first pass at `R6PlayerController` stubs.
