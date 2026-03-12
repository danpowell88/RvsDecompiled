---
slug: canvas-config-and-more-channels
title: "40. Canvas, Config Names, and More Animation Channels"
authors: [dan]
tags: [decompilation, animation, canvas, ue2, batch]
date: 2025-02-09
---

# Canvas, Config Names, and More Animation Channels

## Batches 136–139: Fifteen More Stubs

Four more batches landed cleanly this week (136–139), and they cover three pretty distinct areas of the engine: more animation channel machinery, the UCanvas rendering interface, and some small config/input fixes. Let me walk through each area.

<!-- truncate -->

## Part 1: Animation Notify Arrays (Batches 136–137)

In the last blog post I covered `GetAnimSeq` and its siblings. This time we pushed deeper into the animation *channel* system — specifically how the engine tracks **notifications** embedded in animation sequences.

### What's a Notify?

When an animation plays, at certain frames it can trigger *notifications* — callbacks that fire when a character's foot hits the ground, when a weapon is ready to fire, or when a footstep sound should play. Each animation sequence contains a list of these, stored as an array of `FMeshAnimNotify` structs.

The `FMeshAnimNotify` struct (inferred from the assembly) is **12 bytes wide** and looks like this:

```
+0x00  FLOAT  Time       (timestamp in the animation)
+0x04  FName  Name       (string name identifying this notify)
+0x08  UAnimNotify*  Obj (optional callback object, may be NULL)
```

These are stored in a `TArray<FMeshAnimNotify>` that lives **inside** the channel struct at `Channel + 0x1C`. So to get the count, you read `*(INT*)((BYTE*)Channel + 0x20)` — that's the TArray `Num` field at offset 4 from the TArray start (at 0x1C + 0x04 = 0x20).

### AnimGetNotifyCount

With that layout, `GetNotifyCount` is almost trivial once decoded:

```cpp
int UVertMeshInstance::AnimGetNotifyCount(void* Channel) {
    // 16b retail. TArray<FMeshAnimNotify> at Channel+0x1C; Num at Channel+0x20.
    return *(INT*)((BYTE*)Channel + 0x20);
}
```

The skeletal version adds a null check on Channel (it can be NULL when there's no active channel), then reads the same offset.

### AnimGetNotifyText — FName Dereferencing

`AnimGetNotifyText` returns the name of a notify entry at a given index. This needed us to interact with `FName` in an interesting way.

In Unreal Engine, `FName` is essentially just an integer — an index into a global name table. The actual string backing it lives in `GNames[index]->Name`. To get the `const TCHAR*` from an `FName`, you use `FName::operator*()`, defined inline in `UnName.h`:

```cpp
// From sdk/Raven_Shield_C_SDK/432Core/Inc/UnName.h, line 67
const TCHAR* operator*() const {
    return Names(Index)->Name;
}
```

So to return the text of a notify, we:
1. Access the notify entry: `notifyArray + notifyIndex * 12 + 4` → the `FName` field
2. Load it into a local `FName`
3. Dereference with `*name` to get the `const TCHAR*`

```cpp
const TCHAR* UVertMeshInstance::AnimGetNotifyText(void* Channel, INT notifyIndex) {
    BYTE* notifyArray = *(BYTE**)((BYTE*)Channel + 0x1C);
    FName name = *(FName*)(notifyArray + notifyIndex * 12 + 4);
    return *name;
}
```

`TArray::Data` is a pointer to the actual array storage, so we dereference `Channel+0x1C` to get the data pointer, then offset into it.

---

## Part 2: A Configuration Bug (Batch 137)

One of the most satisfying discoveries in this stretch was catching a real bug.

### When `TEXT("Input")` Isn't "Input"

`UInput::StaticConfigName()` is a virtual method that tells the engine which config section to read settings from. Our stub was returning `TEXT("Input")`, which seemed completely sensible for an input system.

Then we did what we always do: read the actual bytes from the retail `Engine.dll`. The function is only 6 bytes:

```asm
B8 24 C1 52 10  ; MOV EAX, 0x1052C124
C3              ; RET
```

It just returns a pointer into `.rdata`. So we read those bytes directly from the PE:

```python
# VA 0x1052C124: read 16 UTF-16 bytes
55 00 73 00 65 00 72 00 00 00 ...
```

That's `"User"` in UTF-16. Not `"Input"`.

Both `UInput::StaticConfigName` and `UInputPlanning::StaticConfigName` return the same address and therefore the same string: `"User"`. The fix was a one-character change in the stub, but it matters for config file parsing — if they returned `"Input"`, key bindings from the `.ini` would load from the wrong section.

This is a great example of why we verify against the retail binary rather than just guessing at "obviously correct" implementations. The name `UInput` strongly suggests `"Input"` as the config section, but the game engineers chose `"User"` probably to match the Unreal standard convention for user-facing settings.

---

## Part 3: UCanvas Field Archaeology (Batch 138)

`UCanvas` is the engine's 2D rendering context — used to draw HUD elements, text, tiles, and everything that overlays on screen. We had several stubbed methods in `EngineStubs.cpp` that needed implementing: `SetClip`, `StartFade`, and `SetVirtualSize`.

### Mapping the UCanvas Memory Layout

Each one of these methods writes to specific byte offsets on `this`. Between them, we mapped out a solid chunk of UCanvas's memory layout:

| Offset | Type   | Description |
|--------|--------|-------------|
| +0x38  | float  | Clip X |
| +0x3C  | float  | Clip Y |
| +0x40  | float  | Clip Width / OrgX |
| +0x44  | float  | Clip Height / OrgY |
| +0x48  | float  | ClipW × 0.5 |
| +0x4C  | float  | ClipH × 0.5 |
| +0x50  | int    | Clip flags (cleared by SetClip) |
| +0x54  | int    | Clip flags (cleared by SetClip) |
| +0x94  | float  | Stretch X |
| +0x98  | float  | Stretch Y |
| +0x9C  | float  | Virtual output width |
| +0xA0  | float  | Virtual output height |
| +0xA4  | float  | Current virtual width (guard) |
| +0xA8  | float  | Current virtual height (guard) |
| +0xB8  | DWORD  | Fade state bits |
| +0xBC  | FColor | EndColor |
| +0xC0  | FColor | FromColor |
| +0xC4  | float  | Fade time |
| +0xC8  | DWORD  | Pending fade (cleared to 0) |

This kind of reverse engineering — building up a field map from write patterns — is one of the more satisfying parts of the process. Three separate functions each wrote to distinct offsets, and together they painted a picture of the object's structure.

### SetClip and the 0.5f Constant

`SetClip` looks straightforward on the surface: take four integer clip coordinates and store them. But the retail assembly also multiplied ClipW and ClipH by a constant loaded from `.rdata`:

```asm
FMUL [0x1052C608]   ; multiply FP value by constant at this address
```

We read those bytes from the PE:

```
VA 0x1052C608: 00 00 00 3F  → float = 0.5f
```

So the engine stores half-width and half-height as precomputed values at offsets +0x48 and +0x4C. Likely used by rendering code to compute center points or UV coordinates without needing a divide.

The clean implementation:

```cpp
void UCanvas::SetClip(INT ClipX, INT ClipY, INT ClipW, INT ClipH) {
    *(INT*)((BYTE*)this + 0x50) = 0;
    *(INT*)((BYTE*)this + 0x54) = 0;
    *(FLOAT*)((BYTE*)this + 0x38) = (FLOAT)ClipX;
    *(FLOAT*)((BYTE*)this + 0x3C) = (FLOAT)ClipY;
    *(FLOAT*)((BYTE*)this + 0x40) = (FLOAT)ClipW;
    *(FLOAT*)((BYTE*)this + 0x44) = (FLOAT)ClipH;
    *(FLOAT*)((BYTE*)this + 0x48) = ClipW * 0.5f;
    *(FLOAT*)((BYTE*)this + 0x4C) = ClipH * 0.5f;
}
```

### SetVirtualSize and the FUCOMPP+JP Pattern

`SetVirtualSize` had an interesting guard condition involving floating-point comparisons. The retail assembly uses:

```asm
FUCOMPP         ; compare ST0, ST1 and pop both (sets FPU status word)
FNSTSW AX       ; copy FPU status word into AX
TEST AH, 0x44   ; check parity + carry (C2 and C0 bits)
JP skip         ; jump if parity (i.e., C2 or C0 set → "unordered or less")
```

This is how MSVC implements `if (a < b)` with the x87 FPU. The `0x44` mask checks both the C0 bit (set when the first operand is less) and the C2 bit (set when operands are unordered — NaN). The `JP` instruction fires when the parity flag reflects an even count of those bits, which in practice means "the comparison fired for less-than or unordered."

In C++ terms: `if (VirtualX < OrgX) return;` — skip the virtual size update if the new virtual dimensions don't exceed the origin clip region.

```cpp
void UCanvas::SetVirtualSize(FLOAT SizeX, FLOAT SizeY) {
    if (*(FLOAT*)((BYTE*)this + 0xA4) < *(FLOAT*)((BYTE*)this + 0x40)) return;
    if (*(FLOAT*)((BYTE*)this + 0xA8) < *(FLOAT*)((BYTE*)this + 0x44)) return;
    *(FLOAT*)((BYTE*)this + 0x9C) = SizeX;
    *(FLOAT*)((BYTE*)this + 0xA0) = SizeY;
}
```

### UFont::RemapChar — A Divergence

`RemapChar` converts a character code using an optional remapping table (for CJK font support). The retail code is 15 bytes:

```asm
MOV EAX, [ECX+0x50]   ; load remap table pointer
TEST EAX, EAX
JNZ +8                 ; if non-null, jump to CJK lookup (at adjacent function)
MOVZX EAX, WORD [ESP+4]
RET 4
```

When the remap table is NULL (the common Western case), it just passes the character back unchanged. When the table is non-null, however, the retail jumps *past the end of the function* into a CJK helper that lives in adjacent memory. That helper isn't declared in our headers, so for the non-null path we diverge: we return the character unchanged and document the divergence.

---

## Part 4: Channel Getters Batch (Batches 138–139)

The final push in this stretch completed the animation channel getter family. Remember from blog 39 that `USkeletalMeshInstance` tracks animation channels via a `TArray<FMeshAnimChannel>` at `this+0x10C`, with each channel element being 116 bytes (`0x74`) wide.

We already had `SetAnimFrame`, `GetActiveAnimFrame`, `GetActiveAnimRate`, `GetActiveAnimSequence`. This time we filled in their non-"Active" counterparts:

| Function | Element Offset | Description |
|----------|---------------|-------------|
| `GetAnimChannelCount` | N/A | Returns `TArray.Num` (this+0x110) |
| `GetAnimFrame` | +0x10 | Current frame float |
| `GetAnimSequence` | +0x08 | Current sequence FName |
| `GetBlendAlpha` | +0x50 | Blend weight float |

The "Active" variants and these non-Active versions appear to access the **same data**. The distinction in naming might be a UScript/Kismet API distinction that doesn't affect the underlying data path — or the "Active" variants may reflect a slightly different layer in the animation state machine (primary vs. blended). Either way, the assembly confirmed they read identical memory.

`GetAnimChannelCount` is interesting — it's only 12 bytes:

```asm
ADD ECX, 0x10C   ; adjust 'this' to point at TArray
JMP [IAT]        ; tail-call to TArray::Num()
```

This is a tail-call into the import table. The `JMP [IAT]` pattern means the compiler decided the whole function body is just *forwarding* to a TArray method. In our C++ reimplementation we just read the field directly:

```cpp
int USkeletalMeshInstance::GetAnimChannelCount() {
    return *(INT*)((BYTE*)this + 0x110); // TArray.Data=+0x10C, Num=+0x110
}
```

---

## Running Total

We're at **batch 139**. Fifteen more stubs implemented across four batches, with no regressions and a clean build throughout. The animation system is getting well-charted; the remaining skeletal mesh stubs tend to be the complex ones involving vtable dispatch chains and memory allocation — those will need more time.

Next up: continuing through the stub list, and writing more of the engine's canvas and rendering infrastructure.
