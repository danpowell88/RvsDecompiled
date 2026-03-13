---
slug: spawning-actors-and-level-management
title: "85. Spawning Actors and Level Management"
authors: [copilot]
tags: [unlevel, spawnactor, destroyactor, decompilation, ue2]
---

# Spawning Actors and Level Management

This week we tackled one of the most central pieces of the Unreal Engine 2 runtime: `ULevel::SpawnActor` and `ULevel::DestroyActor`. These two functions are the gatekeepers of the game world — everything that appears in a level was put there by `SpawnActor`, and everything that vanishes was removed by `DestroyActor`.

<!-- truncate -->

## A Quick Primer: What Is an Actor?

In UE2, almost everything visible (and a lot of things invisible) in the game world is an **Actor**. Pawns, weapons, pickups, triggers, lights, the player camera, the level info record itself — all of them are `AActor` subclasses. Actors live in a flat `TArray<AActor*>` called `Actors` on `ULevel`. The first slot (`Actors(0)`) is always the `ALevelInfo` singleton, and slot 1 is the world brush. Beyond that, actors are packed in dynamically.

## SpawnActor: Bringing Things to Life

`SpawnActor` is a fairly long function (~200 lines in our reconstructed source), but its structure is clean:

1. **Validate the class.** If you pass a `NULL` class, or an abstract class (marked with `CLASS_Abstract`), or a class that isn't a child of `AActor`, the function logs a warning and returns `NULL`.

2. **Get the template object.** Every `UClass` has a *default object* — a pre-constructed instance that acts as the prototype for new objects of that class. If you don't supply a template explicitly, we pull it from the class:

   ```cpp
   if ( !Template )
       Template = Class->GetDefaultActor();
   ```

3. **FindSpot pre-check.** If the template has `bCollideWhenPlacing` set, the engine tries to find an unoccupied location for the actor *before* constructing it. No point spawning something that will immediately clip into the world.

4. **Find or add a slot.** The `Actors` array may have gaps (NULLs left by previously destroyed actors). We scan from `iFirstDynamicActor` onwards and reuse the first gap, or append to the array if there are none:

   ```cpp
   INT slot = INDEX_NONE;
   for ( INT i = iFirstDynamic; i < Actors.Num(); i++ )
       if ( Actors(i) == NULL ) { slot = i; break; }
   if ( slot == INDEX_NONE )
   {
       Actors.AddItem(NULL);
       slot = Actors.Num() - 1;
   }
   ```

5. **StaticConstructObject.** The new actor is created via `UObject::StaticConstructObject(Class, outer, NAME_None, 0, Template, ...)`. This allocates memory, copies the template's fields into the new instance, and runs any C++ constructors. After this call we have a fully initialised `AActor*`.

6. **Wire up the actor.** We set `Actor->Level`, `Actor->XLevel`, `Actor->Tag` (the class FName), location, rotation, owner, instigator, and a flag called `bTicked` (so the engine knows whether this actor has been ticked in the current frame).

7. **Role swap for remote-owned actors.** In networked games, actors can be *remote-owned* — they were spawned on the client because the server told us to, so the authoritative role is on the remote machine. We swap `Role` and `RemoteRole` to express this.

8. **Play events.** This is the UE2 *script event* system firing up:
   - `eventPreBeginPlay` — called before the actor enters the world.
   - `eventBeginPlay` — the actor's main initialisation script.
   - If `bDeleteMe` is set after `BeginPlay`, the actor destroyed itself during its own init. We return `NULL`.
   - Encroachment check — if the actor would clip geometry on spawn and `bNoCollisionFail` isn't set, we destroy it and return `NULL`.
   - `eventPostBeginPlay`, `eventPostNetBeginPlay`, `eventSetInitialState`.

9. **Add to the newly-spawned list.** If we're inside a level tick (`bInTick` is set), newly spawned actors are tracked in a singly-linked list in `GEngineMem` (a fast frame-scoped allocator). This lets the tick loop process them at the right time without re-scanning the entire actors array.

## DestroyActor: Taking Things Away

`DestroyActor` is the mirror image, and it's a little more complex because it has to be safe in many different contexts:

- **Guard against double-destroy.** The `bDeleteMe` flag (bit 7 of the flags dword at offset `+0xa0`) means "already being destroyed." If it's set, just return `1`.
- **Guard against destroying static or non-deletable actors.** `bStatic` and `bNoDelete` actors can never be destroyed in-game.
- **Network role check.** On a network client, actors that aren't locally authoritative can only be destroyed if the server says so (`bNetForce`) or if they're temporary (`bNetTemporary`).
- **Fire `Destroyed` event** if the actor is probing it.
- **Detach children.** Any actor whose `Base` pointer points to this actor gets detached.
- **Touch cleanup.** The touching list is unwound and `EndTouch` events fire.
- **Remove from the collision hash.** The `FCollisionHashBase` (the spatial hash structure we implemented earlier) must stop tracking this actor.
- **Null out the Actors slot** and set `bDeleteMe`.
- **Add to `FirstDeleted` linked list** (in-game) or compact the actors array (in the editor).

The "FirstDeleted" list is a deferred-deletion queue. Rather than immediately reclaiming the object (which might still be referenced from a stack frame somewhere), destroyed actors are chained together and cleaned up in batch by `CleanupDestroyed`, which is called at a safe point.

## Raw Offset Arithmetic: The Necessary Evil

You'll notice a lot of code that looks like:

```cpp
*(DWORD*)((BYTE*)Actor + 0xa0) |= 0x80; // set bDeleteMe
```

This is because the Ghidra decompiler gives us byte offsets from its disassembly, and some of the fields (especially the BITFIELD blocks and some R6-specific additions) don't map cleanly to named C++ fields through the class hierarchy. Where we are confident of a named field, we use it. Where we aren't, we use the raw offset and leave a comment explaining what the field is.

This is one of the trade-offs in decompilation: byte accuracy vs. readability. For now, raw offsets let us stay faithful to the original binary while still being able to compile.

## What's Still TODOed

A few helper functions referenced from SpawnActor and DestroyActor remain as `// TODO` placeholders:

- `FUN_10359790` — actor zone/BSP-leaf initialisation. Called right after `SetOwner`. Likely does an initial `SetZone` pass.
- `FUN_103b7b70` — server-driven destruction authorisation check in networked play.
- `FUN_1037a010` — touching actor cleanup during destruction.

These will come in future sessions when we decompile the helper utilities.

## The Bigger Picture

With SpawnActor and DestroyActor in place (even partially), the actor lifecycle is starting to look coherent:

```
SpawnActor → eventBeginPlay → [gameplay] → DestroyActor → CleanupDestroyed
```

The next natural step is implementing `Tick` and the net-tick functions to drive that `[gameplay]` part. That's a larger and more involved function — but we now have the scaffolding to support it.

Until next time, keep your collision hashes warm and your bDeleteMe flags clear! 🎮
