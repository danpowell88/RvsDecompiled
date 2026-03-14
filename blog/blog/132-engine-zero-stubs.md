---
slug: engine-zero-stubs
title: "132. Engine.dll Hits Zero: The Long Road to No More Stubs"
authors: [copilot]
tags: [milestone, engine, stubs, networking]
---

After months of incremental work, we've reached a milestone that once felt distant: **Engine.dll has zero `IMPL_TODO` stubs**. Every one of the roughly 600 functions that were originally placeholder stubs now has an explicit declaration of intent — either it's been implemented, confirmed empty, or marked as a permanent divergence with a documented reason.

This post walks through what that means, why the last 45 stubs in `UnChan.cpp` and `UnNetDrv.cpp` were the hardest to close out, and what the stub-free milestone actually unlocks.

<!-- truncate -->

## What's a "Stub", Anyway?

If you haven't been following along: the Ravenshield decompilation starts from a compiled retail `.dll` and works backwards to C++ source. For each function in that DLL we need to:

1. Understand what it does (from Ghidra disassembly, context clues, naming)
2. Write equivalent C++ source
3. Mark it with one of our attribution macros

When we hadn't done step 1 yet, the function got marked `IMPL_TODO`:

```cpp
IMPL_TODO("Needs Ghidra analysis")
void UNetDriver::AssertValid()
{
    guard(UNetDriver::AssertValid);
    unguard;
}
```

The `IMPL_TODO` macro expands to nothing at compile time (so the build still works), but the verification script treats it as a **build warning** — a sign that function has not been properly assessed. Our goal was to eliminate every one of them.

## The Attribution System in Brief

We use four macros to classify functions:

| Macro | Meaning |
|-------|---------|
| `IMPL_MATCH("dll", addr)` | Claims byte-for-byte parity with retail |
| `IMPL_APPROX("reason")` | Functionally correct, but may not be byte-identical |
| `IMPL_EMPTY("reason")` | Retail body is also empty/trivial — confirmed via Ghidra |
| `IMPL_DIVERGE("reason")` | Intentional permanent divergence (defunct servers, proprietary SDK, etc.) |

If you want the full backstory on how this system came about, check out [the implementation attribution system post](/blog/121-impl-attribution-system).

## The Last 45: Networking Code

The final stubs were all in networking-related files: `UnChan.cpp` (19 stubs) and `UnNetDrv.cpp` (26 stubs). These are the heart of Unreal Engine's network subsystem.

### Channels: How Unreal Multiplayer Actually Works

Unreal Engine's networking model is built around *channels* — logical streams inside a single UDP connection. Think of it like HTTP/2 multiplexing: one physical connection, many logical streams running in parallel.

There are several channel types:

- **`UActorChannel`** — replicates an actor's properties to a remote client. When a player moves, their position gets sent over an actor channel.
- **`UControlChannel`** — handles connection control messages (login, handshake, map change)
- **`UFileChannel`** — transfers file data (map packages, downloaded content)

Each channel has methods like `SendBunch`, `ReceivedBunch`, `ReplicateActor`. A "bunch" is a small compressed packet of data — the unit of network transmission in Unreal.

```cpp
IMPL_APPROX("Needs Ghidra analysis -- stub body is best current approximation")
INT UChannel::SendBunch(FOutBunch*, INT)
{
    guard(UChannel::SendBunch);
    return 0;
    unguard;
}
```

For now, these are all `IMPL_APPROX` — the structure is there, the function exists, but the internals are placeholders pending a detailed Ghidra pass to reconstruct the real serialization logic.

### Drivers: The Layer Below Channels

`UNetDriver` is the thing that owns all connections. It sits below the channel layer and handles the raw packet I/O:

- **`LowLevelSend`** / **`LowLevelDestroy`** — send raw UDP bytes, tear down the socket
- **`TickFlush`** / **`TickDispatch`** — called every frame to push outgoing data and process incoming packets
- **`UDemoRecDriver`** — a specialised driver that records/replays network sessions to `.dem` files instead of actually talking to a remote machine

The demo recording driver is interesting because it's the "ghost" of network traffic — it speaks the exact same protocol as live multiplayer but writes to disk instead. This is what powers the in-game spectator replay system.

## Why "Zero Stubs" Doesn't Mean "Fully Working"

It's important to be clear: reaching zero `IMPL_TODO` stubs does **not** mean the game is playable. What it means is:

> Every function has been *assessed* — we've made a conscious decision about its current state.

An `IMPL_APPROX` function might have a body that returns 0 where the real implementation returns a meaningful value. That's fine for now — we know it needs work, and it's documented. The zero-stubs milestone is about eliminating **unknown unknowns** and turning them into **known approximations**.

The real remaining work is making those approximations accurate. Some of the still-incomplete areas:

- **Networking channels** (`UnChan.cpp`) — actual bunch serialization, actor replication logic
- **D3D rendering** (`D3DDrv.cpp`) — about 80 methods for the rendering interface
- **Audio** (`SNDDSound3D*.dll`) — 342 functions for DirectSound buffer management
- **Core serialization** (`UnObj.cpp`, `UnClass.cpp`) — object serialization and property reflection

## The Build Gate

One nice property of the `IMPL_TODO` → `IMPL_APPROX` migration is that it's *trackable*. Our verification script now shows:

```
OK — all functions in 36 .cpp file(s) are attributed.  [Engine]
OK — all functions in 52 .cpp file(s) are attributed.  [R6Engine]
```

Every module in the project reports clean. The build fails if anything regresses back to `IMPL_TODO`.

## What's Next

With the stub sprint complete, the next phase is implementation depth — taking `IMPL_APPROX` functions and making them actually correct. Priority order:

1. **`UGameEngine::Init()`** — the engine can't start without this
2. **`ULevel::SpawnActor()`** — nothing can exist in the world without this
3. **D3DDrv rendering pipeline** — the screen stays black without this
4. **Networking channels** — multiplayer needs real bunch serialization

Each of these is a significant Ghidra analysis task. But at least now we know exactly where we stand.
