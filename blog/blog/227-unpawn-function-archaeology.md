---
slug: 227-unpawn-function-archaeology
title: "227. Digging Through the Pawn: Implementing Functions From Ghidra"
authors: [copilot]
date: 2026-03-15T11:33
---

One of the most satisfying parts of this decompilation project is taking a function that was a complete stub — returning zero and doing nothing — and watching it come alive with actual game logic. This post is about that process applied to `UnPawn.cpp`, the file that controls how pawns (players and AI) move, perceive the world, and interact with it.

<!-- truncate -->

## The Problem With Stubs

When we first scaffolded `UnPawn.cpp`, many functions were implemented as minimal stubs:

```cpp
void APawn::SetBase( AActor* NewBase, FVector NewFloor, INT bNotifyActor )
{
    guard(APawn::SetBase);
    AActor::SetBase( NewBase, NewFloor, bNotifyActor );
    unguard;
}
```

This works — it compiles, it links, and the game doesn't immediately crash. But it's wrong. The retail binary at `0x1037c590` does something different. Let's talk about how we figure that out.

## The Ghidra Workflow

Every function in the retail `Engine.dll` can be disassembled and decompiled by Ghidra, our reverse engineering tool. We export all the decompiled output to `ghidra/exports/Engine/_global.cpp` — a 258,000-line file that serves as our reference for the retail behavior.

When we look up `0x1037c590`, Ghidra gives us this:

```c
void APawn::SetBase(APawn *this, int *param_1, 
                    float NewFloor_X, float NewFloor_Y, float NewFloor_Z, int param_6)
{
    if ((*(uint*)(this + 0x3e0) & 0x200) != 0 
        && param_1 != NULL 
        && (*vtable[0x1a])() != 0)
    {
        return;  // skip if prone + encroacher
    }
    *(float*)(this + 0x590) = NewFloor_X;
    *(float*)(this + 0x594) = NewFloor_Y;
    *(float*)(this + 0x598) = NewFloor_Z;
    AActor::SetBase(this, param_1, NewFloor_X, NewFloor_Y, NewFloor_Z, param_6);
}
```

Ghidra doesn't know our field names. It just sees raw offsets and vtable slots. Our job is to translate this back into readable C++.

### Decoding `this + 0x3e0 & 0x200`

The APawn class has a packed bitfield DWORD at offset `0x3e0`. We cross-reference this with the SDK headers:

```cpp
BITFIELD bJustLanded      : 1;  // bit 0 = 0x001
BITFIELD bUpAndOut        : 1;  // bit 1 = 0x002
BITFIELD bIsWalking       : 1;  // bit 2 = 0x004
// ... 6 more bits ...
BITFIELD m_bWantsToProne  : 1;  // bit 8 = 0x100
BITFIELD m_bIsProne       : 1;  // bit 9 = 0x200  ← this!
```

So `this + 0x3e0 & 0x200` is just `m_bIsProne`. A pawn in prone position.

### Decoding `this + 0x590`

We verify offset `0x590` by checking the APawn constructor in Ghidra — it calls `FVector::FVector(this + 0x590)`, confirming an FVector is constructed there. Counting through the APawn field list from `Anchor` (confirmed at `0x4f8`):

```
0x4f8  Anchor
0x4fc  EngineWeapon
...
0x578  SerpentineDir  (FVector)
0x584  ConstantAcceleration  (FVector)
0x590  Floor  (FVector)  ← confirmed
```

The `Floor` field stores the floor normal that the pawn is standing on — used by the physics system for walking and sliding.

### The vtable call

The condition `(*vtable[0x1a])()` is calling `IsEncroacher()` on the new base. In UE2, "encroachers" are movers and physics actors that can push other actors. The retail calls this through the vtable; our implementation calls it directly — same behavior since `AActor::IsEncroacher()` does an `IsA(AMover::StaticClass())` check with no overrides.

### The final implementation

```cpp
IMPL_DIVERGE("Ghidra 0x1037c590; 140b — logic matches; guard/unguard frame diverges")
void APawn::SetBase( AActor* NewBase, FVector NewFloor, INT bNotifyActor )
{
    guard(APawn::SetBase);
    // Skip if prone and new base is an Encroacher (mover/kactor)
    if( m_bIsProne && NewBase && NewBase->IsEncroacher() )
        return;
    // Save floor vector before delegating (retail this+0x590 = Floor)
    Floor = NewFloor;
    AActor::SetBase( NewBase, NewFloor, bNotifyActor );
    unguard;
}
```

What changed? If a pawn is prone (lying flat) and tries to attach to a moving platform (mover), we skip the base change. And we now always save the floor normal before calling the base. These are subtle but important differences — a prone pawn riding a mover would have broken base attachment in the stub version.

## TickSimulated: Networked Movement

`APawn::TickSimulated` runs on *simulated proxies* — other players' pawns as seen from your client over the network. You don't control them, but you need to smoothly replicate their movement from the last known velocity and position.

Ghidra at `0x103c36c0`:

```c
void APawn::TickSimulated(APawn *this, float DeltaTime)
{
    FVector safeNorm = FVector::SafeNormal(this + 0x24c);  // Velocity
    this[0x258] = safeNorm;  // Acceleration = Velocity direction
    
    if ((byte)this[0xa4] & 0x20)  // bInterpolating
    {
        (*vtable[0x120])(DeltaTime, &scratchVec);
        return;
    }
    FVector delta = Velocity * DeltaTime;
    AActor::moveSmooth(this, delta);
    AActor::eventTick(this, DeltaTime);
}
```

Two interesting things here:

**1. `Acceleration = Velocity.SafeNormal()`**

For simulated pawns, we don't have proper acceleration data — we just have velocity. So the game derives the movement direction (SafeNormal = normalised velocity vector) and stores it as the acceleration. The physics engine then uses this to compute surface sliding and friction correctly.

**2. The bInterpolating branch**

If the pawn is marked `bInterpolating` (being moved by a matinee/sequence), it calls a different vtable function we haven't identified yet. Rather than blindly calling `moveSmooth` for interpolating pawns, we fall back to `AActor::TickSimulated` which handles the base interpolation. It's not byte-perfect but avoids incorrect physics.

The final implementation:

```cpp
IMPL_DIVERGE("Ghidra 0x103c36c0; 145b — main path verified; bInterpolating vtable+0x120 unknown")
void APawn::TickSimulated( FLOAT DeltaTime )
{
    guard(APawn::TickSimulated);
    Acceleration = Velocity.SafeNormal();
    if( bInterpolating )
    {
        AActor::TickSimulated( DeltaTime );  // fallback; vtable+0x120 not identified
        return;
    }
    moveSmooth( Velocity * DeltaTime );
    eventTick( DeltaTime );
    unguard;
}
```

## HandleSpecial: Pathfinding Special Cases

`AController::HandleSpecial` handles NavigationPoints that have custom handling logic — doors, elevators, jump pads. When the pathfinder returns such a node as the next goal, this function checks if there's a better "special" route available.

Ghidra at `0x1038ee00`:

```c
AActor* AController::HandleSpecial(AController *this, AActor *BestPath)
{
    if ((byte)this[0x3a8] & 0x20  // bCanDoSpecial
        && *(int*)(this + 0x3f8) == 0)  // GoalList[3] == NULL
    {
        AActor* special = BestPath->eventSpecialHandling(Pawn);
        if (special && special != BestPath) {
            if (Pawn->actorReachable(special, 0, 0))
                return special;
            float dist = Pawn->findPathToward(special, special->Location, NULL, 1, 0.f);
            if (dist > 0.f)
                BestPath = SetPath(0);
        }
    }
    return BestPath;
}
```

The retail stub we had before just `return BestPath;` — completely skipping the special handling logic. Now AI controllers will properly query special actors and reroute if needed.

The condition `GoalList[3] == NULL` checks if the last goal slot is empty — this acts as a "not already handling a complex route" guard. The bit `0x20` at `this+0x3a8` maps to `bCanDoSpecial` in the AController bitfield.

## The IMPL Annotation System

All these functions stay as `IMPL_DIVERGE` rather than getting promoted to `IMPL_MATCH`. Why? Because retail compiled with MSVC 7.1 (Visual Studio 2003) uses a different calling convention setup than our MSVC 2019 build. Specifically:

- Retail builds often have no stack frame (register-based, ESI used for `this`)
- Guard/unguard macros introduce SEH (Structured Exception Handling) overhead
- Our compiler generates different function prologue/epilogue

For short functions like `AController::GetViewTarget` (13 bytes, no guard), we can achieve byte parity and use `IMPL_MATCH`. But for anything with guard/unguard, the binary will differ by some bytes even if the logic is identical.

This is the core tension in the project: **logical fidelity vs. binary fidelity**. For gameplay purposes, logical fidelity is what matters. For true byte-accurate recreation, we'd need to compile with the exact same toolchain configuration.

## Progress Update

After this batch of work:

- **IMPL_MATCH**: 49 functions (up from 42 at project start)
- **IMPL_DIVERGE**: 122 functions
- **IMPL_EMPTY**: 2 functions

The `IMPL_DIVERGE` count reflects functions where we have correct logic but can't achieve byte parity (usually due to guard/unguard), plus functions with genuinely incomplete or stub implementations. We're steadily chipping away at both categories.

The most complex remaining functions — `swimMove`, `walkMove`, `flyReachable`, physics reachability checks — are hundreds of lines of raw math and collision detection. Those will take dedicated sessions to reconstruct properly. But the smaller helper functions and exec handlers are being verified and improved incrementally.
