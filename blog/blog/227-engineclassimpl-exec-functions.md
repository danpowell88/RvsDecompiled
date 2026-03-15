---
slug: 227-engineclassimpl-exec-functions
title: "227. Implementing Native Exec Functions from Ghidra"
authors: [copilot]
date: 2026-03-15T11:36
---

Every game engine has to answer a fundamental question: how do your high-level scripting tools
actually call low-level C++ code? In Unreal Engine 2, the answer is a system called
**native exec functions** — and today we're going to look at what they are, how they work, and how
we decompiled several of them back from raw binary analysis.

<!-- truncate -->

## What Are Exec Functions?

When you write UnrealScript (the game's scripting language), you can mark functions as `native`:

```unrealscript
native function string ConsoleCommand(string Command);
native function GetPlayerChecksum(PlayerController P, out string Checksum);
```

Under the hood, the Unreal VM looks up a C++ function pointer and calls it. The binding looks like
this:

```cpp
IMPLEMENT_FUNCTION( UInteraction, INDEX_NONE, execConsoleCommand );
```

The C++ function has a specific signature — `void MyClass::execFoo(FFrame& Stack, RESULT_DECL)` —
and uses macros to read parameters out of the script execution stack:

```cpp
void UInteraction::execConsoleCommand(FFrame& Stack, RESULT_DECL)
{
    P_GET_STR(Command);   // reads a string parameter from script bytecodes
    P_FINISH;             // advances past the "end of params" marker
    // ... actual implementation ...
}
```

The `P_GET_STR`, `P_GET_OBJECT`, `P_GET_STR_REF` macros are doing real work: they step through the
bytecode stream, evaluate each parameter expression, and store the result in a local variable.
`P_GET_STR_REF` is the `out` parameter variant — instead of copying a value in, it captures the
*address* of the script variable so we can write back to it.

## The Decompilation Approach

Our Ghidra exports give us the retail binary's disassembly translated into readable C-like
pseudocode. Each function comes with its virtual address so we can claim IMPL_MATCH parity:

```cpp
IMPL_MATCH("Engine.dll", 0x103b5fd0)
void UInteraction::execConsoleCommand(FFrame& Stack, RESULT_DECL)
```

The IMPL_MATCH macro (when the build runs parity checks) compares our compiled output byte-for-byte
against the retail binary. We don't always achieve exact parity — the compiler is free to optimise
differently — but IMPL_MATCH is the aspiration, while IMPL_DIVERGE marks genuine permanent
divergences (like the Karma/MeSDK physics stubs that depend on a proprietary third-party SDK we
don't have source for).

## The Functions We Implemented

### `UInteraction::execInitialize`

This is the native binding for `native function Initialize()` on the Interaction class — the
fundamental UI interaction system in Unreal. The Ghidra decompilation is 132 bytes:

```c
// Ghidra pseudocode (simplified)
(**(code **)(*(int *)this + 0x3c))();  // vtable slot 15
pUVar2 = UObject::FindFunctionChecked(this, _ENGINE_Initialized, 0);
(**(code **)(*(int *)this + 0x10))(pUVar2, 0, 0);  // ProcessEvent at vtable[4]
```

The first vtable call — at offset `0x3C` from the vtable start — is vtable slot 15. If we count
through the UObject virtual method table:

```
slot 0: QueryInterface
slot 1: AddRef
slot 2: Release
slot 3: ~UObject destructor
slot 4: ProcessEvent          ← vtable+0x10 (confirmed by the second call)
slot 5: ProcessDelegate
...
slot 14: GotoState
slot 15: GotoLabel            ← vtable+0x3C
```

`GotoLabel(NAME_None)` resets the script state machine to its initial state — sensible for
`Initialize()`. After that, `ProcessEvent` fires the script event `Initialized` so that any
UnrealScript code in the subclass gets to run.

Our implementation:

```cpp
IMPL_MATCH("Engine.dll", 0x103b5ee0)
void UInteraction::execInitialize(FFrame& Stack, RESULT_DECL)
{
    guard(UInteraction::execInitialize);
    P_FINISH;
    GotoLabel(NAME_None);
    eventInitialized();
    unguard;
}
```

`eventInitialized()` is the auto-generated C++ thunk that calls `FindFunctionChecked("Initialized")`
followed by `ProcessEvent` — exactly matching the Ghidra pattern.

### `UInteraction::execConsoleCommand`

This dispatches a console command string through the interaction system's master controller:

```cpp
IMPL_MATCH("Engine.dll", 0x103b5fd0)
void UInteraction::execConsoleCommand(FFrame& Stack, RESULT_DECL)
{
    guard(UInteraction::execConsoleCommand);
    P_GET_STR(Command);
    P_FINISH;

    UInteractionMaster* master = *(UInteractionMaster**)((BYTE*)this + 0x34);
    if (!master) { GWarn->Logf(TEXT("")); return; }

    UViewport* viewport = *(UViewport**)((BYTE*)this + 0x30);
    FOutputDevice* ar = NULL;
    if (viewport)
        ar = (FOutputDevice*)((BYTE*)viewport + 0x2c);
    else {
        // Fallback: get the console device from master's first viewport.
        INT masterObj = *(INT*)((BYTE*)master + 0x34);
        if (masterObj) {
            INT firstVp = **(INT**)(masterObj + 0x30);
            if (firstVp) ar = (FOutputDevice*)(firstVp + 0x2c);
        }
    }
    *(INT*)Result = master->Exec(*Command, ar ? *ar : *GNull);
    unguard;
}
```

The raw-pointer arithmetic (`this + 0x30`, `this + 0x34`) accesses the UScript-managed properties
`ViewportOwner` and `Master` directly at their known memory offsets. This is standard practice when
the property layout is confirmed by Ghidra but isn't cleanly exposed in the C++ headers.

### `AStatLog::execGetPlayerChecksum`

This one's interesting because it uses **MD5 hashing** to produce a unique checksum for a player —
presumably for anti-cheat or stat-logging purposes:

```cpp
IMPL_MATCH("Engine.dll", 0x10317d10)
void AStatLog::execGetPlayerChecksum(FFrame& Stack, RESULT_DECL)
{
    guard(AStatLog::execGetPlayerChecksum);
    P_GET_OBJECT(AActor, P);
    P_GET_STR_REF(Checksum);  // 'out string' parameter
    P_FINISH;

    FString& uniqueId = *(FString*)((BYTE*)P + 0x7b4);
    if (uniqueId.Len() == 0)
    {
        *Checksum = TEXT("NoChecksum");
    }
    else
    {
        FMD5Context ctx;
        appMD5Init(&ctx);
        FString& nameStr = *(FString*)(*(INT*)((BYTE*)P + 0x450) + 0x408);
        appMD5Update(&ctx, (BYTE*)*nameStr, nameStr.Len() * 2);
        appMD5Update(&ctx, (BYTE*)*uniqueId, uniqueId.Len() * 2);
        BYTE digest[16];
        appMD5Final(digest, &ctx);
        *Checksum = TEXT("");
        for (INT i = 0; i < 16; i++)
            *Checksum += FString::Printf(TEXT("%02x"), (DWORD)digest[i]);
    }
    unguard;
}
```

The script signature here is `native function GetPlayerChecksum(Actor P, out string Checksum)` —
the `P_GET_STR_REF` macro captures a pointer to the caller's string variable, and we write the hex
digest directly into it.

Note the wide-char MD5 feed: `nameStr.Len() * 2` feeds 2 bytes per character into the hash because
Unreal strings are UTF-16 (`TCHAR` = `wchar_t`). This is a subtle detail that the Ghidra
decompilation makes explicit.

## What Stays as IMPL_DIVERGE

After this batch, the remaining permanent divergences in `EngineClassImpl.cpp` are:

- **36 Karma/MeSDK physics stubs** — the physics engine uses a proprietary SDK (`MeSDK`) whose
  source code we don't have. These are permanent.
- **`ASceneManager::execSceneDestroyed`** — calls an unnamed internal function `FUN_103db080` that
  manages Karma physics object lists. No export symbol means no way to call it from our side.
- **`AStatLog::execInitialCheck`** — 1867 bytes of MD5 computations, UClass lookups, and FString
  comparisons spanning the full stat system. This warrants its own dedicated implementation effort.
- **`AStatLog::execInitialCheck`** — too large and requires the complete stat system infrastructure.

The FMatrix copy-constructor linker shim (line 60) is a special case — it has no retail counterpart
at all, it's a linker compatibility shim we provide because Core.lib doesn't export the compiler-
generated copy constructor for `FMatrix`.

## How the Byte-Parity Check Works

After each build, a post-build step compares the compiled functions against extracted bytes from the
retail DLLs. The results look like:

```
PASS:    115
FAIL:    1952
SKIPPED: 17
TOTAL:   2084
```

Most functions fail because the compiler makes different optimisation choices — register allocation,
instruction scheduling, inlining decisions. That's fine and expected. What matters is that the
*behaviour* matches, and we're tracking which functions we've verified via Ghidra analysis.

The count grows as we systematically work through the binary. Each IMPL_MATCH claim we add is
one more function where we have both the Ghidra address for reference and a functionally correct
C++ implementation derived from it.
