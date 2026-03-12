---
slug: 43-build-archaeology-and-brush-transforms
title: "43. Build Archaeology and Brush Transforms"
authors: [danpo]
tags: [decompilation, cmake, win32, fcoords, abrush, transforms, batch-158]
---

Batch 158 had a twist. The implementations themselves — four `ABrush` coordinate transform methods — were straightforward once you understood the math. But getting them to *compile* required digging through three separate build system and SDK pathology issues that had been lurking since the project was first set up. This post covers both the implementation archaeology and the build archaeology.

<!-- truncate -->

## The Silent Misconfiguration

The build system for this project uses CMake with the Visual Studio 2019 generator. For a while, Engine.dll was building fine — or so we thought. Checking `CMakeCache.txt` revealed something alarming:

```
CMAKE_GENERATOR_PLATFORM:INTERNAL=
LINK_FLAGS=/machine:x64 /OPT:ICF /OPT:REF
```

The platform field was **empty**. CMake had defaulted to x64 on a 64-bit machine. Engine.dll was being compiled as x86 (the retail binary is `IMAGE_FILE_MACHINE_I386 = 0x014C`), but a stale dll from before the misconfiguration was masking the problem — the linker never ran on the Engine target, so the x64 errors never surfaced.

Once we forced a rebuild of Engine.dll, the assembly errors came out immediately. The SDK's `UnVcWin32.h` contains x86-specific inline assembly (`__asm __emit`) that's illegal in x64 compilation units. The fix was simple but required manually deleting `CMakeCache.txt` and reconfiguring:

```
cmake -B build -G "Visual Studio 16 2019" -A Win32
```

After reconfiguring, `CMAKE_GENERATOR_PLATFORM=Win32` and `/machine:X86`. With Win32 forced, the compile errors became *real* errors — the kind we could actually fix.

## The WORD Problem

With the correct platform, the Engine target now surfaced errors we'd never seen before. First up: `WORD` undeclared.

This is an SDK quirk specific to this codebase. The SDK's `UnVcWin32.h` contains this at line 20:

```c
#undef WORD
```

Windows.h defines `WORD` as `unsigned short`. The SDK deliberately removes it. The reason is probably to avoid collisions with the Unreal scripting layer, which has its own type vocabulary.

The SDK does define `_WORD` (also `unsigned short`). So any code that referenced `WORD*` in stub implementations needed those changed to `_WORD*`. There were 13 instances across `SetHeightmap`, `GetHeightmap`, and an `FRawIndexBuffer` section.

```c
// Before
WORD* heightData = (WORD*)*(BYTE**)(mipsData + 0x1C);
TArray<WORD> indices;

// After
_WORD* heightData = (_WORD*)*(BYTE**)(mipsData + 0x1C);
TArray<_WORD> indices;
```

Similarly, `FALSE` and `TRUE` macros (from `<windef.h>`) aren't guaranteed to survive after the SDK's header processing. One stub had `bForced = FALSE;` which needed to become `bForced = 0;`.

## The Placement New Problem

The trickier issue was placement new. EngineStubs.cpp has about 112 calls of the form:

```cpp
new ((BYTE*)this + 0x04) TSomeType(args...);
```

This is *placement new* — constructing an object at a specific memory address. The standard signature is `operator new(size_t, void*)`.

The problem: `UnFile.h` defines custom `operator new` overloads. When MSVC sees a custom `operator new` in scope, it stops automatically providing the placement overload. The result was C2665 "no overloaded function could convert all argument types" for every single placement new call.

The fix was to explicitly declare placement new *before* the PCH include:

```cpp
// Placement new: MSVC 2019+ with Win32 target requires explicit operator new(size_t,void*)
// when custom operator new overloads are in scope (UnFile.h overrides the allocating forms).
#pragma warning(push)
#pragma warning(disable: 4291) // no matching operator delete found
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EnginePrivate.h"
```

Once the PCH sees the declaration, all 112 placement new calls resolve correctly.

## Duplicate FColor Bodies

After fixing the WORD and placement new issues, the last compile errors were unexpected:

```
EngineStubs.cpp(8647): error C2084: function 'FLOAT FColor::FBrightness() const' already has a body
```

The FColor methods (`FBrightness`, `HiColor565`, `HiColor555`, `operator FVector`) had been implemented in EngineStubs.cpp as out-of-line definitions — but they were already defined *inline* in `Engine.h`:

```cpp
struct FColor {
    FLOAT FBrightness() const
    { return (2.f*R + 3.f*G + B) / 1536.f; }
    // ...
};
```

The EngineStubs.cpp definitions were simply redundant. The inline versions in Engine.h are correct (the BGRA layout analysis from batch 153–155 confirmed the coefficients), so the out-of-line stubs were removed.

## The Missing UVertMeshInstance::AnimIsInGroup

One final linker error: `UVertMeshInstance::AnimIsInGroup` was declared in `EngineClasses.h` and listed in `Engine.def` at ordinal 2288, but had no stub. The method existed for `UMeshInstance` and `USkeletalMeshInstance` but not the vertex mesh variant. Added:

```cpp
int UVertMeshInstance::AnimIsInGroup(void*, FName)
{
    // Retail: 48b. Has complex sub-call — stub returns 0.
    return 0;
}
```

With that, Engine.dll compiled and linked cleanly.

## ABrush Coordinate Transforms

Now for the actual batch 158 work. `ABrush` is the base class for brushes — the convex hulls used to define BSP geometry. It needs to convert between world space and local (brush) space, which involves three transform components:

1. **Rotation** — stored at `Actor::Rotation` (`FRotator`)
2. **Location** — stored at `Actor::Location` (`FVector`), here reinterpreted as a rotation for the transform chain
3. **TempScale** — a `ModelScale` (at `Actor::TempScale`) that packs a scale factor and shear into an `FScaleMatrix`-like structure

The Unreal coordinate transform system uses `FCoords` objects chained with `/` (divide = inverse compose) and `*` (multiply = compose). `ToLocal` converts from world to local — so it's `UnitCoords / all_transforms`. `ToWorld` is the reverse — `UnitCoords * all_transforms_in_reverse_order`.

```cpp
FCoords ABrush::ToLocal() const
{
    FVector sv(Abs<FLOAT>(TempScale.Scale.Z),
               Abs<FLOAT>(TempScale.SheerRate),
               Abs<FLOAT>(*(FLOAT*)&TempScale.SheerAxis));
    return GMath.UnitCoords / sv / *(FRotator*)&Location / *(FVector*)&Rotation;
}

FCoords ABrush::ToWorld() const
{
    FVector sv(...);
    return GMath.UnitCoords * *(FVector*)&Rotation * *(FRotator*)&Location * sv;
}
```

There are two oddities worth noting:

**Type punning `Location` and `Rotation`**: `Location` is an `FVector` (x, y, z floats) but here it's being reinterpreted as an `FRotator` (pitch, yaw, roll ints). Both are 12 bytes. The retail binary does exactly this — it doesn't use the `Rotation` field for the position transform. Conversely, `Rotation` (nominally `FRotator`) is cast to `FVector`. This is the brush's own definition of how to chain its transforms; the field names are somewhat misleading from the standard actor perspective.

**`OldToLocal`/`OldToWorld`**: These use two additional `FScale` fields at `this + 0x3B0` and `this + 0x3C4`. These are from the old pre-TempScale transform system that predates the current layout. The chain is longer — six transforms instead of three — reflecting the additional scale fields that were part of the legacy brush transform pipeline.

```cpp
FCoords ABrush::OldToLocal() const
{
    FVector sv(...);
    const FScale& s3b0 = *(FScale*)((BYTE*)this + 0x3B0);
    const FScale& s3c4 = *(FScale*)((BYTE*)this + 0x3C4);
    return GMath.UnitCoords / sv / s3b0 / *(FRotator*)&Location / s3c4 / *(FVector*)&Rotation;
}
```

The symmetry is exact: `ToLocal` and `ToWorld` are inverse operations, and so are `OldToLocal` and `OldToWorld`. If you chain them: `v * ToWorld() * ToLocal()` you get `v` back.

## Build State After Batch 158

Engine.dll now builds cleanly from source in Win32 mode. The full RavenShield build passes with no errors. The known warnings (LNK4197 duplicate export for `ENGINE_ConnectionFailed` and `ENGINE_R6ConnectionFailed`) are pre-existing and benign — they come from the same symbol being listed in both the .def file and a DLLEXPORT attribute, and the linker correctly uses the first specification.

Batch count: **158 of 500** target batches complete.
