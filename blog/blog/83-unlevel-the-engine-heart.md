---
slug: unlevel-the-engine-heart
title: "83. ULevel: The Heart of the Game World"
authors: [dan]
date: 2026-03-14T01:15
tags: [engine, decompilation, cpp, unlevel, collision, networking]
---

If there's one class in Unreal Engine that does *everything*, it's `ULevel`. This session we tackled all 36 stub functions in `UnLevel.cpp` — from collision hashing to actor lifecycle management to network replication. Let's talk about what `ULevel` actually is and what we had to reconstruct.

<!-- truncate -->

## What is `ULevel`?

In Unreal Engine 2, a *level* is more than just a map file — it's the runtime container for the entire game world. `ULevel` holds:

- The **actor array** (`Actors`) — every entity in the world
- The **model** (`UModel`) — the BSP geometry defining rooms and walls
- A **collision hash** (`FCollisionHashBase`) — a spatial acceleration structure for fast overlap tests
- **Network drivers** (`UNetDriver`, `UNetConnection`) — the plumbing for multiplayer
- **Time** (`TimeSeconds`) — the game clock
- Links to the **engine**, **client**, and **demo recorder**

Almost everything the game does every frame flows through `ULevel`. Tick, spawn, destroy, move, collide, replicate — all of it.

## The Collision Hash

The `SetActorCollision` function is a great example of how the engine toggles its spatial index on and off. The hash is stored at a fixed offset (`this + 0xF0`). Turning collision *off* means:

1. For every actor that has `bCollideActors` set (flag bit `0x800` at actor offset `+0xA8`), remove it from the hash
2. If we're in the editor, clear each actor's internal overlap list (an `FArray` at `+0x338`)
3. Delete the hash object

Turning it back *on* means:

1. Allocate a new hash via `GNewCollisionHash()` (defined in `UnCamera.cpp` — not in any header, hence the `extern` declaration at the top of the file)
2. Walk every actor and add the collidable ones

```cpp
FCollisionHashBase* nh = GNewCollisionHash();
*(FCollisionHashBase**)((BYTE*)this + 0xf0) = nh;
for ( INT i = 0; i < Actors.Num(); i++ )
{
    AActor* a = Actors(i);
    if ( a && (*(DWORD*)((BYTE*)a + 0xa8) & 0x800) )
        nh->AddActor(a);
}
```

`FCollisionHashBase` is a pure-virtual interface: `AddActor` and `RemoveActor` are vtable slots 2 and 3 (offsets `+0x8` and `+0xC`). We can call them as normal virtual methods because the class definition is in scope.

## `ReconcileActors`: Syncing the Editor's World View

This function only runs in the editor. Its job is to make sure every viewport has a camera actor, and every camera actor has a viewport — and to clean up orphans.

It runs in four passes:

1. **Clear** all `PlayerController::viewport` back-pointers so we can rebuild them cleanly
2. **Match** existing `ACamera` actors to viewports by comparing the camera's tag name against the viewport's object name (using raw offsets since we don't have typed access to all fields)
3. **Spawn** new camera actors for any viewports that still lack one
4. **Sync** camera properties from viewport to actor, or **destroy** cameras whose viewport no longer exists

Pass 2 uses a pointer assignment that needed careful handling on 32-bit Windows — storing a pointer as a `DWORD`:

```cpp
*(DWORD*)(vp + 0x34)        = (DWORD)(size_t)a;
*(DWORD*)((BYTE*)a + 0x5b4) = (DWORD)(size_t)vp;
```

The `size_t` cast is the portable way to say "this pointer fits in the integer type I'm storing it in." On the 32-bit build this project targets, both are 4 bytes.

## The `guard`/`unguard` Macro Trap

This is the most interesting bug of the session, and it's subtle enough to deserve its own section.

Unreal Engine wraps almost every function body with `guard`/`unguard` macros that provide call-stack unwind information when an exception occurs. In release builds they expand like this:

```cpp
guard(FuncName)
// → { static const TCHAR __FUNC_NAME__[] = TEXT("FuncName"); try {

unguard
// → } catch (TCHAR* Err) { throw Err; }
//   catch (...) { appUnwindf(TEXT("%s"), __FUNC_NAME__); throw; } }
```

Notice the braces. `guard` opens **two** scopes: an outer `{` and a `try {`. `unguard` closes the try with `}`, then closes the outer block with a final `}`.

The problem? If you write:

```cpp
guard(Foo);
ALevelInfo* info = GetLevelInfo();
if (!info) { unguard; return; }   // ← WRONG
// ... use info ...
unguard;
```

The `unguard` inside the `if` body closes **both** the try block and the outer `{` block. Every variable declared after `guard(Foo)` — including `info` — is now out of scope. The compiler rightly complains that `info` is undeclared when you reference it later.

The fix is simple: just use a plain `return` inside the guard body. The try block handles exceptions; normal control flow can exit the try without any special ceremony.

```cpp
guard(Foo);
ALevelInfo* info = GetLevelInfo();
if (!info) return;   // ← CORRECT: just exit the try block normally
// ... use info ...
unguard;
```

This caught us out in `DetailChange` and `UpdateTerrainArrays`. Both had early-return guards that were prematurely closing scope.

## `IsA` and Private Static Classes

Every UObject subclass generated by the `DECLARE_CLASS` macro has a `PrivateStaticClass` member — but true to its name, it's *private*. Code that writes `&APawn::PrivateStaticClass` doesn't compile.

The correct idiom is the public static accessor:

```cpp
actor->IsA(APawn::StaticClass())
```

`StaticClass()` returns a pointer to the same `UClass` object, but through the public API. We had to fix this across several `IsA` calls in `ReconcileActors`, `TickNetClient`, `UpdateTerrainArrays`, and a few others.

## `UObject::Modify()` Takes No Arguments

The `ULevel::Modify(INT DoTransArrays)` function takes a parameter, but when it calls the base class method it should be:

```cpp
UObject::Modify();   // no argument
```

`UObject::Modify()` is declared with no parameters — the argument is only meaningful at the ULevel layer for deciding whether to dirty the undo buffer. Easy to miss when you're reading decompiled output that infers argument passing from the call site.

## Commit and What's TODO

After fixing all these issues, the Engine DLL compiled cleanly. The commit message tells the story:

```
Engine: implement UnRenderUtil.cpp stubs and fix UnLevel.cpp compile errors

- Fix UModel::Modify() call to pass DoTransArrays argument
- Fix 'if (!x) { unguard; return; }' anti-pattern
- Fix PrivateStaticClass access: use StaticClass() instead
```

A lot of the ULevel functions still have `/* TODO */` bodies — `Tick`, `MoveActor`, `SpawnActor`, `DestroyActor` and the whole collision/movement system are complex enough to deserve their own sessions. But the skeleton is in place, the types are right, and it all links. That's a solid foundation.

Next up: filling in those TODO functions one system at a time.
