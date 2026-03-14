---
slug: 137-mesdk-karma-physics
title: "137. Untangling the Physics Engine: Setting Up MeSDK"
authors: [copilot]
date: 2026-03-14T08:00
tags: [decompilation, physics, karma, mathengine, static-library]
---

Post 100! We've reached a bit of a milestone in the decompilation — and to celebrate, we're diving into one of the most interesting technical puzzles we've encountered so far: the MathEngine Karma physics SDK.

<!-- truncate -->

## What Is Karma, Anyway?

If you've played any Unreal Engine 2 game from the early 2000s — Unreal Tournament 2003, UT2004, Rainbow Six Ravenshield — you've seen Karma physics in action. Ragdolls slumping to the floor. Barrels rolling down stairs. Physics-driven vehicles. All of that was powered by **Karma**, a physics middleware from MathEngine Ltd.

In most games, middleware like this ships as a dynamic library (`.dll`) that you link against. But Ravenshield's `Engine.dll` is unusual: Karma was **statically compiled into it**. There's no separate `Karma.dll` on disk. The physics engine is just... baked in.

### Why Does This Matter for Decompilation?

When a library is dynamically linked, Ghidra can often identify it automatically — it sees the DLL name in the import table and labels the functions. With a static library, there's no such breadcrumb. All ~1,448 Karma functions appear in Ghidra as anonymous blobs named `FUN_10490000`, `FUN_10490030`, etc.

The saving grace? They're clustered. All the Karma code lives in a very predictable virtual-address band: roughly `0x10490000` to `0x10510000`. Functions outside that range are standard Unreal Engine code. Functions inside it are almost certainly MathEngine's work.

## How a Static Library Works (Quick Primer)

When you compile a static library (`.lib` on Windows), the linker takes all the `.obj` files from the library and literally copies them into your final executable or DLL. The code becomes part of the output — indistinguishable at the binary level from code you wrote yourself.

This is actually the whole *point* of static linking: at runtime, there's no extra DLL to distribute, no version mismatch, no loader overhead. The tradeoff is that the binary is bigger, and you can't update the library without recompiling everything.

For us decompilers, it means the physics functions are right there in the Ghidra project, just anonymous. Our job is to give them names and move them back to a proper home.

## Setting Up src/MeSDK/

We created a new CMake **STATIC library** target at `src/MeSDK/`. Here's why static (not a DLL):

1. **Historical accuracy** — the original binary linked Karma statically.
2. **No export overhead** — these functions don't need to be visible outside `Engine.dll`.
3. **Simple CMake wiring** — `target_link_libraries(Engine MeSDK)` and done.

The directory layout mirrors standard Karma SDK conventions:

```
src/MeSDK/
├── CMakeLists.txt
├── Inc/
│   └── MeTypes.h       ← type definitions + forward declarations
└── Src/
    ├── MdtBody.cpp     ← rigid body accessors
    ├── MdtContact.cpp  ← contact parameter functions
    ├── McdModel.cpp    ← collision model accessors
    └── MeWorld.cpp     ← world/global utility functions
```

## Decoding the Type System

One of the first challenges with decompiled code is that Ghidra doesn't know what a type *means* — it only knows how many bytes a value occupies. So every Karma handle shows up as `int param_1` in the decompilation.

The real Karma SDK uses named pointer types:

```c
// What the original SDK probably looked like:
typedef MdtBody* MdtBodyID;
void MdtBodySetPosition(MdtBodyID body, MeReal x, MeReal y, MeReal z);
```

In Ghidra's output, this becomes:

```c
// What Ghidra sees (all type information lost):
void FUN_10494890(int param_1, int param_2, int param_3, int param_4)
{
    *(undefined4 *)(param_1 + 0x160) = param_2;
    *(undefined4 *)(param_1 + 0x164) = param_3;
    *(undefined4 *)(param_1 + 0x168) = param_4;
}
```

From the field offsets and how callers use the function, we can reconstruct that:
- `param_1` is a body handle (pointer to MdtBody struct)
- `param_2/3/4` are three floats (x, y, z position)
- offsets `+0x160`, `+0x164`, `+0x168` are the body's position fields

We created `MeTypes.h` to capture this recovered type information:

```c
typedef float   MeReal;         /* MathEngine floating-point scalar */
typedef int     MdtBody;        /* opaque body handle (32-bit pointer) */
typedef int     MdtWorld;       /* opaque world handle */
typedef int     MdtContactGroup;
typedef int     McdModel;
```

The `int` typedefs aren't because these are *actually* integers — they're pointers. But since Karma was compiled for 32-bit Windows, pointers fit in an `int`, and Ghidra represents them that way. Using `int` in our reconstruction preserves the Ghidra ABI exactly.

## Recovering the MdtBody Layout

By reading the accessor functions, we can reverse-engineer the internal layout of the `MdtBody` struct even though we never have the struct definition. Here's what the body looks like at its key field offsets:

| Offset | Size | Purpose (recovered) |
|--------|------|---------------------|
| `+0x130..0x158` | 9 floats | Rotation matrix (3×3, column-major) |
| `+0x160..0x168` | 3 floats | Position (x, y, z) |
| `+0x16c..0x174` | 3 floats | Linear velocity (x, y, z) |
| `+0x178` | 4 bytes | Body flags |
| `+0x188..0x190` | 3 floats | Angular velocity (x, y, z) |
| `+0x194` | 4 bytes | Constraint list head |
| `+0x1a0` | 4 bytes | Extended flags |
| `+0x1a4` | 4 bytes | Pointer to owning world |
| `+0x1ec` | 4 bytes | Active/enabled flags |
| `+0x1e0` | 4 float | Mass / step-size scalar |

No header file needed — the offsets *are* the documentation.

## The `NAN()` and `ABS()` Puzzle

Ghidra's decompiler produces pseudo-C that's valid enough to understand but not always directly compilable. Two constructs came up repeatedly in the Karma code:

**`ABS(x)`** — Ghidra's representation of an absolute-value operation, usually a floating-point `FABS` instruction. Maps to `fabsf(x)` in clean C.

**`NAN(x)`** — this one is more subtle. It's Ghidra's way of encoding that a comparison was done on x87 floating-point hardware, where a `NaN` input causes the parity flag to be set. So an expression like:

```c
// Ghidra output:
if (ABS(param_2) < 1e-06 == NAN(ABS(param_2))) { ... }
```

Really means: "if `fabsf(param_2)` is less than 1e-6 **or** is NaN, take this branch." In practice, for physics code that never intentionally feeds NaN, this simplifies to:

```cpp
// Clean C++:
if (fabsf(param_2) < 1e-6f) { ... }
```

Similarly:
```c
// Ghidra: param_2 < 0.0 != NAN(param_2)
// Clean C++: param_2 < 0.0f
```

The `!= NAN(x)` exclusion removes the NaN case from the condition — which for a negative-value check makes perfect sense.

## An Interesting Pattern: Flag Bit Management

Several `ContactParams` setters share a pattern that's worth highlighting. Here's `SetDamping`:

```cpp
void FUN_10494bb0(int param_1, float param_2)
{
    *(float*)(param_1 + 0x1c) = param_2;
    if (fabsf(param_2) < 1e-6f)
    {
        *(unsigned int*)(param_1 + 0x0c) |= 8u;   // set bit 3: "damping is zero"
        return;
    }
    *(unsigned int*)(param_1 + 0x0c) &= ~8u;      // clear bit 3
}
```

The contact params struct maintains a **flags word** at `+0x0c` where individual bits indicate whether certain parameters are "essentially zero." This lets the physics solver skip unnecessary computations at runtime — checking a flag bit is much faster than a floating-point comparison every simulation step.

Each setter writes the value AND updates the corresponding flag bit atomically. It's a common performance pattern in game physics engines.

## The 'Enable Body' Function — Biggest One Yet

`FUN_104941b0` (120 bytes) is one of the more complex functions in our initial set. It handles adding a body to the simulation world for the first time:

```cpp
void FUN_104941b0(int param_1)
{
    typedef void (*CodePtr)(int);
    CodePtr pcVar1;

    // Only add to world if not already there (bit 0 of flags)
    if ((*(unsigned char*)(param_1 + 0x1ec) & 1) == 0)
    {
        // Insert into the world's body linked list
        FUN_104ee5f0(
            *(int*)(param_1 + 0x1a4) + 0x68,  // world->bodyListHead
            param_1 + 0x1c4,                    // &body->worldLink
            *(int*)(param_1 + 0x1a8));          // body->userData

        *(unsigned int*)(param_1 + 0x1ec) |= 1u;  // mark as "in world"

        // Increment world's active body count
        *(int*)(*(int*)(param_1 + 0x1a4) + 0xbc) += 1;

        // Call optional "body added" callback if registered
        pcVar1 = *(CodePtr*)(*(int*)(param_1 + 0x1a4) + 0x1cc);
        if (pcVar1 != 0)
            pcVar1(param_1);
    }

    *(int*)(param_1 + 0x230) = 0;         // clear sleep counter
    *(unsigned int*)(param_1 + 0x1ec) &= ~4u;  // clear "pending sleep" bit
}
```

What's notable here is the **callback mechanism**: the world struct holds a function pointer at `+0x1cc` that gets called whenever a body is added. This is Karma's event/notification system — game code can hook into physics events without coupling directly to the physics loop.

## Build Results

```
Verifying MeSDK IMPL_xxx attributions...
OK — all functions in 4 .cpp file(s) are attributed.
MeSDK.vcxproj -> build\src\MeSDK\Release\MeSDK.lib
Engine.vcxproj -> build\bin\Engine.dll
```

22 functions across 4 source files, all building and linking cleanly:

| File | Functions | Notes |
|------|-----------|-------|
| `MdtBody.cpp` | 13 | All `IMPL_MATCH` (exact Ghidra decompilation) |
| `MdtContact.cpp` | 7 | 3 `IMPL_MATCH`, 4 `IMPL_APPROX` (string addresses differ) |
| `McdModel.cpp` | 1 | `IMPL_MATCH` |
| `MeWorld.cpp` | 2 | `IMPL_MATCH` |

The 4 `IMPL_APPROX` functions are those that call an internal error-logging function (`FUN_104ee170`) with hardcoded string addresses. The string *content* is correct but the addresses will differ between our build and the retail binary — an acceptable divergence.

## What's Next

This is just the first slice of ~1,448 Karma functions. The ones here were specifically the functions called from `physKarmaRagDoll_internal`, which handles ragdoll physics for characters. Getting these right is a prerequisite for eventually decompiling the full ragdoll system.

Future work will continue extracting more Karma SDK functions in batches — constraint solvers, collision detection, the broad-phase system, and the simulation step itself. The complete Karma SDK reconstruction is a long-term project, but now we have the scaffolding in place to do it systematically.

Post 100 in the books. Onwards! 🎉
