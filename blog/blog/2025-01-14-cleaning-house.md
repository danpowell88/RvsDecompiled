---
slug: cleaning-house
title: "Cleaning House — Removing 830 Lines of Debug Scaffolding"
authors: [rvs-team]
tags: [decompilation, ravenshield, progress, deep-dive]
---

The game boots. The Entry map loads. A player spawns. Karma physics ticks. The D3D8 renderer initializes. After weeks of debugging, poking at vtable slots, patching INT3 breakpoints into running code, and tracing every virtual method call through crash-prone cross-DLL boundaries — Phase 9 is done. But behind the scenes, `Launch.cpp` had become a war zone: 1,548 lines of diagnostic scaffolding wrapped around 700 lines of actual launcher code. Time to clean house.

<!-- truncate -->

## The Archaeology of Debugging

If you've ever inherited someone else's codebase and found `console.log("HERE 3 !!!")` scattered through the business logic, you know the feeling. Now imagine that, but with Win32 vectored exception handlers, INT3 breakpoint patches, and a custom crash logger that walks the EBP chain to dump 16 stack frames to a file.

That was `Launch.cpp` after the debugging phase. Every breakthrough left behind its tools:

```
Component                          Lines    Purpose
────────────────────────────────── ─────    ──────────────────────────────────
DiagWrite / DiagWriteW             30       Log to crash_diag.txt
CheckGModMgr                       15       Poll GModMgr for liveness
DiagVectoredHandler                150      Trap INT3 / log GPF with context
DiagExceptionFilter                50       Verbose unhandled exception dump
FFileManagerWindowsTraced          80       Traced file I/O wrappers
FConfigCacheIniTraced              200      Traced config API + vtable dumps
FArchive vtable probes             80       Module base + vtable slot scanner
CrashHandlers struct               100      OnTerminate / OnPurecall / OnInvalid
INT3 patch code                    40       VirtualProtect + byte patching
SEHHelper wrapper                  15       __try/__except around Engine->Init
DiagWrite breadcrumbs              90+      "→ reached InitSplash", etc.
────────────────────────────────── ─────
TOTAL removed                      ~830 lines
```

Every single one of these was essential at the time it was written. But now that the game boots cleanly, they're just noise — and *dangerous* noise, because anyone reading the code would have no idea which parts are "the real launcher" and which parts are temporary forensic tools.

## What Is Diagnostic Scaffolding?

If you're used to working with managed languages — JavaScript, C#, Python — you probably debug with breakpoints and a debugger UI. Step through the code, inspect variables, move on. But decompiling a 2003 C++ game engine that loads retail DLLs compiled with MSVC 7.1 into a process built with MSVC 2019 introduces a special kind of hell: **cross-CRT debugging**.

The problem: when the retail `Engine.dll` throws a C++ exception, it uses the MSVC 7.1 exception handling tables baked into its `.rdata` section. Our modern exe uses MSVC 2019's exception handling. If a `catch(...)` block in our code catches an exception thrown by the old DLL, the C runtime calls `std::terminate()` because the exception metadata is incompatible. Your debugger doesn't see this coming — the crash looks like a random abort deep inside `_CxxFrameHandler`.

So instead of `try/catch` and breakpoints, you end up writing things like this:

```cpp
// Patch the _purecall handler to INT3 so our VEH catches it
DWORD oldProt;
VirtualProtect(purecallAddr, 1, PAGE_EXECUTE_READWRITE, &oldProt);
*(BYTE*)purecallAddr = 0xCC;  // INT3
VirtualProtect(purecallAddr, 1, oldProt, &oldProt);
```

And you install a **Vectored Exception Handler** (VEH) — a Windows API that lets you intercept *all* exceptions before any stack unwinding happens. The VEH checks the exception code: is it an INT3 (your breakpoint)? An access violation? A stack overflow? Based on that, it dumps the register state, module addresses, and a manual EBP chain walk to a file. All this because the regular debugger can't handle mixed-CRT exceptions.

## The Heap Corruption Saga

The nastiest bug we found during the debug phase didn't crash immediately. It corrupted the heap silently and then crashed minutes later in completely unrelated code — the classic "use after free" where the "use" is in a different galaxy from the "free."

The culprit: `GetUserIni()` and `GetServerIni()` in the config system.

These are virtual methods in `FConfigCache` that Ravenshield's `Engine.dll` calls during startup. The engine passes an uninitialized `FString` on the stack as an output parameter. In the MSVC calling convention for struct returns, this looks like:

```
caller:
    sub  esp, 12          ; allocate stack space for FString (Data, Num, Max)
    push esp              ; push pointer to uninitialized memory as 'OutIni'
    call GetServerIni
```

The problem: `FString::operator=()` checks whether it needs to free the existing allocation before copying the new value. If `Data` is a non-null stale pointer (which it will be — it's uninitialized stack memory), the allocator tries to `Realloc(stale_pointer, newSize)`, which corrupts the heap.

The fix is deceptively simple:

```cpp
FString& GetServerIni(FString& OutIni)
{
    // Zero the raw memory before operator= touches it.
    appMemzero(&OutIni, sizeof(FString));
    OutIni = ServerIni;
    return OutIni;
}
```

One `appMemzero` call. That's it. But finding this bug required tracing heap corruption backwards through the allocator's freelist, correlating addresses with GModMgr's allocation pattern (its pointer happened to live at an address that, reinterpreted as an `FString::Data` field, pointed into the heap), and realising that the retail DLL's calling convention passes stack garbage.

This fix stays in the cleaned-up `FConfigCacheIniR6` class. Everything else goes.

## The Cleanup

The cleanup was surgical. The goal: remove every diagnostic tool while keeping every piece of real launcher functionality. Here's what the key areas looked like before and after.

### Before: FConfigCacheIniTraced (200 lines)

```cpp
class FConfigCacheIniTraced : public FConfigCacheIni {
    UBOOL GetString(const TCHAR* Section, const TCHAR* Key,
                    TCHAR* Value, INT Size, const TCHAR* Filename) {
        DiagWrite("GetString Section=[%ls] Key=[%ls] File=[%ls]",
                  Section, Key, Filename ? Filename : L"null");
        UBOOL r = FConfigCacheIni::GetString(Section, Key, Value, Size, Filename);
        DiagWrite("  -> result=%d val=[%ls]", r, Value);
        return r;
    }
    // ... 15 more traced overrides ...
    static FConfigCache* Factory() {
        auto* p = new FConfigCacheIniTraced();
        DiagWrite("Factory: created FConfigCacheIniTraced at %p", p);
        DiagWrite("  vtable: %p", *(void**)p);
        // ... 20 more lines dumping vtable slots ...
        return p;
    }
};
```

### After: FConfigCacheIniR6 (60 lines)

```cpp
class FConfigCacheIniR6 : public FConfigCacheIni {
    void InitUser(const TCHAR* Path, const TCHAR* Ini) { /* ... */ }
    void InitServer(const TCHAR* Ini) { /* ... */ }
    FString& GetUserIni(FString& OutIni) {
        appMemzero(&OutIni, sizeof(FString));  // prevent heap corruption
        OutIni = UserIni;
        return OutIni;
    }
    FString& GetServerIni(FString& OutIni) {
        appMemzero(&OutIni, sizeof(FString));
        OutIni = ServerIni;
        return OutIni;
    }
    // R6Reserved slots 23-33 for vtable compatibility
    static FConfigCache* Factory() { return new FConfigCacheIniR6(); }
};
```

Clean, readable, and the heap corruption fix is right there where you can see it.

### The Build System

Two compiler flags changed as a result of what we learned:

- **`/GS-`** — Disable stack cookies. MSVC 2019 injects `__security_cookie` checks into every function by default. But our code interacts with retail DLLs from 2003 that don't know about stack cookies, and the guard macros (`guard`/`unguard`) are disabled anyway. One less thing to go wrong.

- **`DO_GUARD=0`** — This was the `try/catch` nuclear option. Unreal Engine's `guard()`/`unguard()` macros expand to `try`/`catch(...)` blocks in every function. With cross-CRT exception handling being incompatible between MSVC 7.1 and 2019, these catch blocks cause `std::terminate()` when exceptions propagate from retail DLLs through our stack frames. Setting `DO_GUARD=0` makes them expand to plain braces — no C++ exception handling at all. Exceptions propagate through our frames as if they were plain C code.

## The Stub Audit

While we were tidying up, we also did a complete audit of every stub in the codebase. The headline number: **~3,930 stubs** across 18 modules.

But here's the thing — most of them are *correct by design*:

- **2,612 linker stubs** (`/alternatename` pragmas in EngineStubs1-4.cpp): These redirect `.def`-exported symbols to a `dummy_stub_func` function. They exist because our `.def` file lists every ordinal that the retail Engine.dll exports — and for the 2,612 symbols we haven't reconstructed yet, the linker needs *something* to point to. These are harmless: the actual implementations live in the retail DLLs, which the game loads at runtime. The stubs only exist to make the linker happy.

- **104 EXEC_STUB macros** (EngineExtra.cpp + UnEffects.cpp): These are UnrealScript native function stubs — the bridge between the bytecode interpreter and C++ code. Each one just calls `P_FINISH` (mark the script stack as consumed) and returns. They'll be reconstructed one by one in later phases as we rebuild gameplay logic.

- **409 sound system stubs** (SNDDSound3D + SNDext): The 3D sound wrappers are entirely empty because the sound DLLs are loaded dynamically and implement everything internally.

None of these are "bugs" or "missing code." They're architectural placeholders — scaffolding of a different kind than the debug code, and scaffolding that needs to stay.

## The Result

`Launch.cpp` went from 1,548 lines to 710 lines. The game boots identically — Entry map, Karma physics, D3D8 renderer, player spawned, viewport active. The code now reads like what it is: a game launcher, not a crash investigation toolkit.

```
Before:  1,548 lines  (diagnostic scaffolding + launcher)
After:     710 lines  (just launcher)
Removed:   838 lines  (100% diagnostic code)
```

The remaining TODOs in Launch.cpp are genuine forward work items — implementing console commands like `TakeFocus` and `EditActor` that need class member layouts we haven't reconstructed yet, and wiring up the log window once we sort out window class registration. These are the doors to future phases, not debris from past ones.

## What's Next

The house is clean. The game runs. The stub audit gives us a map of every remaining placeholder in the codebase — 3,930 pins on a very large map, but a map nonetheless.

Next up: turning those `EXEC_STUB` entries into real gameplay logic, implementing the `WLog` console window, and starting to tackle the 200+ R6Engine virtual overrides that make Ravenshield more than just "Unreal with different textures."

One `appMemzero` at a time.
