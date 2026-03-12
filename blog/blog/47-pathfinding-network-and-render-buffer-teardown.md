---
slug: batch-162-pathfinding-network-render
title: "Batch 162: Pathfinding Specs, Scout Init, Network Flush, and Render Teardown"
authors: [danpo]
tags: [reverse-engineering, engine, navigation, networking, reachspec, batch-162]
date: 2026-12-04
---

Batch 162 brings together four distinct engine subsystems: navigation reach specs, bot scout initialisation, network connection flushing, and render buffer teardown. None of these were the biggest functions in the codebase, but each reveals a different low-level pattern in how the Rainbow Six 3 engine is structured.

<!-- truncate -->

## UReachSpec: The Navigation Edge Type

`UReachSpec` represents a directed edge in the AI navigation graph. Each node (a `ANavigationPoint`) has a list of outbound reach specs describing how a bot can traverse from one point to another — and each spec carries exactly the constraints for that traversal: distance, collision radius, collision height, reach flags, and maximum landing velocity.

### BotOnlyPath

```cpp
int UReachSpec::BotOnlyPath() {
    return CollisionRadius < 0x28 ? 1 : 0;
}
```

Dead simple. A path is bot-only if its collision radius is less than 40 units. The retail constant `0x28 = 40`, which corresponds to the minimum human-sized player collision cylinder. If the corridor is narrower than that, bots can still navigate through it (they use a different path-width tolerance), but players cannot.

### operator==

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

The equality operator compares four fields directly, but `MaxLandingVelocity` is interestingly compared as a *threshold* — two specs are considered equivalent so long as they agree on whether the velocity is above or below `0x24F = 591`. This is a "soft landing" threshold: it doesn't matter exactly how fast you can land, only whether you can soft-land at all.

### PathColor

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

This is a debug/editor visualisation function. Each reach-flag type gets its own colour in the path network editor view. The green case is a size check — wide, tall passages are shown green because they're easily navigable by anything. Red means a standard walking path.

The flag assignments are:
- `0x80` — restricted to bots (blue, same hue as bot-only for humans)
- `0x20` — swim paths
- `0x40` — fly paths (used for birds, jets in mods)
- `0x100` — pruned/disabled reach spec (black = invisible)

## AScout::InitForPathing

`AScout` is the engine's pathfinding helper actor — a ghost pawn spawned when the editor rebuilds the navigation graph. It walks the level testing collisions to determine valid reach specs. `InitForPathing` sets it up with the bot's physical constants before the path-tracing begins.

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

The values are written as raw float bit patterns:
- `0x43D20000` = 424.0f — maximum step height in unreal units
- `0x44160000` = 600.0f — vertical jump velocity
- `0x44138000` = 590.0f — horizontal ground movement speed

The reach flag modification clears `0x20000` (a "special movement" flag) and sets `0x5C000` which encodes that the scout can crouch, walk, and jump — the standard repertoire for a human bot. These values represent the *worst-case* human constraints: if the scout can pass, any player-class bot can too.

## UNetDriver::TickFlush

`TickFlush` is called once per frame to push any pending outbound data on all active network connections. The driver maintains both a `ServerConnection` (if we're a client) and a `ClientConnections` array (if we're a server).

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

Both the server connection and each client connection store their `TickFlush` implementation through a vtable pointer at offset `0x84`. This is polymorphic dispatch — the same `UNetDriver` code works whether connections are TCP, UDP, or any other transport, because each `UNetConnection` subclass overrides `TickFlush` to handle its own flush logic.

The pattern is: grab vtable from the object, fetch slot 0x84/4 (slot 33), cast to the right `__thiscall` function pointer, and dispatch. This is how the Unreal Engine 2 runtime does virtual dispatch on objects whose C++ class hierarchy isn't fully restored yet.

## UMotionBlur::Destroy

`UMotionBlur` is the motion blur render effect and holds two intermediate render buffers. On destruction they need to be freed explicitly.

```cpp
void UMotionBlur::Destroy() {
    Super::Destroy();
    void* buf0 = *(void**)((BYTE*)this + 0x38);
    void* buf1 = *(void**)((BYTE*)this + 0x3C);
    if (buf0) appFree(buf0);
    if (buf1) appFree(buf1);
}
```

The base `UObject::Destroy` handles the usual cleanup (deregistration from the object system, GC rooting etc.), and then the two render buffers are freed. The buffers are raw heap allocations made with `appMalloc`, so they need `appFree` — not `delete`. This is consistent with all other render buffer cleanup in the engine.

## UMeshAnimation Footprints (Placeholder)

`UMeshAnimation::MemFootprint` and `UMeshAnimation::SequenceMemFootprint` both call into a retail function `FUN_10430990` whose purpose isn't yet fully determined — it appears to compute a compressed memory cost but uses internal allocation tracking state we haven't decoded. Both functions have placeholder implementations that preserve the correct control flow structure but return 0. They'll be revisited once `FUN_10430990` is decoded.

## What's Next

Batch 163 will look at more navigation and AI infrastructure — `UReachSpec::operator+`, `UReachSpec::operator<=`, and several `UPlayer` methods. The bot navigation graph is getting near-complete coverage.

*Batch 162 committed as `ac7ee4b`. Engine.dll: 1,034,752 bytes.*
