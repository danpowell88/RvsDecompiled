---
slug: the-invisible-world
title: "The Invisible World — Collision, Octrees, and Finding the Floor"
authors: [default]
tags: [decompilation, collision, spatial-data-structures, pathfinding, unreal-engine, reverse-engineering]
---

Most of the time, the most important parts of a game world are the ones you never see. The collision geometry. The pathfinding graph. The invisible bounding boxes that stop you walking through walls. This week we implemented two systems that are foundational to all of that: the **collision octree** and the **path anchor finders**. Neither draws a single pixel. Both are essential for the game to actually work.

<!-- truncate -->

## Two Collision Systems? Really?

You might wonder why Unreal Engine 2 has *two* separate collision systems. The answer is history, and a familiar engineering tradeoff.

The older system — `FCollisionHash` — is a **hash grid**. It divides the world into a regular 3D grid of buckets, each covering a fixed-size cell. When you want to know what actors are near a point, you compute the bucket indices and walk the linked list for each nearby bucket. It's fast and simple, but the bucket size is fixed (256 Unreal units per cell) and the world is assumed to fit within a 524,288 × 524,288 × 524,288 unit box. Not ideal for a large outdoor level.

The newer system — `FCollisionOctree` — is an **octree**. It's more adaptive: instead of a uniform grid, it starts with one root node covering the whole world and can subdivide any node that contains too many actors. If actors cluster in one corner of the map, only *that* corner gets subdivided deeply. The rest stays coarse.

The two systems coexist in Ravenshield because the hash is used in the editor (where stability and simplicity matter) and the octree is used during gameplay (where adaptability matters). Our `FCollisionHash` implementation was done in an earlier batch — this time it was the octree's turn.

## What Is an Octree?

Before diving into implementation, let's step back and understand what an octree actually *is*, because it's one of those concepts that sounds intimidating until you see the picture.

Imagine the entire game world fits inside a giant cube. That cube is the root of your octree. Now, subdivide it: cut it in half along each of the three axes (X, Y, Z), giving you **eight child cubes** — that's where "oct" comes from.

```
      ┌───┬───┐
     /│   │   /│
    ┌─┼───┼──┤ │
    │ ├───┼──┤ │    Eight equal octants
    │/    │   /│    sharing one parent
    └─────┴──┘
```

Each of those eight children can itself be subdivided into eight more, and so on. You only subdivide a node when it contains too many objects — this is what makes octrees adaptive. An empty region of the map stays as a single large leaf node. A crowded arena might subdivide three or four levels deep.

Querying the octree — "what's near this point?" — starts at the root and descends only into nodes whose volumes *intersect* your query region. Big, quiet parts of the map are skipped entirely.

## The Ravenshield FOctreeNode

In Ravenshield's engine, octree nodes live as `FOctreeNode` objects. After reconstructing the class from Ghidra, the actual in-memory layout is surprisingly compact: just **16 bytes**.

```
Offset  Size  Content
------  ----  -------
+0       4    TArray<AActor*> data pointer  ─┐
+4       4    TArray count                   ├─ actors in this node
+8       4    TArray max capacity            ┘
+12      4    FOctreeNode* children array     ─ NULL if leaf
```

The `TArray<AActor*>` at the start holds the actors currently stored in this node. The children pointer is `NULL` for leaf nodes; if the node has been subdivided, it points to a heap-allocated block containing eight `FOctreeNode` structs back-to-back.

One quirk: the header file declares `BYTE Pad[64]` for the node, implying 64 bytes. Ghidra tells us the real allocation is `malloc(0x84)` for the eight-child block — that's 4 bytes for a child count, plus 8 × 16 bytes for the nodes themselves. The 64-byte header is an over-reservation. We leave the header as-is to avoid breaking the vtable and public API, but all our code uses the real 16-byte layout via raw offset access.

## The FCollisionOctree

The `FCollisionOctree` class itself is the manager. It stores:

- A pointer to the root `FOctreeNode`
- A **frame counter** used to deduplicate actors during queries (more on that in a moment)
- **Query state** — start/end vectors, extent, flags, source actor — all baked in at the start of each collision query so the recursive node traversal can read them without threading parameters through every call

Our Ghidra analysis showed the actual field layout:

```
Offset  Field          Purpose
------  -----          -------
+4      FOctreeNode*   root node
+8      INT            frame counter (starts at 0x1fffffff)
+12     FCheckResult*  result list head during query
+16     FMemStack*     allocator for FCheckResult objects
+20..   FVectors       query start, end, direction, 1/direction, extent
+88     DWORD          TypeFlags
+96     AActor*        SourceActor (for owner-chain skipping)
```

## The Subdiving Problem

Here's where we hit our first snag.

In the fully-implemented retail engine, `FOctreeNode` can subdivide itself. When a node accumulates more than a threshold of actors and is large enough, it allocates eight child nodes and redistributes actors into them. The filtering code — `SingleNodeFilter` (routes actor to one child) and `MultiNodeFilter` (routes actor to multiple overlapping children) — walks the actor's bounding box against each child octant to figure out where it belongs.

The spatial math for this lives in four helper functions. In Ghidra:

- `FUN_103d8e50` — which single child octant does this bbox fit in? (-1 if it spans multiple)
- `FUN_103d8d50` — how many children overlap this bbox? Fill an index array.
- `FUN_103d8c80` — compute center and splitting planes for a child octant
- `FUN_103d8ce0` — quick test: does this bbox fit in any one child?

The problem? **None of these are exported.** They're private helper functions with no symbols. We can see them in Ghidra's disassembly by address, but decompiling them faithfully is a substantial project in itself — each involves non-trivial geometry maths with multiple branches.

Faced with this, we took a pragmatic approach: **flat root storage**. All actors go into the root node. No subdivision. The octree becomes equivalent to a flat linked list for now. Queries iterate every tracked actor linearly.

This is O(n) per query — worse than O(log n) for a balanced octree, but:

1. It's *correct*. The right actors participate in collision. The game logic works.
2. It unblocks everything that depends on collision.
3. The performance gap matters mainly for levels with hundreds of dynamic actors. For most game situations it's fine.
4. We document the divergence prominently, so a future contributor can finish the spatial math.

## AddActor and RemoveActor

With the "flat root" decision made, `AddActor` becomes beautifully simple:

```cpp
void FCollisionOctree::AddActor(AActor* Actor)
{
    // Validate prerequisites
    check((*(DWORD*)((BYTE*)Actor + 0xa8)) & 0x800);   // bCollideActors
    if (*(SBYTE*)((BYTE*)Actor + 0xa0) < 0) return;    // bDeleteMe
    if ((*(DWORD*)((BYTE*)Actor + 0xa8)) & 0x100) return; // bNoCollision

    // Already registered? (OctreeNodes list is non-empty)
    TArray<FOctreeNode*>& NodeList = *(TArray<FOctreeNode*>*)((BYTE*)Actor + 0x338);
    if (NodeList.Num() > 0) return;

    // Store in root node
    FOctreeNode* Root = *(FOctreeNode**)Pad;
    if (Root) Root->SingleNodeFilter(Actor, this, NULL);

    // Remember where we placed this actor (used for consistent removal)
    *(DWORD*)((BYTE*)Actor + 0x308) = *(DWORD*)((BYTE*)Actor + 0x234);  // ColLocation = Location
    *(DWORD*)((BYTE*)Actor + 0x30c) = *(DWORD*)((BYTE*)Actor + 0x238);
    *(DWORD*)((BYTE*)Actor + 0x310) = *(DWORD*)((BYTE*)Actor + 0x23c);
}
```

The key design feature here is the **two-way registration**. When we add an actor to a node's TArray, we also add a pointer back to *that node* in the actor's own `OctreeNodes` list (at `actor+0x338`). This means removal is fast: we don't search the whole octree — we just walk the actor's personal list of nodes and remove ourselves from each one.

```cpp
void FCollisionOctree::RemoveActor(AActor* Actor)
{
    check((*(DWORD*)((BYTE*)Actor + 0xa8)) & 0x800);
    if (*(SBYTE*)((BYTE*)Actor + 0xa0) < 0) return;

    // Walk actor's node list, removing from each
    TArray<FOctreeNode*>& NodeList = *(TArray<FOctreeNode*>*)((BYTE*)Actor + 0x338);
    for (INT i = 0; i < NodeList.Num(); i++)
    {
        FOctreeNode* Node = NodeList(i);
        if (!Node) continue;
        TArray<AActor*>& ActorList = *(TArray<AActor*>*)Node;
        ActorList.RemoveItem(Actor);
    }
    NodeList.Empty();
}
```

Elegant: one data structure stores the forward mapping (node → actors), the other stores the reverse (actor → nodes), and together they make both insertion and deletion O(k) in the size of the overlap, not O(n) in the total scene.

## Collision Queries

Once actors are in the octree, we need to answer queries: "does this ray hit anything? does this sphere overlap anything?"

The key function is `ActorLineCheck`. It takes a start point, end point, and optional extent (for capsule sweeps). In the retail code, the octree recursively descends to find only the nodes whose bounding volume the ray intersects — that's the whole point of the spatial structure. In our simplified version, we iterate the root's flat list:

```cpp
FCheckResult* FCollisionOctree::ActorLineCheck(FMemStack& Mem,
    FVector End, FVector Start, FVector Extent,
    DWORD TraceFlags, DWORD TypeFlags, AActor* SourceActor)
{
    INT& Frame = *(INT*)(Pad + 4);
    Frame++;  // New frame = fresh dedup slate

    FOctreeNode* Root = *(FOctreeNode**)Pad;
    if (!Root) return NULL;

    TArray<AActor*>& Actors = *(TArray<AActor*>*)Root;
    FCheckResult* List = NULL;

    for (INT i = 0; i < Actors.Num(); i++)
    {
        AActor* A = Actors(i);
        if (!A) continue;

        // Deduplication: if already visited this frame, skip
        if (*(INT*)((BYTE*)A + 0x60) == Frame) continue;
        *(INT*)((BYTE*)A + 0x60) = Frame;

        if (A == SourceActor) continue;

        // Skip owned actors (walk owner chain)
        bool bIgnored = false;
        for (BYTE* pI = (BYTE*)SourceActor; pI; pI = (BYTE*)*(INT*)(pI + 0x140))
            if ((AActor*)pI == A) { bIgnored = true; break; }
        if (bIgnored) continue;

        if (A->ShouldTrace(SourceActor, TraceFlags))
        {
            FCheckResult TestHit(0.f);
            if (A->GetPrimitive()->LineCheck(TestHit, A, End, Start,
                                              Extent, TypeFlags, TraceFlags) == 0)
            {
                FCheckResult* CR = (FCheckResult*)Mem.PushBytes(sizeof(FCheckResult), 8);
                if (CR) {
                    appMemcpy(CR, &TestHit, sizeof(FCheckResult));
                    CR->GetNext() = List;
                    List = CR;
                }
                if (TraceFlags & 0x200) return List;  // Early exit if first-hit-only
            }
        }
    }
    return List;
}
```

The **frame counter deduplication** trick is worth understanding. In a proper octree, an actor's bounding box might overlap multiple nodes. Without deduplication, a query that spans several nodes could hit the same actor multiple times. The frame counter solves this cheaply: increment a counter at the start of each query, and mark each actor with the current counter when you visit it. If you see an actor already marked with the current counter, skip it — you've already checked it this query.

The counter starts at `0x1fffffff` and simply counts up. Since the tag is just an INT per actor, it wraps around eventually, but for practical gameplay durations that never happens. This identical pattern appears in `FCollisionHash` — it's a Unreal Engine idiom.

## FOctreeNode::StoreActor

The actual act of recording an actor in a node is handled by `StoreActor`. Because `StoreActor` is declared `private` in `FOctreeNode` (you can tell from its mangled name: `@@AAE` means private, while `SingleNodeFilter` uses `@@QAE` meaning public), external callers like `FCollisionOctree::AddActor` can't call it directly. The public `SingleNodeFilter` wraps it:

```cpp
void FOctreeNode::StoreActor(AActor* Actor, FCollisionOctree* OctHash, FPlane const* Plane)
{
    // Add actor to this node's flat list
    TArray<AActor*>& ActorList = *(TArray<AActor*>*)this;
    ActorList.AddItem(Actor);

    // Back-register: actor knows it lives in this node
    TArray<FOctreeNode*>& NodeList = *(TArray<FOctreeNode*>*)((BYTE*)Actor + 0x338);
    NodeList.AddItem(this);
}

void FOctreeNode::SingleNodeFilter(AActor* Actor, FCollisionOctree* OctHash, FPlane const* Plane)
{
    StoreActor(Actor, OctHash, Plane);  // Simplified: no octant routing
}
```

Reading C++ name mangling is genuinely useful for this kind of work. The access specifier is encoded in the symbol. `A` = private, `Q` = public, `I` = protected, combined with `AE` = thiscall (instance method). This kind of encoding lets us reconstruct visibility rules from binary-only analysis.

## FSortedPathList: Finding Your Anchors

The other work in this batch was less architecturally complex but equally important for AI: implementing `FSortedPathList::findStartAnchor` and `FSortedPathList::findEndAnchor`.

When the AI wants to navigate from point A to point B, it doesn't teleport. It uses a pathfinding graph — a network of `ANavigationPoint` actors connected by edges. But the AI pawn's *current position* and *desired destination* probably aren't directly on a nav point. So before running A* (or Ravenshield's equivalent), we need to snap both ends of the journey to the nearest reachable nav point.

That's what the anchor finders do.

An `FSortedPathList` is a small fixed-size array of nav points, pre-sorted by distance or some cost metric. The "start anchor" is the first nav point in the list that the scout pawn can actually *reach* (i.e., walk to without getting stuck). The "end anchor" is the first nav point from which the pawn could reach the *destination*.

The nav graph includes a "blocked" flag (`bit 0x200` at `NavPoint+0x3a4`). If a node is flagged as blocked, skip it — the path can't pass through it anyway. Then we ask the engine's physics/reachability test via `APawn::actorReachable`:

```cpp
ANavigationPoint* FSortedPathList::findStartAnchor(APawn* Scout)
{
    ANavigationPoint** Paths = (ANavigationPoint**)Pad;
    INT Count = *(INT*)(Pad + 0x100);

    for (INT i = 0; i < Count; i++)
    {
        ANavigationPoint* Nav = Paths[i];
        if (!Nav) continue;
        if ((*(DWORD*)((BYTE*)Nav + 0x3a4)) & 0x200) continue;  // blocked
        if (Scout->actorReachable(Nav, 1, 1)) return Nav;        // can scout walk here?
    }
    return NULL;
}
```

`findEndAnchor` is similar but adds a second test: can the scout reach the *goal* from the candidate nav point? If not, note it as a fallback (if `bAllowFallback` is set) and keep looking. This prevents the AI from committing to an anchor that leads to a dead end.

## The ColLocation Mystery

One detail worth calling out: when `AddActor` stores an actor in the octree, it copies the actor's current `Location` into a separate field called `ColLocation` (at `actor+0x308`). Why?

Because actors *move*. Between the time you call `AddActor` and when you call `RemoveActor`, the actor might have walked across the level. If `RemoveActor` tried to find the actor by its *current* location, it might look in the wrong octree node — the one where the actor *is now*, not the one where it *was registered*.

By caching the location at registration time (`ColLocation`), the removal code can correctly find and clean up the actor's presence even after it's moved. The next `AddActor` call will register it fresh at the new location.

This is a subtle correctness requirement that's easy to miss if you just look at the interface. The Ghidra decompilation makes it visible.

## What's Next

This batch rounds out the core collision infrastructure. The octree is functional — not as spatial-partitioning-efficient as the retail implementation, but correct and ready to be called by the game simulation loop.

Next up is more Phase 7 mop-up: the remaining vertex stream methods, some scene node plumbing, and eventually the terrain collision system (which is a beast in its own right). We also need to look at the Phase 7F build cleanup — removing the remaining `/alternatename` pragma hacks from Launch.cpp, Window.cpp, and friends, replacing them with clean out-of-line definitions.

The goal: every stub gone, every function implemented, every `/alternatename` redirect replaced with actual code. We're getting close.
