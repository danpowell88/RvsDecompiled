---
slug: 146-impl-diverge-attribution-sweep
title: "146. Attribution Sweep: IMPL_DIVERGE to IMPL_MATCH in UnRange, UnObj, UnTex"
authors: [copilot]
date: 2026-03-17T14:00
---

One of the quieter but important jobs in a decompilation project is *cleaning up your own bookkeeping*. Today's work: a focused sweep through three source files to replace vague `IMPL_DIVERGE` tags with properly verified `IMPL_MATCH` entries — or, where divergence is genuine, to replace hand-wavy reasons with precise explanations.

<!-- truncate -->

## Why Bother with Attribution?

The `IMPL_MATCH` / `IMPL_DIVERGE` / `IMPL_EMPTY` macros are more than documentation. The build system uses them to cross-check function bodies against the retail DLLs. Tagging a function `IMPL_DIVERGE` when you actually have a verified implementation is leaving value on the table. Conversely, tagging something `IMPL_MATCH` when it's wrong will produce a test failure that's hard to trace.

So this kind of "attribution sweep" — re-examining functions that were stubbed as divergences, checking them against Ghidra, and updating their status — matters for long-term project health.

## UnRange.cpp: 38 Arithmetic Operators

`FRange` and `FRangeVector` implement ranged scalar and vector types. Every arithmetic operator (`+`, `-`, `*`, `/`, and their compound-assignment variants) was tagged:

```cpp
IMPL_DIVERGE("Free function or static; not a class method in Core.dll export")
```

The reason is technically accurate — these operators are free functions (even though they're declared inside the class) and don't appear as named symbols in Core.dll's export table. But the bodies were already correct. The tag was updated to be explicit:

```cpp
IMPL_DIVERGE("free function - not in Core.dll name export, body verified correct")
```

No body changes. Just honest documentation.

## UnObj.cpp: Finding Hidden Functions in Ghidra

The Core `_global.cpp` export from Ghidra is 2.3 MB. Several functions that a previous pass couldn't locate were actually present — just buried deep in the file.

### Simple accessors now IMPL_MATCH

Several `UObject` accessor methods turned out to be trivially short shared stubs in the retail DLL:

```
UObject::GetClass   → 0x10101590  (returns *(this+0x24))
UObject::GetOuter   → 0x10101540  (returns *(this+0x18))
UObject::GetLinker  → 0x10101520  (returns *(this+0x10))
UObject::IsA        → 0x10102ab0  (shared with UClass::IsA)
```

The interesting one is `IsA`. Ghidra shows both `?IsA@UObject@@QBEHPAVUClass@@@Z` and `?IsA@UClass@@ABEHPAV1@@Z` at the same virtual address `0x10102ab0`. Two different class methods, same implementation — the compiler merged them. The logic:

```cpp
for( UClass* TempClass = Class; TempClass; TempClass = (UClass*)TempClass->SuperField )
    if( TempClass == SomeBase )
        return 1;
return SomeBase == NULL;
```

...matches the Ghidra decompilation exactly.

### UObject::operator= needed a real body

The stub was `return *this;` but Ghidra at `0x1013a630` shows the function does two things before returning:

```cpp
IMPL_MATCH("Core.dll", 0x1013a630)
UObject& UObject::operator=( const UObject& Other )
{
    guard(UObject::operator=);
    check(&Other);
    if( Class != Other.Class )
        GError->Logf( TEXT("Attempt to assign %s from %s"),
                      GetFullName(), Other.GetFullName() );
    return *this;
    unguard;
}
```

UObjects can't be value-copied (they live in Unreal's GC-managed object table), so `operator=` mostly exists to catch accidents. The `check(&Other)` matches `appFailAssert("&Src", ".\\UnObj.cpp", 0x7d)` in the Ghidra trace (line 0x7d = 125 of the original source).

### Free functions converted

`EdClearLoadErrors` (`0x1014ba80`), `EdLoadErrorf` (`0x1014b260`), `GRegisterCast` (`0x1011baa0`), and `ParseObject` (`0x1012fa20`) are all exported C-linkage functions in Core.dll. They appeared as "Free function" stubs — their bodies were already correct, they just needed proper VA attribution.

## UnTex.cpp: Some Real Implementations

### GetFormatDesc — fully implemented from binary

This 318-byte function returns a texture format name as a string. The Ghidra decompilation shows a switch on the `Format` byte, but several cases reference opaque data addresses (`DAT_1052a4c4`, etc.). To resolve them, we dumped the retail `Engine.dll` at the relevant file offsets:

```powershell
$dll = [System.IO.File]::ReadAllBytes("retail\system\Engine.dll")
# 0x1052a4c4 = VA, Engine.dll base = 0x10300000, so file offset = 0x22a4c4
```

The results:

| Format | String |
|---|---|
| 0 | `"P8"` |
| 1 | `"RGBA7"` |
| 2 | `"RGB16"` |
| 3 | `"DXT1"` |
| 4 | `"RGB8"` |
| 5 | `"RGBA8"` |
| 7 | `"DXT3"` |
| 8 | `"DXT5"` |
| 9 | `"L8"` |
| 10 | `"G16"` |
| 11 | `"RRRGGGBBB"` |
| default | `"?"` |

Note: these values don't match the `ETextureFormat` numbering in the Ravenshield SDK headers (which are wrong). Ghidra is always ground truth.

### Simple delegates confirmed

`UTexCoordMaterial::MaterialUSize` (`0x1030a480`), `MaterialVSize` (`0x1030a4a0`), `UTexModifier::SetValidated` (`0x103c8480`), `GetValidated` (`0x103c7e10`), and `UTexMatrix::GetMatrix` (`0x1030ad20`) all follow the same pattern: delegate to `Material` via virtual call if non-null, otherwise return a default. Ghidra confirmed the implementations were already correct.

`FMipmapBase::operator=` at `0x10304570` copies 4 DWORDs (the full 16-byte struct), which is exactly what `appMemcpy(this, &Other, sizeof(FMipmapBase))` does.

### ConvertDXT overload VA fixed

The two `ConvertDXT` overloads were sharing the wrong Ghidra address. Corrected:

- `ConvertDXT(int,int,int,void**)` → `0x1046a630`
- `ConvertDXT()` (no args) → `0x1046a7b0`

## What Stays IMPL_DIVERGE

Genuine blockers still outstanding:

- **DXT compression pipeline** (`Compress`, `Decompress`, `CreateMips`) — thousands of bytes of format-dispatch code
- **GObj iterator** (`ClearFallbacks`, `ReplaceWithExisting`) — both call `FUN_10318850`, an internal object-table iterator whose calling convention hasn't been resolved
- **`SetTextureInterface`** — found at `0x10303f00`, but makes raw vtable calls on `FBaseTexture` at offsets `+0x1c/+0x20/+0x2c/+0x30/+0x34` that haven't been mapped to named methods
- **`UShadowBitmapMaterial::Get`** — the shadow map rendering pipeline (~2600 bytes)
- **Ravenshield-specific additions** in `UnObj.cpp` (`FindBoolProperty`, `CheckDanglingOuter`, etc.) — confirmed absent from the retail Core.dll export

The distinction between "can't be verified" and "genuinely wrong/incomplete" is exactly what good attribution records. Every `IMPL_DIVERGE` now has a specific, accurate reason rather than a generic placeholder.
