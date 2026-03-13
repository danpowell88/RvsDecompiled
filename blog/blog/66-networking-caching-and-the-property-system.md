---
title: "66. Networking, Caching, and the Property System"
authors: [rvs-team]
tags: [core, networking, cache, properties, reflection, ghidra, decompilation]
---

This post covers a batch of Core module stubs that are small in line count but large in conceptual weight — they touch three of the most fundamental systems in Unreal Engine: the property reflection system, the package networking layer, and the frame timing subsystem.

<!-- truncate -->

## What Even Is Unreal's Property System?

Before we dive into specific functions, let's talk about something that trips up almost everyone who first looks at Unreal Engine source: **the property reflection system**.

In most game engines, if you want a variable to be editable in the editor, saved to disk, or sent over the network, you write special code to handle each case. In UE2, there's a different approach: every class has metadata about its fields stored as `UProperty` objects attached to the class. These property objects know each field's name, type, offset, and flags (like `CPF_Config` meaning "save to ini file" or `CPF_Net` meaning "replicate over network").

The function `USystem::StaticConstructor()` is where these property descriptors get created for the game's configuration system. It runs once when the class is first loaded:

```cpp
void USystem::StaticConstructor()
{
    // LicenseeMode = 1 means this is a licensed (not Epic internal) build
    LicenseeMode = 1;

    // Register "PurgeCacheDays" as an integer config property
    new(GetClass(), TEXT("PurgeCacheDays"), RF_Public)
        UIntProperty(CPP_PROPERTY(PurgeCacheDays), TEXT("Options"), CPF_Config);

    // Register "Paths" as an array of strings  
    UArrayProperty* PA = new(GetClass(), TEXT("Paths"), RF_Public)
        UArrayProperty(CPP_PROPERTY(Paths), TEXT("Options"), CPF_Config);
    PA->Inner = new(PA, TEXT("StrProperty0"), RF_Public)
        UStrProperty(EC_CppProperty, 0, TEXT("Options"), CPF_Config);
    // ... and so on for SavePath, CachePath, CacheExt, Suppress
}
```

The `CPP_PROPERTY(FieldName)` macro expands to something like `EC_CppProperty, offsetof(ThisClass, FieldName)` — it encodes the byte offset of the field within the class. When Unreal loads a config file and sees `Paths=../System`, it uses these registered property objects to find exactly where in memory to write the string array. No manual parsing, no special cases — it's all driven by the metadata.

## UCommandlet::Main — The Simplest Function

`UCommandlet` is the base class for command-line tools that run as part of the Unreal engine (think "run a map check" or "cook packages"). Its `Main` function is beautifully simple:

```cpp
INT UCommandlet::Main( const TCHAR* Parms )
{
    guard(UCommandlet::Main);
    return eventMain( Parms );
    unguard;
}
```

That's it — it just calls through to the UnrealScript `Main` event. All the actual logic lives in script. The C++ side is just a bridge.

The `guard`/`unguard` pair is Unreal's built-in crash reporting system. When something goes wrong, these macros unwind the call stack and report "crash in UCommandlet::Main" in the error log. Simple but effective.

## UPackageMap — Network Object Serialisation

Now for something more interesting. When Ravenshield runs a multiplayer game, actors and their properties get synchronized across the network. But you can't just send C++ pointers over the wire — the server's memory layout is completely different from the client's. You need a way to identify objects that works on both machines.

`UPackageMap` is that translation layer. Each side maintains a map of "package-qualified object references" that both machines agree on. Three functions make it work:

**CanSerializeObject** — checks whether an object can be described in the shared map:
```cpp
UBOOL UPackageMap::CanSerializeObject( UObject* Obj )
{
    // The base class should never be called directly
    appErrorf(TEXT("Unexpected UPackageMap::CanSerializeObject"));
    return 1;
}
```

**ObjectToIndex** — converts a live pointer to a network-stable integer:
```cpp
INT UPackageMap::ObjectToIndex( UObject* Object )
{
    // Find which package this object belongs to via its linker
    FPackageInfo& Info = List( LinkerMap( Object->_Linker ) );
    return Info.ObjectBase + Object->_LinkerIndex;
}
```

**IndexToObject** — converts that integer back to a pointer on the receiving end:
```cpp
UObject* UPackageMap::IndexToObject( INT Index, UBOOL Load )
{
    for( INT i = 0; i < List.Num(); i++ )
    {
        if( Index >= List(i).ObjectBase && Index < List(i).ObjectBase + List(i).ObjectCount )
        {
            INT LocalIndex = Index - List(i).ObjectBase;
            if( !List(i).Linker->ExportMap(LocalIndex)._Object && Load )
                List(i).Linker->CreateExport( LocalIndex );
            return List(i).Linker->ExportMap(LocalIndex)._Object;
        }
    }
    return NULL;
}
```

The pattern: objects know which "linker" (package file) they came from, and they have an index within that package. The `ObjectBase` field in `FPackageInfo` is an offset so that all packages can share a single flat namespace of integer IDs.

## FMemCache::Tick — Tracking Staleness

The last piece in this batch is `FMemCache::Tick`, called once per game frame to maintain the engine's in-memory cache. The cache stores things like decoded textures — expensive to recompute but also memory-hungry. The Tick function manages how long things stay "fresh":

```cpp
void FMemCache::Tick()
{
    // Reset per-frame MRU (Most Recently Used) tracking
    MruId   = 0;
    MruItem = NULL;

    // Reset per-frame counters (not lifetime totals)
    ItemsFresh = ItemsStale = NumGaps = MemFresh = MemStale = 0;

    // Decay the "cost" of stale items slightly each frame
    // Cost >>= 5 is roughly a 3% reduction per frame
    for( FMemCache::FItem* Item = ... )
        if( Item->IsStale() )
            Item->Cost -= Item->Cost >> 5;

    Time++;  // advance the frame clock for staleness calculations

    // Measure how long this tick took
    TickCycles += appCycles() - overhead;
}
```

The cost decay is the smart bit. Items that haven't been accessed recently have their cost slowly reduced. When the cache is under memory pressure, it evicts the cheapest stale items first. Items that were expensive to create (large textures) naturally survive longer because even after decay they still cost more than cheap items.

## A Linker Error Surprise

Speaking of `appCycles()` — we hit an unexpected build failure during this work. The function is an inline that uses the `RDTSC` assembly instruction (Read Time-Stamp Counter), but it guards it with a global flag called `GTimestamp`. If `GTimestamp` is false, the function returns 0 (no timing).

The catch: `GTimestamp` is declared as `extern CORE_API UBOOL GTimestamp` but was never *defined* anywhere in our source. Every other Core global had a definition in `Core.cpp` — `GTimestamp` was simply missing from the list. Adding it:

```cpp
CORE_API UBOOL GTimestamp = 1;
```

One line, but without it the linker refused to build Core.dll at all.

## Joystick Input, Properly

On the WinDrv side, `UWindowsViewport::JoystickInputEvent` went from `return 0` to the real implementation. Joystick hardware reports raw axis values in the range [-32767, 32767]. The function normalises these and applies a deadzone:

```cpp
FLOAT fAxis = DeltaSeconds * 3.0517578e-05f;  // divide by 32768
if( Abs )
{
    if( fAxis > 0.2f )       fAxis = (fAxis - 0.2f) * 1.25f;
    else if( fAxis < -0.2f ) fAxis = (fAxis + 0.2f) * 1.25f;
    else                     fAxis = 0.0f;  // dead zone
}
return CauseInputEvent( Key, IST_Axis, fAxis * Delta );
```

The `0.2f` deadzone means the first 20% of stick travel is ignored (preventing drift from an imperfect centre position), and then the remaining 80% is linearly remapped to cover the full [-1, 1] range via the `* 1.25f` factor. A textbook deadzone implementation.

## 3D Lines in the HUD

Finally, two `execDraw3DLine` implementations that draw debug lines in world space. Both `UCanvas` and `AHUD` had no-op stubs; the real version uses `FLineBatcher`, a helper class that batches line segments for the GPU:

```cpp
if( Viewport )
{
    // RI lives at a raw offset in UViewport (not in public headers)
    FRenderInterface* RI = *(FRenderInterface**)((BYTE*)Viewport + 0x164);
    if( RI )
    {
        FLineBatcher Batcher( RI, 1, 0 );
        Batcher.DrawLine( Start, End, Color );
    }
}
```

The `FRenderInterface` pointer at offset 0x164 is only valid while the viewport is locked for rendering — which it always is when UnrealScript HUD code runs. The batcher itself handles all the vertex buffer management.

## Where We Stand

This batch cleared several important Core systems. The property reflection system, package networking, frame timing, and input handling all have proper implementations now. The build stays clean, and the game is one step closer to running end-to-end.

Next up: the remaining Engine stubs — physics movement, AI pathfinding, and the rendering pipeline.
