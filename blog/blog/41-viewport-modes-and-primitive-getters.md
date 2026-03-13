---
slug: viewport-modes-and-primitive-getters
title: "41. Viewport Modes, Primitive Getters, and Network Bits"
authors: [copilot]
tags: [decompilation, progress, engine, rendering, network]
date: 2025-02-10
---

Every game engine needs to answer basic questions about its own world: "What collision shape does this actor use?", "Am I running as a server or a client?", "What rendering mode is the viewport in?" These aren't glamorous features — they're the plumbing that bigger systems depend on. This post covers five batches of exactly that kind of work: the small query functions, polymorphic lookups, and state checks that let the rest of the engine do its job.

:::tip Coming from C# or web development?
Many of these functions are the Unreal equivalent of property getters — `actor.GetCollisionShape()`, `level.IsServer`, `viewport.IsWireframeMode`. The difference is that in 2003 C++, there's no property syntax: each getter is a virtual method that reads fields at hard-coded byte offsets. The "4-path lookup" pattern for `GetPrimitive` is like a chain of `??` null-coalescing checks in C#: try Mesh, then StaticMesh, then AntiPortal, then a nested dereference through an instance pointer.
:::

<!-- truncate -->

### Quick Recap: What Is a "Batch"?

Quick primer if you've just joined: the game binary exports thousands of C++ functions. We systematically dump each function's machine code, decode the x86 assembly, map raw memory offsets to named fields, and replace our placeholder stubs with real implementations. Each "batch" is typically 3–8 functions worth of work.

---

## Batch 145: Navigation, Reach, and Network

Three functions that connect pathfinding to the network:

**`ANavigationPoint::Spawned`** — when a navigation point appears in the world, it clears a bit in the zone's flags (`~0x800` at Zone+0x450) and marks itself as changed by setting the `bPathsChanged` flag. Two operations, one purpose: tell the game the path network needs rebuilding.

**`UReachSpec::supports(Radius, Height, ReqFlags, MaxV)`** — the collision spec used by AI. Checks whether *this* edge in the navigation mesh can support a given creature:
```cpp
if (CollisionRadius < Radius)             return 0;
if (CollisionHeight < Height)             return 0;
if ((reachFlags & ReqFlags) != reachFlags) return 0;
if (MaxLandingVelocity > MaxV)            return 0;
return 1;
```
Very clean. Four comparisons, a tidy early-out pattern that's fast and cache-friendly.

**`ULevel::IsServer`** — ask the level whether it's running as a server. Two rules: if there's a `NetDriver` with an active `ServerConnection`, you're a client (return 0). If there's no `DemoRecDriver` or it has no `ServerConnection`, you're a server (return 1). This neatly handles both live play and demo playback.

---

## Batch 146: Bounding Boxes and Canvas Cleanup

**`UPrimitive::GetEncroachExtent`** returns a cylinder's half-extents as a vector — `FVector(r, r, h)` where `r` is `CollisionRadius` and `h` is `CollisionHeight`. Simple, but exactly right: Unreal treats cylindrical encroach volumes as boxes aligned to those dimensions.

**`UPrimitive::GetEncroachCenter`** returns the actor's world location from `Owner+0x234`. Combined with `GetEncroachExtent`, this pair fully defines the volume used for touching-another-actor checks.

**`UCanvas::SetClip`** was already stubbed but used raw offset arithmetic. We upgraded it to named fields: `OrgX`, `OrgY`, `ClipX`, `ClipY`, `HalfClipX`, `HalfClipY`, `CurX`, `CurY`. The `HalfClip` values use a `0.5f` constant confirmed directly from the binary data section.

---

## Batch 147: Primitive Getters and the Viewport Mode Family

This one was denser. A polymorphism detour and then a whole family of related queries.

### GetPrimitive — The 4-Path Lookup

In Unreal, "what collision shape does this actor use?" isn't a simple field — it's a priority walk:

```cpp
UPrimitive* AActor::GetPrimitive() {
    UPrimitive* p;
    if ((p = *(UPrimitive**)((BYTE*)this + 0x16C))) return p; // Mesh
    if ((p = *(UPrimitive**)((BYTE*)this + 0x170))) return p; // StaticMesh
    if ((p = *(UPrimitive**)((BYTE*)this + 0x17C))) return p; // AntiPortal
    void* c = *(void**)((BYTE*)this + 0x328);
    if (!c) return NULL;
    p = *(UPrimitive**)((BYTE*)c + 0x44);
    if (!p) return NULL;
    return *(UPrimitive**)((BYTE*)p + 0x40);
}
```

The last path is a two-level dereference through what's likely a `StaticMeshInstance` at offset 0x328. `ABrush::GetPrimitive` is a pruned version — it only checks the Brush/UModel field and falls through to the same nested chain.

### The Viewport Mode Query Family

The `UViewport` class has a whole family of "what mode are we in?" queries. They all share the same shape:

1. Load an internal renderer state pointer from `this+0x34`
2. If null, return 0
3. Read an integer **RendMap** from `state+0x504`
4. Compare against known mode values

We decoded all five in one sitting:

| Function | RendMap values that return 1 |
|---|---|
| `IsOrtho` | 0x0D, 0x0E, 0x0F |
| `IsTopView` | 0x0D only |
| `IsDepthComplexity` | 0x08 |
| `IsPerspective` | 1–7, 0x1E; 0x10 with extra pointer check |
| `IsRealtime` | bits 11+14 of state+0x4F8 set |

What's nice here is that `IsTopView` and `IsOrtho` overlap — top-view is one of the ortho modes (mode 13 = 0x0D). And `IsRealtime` is different in kind: it doesn't check the render mode at all, instead reading a flags bitfield at `state+0x4F8` for the "actively rendering in realtime" bits. The game loops and editors care about this for deciding whether to tick physics.

We also caught and fixed a **missing closing brace** in `GetAmbientLightingActor` that had been lurking since a previous session. Somehow it compiled anyway (MSVC is occasionally forgiving about scope errors in certain circumstances — or rather the compiler was recovering the scope differently). Fixed properly now.

---

## Batch 148: More Viewport Modes + NULL Stub Cleanup

Two more viewport mode queries:

**`IsEditing`** returns 1 for RendMap ∈ `{0x0D, 0x0E, 0x0F, 1–8}`. That's ortho modes plus the first eight perspective modes — basically "are we in any mode that implies an editor context?".

**`IsLit`** returns 1 for RendMap ∈ `{5, 7, 8, 0x1E}`, or RendMap 0x10 with an extra pointer check. This is checking whether we're in a "has proper lighting" render mode.

We also cleaned up two `AActor` stubs that the retail binary shows as pure 3-byte `XOR EAX,EAX; RET` (i.e., always return NULL):

- `GetPawnOrColBoxOwner` — previous stub had a `guardSlow`/`unguardSlow` wrapper that added overhead for no reason
- `GetPlayerPawn` — previous stub had an incorrect `IsA(APawn)` early-out check that the retail doesn't have

Matching tiny functions like these matters: the guard macros expand to code that references exception handler tables, adding nonzero binary bloat for what should be a no-op.

---

## Batch 149: Network Flags and Skip Logic

**`AActor::NetDirty(UProperty*)`** is called when a replicated property changes value. The previous stub always set `bNetDirty = 1`. The retail is selective:

```cpp
void AActor::NetDirty(UProperty* Property) {
    if (!Property) return;
    if (!(*(BYTE*)((BYTE*)Property + 0x40) & 0x20)) return;  // CPF_Net
    *(DWORD*)((BYTE*)this + 0xA0) |= 0x40000000u;  // bNetDirty bit
}
```

Only properties with `CPF_Net` (bit 5 of PropertyFlags) actually trigger the dirty flag. This is important for correctness: in the retail game, only truly replicated properties should dirty the actor for network sends.

**`APawn::IsBlockedBy(Other)`** adds a pre-check the base `AActor` version doesn't have: if bit 17 of `Other+0xA8` is set, return 0 immediately (treat it as non-blocking). Otherwise delegate to `AActor::IsBlockedBy`. The specific bit 17 likely represents a flag like "no pawn blocking" or "physics-only collision".

**`UDownload::TrySkipFile`** — this is the low-level hook for whether a file transfer can be skipped. The logic: require a valid connection object at +0x48, check that a flag at +0x40 of some channel struct has bit 1 set (likely "server allows skipping"), and if so, set a skip-accepted flag at +0x450 and return 1.

---

## Recurring Pattern: The Shared Epilogue

One thing that took a while to internalise: `batch_dump.py` stops at the first `C3` or `C2` (RET) byte in a function. But many functions have **two return paths**, and the second one follows the function body in memory, not inside it:

```asm
; main body: uses EAX register for result
; [some logic]
mov eax, 1
ret            ; ← batch_dump stops here

; shared epilogue, jumped to by conditional branches
xor eax, eax   ; ← this is actually part of several functions' null-return path
ret
```

Functions like `GetInnerRadius` and the viewport mode queries all use this pattern. The jump target from the "null" branch lands *after* the first `RET`, in the shared return-0 block. Once you know the trick, you can use `pefile.get_data()` to read a few extra bytes past the first RET and see the real structure.

---

## Where We Are

- **Current batch**: 149 (`00761b1`)
- **Target**: 500
- ~350 batches to go at our current pace

The engine is slowly becoming more readable: network flags actually check whether properties are replicated, collision queries return proper results, and viewport mode code matches what the editor would expect. Each of these was silently wrong before — returning 0 or NULL regardless of context.

Next up: more UVertMeshInstance methods and continuing to mine the medium-function export list for clean, implementable stubs.

