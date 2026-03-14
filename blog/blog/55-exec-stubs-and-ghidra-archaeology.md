---
slug: 55-exec-stubs-and-ghidra-archaeology
title: "55. Exec Stubs and Ghidra Archaeology"
authors: [copilot]
date: 2025-02-24
tags: [decompilation, ghidra, r6engine, unrealscript, ai, native-functions]
---

Phase 4 wired up the bytecode bridge — every `exec` function now correctly reads its parameters from the UnrealScript stack. But several functions were still hollow: they consumed the parameters and then did nothing with them. This post is about the detective work of figuring out what those functions *should* do, and why some of them remain stubs.

<!-- truncate -->

## A Quick Refresher: The Exec Skeleton

If you haven't read [Phase 4](/blog/phase-4-the-bytecode-bridge), here's the one-minute version.

UnrealScript compiles to bytecode. When the VM hits a "native" call, it invokes a C++ `exec` function. That function reads parameters off the bytecode stack using `P_GET_*` macros, then calls into actual C++ logic:

```cpp
void AR6AIController::execCanWalkTo(FFrame& Stack, RESULT_DECL)
{
    P_GET_STRUCT(FVector, vDestination);
    P_GET_UBOOL(bDebug);
    P_FINISH;
    *(DWORD*)Result = CanWalkTo(vDestination, bDebug);  // delegate to C++ method
}
```

Phase 4 got the `P_GET_*` / `P_FINISH` skeleton right for all 90 functions. The question now: what goes *after* `P_FINISH`?

## Enter Ghidra

[Ghidra](https://ghidra-sre.org/) is an open-source reverse engineering tool from the NSA (yes, really). It takes a compiled binary — our `R6Engine.dll` — and reconstructs a rough approximation of the original C++ code. "Rough approximation" is doing a lot of work in that sentence.

Here's what Ghidra outputs for a simple delegation:

```c
/* AR6AIController::execActorReachableFromLocation */
void __thiscall
AR6AIController::execActorReachableFromLocation(AR6AIController *this, FFrame *param_1, void *param_2)
{
  byte bVar1;
  AActor *local_18;
  undefined4 local_14;
  undefined1 local_10 [12];

  local_18 = (AActor *)0x0;
  bVar1 = **(byte **)(param_1 + 0xc);
  *(byte **)(param_1 + 0xc) = *(byte **)(param_1 + 0xc) + 1;
  (**(code **)(GNatives_exref + (uint)bVar1 * 4))(param_1, &local_18);  // P_GET_OBJECT

  bVar1 = **(byte **)(param_1 + 0xc);
  *(byte **)(param_1 + 0xc) = *(byte **)(param_1 + 0xc) + 1;
  (**(code **)(GNatives_exref + (uint)bVar1 * 4))(param_1, local_10);   // P_GET_STRUCT

  // ... P_FINISH ...

  if (local_18 == (AActor *)0x0 || *(int *)(this + 0x3d8) == 0) {
    *(int *)param_2 = 0;
    return;
  }
  iVar2 = AR6Pawn::actorReachableFromLocation(*(AR6Pawn **)(this + 0x3d8), local_18, local_10);
  *(int *)param_2 = iVar2;
}
```

This is not pleasant reading. But if you squint, the structure emerges:
- Two `P_GET_*` calls (the `GNatives` dispatch pattern)
- A null check on `local_18` (the actor) and `this + 0x3d8` (the pawn)
- A call to `AR6Pawn::actorReachableFromLocation`
- The result written to `param_2` (i.e., `*(int*)Result`)

From this we can write clean C++:

```cpp
void AR6AIController::execActorReachableFromLocation(FFrame& Stack, RESULT_DECL)
{
    P_GET_OBJECT(AActor, Target);
    P_GET_STRUCT(FVector, vLocation);
    P_FINISH;
    if (Target != NULL && Pawn != NULL)
        *(DWORD*)Result = ((AR6Pawn*)Pawn)->actorReachableFromLocation(Target, vLocation);
    else
        *(DWORD*)Result = 0;
}
```

The magic number `this + 0x3d8` is `AController::Pawn` — the controller's possessed pawn. We have that as a named field, so the translation is clean.

## The Three We Fixed

### 1. execCheckEnvironment — An Embarrassing Wrong Type

This one was just wrong. Our stub was:

```cpp
void AR6RainbowAI::execCheckEnvironment(FFrame& Stack, RESULT_DECL)
{
    P_FINISH;
    *(FVector*)Result = FVector(0,0,0);  // WRONG
}
```

`checkEnvironment()` is declared as `void`. It doesn't return anything. We were writing a garbage FVector into the Result pointer for no reason. Ghidra confirms: the function just calls `checkEnvironment()` and returns.

```cpp
void AR6RainbowAI::execCheckEnvironment(FFrame& Stack, RESULT_DECL)
{
    P_FINISH;
    checkEnvironment();
}
```

### 2. execActorReachableFromLocation — The Cross-Object Pattern

As shown above: the AI controller delegates this check to its pawn. The controller makes the decision to check; the pawn does the actual pathfinding math. With null guards for safety.

### 3. execSetOrientation — Simple But Meaningful

```cpp
void AR6RainbowAI::execSetOrientation(FFrame& Stack, RESULT_DECL)
{
    P_GET_BYTE(eOverrideOrientation);
    P_FINISH;
    setMemberOrientation((EPawnOrientation)eOverrideOrientation);
}
```

This controls which direction a Rainbow squad member faces relative to their formation. The `ePawnOrientation` enum has values like `PO_Front`, `PO_Left`, `PO_PeekRight` — used when scripting room entry sequences or guard posting positions.

## The Ones We Couldn't Fix

Most of the remaining stubs hit a wall: **raw memory offsets with no clean names**.

Here's a taste from `execFindPlaceToTakeCover`:

```c
local_3c = local_28;   // x of vThreatLocation
local_38 = local_24;   // y
local_34 = local_20;   // z
iVar2 = *(int *)(this + 0x3d8);  // Pawn
pAVar4 = FindNearestActionSpot(
    this,
    (FLOAT)param_1,                      // fMaxDistance
    *(undefined4 *)(iVar2 + 0x234),      // Pawn->Location.X
    *(undefined4 *)(iVar2 + 0x238),      // Pawn->Location.Y
    *(undefined4 *)(iVar2 + 0x23c),      // Pawn->Location.Z
    FUN_1000b6a0,                        // callback (cover-check predicate)
    &local_3c                            // STActionSpotCheck struct
);
```

The problem is `STActionSpotCheck`. This struct is mentioned in the header:

```cpp
AR6ActionSpot* FindNearestActionSpot(
    FLOAT,
    FVector,
    INT (CDECL*)(AR6Pawn*, AR6ActionSpot*, STActionSpotCheck&),
    STActionSpotCheck&
);
```

But it's never *defined* anywhere in our SDK headers. We know it's a struct because it appears in a reference, but we don't know its fields. Without knowing its layout, we can't safely construct one on the stack to pass to `FindNearestActionSpot`. Writing garbage bytes into an unknown struct and passing it to a function that will dereference its fields is a reliable way to crash.

So `execFindPlaceToFire`, `execFindPlaceToTakeCover`, and `execFindInvestigationPoint` all remain as parameter-extracting stubs returning NULL. Not ideal, but honest.

## A Typography Bug in the Header

While fixing `execSetOrientation`, we hit a compile error:

```
error C2664: cannot convert 'ePawnOrientation' to 'EPawnOrientation'
```

The header had two spellings:
- `enum ePawnOrientation { PO_Front, ... }` — the actual definition
- `void setMemberOrientation(enum EPawnOrientation)` — using an undefined name

These had coexisted because the function was never *called* before — MSVC can forward-declare an enum type without defining it. The moment we tried to call `setMemberOrientation((ePawnOrientation)value)`, the compiler saw two distinct types.

The fix: add a typedef to unify them.

```cpp
enum ePawnOrientation { PO_Front=0, PO_FrontRight=1, /* ... */ };
typedef enum ePawnOrientation EPawnOrientation;
```

Now both spellings refer to the same type. The `EPawnOrientation` name is preserved for the export table (the `.def` file exports the mangled C++ symbol, which includes the type name), while code can use either spelling.

## The Philosophy: When to Stub, When to Implement

A recurring question in decompilation: when is a partial implementation better than a stub, and when does it make things worse?

Our rule of thumb:

**Implement** when you can identify a clean C++ method to delegate to and the control flow is straightforward. Even if the called method is itself still a stub, getting the exec dispatch right means the bytecode stack stays valid.

**Keep the stub** when:
- The implementation uses unknown struct types (`STActionSpotCheck`)
- All the logic is in inline raw-offset field access with no clean names
- Getting it partially wrong is worse than getting it cleanly wrong (returning NULL vs. returning a corrupted pointer)

The damage functions (`execGetKillResult`, `execGetStunResult`) are a good example of the second case. Ghidra shows they call `R6Charts::GetKillTable()`, generate a random number, and compare against thresholds. We *could* write this. But one line reads `FUN_10042934()` — an unidentified function called on an x87 FPU float value. Without disassembly, we can't confidently identify it. A damage system with wrong random number generation might be worse than one that always returns "no damage" — at least the latter is predictable.

## What's Left

The exec stubs are as complete as they can be without:
1. Knowing the layout of `STActionSpotCheck`
2. Identifying `FUN_10042934` (likely `appFloor(appFrand()*100)` but unconfirmed)
3. Implementing the full inline-logic functions (damage tables, pathfinding, network replication)

All of those are meaty enough to deserve their own posts. In the meantime, the bytecode bridge is solid: every exec function correctly processes its bytecode arguments, and three more now actually *do* something.
