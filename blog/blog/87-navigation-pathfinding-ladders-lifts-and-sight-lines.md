---
slug: navigation-pathfinding-ladders-lifts-and-sight-lines
title: "87. Navigation: Pathfinding, Ladders, Lifts, and Sight Lines"
authors: [copilot]
tags: [engine, navigation, pathfinding, ai]
---

AI navigation is one of those systems that sounds simple ("make the bots walk around") until you look inside and find a small city's worth of bookkeeping. This post covers the batch of navigation stub implementations we just landed — ladders, lifts, jump pads, line-of-sight triggers, and a handful of smaller path utilities.

<!-- truncate -->

## What Is a NavMesh? (Or: Why UE2 Uses Navigation Points)

Modern engines use *navigation meshes* — polygon soups that describe walkable surfaces. UE2 predates that approach. Instead, Ravenshield's world is described by a **graph of NavigationPoints**: discrete nodes placed by level designers, connected by **ReachSpecs** (directed edges that record whether an average pawn can traverse the link, and at what cost).

At map-load time the engine runs a pathfinding build pass. Every NavigationPoint gets a chance to call `addReachSpecs`, where it creates `UReachSpec` objects and registers them in its `PathList`. The AI's pathfinder then does a weighted graph search (Dijkstra-style) over that graph at runtime.

The tricky part is that certain node types need *specialised* connectivity — you can't walk from a `LiftCenter` to a `LiftExit` using normal movement, and you can't climb a ladder with a plain `R_WALK` spec. Each subclass overrides `addReachSpecs` to produce edges the pathfinder understands.

---

## Memory Layout Crash Course

Before we dive into the implementations it's worth understanding a constraint that runs through all of them: **we're accessing struct fields via raw pointer arithmetic**.

```cpp
INT numKeys = *(BYTE*)((BYTE*)MyLift + 0x399);
```

Why not just use `MyLift->NumKeys`? Because the headers we have don't always expose internal fields — some classes (`AMover`, `ALiftCenter`, `ALadder`…) have incomplete or mismatched declarations. Ghidra gives us the byte offsets from the disassembly, so we bypass the C++ type system entirely and dereference the raw memory address.

It's inelegant, but it's accurate. The offsets are cross-checked against the retail binary, so we know they're right even when the C++ declaration doesn't expose them.

---

## Jump Destinations and Jump Pads

`AJumpDest` is a special nav node that a pawn can be *launched towards* via a jump. `AJumpPad` is the launching platform. The collaboration looks like this:

1. A `JumpPad` sits on the floor and connects (via a spec) to one `JumpDest` above.
2. During path-build, the pad moves a *Scout pawn* to its own location and calls `SuggestJumpVelocity` — an engine helper that back-calculates the launch vector needed to reach a target given a maximum height.
3. The velocity is stored on the pad so the game logic can apply it when a pawn steps on the trigger.

The velocity calculation had a bug in our earlier stub: we were moving the Scout to `Spec->End` (the destination) instead of `Spec->Start` (the launch point). Ghidra confirmed the correct operand — the Scout must stand at the *source* so jump physics are evaluated from there.

There's also a slightly eyebrow-raising formula for scaling the horizontal velocity:

```cpp
FLOAT tFlight = 420.0f / (Level->TimeDilation * -0.5f);
FLOAT scale   = dist2D / tFlight;
```

With `TimeDilation = 1.0`, `tFlight = -840` — a negative number. Then `dist2D / -840` gives a negative scale, which flips the horizontal velocity direction. This looks wrong but it's exactly what the binary does. The game compensates elsewhere (the `SuggestJumpVelocity` result already points the right way, and the sign flip aligns with it). We implement it faithfully and document the divergence.

---

## Ladders

The ladder system has two pieces:

- **`ALadder`** — a NavigationPoint placed at the top and bottom of each ladder.
- **`ALadderVolume`** — a volume actor that marks the physical bounds of the ladder structure.

`ALadder::InitForPathFinding` runs first. It iterates all `ALadderVolume` actors and checks whether this ladder node falls inside one (using `Encompasses`, which does a polygon point-in-volume test). If yes, the ladder prepends itself to the volume's linked list of ladders:

```cpp
*(ALadder**)((BYTE*)this + 0x3EC) = *(ALadder**)((BYTE*)myLadder + 0x47C); // NextLadder = old head
*(ALadder**)((BYTE*)myLadder + 0x47C) = this;                               // new head = this
```

Classic intrusive linked list — each ladder stores a `NextLadder` pointer and the volume stores the head.

`ALadder::addReachSpecs` then walks all actors looking for other `ALadder` nodes that share the same `ALadderVolume`. For each matching pair, it creates a spec with `reachFlags = 64` (`R_LADDER`), which tells the AI "use ladder traversal logic". After the base `addReachSpecs` call it prunes any specs that represent a downward *jump* (as opposed to a controlled climb-down):

```cpp
if (s->End->Location.Z < s->Start->Location.Z - s->Start->CollisionHeight)
    s->bPruned = 1;
```

One thing worth noting is the **bOnlyLift bit toggle**. Both `ALadder` and `ALiftCenter` apply the same Ghidra-derived bit manipulation to bit `0x800` of a bitfield DWORD. Translated from the assembly:

```cpp
DWORD uVar = *(DWORD*)((BYTE*)this + 0x3A4);
INT   iVar = ((uVar & 0x800) == 0 && bOnlyChanged != 0) ? 0 : 1;
*(DWORD*)((BYTE*)this + 0x3A4) = ((DWORD)(iVar << 11) ^ uVar) & 0x800u ^ uVar;
```

What this actually does: if `bOnlyChanged` is zero (full rebuild), *always set* bit `0x800`; if `bOnlyChanged` is non-zero (incremental), *preserve the existing value*. It looks opaque in the C++ but makes sense as "only rebuild this node if it's been marked as changed".

---

## ALadderVolume::RenderEditorInfo

This one is editor-only eye candy — it draws an arrow showing the ladder's orientation in the level editor viewport:

```cpp
FLineBatcher batcher(RI, 1, 0);
batcher.DrawDirectionalArrow(
    FindCenter(),
    FRotator(pitch, yaw, roll),
    arrowColor,
    arrowSize
);
```

`FLineBatcher` is a stack-allocated RAII helper that batches line draw calls into a single render submission. Declaring it on the stack means the destructor (which flushes the batch) fires automatically when the function exits. Ghidra showed it as `FLineBatcher local_4c[56]` — that's just the decompiler's way of saying "56 bytes of stack space for an object"; the C++ is a normal local variable.

The arrow colour comes from a pointer chain: `SceneNode -> Level -> LevelOuter -> WireColor`. We read it as a raw `BYTE*` offset because the intermediate types aren't fully declared in our headers.

---

## Lifts

The lift system is more elaborate than ladders. The key actors are:

- **`ALiftCenter`** — a NavigationPoint on the lift platform itself.
- **`ALiftExit`** — a NavigationPoint at each floor the lift can reach.
- **`AMover`** — the actual moving brush (the lift geometry).

`ALiftCenter::FindBase` runs in editor mode and resolves which `AMover` owns this center node by scanning actors for one whose `Tag` matches the center's `LiftTag`. Once found it calls `SetBase` (which parents the nav node to the mover so it moves with it) and caches `LiftOffset` — the node's position relative to the mover's origin.

`ALiftCenter::addReachSpecs` does the heavy lifting (no pun intended). For every matching `ALiftExit`:

1. A bidirectional pair of specs is created (`reachFlags = 32 = R_LIFT`), both with a fixed distance of 500 units.
2. The exit is checked to see which mover *keyframe* (stop position) aligns with its world location. A keyframe is a relative position vector stored in the mover; the function adds `MyLift->Location + LiftOffset + KeyPos` to get the world-space position at each stop, then picks the closest one that has a clear line of sight to the exit via `SingleLineCheck`.

```cpp
FCheckResult hit(1.0f);  // default Time = 1.0 = no hit
XLevel->SingleLineCheck(hit, actor, endPos, actor->Location, 0x86, extent);
if (hit.Time == 1.0f)    // still 1.0 = nothing was hit = clear path
{
    bestKey  = k;
    bestDist = d2D;
}
```

The `FCheckResult` constructor takes the initial `Time` value (1.0 = "no hit yet"). `SingleLineCheck` fills it in on collision; if `Time` is still 1.0 after the call, there was no obstruction.

---

## ALineOfSightTrigger

This is a lovely little actor: it fires an event when a player *looks at* a specific actor. The per-tick check is:

1. Is the trigger enabled and not already triggered?
2. For each local player controller, is the pawn within range of the watched actor?
3. Is the direction from the pawn to the watched actor close enough to the player's view direction? (dot product vs `SightDot` threshold)
4. Is there a clear line of sight from the watched actor to the player's eye position?

If all four are true, `eventPlayerSeesMe` fires and we break out of the loop.

```cpp
FVector dir = (triggerActor->Location - pawn->Location).SafeNormal();
FVector viewDir = FRotator(pitch, yaw, roll).Vector();
FLOAT dotVal = dir | viewDir;   // dot product
if (dotVal > sightDot) { /* player is looking at triggerActor */ }
```

The view rotation is read from raw offsets in `APlayerController` because those fields aren't in our current class declaration. The eye-pawn pointer at `playerController + 0x5B8` is a separate concept from `controller->Pawn` — in Ravenshield (and Rainbow Six games generally) your "camera pawn" can differ from your physics pawn due to the first-person body and camera offset system.

---

## APathNode::CheckSymmetry

This diagnostic helper runs during the path-build and checks that if there's a spec from node B to node A, there *should* also be a spec from A to B. If not, it resets all `visitedWeight` counters and calls `CanReach` to see if A can actually get to B via any indirect route. If it can't, it logs a warning suggesting the designer should place a `JumpDest` at A.

---

## Stats

Eleven functions implemented. No new files. Build clean. This brings the navigation layer much closer to being functionally equivalent to the retail binary — the path-builder should now correctly construct ladders, lift connections, and jump-pad trajectories when invoked.

Next up: more of the mid-level engine subsystems (material actions, physics integrations, and possibly the first look at renderer stubs).
