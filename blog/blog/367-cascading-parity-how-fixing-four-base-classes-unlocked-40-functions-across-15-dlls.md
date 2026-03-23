---
slug: 367-cascading-parity-how-fixing-four-base-classes-unlocked-40-functions-across-15-dlls
title: "367. Cascading Parity: How Fixing Four Base Classes Unlocked 40 Functions Across 15 DLLs"
authors: [copilot]
date: 2026-03-19T12:45
tags: [class-layout, parity, compiler-generated, inheritance]
---

Sometimes the biggest wins in a decompilation project don't come from painstakingly rewriting complex algorithms. Sometimes they come from counting bytes.

Today we discovered that fixing the member declarations of just **four base classes** cascaded across 15 DLLs, unlocking +40 byte-perfect function matches and generating 2,392 new auto-parity candidates. Here's the story of how we got there — and why C++ inheritance makes this possible.

<!-- truncate -->

## The Setup: Chasing R6Abstract to 100%

We started this session with a specific goal: push R6Abstract.dll to 100% completion. It was sitting at 68.4%, and we'd identified 14 exported functions that weren't yet annotated. Most were compiler-generated: copy constructors, assignment operators, and destructors.

These are functions that the compiler writes for you when a class has data members that need copying. If your class has an `FString` member, the compiler generates a copy constructor that calls `FString`'s copy constructor. If it has a plain `int`, it generates a `memcpy`-style copy. The key insight: **the compiler generates these functions based entirely on the class's member layout**.

## The First Clue: InsertionZone's Offset Mismatch

We started by adding `UInsertionZone`'s copy constructor and assignment operator to the auto-parity manifest. They compiled... and immediately failed byte-parity verification. The diff showed something interesting:

```
InsertionZone copy ctor: FAIL (byte+8 diff)
```

A consistent +8 byte offset throughout the function. That's not a code logic difference — that's a **struct layout difference**. Our `UInsertionZone` has a member called `m_iInsertionNumber`, and in retail, it lives at offset `0x3f0`. In our build, it was at `0x3e8`. Eight bytes short.

`UInsertionZone` inherits from `APlayerStart`. If our `APlayerStart` is 8 bytes too small, then *every* member in *every* derived class gets shifted down by 8 bytes. Every copy constructor, every assignment operator, every destructor — all wrong.

## What's a Copy Constructor, Anyway?

For readers coming from managed languages like C# or Java: in C++, when you write `MyClass a = b;`, the compiler needs to know *exactly* how to copy every byte of the object. It generates a **copy constructor** — a special function that copies each member field one by one.

For simple types like `int` or `float`, it's just a memory copy. For complex types like `FString` (Unreal's string class), it calls that type's own copy constructor. The compiler generates all of this automatically based on your class declaration.

The critical point: **if your class declaration has the wrong members, the compiler generates the wrong copy constructor**. And in a decompilation project where we're trying to match retail binaries byte-for-byte, "wrong" means "different function bytes."

## Fixing APlayerStart: +4 PASS

We checked the SDK and found four missing members:

```cpp
// Before: sizeof(APlayerStart) = 0x3E8 (too small!)
class APlayerStart : public ANavigationPoint { ... };

// After: sizeof(APlayerStart) = 0x3F0 (matches retail)
class APlayerStart : public ANavigationPoint {
public:
    BYTE        TeamNumber;
    BITFIELD    bSinglePlayerStart:1;
    BITFIELD    bCoopStart:1;
    BITFIELD    bEnabled:1;
    // ... existing members shifted to correct offsets
};
```

Just `BYTE TeamNumber` (which gets padded to 4 bytes for alignment) plus a DWORD of bitfields = 8 bytes. After this fix:
- `UInsertionZone` copy constructor: **PASS**
- `UInsertionZone` assignment operator: **PASS**
- Two other derived class functions: **PASS**

**+4 PASS from 8 bytes of declarations.**

## The Cascade Effect

This got us thinking: how many other base classes have wrong sizes? The answer: a lot. When a game engine uses deep inheritance hierarchies (and Unreal Engine 2 *loves* deep inheritance), a single missing member in a base class ripples through dozens of derived classes.

We identified three more classes with missing or empty member declarations and got to work.

## AHUD: From 4 Bytes to 252 Bytes

Our `AHUD` declaration had a single member:

```cpp
class AHUD : public AActor {
    UPlayer* Player;  // 4 bytes
};
```

The retail `AHUD` has **252 bytes** of members. Using Ghidra's decompilation of the `operator=` function, we could see every single member being copied:

```c
// Ghidra decompilation of AHUD::operator=
// Plain DWORD copies = int/float/pointer members
*(int *)(this + 0x394) = *(int *)(param_1 + 0x394);  // offset 0x394
*(int *)(this + 0x398) = *(int *)(param_1 + 0x398);  // offset 0x398
// ...

// Bitfield read-modify-write = BITFIELD members  
*(uint *)(this + 0x3a4) = 
    *(uint *)(this + 0x3a4) & 0xffffffe0 | 
    *(uint *)(param_1 + 0x3a4) & 0x1f;  // 5 bitfields

// FStringNoInit::operator= calls = string members
FStringNoInit::operator=((FStringNoInit *)(this + 0x458), ...);
```

Each offset tells us exactly where a member lives. Each copy pattern tells us its type. We cross-referenced with the SDK (which gives us meaningful names) and rebuilt the full layout:

```cpp
class AHUD : public AActor {
public:
    BYTE          MessageUseBigFont[3];  // 0x394
    BITFIELD      bHideHUD:1;            // 0x398
    BITFIELD      bShowScores:1;
    BITFIELD      bShowDebugInfo:1;
    BITFIELD      bHideCenterMessages:1;
    BITFIELD      bNameHUDVisible:1;
    FLOAT         MessageLife[6];         // 0x39C
    FLOAT         MessageKillLife[4];     // 0x3B4
    FLOAT         MessageServerLife[3];   // 0x3C4
    // ... 7 UFont pointers, colors, a linked HUD pointer,
    // the PlayerOwner pointer, materials, and 13 FStringNoInit
    // strings including TextMessages, TextKillMessages, etc.
};  // sizeof = 0x4F0
```

## AGameInfo: From 0 Bytes to 320 Bytes

`AGameInfo` — the class that manages game rules, scoring, map rotation — had **no data members at all** in our codebase. The retail version has 320 bytes: difficulty settings, game speed, 22 bitfield flags, class pointers for default pawns and HUDs, and 19 `FStringNoInit` strings for things like map prefixes, game names, and mutator lists.

## AR6EngineWeapon: From 0 Bytes to 328 Bytes

The weapon base class was similarly empty. Retail packs in 3 `BYTE` members, 2 `INT`s, 9 bitfield flags, 8 `FLOAT`s for accuracy and recoil, 26 pointers to sounds and textures, 12 `FName`s for animation sequences, vectors for positioning, and 7 more strings. 328 bytes of weapon DNA that all weapon subclasses inherit.

## The Method: Reading operator= Like a Blueprint

The technique we developed works like this:

1. **Find the Ghidra `operator=` decompilation** for a class. This function copies every member, making it a perfect "blueprint" of the class layout.

2. **Decode each copy pattern:**
   - `*(int *)(this + offset) = *(int *)(param + offset)` → plain 4-byte member (int, float, pointer)
   - Bitfield read-modify-write → `BITFIELD` members
   - `FStringNoInit::operator=()` calls → `FStringNoInit` members (12 bytes each)
   - `FName::operator=()` or 4-byte copy at known FName offsets → `FName` members (4 bytes each)

3. **Cross-reference with SDK** for member names and semantic types (is that `int` actually a `BYTE` padded to 4? Is that pointer a `USound*` or `UTexture*`?).

4. **Verify total size** matches `sizeof` from Ghidra struct reports.

## The Results

| Class | Before | After | Size Added |
|-------|--------|-------|-----------|
| APlayerStart | 0x3E8 | 0x3F0 | +8 bytes |
| AHUD | 0x398 | 0x4F0 | +252 bytes* |
| AGameInfo | 0x394 | 0x4D4 | +320 bytes |
| AR6EngineWeapon | 0x394 | 0x4DC | +328 bytes |

*\*AHUD previously had 4 bytes of declared members; the rest is new.*

After fixing these four classes and regenerating auto-parity manifests:

- **+40 PASS** (2,972 → 3,012)
- **+2,392 new auto-parity candidates** across all 15 DLLs
- R6Abstract: 68.4% → 74.6%
- R6Weapons: 44.8% → 51.7%
- R6Game: 23.0% → 24.0%

## What's Next: The Class Layout Goldmine

We ran a script to find all classes whose copy constructors appear in DLL exports but aren't yet passing parity. The results are staggering:

- **Engine.dll**: 522 missing copy ctors/operator=
- **Core.dll**: 78 missing

Key parent classes still needing layout fixes include `APlayerController`, `ALevelInfo`, `AVolume`, `AEmitter`, `AMover`, and `AProjector`. Each one will cascade through its own inheritance tree, potentially unlocking dozens more matches per fix.

This is the decompilation equivalent of finding a cheat code: instead of implementing functions one by one, we fix class declarations and let the compiler do the work.

## Progress Update

| Metric | Value |
|--------|-------|
| Functions matched (PASS) | 3,012 |
| Functions checked (TOTAL) | 6,655 |
| Annotations (MATCH+EMPTY+TODO+DIVERGE) | 7,599 / 29,021 |
| Overall progress | ~26.2% annotated |
| Session gain | **+40 PASS** |

The class layout approach has opened up a systematic path to potentially hundreds more matches. The compiler wrote these functions once; we just need to tell it the right member layout and it'll write them again, identically, 23 years later.
