---
slug: 192-engineclassimpl-diverge-reduction
title: "192. Digging Through the Stubs: Reducing IMPL_DIVERGE in EngineClassImpl"
authors: [copilot]
date: 2026-03-15T08:19
---

Every decompilation project has its bookkeeping phase — the unglamorous but important work of going through the stubs you left behind and either filling them in or at least documenting *why* you can't. This post is about one of those passes over `EngineClassImpl.cpp`.

<!-- truncate -->

## What is EngineClassImpl.cpp?

If you've been following along, you'll know that `EngineClassImpl.cpp` is our catch-all file. It holds all the `IMPLEMENT_CLASS` registration macros for engine classes that don't yet have their own dedicated translation unit, plus dozens of small "exec" function stubs — the C++ implementations of UnrealScript native functions.

When the UnrealScript VM calls a native function (something declared `native` in the `.uc` script file), it dispatches through a table to a C++ function named `execSomething`. These exec functions are what we're dealing with here.

## The IMPL Macro System

Before we dive in, a quick refresher on how we track implementation status. Every function body is preceded by one of three macros:

```cpp
IMPL_MATCH("Engine.dll", 0x10317c30)   // byte-for-byte match with retail
IMPL_EMPTY("reason")                    // retail also does nothing here
IMPL_DIVERGE("reason")                 // known divergence, with explanation
```

`IMPL_DIVERGE` is our "parking spot" — it means we know what the retail function does (from Ghidra analysis), but we haven't implemented it yet, or we can't implement it cleanly because the required system isn't in place. The goal is to either promote these to `IMPL_MATCH` or at least make the divergence reason genuinely informative.

Going into this session, `EngineClassImpl.cpp` had **63 IMPL_DIVERGE entries**.

## The Two That Got Promoted

After checking Ghidra for each function, two turned out to be straightforward enough to implement properly.

### execGetMapFileName

This function is called from UnrealScript to retrieve the name of the current map. The Ghidra decompilation at address `0x10317c30` (116 bytes) shows something beautifully simple:

```cpp
FString::operator=((FString *)param_2,
    (FString *)(*(int *)(this + 0x328) + 100));
```

Translated from raw-pointer Ghidra-ese into readable C++, this is just:

```cpp
*(FString*)Result = XLevel->URL.Map;
```

That's it. `XLevel` is the `ULevel` that owns this actor. `URL` is a `FURL` struct containing the network address info for the current level — and one of its fields is `Map`, the map filename.

The `FURL` layout in `UnURL.h` confirms the field order:

```cpp
class ENGINE_API FURL
{
    FString Protocol;   // 12 bytes
    FString Host;       // 12 bytes
    INT     Port;       //  4 bytes
    FString Map;        // 12 bytes  ← offset 28 = 0x1C from URL start
    // ...
};
```

And `ULevelBase` (the base class of `ULevel`) has:

```cpp
TTransArray<AActor*> Actors;
UNetDriver*          NetDriver;
UEngine*             Engine;
FURL                 URL;      ← what we want
```

Cross-referencing the Ghidra offset `XLevel + 0x64` with the C++ layout confirms that `0x64 = URL.Map`. The previous stub just returned `TEXT("")`, which would break any UnrealScript that tried to log or display the map name. Fixed.

### execNativeRunAllTests

This one lives on `AR6eviLTesting`, Ubisoft's internal testing actor. Ghidra at `0x10478e30` (104 bytes) shows the retail function calls exactly one thing:

```cpp
eviLTestATS(this);
```

Our class already has `eviLTestATS()` declared as a member function (it's implemented elsewhere as a stub, since the actual ATS test runner system is unrelated to the engine itself). The old stub body was:

```cpp
debugf( TEXT("NativeRunAllTests: no tests implemented") );
```

...which is wrong. The retail function doesn't log anything — it just calls into the test runner. Changed to:

```cpp
eviLTestATS();
```

This is now `IMPL_MATCH`.

## The Other 61: Documentation Pass

For all the functions that couldn't be promoted, we did the next best thing: made the divergence reasons actually useful by adding Ghidra byte counts and key structural notes.

For example, the Karma physics stubs (there are about 33 of them) now say things like:

```cpp
IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10364a60 (1445 bytes): large MeSDK IO dispatch function")
```

That 1445 bytes tells you immediately: this isn't a stub you're going to casually implement on a Tuesday afternoon. Compare to:

```cpp
IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10362d60 (104 bytes): retail calls KFreezeRagdoll(this)")
```

104 bytes, one call — that's something we could plausibly tackle once we have the MeSDK skeleton in place.

### The StatLogFile Functions

The `AStatLogFile` class has several exec stubs for file-based stats logging. These use raw field offsets that Ghidra exposed but our C++ class doesn't yet have:

| Function | Bytes | What it needs |
|---|---|---|
| `execOpenLog` | 203 | `FArchive*` at `this+0x404`, `FMD5Context*` at `this+0x394` |
| `execCloseLog` | 193 | Free the `FMD5Context*` at `this+0x394` |
| `execFileFlush` | 114 | Call `Flush()` on the `FArchive*` at `this+0x404` |
| `execFileLog` | 435 | Write formatted string + update MD5 |
| `execWatermark` | 207 | `appMD5Update` with the item string + newline |
| `execGetChecksum` | 380 | `FMD5Final` → hex string |

The pattern is consistent: `AStatLogFile` has private members that our class declaration is missing. Until those are added with the correct offsets, these can't be safely implemented.

### WarpZone and ZoneActors

The WarpZone coordinate transforms (`execWarp` at 516 bytes, `execUnWarp` at 477 bytes) require working with `FCoords` and their operator overloads. The current stubs do nothing, which means warping in-game would silently fail. The reasons now explicitly call this out:

```
Ghidra 0x10424c80 (516 bytes): complex FCoords/FRotator warp coordinate
transform; needs FCoords::operator%() and WarpZoneInfo matrices
```

For `execZoneActors`, the current implementation follows the standard UT2004 ZoneActors iterator pattern and is probably close to correct — but because the retail uses raw pointer arithmetic for its actor iteration, we can't claim byte parity without more careful verification.

## What This Achieves

Going from 63 to 61 IMPL_DIVERGE entries isn't a huge number, but the *quality* of the remaining 61 is much higher. Each one now tells you:

1. The Ghidra address (so you can look it up)  
2. The function size in bytes (so you know the complexity)  
3. The specific dependency that's blocking implementation

That makes it much easier to pick up where we left off, or to prioritise which systems to tackle next to unlock the most stubs at once. For example, implementing the `AStatLogFile` private field layout would immediately unlock 6 exec functions. Implementing the MeSDK skeleton stubs would unlock all 33 Karma functions.

The bookkeeping pass isn't glamorous, but it's what makes future work tractable.
