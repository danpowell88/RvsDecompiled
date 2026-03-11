---
slug: 32-transforms-and-the-physics-of-walking
title: "Dev Blog #32: Transforms, Actors, and the Physics of Walking"
authors: [dan]
tags: [decompilation, math, physics, ue2engine]
date: 2025-07-11
---

This post covers Batches 83 and 84: implementing the actor transform matrices, a cluster of utility collision functions, and the core APawn physics machinery that makes characters actually walk around.

<!-- truncate -->

## The Missing Coordinate Frame

Every object in an Unreal Engine 2 level sits somewhere in 3D space with a rotation and a scale. When the renderer wants to draw a mesh, or a physics routine wants to test a collision, it needs to know two things:

- **LocalToWorld**: given a point in the object's local space, where is it in the world?
- **WorldToLocal**: the reverse — given a world position, where is it relative to the actor?

These are **transformation matrices** — 4×4 grids of numbers that encode rotation, scale, and translation in one mathematical object.

### Building the LocalToWorld Matrix

Unreal uses a **row-vector convention**, meaning you multiply on the left: `WorldPos = LocalPos * M`. The matrix looks like this:

```
| r00  r01  r02  0 |   ← X-axis row (scaled)
| r10  r11  r12  0 |   ← Y-axis row (scaled)
| r20  r21  r22  0 |   ← Z-axis row (scaled)
| tx   ty   tz   1 |   ← translation (in WPlane row)
```

The rotation part is built from Euler angles (Yaw, Pitch, Roll) using the engine's lookup tables (`GMath.SinTab`/`GMath.CosTab`). Each row is the corresponding world-space axis of the actor, scaled by `DrawScale3D * DrawScale`. The translation is the actor's world location minus the pivot offset (`PrePivot`) projected through the rotation:

```cpp
FLOAT tx = Location.X - r00*PrePivot.X - r10*PrePivot.Y - r20*PrePivot.Z;
```

The `PrePivot` field lets artists shift the model's centroid without moving the collision cylinder — a common trick to line up a character model with its bounding box.

### The WorldToLocal Inverse

For an arbitrary matrix the inverse is expensive. For a scale-rotation-translation matrix, though, there's a closed-form shortcut. Because the rotation block is orthogonal (rows are perpendicular unit vectors), its inverse is just the **transpose** divided by the scale squared:

`W[i][j] = L[j][i] / (S[j] * S[j])`

Since `L[j][i] = S[i] * R[j][i]`, dividing by `S[j] * S[j]` gives us `R[j][i] / S[j]` — the transposed rotation with inverted scale. The translation becomes:

```cpp
FLOAT wtx = PrePivot.X - (Location.X*w00 + Location.Y*w10 + Location.Z*w20);
```

Which ensures that when you feed in the actor's world location, you get back `PrePivot` (the local pivot) — exactly what you'd expect.

---

## Cylinder Collision: IsOverlapping

With transforms working, the next piece is **collision detection**. `AActor::IsOverlapping` asks: are these two actors intersecting right now?

Unreal uses an axis-aligned cylinder as the default collision shape — it's fast, it doesn't need normals, and it works well for upright humanoids. Two cylinders overlap when:

1. Their Z extents overlap: `abs(Z1 - Z2) < H1 + H2`
2. Their XY circles overlap: `sqrt((X1 - X2)^2 + (Y1 - Y2)^2) < R1 + R2`

In code we skip the sqrt and compare squares to avoid the expensive operation. We also skip actors joined to each other (attached objects) and actors that are the same as their owner. The Ghidra confirms this logic, plus an additional mesh-based narrow phase for projectors and fluid surfaces — those are deferred until mesh APIs are available.

---

## Stepping Over Things: stepUp

`AActor::stepUp` is one of the most important movement functions you've never thought about. Every time a pawn walks into a low kerb or a stair step, this function runs.

The algorithm (from Ghidra 0xef2f0, confirmed against UT99 reference):

1. **Move up** by `MaxStepHeight` (33 UU for base `AActor`) in the inverse gravity direction
2. **Move forward** by the desired delta
3. If we hit a wall going forward:
   - If the wall is nearly vertical (`Normal.Z < 0.08`) and we've moved far enough, undo the up-step and try the full-delta projected onto the wall
   - Otherwise call `processHitWall` and slide along the wall (projecting out the normal component)
4. **Move back down** by the step height to return to the floor

The cleverness is step 3's wall-slide — by zeroing out the Z component of the hit normal and re-normalising it, we project our remaining movement onto the horizontal plane of the wall. Two-wall corners go through `TwoWallAdjust` which computes the optimal sliding direction between both normals.

---

## Finding Ground: FindBase and PutOnGround

`FindBase` shoots a single trace straight down 8 units from the actor's feet. If it hits something other than the current base, it calls `SetBase` to re-attach. This gets called during level loading and teleportation to make sure floating objects sink to the floor.

`PutOnGround` is the more forceful version: it traces down by `CollisionHeight × 3` (a generous reach), and if it finds a surface with slope less than ~45° (`Normal.Z > 0.7`), it snaps the actor down to that surface using `FarMoveActor`. Doors, crates, dropped weapons — anything that needs to sit convincingly on the ground uses this.

---

## APawn::performPhysics: The Walking Machine

For pawns (characters who can walk, jump, crouch, and swim), physics is more complex than for generic actors. The entry point is `APawn::performPhysics`:

```cpp
void APawn::performPhysics(FLOAT DeltaSeconds)
{
    // 1. Fell out of world? Kill AI, warn player.
    if (bCollideWorld && Region.ZoneNumber == 0 && !bIgnoreOutOfWorld) { ... }

    // 2. Save velocity for rotation reference
    FVector OldVelocity = Velocity;

    // 3. Crouch state machine
    if (Physics == PHYS_Walking && bWantsToCrouch && !bIsCrouched)
        Crouch(0);
    else if (bIsCrouched)
        UnCrouch(0);

    // 4. Dispatch to the appropriate physics mode
    startNewPhysics(DeltaSeconds, 0);

    // 5. Update the IsWalking flag
    bIsWalking = (Physics == PHYS_Walking || Physics == PHYS_Falling);

    // 6. Controller drives rotation
    if (Controller && !bInterpolating && ...)
        physicsRotation(DeltaSeconds, OldVelocity);

    // 7. Deferred touch events
    if (PendingTouch) { ... }
}
```

`startNewPhysics` is the actual switch that routes to `physWalking`, `physFalling`, `physSwimming`, etc. (It was already implemented in a prior batch.) The call to `physicsRotation` on the base `APawn` class actually asserts false in the retail binary — derived classes like `AR6Pawn` override it to rotate based on the player's input or AI steering. We implement the base class as a no-op, matching the shipping behaviour.

---

## calcVelocity: Friction and Momentum

Every frame when a pawn is moving, `calcVelocity` computes how fast they should be going next frame. There are two modes:

**Braking** (when `Acceleration == 0`): friction decelerates the pawn. Rather than one big step, the Ghidra decompilation reveals **sub-step integration** — the 0.03-second timestep is important to prevent overshooting at high framerates. Each sub-step applies:

```
Velocity -= Velocity * Friction * StepSize
```

If velocity drops below 10 UU/s or reverses direction (dot product with original velocity < 0), the pawn stops immediately. This prevents the jittery sliding you'd get from purely exponential decay.

**Accelerating**: apply friction first (slowing residual momentum), then add the normalised acceleration direction scaled by `MaxSpeed * DeltaTime`, then clamp to `MaxSpeed`. The normalisation step is intentional — it means diagonal movement is capped to the same maximum speed as axis-aligned movement.

---

## NewFallVelocity: Gravity in the Middle

When a pawn is airborne, gravity needs to be integrated into the velocity each frame. Naive Euler integration (add gravity once at the end) has noticeable drift. The Ghidra shows **midpoint integration** (a form of Verlet integration):

```cpp
FVector HalfGrav = Gravity * (DeltaTime * 0.5f);
return OldVelocity + HalfGrav + OldAcceleration * DeltaTime + HalfGrav;
```

Two half-gravity steps — one before the acceleration and one after — cancel out the first-order error term, giving much better energy conservation during long falls. The gravity value comes from the zone at raw offset `Zone + 0x450`, which is the AZoneInfo `ZoneGravity` field (not yet formally declared in our headers). Buoyancy from swimming or water volumes also reduces the effective gravity.

---

## What's Left

The remaining TODOs in the physics tier are the deeper ones:

- `APawn::physWalking` — the full walking algorithm (ground tracing, step-up, slope sliding)
- `APawn::physFalling` with air control — more complex than AActor falling
- Zone and volume update functions (`SetZone`, `SetVolumes`)
- Mesh animation playback APIs (waiting on mesh subsystem)

Walking physics is the next big milestone — it's the foundation for every character in the game actually moving convincingly. See you in the next post.

