---
title: "64. Actor Internals: Karma, Debug Lines, and Joined Actors"
authors: [rvs-team]
tags: [r6engine, unactor, karma, physics, ghidra, decompilation, debug]
---

This session filled in nine stub functions in `UnActor.cpp` — the heart of the actor system —
plus added `// STUB:` annotations to a further nineteen functions that are too complex to
reconstruct safely yet. Small changes, but each one came with its own little puzzle. Let's walk
through the interesting ones.

<!-- truncate -->

## A Quick Refresher: What's an Actor?

In Unreal Engine, *everything in the game world is an actor*. A weapon, a door, a light, a
trigger, a player character — they all inherit from `AActor`. The engine maintains a big list of
actors and each frame it "ticks" them (updates their state), runs physics on them, draws them,
and lets them talk to each other via collision and overlap events.

`UnActor.cpp` is the C++ implementation file for all of that base machinery. When we stub a
function here we're touching the very foundation the whole game is built on.

---

## `getKModel()` — Finding the Physics Shape

Karma is the physics middleware Ravenshield uses (based on MathEngine's Karma SDK). Every
physics-enabled actor has a `KParams` pointer that points to a Karma parameter block. Inside
that block, at offset `+0x48`, is the actual *MCD model* — the collision shape handed to the
Karma solver.

The original code is almost comically simple:

```cpp
struct _McdModel* AActor::getKModel() const
{
    if( !KParams ) return NULL;
    return *( struct _McdModel** )( (BYTE*)KParams + 0x48 );
}
```

But it takes Ghidra to confirm those magic offsets. Ghidra shows the binary reads
`*(ptr)(this+0x18c)` for `KParams` then dereferences at `+0x48`. Cross-checking with the
`AActor` field layout we reconstructed earlier confirms 0x18c is `KParams`.

---

## `physKarma()` / `physKarmaRagDoll()` — Profiled Wrappers

The original binary has an interesting pattern: the public `physKarma` function is just a tiny
wrapper around `physKarma_internal`. The wrapper's only *extra* job in the original is to
timestamp it with `rdtsc` (the CPU's cycle counter) and accumulate the result into some
binary-specific global performance counters.

We keep the wrapper pattern but drop the profiling:

```cpp
void AActor::physKarma( FLOAT DeltaTime )
{
    guard(AActor::physKarma);
    physKarma_internal( DeltaTime );
    unguard;
    // DIVERGENCE: omits original rdtsc profiling counter update (binary-specific globals)
}
```

The `guard`/`unguard` macros are Unreal's structured exception handling wrappers — they catch
crashes and report which function was on the call stack, which is invaluable for debugging.
Ghidra's output showed an SEH frame here, so we keep it.

`physKarma_internal` itself is a large chunk of Karma SDK calls we haven't decoded yet, so it
stays stubbed.

---

## `IsJoinedTo()` — Walking the Base Chain

This one is elegant. In Unreal, actors can be *based on* other actors — think a crate sitting on
a moving platform, or an attachment bolted to a character. There's also `JoinedTag`: a shared
integer tag that marks a group of actors as logically joined (so they don't collide with each
other, for example).

`IsJoinedTo` walks up the `Base` chain checking both conditions:

```cpp
INT AActor::IsJoinedTo( const AActor* Other ) const
{
    for( const AActor* A = this; A; A = A->Base )
    {
        if( A == Other )
            return 1;
        if( A && Other && A->JoinedTag != 0 && A->JoinedTag == Other->JoinedTag )
            return 1;
    }
    return 0;
}
```

Ghidra confirmed the offsets: `Base` is at `+0x15c`, `JoinedTag` at `+0x31c`. The loop
structure matches Ghidra's output exactly.

---

## `NativeNonUbiMatchMaking()` — Command-line Flags

These two functions answer a simple question: "was this game started with a particular
command-line flag?" The `Ip=` flag means "connect directly by IP" (non-Ubi.com matchmaking),
and `Host` means "act as a host".

```cpp
INT AActor::NativeNonUbiMatchMaking()
{
    guard(AActor::NativeNonUbiMatchMaking);
    return ParseParam( appCmdLine(), TEXT("Ip=") );
    unguard;
}
```

`appCmdLine()` returns the raw command-line string. `ParseParam` scans it for a token. The
string `L"Ip="` was confirmed by direct binary inspection of address `0x1055b2f8` in Ghidra.
Simple, but nice to have right.

---

## `DbgAddLine()` — The Debug Drawing Array

Ravenshield has a small debug-line buffer: a global array of 100 `STDbgLine` entries and a
rolling index. Each entry stores a start point, end point, and colour. Calling `DbgAddLine`
bumps the index (wrapping at 99) and writes into that slot.

We needed to define the struct locally in `UnActor.cpp` since it's only forward-declared in the
header:

```cpp
// STDbgLine: debug line entry — 28 bytes matching binary layout (Ghidra 0x71250)
struct STDbgLine
{
    FVector Start;  // 0x00
    FVector End;    // 0x0c
    FColor  Color;  // 0x18
};

extern ENGINE_API STDbgLine* GDbgLine;
extern ENGINE_API INT        GDbgLineIndex;
```

The `ENGINE_API` qualifier means these globals are exported from the Engine DLL so other modules
can access them. Total size of `STDbgLine` is `3×4 + 3×4 + 4 = 28` bytes, matching Ghidra's
0x1c.

```cpp
void AActor::DbgAddLine( FVector Start, FVector End, FColor Color )
{
    if( ++GDbgLineIndex > 99 )
        GDbgLineIndex = 0;
    GDbgLine[ GDbgLineIndex ].Start = Start;
    GDbgLine[ GDbgLineIndex ].End   = End;
    GDbgLine[ GDbgLineIndex ].Color = Color;
}
```

---

## `DbgVectorReset()` — TArray Element Access

```cpp
void AActor::DbgVectorReset( INT VectorIndex )
{
    if( VectorIndex < m_dbgVectorInfo.Num() )
        m_dbgVectorInfo( VectorIndex ).m_bDisplay = 0;
}
```

One syntax detail worth noting: Unreal's `TArray` overloads `operator()` (not `operator[]`) for
element access. `m_dbgVectorInfo(VectorIndex)` returns a reference to the element — the bounds
check via `Num()` guards against out-of-range indices, matching Ghidra's pattern.

---

## `ABrush::InitPosRotScale()` — Hidden Fields

`ABrush` has two `FScale` fields that never made it into the public `EngineClasses.h` header —
they're at raw offsets `+0x3b0` and `+0x3c4`. We access them with pointer arithmetic:

```cpp
void ABrush::InitPosRotScale()
{
    guard(ABrush::InitPosRotScale);
    check(Brush);
    *(FScale*)((BYTE*)this + 0x3b0) = GMath.UnitScale;
    *(FScale*)((BYTE*)this + 0x3c4) = GMath.UnitScale;
    Location  = FVector(0,0,0);
    Rotation  = FRotator(0,0,0);
    // PrePivot — hidden at raw offset 0x2c8 due to gap in EngineClasses.h reconstruction
    *(FVector*)((BYTE*)this + 0x2c8) = FVector(0,0,0);
    unguard;
}
```

`GMath.UnitScale` is the identity scale (`1.0, no sheer`). Ghidra showed a `memcpy` of 5 DWORDs
(20 bytes = sizeof FScale) from `GMath+0x48` to both offsets. The `check(Brush)` call maps to
the `appFailAssert("Brush", ...)` in the original binary.

---

## What's Still Stubbed?

Nineteen functions got `// STUB: too complex` comments rather than implementations. The biggest
ones are:

- `physKarma_internal` / `physKarmaRagDoll_internal` — hundreds of Karma SDK calls, needs its
  own dedicated session
- `PostNetReceive` / `PreNetReceive` — `>150` lines touching binary-specific networking globals
- `AttachProjector` / `DetachProjector` — complex projector texture bookkeeping
- `RenderEditorInfo` / `RenderEditorSelected` — editor rendering, low priority for gameplay

These stubs compile and link cleanly; the game just won't exhibit those specific behaviours
until we fill them in.

---

## Build Status

Zero errors, only the same pre-existing warnings we always have (`C4595` on inline `new/delete`
in the SDK headers). Every commit leaves the build green — that's the invariant we never break.
