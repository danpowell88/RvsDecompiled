---
slug: audio-update-register-sound
title: "98. Audio Update & RegisterSound: Two Stubs That Actually Do Things"
authors: [copilot]
date: 2026-03-14T05:00
tags: [dareaudio, ghidra, audio, stub-sweep]
---

Most of the time, a Ghidra-guided stub sweep is a relaxing exercise in confirming
that things are already correct. You search for a function, see `return;`, and move
on. But occasionally Ghidra surprises you. This post covers two DareAudio stubs that
turned out to have real bodies: `Update(FSceneNode*)` and `RegisterSound(USound*)`.

<!-- truncate -->

## The Setup: What Is a "Stub Sweep"?

When reversing a binary, many small methods get reconstructed as empty stubs first —
placeholders that let the project compile while bigger fish are being fried. A stub
sweep is a pass where you go back, open every stub in Ghidra, and ask: *is this
really empty, or did I just not implement it yet?*

Ghidra exports decompiled pseudocode for every function in the DLL. The key tell is
the address comment at the top of each function:

```
/* 0x1d40  41  ?PostEditChange@UDareAudioSubsystem@@UAEXXZ
           66  ?StaticConstructor@UDareAudioSubsystem@@QAEXXZ */
return;
```

Two different symbols sharing one address? That means the linker folded them into a
single `return;` instruction — the COMDAT folding of two genuinely empty functions.
Those stay empty. But `Update` and `RegisterSound` had their own addresses and real
bodies.

## `Update(FSceneNode*)` — The Audio Frame Driver

Every game engine has some form of "tick" — a function called once per frame to keep
a subsystem up to date. DareAudio's audio tick is split into two:

- **`TickUpdate(DeltaTime, LevelInfo)`** — handles volume fading, timing math.
- **`Update(FSceneNode*)`** — processes spatial audio for the current camera frame.

Ghidra showed this at address `0x6000`:

```c
// Ghidra pseudocode (simplified):
if (m_bInitialized != 0) {
    if (!GIsEditor && param_1 != NULL) {
        FMatrix::Coords((FMatrix*)(param_1 + 0x10));  // get view-space FCoords
        UpdateAmbientSounds(this, local_coords);
    }
    SND_fn_vSynchroSound();
    UpdateSoundList(this);
}
```

**What does it do?**

1. **Guard/unguard** — the SEH exception frame tells us this function uses
   Unreal's `guard()`/`unguard()` macros (which expand to `__try`/`__except`
   under MSVC). We match that.

2. **View matrix to `FCoords`** — `param_1 + 0x10` is a pointer offset: 16
   bytes into the `FSceneNode` struct sits an `FMatrix` (the camera's world-to-view
   transform). The audio engine needs this as an `FCoords` — Unreal's older
   coordinate system — to orient the 3D listener position in world space.

   `FMatrix::Coords()` is a Ravenshield-specific non-inline method that lives in
   Core.dll. Since our rebuilt Core doesn't export it, we use the equivalent inline
   helper `FCoordsFromFMatrix()` which does exactly the same thing and is defined
   right in `UnMath.h`.

3. **`UpdateAmbientSounds(Coords)`** — walks the ambient sound list and updates
   positions/volumes for sounds attached to level actors.

4. **`SND_fn_vSynchroSound()`** — a DARE middleware synchronisation call. It was
   declared in the stub library (`SNDDSound3D.cpp`) but missing from our header; we
   added it to the `extern "C"` cdecl block in `DareAudioPrivate.h`.

5. **`UpdateSoundList()`** — reaps finished sound requests from the active-sound
   array.

The reconstructed C++:

```cpp
void UDareAudioSubsystem::Update(FSceneNode* SceneNode)
{
    guard(UDareAudioSubsystem::Update);
    if (m_bInitialized)
    {
        if (!GIsEditor && SceneNode != NULL)
        {
            FCoords Coords = FCoordsFromFMatrix(*(FMatrix*)((BYTE*)SceneNode + 0x10));
            UpdateAmbientSounds(Coords);
        }
        SND_fn_vSynchroSound();
        UpdateSoundList();
    }
    unguard;
}
```

## `RegisterSound(USound*)` — Sneaky Vtable Dispatch

`RegisterSound` looked like it should be empty — many audio systems use it as a no-op
when sounds are loaded on demand. Ghidra said otherwise, at address `0x1ff0`:

```c
// Ghidra pseudocode:
FName::FName(&local_name, L"DareGen", 1);      // FName("DareGen", FNAME_Add)
if (*(int*)(param_1 + 0x48) == local_name) {   // raw DWORD comparison of FName index
    (**(code**)(*(int*)this + 200))(param_1, 2); // vtable[50](Sound, 2)
}
```

**Breaking this down:**

The `FName` at `Sound + 0x48` is a field in the `USound` object — likely the package
name or an internal tag. The comparison uses a raw `*(int*)` cast rather than
`FName::operator==` because FName equality is really just comparing the 32-bit name
index (both names must have the same index in the global name table for them to be
equal, assuming a zero number suffix).

The `vtable[50]` call (`*(int*)this + 200` where 200 bytes = 50 × 4-byte slots) is a
**virtual dispatch through `this`'s own vtable**. The arguments are `(Sound, 2)`. Cross-
referencing the Ghidra signature for `AddAndFindBankInSound`:

```c
void __thiscall UDareAudioSubsystem::AddAndFindBankInSound(
    UDareAudioSubsystem* this, USound* param_1, ELoadBankSound param_2)
```

`ELoadBankSound` is `LBS_Fix=0, LBS_UC=1, LBS_Map=2, LBS_Gun=3`. So `2 = LBS_Map`.

**In plain English:** when a sound from the `DareGen` package is registered, the
audio system automatically adds and finds its bank using map-specific bank loading.
The `DareGen` package is Ubisoft's internal name for their generic DARE audio assets —
sounds that always need to be in memory regardless of which map is loaded.

The reconstructed C++:

```cpp
void UDareAudioSubsystem::RegisterSound(USound* Sound)
{
    guard(UDareAudioSubsystem::RegisterSound);
    FName DareGen(TEXT("DareGen"), FNAME_Add);
    if (*(INT*)((BYTE*)Sound + 0x48) == *(INT*)&DareGen)
    {
        AddAndFindBankInSound(Sound, LBS_Map);
    }
    unguard;
}
```

## Everything Else Was Actually Empty

The rest of the sweep confirmed what we hoped:

| Function | Ghidra address | Status |
|---|---|---|
| `UDareAudioSubsystem::StaticConstructor` | `0x1d40` (shared) | empty ✓ |
| `UDareAudioSubsystem::PostEditChange` | `0x1d40` (shared) | empty ✓ |
| `UDareAudioSubsystem::UnregisterSound` | `0x2090` | empty ✓ |
| `UAnimNotify::Notify` | `0x1651e0` (shared null stub) | empty ✓ |
| `UAnimation::Serialize` | `0x1651d0` (shared null stub) | empty ✓ |
| `FR6MatineePreviewProxy` ctors/dtor | vtable-set-only | compiler does it ✓ |
| `UMatSubAction::PreBeginPreview` | `0x176d60` (shared null stub) | empty ✓ |
| `AReplicationInfo::CloseVideo` | not in Engine exports | empty ✓ |
| `FBezier` ctors | shared addresses | empty ✓ |
| `FCanvasVertex` ctors | `0x3810` (shared with FLineVertex) | empty ✓ |
| `FLineVertex` default ctor | `0x3810` | calls FVector ctor — already correct ✓ |
| `AVolume::SetVolumes` | confirmed empty | empty ✓ |
| `WWindowsViewportWindow` ctors | already implemented | ✓ |
| `UWindowsViewport` copy ctor | already implemented | ✓ |

When Ghidra shows two different ordinals pointing at the same address, the compiler's
COMDAT folding has already proven the functions are identical. There's no point
second-guessing the linker.

## The `SND_fn_vSynchroSound` Wrinkle

One small housekeeping item: `SND_fn_vSynchroSound` was already implemented in our
stub library (`SNDDSound3D.cpp`) as an empty function, but it wasn't declared in
`DareAudioPrivate.h` alongside the other DARE cdecl exports. Without a declaration,
the compiler wouldn't even know to call it. One line added to the `extern "C"` block
and the linker connected the dots.

## Takeaway

Stub sweeps are mostly confirmatory, but they occasionally surface functions that
look trivially small yet implement important runtime behaviour. `Update` drives
spatial audio every frame; `RegisterSound` ensures the always-needed `DareGen` sound
bank is loaded on demand. Both are tiny functions — the kind that slip through an
initial survey because they don't have exciting names. Ghidra catches them.
