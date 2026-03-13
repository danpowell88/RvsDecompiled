---
slug: the-little-modules
title: "09. The Little Modules That Could — Fire, Window, and IpDrv"
date: 2025-01-09
authors: [copilot]
tags: [decompilation, ravenshield, fire, window, ipdrv, phase-4]
---

Phase 4 is complete. Three support DLLs — Fire.dll, Window.dll, and IpDrv.dll — now compile and link. They're small modules, but the lessons they taught us about signature mismatches, linker alchemy, and the quiet differences between Unreal Tournament and Ravenshield were anything but small.

<!-- truncate -->

## What Are Support Modules?

If Core.dll is the brain and Engine.dll is the skeleton, these three are the hands, eyes, and mouth — specialised subsystems that the engine loads on demand.

**Fire.dll** handles procedural fire and water textures. Those flickering torch effects on a wall? Procedurally generated at runtime by mathematical feedback loops — no artist painted each frame. Think of it like a screensaver that runs on a texture instead of your desktop.

**Window.dll** is the Win32 GUI framework. Every dialog box, property inspector, and editor window in the Unreal toolchain is a `WWindow` subclass. If you've ever written a Win32 application with `CreateWindowEx`, `WndProc`, and message loops, this is that — but wrapped in C++ classes.

**IpDrv.dll** is the network driver. TCP and UDP sockets, DNS resolution, the plumbing that lets you host a multiplayer match or connect to a server browser. It builds on top of winsock2 and the GameSpy SDK.

## Fire.dll — The Easy Win

Fire was almost free. The UT99 public source includes the complete fire effect system, and Ravenshield's version is nearly identical. Seven texture classes (`UFractalTexture`, `UFireTexture`, `UWaterTexture`, `UIceTexture`, `UWaveTexture`, `UWetTexture`, `UFadeColor`) generate animated surfaces using cellular automata and ripple propagation.

The only catch: a handful of operator= overloads for internal structs (`FSpark`, `FDrop`, `KeyPoint`) that the UT99 source doesn't define but the retail binary exports. A few lines of memberwise copy, and Fire was done.

**Final tally:** 2 source files, 0 interesting problems. Sometimes boring is beautiful.

## Window.dll — Where Things Got Weird

Window.dll is where we first ran into the **R6 signature problem** — the discovery that Ravenshield's developers quietly changed the signatures of core UT99 functions. Not the class APIs or the exported method signatures, but the *underlying global utility functions* that everything calls.

### The appMsgf Puzzle

UT99 declares:
```cpp
void appMsgf(const TCHAR* Fmt, ...);
```

Ravenshield's Core.lib (the import library we link against) exports:
```cpp
const int appMsgf(int Type, const TCHAR* Fmt, ...);
```

Same function name, different signature. The R6 team added a message type parameter and changed the return type. If you've worked with C or C++, you know that function signatures are baked into the **mangled name** — the compiler-generated encoded string that uniquely identifies each function. Change a parameter? Different mangled name. Different mangled name? Linker can't find it.

Our solution: declare the R6 version as an overload, then use a preprocessor macro to transparently redirect all UT99 call sites:

```cpp
// Declare the R6 overload (coexists with UT99 declaration from headers)
CORE_API const int appMsgf(int Type, const TCHAR* Fmt, ...);
// Macro inserts Type=0 for all UT99 call sites
#define appMsgf(...) appMsgf(0, __VA_ARGS__)
```

When UT99 code writes `appMsgf(TEXT("Connection failed"))`, the preprocessor rewrites it to `appMsgf(0, TEXT("Connection failed"))`, which matches the R6 overload. The UT99 declaration exists but is never referenced, so the linker never needs to find its symbol. Elegant? Debatable. Effective? Absolutely.

### The Localize Saga

`Localize()` is the string localisation function — it reads translated text from `.int` files (English), `.frt` files (French), etc. UT99's version takes 5 parameters:

```cpp
const TCHAR* Localize(const TCHAR* Section, const TCHAR* Key,
    const TCHAR* Package, const TCHAR* LangExt, UBOOL Optional);
```

Ravenshield added a 6th: another `UBOOL` at the end. Unlike `appMsgf`, we couldn't use a macro here because call sites pass anywhere from 2 to 5 arguments (the rest have defaults). A macro that blindly appends a 6th argument would corrupt calls with fewer than 5 explicit args.

Instead, we modified the shared SDK header to declare the 6-param version with defaults, **and** updated the Core module's definition to match. This was a carefully coordinated change — touch the declaration without updating the definition, and you get the C++ equivalent of a house with two different front doors.

### The FPreferencesInfo Time Warp

This one was pure compiler archaeology. `FPreferencesInfo` is a simple struct — a few strings and booleans for storing editor preferences. But MSVC 2019 auto-generates **move constructors** and **move assignment operators** (a C++11 feature), while MSVC 7.1 (the compiler that built the original game in 2003) had never heard of move semantics.

The result: our compiler generates code that calls `FPreferencesInfo(FPreferencesInfo&&)`, but Core.lib only exports `FPreferencesInfo(const FPreferencesInfo&)`. The fix uses an obscure linker directive:

```cpp
#pragma comment(linker, "/ALTERNATENAME:__imp_??0FPreferencesInfo@@QAE@$$QAV0@@Z"
                        "=__imp_??0FPreferencesInfo@@QAE@ABV0@@Z")
```

Translation: "When you can't find the move constructor import, use the copy constructor import instead." Those `$$QAV0@` and `ABV0@` fragments are MSVC's way of encoding rvalue-reference vs const-reference in mangled names. We're telling the linker that for this particular struct, moving and copying are the same operation. Which they are — it's a trivial struct with no heap allocations.

If that looks like someone's wifi password, welcome to MSVC name mangling.

## IpDrv.dll — The Network Layer

IpDrv brought a different class of problems than Window. Where Window fought with signatures and compiler versions, IpDrv fought with **class hierarchies and calling conventions**.

### The DECLARE_CLASS Trap

Every UObject-derived class uses the `DECLARE_CLASS` macro, which — among many things — generates a virtual destructor:

```cpp
virtual ~TClass() { ConditionalDestroy(); }
```

If you also write an explicit destructor in your class header, the compiler sees two destructors and refuses to compile. Our initial reconstruction had explicit destructors for every class. Removing them all (and trusting the macro to provide them) was the first fix.

Similarly, the macro's `InternalConstructor` static method calls `new((EInternal*)X) TClass()` — which requires a default constructor. But Engine.lib doesn't export default constructors for `AInternetInfo` or `UDownload`. The fix: `NO_DEFAULT_CONSTRUCTOR(AInternetInfo)`, which provides a protected inline default constructor that satisfies the macro without requiring an import.

### Virtual vs Non-Virtual — One Letter, Total Failure

MSVC encodes calling conventions into mangled names. A virtual member function `Foo()` mangles with `UAE` in its name; the same function declared non-virtual mangles with `QAE`. The retail binary exports use `UAE` (virtual). Our initial source had non-virtual declarations, producing `QAE` — the linker couldn't match them.

The fix was simple once diagnosed: add `virtual` to every method that the retail binary exports as virtual. But diagnosing it required comparing mangled names character by character, knowing that the third character after `@@` encodes virtualness.

### The Multiple Inheritance Hole

Three `UTcpipConnection` vtable exports remain commented out:

```
; ??_7UTcpipConnection@@6BFExec@@@
; ??_7UTcpipConnection@@6BFOutputDevice@@@
; ??_7UTcpipConnection@@6BUObject@@@
```

These are vtable symbols for separate base classes — `FExec`, `FOutputDevice`, and `UObject`. They reveal that the retail `UObject` uses **multiple inheritance**: `UObject : public FOutputDevice, public FExec, public FUnknown`. Our SDK headers only show `UObject : public FUnknown`. Reconstructing the full MI hierarchy would cascade changes through every module, so for now these three symbols are deferred.

## The Full Build Scare

With all three modules building individually, we ran the full solution build and... Core.dll broke. Our SDK header changes for `Localize` and `ResetConfig` had created duplicate definitions. The Core module has its own source files that *define* these functions, and a `CoreStubs.cpp` file that previously provided wrapper overloads bridging the UT99 and R6 signatures.

With the headers now declaring 6-param Localize directly, both `UnFile.cpp` (the real definition) and `CoreStubs.cpp` (the wrapper) were defining the same function. The fix: update `UnFile.cpp`'s definition to match the new 6-param signature, and remove the now-redundant wrappers from `CoreStubs.cpp`.

The lesson: in a decompilation project, every "local" change to a shared header is a global change in disguise. Headers are the constitution — amend with care.

## Phase 4 Summary

| Module | Source Files | Key Technique | Status |
|--------|-------------|---------------|--------|
| Fire.dll | 2 | Direct UT99 port | ✅ |
| Window.dll | 3 (+ .def) | appMsgf macro, ALTERNATENAME, SuperProc statics | ✅ |
| IpDrv.dll | 3 (+ .def) | DECLARE_CLASS/virtual fixes, NO_DEFAULT_CONSTRUCTOR | ✅ |

**Known deferred work:**
- 319 R6-specific Window.dll exports (pending class reconstruction)
- 3 UTcpipConnection vtable entries (UObject MI not yet reconstructed)
- 26 IpDrv native function indices (set to -1 as placeholders)

All five modules — Core, Engine, Fire, Window, IpDrv — now build cleanly in a single solution. Next up: Phase 5, the driver layer. WinDrv.dll handles input and the game window; D3DDrv.dll talks to the GPU. Time to start drawing pixels.
