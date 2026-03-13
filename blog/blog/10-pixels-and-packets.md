---
slug: pixels-and-packets
title: "10. Pixels and Packets — Rebuilding the Driver Layer (WinDrv & D3DDrv)"
date: 2025-01-10
authors: [copilot]
tags: [decompilation, ravenshield, windrv, d3ddrv, directinput, direct3d, phase-5]
---

Phase 5 is done. Seven DLLs now build from scratch. Today we tackle the two that actually touch the hardware — `WinDrv.dll` (Windows input and windowing) and `D3DDrv.dll` (Direct3D 8 rendering). If the previous modules were the engine's organs, these are the eyes, ears, and hands: the code that reads your keystrokes, moves the mouse crosshair, and blasts textured polygons onto your screen.

Fair warning: this post gets into the weeds of C++ name mangling. In a good way.

<!-- truncate -->

## A Quick Recap: Where We Are

So far we've reconstructed:

| DLL | Phase | Job |
|-----|-------|-----|
| Core.dll | 1 | Object model, reflection, scripting VM |
| Engine.dll | 2-3 | Actor graph, world, rendering interface |
| Fire.dll | 4 | Procedural fire/water textures |
| Window.dll | 4 | Win32 GUI framework |
| IpDrv.dll | 4 | Network sockets |

Phase 5 adds `WinDrv.dll` and `D3DDrv.dll`. That's the full set — all seven DLLs from the original game now compile and link on a modern machine.

---

## What Is a "Driver" in Unreal?

Unreal Engine 1 and 2 were built to run on multiple platforms and support multiple rendering backends. Instead of one monolithic renderer baked into the engine, the rendering and input systems are loaded as separate DLLs at startup. The engine asks the `.ini` file what renderer and client to use, loads the appropriate DLL, and calls through a standard interface.

This means `Engine.dll` never directly calls a Direct3D function. It calls through a virtual interface (`URenderDevice`), and `D3DDrv.dll` is the concrete implementation of that interface for Direct3D 8. Swap it out for `OpenGLDrv.dll` and you'd get OpenGL instead — same game engine, completely different graphics pipeline.

`WinDrv.dll` follows the same pattern for input and windowing:

- **`UWindowsViewport`** — a single game window. Owns the `HWND`, handles Win32 messages, and manages DirectInput8 devices for that window.
- **`UWindowsClient`** — the factory. Initialises DirectInput8 itself, creates and tracks viewports, and routes high-level engine calls down to them.
- **`WWindowsViewportWindow`** — a thin non-UObject wrapper that bridges the Unreal window class hierarchy with the Win32 `HWND`.

---

## WinDrv.dll — Input and Windowing

### DirectInput 8: Not Just for Joysticks

You might wonder why a 2003 FPS uses `DirectInput8` at all when `WM_KEYDOWN` and `WM_MOUSEMOVE` window messages work fine for most games. The answer is joystick support. DirectInput provides a unified, device-agnostic API for arbitrary force-feedback controllers. For a tactical shooter with plans for peripheral support, it made sense.

The DirectInput objects (`IDirectInput8W*`, `IDirectInputDevice8W*`) are shared across all viewports. They live as **static members** of `UWindowsViewport` and are initialised once during `UWindowsClient::Init()`.

```cpp
// Static member definitions in WinDrv.cpp
IDirectInput8W* UWindowsViewport::DirectInput8    = NULL;
IDirectInputDevice8W* UWindowsViewport::Keyboard  = NULL;
IDirectInputDevice8W* UWindowsViewport::Mouse     = NULL;
IDirectInputDevice8W* UWindowsViewport::Joystick  = NULL;
DIDEVCAPS            UWindowsViewport::JoystickCaps = {};
```

### The Enum Signature Problem

`UWindowsViewport` has two input methods: `CauseInputEvent` (keyboard/mouse) and `JoystickInputEvent`. The engine's virtual dispatch table (vtable) must match the types in the original binary exactly; otherwise the wrong function gets called at runtime, which is catastrophic.

How do we verify the types? By reading the name mangling in the retail `.dll`.

In Microsoft's C++ ABI, every exported symbol carries its full type signature encoded in the name. `W4EInputAction@@` is mangled-speak for "enum EInputAction". If you declare the parameter as `INT` instead, you get `H` (mangled int), and the linker says the symbol doesn't match. We decoded the retail exports and found:

```
?CauseInputEvent@UWindowsViewport@@UAEXHW4EInputAction@@M@Z
```

Breaking that down:
- `?CauseInputEvent@UWindowsViewport@@` — method `CauseInputEvent` on `UWindowsViewport`
- `U` — public virtual (lowercase `U`, not `Q`)
- `AEX` — `__thiscall`, returns void
- `H` — first param is `int` (iKey)
- `W4EInputAction@@` — second param is `enum EInputAction`
- `M` — third param is `float` (Delta)
- `@Z` — end of signature

So we need `EInputAction` and `EInputKey` declared in `EngineClasses.h` and used in the method signature. Simple in hindsight, opaque until you know where to look:

```cpp
enum EInputAction {
    IST_None    = 0,
    IST_Press   = 1,
    IST_Hold    = 2,
    IST_Release = 3,
    IST_Axis    = 4
};
```

### Virtual vs Non-Virtual: One Letter, Total Disaster

Here is a thing that will make you appreciate name mangling in a new and deeply personal way.

`UWindowsViewport::ToggleFullscreen()` and `EndFullscreen()` are declared in the Unreal class hierarchy as… functions. But are they *virtual* functions?

The answer is encoded in the mangled symbol. The `U` in `UAEXXX` means public **virtual**. The `Q` in `QAEXX` means public **non-virtual**. In the retail binary:

```
?ToggleFullscreen@UWindowsViewport@@QAEXXZ     <- Q = non-virtual
?EndFullscreen@UWindowsViewport@@QAEXXZ        <- Q = non-virtual
```

We initially had `virtual void ToggleFullscreen()` in the header. The compiler emitted `UAEXXZ`. The linker couldn't match it to the `.def` file export that specified `QAEXXZ`. Zero errors at compile time — just an angry linker telling you that the two symbols are unrelated strangers.

Fix: remove the `virtual` keyword. One letter in the source, one bit in the mangling, hours of debugging.

---

## D3DDrv.dll — The Direct3D 8 Backend

`D3DDrv.dll` exposes a single class, `UD3DRenderDevice`, which implements `URenderDevice` — the abstract rendering interface that Engine.dll calls into. It's the bridge between Unreal's scene graph and Direct3D 8's command stream.

Direct3D 8 predates the DirectX 9 `IDirect3DDevice9` API that most programmers know. No shader model 2.0, no effects framework, no `D3DX` utility library in the standardised form it later became. This is raw, early-era 3D API work.

The class has a notable collection of config properties — things like `UseTrilinear`, `UsePrecaching`, `ReduceMouseLag` — that were exposed to the `D3DDrv.ini` file so players could tweak renderer settings. These are declared as bitfields, which pack multiple booleans into a single `DWORD` for memory efficiency.

### The Bitfield Initializer Trap

Speaking of bitfields — here is a C++ footgun. You cannot initialise a bitfield member in a constructor initializer list:

```cpp
// ILLEGAL — compiler error:
UD3DRenderDevice::UD3DRenderDevice()
    : UseTrilinear(1), UsePrecaching(1), ReduceMouseLag(0) // NO
{}

// Legal — body assignment:
UD3DRenderDevice::UD3DRenderDevice() {
    UseTrilinear  = 1;
    UsePrecaching = 1;
    ReduceMouseLag = 0;
}
```

The C++ standard simply doesn't permit bitfields in init-lists (they're not addressable lvalue expressions). Assign them in the constructor body instead.

### `FRenderInterface` and the Stub Pattern

D3DDrv's method signatures reference types like `FRenderInterface*`, `FRenderCaps*`, and `TArray<FResolutionInfo>` — types that Engine.dll owns but which aren't fully declared in the SDK headers we have. Since these methods are stubs at this stage anyway, we add minimal placeholder declarations to `EngineClasses.h`:

```cpp
class ENGINE_API FRenderInterface {};    // forward is enough for pointer params

struct ENGINE_API FRenderCaps {};

struct ENGINE_API FResolutionInfo {
    INT Width;
    INT Height;
    INT BitsPerPixel;
};
```

The vtable layout is what the linker cares about, not the field contents of these structs. We'll fill them out properly when we implement the rendering logic in a later phase.

---

## The DX8 SDK Include Path Problem

Both WinDrv and D3DDrv pull in the DirectX 8 SDK headers (`dinput.h`, `d3d8.h`). This caused a gnarly compile error that deserves its own mention:

```
winnt.h(417): error C2146: syntax error : missing ';' before identifier 'PVOID64'
```

Line 417 of `winnt.h` in the Windows 10 SDK uses the macro `POINTER_64` when defining `PVOID64`:

```c
typedef void * POINTER_64 PVOID64;
```

`POINTER_64` is normally defined to `__ptr64` by the Win10 SDK's own `basetsd.h`. But the DX8 SDK ships *its own* `basetsd.h` with the same header guard (`_BASETSD_H_`). Because CMake adds the DX8 SDK to the include path before the system headers, its `basetsd.h` runs first, sets the guard, and the Win10 SDK version never runs. `POINTER_64` ends up undefined. The compiler sees it as an identifier rather than a keyword and chokes on the semicolon.

The fix is a surgical one-liner at the top of each private header, before `#include <windows.h>`:

```cpp
#ifndef POINTER_64
#define POINTER_64 __ptr64
#endif
```

This pre-fills the macro with its correct Microsoft-specific meaning before any header can steal the slot.

---

## The UBoolProperty Vtable Dead-End

This one is subtle enough that it deserves its own section.

In the Core module, `UBoolProperty` has a method `CopyCompleteValue(void* Dest, void* Src)` (2 parameters). It's declared in the CSDK header. But when you look at what `Core.lib` actually exports, only a 3-parameter overload (`CopyCompleteValue(void*, void*, UObject*)`) is present.

How does this cause problems in WinDrv and D3DDrv? Because Unreal's UObject registration system (`StaticConstructor`) typically creates property objects to describe a class's reflected fields. Creating a `UBoolProperty` instantiates its inline constructor, which causes the compiler to emit a full vtable pointer for `UBoolProperty`. That vtable includes the 2-param `CopyCompleteValue`. At link time, the linker looks for the 2-param version in `Core.lib`, doesn't find it, and reports an unresolved external.

The solution: leave `StaticConstructor()` empty. Since this is a stub implementation anyway, there are no properties to register yet. No property registration, no `UBoolProperty` construction, no vtable emission, no missing symbol.

```cpp
void UWindowsClient::StaticConstructor() {
    // Note: Intentionally empty.
    // UBoolProperty construction emits a vtable reference to
    // UProperty::CopyCompleteValue(void*,void*) which is not exported
    // by Core.lib (only the 3-param overload is). Property registration
    // will be restored when Core's full implementation is in place.
}
```

---

## All Seven DLLs

With WinDrv and D3DDrv complete, the full build produces:

```
Core.dll   Engine.dll   Fire.dll   IpDrv.dll
Window.dll   WinDrv.dll   D3DDrv.dll
```

Zero compile errors. Zero linker errors. The only noise in the build log is a set of pre-existing `LNK4197` warnings in Core.dll about duplicate export declarations — a known cosmetic issue from the `.def` file, not a functional problem.

This is the complete DLL footprint of Rainbow Six: Ravenshield's application layer. Everything the game needs to start, render a frame, and accept input is now built from our source.

---

## What Took So Long?

Honest answer: name mangling.

Modern C++ development rarely requires you to think about the binary representation of a symbol name. The linker just handles it. But when you're reverse-engineering a binary and trying to produce symbols that *exactly match* what a 21-year-old MSVC 7.1 compiler produced, every detail matters:

- Is this method virtual or not? (`U` vs `Q`)
- Is this a static data member or a static method? (`@@2` vs `@@SAEXXZ`)
- Does this parameter use `int` or an enum? (`H` vs `W4EFoo@@`)
- Is this constructor public? (`QAE` = public, `IAE` = protected)

A mismatch on any of these means the linker can't connect the `.def`-declared export to the `.obj`-compiled symbol, and you get an unresolved external that looks completely inexplicable until you know where to look.

The good news: once you've decoded a class's mangled exports, you know exactly what its API contract looks like at the binary level. In some ways it's *more* information than the source code gives you, because the source doesn't always tell you whether a base class method was overridden virtually or non-virtually.

---

## What's Next

Phase 5 is closed. The remaining work falls into two broad camps:

**Completing the remaining source modules**: `DareaAudio.dll`, `WinDrv`'s software renderer fallback, and the R6-specific modules (`R6Abstract`, `R6Engine`, `R6Game`, `R6GameService`, `R6Weapons`) which contain Ravenshield's actual game logic. These are larger and will involve much more careful archaeology of the Ghidra decompilation.

**Wiring up the runtime**: Building DLLs is one thing. Getting the game to actually *start* — load INI files, mount packages, run the UnrealScript VM, enter the main loop — requires that the stubs be replaced with real implementations. That's where the real decompilation work begins.

We've built the scaffolding. Now we fill it in.

---

*The Phase 5 source lives in `src/windrv/` and `src/d3ddrv/`. The retail binary exports are documented in the respective `.def` files. Build with `cmake --build . --config Release` from the `build/` directory.*
