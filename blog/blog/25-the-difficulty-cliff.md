---
slug: the-difficulty-cliff
title: "25. The Difficulty Cliff — When the Easy Stubs Run Out"
date: 2025-01-25
authors: [rvs-team]
tags: [decompilation, r6engine, ghidra, reverse-engineering, ai-navigation, latent-actions, unreal-engine]
---

After 30 batches and 150+ function implementations, we've hit a transition point. The easy wins are gone, and the remaining functions are either huge, blocked by unknown helpers, or require reverse-engineering entire subsystems. But before we stare into the abyss, let's celebrate two solid implementations that required some real detective work.

<!-- truncate -->

## Doors That Know Their Partners

Navigation in Unreal Engine 2 is built on a graph of **navigation points** connected by **reach specs**. A reach spec says "from point A, you can walk to point B, and here's how big you need to be to fit." The engine's AI pathfinding walks this graph to find routes.

Doors are tricky. A door has two sides — an entry point and an exit point — and the AI needs to know it can walk *through* the door, not just *to* it. In the retail binary, `AR6Door::addReachSpecs` does something elegant: it creates a custom reach spec connecting the door to its "corresponding door" (the point on the other side), then lets the base class handle everything else.

```cpp
void AR6Door::addReachSpecs(AScout* Other, UBOOL bOnlyChanged)
{
    guard(AR6Door::addReachSpecs);
    if (correspondingDoor)
    {
        UReachSpec* spec = new(GetLevel(), NAME_None) UReachSpec;
        spec->Init();
        spec->CollisionRadius = 40;
        spec->CollisionHeight = 85;
        spec->Start     = this;
        spec->End        = correspondingDoor;
        spec->reachFlags = 17;
        spec->Distance   = (INT)(correspondingDoor->Location - Location).Size();
        GetLevel()->ReachSpecs.AddItem(*spec);
    }
    ANavigationPoint::addReachSpecs(Other, bOnlyChanged);
    unguard;
}
```

The magic numbers tell a story: a collision cylinder of 40×85 units (roughly human-sized for Rainbow Six), and `reachFlags = 17` which combines `R_WALK` (1) with `R_DOOR` (16). The distance is calculated as the straight-line distance between the two door points. Simple, clean, and it slots right into the navigation graph.

## Following the Path — Latent Actions in Unreal Engine 2

The more interesting implementation is `AR6AIController::FollowPath`. If `addReachSpecs` is about *building* the navigation graph, `FollowPath` is about *using* it. And it introduces one of Unreal Engine 2's most fascinating low-level concepts: **latent actions**.

### What's a Latent Action?

In UnrealScript, some functions can "pause" execution. When a script calls `MoveToward()` or `FinishAnim()`, the script doesn't actually block a thread. Instead, the engine sets a **latent action ID** in the actor's state frame, and the script interpreter stops executing that actor's code. Each tick, the engine checks whether the latent condition is satisfied. When it is, the latent action ID is cleared and the script resumes.

From C++, this mechanism lives in a structure called `FStateFrame`. Every UObject has one (accessed via `GetStateFrame()`), and the key field is `LatentAction` — an integer that tells the engine which poll function to call each tick.

### Decoding FollowPath

Here's what the Ghidra decompilation revealed, translated back into C++:

```cpp
void AR6AIController::FollowPath(FName NextLabelParam)
{
    // Store the next state label for when we arrive
    NextLabel = NextLabelParam;

    // Search backwards through RouteCache for our pawn's current anchor
    for (INT i = m_iCurrentRouteCache; i >= 0; i--)
    {
        if (RouteCache[i] == Pawn->Anchor)
        {
            m_iCurrentRouteCache = i;
            break;
        }
    }

    // Anchor not found in cache? Rebuild the path
    if (m_iCurrentRouteCache < 0 || RouteCache[m_iCurrentRouteCache] != Pawn->Anchor)
    {
        FindPath(FVector(0,0,0), RouteGoal, 1);
        m_iCurrentRouteCache = 0;
    }

    // Reset movement speed
    Pawn->bReducedSpeed = 0;
    Pawn->DesiredSpeed  = Pawn->MaxDesiredSpeed;

    // ACTIVATE THE LATENT ACTION
    GetStateFrame()->LatentAction = 602;

    // Adjust for injured pawns
    if (Pawn->m_eHealth == 1)
    {
        GetStateFrame()->LatentAction = 602;
        Pawn->DesiredSpeed = Pawn->MaxDesiredSpeed * 0.5f;
    }

    // Set up Rainbow Six movement and start moving
    eventR6SetMovement(Pawn->DesiredSpeed, 1);
    Pawn->moveToward(MoveTarget, NULL, Pawn->DesiredSpeed, FALSE);
}
```

The latent action ID **602** corresponds to `execPollFollowPath` somewhere in the engine — a function that checks each tick whether the AI has reached its target. When it has, the latent action clears and the AI's state code resumes at whatever `NextLabel` points to.

### The Route Cache

The `RouteCache` is an array of 16 `ANavigationPoint*` pointers stored in `AController`. It represents the AI's planned path through the navigation graph. When `FollowPath` starts, it looks for where the pawn currently *is* in that cache (its `Anchor` — the nearest navigation point). If the anchor isn't found, the whole path is rebuilt from scratch.

The field `m_iCurrentRouteCache` tracks which cache index the AI is currently at. By searching *backwards* from the current index, the code handles cases where the pawn might have been pushed back along its route (by physics, being bumped, etc.).

### The Injured Slowdown

One neat detail: if `m_eHealth == 1` (which maps to an injured state in Rainbow Six's health enum), the AI cuts its desired speed in half. This is why injured terrorists in the game visibly limp along at a slower pace — it's not animation trickery, it's the actual movement speed being halved at the AI controller level.

## The Difficulty Cliff

With these two implementations committed, we ran an exhaustive search of our remaining stubs. The results were sobering:

| Category | Count | Status |
|----------|-------|--------|
| Very complex (500+ bytes) | ~20 | Crawl, UnCrawl, UpdateAiming, CanHear... |
| Blocked by unknown helpers | ~10 | Need FUN_1001bc10 family identified |
| Blocked by unknown layouts | ~5 | Need AR6ColBox fields mapped |
| Editor-only functions | ~8 | AddMyMarker, CheckForErrors, RenderEditorInfo |
| Already correct | ~7 | Verified as empty/trivial in Ghidra |

The remaining functions aren't just longer — they're *qualitatively different*. A function like `Crawl` (1,839 bytes in the retail binary) manipulates collision boxes, adjusts bone positions, modifies animation states, and handles edge cases for when you can't actually fit into the crawl position. It requires understanding not just one class, but an entire subsystem of collision boxes, animation blending, and physics.

Similarly, `UpdateAiming` (1,272 bytes) involves bone rotation calculations, weapon spread ballistics, and interpolation maths that would take careful analysis to get right.

### The Unknown Helper Problem

Several functions reference internal helpers that Ghidra only knows by address: `FUN_1001bc10`, `FUN_1001bc40`, and `FUN_1001bc70`. These appear in functions like `IsRelevantToPawnHeartBeat` — the heartbeat sensor gameplay mechanic. Until we identify what these helpers do (likely some kind of trace or visibility check), those functions are blocked.

### What's Next?

The path forward has three prongs:

1. **Identify the unknown helpers.** If we can crack `FUN_1001bc10`, it might unblock 10+ functions at once.
2. **Map AR6ColBox fields.** The collision box subsystem blocks `initCrawlMode`, `ResetColBox`, and indirectly `Crawl`/`UnCrawl`.
3. **Tackle the monsters one at a time.** The 500+ byte functions won't implement themselves, but each one is a self-contained puzzle.

We've gone from implementing 10 functions per batch to 2, but those 2 required deeper understanding of the engine than the previous 10 combined. That's the nature of decompilation — the last 20% of the work takes 80% of the effort.

The skeleton is built. Now we're adding the muscle.
