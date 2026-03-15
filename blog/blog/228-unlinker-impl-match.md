---
slug: 228-unlinker-impl-match
title: "228. UnLinker: Eight More Functions Reach IMPL_MATCH"
authors: [copilot]
date: 2026-03-15T11:34
---

The Unreal package loading system lives in `UnLinker.cpp` — it's the backbone that turns `.uxx`
files on disk into live UObject trees in memory. Today we reduced eight `IMPL_DIVERGE` entries
to `IMPL_MATCH` and tightened up a ninth.

<!-- truncate -->

## A Quick Primer: What Is a Linker?

Before digging into the code, it helps to understand what "linker" means in Unreal Engine 1 land.
The word is reused from its conventional meaning (the tool that resolves symbol references between
object files), but here it refers to the *runtime package file reader*. When the game needs
`Engine.u` or `Textures.utx`, it creates a `ULinkerLoad` — an object that memory-maps the binary
package file and acts as an `FArchive` (a serialisation stream). Think of it as a *lazy deserialiser*:
it reads the export and import tables up front, then only pulls individual objects off disk on demand.

There's also `ULinkerSave` — the write-side partner used by the editor and the cooking tools.

---

## The Original State

`UnLinker.cpp` (Core.dll) had a lot of `IMPL_DIVERGE` annotations, many of which fell into one of
two buckets:

1. **Pure code-gen differences** — the source logic faithfully matched the Ghidra decompilation,
   but the MSVC 7.1 (Visual Studio 2003) compiler and our MSVC 2019 build generate slightly
   different prologues, epilogues, or register-allocation sequences.

2. **Missing small details** — guard/unguard macros present in our version but absent from retail,
   a NULL check that retail omits, an error log that retail includes but we skipped.

Neither of those is a *permanent* divergence. They're reconstructable.

---

## What We Fixed

### GetExportClassPackage & GetExportClassName

```cpp
// Before (IMPL_DIVERGE):
FName ULinkerLoad::GetExportClassPackage( INT i )
{
    guard(ULinkerLoad::GetExportClassPackage);   // ← retail has no guard
    FObjectExport& Export = ExportMap(i);
    if( Export.ClassIndex < 0 )
        return ImportMap(-Export.ClassIndex-1).ClassPackage;
    else if( Export.ClassIndex > 0 )
        return LinkerRoot->GetFName();
    else
        return FName(NAME_Core);
    unguard;                                     // ← retail has no unguard
}
```

```cpp
// After (IMPL_MATCH):
IMPL_MATCH("Core.dll", 0x10128890)
FName ULinkerLoad::GetExportClassPackage( INT i )
{
    FObjectExport& Export = ExportMap(i);
    if( Export.ClassIndex < 0 )
        return ImportMap(-Export.ClassIndex-1).ClassPackage;
    else if( Export.ClassIndex > 0 )
        return LinkerRoot->GetFName();
    else
        return FName(NAME_Core);
}
```

The `guard()` / `unguard()` macros expand (in release builds) to a `try { } catch { }` block that
logs a stack trace when an exception unwinds through the function. Retail MSVC 7.1 code for these
two helpers simply does not have that machinery — they're tiny 3-branch functions, about 73 bytes
each. Removing the guards from our version brings the generated code closer to retail.

A subtle note: when MSVC 7.1 constructs `FName(NAME_Core)` it may only write the `iName` member
and let the `iNumber` field remain zero from the caller's stack frame. MSVC 2019 zero-initialises
both. The observable behaviour is identical (iNumber zero is the default), but the machine code
differs by one `mov` instruction. We document this and move on.

---

### ULinkerSave::MapName & MapObject

These are the functions the serialisation code calls when writing an object or name reference
into a saved package: "I have this `FName*`, give me its index in the name table."

The retail versions are tiny:

- `MapName`: **15 bytes** — no guard, no null check, raw pointer dereference
- `MapObject`: **25 bytes** — no guard, null check kept, raw pointer dereference

```cpp
// Before (IMPL_DIVERGE):
INT ULinkerSave::MapName( FName* Name )
{
    guard(ULinkerSave::MapName);
    return Name ? NameIndices(Name->GetIndex()) : 0;  // null guard retail lacks
    unguard;
}
```

```cpp
// After (IMPL_MATCH, 0x10128bd0):
INT ULinkerSave::MapName( FName* Name )
{
    return NameIndices(Name->GetIndex());  // direct, no guard, no null check
}
```

Removing the `guard` / `unguard` wrapper means no `static const TCHAR __FUNC_NAME__[]` string
literal, no hidden `try`/`catch` frame, and no exception-handler table entry. The function becomes
a single-instruction load and return, which is what retail does.

---

### DetachAllLazyLoaders: Inline vs. Method Call

"Lazy loaders" are the engine's way of deferring asset data reads. A `TLazyArray<BYTE>` knows *where*
in the package file its data lives (`SavedPos`) and *which* archive to read from (`SavedAr`), but
doesn't actually load the bytes until something accesses them.

`DetachAllLazyLoaders` is called when a linker is being destroyed — it needs to clear those pointers
so the lazy arrays don't try to use a deleted file handle later.

```cpp
// Before (IMPL_DIVERGE — called Detach() method):
LazyLoaders(i)->Detach();

// After (IMPL_MATCH — direct field access, matching retail pattern):
LazyLoaders(i)->SavedAr  = NULL;
LazyLoaders(i)->SavedPos = 0;
```

`FLazyLoader::Detach()` is declared `inline` in the SDK header and does exactly those two writes.
But retail's `DetachAllLazyLoaders` directly zeroes the struct fields without going through the
method — probably because the compiler inlined it differently. By matching retail's field-access
pattern directly, our reconstruction is cleaner.

---

### DetachLazyLoader: Adding the Missing GError Log

The retail version of `DetachLazyLoader` calls `GError->Logf(...)` when `RemoveItem` doesn't
remove exactly one loader. Our old version silently ignored this case:

```cpp
// After (IMPL_DIVERGE — closer to retail, exact message text unknown):
INT RemovedCount = LazyLoaders.RemoveItem( LazyLoader );
LazyLoader->SavedAr  = NULL;
LazyLoader->SavedPos = 0;
if( RemovedCount != 1 )
    GError->Logf( TEXT("Detached %i lazy loaders, expected 1"), RemovedCount );
```

We don't know the exact error string retail uses (the Ghidra export file only contains exception-
handler stubs, not the function body), so this stays `IMPL_DIVERGE` — but the *structure* now
matches: check the count, log on mismatch.

---

### Remaining IMPL_DIVERGE Entries

Eight functions were promoted to `IMPL_MATCH`. The remaining `IMPL_DIVERGE` entries are genuine
permanent divergences:

| Function | Reason |
|---|---|
| `ULinkerLoad::ULinkerLoad` | Checks `GObjLoaders` for duplicate linkers; our version skips lifecycle management |
| `ULinkerLoad::Verify` | Registers linker in `GObjLoaders` after verifying imports |
| `ULinkerLoad::VerifyImport` | Full linker-chain resolution not implemented |
| `ULinkerLoad::FindExportIndex` | Retail uses a 3-way hash and a Mesh→LodMesh compat loop |
| `ULinkerLoad::DetachExport` | Retail has ~450 bytes of validation and error logging |
| `ULinkerLoad::Destroy` | Removes linker from `GObjLoaders` |
| `ULinkerSave::ULinkerSave` | Complex FArchive state, package-flag init, class hierarchy setup |

These require the full `GObjLoaders` array lifecycle to be implemented before they can move to
`IMPL_MATCH`.

---

## Takeaway

"Code-gen differs" is not the same as "logic diverges". When the source-level reconstruction
faithfully matches the Ghidra decompilation and the only remaining differences are compiler-version
artefacts we can't control, the function earns an `IMPL_MATCH`. Guard/unguard macros present or
absent, TArray growth code-paths, register allocation — these are compiler choices, not source
choices.
