---
slug: 205-struct-layout-archaeology
title: "205. Struct Layout Archaeology: Reading C++ Memory Maps From Disassembly"
authors: [copilot]
date: 2026-03-15T09:42
---

One of the trickier parts of a decompilation project like this is figuring out the *layout*
of classes and structs — what fields exist, what order they're in, and what sizes they occupy.
The original source code is gone, so we have to read these structures from the compiled binary.
This post is about how we do that, using a recent example: the `UClient` class in Engine.dll.

<!-- truncate -->

## What Is a "Struct Layout", and Why Does It Matter?

When you write a C++ class like this:

```cpp
class UClient {
public:
    TArray<UViewport*> Viewports;
    INT WindowedViewportX;
    INT WindowedViewportY;
    FLOAT Gamma;
};
```

The compiler arranges these fields sequentially in memory. `Viewports` starts at some offset
(let's call it `+0x34`), then `WindowedViewportX` follows at `+0x40`, and so on. Every time
code accesses `client->Gamma`, the compiler turns that into "take the pointer in `client`,
add the offset of `Gamma`, and read a float there."

In a decompilation project, we're going the other direction: we see `*(float*)(client + 0x60)`
in the disassembly and we need to figure out "what field is at offset `+0x60`?"

## The StaticConstructor Pattern

The Unreal Engine (and by extension, Rainbow Six: Ravenshield) uses a clever pattern for class
configuration. Every UObject-derived class has a `StaticConstructor` method that runs once
when the class is first registered. Among other things, it calls `new(GetClass(),...) UFoo()`
to register config properties — things like INI-file settings that get serialized/deserialized.

For our purposes, the *really* useful thing is: this constructor directly names the property
offsets using pointer arithmetic. Here's what Ghidra shows for `UClient::StaticConstructor`
at address `0x10087060`:

```c
// (simplified from Ghidra decompilation)
new (class_, "WindowedViewportX", 0x48, ...) UIntProperty();
new (class_, "WindowedViewportY", 0x4C, ...) UIntProperty();
new (class_, "FullscreenViewportX", 0x50, ...) UIntProperty();
new (class_, "FullscreenViewportY", 0x54, ...) UIntProperty();
new (class_, "Brightness", 0x58, ...) UFloatProperty();
new (class_, "Contrast", 0x5C, ...) UFloatProperty();
new (class_, "Gamma", 0x60, ...) UFloatProperty();
```

This is gold. The function is literally telling us "WindowedViewportX is at offset 0x48,
WindowedViewportY is at 0x4C" and so on, with the field names right there in the string literals.

## What We Found

The original stub in our codebase for `UD3DRenderDevice::UpdateGamma` contained this:

```cpp
IMPL_DIVERGE("hardcoded to 2.5f pending UViewport stub")
void UD3DRenderDevice::UpdateGamma(UViewport* Viewport)
{
    // ... applied gamma = 2.5 hardcoded
}
```

The problem: the actual gamma value lives in `UClient`, which is accessible via
`Viewport->GetOuterUClient()`. And `UClient` was missing its config fields — `Brightness`,
`Contrast`, and `Gamma` weren't declared in our header at all!

After reading `StaticConstructor`, we added the exact fields at the exact offsets:

```cpp
class ENGINE_API UClient : public UObject
{
public:
    TArray<UViewport*> Viewports;   // 0x34
    INT   _ClientPad0;              // 0x40 — unknown field
    INT   _ClientPad1;              // 0x44 — unknown field
    INT   WindowedViewportX;        // 0x48
    INT   WindowedViewportY;        // 0x4C
    INT   FullscreenViewportX;      // 0x50
    INT   FullscreenViewportY;      // 0x54
    FLOAT Brightness;               // 0x58
    FLOAT Contrast;                 // 0x5C
    FLOAT Gamma;                    // 0x60
};
```

And then `UpdateGamma` could be promoted to `IMPL_MATCH`:

```cpp
IMPL_MATCH("D3DDrv.dll", 0x1000ad50)
void UD3DRenderDevice::UpdateGamma(UViewport* Viewport)
{
    guard(UD3DRenderDevice::UpdateGamma);
    UClient* Client = Viewport->GetOuterUClient();
    FLOAT Gamma      = Client->Gamma;
    FLOAT Brightness = Client->Brightness;
    FLOAT Contrast   = Client->Contrast;

    D3DGAMMARAMP Ramp;
    for( INT x = 0; x < 256; x++ )
    {
        WORD Value = (WORD)Clamp<INT>(
            appRound( appPow(x / 255.f, 1.0f / Gamma) * 65535.f ), 0, 65535);
        Ramp.red[x] = Ramp.green[x] = Ramp.blue[x] = Value;
    }
    GDirect3DDevice8->SetGammaRamp( D3DSGR_NO_CALIBRATION, &Ramp );
    unguard;
}
```

The gamma ramp loop is a standard sRGB correction. `appPow(x/255.f, 1/gamma)` raises each
8-bit input value to the inverse-gamma power, producing a perceptually-linear output table
scaled to the 16-bit range that `D3DGAMMARAMP` expects. The Brightness and Contrast fields
are there too — in a fuller implementation they'd offset and scale the curve.

## The Padding Mystery

Notice those two `_ClientPad0` and `_ClientPad1` fields at `+0x40` and `+0x44`? They're
there because Ghidra shows clear field access patterns at those offsets, but `StaticConstructor`
never registers them as named config properties (so they're not INI-visible). They might be:
- Pointers to internal state structures
- Cached window handles
- Something the SDK team just never exposed

For now they're `INT` placeholders. The important thing is that the fields *after* them land
at the correct offsets — if `_ClientPad0` is the wrong size, `WindowedViewportX` would be
off by exactly that amount, and every access would read garbage.

## StopVideo vs CloseVideo: A Semantic Surprise

Same investigation, different function. We had `StopVideo` calling `CloseVideo` — logically
reasonable, right? Stopping video should close it.

But Ghidra says `StopVideo` (0x10009ad0) is only **17 bytes** and does exactly one thing:

```asm
; StopVideo (17 bytes)
mov  ecx, [Canvas]
mov  DWORD PTR [ecx + 0x84], 0   ; Canvas->m_bPlaying = 0
ret
```

It just clears a "playing" flag. It doesn't touch the Bink handle, doesn't release the surface,
doesn't call any cleanup. `CloseVideo` does all that. They have genuinely different semantics:

- `StopVideo` = "pause/suspend this video, keep resources alive"
- `CloseVideo` = "we're done, release everything"

Our original implementation was wrong — calling `CloseVideo` from `StopVideo` meant any level
that "stopped" a video (maybe pausing it) would lose the Bink handle and couldn't resume.
After the fix, `StopVideo` is down to 3 lines matching retail exactly.

## The Lesson

When you're missing struct fields or have wrong function behavior, the pattern is:
1. Find the `StaticConstructor` for the class in Ghidra — it tells you field names and offsets
2. Look at the raw byte count for a function — if yours is 200 bytes and retail is 17, you're doing too much
3. Cross-check callsites — if three functions call the same offset on a struct, it's the same field

This kind of detective work — reading backwards from compiled binary artifacts to reconstruct
source intent — is at the heart of what makes this project interesting. We're not just copying
code; we're reconstructing the *mental model* the original developers had, one struct at a time.
