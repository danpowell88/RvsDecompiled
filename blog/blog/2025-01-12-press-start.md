---
slug: press-start
title: "Press Start — Launching the Engine"
authors: [rvs-team]
tags: [decompilation, ravenshield, launcher, winmain, safedisc, phase-8]
---

Every game you've ever played has a moment you never see — the few hundred milliseconds between double-clicking the icon and anything appearing on screen. During that sliver of time, an enormous amount of machinery spins up: memory allocators, log files, configuration systems, windowing frameworks, the engine object itself. Phase 8 rebuilds that invisible moment: `RavenShield.exe`, the 400-line launcher that kicks everything into motion.

<!-- truncate -->

## What Does a Launcher Actually Do?

If you've worked on web applications, you're used to a framework handling startup for you. Express calls your route handlers. Spring boots your beans. The runtime takes care of the boring stuff.

Game engines from the early 2000s don't have that luxury. There's no container, no dependency injection, no "just deploy it." The first thing that runs is a raw `WinMain` — the Windows equivalent of `main()` — and from there it's your responsibility to create every subsystem the game needs, in the right order, handling every failure mode yourself.

Here's the high-level sequence:

```
WinMain()
  ├─ Parse command line
  ├─ Check for already-running instance
  ├─ appInit() ── memory, logging, file I/O, config
  ├─ InitSplash() ── show the logo bitmap
  ├─ InitWindowing() ── Window.dll's WndClass setup
  ├─ Create WLog window ── the in-game console
  ├─ InitEngine() ── create and init UGameEngine
  ├─ ExitSplash() ── hide the logo
  └─ MainLoop() ── tick engine + pump Windows messages
       ├─ Engine->Tick(DeltaTime)
       ├─ GWindowManager->Tick(DeltaTime)
       ├─ Enforce max tick rate
       └─ PeekMessage / TranslateMessage / DispatchMessage
```

That's the entire game, soup to nuts. When `MainLoop` returns, the process exits.

## The SafeDisc Problem

Every previous phase had *something* we could feed to Ghidra — a DLL with clear exports, recognizable vtable patterns, maybe even debug symbols in the import table. Phase 8 had none of that, because the retail `RavenShield.exe` is wrapped in **SafeDisc v2 copy protection**.

SafeDisc is (was — it's long defunct) a DRM system that encrypts the game's executable on disc. When you run it, a tiny unprotected stub runs first: it validates the original CD, decrypts the real game code into memory, rebuilds the import table, and jumps to the actual entry point. From Ghidra's perspective, the `.text` section of `RavenShield.exe` is compressed garbage — over a thousand lines of XOR loops, TEA cipher blocks, and PE section manipulation.

So how do you decompile something you can't even disassemble?

### Reading the Import Table

You can't see the *code*, but you can see the *imports*. The SafeDisc wrapper still needs to resolve the game's DLL dependencies after decryption, so the original import table is preserved (it has to be — Windows needs it). By running `dumpbin /imports` on the retail exe, we get a treasure map:

| DLL | Import Count | What It Tells Us |
|-----|-------------|-------------------|
| Core.dll | 83 functions | Memory init (`appInit`), globals (`GIsClient`, `GIsEditor`), string ops, config API |
| Engine.dll | 10 symbols | `g_pEngine`, `GEngineStats`, `UGameEngine::StaticClass`, `UEngine::StaticClass` |
| Window.dll | 40+ symbols | `WLog`, `InitWindowing`, `GLogWindow`, `WConfigProperties`, `WObjectProperties` |
| User32.dll | Window creation | `CreateDialogW`, `PeekMessageW`, `DispatchMessageW`, `ShowWindow` |
| Kernel32.dll | System | `CreateMutex`, `GetCommandLine`, `ExitProcess` |
| Shell32.dll | Paths | `SHGetSpecialFolderPathW` |
| COMDLG32.dll | Dialogs | First-run configuration |

From these imports, we can reconstruct what the launcher *must* be doing — it's creating a game engine, showing a log window, running a message pump. The exact code is unknown, but the structure is deterministic.

### The UT99 Reference

Unreal Engine launchers follow a well-established pattern that Tim Sweeney established in the original Unreal/UT99 codebase. The UT99 public source includes `Launch.cpp` and `UnEngineWin.h`, which together implement the exact sequence described above. Ravenshield is built on the same engine (Unreal Engine 2.x), so its launcher follows the same pattern with R6-specific additions.

This is a recurring theme in decompilation work: even without source code, knowing the *framework conventions* gets you 80% of the way there.

## The Allocator Bootstrap Problem

Here's something that tripped us up: `FMallocWindows`.

The Unreal Engine uses a custom memory allocator everywhere — `GMalloc` points to an `FMalloc`-derived object that replaces `new` and `delete` globally. The launcher instantiates `FMallocWindows` (a pooling allocator that uses `VirtualAlloc` for large blocks and a freelist for small ones) and passes it to `appInit()` before any other engine code runs.

The catch: the R6 SDK's `FMallocWindows.h` has the `Malloc()`, `Realloc()`, and `Free()` method bodies **commented out**. The declarations are there, but the implementations are wrapped in `/* */` blocks. In our reconstructed `Core.dll`, those method bodies live in `UnMem.cpp` — but `FMallocWindows` isn't exported from Core.dll. The class is instantiated locally by whoever calls `appInit()`.

The UT99 version of the same header has all methods inline. Our fix: a local `FMallocWindows.h` shim in the launcher module that redirects to the UT99 version where everything is self-contained.

## GTimestamp: The Missing Global

`appSeconds()` — the function that tells you what time it is — is an inline function defined in `UnVcWin32.h`. On CPUs that support the RDTSC instruction (all of them, since the Pentium), it reads the CPU's timestamp counter directly, which is much faster than calling `QueryPerformanceCounter`. The function checks a global flag called `GTimestamp` to decide whether RDTSC is available.

Here's the fun part: `GTimestamp` is declared as `extern CORE_API UBOOL GTimestamp` (meaning "this symbol is exported from Core.dll"), but the retail `Core.dll` **doesn't export it**. We verified this with `dumpbin /exports` — the symbol simply isn't there.

This means the retail `RavenShield.exe` must provide `GTimestamp` storage locally. Since the launcher is the one calling `appSeconds()` most frequently (once per frame in the main loop), it makes sense — the inline function expands into the calling module, so the global needs to be defined there.

We define it as `TRUE` — every CPU from 1993 onwards supports RDTSC.

## The Virtual/Non-Virtual Show Problem

Here's a linker puzzle that perfectly illustrates the archaeology of decompilation work.

The UT99 `Window.h` declares `WWindow::Show(int)` as a **non-virtual** method. In C++ name mangling terms, that's `?Show@WWindow@@QAEXH@Z` (the `Q` means public non-virtual).

The R6 `Window.dll` exports it as `?Show@WWindow@@UAEXH@Z` (the `U` means public **virtual**).

Same function. Same parameters. Different linkage. When our launcher calls `GLogWindow->Show(1)`, the compiler generates a call to the non-virtual version (because that's what the header says), but the import library only has the virtual version. Linker error.

The fix is a single pragma:
```cpp
#pragma comment(linker,
  "/ALTERNATENAME:__imp_?Show@WWindow@@QAEXH@Z"
  "=__imp_?Show@WWindow@@UAEXH@Z")
```

This tells the linker: "when you see a request for the non-virtual `Show`, redirect it to the virtual `Show`." The calling convention and parameters are identical — the only difference is whether the call goes through the vtable or not, and since we're importing across a DLL boundary, it's a direct call to the exported symbol either way.

## What's Left Stubbed

The launcher compiles and links, but several pieces are intentionally stubbed pending Phase 8C (the audit pass that fills in method bodies across all modules):

- **`Engine->Init()`** — This is a virtual method call. Getting it right requires knowing the exact vtable slot ordering for `UEngine`/`UGameEngine`, which depends on the complete virtual method declaration order across the entire inheritance chain. Wrong slot = calling the wrong function = crash.

- **`Engine->Tick(DeltaTime)`** — Same vtable issue. The main loop currently ticks `GWindowManager` (window events) but not the engine itself.

- **`Engine->GetMaxTickRate()`** — Uses a placeholder value of 60fps instead of reading from the engine config.

- **FExecHook command handlers** — `TakeFocus`, `EditActor`, and `Preferences` require accessing `UEngine::Client` (a member at an unknown offset in our stub class) and `AActor::Location`/`bDeleteMe` (same problem).

These stubs are the consistent pattern across the project: get the signatures right, get the exports right, get the module building and linking, then fill in the actual logic when we have enough class layout information to do it safely.

## The RavenShield.exe Export Table

The retail exe exports exactly 3 symbols:

| Export | Type | Purpose |
|--------|------|---------|
| `GPackage` | `TCHAR[64]` | Package name — `"Launch"` — used by the localization system |
| Ordinal 1 | `HINSTANCE` | The exe's instance handle, shared with DLLs |
| `entry` | function | The SafeDisc wrapper entry point (not the real WinMain) |

Our reconstructed version exports `GPackage` via `__declspec(dllexport)`. The `hInstance` storage is provided as a regular global (the SDK headers already declare it as `extern`). There's no SafeDisc wrapper, so our entry point is just `WinMain`.

## Building It

With Phase 8 complete, the full build output now includes an executable:

```
Core.dll           ✓
Engine.dll         ✓
Window.dll         ✓
WinDrv.dll         ✓
D3DDrv.dll         ✓
Fire.dll           ✓
IpDrv.dll          ✓
R6Abstract.dll     ✓
R6Engine.dll       ✓
R6Game.dll         ✓
R6GameService.dll  ✓
R6Weapons.dll      ✓
DareAudio*.dll     ✓ (×3)
RavenShield.exe    ✓  ← NEW
```

That's every module in the game. From Phase 1's empty CMake skeleton to a complete set of binaries — 15 build artifacts, all compiling and linking from reconstructed source. The method bodies are mostly stubs, and the exe can't actually boot the game yet (that's what Phase 8B and 8C are for), but the entire dependency graph is now closed.

The next step is Phase 8B: reconstructing the D3DDrv render loop so we can actually see pixels on screen. But that's a story for another post.
