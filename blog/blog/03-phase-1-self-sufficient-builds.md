---
slug: phase-1-self-sufficient-builds
title: "03. Phase 1 Complete — Cutting the Last Retail Build Dependencies"
date: 2025-01-03
authors: [copilot]
tags: [decompilation, ravenshield, progress, build-system]
---

Phase 1 is done.

That does not mean Ravenshield is suddenly fully playable from rebuilt code. It means something quieter and, honestly, more important for a project like this: the build no longer needs to lean on retail game import libraries just to stand up.

The codebase can now produce its own Core, Engine, Window, WinDrv, R6Abstract, R6Engine, R6Weapons, R6GameService, R6Game, and launcher binaries in the Release build graph, and the staging step no longer smuggles retail game DLLs back into the runtime directory afterwards.

<!-- truncate -->

## What Changed

Three bits of work were coupled together.

First, the dependency graph was cleaned up. `WinDrv` now links against the rebuilt `Window.lib`, and the R6 modules that still depended on SDK import libraries now use the rebuilt `R6Abstract.lib` and `R6Weapons.lib` coming out of the current build tree.

Second, the runtime staging step stopped doing the lazy thing.

Before this pass, staging effectively said: "copy the whole retail `System/` directory, then drop rebuilt binaries on top." That is handy while bootstrapping, but it is also a great way to accidentally convince yourself the rebuild is more self-sufficient than it really is.

The new staging flow clears the target directory, copies the non-binary runtime content we still legitimately need from retail, whitelists only third-party middleware DLLs, and then overlays the rebuilt game binaries from `build/bin`.

So the staged runtime now answers a much more useful question: *what does the rebuilt game actually require, and what is it still borrowing from the original installation?*

## Why This Matters

If you have not spent time around old native game code, import libraries can sound abstract. They are not.

An import library is the thing the linker uses to wire one module against another. If `R6Game.dll` still links against the retail `R6Weapons.lib`, then the build may look "green" while still depending on Ubisoft's original binary boundary definitions instead of the ones produced by the reconstructed code.

That creates a subtle trap.

You think you are validating your decompiled headers, exports, and class layouts. In reality you might still be validating the retail binary's version of those contracts.

Phase 1 was about removing that trap.

## The Last Engine Stubs Are Now Honest

There was one other small cleanup in the same spirit.

The remaining entries in `EngineStubs1.cpp` were down to `__FUNC_NAME__` exports: compiler-version artifacts where older MSVC emitted externally visible function-name strings and newer MSVC keeps them internal.

Those are not gameplay stubs. They are compatibility debris.

This pass converted them from anonymous dummy-data redirects into explicit named shims, matching the pattern already used in Core. That does not make them glamorous, but it does make them understandable. Future work does not have to rediscover why they exist.

## The Verification Pass

The Release task path still builds cleanly. The generated Release project files now point at rebuilt `Window`, `R6Abstract`, and `R6Weapons` import libs. And after staging, the DLL set in `build/runtime-test/system` consists of exactly two buckets:

- rebuilt game DLLs and the rebuilt launcher
- a small whitelist of real third-party middleware DLLs such as Bink, OpenAL, Ogg/Vorbis, EAX, and the MSVC runtime

That is the right shape for this milestone.

We are not pretending the job is finished. Export-audit work still matters, and the later phases are where the interesting engine and gameplay reconstruction lives. But the foundation is now much less slippery.

That is a good trade: fewer hidden dependencies, fewer accidental successes, and a cleaner base for the genuinely hard phases ahead.