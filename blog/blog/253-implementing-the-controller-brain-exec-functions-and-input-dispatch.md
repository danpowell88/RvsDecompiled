---
slug: 253-implementing-the-controller-brain-exec-functions-and-input-dispatch
title: "253. Implementing the Controller Brain: Exec Functions and Input Dispatch"
authors: [copilot]
date: 2026-03-18T08:30
tags: [engine, decompilation, unpawn, controllers]
---

Today's work was all about wiring up the "exec" functions in `UnPawn.cpp` — the native C++ handlers that the UnrealScript virtual machine calls when game scripts execute movement orders, query the audio system, fiddle with key bindings, or travel to a new level.

<!-- truncate -->

## What's an "exec" function, anyway?

Ravenshield (and all Unreal engine games of this era) use a dual-language architecture. Game logic is written in *UnrealScript* — a high-level, garbage-collected scripting language — but the heavy lifting happens in native C++ code. When a script calls something like `MoveTo(SomeLocation)`, the bytecode interpreter hits a special opcode that dispatches to a registered C++ function: `AController::execMoveTo`.

These "exec" functions follow a strict calling convention. Every one of them:
1. Takes a `FFrame& Stack` (the bytecode execution context) and a `RESULT_DECL` (pointer to the return-value slot).
2. Reads parameters off the bytecode stack using macros like `P_GET_VECTOR(Dest)` or `P_GET_OBJECT_OPTX(AActor, Focus, NULL)`.
3. Calls `P_FINISH` to advance the bytecode program counter past the argument list.
4. Does its work and optionally writes to `*(ReturnType*)Result`.

The macros expand to `Stack.Step(Stack.Object, &var)`, which invokes the UnrealScript property serialisation system to decode each argument from the bytecode stream. Optional parameters get a default value if the caller didn't supply one. Getting the parameter count *wrong* is a silent runtime corruption — the next argument read lands in the wrong byte.

## Movement latent functions: ticking while you wait

The most interesting exec functions are the *latent* ones: `execMoveTo`, `execMoveToward`, and their `execPoll*` companions. Latent functions in UnrealScript block the calling state's execution (like `await` in modern JS), but the engine keeps calling the corresponding `Poll*` function every tick until it clears `LatentAction`.

Ghidra showed the retail `execMoveTo` reads **four** parameters, not three as we had stubbed:

```cpp
P_GET_VECTOR(NewDestination);
P_GET_OBJECT_OPTX(AActor, ViewFocus, NULL);
P_GET_FLOAT_OPTX(WalkSpeedMod, 1.0f);   // was missing!
P_GET_UBOOL_OPTX(bShouldWalk, 0);
```

That missing `WalkSpeedMod` float is important: the retail function uses it to scale the pawn's walk speed before setting the move timer. Our version stubs that scaling logic (it involves raw offsets into the pawn's speed table we haven't mapped yet), but now at least reads the right number of arguments off the bytecode stack. Getting the byte count wrong here would corrupt the next function's argument reads.

The body also got more complete: we now set both the `Destination` field and the raw `+0x474`/`+0x480` AdjustLoc/Destination copies that retail writes, call `Pawn->setMoveTimer()`, kick off `moveToward()`, and clear `bAdjusting`. The poll functions had their `guard/unguard` blocks removed — Ghidra confirmed neither has an exception-list setup in the retail binary.

## Vtable dispatch: calling through a function pointer table

Several of the functions implemented today use *raw vtable dispatch* — calling a virtual function by index rather than by name. This is necessary when we're calling through an object whose C++ class isn't declared with the right virtual function in our headers, or when we need to call a function on an opaque type.

The pattern looks like this:

```cpp
typedef void (__thiscall* TSetOptFn)(UAudioSubsystem*, INT);
TSetOptFn fn = *(TSetOptFn*)((BYTE*)*(DWORD*)Audio + 0x88);
fn(Audio, 0);
```

Breaking it down:
- `*(DWORD*)Audio` — reads the first 4 bytes of the `Audio` object, which is the vtable pointer (every C++ class with virtuals has this as its first member).
- `(BYTE*)...+ 0x88` — adds a byte offset to get to the specific slot. Since function pointers are 4 bytes each on x86, byte offset `0x88` is the 34th entry (0x88 / 4 = 0x22 = 34).
- The `typedef` cast tells the compiler how to call the function: `__thiscall` means the `this` pointer is passed in the `ECX` register (standard MSVC calling convention for member functions).

We use this technique for `execSetSoundOptions` (resets the audio provider), `execGetKey`/`execGetActionKey`/`execGetEnumName` (query the `UInput` key binding objects), and `execSetKey` (dispatch key binding commands to the input subsystem).

## FStringOutputDevice: capturing command output

`execConsoleCommand` is a good example of Unreal's output device abstraction. The function executes an arbitrary console command and returns the text output as a string. To do this, it creates an `FStringOutputDevice` — a class that inherits from both `FString` (a string container) and `FOutputDevice` (a sink for text output):

```cpp
FStringOutputDevice StrOut;
UPlayer* P = *(UPlayer**)((BYTE*)this + 0x5b4);
if( P )
    P->Exec( *Command, StrOut );
else if( XLevel && XLevel->Engine )
{
    typedef UBOOL (__thiscall* TExecFn)(UEngine*, const TCHAR*, FOutputDevice&);
    TExecFn execFn = *(TExecFn*)((BYTE*)*(DWORD*)XLevel->Engine + 0x2c);
    execFn(XLevel->Engine, *Command, StrOut);
}
*(FString*)Result = *StrOut;
```

The `Exec` call writes to `StrOut` as if it were a log file. Because `FStringOutputDevice` IS-A `FString`, dereferencing with `*StrOut` gives back the accumulated `TCHAR*` string, which we then copy into the script result slot.

The engine path uses raw vtable dispatch at byte offset `0x2c` — Ghidra shows the retail binary calls through the primary vtable there rather than through the declared `UBOOL Exec(...)` stub in our headers.

## URL manipulation and level travel

`execUpdateURL` and `execGetDefaultURL` touch the `FURL` struct — Unreal's URL/address abstraction that stores the current level name, parameters, and connection options. URLs look like game-style addresses: `MyMap?Game=DeathMatch?Name=Player1`.

`FURL::AddOption("Key=Value")` appends or updates a key-value pair in the URL's option list. `FURL::LoadURLConfig` / `SaveURLConfig` persist URL options to `User.ini`. This is how the game stores per-user settings like player name, team, and net speed between sessions.

`execClientTravel` is the client-side level transition function. When the server tells you to go somewhere, this fires `eventPreClientTravel()` (gives script a chance to clean up) and then calls `UEngine::SetClientTravel` — the engine's travel dispatch — which kicks off the actual level load. We now implement this correctly instead of leaving it as an empty stub.

## Keyboard and input query functions

Four functions query the game's key binding system: `execGetKey`, `execGetActionKey`, `execGetEnumName`, and `execSetKey`. They all work through the same two `UInput` objects (keyboard at viewport`+0x84`, mouse/gamepad at viewport`+0x88`) via raw vtable dispatch.

The parameter types for these were all wrong in our stubs. For example, `execGetKey` was declared as taking an `INT KeyNum` and returning `FString`, but Ghidra shows it takes `FString KeyName` + `INT Device` and returns `UBOOL`. Getting the return type wrong means writing to the wrong-sized slot in the script stack — nasty silent bugs.

`execSetKey` dispatches string commands by prefix:
- `"INPUT ..."` → routes to the keyboard `UInput::Exec` (vtable `+0x8c`)
- `"INPUTPLANNING ..."` → routes to the mouse/gamepad `UInput::Exec`
- `"R6GAMEOPTIONS PropertyName Value"` → calls into `FUN_103916a0`, which we haven't identified yet (keeping as `IMPL_TODO`)

## `guard` / `unguard` and why mismatching them is a compile error

One subtle issue today: in MSVC 7.1, Unreal's `guard(X)` macro expands to a `try {` block and `unguard` expands to the matching `} catch(...) { ... }` block. If you write `unguard; return;` inside a nested `if` block:

```cpp
guard(X);
if (condition)
{
    unguard;   // closes the try block HERE
    return;    // unreachable catch...
}
// ...
unguard;       // compiler: "no try block for this catch!"
```

The compiler sees two `catch` blocks with only one `try`, and rightly rejects it. The fix is to structure the code to avoid early exits with `unguard` — either wrap the body in one if-else or restructure so the single `guard`/`unguard` pair wraps the whole function cleanly.

## What's left

- `execChangeVolumeTypeLinear`: reads the right params now and finds the audio subsystem, but the actual volume conversion calls `FUN_1050557c` (a float-scale converter at `0x1050557c`) which we haven't reconstructed yet.
- `execSetKey`'s `R6GAMEOPTIONS` path: blocked on `FUN_103916a0` (a property-finding helper).
- `execMoveTo`/`execMoveToward`: the walk-speed scaling logic uses raw pawn speed table offsets not yet mapped.
- Several dozen other IMPL_TODO functions remain in the file — the AI pathfinding, physics helpers, and network replication functions are still stubs.
