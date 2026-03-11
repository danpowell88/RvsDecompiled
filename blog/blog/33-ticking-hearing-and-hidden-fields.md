---
slug: ticking-hearing-and-hidden-fields
title: "Ticking, Hearing, and Hidden Fields"
authors: [dan]
tags: [physics, ai, engine, networking]
date: 2025-07-12
---

Four batches of work land in one post this time. We've been steadily chipping through the actor lifecycle — implementing how objects update every frame, how AI characters hear footsteps and gunshots, and how player controllers manage their state. Along the way we also had to play detective with memory layouts when the original SDK left out the juicy bits.

Let's dig in.

<!-- truncate -->

## Ticking: The Heartbeat of Everything

If you've ever wondered how a game "knows" to update every frame, the answer in Unreal is `Tick`.

Every `AActor` gets a call to `Tick(DeltaTime, TickType)` each frame. `DeltaTime` is how many seconds have elapsed since the last frame — on a machine running at 60fps this is about 0.016 seconds, at 30fps it's 0.033. The idea of multiplying everything by `DeltaTime` (rather than advancing by a fixed amount per frame) is what makes physics and animation look smooth regardless of frame rate. It's called *delta-time scaling* and is one of those fundamentals you see in every game engine ever made.

The Ravenshield `Tick` implementation looks like this after reconstruction:

```cpp
INT AActor::Tick( FLOAT DeltaTime, ELevelTick TickType ) {
    if( StateFrame && StateFrame->LatentAction )
        ProcessState( DeltaTime );   // UnrealScript awaiting a latent call

    if( !TickThisFrame( DeltaTime ) ) 
        return 0;                    // skip net-irrelevant actors

    if( TickType != LEVELTICK_ViewportsOnly )
        TickAuthoritative( DeltaTime );   // physics + timers

    TickSimulated( DeltaTime );   // client-side prediction
    TickSpecial( DeltaTime );     // per-class bonus logic
    return 1;
}
```

There are three distinct tick paths:
- **TickAuthoritative**: runs on the server (or in single-player). It advances timers and runs the physics simulation. This is the "real" update.
- **TickSimulated**: runs on clients for remote actors. It applies networked approximations — things like interpolated movement.
- **TickSpecial**: a virtual override point where specific classes (like `APawn`) do extra work unique to them.

The `LatentAction` check at the top is interesting. In UnrealScript, you can write things like `Sleep(2.0)` — which pauses the script for two seconds. The way this works under the hood is that the script VM sets a "latent action" flag and the `ProcessState` call advances the running state machine each tick until the latent action completes. It's basically cooperative multitasking baked into the scripting layer.

## Falling Through Space (With Control)

Back in batch 85 we dealt with `physFalling` — the physics mode that runs while a pawn is in the air. Free-fall in Unreal isn't just a straight vertical drop; it also handles *air control*, which is the slight lateral movement you can make while jumping. Rainbow Six doesn't have Mario-level air control, but the system still exists.

The implementation runs as a sub-step loop: each frame is divided into chunks no larger than 50ms, and for each chunk:

1. Gravity is applied to the vertical velocity (downward acceleration).
2. A small AirControl-scaled nudge is applied to the horizontal velocity based on player input.
3. `MoveActor` is called to actually move the pawn.
4. If the collision normal indicates the pawn has hit the floor (Z component ≥ 0.7), `processLanded` is called.
5. If the pawn hits a wall, `processHitWall` is called.

The sub-stepping is crucial for stability. A single large physics step with high velocity can "tunnel" through geometry — the object moves so far in one tick that it passes through a wall entirely. By capping step size at 50ms and running multiple steps, the simulation stays physically reasonable.

## What Zone Are You In?

`AActor::SetZone` sounds mundane but it's what keeps the game world coherent. Every volume in a Ravenshield level — rooms, water zones, damage zones — is a "zone". When an actor moves into or out of a zone, `SetZone` fires events:

```
ActorLeaving  →  ZoneChange  →  ActorEntered
```

These events let scripts react: a fire zone might deal damage when `ActorEntered` fires, a trigger zone might open a door. The zone also carries physics properties — zones have their own gravity and "zone velocity" (useful for water currents or wind). When SetZone runs, we stash the new `PhysicsVolume` on the actor and fire the appropriate events on both the old and new zone.

Finding the `UModel` that contains the zone BSP data required some raw pointer archaeology. Our `EngineClasses.h` doesn't formally declare `ULevel::Model`, but Ghidra showed the field clearly at `XLevel + 0x90`. Rather than add a fake declaration, we cast it raw:

```cpp
UModel* Model = *(UModel**)((BYTE*)XLevel + 0x90);
FPointRegion Region = Model->PointRegion(GetLevel(), Location);
```

This pattern — using raw pointer offsets where the SDK header is incomplete — crops up a lot in Ravenshield reconstruction.

## "Did You Hear That?"

The AI hearing system in Unreal Engine 2 is built around `MakeNoise` and `CheckNoiseHearing`. Here's how it works:

1. When something makes a sound (footstep, gunshot, explosion), it calls `MakeNoise(Loudness)` on the actor that made the noise.
2. `MakeNoise` records the noise on the responsible `APawn`: timestamp, loudness, and type. This acts like a breadcrumb — AI can check "when did this pawn last make noise and how loud was it?"
3. Then `CheckNoiseHearing` broadcasts the noise to all active controllers in the level.
4. Each controller calls `CanHear` — a virtual method that implements hearing logic (decay by distance, line-of-sight, hearing range, etc.). The default implementation returns false; AI subclasses override it.
5. If a controller can hear, `eventHearNoise` is called on it, which fires the UnrealScript `HearNoise` event and wakes up the AI hearing state machine.

```cpp
void AActor::CheckNoiseHearing( FLOAT Loudness, ENoiseType NoiseType, ... ) {
    for( AController* C = Level->ControllerList; C; C = C->nextController ) {
        if( C->bDeleteMe ) continue;
        if( C->CanHear( Location, Loudness, this, NoiseType, PawnType ) )
            C->eventHearNoise( Loudness, this, (BYTE)NoiseType, (BYTE)PawnType );
    }
}
```

One quirk we hit: we initially assumed `eventHearNoise` lived on `APawn`, but the export symbols told a different story — it's on `AController`. This makes sense architecturally: controllers are the decision-makers; pawns are just the physical body. The AI *controller* hears the noise and decides what to do; the pawn just follows instructions.

## The Mystery of _NativeData

Here's a fun one. `APlayerController` has a block of native data that isn't formally declared in any SDK header:

```cpp
INT _NativeData[193];  // 772 bytes of undeclared fields
```

The retail binary clearly uses fields in this region — Ghidra shows the constructor zeroing out FVectors, FRotators, and FStrings across this range. We know from `SetPlayer` (which we can disassemble) that offset `0x5B4` (`_NativeData[50]`) holds the `UPlayer*` — the viewport/connection that "owns" this controller.

From `GetViewTarget`, we could infer that `_NativeData[51]` (`0x5B8`) holds the current `ViewTarget` — the actor the camera looks at.

Armed with this knowledge, three stubs became real implementations:

**execConsoleCommand** — The UnrealScript `ConsoleCommand` function routes through to the native player viewport, which has its own `Exec` handler for console input. We access the viewport directly:

```cpp
UPlayer* P = *(UPlayer**)(&_NativeData[50]);
if( P ) P->Exec( *Command, *GLog );
```

**execSetViewTarget** — Trivially stores the new view target in the known slot:

```cpp
*(AActor**)(&_NativeData[51]) = NewViewTarget;
```

**GetPlayerNetworkAddress** — The network address of the connected player is retrieved from the `UNetConnection` (which is a `UPlayer` subclass). This required us to add `LowLevelGetRemoteAddress()` as a pure virtual method on `UNetConnection` — something the SDK reference implied but didn't declare outright.

## Network Protocol Versions

A minor but satisfying fix: in `UChannel::Init`, channels get their negotiated protocol version from the connection. This `NegotiatedVer` field tells both sides which protocol version they've agreed to use for this connection — useful when newer clients talk to older servers (or vice versa).

The actual field in `UNetConnection` is buried in our `_ConnPad` opaque block (offsets not yet decoded from Ghidra), so for now we default to `0`. This is safe — protocol version 0 is always the minimum supported version. Once we do a proper decode of the connection layout this can be wired up properly.

## What's Left?

The remaining TODOs in the engine source fall into a few buckets:

**Mesh/animation**: Everything related to skeletal mesh manipulation (`PlayAnim`, `TweenAnim`, `GetBoneCoords`, etc.) is blocked on a full `UMeshInstance` API that doesn't exist in our headers yet. This is the biggest remaining chunk.

**Audio**: The `PlaySound` and related exec functions need the audio subsystem, which is a member of `UEngine` that we haven't decoded yet.

**Rendering**: A few canvas drawing functions use `FLineBatcher` (a batched line rendering system) that needs the render subsystem to be up.

The good news is that none of these are crash-critical for getting the game to boot and run. The mesh and audio stubs return harmless defaults, actors just won't animate or make noise until those are wired up.

The engine is ticking. Quite literally.
