---
slug: the-property-shuffle
title: "24. The Property Shuffle — When Memory Layout Lies to You"
date: 2025-01-24
authors: [rvs-team]
tags: [decompilation, r6engine, ghidra, reverse-engineering, unreal-engine, memory-layout]
---

Today we discovered that Unreal Engine 2's property system secretly rearranges your class fields behind your back — and that one tiny compiler intrinsic appears 192 times in the binary without a name.

<!-- truncate -->

## The Exref Blockade

After 26 batches of function implementations, we hit a wall. Not a code wall — a *reference* wall. Ghidra uses a notation called `_exref` (external reference) when a function accesses a symbol that lives in another DLL. Every time a function reads `FVector::FVector0` (the engine's constant zero vector), Ghidra writes `FVector0_exref` instead of the actual symbol.

The problem? **234 functions** in our Ghidra export reference `FVector0_exref`. That's 234 functions we couldn't even *read* properly, let alone implement, because we didn't know what the reference resolved to.

The fix turned out to be embarrassingly simple. The *value* `FVector(0,0,0)` was already defined in our `CoreStubs.cpp`:

```cpp
const FVector FVector::FVector0(0, 0, 0);
```

But no one had ever *declared* it in the header. The class had `__declspec(dllimport)` — meaning the static member would be imported from `Core.dll` — but without a class-level declaration, no code could reference it. One line fixed 234 blockers:

```cpp
static const FVector FVector0;
```

We did the same for seven global variables (`GNightVisionActive`, `GZoomAdjustment`, and friends) that were defined in Core but never declared in any header. Simple extern declarations in `Core.h` resolved dozens more references.

## The Ghost Function

With the exrefs resolved, we started implementing `AR6RainbowAI::UpdateTimers` — the function that drives AI attack timing. The Ghidra decompilation was mostly clean, but one call appeared constantly:

```
uVar4 = FUN_10042934();
```

No name. No definition. Just a raw address. This function appears **192 times** across the entire R6Engine binary, always returning a `ulonglong` that immediately gets cast to `int`. Here's how it shows up in UpdateTimers:

```c
uVar4 = FUN_10042934();
*(float*)(this + 0x590) = fVar1 - (float)(int)uVar4 * *(float*)(this + 0x58c);
```

If you squint, you can see the pattern: take a float, convert it to an integer, multiply, subtract. This is integer truncation — `(int)(accumulator / rate) * rate` — which is just modular arithmetic.

### What Is FUN_10042934?

It's `__ftol2_sse` — Microsoft Visual C++'s compiler-inserted function for converting floating-point numbers to 64-bit integers. When you write `(int)someFloat` in C++, the MSVC compiler doesn't emit an inline conversion. Instead, it calls this tiny helper function that reads from the x87 FPU stack and returns the truncated integer in the `eax:edx` register pair.

It has no name in the symbol table because it's a compiler runtime thunk, not a user-defined function. Ghidra can't resolve it because it's neither exported nor imported — it's baked directly into the DLL's code section by the linker.

In our decompiled C++, all 192 occurrences simply become normal `(INT)` casts:

```cpp
m_fAttackTimerCounter = fAccum - (FLOAT)(INT)(fAccum / m_fAttackTimerRate) * m_fAttackTimerRate;
```

## UpdateTimers: How AI Decides to Shoot

With the ghost function identified, we could finally implement `AR6RainbowAI::UpdateTimers`. This is the heartbeat of AI combat timing:

```cpp
void AR6RainbowAI::UpdateTimers(FLOAT DeltaTime)
{
    if (m_fAttackTimerRate > 0.0f)
    {
        FLOAT fAccum = m_fAttackTimerCounter + DeltaTime;
        m_fAttackTimerCounter = fAccum;

        if (fAccum >= m_fAttackTimerRate)
        {
            // Modular reset: handles frame skips gracefully
            m_fAttackTimerCounter = fAccum
                - (FLOAT)(INT)(fAccum / m_fAttackTimerRate) * m_fAttackTimerRate;

            if (Enemy != NULL || bFire != 0)
            {
                eventAttackTimer();

                if (bFire != 0)
                    m_fFiringAttackTimer = (FLOAT)(appRand() % 6 + 1) * 0.05f;
            }
            goto CallSuper;
        }
    }

    if (bFire != 0 && m_fFiringAttackTimer <= m_fAttackTimerCounter)
        eventStopAttack();

CallSuper:
    AActor::UpdateTimers(DeltaTime);
}
```

The design is elegant. When `m_fAttackTimerRate` is positive, the AI accumulates time until it exceeds the rate, then fires an `AttackTimer` event. The jitter — `appRand() % 6 + 1) * 0.05` — adds 50ms to 300ms of randomness to prevent all AI from firing in lockstep. When the rate drops to zero (cease fire), the function watches for the firing timer to expire and dispatches `StopAttack`.

The `goto CallSuper` pattern matches the original binary exactly. The compiler generated it because both the "timer fired" path and the "timer didn't fire" path converge on the same `AActor::UpdateTimers(DeltaTime)` call.

## The Property Shuffle

While working on `AR6Door::PrunePaths`, we needed to access fields on `UReachSpec` — Unreal's class for describing how AI navigates between waypoints. The UnrealScript source declares the fields in this order:

```
var int Distance;
var const NavigationPoint Start;
var const NavigationPoint End;
var int CollisionRadius;
var int CollisionHeight;
var int reachFlags;
var int MaxLandingVelocity;
var byte bPruned;
var const bool bForced;
```

So naturally, `Distance` should be at offset `0x2C` (right after UObject's 44 bytes), `Start` at `0x30`, `End` at `0x34`, and so on. Right?

**Wrong.**

When we looked at `UReachSpec::operator=` in the Engine's Ghidra export, the byte-level field copies told a different story:

| Offset | Actual Field | Expected Field |
|--------|-------------|----------------|
| 0x2C | bPruned (BYTE) | Distance |
| 0x30 | Distance (INT) | Start |
| 0x34 | CollisionRadius (INT) | End |
| 0x48 | Start (NavigationPoint*) | bPruned |
| 0x4C | End (NavigationPoint*) | bForced |

The UE2 property system *sorts fields by type for alignment*: bytes first, then integers, then booleans, then object references. This isn't documented anywhere in the engine headers — it's buried in the property serialization code. If you trust the UnrealScript declaration order, every single field offset is wrong.

We confirmed the layout by cross-referencing three separate Ghidra functions (`operator=`, `operator<=`, and `PrunePaths` itself). With the correct offsets, PrunePaths fell into place:

```cpp
INT AR6Door::PrunePaths()
{
    INT Count = 0;
    for (INT i = 0; i < PathList.Num(); i++)
    {
        for (INT j = 0; j < PathList.Num(); j++)
        {
            if (PathList(i)->End != m_CorrespondingDoor
                && i != j
                && PathList(j)->bPruned == 0)
            {
                if (*PathList(j) <= *PathList(i))
                {
                    if (PathList(j)->End->FindAlternatePath(
                            PathList(i), PathList(j)->Distance))
                    {
                        Count++;
                        PathList(i)->bPruned = 1;
                        j = PathList.Num(); // break
                    }
                }
            }
        }
    }
    CleanUpPruned();
    return Count;
}
```

This is Ravenshield's door-specific path pruning. For each pair of reachspecs in a door's path list, it checks whether one is "contained within" using `operator<=` against another. If so, and if the weaker spec has an alternate route, the stronger spec gets pruned. The `m_CorrespondingDoor` check ensures the door's own connection never gets pruned — you always need to be able to walk through the door itself.

## The Remaining Frontier

With these implementations complete, we've now implemented around 144 methods across 27 batches. But we also did a complete inventory of what's left: **~114 stubs** remain.

The picture isn't great for quick wins. Most remaining functions fall into a few categories:

- **Large and complex** (500+ bytes): Physics code, AI decision trees, skeletal animation. These need weeks of careful offset mapping.
- **Blocked by PrivateStaticClass**: 74 Ghidra references use UClass hierarchy traversal patterns we haven't resolved yet.
- **Editor-only code**: RenderEditorInfo functions that draw debug visualization. The game works without them.
- **Already correct**: Several 1-5 byte functions that genuinely just `return 0` or are empty — our stubs match the retail binary.

The exref resolution strategy worked beautifully for `FVector0` and the global variables, but the remaining blockers (PrivateStaticClass, vtable dispatch patterns) require deeper structural work. The low-hanging fruit is gone. What remains is the dense core of game logic — the parts that make Ravenshield *Ravenshield*.

## What We Learned

1. **Compiler intrinsics haunt decompilers.** `__ftol2_sse` appears 192 times and Ghidra can't name it. Always check suspicious "unknown functions" that return `ulonglong` — they're usually runtime helpers.

2. **UE2 reorders your properties.** The native memory layout groups fields by type alignment, not declaration order. If your offsets don't match the UnrealScript source, you're probably reading the fields in the wrong order.

3. **Cross-reference everything.** We verified `UReachSpec`'s layout using three independent functions. Any one of them could have been misread, but all three agreeing gives confidence.

4. **Exref resolution has outsized returns.** One static member declaration unblocked 234 references. Always look for systemic fixes before grinding individual functions.
