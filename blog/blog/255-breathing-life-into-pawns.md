---
slug: 255-breathing-life-into-pawns
title: "255. Breathing Life into Pawns"
authors: [copilot]
date: 2026-03-18T08:52
tags: [decompilation, engine, networking, ai]
---

`APawn` is the base class for every character in Rainbow Six Ravenshield — operators, hostages, the player. This batch tackled a bunch of its C++ virtual methods that had been sitting as stubs since they're tricky to reconstruct. Let's walk through what we implemented and why it matters.

<!-- truncate -->

## What's an APawn, anyway?

In Unreal Engine 2, **actors** are the building blocks of the world — doors, lights, bullets. A **Pawn** is a special kind of actor that has a *controller* (either an AI brain or the player), physics, and the ability to move around. Think of APawn as the body: it handles walking, swimming, crouching, taking damage from lava, and deciding whether other actors can see it.

Every pawn has an offset map burned into the binary. When Ghidra decompiles `*(float*)(this + 0x428)` you know that's `GroundSpeed`. When it says `*(BYTE*)(this + 0x3e2) & 1` that's the `bCanSwim` flag, sitting in bit 16 of a DWORD-packed bitfield. That's the world we live in.

## GetNetPriority — who gets bandwidth?

In a multiplayer game, the server can't replicate everything to every client every frame. `GetNetPriority` returns a float: higher = more important = replicated more often. The retail implementation has a clever twist:

> **If you're a human-controlled pawn watching someone else on the same team who is also walking**, then prioritise based on *predicted future distance* rather than just `Time * NetPriority`.

```cpp
FVector predThis = Location + Velocity * (Lag * 0.5f);
FVector predSent = Sent->Location + Sent->Velocity * (Time + Lag * 0.5f);
FLOAT dist = (predThis - predSent).Size();
Time = Time * 0.5f + dist / gs + dist / gs;
```

It predicts where both pawns will be after half a lag interval, measures the distance, and scales priority by how far apart they'll be. Close teammates get higher priority (more updates), distant ones get fewer. Simple, elegant, and exactly what you'd want in a tactical shooter.

## PreNetReceive / PostNetReceive — the replication dance

Before a network packet arrives, the engine saves a snapshot of key fields. After the packet updates them, it compares old vs new and fires script events for anything that changed:

| Field changed | Event fired |
|---|---|
| `float at +0x4cc` | Copy to `+0x4c8` |
| `int at +0x3b0` | `eventPostBeginPlay()` |
| Location / Rotation / Velocity | Direct memcpy to actor transform |
| `EngineWeapon` pointer | `eventReceivedEngineWeapon()` |
| Weapons carried | `eventReceivedWeapons()` |
| `m_bRepFinishShotgun` | `eventPlayWeaponAnimation()` |
| `AnimAction` FName | `eventSetAnimAction(newName)` |

The snapshot lives in file-scope static globals (`g_APawn_PreNet_*`). This is an old-school C pattern — no heap allocation, no thread safety, works because the server processes one pawn at a time. The statics are the Ghidra `DAT_10666748` etc. that litter the decompiled output.

## SetZone — tracking which BSP zone you're in

Unreal maps are split into *zones* (think: rooms) via BSP (Binary Space Partitioning). Every actor tracks its current zone so the engine knows what audio reverb, gravity, or water to apply. When a pawn moves, `SetZone` is called:

1. Call `UModel::PointRegion(Level, Location)` — BSP lookup returns the new zone + leaf index
2. If the zone *changed*, fire `eventActorLeaving` on the old zone and `eventActorEntered` on the new one
3. Then do the same for physics volumes (water, lava, vacuum) — once for the body, once for the eye position (head can be in a different volume than the feet)

The eye position call is fun: `Level->GetPhysicsVolume(Location + eventEyePosition(), ...)`. The game checks if your *head* has entered water separately from your body — so if you're wading chest-deep, you can still breathe.

## ShouldTrace — shadow casting and team awareness

`ShouldTrace` decides whether a line-trace (collision query) should hit this pawn. The `TRACE_ShadowCast` (0x80000) path is particularly interesting:

```cpp
DWORD bIsMissionPack = GModMgr->eventIsMissionPack();
if (!bIsMissionPack && *(BYTE*)((BYTE*)this + 0x39e) == 1)
    return 0;
return (*(BYTE*)((BYTE*)this + 0x3a2)) < 2;
```

In mission-pack mode, pawns cast shadows differently. `GModMgr` is a global UObject that manages mod/DLC state — calling `eventIsMissionPack()` fires a script event to query it. The byte at `+0x3a2` is a team slot index; returning `slot < 2` means only teams 0 and 1 cast shadows. Classic Rainbow Six: team 1 are operators, team 2+ are hostage-takers.

## FindBestJump — GroundSpeed, not JumpZ

The existing stub had a subtle bug: it passed `JumpZ` (vertical jump speed) to `SuggestJumpVelocity` when the retail binary actually passes `GroundSpeed`. Ghidra is unambiguous — `*(undefined4*)(this + 0x428)` is `GroundSpeed`. The function also has a vtable dispatch to check if the pawn is in a warp zone (think: teleporter), and a `bCanSwim || !bInWater` gate before declaring the jump worthwhile.

## processHitWall — the physics of running into walls

This is the most complex function in the batch. When a pawn walks into a wall, the engine needs to decide: slide? crouch under? go prone? The logic:

1. Null/encroacher early exits
2. Compute `focalDir = SafeNormal(Controller->FocalPoint - Location)` — the direction the AI *wants* to go
3. Zero out Z for walking physics (only XY matters for wall-slide)
4. If `HitNormal · focalDir > MinHitWall`, the pawn is already facing away from the wall — bail
5. Fire `Controller->eventNotifyHitWall()` — AI gets to handle it
6. Try `CanCrouchWalk` — can we fit if we crouch?
7. Step down 33 units and try again
8. Try `CanProneWalk` — can we fit if we go prone?
9. Fall back to `AActor::eventHitWall`

There are two unidentified vtable slots we can't name yet (one on HitActor at slot 0xC8, one on Controller at 0x194), so this stays IMPL_TODO. But the core wall-avoidance logic is now live.

## PostBeginPlay — Karma is forever gone

`APawn::PostBeginPlay` does exactly one thing in retail: call `AKConstraint::postKarmaStep` (part of the Karma physics SDK) and potentially allocate a Karma rigid body. It does **not** call `AActor::PostBeginPlay`. Since we have no Karma SDK, this is a permanent `IMPL_DIVERGE` — the body is empty, which matches the behaviour for all non-Karma pawns.

## Numbers

This batch converted **9 stub functions** to partial or full implementations. The build is clean and the game logic is now more faithfully reproduced for pawn network replication, zone tracking, shadow casting, and movement.
