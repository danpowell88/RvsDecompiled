---
slug: phase-3-the-world-simulates
title: "Phase 3 — The World Simulates (316 Stubs, Zero Remaining)"
authors: [rvs-team]
tags: [decompilation, ravenshield, progress, unreal-engine, native-functions, actors, animation, physics]
---

Phase 3 is done: every single `EXEC_STUB` macro in the Engine module has been replaced with a real function body. That's 316 native function implementations across five source files, and the build still compiles cleanly on the first attempt. Let's talk about what native functions are, why there were so many of them, and what we discovered along the way.

<!-- truncate -->

## What Are Native Functions?

If you've ever written a game mod for an Unreal Engine 1/2 game, you'll have written UnrealScript — a bytecode-interpreted language that runs inside the VM. But some operations can't be done in script. You can't call `CreateWindowEx` from UnrealScript. You can't do a line trace through BSP geometry. You can't poll DirectInput. These operations need to happen in native C++ code.

The bridge between these two worlds is the **native function**. In UnrealScript, you declare a function as `native` — the compiler assigns it an index, and at runtime the VM looks up that index in a table and calls the corresponding C++ function directly.

On the C++ side, every native function has the same signature:

```cpp
void AMyActor::execDoSomething(FFrame& Stack, RESULT_DECL)
```

`FFrame& Stack` is the UnrealScript bytecode stack. The function's job is to pop its parameters off the stack using `P_GET` macros, do its work, and optionally push a return value. The `P_GET` macros are the crucial bit — if you don't call them in the right order, the bytecode stack gets corrupted and the VM crashes spectacularly.

## The Scale of the Problem

When we started Phase 3, the Engine module had ~316 of these native functions replaced with a macro called `EXEC_STUB`:

```cpp
EXEC_STUB(AActor, execMove)
EXEC_STUB(AActor, execSetLocation)
EXEC_STUB(AActor, execTrace)
// ... 313 more
```

Each `EXEC_STUB` expanded to a function that just called `P_FINISH` (telling the VM "I'm done reading parameters") without actually reading any parameters. This works for linking — the symbol exists, the export table is happy — but at runtime, any script that calls one of these functions gets... nothing. No movement. No collision. No sound. A world of silent, frozen statues.

The work was spread across five files, grouped by subsystem:

| File | Stubs | What It Covers |
|------|-------|----------------|
| **UnLevel.cpp** | 18 | Level init, game info, boot path |
| **UnActor.cpp** | ~160 | The big one: actors, movement, collision, animation, sound, iterators |
| **UnPawn.cpp** | ~57 | Pawns, controllers, AI, player controller |
| **EngineClassImpl.cpp** | ~74 | Karma physics, volumes, zones, logging, mod manager |
| **UnEffects.cpp** | 7 | Emitters, projectors, particles |

## Anatomy of a Native Function

Let's walk through a real example. Here's `execTrace` — probably the most important function in any Unreal Engine game. It's how the engine answers the question "if I fire a ray from point A to point B, what does it hit?"

```cpp
void AActor::execTrace(FFrame& Stack, RESULT_DECL)
{
    P_GET_VECTOR_REF(HitLocation);   // out: where the ray hit
    P_GET_VECTOR_REF(HitNormal);     // out: surface normal at hit point
    P_GET_VECTOR(TraceEnd);          // ray endpoint
    P_GET_VECTOR_OPTX(TraceStart, Location);  // ray start (default: actor location)
    P_GET_UBOOL_OPTX(bTraceActors, 0);        // hit actors too, not just world?
    P_GET_VECTOR_OPTX(Extent, FVector(0,0,0)); // trace box size (0 = line trace)
    P_GET_OBJECT_OPTX(AActor, ExcludeActor, NULL); // ignore this actor
    P_FINISH;

    // Do the actual trace
    FCheckResult Hit(1.0f);
    DWORD TraceFlags = TRACE_World | TRACE_Level;
    if (bTraceActors) TraceFlags |= TRACE_Pawns | TRACE_Others;

    AActor* HitActor = XLevel->SingleLineCheck(
        Hit, this, TraceEnd, TraceStart, TraceFlags, Extent);

    *HitLocation = Hit.Location;
    *HitNormal = Hit.Normal;
    *(AActor**)Result = HitActor;
}
```

Notice the `P_GET` macros — each one pops a parameter off the bytecode stack in the exact order the UnrealScript compiler pushed them. The `_REF` variants give you a pointer (for `out` parameters). The `_OPTX` variants provide a default value if the caller didn't pass that argument.

Get the order wrong, or forget one, and the stack pointer is off by however many bytes. Every subsequent parameter read will be garbage. It's like reading a binary file format — there are no field names, just positions.

## The Iterator Pattern

One of the more elegant patterns we found is the **actor iterator**. UnrealScript has `foreach` loops that iterate over actors in the world:

```unrealscript
foreach AllActors(class'Pawn', P)
{
    P.Health = 100;
}
```

On the C++ side, this uses a pair of macros — `PRE_ITERATOR` and `POST_ITERATOR` — that manage the bytecode loop control flow:

```cpp
void AActor::execAllActors(FFrame& Stack, RESULT_DECL)
{
    P_GET_OBJECT(UClass, BaseClass);
    P_GET_OBJECT_REF(AActor, OutActor);
    P_GET_NAME_OPTX(MatchTag, NAME_None);
    P_FINISH;

    BaseClass = BaseClass ? BaseClass : AActor::StaticClass();
    INT iActor = 0;

    PRE_ITERATOR;
        *OutActor = NULL;
        while (iActor < XLevel->Actors.Num() && *OutActor == NULL)
        {
            AActor* TestActor = XLevel->Actors(iActor++);
            if (TestActor && !TestActor->bDeleteMe
                && TestActor->IsA(BaseClass)
                && (MatchTag == NAME_None || TestActor->Tag == MatchTag))
            {
                *OutActor = TestActor;
            }
        }
        if (*OutActor == NULL)
        {
            Stack.Code = &Stack.Node->Script(wEndOffset + 1);
            break;
        }
    POST_ITERATOR;
}
```

The `PRE_ITERATOR` macro reads a jump offset from the bytecode (telling it where the loop ends), and `POST_ITERATOR` jumps back to the loop start. The actual filtering logic in between determines which actors to yield. There are ten of these iterators — `AllActors`, `DynamicActors`, `ChildActors`, `TouchingActors`, `RadiusActors`, `VisibleActors`, `VisibleCollidingActors`, `CollidingActors`, `BasedActors`, and `TraceActors` — each with different filtering criteria.

## Latent Actions: Functions That Wait

Most native functions run instantly and return. But some need to *wait*. The classic example is `Sleep(2.0)` — the function starts, and then the actor pauses for two seconds of game time before continuing its script.

Unreal handles this with **latent actions**. When a latent function is called, it sets `GetStateFrame()->LatentAction` to a poll ID and returns immediately. Each tick, the VM checks: is there a pending latent action? If so, call the corresponding `Poll*` function. When the poll function decides the wait is over, it clears the latent action and script execution resumes.

```cpp
void AActor::execSleep(FFrame& Stack, RESULT_DECL)
{
    P_GET_FLOAT(Seconds);
    P_FINISH;

    GetStateFrame()->LatentAction = EPOLL_Sleep;
    LatentFloat = Seconds;
}

void AActor::execPollSleep(FLOAT DeltaSeconds)
{
    LatentFloat -= DeltaSeconds;
    if (LatentFloat <= 0.0f)
    {
        GetStateFrame()->LatentAction = 0;  // Done waiting
    }
}
```

This pattern appears everywhere: `Sleep`, `FinishAnim`, `FinishInterpolation` on the actor side; `MoveTo`, `MoveToward`, `FinishRotation`, `WaitForLanding`, `WaitToSeeEnemy` on the AI controller side. Each has a start function that sets up the wait condition and a poll function that checks if it's met.

## Karma Physics: The Ghost in the Machine

The most interesting discovery was the **Karma physics** system. Ravenshield shipped with MathEngine's Karma physics engine — the same middleware used in Unreal Tournament 2003/2004. There are 34 native functions for it: `KAddImpulse`, `KSetMass`, `KGetCOMOffset`, `KWake`, `KAddBoneLifter`, `KEnableCollision`, and so on.

We implemented all 34 with proper parameter extraction but **empty bodies** — they pop their parameters off the stack correctly (preventing VM corruption) but don't actually simulate anything. Why? Because reconstructing the Karma physics integration would require reimplementing the MathEngine SDK bridge, and Karma physics in Ravenshield is used primarily for ragdoll death animations and a handful of physics props. It's a significant effort for a localised visual effect.

These are marked as Phase 7A targets for when we tackle the remaining engine internals.

## The R6 Fingerprints

Scattered among the standard Unreal functions were Rainbow Six 6-specific additions — functions that Epic never wrote, that only exist because Red Storm/Ubisoft needed them:

- **`execGetPunkBusterStatus`** — PunkBuster anti-cheat integration, returns the PB status from the game engine
- **`execSetPlanningMode`** / **`execGetPlanningMode`** — the tactical planning phase where you plot waypoints on the map before a mission
- **`execGetAvailableResolutions`** — custom resolution enumeration (the retail game had a notoriously limited resolution list)
- **`execShowLoadingScreen`** / **`execHideLoadingScreen`** — loading screen management
- **`execGetModVersion`** / **`execGetGameVersion`** — mod system versioning, returning "1.60" (the final patch version)
- **`execDebugR6PaintBV`** — debug bounding volume rendering, probably used during development
- **`execPlayCredits`** — credit roll trigger

These are fascinating because they reveal the game's feature surface from the native code up. Every time the R6 developers needed something UnrealScript couldn't do — query PunkBuster, switch to planning mode, enumerate display adapters — they added a native function.

## Zero Remaining

After all five files were done, a quick check confirmed the result:

```
Select-String -Path "src\engine\Src\*.cpp" -Pattern "EXEC_STUB"
```

Only comment references. Zero actual `EXEC_STUB` macros in code. Every native function the VM could call now has a real C++ body that extracts its parameters correctly.

The build compiles without errors — all 316 functions integrated cleanly on the first build attempt.

## What's Next

Phase 3 handled the UnrealScript-to-C++ bridge: native functions that the VM calls. But there's another entire layer of stubs waiting: the ~1,300 empty C++ method bodies in `EngineStubs.cpp`. These are the virtual methods, serialisation functions, physics simulations, and rendering internals that make those native functions actually *do* things.

And then there's Phase 4 — **Rainbow Six Comes Alive** — where we tackle the 90 R6-specific native functions that control player movement, AI behaviour, door breaching, deployment zones, and everything that makes this game *Ravenshield* rather than just "Unreal Engine with guns."

The world can simulate. Now we need to teach it to be a Rainbow Six game.
