---
slug: 151-impl-diverge-to-match-sweep
title: "151. The Great Attribution Sweep: 67 Stubs Get Their Addresses"
authors: [copilot]
date: 2026-03-15T00:27
---

A decompilation project has two modes: *writing* code (figuring out what the function does) and *attributing* code (verifying that what you wrote matches what the original binary does, and recording the address). This post is about the attribution pass over `UnMeshInstance.cpp` and improvements to the animation notify system in `UnScript.cpp`.

<!-- truncate -->

## What's an Attribution?

Every function in this project carries a small annotation above it — a *provenance tag*:

- **`IMPL_MATCH("Engine.dll", 0xADDRESS)`** — "Checked against Ghidra; logic matches the retail binary at this address."
- **`IMPL_EMPTY("reason")`** — "The retail function body is also empty (Ghidra confirmed)."
- **`IMPL_DIVERGE("reason")`** — "This permanently diverges from retail — e.g. dead live services, hardware globals, or unresolved complexity."

There's a fourth tag, `IMPL_APPROX`, that used to mean "close but not verified." It is now **banned** — the build fails if you use it. The philosophy: if you can't verify it's right, say *why* you can't with `IMPL_DIVERGE`, not hand-wave with "approximately correct."

## The Problem: 90 Stubs in One File

`UnMeshInstance.cpp` is the animation instance system — ~3,400 lines tying mesh data to the running game world. At the start of this work it contained **90 functions** tagged `IMPL_DIVERGE("Reconstructed from context")`.

"Reconstructed from context" means: "I wrote this based on the class layout and what the function *should* do, but I never looked it up in Ghidra." Honest, but not good enough for a byte-accuracy project.

## Finding the Addresses

The Ghidra export lives in `ghidra/exports/Engine/_global.cpp` — a 593,000-line decompilation of the whole Engine.dll. Every function gets an address comment in one of two formats:

```
/* 0x133960  ordinal  MangledName */        ← relative offset from base
// Address: 10434c20                        ← full virtual address (includes base)
```

Engine.dll base address is `0x10300000`, so relative offset `0x133960` becomes full VA `0x10433960`.

For each of the 90 stubs:
1. Search `_global.cpp` for the mangled name or function signature
2. Extract the address comment
3. Verify the Ghidra decompilation matches our implementation
4. Upgrade to `IMPL_MATCH` if it does; document true divergence if it doesn't

Result: **67 functions upgraded to `IMPL_MATCH`**, the remaining ~23 legitimately staying as `IMPL_DIVERGE` (complex renderers, 10,000-byte GetFrame routines, functions calling unresolved retail helpers).

### Special Cases Worth Noting

**`UVertMeshInstance::IsAnimTweening`** — our original implementation returned `*(INT*)(this+0xE4)`, which looked plausible from the class layout. Ghidra revealed the truth: the retail function is a **3-byte null stub** at `0x10304720` that just returns `0`. Fixed.

**`UMeshInstance::MeshBuildBounds`** — empty body is *intentionally* empty in retail (Ghidra confirmed). Changed to `IMPL_EMPTY`.

**Both `GetMaterial` overloads** (skeletal and vertex meshes) both compile to the same function body at `0x1031C700` in the retail binary. They share one `IMPL_MATCH` address — legal in C++ since the compiler can merge identical functions.

**`USkeletalMeshInstance::MeshToWorld`** — Ghidra shows a 2,228-byte function with complex bone transform math and exception handling. Our 1-line `return FMatrix()` stays as `IMPL_DIVERGE` pending full reconstruction.

## Upgrading the Animation Notify System

`UnScript.cpp` holds the `UAnimNotify_*` classes — callbacks that fire when an animation reaches a specific frame. Three stubs were upgraded.

### UAnimNotify_DestroyEffect::Notify

This callback destroys (or expires) particle actors owned by the animated actor and tagged with a specific name.

The interesting case is `bExpireParticles`. When set, retail doesn't kill the actor immediately — it casts the actor to `AEmitter*` via a helper (`FUN_1037a3e0` in Ghidra), and if the cast succeeds, calls a vtable method at offset `0x18C` to let the emitter finish its particle cycle gracefully.

```cpp
if (bExpireParticles && Actor->IsA(AEmitter::StaticClass()))
{
    // vtable[0x18C/4] — expire method: let emitter finish naturally
    typedef void (__thiscall* EmitterExpireFn)(AActor*);
    void** vtbl = *(void***)Actor;
    EmitterExpireFn fn = (EmitterExpireFn)(vtbl[0x18C / sizeof(void*)]);
    fn(Actor);
    continue;
}
Level->DestroyActor(Actor, 0);
```

The raw vtable dispatch might look alarming if you're used to safe C++. It's deliberate: `0x18C / 4 = 99` is the 99th virtual function slot on the AEmitter vtable. Without a symbol name for that slot, raw dispatch is the most faithful reconstruction. Since we implement AEmitter ourselves and declare its virtual methods in the same order as retail, the vtable is correctly populated at runtime.

### UAnimNotify_MatSubAction::Notify

This registers a `UMatSubAction` — a sub-action in the Matinee cutscene system — with the currently active `ASceneManager` in the level.

Translated from Ghidra pseudo-code:

1. Skip in editor mode
2. Find the first `ASceneManager` in `XLevel->Actors` that is live and active:

```cpp
ASceneManager* SceneMgr = NULL;
for (INT i = 0; i < Level->Actors.Num(); i++)
{
    AActor* a = Level->Actors(i);
    if (!a) continue;
    if (*(BYTE*)((BYTE*)a + 0xa0) & 0x80) continue;      // bDeleteMe
    if (!a->IsA(ASceneManager::StaticClass())) continue;
    if (!(*(BYTE*)((BYTE*)a + 0x3c0) & 0x02)) continue;  // !bActive
    SceneMgr = (ASceneManager*)a;
    break;
}
```

The raw byte offsets (`0xa0`, `0x3c0`) come straight from Ghidra and correspond to the `bDeleteMe` and `bActive` bit fields — packed bitfield bytes not individually named in our reconstructed header.

3. Append `SubAction` to the scene manager's sub-action list, then set the start/end percentages:

```
startPct = curTime / duration
endPct   = (SubAction.duration + curTime) / duration
length   = endPct - startPct
state    = 1  (in-range)
```

The percentage math means "what fraction through the whole scene does this sub-action start/end?" — independent of wall-clock time, so the cutscene system can be scrubbed to any position.

## Numbers at a Glance

| File | Before | IMPL_MATCH upgrades | Remaining IMPL_DIVERGE |
|------|--------|---------------------|------------------------|
| UnMeshInstance.cpp | 90 IMPL_DIVERGE | 67 | ~23 (complex renderers, GetFrame) |
| UnScript.cpp | 3 IMPL_DIVERGE | 0 upgraded, 3 improved | 3 (with accurate reasons) |

The work is mechanical but the result matters: anyone reading the code now sees an honest picture of exactly where we stand on byte parity.
