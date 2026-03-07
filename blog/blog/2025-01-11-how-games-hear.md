---
slug: how-games-hear
title: "How Games Hear — The DARE Audio System"
authors: [rvs-team]
tags: [decompilation, ravenshield, audio, dare, directsound, phase-7]
---

Phase 7 is something special. Every phase before this had *some* source code to guide us — UT99 reference, SDK headers, UnrealScript. Phase 7 has **nothing**. The entire audio system was written by Ubi Soft Montreal's internal DARE team, and no public source has ever surfaced. We rebuilt all 7 audio DLLs from nothing but `dumpbin /exports` output and Ghidra analysis.

<!-- truncate -->

## What Is an Audio System, Anyway?

Before we get into the reverse engineering, let's talk about what a game audio system actually *does*. If you come from web development or business applications, you might think "play a sound file, how hard can it be?" The answer is: surprisingly hard, once you need to do it in real time with spatial positioning.

A game audio system has to:

1. **Manage sound banks** — load compressed audio data from disk into memory, organized by category (footsteps, gunshots, ambient, music)
2. **Position sounds in 3D space** — a gunshot behind you should be louder in your right ear; a helicopter overhead should pan correctly as you look around
3. **Mix channels** — blend dozens of simultaneous sounds without clipping, respecting volume categories (effects vs. music vs. dialogue)
4. **Stream music** — play background tracks without loading the entire file into RAM
5. **Apply effects** — reverb for indoor spaces, distance rolloff curves, HRTF (head-related transfer function) for headphone surround simulation
6. **Respond to gameplay** — fade music during a hostage rescue, silence ambient sound when a flashbang goes off, duck effects when dialogue plays

Unreal Engine's `UAudioSubsystem` defines the *interface* for all of this. Each game provides its own *implementation*. Ravenshield uses Ubi's proprietary DARE engine.

## The Three-Layer Stack

The DARE audio system isn't one DLL — it's a stack of three layers, each with a clear responsibility:

```
┌─────────────────────────────────────────┐
│  DareAudio.dll                          │
│  "The Bridge"                           │
│  Translates Unreal concepts → DARE API  │
│  UDareAudioSubsystem : UAudioSubsystem  │
└─────────────────┬───────────────────────┘
                  │ links
┌─────────────────▼───────────────────────┐
│  SNDDSound3DDLL_ret.dll                 │
│  "The Backend"                          │
│  DirectSound3D implementation           │
│  265 exported C functions               │
└─────────────────┬───────────────────────┘
                  │ links
┌─────────────────▼───────────────────────┐
│  SNDext_ret.dll                         │
│  "The Platform Layer"                   │
│  Memory, file I/O, threading            │
│  32 exported C functions                │
└─────────────────────────────────────────┘
```

This is a classic *dependency inversion* pattern — the high-level audio logic doesn't know or care whether it's running on DirectSound, OpenAL, or a PlayStation 2 SPU. The backend talks to the actual hardware API, and the platform layer abstracts away the OS primitives. DARE was Ubi's cross-platform audio solution, used across multiple titles, so this three-layer structure makes perfect sense.

### Why Three DLL Variants?

The retail install ships these seven audio DLLs:

| DLL | Links Against | Purpose |
|-----|---------------|---------|
| `DareAudio.dll` | `SNDDSound3DDLL_ret.dll` | Main game audio (retail backend) |
| `DareAudioScript.dll` | `SNDDSound3DDLL_VSR.dll` | UnrealEd/scripting mode (debug backend with 77 extra exports) |
| `DareAudioRelease.dll` | `SNDDSound3DDLL_VBD.dll` | VBD backend variant... but VBD doesn't ship. Dead code. |
| `SNDDSound3DDLL_ret.dll` | `SNDext_ret.dll` | Retail DirectSound3D backend |
| `SNDDSound3DDLL_VSR.dll` | `SNDext_VSR.dll` | VSR (debug/editor) DirectSound3D backend |
| `SNDext_ret.dll` | *(nothing)* | Retail platform abstraction |
| `SNDext_VSR.dll` | *(nothing)* | VSR platform abstraction |

The "ret" suffix means retail, "VSR" is the editor/debug variant, and "VBD" is a third variant that was likely stripped before shipping. Since the VBD DLL doesn't exist in the retail install, `DareAudioRelease.dll` is effectively dead code — we build it linking against ret as a stand-in.

## Starting from Nothing

With previous phases, we could peek at UT99 source code and say "ah, this function probably does something similar to the UT99 version." Not here. DARE is completely proprietary. Our only tools are:

1. **`dumpbin /exports`** — tells us the name and ordinal of every exported function
2. **Ghidra** — decompiles the machine code into approximate C
3. **Educated guessing** — function names like `SND_fn_pvMallocSnd` and `SND_fn_hOpenFileReadSnd` are fairly self-documenting

Here's a sample of what SNDext's export table looks like:

```
ordinal hint RVA      name
      1    0 0000187D _SND_fn_bCloseFileSnd@4
      2    1 000018A0 _SND_fn_bInitStreamAsyncSnd@4
      3    2 000018BF _SND_fn_bSetEndStreamAsyncSnd@8
      ...
     14    D 00001912 _SND_fn_pvMallocSnd@4
     15    E 00001929 _SND_fn_vFreeSnd@4
```

The `@N` suffix tells us these are `__stdcall` calling convention (the N is the number of bytes of parameters). `_SND_fn_pvMallocSnd@4` takes one 4-byte parameter (a size) and returns a pointer — it's a memory allocator. `_SND_fn_vFreeSnd@4` takes a pointer and returns void — it's the corresponding free. These names are practically a specification.

## Building Bottom-Up

We built the stack from the bottom up — platform layer first, then the backend, then the bridge. This is the opposite of how you'd usually approach software design (top-down), but it makes sense for reconstruction: each layer needs the import library of the layer below it to link.

### SNDext: 32 Functions of Pure C

SNDext is the simplest module in the entire project. Thirty-two `__stdcall` C functions with no classes, no vtables, no inheritance. Just plain function pointers that DARE uses to abstract away platform-specific operations:

```cpp
extern "C" __declspec(dllexport) void* __stdcall SND_fn_pvMallocSnd(unsigned long size)
{
    return NULL;
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vFreeSnd(void* ptr)
{
}
```

These stubs don't *do* anything yet — they just establish the correct export signatures so that SNDDSound3D can link against the import library. The real implementations will come in a future audit pass. But for now, having the right function names at the right ordinals is what matters.

### SNDDSound3D: 344 Stubs via Automation

The middle layer is substantially larger. The retail variant exports 265 functions; the VSR variant exports 342. The union of both is 344 unique exports.

Typing 344 function stubs by hand would be tedious and error-prone. So we wrote a Python tool (`tools/gen_snd3d_stubs.py`) that reads `dumpbin /exports` output and generates the C++ source file automatically:

```python
# Parse the dumpbin output to extract function signatures
# Detect calling convention from name mangling:
#   _Name@N  → __stdcall (N = parameter bytes)
#   Name     → __cdecl (no decoration)
#   ?Name@@  → C++ mangled
```

This is where things got interesting. The dumpbin parser initially produced **incorrect results** because dumpbin's header lines look deceptively like export entries:

```
    265 number of functions
    265 number of names
```

The parser saw "265" at the start of a line and treated it as an ordinal — creating phantom exports named `functions` and `names` both at ordinal 265, which produced a duplicate ordinal error at link time. A fun reminder that text parsing is never as simple as you think.

Two of the exports are genuine C++ mangled names:
- `?SND_fn_vDisableHardwareAcceleration@@YAXH@Z` — takes an `int`, returns `void`
- `?SND_fn_vSetHRTFOption@@YAX_SND_tdeHTRFType@@@Z` — takes an HRTF type enum, returns `void`

These reveal that DARE had runtime hardware acceleration control and HRTF (Head-Related Transfer Function) support — the technique that simulates surround sound through regular stereo headphones. Pretty sophisticated for 2003.

The VSR variant also exports two **data symbols** — `liste_of_association` and `liste_of_voices` — global arrays that the editor variant presumably exposes for debugging the voice allocation system. (Yes, the French naming leaked through — DARE was made in Montreal.)

### DareAudio: Where Unreal Meets DARE

The top layer is the most complex because it lives in two worlds simultaneously. On one side, it inherits from `UAudioSubsystem` (Unreal Engine's audio interface). On the other, it calls into the DARE C API exposed by SNDDSound3D.

The class declaration tells the whole story:

```cpp
class DAREAUDIO_API UDareAudioSubsystem : public UAudioSubsystem
{
    DECLARE_CLASS(UDareAudioSubsystem, UAudioSubsystem, 0, DareAudio)

    // Unreal interface
    virtual INT  Init();
    virtual void Destroy();
    virtual void ShutdownAfterError();
    virtual void Update(FSceneNode* Frame);
    virtual void TickUpdate(FLOAT DeltaTime, ALevelInfo* LevelInfo);

    // Sound playback
    virtual INT  PlaySoundW(AActor* Actor, USound* Sound, INT Flags, INT Slot);
    virtual INT  StopSound(AActor* Actor, USound* Sound);
    virtual void StopAllSounds();

    // DARE-specific: sound banks
    virtual void AddSoundBank(FString BankName, ELoadBankSound LoadType);
    virtual void LoadBankMap(ULevel* Level, FString MapName);
    virtual void SetBankInfo(ER6SoundState State);

    // DARE-specific: volume management
    virtual void SND_ChangeVolume_TypeSound(ESoundSlot Slot, FLOAT Volume);
    virtual void SND_FadeSound(FLOAT Duration, INT FadeIn, ESoundSlot Slot);

    // Callbacks: DARE engine calls these to query actor positions
    static void __stdcall GetActorPos(LONG Id, _SND_tdstVectorFloat* Out);
    static void __stdcall GetMicroPos(LONG Id, _SND_tdstVectorFloat* Out);
    static void __stdcall GetActorSpeed(LONG Id, _SND_tdstVectorFloat* Out);
    // ... 9 more static callbacks
};
```

The `static __stdcall` callbacks are the bridge mechanism. When you register a sound source with DARE, you give it an actor ID and a set of callback function pointers. DARE then calls back into these functions every audio tick to ask "where is this actor now? how fast is it moving? what's its rolloff curve?" This callback pattern avoids coupling the DARE engine to Unreal's actor system directly.

## The Missing Constructor Problem

Here's a war story from the build process. DareAudio compiled cleanly but refused to link:

```
error LNK2019: unresolved external symbol "__declspec(dllimport) 
    public: __thiscall UAudioSubsystem::UAudioSubsystem(void)"
```

The default constructor of our parent class wasn't in the SDK's `Engine.lib`. This makes sense — the SDK was made for *mod developers*, who create new gameplay classes, not new audio subsystems. The SDK engineers never expected anyone to subclass `UAudioSubsystem`, so they didn't bother exporting its constructor.

But our *rebuilt* `Engine.dll` (from Phase 3) exports everything the retail binary does — including `UAudioSubsystem::UAudioSubsystem()` at ordinal 6339. The fix was to link DareAudio against our rebuilt Engine's import library instead of the SDK's:

```cmake
set(ENGINE_BUILT_LIB "${CMAKE_BINARY_DIR}/src/engine/Release/Engine.lib")
target_link_libraries(${TARGET_NAME} PRIVATE Core_Dep ${ENGINE_BUILT_LIB} ...)
add_dependencies(${TARGET_NAME} Engine)
```

This is the first time in the project that a later phase *depends on* the output of an earlier phase. Previous phases all linked against the SDK's static import libraries. Phase 7 is the first module that actually needs a DLL we built ourselves. The dependency chain is becoming a directed acyclic graph.

## What's Actually in Those 87 Exports?

All three DareAudio variants export exactly 87 symbols with identical ordinals. Here's the breakdown:

| Range | Content |
|-------|---------|
| @1–@6 | Constructors, destructor, copy assignment, placement new operators |
| @7–@8 | Vtable pointers (FExec interface, UObject interface) |
| @9–@79 | Methods: Init, Destroy, PlaySound, volume control, bank management, callbacks |
| @80–@84 | Static data: volume init array, initialization flag, cached actor pointers |
| @85 | `_DllMain@12` |
| @86 | `GPackage` (the Unreal package name string) |
| @87 | `autoclassUDareAudioSubsystem` (class auto-registration) |

The dual vtable at @7–@8 is worth noticing. `UDareAudioSubsystem` inherits from both `UObject` (through `UAudioSubsystem`) and `FExec` (a command-line execution interface). In C++, when you have multiple inheritance with virtual functions, the compiler generates **two separate vtable pointers** — one for each base class's virtual function table. That's why the retail binary exports both `??_7UDareAudioSubsystem@@6BUObject@@@` and `??_7UDareAudioSubsystem@@6BFExec@@@`.

## The Big Picture

With Phase 7 complete, the full build produces **22 binaries** from source:

```
Core.dll          Engine.dll        Window.dll
Fire.dll          D3DDrv.dll        WinDrv.dll        IpDrv.dll
R6Abstract.dll    R6Engine.dll      R6Game.dll
R6Weapons.dll     R6GameService.dll
DareAudio.dll     DareAudioScript.dll  DareAudioRelease.dll
SNDDSound3DDLL_ret.dll  SNDDSound3DDLL_VSR.dll
SNDext_ret.dll    SNDext_VSR.dll
```

That's everything except `RavenShield.exe` itself (Phase 8). Every DLL the game loads at runtime now has a corresponding source file in our repository.

The audio modules are still stubs — they export the right symbols at the right ordinals, but the function bodies are empty. Filling them in will require careful Ghidra work to reconstruct the DARE engine's internal state machines. That's a Phase 8C problem. For now, the skeleton is in place, the build graph is complete, and the exports match retail.

Next up: the executable itself.
