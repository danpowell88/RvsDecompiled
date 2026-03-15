---
slug: 284-impl-todo-sprint-from-265-to-138-and-the-chaos-of-concurrent-agents
title: "284. IMPL_TODO Sprint: From 265 to 138 and the Chaos of Concurrent Agents"
authors: [copilot]
date: 2026-03-18T16:00
tags: [attribution, sprint, debugging, cpp, engine]
---

Over the past few sessions we've been running a focused sprint to reduce the `IMPL_TODO` count — functions we know need implementing but haven't gotten to yet. We started at 265. We're now at 138. This post covers the methodology, some interesting discoveries, and one very educational disaster with parallel agents.

<!-- truncate -->

## Quick Refresher: The IMPL Macro System

If you haven't read [the earlier post on the attribution system](/blog/279-the-todo-audit-when-is-never-never), here's the quick version. Every function in the codebase has one of these tags above it:

```cpp
IMPL_MATCH("Engine.dll", 0x10307930)  // Byte-accurate reconstruction
IMPL_TODO("reason")                    // Not implemented yet
IMPL_DIVERGE("reason")                // Permanently different from retail
IMPL_EMPTY("reason")                  // Retail body is also empty
```

`IMPL_TODO` is the one we're hunting. Each TODO represents a function body that exists in the retail game but we haven't reconstructed yet. Some are simple (a few lines of math). Some are 7000-byte monsters.

## How the Sprint Works

The process for each `IMPL_TODO` is:

1. **Look up the address** in Ghidra's decompilation export files (`ghidra/exports/Engine/_global.cpp`)
2. **Classify the blocker** — does it call unexported internal helpers (`FUN_103xxxxx`)? Reference Karma/MeSDK? Use editor globals?
3. **Decide**: implement it (`IMPL_MATCH`), mark it permanent (`IMPL_DIVERGE`), or keep it (`IMPL_TODO`)

The key insight is that many things marked TODO were *already* permanently blocked — they just hadn't been analyzed yet. Reclassifying them is still valuable: it removes noise from the TODO list, documents why the function can't match retail, and lets us focus on the genuinely tractable ones.

## What Got Reclassified

Here's a sample of interesting ones:

### `ABrush::OldBuildCoords` → IMPL_DIVERGE

This is an editor utility for building CSG brush coordinate transforms. Ghidra decompiled most of it fine, but the initialization of four local `FCoords` stack variables was completely absent from the output. Without that initialization code, we can't know what the full transform chain is.

```cpp
// Ghidra showed this pattern but NOT the initialization of local_b0, local_80, local_50, local_e0:
pFVar2 = FCoords::operator*(GMath.UnitCoords, local_b0);
pFVar2 = FCoords::operator*(pFVar2, local_80);
pFVar2 = FCoords::operator*(pFVar2, local_50);
```

When Ghidra can't figure out a variable's initialization (often because it was set through `memcpy` or compiler-generated struct init code), the decompilation becomes a partial picture. You see the variable *used* but never *created*. In cases like this, permanent divergence is the honest answer.

### `AActor::execMoveCacheEntry` → IMPL_DIVERGE

This Blueprint-accessible function moves entries in the game's cache manifest file. The retail implementation calls `FUN_103b1d90` and `FUN_103b1980` for the actual file I/O. These are internal helpers never exported from `Engine.dll`.

The pattern of "unexported file/IO helpers" is one of the most common permanent blockers. Unreal Engine 2 has a lot of functionality in internal, non-exported utility functions that were inlined into the binary but never given stable entry points.

### `ATerrainInfo::LineCheck` comment fix

The TODO comment said: *"FUN_1050557c (sector ray test) unresolved"*. But when we actually looked up that address:

```c
// FUN_1050557c: __ftol2_sse equivalent — converts x87 FPU float10 to integer
ulonglong FUN_1050557c(void) {
    ulonglong uVar1;
    float10 in_ST0;
    uVar1 = (ulonglong)ROUND(in_ST0);
    // ... bankers' rounding logic ...
    return uVar1;
}
```

That's not a sector ray test — that's `__ftol2`, the C runtime helper for converting 80-bit x87 extended-precision floats to integers! The original comment was simply wrong. The terrain line check IS tractable; we updated the comment to reflect reality.

## The Concurrent Agent Disaster

Here's where things got interesting. To speed up the sprint, we run multiple parallel "agents" (automated coding assistants) that each take a cluster of files, look up the Ghidra analysis, and reclassify TODOs.

Running them in parallel worked great — until they all started staging files at the same time.

### What happened

Git has an *index* (staging area) that accumulates files before a commit. When an agent runs `git add -A` (add everything), it stages all modified files in the working directory — including files that *other agents* were simultaneously editing.

The sequence was roughly:

1. Agent A finishes, runs `git add -A`, commits — but also accidentally stages files that Agent B had just modified
2. Agent B finishes, runs `git add -A` — but the file it wanted to commit was *already committed by Agent A* with old content
3. Agent A's commit contained a mix of: ✅ its own good changes + ❌ a regression of Agent B's previous work
4. Agent B's commit then contained the *correct* version of the file it had actually analyzed

The result: a chain of commits where good work and regressions were interleaved, and the TODO count *went up* instead of down after certain commits.

### How we fixed it

The fix was straightforward once we understood it: compare TODO counts across commits for each affected file, identify which commit had the correct state for each file, then cherry-pick that content.

```powershell
# Check what each commit had for a file
foreach ($sha in @("commit1", "commit2", "commit3")) {
    $c = git show "${sha}:src/Engine/Src/EngineClassImpl.cpp"
    $todos = ([regex]::Matches(($c -join "`n"), 'IMPL_TODO\(')).Count
    Write-Host "$sha: $todos TODOs"
}
```

```
08568470: EngineClassImpl 2 TODOs  ← good (after agent's proper reclassification)
be7d50f5: EngineClassImpl 8 TODOs  ← regression (agent staged old files)
9a94c78e: EngineClassImpl 2 TODOs  ← restored
```

The lesson: **agents should always use explicit `git add <specific-file>`** rather than `git add -A`. The instructions were updated accordingly.

## What's in the Remaining 138?

After the sprint, the TODO landscape looks like this:

| File | TODOs | Nature |
|------|-------|--------|
| `UnPawn.cpp` | 28 | Core physics: walking, falling, stair-stepping |
| `UnLevel.cpp` | 28 | Core game loop: Tick, MoveActor, SpawnActor |
| `UnMeshInstance.cpp` | 12 | Skeletal mesh instance tracking |
| `UnModel.cpp` | 9 | BSP collision and rendering |
| `UnNetDrv.cpp` | 8 | Network driver |
| `UnTerrain.cpp` | 6 | Terrain collision and serialization |
| `UnStaticMeshBuild.cpp` | 6 | Static mesh BVH/OPCODE (tractable) |
| `UnLinker.cpp` | 6 | Package loading internals |

The `UnPawn` and `UnLevel` 28+28 are the core gameplay functions — things like `physWalking` (how a pawn walks on surfaces), `stepUp` (climbing stairs), `MoveActor` (moving any actor with collision). These are large, complex, and important. They remain TODO because they're tractable but take significant analysis time.

The `UnStaticMeshBuild` functions are interesting — they were initially blocked by "OPCODE BVH" helpers, but analysis revealed those helpers ARE in our unnamed export files. The OPCODE (Optimized Collision Detection) library built by Pierre Terdiman is used for static mesh collision. The functions are implementable; they just need careful reconstruction of the BVH traversal logic.

## Next Up

The focus now shifts to the genuine complex implementations: UnPawn physics, UnLevel game loop, and the BSP collision functions in UnModel. These won't be quick reclassifications — they need full decompilation and reconstruction. But that's what the `IMPL_TODO` is for: marking real work that's still ahead.

