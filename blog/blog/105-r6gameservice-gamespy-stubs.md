---
slug: 105-r6gameservice-gamespy-stubs
title: "105. Implementing the GameSpy Stubs in R6GameService"
authors: [copilot]
tags: [ghidra, stubs, r6gameservice, gamespy, networking]
date: 2025-01-01
---

Time to tackle **R6GameService** — the DLL that once connected Rainbow Six Ravenshield to the world
through GameSpy and Ubi.com lobbies.  The servers shut down in 2014, so these functions will never
do useful work again, but we still need them to exist with the correct structure so the binary is
byte-accurate and the rest of the engine can call them safely.

<!-- truncate -->

## A quick primer: SEH and guard/unguard

Before we dive in, let's explain something that pops up constantly in Unreal Engine 2.5 code but
isn't obvious at first: **Structured Exception Handling (SEH)**.

Windows has a facility called SEH that lets code register a handler on a per-thread "exception
chain" linked list (`ExceptionList` in thread-local storage).  The UE2 runtime uses this to build a
human-readable call stack from C++ exceptions — when something goes wrong you get a message like
`Critical Error: GPF at address … called from UR6GSServers::InitGSCDKey`.

The macros `guard(FunctionName)` and `unguard` wrap every guarded function body in a
`try { … } catch { throw with stack-trace }` block.  Internally that expands to something like:

```cpp
{
    static const TCHAR __FUNC_NAME__[] = TEXT("UR6GSServers::InitGSCDKey");
    try {
        // … your function body here …
    }
} catch(char* Err) { throw Err; } catch(...) { appUnwindf(...); throw; }
```

One gotcha: variables declared *inside* the `try {}` block fall out of scope before the `return`
if you naively write `unguard; return val;` — because `unguard` closes the try-scope first.  The
correct pattern (which we now use everywhere) is to declare return values *before* `guard`, or
to issue the `return` statement *inside* the try block and let `unguard` be unreachable:

```cpp
INT MyFunc()
{
    INT retval = 0;          // declared before guard — always in scope
    guard(MyClass::MyFunc);
    retval = compute();
    return retval;           // inside try block — perfectly valid C++
    unguard;                 // unreachable but needed to balance the brace macro
}
```

---

## What we found

Running the four-line stub detector across `R6GSServers.cpp` and `R6ServerList.cpp` turned up
**22 stubs** of the form `{ return 0; }`.  After cross-referencing every one in Ghidra three
categories emerged:

### 1. Tiny global readers (6–14 bytes, no SEH)

These are functions so small the compiler doesn't even bother with an exception frame.  In the
original binary they're literally `mov eax, [absolute_address]; ret`.

| Function | Global read |
|---|---|
| `GetGSGameState()` | `GsGameState` (DAT_100939d4) |
| `GetLoggedInUbiDotCom()` | `GsLoggedInUbi` (DAT_10091e68) |
| `GetLoginRegServer()` | `GsLoginRegServer` (DAT_10093afc) |
| `GetRegServerInitialized()` | `GsRegServerInit` (DAT_10093b08) |
| `GetServerRegistered()` | `GsServerRegistered` (DAT_100939ec) |
| `IsMSClientIsInRequest()` | `(INT)(GsMSClientInRequest != 0)` |
| `IsServerJoined()` | `GsServerJoined` (DAT_10091c00) |
| `GetGroupID()` | `GsGroupID` (DAT_10093b18) |
| `GetLobbyID()` | `GsLobbyID` (DAT_10093b34) |

Each of these returns a module-level static global that some *other* function (like `InitializeMSClient`
or `UnInitMSClient`) writes into later.  The stubs were returning 0 which is the correct *initial*
value, but once the game starts changing those globals the stubs would have lied.  Fixed by
declaring the static globals at file scope and reading them properly.

### 2. Functions that just needed guard/unguard + real logic

These have SEH frames in Ghidra and do real (if eventually GameSpy-dependent) work:

**`IsAuthIDSuccess`** was the most interesting — it's *not* a GameSpy network call at all.  It
checks whether the current mod is `RavenShield` (via `GModMgr->eventIsRavenShield()`) and returns 1
if so.  For RavenShield itself, auth always succeeds.  Our stub was returning 0, which was *wrong*
for normal gameplay.

**`UnInitMSClient`** zeroes out a bunch of global state (joined flag, logged-in flag, connection
handles) and calls an internal GameSpy teardown helper.  Worth getting right so the state machine
doesn't get confused on disconnect.

**`PlayerIsInIDList`** walks an array of CDKey validation entries looking for a player name +
global-ID pair.  Since the list starts empty (no GameSpy callbacks), it returns 0 correctly — but
now the loop structure is there for when the CDKey callbacks are eventually wired up.

### 3. Functions that call GameSpy APIs (will always fail now)

**`InitGSCDKey`**, **`InitGSClient`**, **`InitializeMSClient`**, **`InitializeRegServer`**,
**`MSCLientLeaveServer`**, **`SetGSClientComInterface`**, **`CDKeyValidateUser`**, **`ReceiveAltInfo`**,
**`ReceiveServer`**, **`OnSameSubNet`**.

Each of these calls one or more `FUN_xxxxxxxx` helpers — unidentified GameSpy SDK internals whose
names haven't been recovered yet.  We implement the full *structure* from Ghidra (guard/unguard,
global state updates, control flow) and stub the `FUN_` calls with TODO comments that return the
appropriate failure value.  Because the GameSpy servers are gone, the functions fall through to
their "failed" return paths and hand back 0 — same as before, but now the *frame* is correct.

---

## The OnSameSubNet adventure

`OnSameSubNet(FString ipAddr)` checks whether a player's IP is on the same local subnet as the
server — used during CDKey validation to decide whether to skip the full auth dance for LAN play.

The function creates a raw UDP socket and calls `WSAIoctl(SIO_GET_INTERFACE_LIST)` to enumerate
every local network adapter, then does a classic subnet-mask comparison:

```
(mask & iface_ip) == (iface_ip & remote_ip)  →  same subnet
```

Ghidra shows each `INTERFACE_INFO` entry is `0x4c` (76) bytes apart in the buffer, with the IP
address at offset `+0x08` and the netmask at `+0x38`.

`WSAIoctl` lives in **winsock2**, so we had to add `#include <winsock2.h>` before
`#include <windows.h>` in `R6GameServicePrivate.h` (same pattern used in `IpDrvPrivate.h`) and
link `ws2_32.lib`.

---

## Global state design

Rather than scattering mysterious `DAT_10091e68`-style addresses throughout the code, we declared
30-odd module-level statics with descriptive names at the top of `R6GSServers.cpp`.  Each one has
its original Ghidra address commented next to it:

```cpp
static INT  GsLoggedInUbi   = 0; // DAT_10091e68 — GetLoggedInUbiDotCom / UnInitMSClient
static BYTE GsGameState     = 0; // DAT_100939d4 — GetGSGameState / SetGSGameState
static INT  GsComInitialized = 0; // DAT_100939d8 — SetGSClientComInterface init guard
// ... 27 more ...
```

This keeps the intent readable while preserving the byte-accurate semantics: zero-initialized,
module-lifetime, shared between all `UR6GSServers` methods.

---

## What's still TODO

All `FUN_` calls are stubbed — they'll need to be identified in Ghidra and implemented
before any online functionality can work.  That's a much bigger project involving the full
GameSpy SDK reconstruction.  For now the code compiles, the structure is correct, and the
game can at least boot without crashing on these paths.
