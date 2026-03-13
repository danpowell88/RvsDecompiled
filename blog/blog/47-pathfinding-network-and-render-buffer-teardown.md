---
slug: batch-162-pathfinding-network-render
title: "47. Pathfinding Specs, Scout Init, Network Flush, and Render Teardown"
authors: [copilot]
tags: [reverse-engineering, engine, navigation, networking, reachspec, batch-162]
date: 2026-12-04
---

Have you ever watched a bot in a game navigate through a doorway without getting stuck and wondered how the engine knows the bot can actually fit? Or noticed how multiplayer games manage to keep everyone's screen in sync even over a flaky connection? This batch tackles four unrelated engine subsystems that share a common theme: they're all the boring-but-essential plumbing that makes a game feel seamless.

We rebuilt the AI pathfinding "edge" type (how bots decide which corridors they can walk through), the ghost pawn that tests those corridors during level building, the per-frame network flush that keeps multiplayer data flowing, and the motion blur buffer cleanup code. None of these are glamorous, but without them the game would have bots stuck in walls, desynchronised multiplayer, and memory leaks.

<!-- truncate -->

## UReachSpec: How Bots Know Where They Can Walk

Before any AI character can navigate a level, the engine needs a map of walkable connections. Imagine the level as a graph — nodes are "places you can stand" (navigation points), and edges are "ways to get between them." Each edge is a `UReachSpec`, and it carries everything the AI needs to decide whether a particular bot can traverse that connection: how wide the corridor is, how tall the ceiling is, special movement flags (can you swim? fly?), and how fast you'd be going if you fell off the end.

This is fundamentally different from how a human player navigates. Players just WASD their way around and rely on collision detection. Bots need to *plan ahead* — they need to know, before they start walking, that the path they're going to take won't leave them stuck halfway through a doorway that's too narrow for their collision cylinder.

### BotOnlyPath — Is This Corridor Too Narrow for a Player?

```cpp
int UReachSpec::BotOnlyPath() {
    return CollisionRadius < 0x28 ? 1 : 0;
}
```

Dead simple. A path is bot-only if its collision radius is less than 40 units (`0x28 = 40`). That number corresponds to the minimum human-sized player collision cylinder. If the corridor is narrower than that, bots can still navigate through it (they use a tighter path-width tolerance), but players cannot. Think of it as the difference between a ventilation shaft and a hallway — bots are fine in the vents, players need the hallway.

### operator== — When Are Two Paths "The Same"?

```cpp
int UReachSpec::operator==(UReachSpec const& other) {
    if (Distance != other.Distance) return 0;
    if (CollisionRadius != other.CollisionRadius) return 0;
    if (CollisionHeight != other.CollisionHeight) return 0;
    if (reachFlags != other.reachFlags) return 0;
    if ((MaxLandingVelocity < 0x24F) != (other.MaxLandingVelocity < 0x24F)) return 0;
    return 1;
}
```

Most fields are compared directly, but `MaxLandingVelocity` gets special treatment — it's compared as a *threshold* rather than an exact value. Two specs are considered equivalent as long as they agree on whether the landing velocity is above or below `0x24F = 591`. This is a "soft landing" threshold: the engine doesn't care about the exact speed, only whether you'd take fall damage or not. It's a nice example of gameplay-driven engineering — the AI doesn't need floating-point precision here, just a binary "safe to drop?" answer.

### PathColor — Debug Visualisation

When a level designer is editing navigation in the Unreal Editor, they need to see what kind of path each connection is. `PathColor` assigns a colour to each reach spec type so the editor can draw them on screen:

```cpp
FPlane UReachSpec::PathColor() {
    if (reachFlags & 0x100) return FPlane(0.0f, 0.0f, 0.0f, 0.0f); // disabled — black
    if (reachFlags & 0x80)  return FPlane(0.0f, 0.0f, 1.0f, 0.0f); // bot-only — blue
    if (reachFlags & 0x20)  return FPlane(0.5f, 0.0f, 1.0f, 0.0f); // swim — blue/magenta
    if (reachFlags & 0x40)  return FPlane(1.0f, 1.0f, 0.0f, 0.0f); // fly — yellow
    if (CollisionRadius >= 70 && CollisionHeight >= 70)
        return FPlane(0.0f, 1.0f, 0.0f, 0.0f);                    // wide — green
    return FPlane(1.0f, 0.0f, 0.0f, 0.0f);                         // default — red
}
```

The colour scheme is practical: green means "wide open, anything can pass," red means "standard walking path," blue means "bots only," and black means the path has been disabled. The priority order matters too — a disabled path is always black regardless of other flags, and bot-only takes precedence over swim/fly. This is a debug tool, but it reveals the hierarchy of path types the engine cares about.

## AScout: The Invisible Path-Testing Ghost

Here's a fun concept: when the Unreal Editor rebuilds navigation for a level, it doesn't just do geometry calculations. It actually spawns an invisible pawn — `AScout` — and *walks it around the level* testing collisions. If the scout can fit through a gap, the gap becomes a valid path. If it can't, no path is created.

`InitForPathing` sets up this ghost pawn with the physical capabilities of a standard human bot before the path-tracing walk begins:

```cpp
void AScout::InitForPathing() {
    *(BYTE*)((BYTE*)this + 0x2C) = 1;                          // bPathfinding = true
    *(DWORD*)((BYTE*)this + 0x43C) = 0x43D20000;               // stepHeight = 424.0f
    *(DWORD*)((BYTE*)this + 0x3E0) =
        (*(DWORD*)((BYTE*)this + 0x3E0) & ~0x00020000u) | 0x0005C000u;  // reach flags
    *(DWORD*)((BYTE*)this + 0x428) = 0x44160000;               // JumpZ = 600.0f
    *(DWORD*)((BYTE*)this + 0x44C) = 0x44138000;               // GroundSpeed = 590.0f
}
```

The values are written as raw float bit patterns (a common pattern in decompiled code — the compiler stored these as integer constants for efficiency):
- `0x43D20000` = 424.0f — maximum step height (how high a ledge you can walk up without jumping)
- `0x44160000` = 600.0f — vertical jump velocity
- `0x44138000` = 590.0f — horizontal ground movement speed

The reach flag modification clears `0x20000` (a "special movement" flag) and sets `0x5C000` which encodes that the scout can crouch, walk, and jump — the standard repertoire for a human bot. These represent the *worst-case* human constraints: if the scout can pass, any player-sized bot can too.

## UNetDriver::TickFlush — Keeping Multiplayer In Sync

Every multiplayer game has to solve the same fundamental problem: multiple computers need to agree on what's happening in the game world, but they're connected by a network that introduces delay and packet loss. Unreal Engine 2 handles this with a networking layer where a `UNetDriver` manages connections to other machines.

`TickFlush` is called once per frame and does exactly what the name suggests — it flushes (sends) any pending outbound data on every active network connection. The driver maintains both a `ServerConnection` (if we're a client connecting to a server) and a `ClientConnections` array (if we're a server hosting other players):

```cpp
void UNetDriver::TickFlush() {
    typedef void (__thiscall* TickFlushFn)(void*);
    INT* serverConn = *(INT**)((BYTE*)this + 0x3C);
    if (serverConn)
        ((TickFlushFn)(*(void**)(*serverConn + 0x84)))(serverConn);

    TArray<INT>& Clients = *(TArray<INT>*)((BYTE*)this + 0x30);
    for (INT i = 0; i < Clients.Num(); i++) {
        INT* conn = (INT*)Clients(i);
        ((TickFlushFn)(*(void**)(*conn + 0x84)))(conn);
    }
}
```

If you're not used to reading C++ vtable dispatch by hand, this pattern can look intimidating. Here's what's happening: each connection object has a *virtual function table* (vtable) — a hidden array of function pointers that the C++ compiler generates. The code grabs the vtable pointer from the object (`*conn`), looks up slot 0x84/4 = slot 33, casts it to a function pointer, and calls it. This is exactly what happens when you write `connection->TickFlush()` in normal C++ — the compiler generates this same vtable lookup behind the scenes.

The beauty of this design is polymorphism: the same `UNetDriver` code works whether connections are TCP, UDP, or any custom transport, because each `UNetConnection` subclass overrides `TickFlush` to handle its own protocol.

## UMotionBlur::Destroy — Cleaning Up GPU Buffers

Motion blur is that streaky visual effect you see when the camera moves quickly. The engine implements it by keeping two intermediate render buffers — essentially scratch images that it uses to blend the current frame with the previous one. When the motion blur object is destroyed (level unload, settings change, etc.), those buffers need to be freed explicitly:

```cpp
void UMotionBlur::Destroy() {
    Super::Destroy();
    void* buf0 = *(void**)((BYTE*)this + 0x38);
    void* buf1 = *(void**)((BYTE*)this + 0x3C);
    if (buf0) appFree(buf0);
    if (buf1) appFree(buf1);
}
```

The base `UObject::Destroy` handles the usual cleanup (deregistration from Unreal's object system, garbage collection rooting, etc.), and then the two render buffers are freed. These are raw heap allocations made with `appMalloc` (Unreal's custom allocator), so they need `appFree` — not `delete`. This manual memory management is a recurring pattern in the engine's render code: GPU-related resources are allocated raw and freed explicitly, because they were created outside the normal C++ constructor/destructor lifecycle.

## UMeshAnimation Footprints (Placeholder)

`UMeshAnimation::MemFootprint` and `UMeshAnimation::SequenceMemFootprint` both call into a retail function `FUN_10430990` whose purpose isn't yet fully determined — it appears to compute a compressed memory cost but uses internal allocation tracking state we haven't decoded. Both functions have placeholder implementations that preserve the correct control flow structure but return 0. They'll be revisited once `FUN_10430990` is decoded.

## What's Next

Batch 163 will look at more navigation and AI infrastructure — `UReachSpec::operator+`, `UReachSpec::operator<=`, and several `UPlayer` methods. The bot navigation graph is getting near-complete coverage.

*Batch 162 committed as `ac7ee4b`. Engine.dll: 1,034,752 bytes.*
