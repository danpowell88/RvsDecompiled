---
slug: unobj-stubs-implemented
title: "70. The Heart of Unreal: Implementing UObject's Core Methods"
authors: [rvs-team]
tags: [core, unreal-engine, ghidra, decompilation]
date: 2026-03-13
---

Every object in an Unreal Engine game — every actor, every weapon, every menu widget — is ultimately a `UObject`. The `UObject` class is the foundation on which everything else stands, providing garbage collection, serialisation, scripting, config loading, and the state machine that powers UnrealScript. Today we filled in 30 previously-stubbed methods in `UnObj.cpp` and `CoreStubs.cpp`, working directly from Ghidra decompilation output.

<!-- truncate -->

## What Is UObject, Really?

If you have a C++ background you might think of `UObject` as just a base class with some ref-counting. In Unreal Engine 2 it is far more than that. Every `UObject` carries:

- **A global index** — its slot in the `GObjObjects` array, the engine's master object table.
- **A hash chain** — for fast name lookups in `GObjHash[4096]`.
- **A state frame** (`FStateFrame`) — the execution stack for UnrealScript state machines.
- **Object flags** — a bitmask encoding lifecycle state (`RF_Native`, `RF_Transactional`, `RF_TagGarbage`, …).
- **A linker reference** — tracking which package file the object came from.

None of the interesting engine behaviour works until those methods have real implementations. A stub that just `return 0` will silently break state transitions, config loading, garbage collection, and console commands.

---

## Reading Ghidra Output

Ghidra decompiles the compiled binary back into C-like pseudocode. It can't recover variable names or types — it gives you things like:

```c
*(undefined4 *)(*(int *)(this + 0xc) + 0x28) = 0;
```

That single line, once you know the struct layout, is just:

```cpp
StateFrame->LatentAction = 0;
```

The key skill is mapping raw byte offsets to named struct fields. We computed offsets for every level of the inheritance chain:

| Class | Size | Key fields |
|-------|------|------------|
| `UObject` | 0x2C | vtable, Index, HashNext, StateFrame, Outer, ObjectFlags, Name, Class |
| `UField` | +0x0C | SuperField, Next, HashNext(field) |
| `UStruct` | +0x3C | Children, Script (TArray), LabelTableOffset |
| `UFunction` | +0x14 | FunctionFlags, ParmsSize, Func pointer |
| `UState` | +0x18 | ProbeMask (QWORD), IgnoreMask (QWORD), LabelTableOffset |

### The Struct-Offset Divergence

One interesting quirk: the binary's `FStateFrame` is 4 bytes larger than our reconstructed source struct. The binary was compiled with 8-byte QWORD alignment for `ProbeMask`, inserting a 4-byte pad after `StateNode`. As a result:

- **Binary:** `LatentAction` is at `StateFrame + 0x28`
- **Our source:** `LatentAction` is at `StateFrame + 0x24`

Rather than match the binary byte-for-byte with raw offsets (which would make the source unreadable), we use the named field `StateFrame->LatentAction` everywhere and document the divergence with a comment.

---

## The State Machine (GotoState / GotoLabel)

UnrealScript lets you write code like this:

```unrealscript
state Running {
    Begin:
        PlayAnim('Run');
        FinishAnim();
    GotoState('Idle');
}
```

`GotoState` and `GotoLabel` are the engine functions that make this work.

### GotoState

The implementation has to handle several tricky scenarios:

1. **Auto states.** `GotoState(NAME_Auto)` finds the first state with the `STATE_Auto` flag set — the "default" starting state for a class.

2. **EndState / BeginState events.** When leaving a named state, the engine calls `eventEndState()`. When entering one, it calls `eventBeginState()`. Either can trigger a *nested* `GotoState` (a preemption).

3. **Re-entrancy guards.** Two `ObjectFlags` bits prevent infinite loops:
   - `RF_InEndState` (0x2000) — set while `GotoState` is running, blocks re-entering the EndState path.
   - `RF_StateChanged` (0x1000) — set by a nested successful `GotoState`, detected by the outer call to decide whether it was preempted.

The logic looks like this in broad strokes:

```cpp
// Before calling EndState, arm the re-entrancy guard.
ObjectFlags = (ObjectFlags & ~RF_StateChanged) | RF_InEndState;
eventEndState();
ObjectFlags &= ~RF_InEndState;  // leave the guard
if( ObjectFlags & RF_StateChanged )
    return GOTOSTATE_Preempted;  // EndState started a new state transition
```

4. **ProbeMask.** The new state's probe mask is derived by OR-ing the class and state masks together, then applying the state's ignore mask:

```cpp
StateFrame->ProbeMask =
    (GetClass()->ProbeMask | NewStateNode->ProbeMask) & NewStateNode->IgnoreMask;
```

This controls which events the object currently responds to.

### GotoLabel

Labels in UnrealScript (like `Begin:`) are stored as a `FLabelEntry` table at the end of a state's bytecode array. `GotoLabel` walks the state hierarchy and does a linear scan of that table:

```cpp
for( FLabelEntry* Entry = (FLabelEntry*)&StateNode->Script(StateNode->LabelTableOffset);
     Entry->Name != NAME_None; Entry++ )
{
    if( Entry->Name == Label )
    {
        StateFrame->Code = &StateNode->Script(Entry->iCode);
        return 1;
    }
}
```

---

## Garbage Collection (IsReferenced / PurgeGarbage)

Unreal Engine 2 uses a classic **mark-and-sweep** garbage collector. The two functions we implemented are the per-object slice of it:

`IsReferenced` runs a mini GC pass — it tags everything with `RF_TagGarbage`, unmarks objects reachable from the root set and keep-flagged objects, then checks if the target object still has its tag. Crucially, it **leaves the tags in place** so that `PurgeGarbage` knows what to destroy:

```cpp
// Mark everything.
for all GObjObjects: SetFlags(RF_TagGarbage)
// Unmark the reachable set.
for all GObjRoot: ClearFlags(RF_TagGarbage)
for objects with KeepFlags set: ClearFlags(RF_TagGarbage)
// Tagged objects are unreachable.
return !(Res->GetFlags() & RF_TagGarbage);
```

`PurgeGarbage` then sweeps:

```cpp
for each object still tagged RF_TagGarbage (and not RF_Native):
    ConditionalDestroy();
// Clear residual tags.
for all objects: ClearFlags(RF_TagGarbage);
```

---

## Field Lookup: VfHash

UnrealScript fields (functions, states, variables) are stored in a hash table on each `UState`/`UClass`:

```cpp
UField* VfHash[256];  // HASH_COUNT = 256
```

Finding a field by name:

```cpp
INT idx = FieldName.GetIndex() & 0xFF;
for( UField* F = Class->VfHash[idx]; F; F = F->HashNext )
    if( F->GetFName() == FieldName )
        return F;
```

`FindObjectField` checks the current state's hash first (for local state functions), then falls back to the class hierarchy. `FindState` additionally verifies that the found field actually `IsA(UState)` before returning it.

---

## Config and Localisation

`LoadConfig` and `SaveConfig` iterate properties flagged `CPF_Config` and read/write them through `GConfig`:

```cpp
for( TFieldIterator<UProperty> It(GetClass()); It; ++It )
{
    if( !(It->PropertyFlags & CPF_Config) ) continue;
    TCHAR Buffer[1024];
    if( GConfig->GetString(Section, It->GetName(), Buffer, ..., Filename) )
        It->ImportText(Buffer, (BYTE*)this + It->Offset, 0);
}
```

`LoadLocalized` does the same for `CPF_Localized` properties, routing through `Localize()` instead of `GConfig`.

---

## What's Left

`VerifyLinker` remains a stub — the public linker API doesn't expose a `Verify()` call we can target without more Ghidra work. `CacheDrivers` is also stubbed; it requires scanning all active GConfig sections for `Driver=` entries, which is non-trivial and rarely called outside the editor.

The build compiles and links cleanly with 0 errors. With these 30 methods in place, state machine transitions, scripted console commands, garbage collection, and property serialisation are all wired up and ready for testing as the broader decompilation progresses.
