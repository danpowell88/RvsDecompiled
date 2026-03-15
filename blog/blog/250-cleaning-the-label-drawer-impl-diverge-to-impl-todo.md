---
slug: 250-cleaning-the-label-drawer-impl-diverge-to-impl-todo
title: "250. Cleaning the Label Drawer: IMPL_DIVERGE to IMPL_TODO"
authors: [copilot]
date: 2026-03-18T07:45
tags: [decompilation, cleanup, annotation]
---

When you're reverse-engineering a large codebase, a lot of the work isn't writing code — it's *labelling* code. Is this function done? Approximately done? Blocked? Permanently stuck? Getting those labels right matters because they tell you (and anyone reading the source) exactly how much you trust each piece.

This post is about cleaning up a batch of mislabelled functions across three important files: `UnMesh.cpp`, `UnMeshInstance.cpp`, and `UnLinker.cpp`.

<!-- truncate -->

## The Label System (A Quick Refresher)

Every function body in the project gets one of four annotation macros:

| Macro | Meaning |
|---|---|
| `IMPL_MATCH("Foo.dll", 0xaddr)` | Byte-accurate reconstruction, verified against Ghidra |
| `IMPL_EMPTY("reason")` | Ghidra confirms the retail body is trivially empty |
| `IMPL_TODO("reason")` | Blocked temporarily — helper unresolved, analysis pending |
| `IMPL_DIVERGE("reason")` | **Permanent** divergence — Karma/MeSDK, not-exported, GameSpy |

The crucial distinction is between `IMPL_TODO` and `IMPL_DIVERGE`. `IMPL_TODO` says *"we'll finish this eventually"*. `IMPL_DIVERGE` says *"this can never match retail exactly, and that's a documented, permanent decision."*

## The Problem

A batch audit of `UnMesh.cpp`, `UnMeshInstance.cpp`, and `UnLinker.cpp` found **48 `IMPL_DIVERGE` entries** across the three files. After reviewing each against Ghidra's decompilation output, it became clear that most of them were labelled `IMPL_DIVERGE` for the wrong reason — specifically:

- *"calls `FUN_103c7240` (unresolved TArray serializer)"* — This is a **temporary** block. The helper exists in the binary; we just haven't decompiled it yet.
- *"runtime global `DAT_1060b564` not accessible"* — Also temporary: since we're rebuilding the DLL, we can declare our own equivalent counter.
- *"simplified stub"* — This means we wrote something *approximate*, not that we *can't* write the real version.

None of these are permanent. The word "permanent" should be reserved for things like:
- **Karma/MeSDK**: The ragdoll physics SDK (`USkeletalMesh::LineCheck`'s ragdoll path) is a binary-only proprietary library. No source exists.
- **Not-exported symbols**: `FGenerationInfo::FGenerationInfo` and `FPackageFileSummary::FPackageFileSummary` aren't in Core.dll's export table, so Ghidra can't verify them by address. We can't claim `IMPL_MATCH`.

Everything else is just *unfinished work*, and `IMPL_TODO` is the honest label for that.

## What Changed

### `UnMesh.cpp` — 15 of 16 reclassified

The one entry that stays `IMPL_DIVERGE` is `USkeletalMesh::LineCheck`'s Karma ragdoll branch — the ragdoll collision check delegates to `MeXContactPoints`, which lives inside the MeSDK proprietary binary. That's truly permanent.

The other 15 became `IMPL_TODO`. Here are a few illustrative examples:

**`ULodMesh::Serialize`** was labelled diverge because it calls `FUN_103c7240` and friends — a cluster of TArray serialization helpers. Ghidra shows these exist and have decompilable bodies. They're just not written yet. That's `IMPL_TODO`.

**`UVertMesh::RenderPreProcess`** uses `DAT_1060b564` — a resource-ID counter inside the retail Engine.dll. Since we're rebuilding that DLL, we can define our own `static DWORD g_ResourceIdCounter`. Not permanent.

**`USkeletalMesh::PostLoad`** was almost fully implemented — `UObject::PostLoad()`, the LOD rebuild, the four `GenerateLodModel` calls. The only missing piece was a vtable call on the stream object at `this+0xF4` (a render-stream clear). That vtable layout isn't resolved yet, so `IMPL_TODO` is correct.

### `UnMeshInstance.cpp` — all 16 reclassified

Every single `IMPL_DIVERGE` here was temporary. The common themes:

- **`FUN_10438ce0` GPU-skinning transform**: Used in two separate functions (the direct skinning path and a per-vertex loop). Ghidra shows a large function exists at that address; it just hasn't been analysed yet.
- **Ghidra decompilation failure at `0x10439f40`**: The 10 KB `GetAnimFrame` function hit a Ghidra encoding error and didn't decompile. That's a tooling problem, not a permanent external constraint — it can be worked around with manual disassembly. `IMPL_TODO`.
- **Render pipelines** (`Render`, `GetFrame`, `GetMeshVerts`, `MeshBuildBounds`): All blocked by unresolved stream/transform helpers. Not permanent.

### `UnLinker.cpp` — 14 of 16 reclassified

The two that stay `IMPL_DIVERGE` are the trivial constructors (`FGenerationInfo` and `FPackageFileSummary`) — they're not individually exported from Core.dll, so they can't be verified by Ghidra address. That's a valid, permanent reason.

The 14 that became `IMPL_TODO` are all about implementation depth:

- `ULinkerLoad::ULinkerLoad` — retail (1741 bytes) checks `GObjLoaders` for duplicate linkers, handles UCC context, uses a complex internal package-file reader. Our version is a simplified working version. Temporary.
- `ULinkerLoad::FindExportIndex` — retail uses a 3-way hash combining class name, class package, and object name, with a `Mesh → LodMesh` compatibility fallback. We use a simpler ObjectName-only hash. Temporary.
- `ULinkerLoad::Destroy` — retail removes the linker from `GObjLoaders`. Our version doesn't. Temporary — we know *what* needs to be added.

One function also got a small correctness fix:

**`ULinkerLoad::DetachLazyLoader`** was logging with a guessed message. Ghidra's decompilation of `FUN_1012a860` shows the actual retail message:

```cpp
// Before (guessed):
GError->Logf( TEXT("Detached %i lazy loaders, expected 1"), RemovedCount );

// After (from Ghidra):
GError->Logf( TEXT("Detachment inconsistency: %i (%s)"), RemovedCount, *Filename );
```

Ghidra also shows the retail function logs the error *before* zeroing `SavedAr`/`SavedPos` (not after), so the field-zeroing order was corrected too.

## The Numbers

| File | Before | After | Stayed IMPL_DIVERGE |
|---|---|---|---|
| `UnMesh.cpp` | 16 | 1 | Karma/MeSDK |
| `UnMeshInstance.cpp` | 16 | 0 | — |
| `UnLinker.cpp` | 16 | 2 | Not-exported ctors |
| **Total** | **48** | **3** | |

45 labels corrected in one pass.

## Why This Matters

`IMPL_DIVERGE` is a strong claim. It says *"this function will never match retail, and we've documented why."* Overusing it hides real work behind a false permanence. When every partially-implemented function gets labelled `IMPL_DIVERGE`, you can't tell at a glance which functions are genuinely stuck and which are just waiting for someone to finish them.

`IMPL_TODO` is honest about the state of the work: *"we know what retail does here, we know roughly how to implement it, we just haven't done it yet."* That's useful information. It invites someone to pick it up.

The three remaining `IMPL_DIVERGE` entries — Karma, and the two unexported constructors — are genuinely permanent. Everything else is just a to-do list.
