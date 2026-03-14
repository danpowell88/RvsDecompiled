---
slug: 109-stub-migration-proper-homes
title: "109. Finding Proper Homes: Moving Stubs Out of EngineStubs.cpp"
authors: [copilot]
date: 2026-03-14T06:30
tags: [refactoring, engine, decompilation, architecture]
---

Every growing codebase eventually needs a tidy-up. Today we performed a surgical
refactoring on `EngineStubs.cpp` — the engine's catch-all file for decompiled
functions — moving about 94 implementations into the source files where they
actually belong.

<!-- truncate -->

## The Problem: One Giant File to Rule Them All

When we first started this decompilation project, we needed a way to get the
engine to compile and link before we had fully understood every function. The
solution was `EngineStubs.cpp`: a single file containing trivial stub bodies for
every exported symbol the DLL needed to provide.

```cpp
// EngineStubs.cpp — circa a few hundred commits ago
FSceneNode::~FSceneNode() {}
FStatGraph::FStatGraph(FStatGraph const& p0) {}
FWaveModInfo::FWaveModInfo() : SampleLoopsNum(0), NoiseGate(0) {}
// ... hundreds more just like this
```

The file served its purpose beautifully: it let the linker satisfy every `.def`
export while we gradually reverse-engineered the real implementations. But as
those real implementations landed, something began to feel wrong.

The `FWaveModInfo::ReadWaveInfo` function — a 50-line WAV parser — was living
in `EngineStubs.cpp` right next to `FSortedPathList::findEndAnchor`, a pathfinding
helper. These two functions have absolutely nothing to do with each other, and
neither belongs in a file called "stubs".

By the time we noticed, `EngineStubs.cpp` had grown to **4,152 lines**.

## What We Moved and Where

Today's commit moves 94 function implementations to 15 different target files,
each of which is the natural home for that code:

| Target file | What moved there |
|---|---|
| `Engine.cpp` | `FRotatorF` arithmetic operators, `FURL` parsing and serialisation |
| `UnRender.cpp` | `FSceneNode` hierarchy, all `UVertexStream*` classes, `FColor(FPlane)`, `FDbgVectorInfo`, `FRenderInterface`, scene node subclasses, `HCoords` |
| `UnStatGraph.cpp` | `FStatGraph`, `FStats`, `FEngineStats` |
| `UnAudio.cpp` | `FWaveModInfo` (WAV parsing/resampling), `FSoundData` |
| `UnChan.cpp` | `FInBunch`, `FOutBunch` |
| `UnActCol.cpp` | `FCollisionHash`, `FCollisionOctree`, `FOctreeNode` |
| `UnSceneManager.cpp` | `FMatineeTools`, `ECLipSynchData` |
| `UnLevel.cpp` | `FPointRegion` |
| `UnTerrain.cpp` | `UTerrainSector` and `UTerrainPrimitive` constructors |
| `UnConn.cpp` | `UPackageMapLevel` constructor |
| `R6EngineIntegration.cpp` | `UR6AbstractTerroristMgr` constructor |
| `UnFPoly.cpp` | `FPoly::operator=`, `FPoly::GetTextureSize` |
| `UnNavigation.cpp` | `FSortedPathList::findEndAnchor/findStartAnchor`, `FPathBuilder::operator=` |
| `UnStaticMeshBuild.cpp` | `FRebuildTools` accessors |

After the move, `EngineStubs.cpp` shrank from 4,152 to **2,885 lines** — a
reduction of roughly 30%.

## How It Was Done: Surgical Python Scripts

Moving code between files is inherently error-prone if done by hand. A
copy-paste mistake, a missed closing brace, or a stray comment can silently
break things. We automated the process with two Python scripts.

### Script 1: Append to Target Files

The first script simply appended each implementation block to the end of its
target file. The logic was straightforward: check if the block is already
present (idempotency guard), then write it.

### Script 2: Remove from EngineStubs.cpp

The removal script is where the interesting engineering happened. It needed to:

1. Find each function by a **unique substring** of its signature
2. Walk **backward** through consecutive `//` comment lines to capture the
   whole documentation block
3. Walk **forward** using brace-depth tracking to find the closing `}`
4. Collect all matching line indices into a removal set
5. Write the file back without those lines
6. Collapse any resulting triple-blank-line runs back to double

The brace tracking deserves a small mention. Functions come in two shapes:

```cpp
// Single-line (depth goes 0 → 1 → 0 on same line)
FSceneNode::~FSceneNode() {}

// Multi-line (depth tracks across lines)
void FStats::Clear()
{
    // 50 lines of logic
}
```

The tracker handles both by counting `{` and `}` characters while skipping
`//` line comments (so brace characters inside comment text don't fool it).

One gotcha: the `FSceneNode::GetLevelSceneNode()` stub sits in the middle of
several other GetXxx stubs, and immediately after it is `UMeshInstance::MeshToWorld()`
which we *don't* want to remove. By using precise signature strings rather than
line ranges, we avoided any accidental deletions.

## A Small Fix Along the Way

Moving `FLightMapSceneNode::FilterActor` to `UnRender.cpp` revealed that the
function references `GRebuildTools` — a global declared `extern` at the top
of `EngineStubs.cpp`. Since `UnRender.cpp` doesn't have that declaration, we
got a clean compiler error:

```
UnRender.cpp(623,7): error C2065: 'GRebuildTools': undeclared identifier
```

The fix was a one-liner: add the `extern` declaration immediately before the
`FLightMapSceneNode` block in `UnRender.cpp`:

```cpp
extern ENGINE_API FRebuildTools GRebuildTools;
void FLightMapSceneNode::Render(FRenderInterface*) {}
INT FLightMapSceneNode::FilterActor(AActor* Actor) { ... }
```

That's exactly the kind of thing automated tooling catches immediately — the
build broke, the error pointed straight at the problem, and the fix was trivial.

## Why This Matters

Keeping code near related code is more than aesthetic. When you're tracing
through `UnAudio.cpp` trying to understand how the engine loads a sound file,
you want `FSoundData::Load` and `FWaveModInfo::ReadWaveInfo` to be *right there*
— not buried somewhere in a 4,000-line grab-bag file. As the decompilation
progresses and more real logic appears, the file structure should be a map that
guides you.

`EngineStubs.cpp` still exists and still has real work to do. But it's now
smaller, more focused, and its contents are more honestly "stubs that haven't
been decompiled yet" rather than "stubs plus a bunch of functions that belong
somewhere else."

The goal is for it to eventually disappear entirely.
