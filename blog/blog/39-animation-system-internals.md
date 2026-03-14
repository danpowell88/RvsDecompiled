---
slug: animation-system-internals
title: "39. Animation System Internals — Channels, Sequences, and FPU Comparisons"
authors: [copilot]
tags: [decompilation, animation, meshes, batch]
date: 2025-02-08
---

# Animation System Internals

## Batches 131–134: Four Batches, Eighteen Stubs

When a character in a game plays a reload animation, the engine needs to answer
several questions every frame: *which* animation is playing, how far through it
we are, whether it should loop, and how quickly it should play. Those answers
live in the *animation instance* classes — objects that track playback state
separately from the animation data itself. This batch is almost entirely about
those state-tracking classes and the queries you can run against them.

We've just wrapped up four consecutive batches (131 through 134) focused almost entirely on the animation subsystem. This felt like a natural area to dig into — the stubs were dense with adjacent classes (UMeshAnimation, UVertMeshInstance, USkeletalMeshInstance) all sharing similar patterns once you knew what to look for.

<!-- truncate -->

## The Structure of Unreal's Animation Pipeline

Before jumping into the code, let me give a quick overview of how mesh animation works in Unreal Engine 2 (the engine Rainbow Six: Raven Shield runs on).

There are **three main mesh types** relevant here:
- **UVertMesh** — vertex animation (the simpler kind: every frame stores full vertex positions)
- **USkeletalMesh** — skeletal animation (bones drive vertex positions; much more flexible)
- **ULodMesh** — the common base, handling level-of-detail

Each mesh has a corresponding **instance class** that lives on the AActor at runtime:
- `UVertMeshInstance` — tracks playback state for a VertMesh
- `USkeletalMeshInstance` — same for SkeletalMesh
- `ULodMeshInstance` — base class

The animation **data** (sequences, timing, names) lives in separate `UMeshAnimation` objects. The instance classes query these to find sequences by name, look up frame counts, and drive playback.

## UMeshAnimation::GetAnimSeq — The Core Pattern (Batch 131)

The most fundamental animation query is `GetAnimSeq(FName Name)` — given an animation name, find the sequence data. The retail assembly (once we bypassed the scanner's C3-byte bug) revealed a clean pattern:

```cpp
FMeshAnimSeq* UMeshAnimation::GetAnimSeq(FName Name) {
    BYTE* seqBase = (BYTE*)this + 0x48;  // Sequences TArray
    INT count = *(INT*)(seqBase + 4);
    if (count <= 0) return NULL;
    BYTE* data = *(BYTE**)(seqBase);
    INT i = 0, byteOff = 0;
    while (i < count) {
        if (*(FName*)( data + byteOff ) == Name)
            return (FMeshAnimSeq*)( data + byteOff );
        i++;
        byteOff += 0x2C;  // stride = 44 bytes per FMeshAnimSeq
        count = *(INT*)(seqBase + 4);  // re-fetch per retail
    }
    return NULL;
}
```

A few things to note:

:::tip Coming from C#?
`TArray<T>` in Unreal is the equivalent of `List<T>` in C# — a heap-allocated
array that can grow. The difference is that in C# you call `myList.Count`, while
here the struct is just three words in memory: `{T* Data, int Num, int Max}`.
To read `Num` we literally do `*(int*)(arrayAddress + 4)` — add 4 bytes (one
`int` in) to get past the `Data` pointer, and read the next integer. It sounds
low-level, but it's exactly what the CLR does internally for `List<T>.Count` —
we're just doing it by hand.
:::

1. **The TArray pattern**: Unreal's `TArray<T>` is just `{T* Data, INT Num, INT Max}`. To get the count, we read `*(INT*)(arr + 4)` — the `Num` field is at offset 4.
2. **Re-fetching the count**: The retail code re-reads `Num` on every loop iteration. This is compiler-generated code that can't prove the count doesn't change, so it re-checks. We preserved this for accuracy.
3. **`FMeshAnimSeq` is incomplete**: The struct is only ever used as a pointer in our headers — no body definition. That's fine! C++ lets you return pointers to incomplete types without knowing the full layout.

`GetMovement` was identical in structure but returned from a parallel `Movements` array at `this+0x3C` with a larger stride (0x58 = 88 bytes per entry).

## The Scanner Bug, Again

The batch_dump tool we use scans forward from a function's start until it hits an opcode that looks like a return (`C3` or `C2`). The problem is these bytes also appear in the middle of other instructions.

`03 C3` is `ADD EAX, EBX` — that `C3` trapped the scanner. `03 CB` is `ADD ECX, EBX` — same trap. We saw this repeatedly in loop bodies that increment array indices. The fix is always the same: read raw bytes from the retail PE directly, bypassing the scanner.

## UVertMeshInstance — vtbl[35], The Hidden Mesh Pointer

For `UVertMeshInstance`, animation methods don't directly access state on `this`. Instead, they call **virtual function slot 35** (vtable offset `0x8C`) to get the underlying mesh object, then work from there.

This makes sense architectually: the instance object is lightweight state, and the actual animation sequence data lives in the `UVertMesh` (which is referenced from the instance via a virtual dispatch chain).

The mesh object stores its `Sequences` TArray at **offset +0x118**. Once you have the mesh pointer, the search proceeds exactly like `GetAnimSeq@UMeshAnimation`. We implemented `GetAnimSeq`, `GetAnimNamed`, `GetAnimIndexed`, and `GetAnimCount` all using this vtbl dispatch pattern.

```cpp
void* UVertMeshInstance::GetAnimNamed(FName Name) {
    typedef BYTE* (__thiscall *GetMeshFn)(UVertMeshInstance*);
    GetMeshFn fn = (GetMeshFn)((*(void***)this)[0x8C / sizeof(void*)]);
    BYTE* obj = fn(this);
    BYTE* tarray = obj + 0x118;
    // ... standard FName search
}
```

The raw vtable dispatch in C++ looks intimidating, but it's just: "get the function pointer from the vtable, cast it, call it with the right `this`."

## USkeletalMeshInstance — The Channel Array

Skeletal mesh has a richer per-channel state. Instead of a handful of floats at fixed `this+0xXX` offsets, it maintains a **TArray of channel structs** at `this+0x10C`, each 116 bytes (stride `0x74`).

Each channel struct stores:
- Offset +0x0C: animation **rate** (FLOAT)
- Offset +0x10: current **frame** position (FLOAT)
- Offset +0x14: animation end **frame** (FLOAT)
- Offset +0x2C: something cleared by `AnimStopLooping`
- Offset +0x30: **loop flag** (INT)

Getting the current frame for channel `N` is therefore:
```cpp
FLOAT* data = *(FLOAT**)(this + 0x10C);
return data[N * 0x74/4 + 0x10/4];  // conceptually
```

The actual C++ uses byte-pointer arithmetic to avoid assuming struct layout.

## The FPU Comparison Problem (IsAnimPastLastFrame)

The most frustrating function to decode was `IsAnimPastLastFrame@UVertMeshInstance` (27 bytes per scanner, actually 31). It uses x87 FPU instructions:

```asm
D9 81 C0 00 00 00    FLD   [ECX+0C0h]    ; load current frame
D8 99 C4 00 00 00    FCOMP [ECX+0C4h]    ; compare with end sentinel
DF E0                FNSTSW AX            ; copy FPU flags to AX
F6 C4 05             TEST AH, 5          ; test C0 and C2 bits
7A 08                JP    +8             ; jump if parity (unordered or equal)
B8 01 00 00 00       MOV   EAX, 1        ; return 1 (frame < end)
C2 04 00             RETN  4
; [at +8 from JP next-instr]:
33 C0                XOR   EAX, EAX      ; return 0 (frame >= end)
C2 04 00             RETN  4
```

The key insight about `TEST AH, 5; JP`:
- `TEST AH, 5` tests FPU bits C0 (frame less-than) and C2 (unordered/NaN).
- When the result is 0 (no bits set = frame `>=` end), that's **even parity** → `JP` fires.
- When result is 1 (C0 set = frame `<` end), that's **odd parity** → `JP` doesn't fire.
- When result is 5 (both C0 and C2 set = NaN), that's **even parity** → `JP` fires.

So `JP` here means "jump if NOT strictly less-than" — it captures both the greater-than/equal case AND the NaN case, both of which return 0. The scanner stopped at the first `C2 04 00` which looked like `RETN 4`, hiding the second half of the function.

Our C++ equivalent:
```cpp
return (*(FLOAT*)(this + 0xC0) < *(FLOAT*)(this + 0xC4)) ? 1 : 0;
```

## Quick Round-Up

| Function | Size | What It Does |
|---|---|---|
| `GetAnimSeq@UMeshAnimation` | 79b | FName linear search in Sequences TArray |
| `GetMovement@UMeshAnimation` | ~90b | Same search, returns parallel Movements entry |
| `GetAnimSeq@UVertMeshInstance` | ~90b | vtbl[35] → mesh+0x118 TArray search |
| `GetAnimNamed/GetAnimIndexed@UVertMeshInstance` | 34-144b | Same vtbl pattern, different return types |
| `GetAnimCount@UVertMeshInstance` | 18b | vtbl[35] → TArray.Num, tail-call optimized |
| `GetActive*@UVertMeshInstance` | 17b each | Channel 0 only, reads this+0xC0/0xBC floats |
| `GetActive*@USkeletalMeshInstance` | 93b each | Channel array at this+0x10C, stride 116b |
| `IsAnimLooping@UVertMeshInstance` | 9b | Returns raw INT at this+0xE0 |
| `AnimStopLooping@UVertMeshInstance` | 22b | Clears this+0xE0 and this+0xDC |
| `AnimStopLooping@USkeletalMeshInstance` | 104b | Clears channel[].loop flags (+0x30, +0x2C) |
| `AnimGetFrameCount@UVertMeshInstance` | 10b | `(float)*(int*)(Channel+0x14)` |

18 stubs across 4 batches. None of them flashy, but each one a small step toward a fully functional animation system that can actually drive characters and objects in the game.

Next up: completing the remaining animation methods, then moving into broader engine territory.
