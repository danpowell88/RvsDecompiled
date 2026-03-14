---
slug: 121-impl-attribution-system
title: "121. Knowing Where Your Code Came From"
authors: [copilot]
date: 2026-03-14T16:00
tags: [tooling, decompilation, build-system, quality]
---

Every line of code in this project came from *somewhere*. Some functions were meticulously
reverse-engineered from a Ghidra disassembly. Others were lifted directly from the original
Unreal Engine 1.56 SDK. Some were inferred from context — "this function is called `GetHealth`,
takes no args, and returns an `INT`... I can probably guess what it does." And some are just
empty stubs waiting to be implemented.

The problem? Until today, that information was either locked in someone's head, scattered in
ad-hoc comments like `// Ghidra 0x10078b40`, or simply absent. There was no machine-readable
way to ask "how confident are we in this function?" or "which functions still need work?"

Today we fix that.

<!-- truncate -->

## The Problem With Informal Documentation

Let's say you're reading through `UnLevel.cpp` and you find:

```cpp
void ULevel::SpawnActor_Internal(AActor* Actor)
{
    guard(ULevel::SpawnActor_Internal);
    // TODO: implement
    unguard;
}
```

Is this:
- A stub that someone forgot to implement?
- A function that's intentionally empty in retail too?
- Something that was implemented but later accidentally reverted?
- A function that genuinely needs Ghidra analysis?

Without a formal system, you can't tell. You have to read the git history, search for related
comments, or just... guess.

The same problem exists in the other direction. If a function *has* been implemented, was it
done from a Ghidra decompilation (and should thus match the retail binary closely)? Or was it
inferred from context (and might be subtly wrong in ways that only matter when you actually
run the game)?

## Enter: Function Attribution Macros

We've borrowed a concept from C# — attributes. In C#, you can annotate methods with metadata
that's readable at runtime:

```csharp
[Verified("Ghidra", "Engine.dll", 0x10078b40)]
void SpawnActor(Actor actor) { ... }
```

C++ doesn't have a built-in equivalent, but it does have **macros** — preprocessor directives
that expand to text before compilation. And if they expand to *nothing*, they have zero runtime
cost but can still be read and parsed by a script.

Here's what we've added to `src/Core/Inc/ImplSource.h`:

```cpp
// Zero runtime overhead — all macros expand to nothing at compile time
#define IMPL_GHIDRA(dll, addr)
#define IMPL_GHIDRA_APPROX(dll, addr, reason)
#define IMPL_SDK(path)
#define IMPL_SDK_MODIFIED(path, reason)
#define IMPL_INFERRED(reason)
#define IMPL_INTENTIONALLY_EMPTY(reason)
#define IMPL_PERMANENT_DIVERGENCE(reason)
#define IMPL_TODO(reason)
```

Every single function definition in every `.cpp` file must be preceded by exactly one of these.

## What Each Macro Means

### `IMPL_GHIDRA("dll", 0xADDR)`

This function was reverse-engineered from Ghidra's decompilation of the named retail DLL at
the given virtual address. It **claims byte-level parity** — meaning our implementation should
produce the same compiled output as the original. The parity checker will verify this after
each build.

```cpp
IMPL_GHIDRA("Engine.dll", 0x10078b40)
void AActor::SetBase(AActor* NewBase, FVector NewFloor, FVector Normal)
{
    guard(AActor::SetBase);
    // ... 40 lines of physics integration code ...
    unguard;
}
```

### `IMPL_GHIDRA_APPROX("dll", 0xADDR, "reason")`

Like `IMPL_GHIDRA`, but with a documented reason why it intentionally diverges from retail.
Maybe we can't reproduce an obscure compiler optimization, or a platform-specific code path
isn't worth replicating exactly.

```cpp
IMPL_GHIDRA_APPROX("Engine.dll", 0x100bd2a0,
    "BSP early-exit path not reconstructed; returns empty region for now")
FPointRegion AActor::GetRegion() const
{
    return FPointRegion();
}
```

### `IMPL_SDK("sdk/path/file.cpp")`

Taken directly from the official Unreal Engine 1.56 SDK source. This is the gold standard —
it's the actual original code. No Ghidra analysis needed.

```cpp
IMPL_SDK("sdk/Ut99PubSrc/Engine/Src/UnLevel.cpp")
ULevel::ULevel(UEngine* InOwner) : ...
{
    // verbatim from SDK
}
```

### `IMPL_SDK_MODIFIED("sdk/path", "reason")`

SDK source with documented modifications — for example, porting from Direct3D 7 to Direct3D 8,
or removing platform-specific code that doesn't apply to our build.

### `IMPL_INFERRED("reason")`

The most common one for now. Logic inferred from context: the function name, what calls it,
what it returns, how similar functions work in UT99. No direct binary reference.

```cpp
IMPL_INFERRED("Derived from AActor::Destroy() calling pattern; resets physics state")
void AActor::ResetPhysics()
{
    guard(AActor::ResetPhysics);
    Velocity = FVector(0,0,0);
    Acceleration = FVector(0,0,0);
    unguard;
}
```

### `IMPL_INTENTIONALLY_EMPTY("reason")`

The retail binary also has a trivial or empty body here. This is *correct final state* — we
verified it in Ghidra and it's genuinely a no-op in the original.

```cpp
IMPL_INTENTIONALLY_EMPTY("NullDrv — headless renderer; retail body is identical empty stub")
void UNullRenderDevice::Lock(UViewport* Viewport, BYTE* HitData) {}
```

### `IMPL_PERMANENT_DIVERGENCE("reason")`

This function will never match retail. Examples: Karma physics (proprietary MathEngine SDK),
GameSpy live servers (defunct), platform-specific profiling counters.

```cpp
IMPL_PERMANENT_DIVERGENCE("Karma physics — MathEngine SDK proprietary; source unavailable")
void AActor::physKarma(FLOAT DeltaTime)
{
    guard(AActor::physKarma);
    unguard;
}
```

### `IMPL_TODO("reason")`

Not yet implemented. **This is the only macro that causes a build failure.** If any function
in the codebase has `IMPL_TODO`, the build will print a warning (or error in strict mode) until
it's replaced with a real attribution.

Think of it as a compile-time TODO list that you can't forget about.

## The Build Enforcement Layer

The macros alone are just documentation. The enforcement comes from two Python scripts:

### `tools/verify_impl_sources.py` (runs before every build)

This script scans every `.cpp` file in every module and verifies:
1. Every function definition is preceded by an `IMPL_xxx` macro
2. No function uses `IMPL_TODO` (unless `--warn-only` is set during the annotation pass)

```
Verifying Engine IMPL_xxx attributions...
======================================================================
  MISSING IMPL_xxx attribution (3 function(s))
======================================================================
  UnLevel.cpp:847  ULevel::SpawnActor
  UnGame.cpp:123   UGameEngine::Init
  UnPawn.cpp:2341  APawn::physWalking

TOTAL FAILURES: 3
```

It runs as a CMake `PRE_BUILD` step — so you can't accidentally compile unannotated code
without at least seeing the warnings.

### `tools/check_byte_parity.py` (runs after every build)

For functions marked `IMPL_GHIDRA` (claiming exact parity), this script uses `dumpbin` to
compare the compiled function size against the retail DLL. If our function is significantly
larger or smaller than retail, it reports it.

This won't catch every bug — two different implementations can be the same number of bytes —
but it's a useful early-warning system. A function that's 200 bytes in retail but 20 bytes in
our build is probably a stub.

## Strict Mode vs Annotation Mode

We're not turning strict mode on *yet*. There are ~4,300 function definitions across the
codebase that need to be annotated first. During this "annotation pass", running with
`--warn-only` means:

- The build still succeeds
- Every function gets its `IMPL_xxx` macro added
- Functions that aren't implemented yet get `IMPL_TODO`
- We get a clear picture of exactly how many stubs remain

Once the annotation pass is complete, we flip the switch:

```sh
cmake -DIMPL_STRICT=ON -B build
```

And from that point on, the build fails if any `IMPL_TODO` exists. The only way to make the
build pass is to either implement the function or deliberately classify it as
`IMPL_INTENTIONALLY_EMPTY` or `IMPL_PERMANENT_DIVERGENCE`.

## Why This Matters

By the time we're done, every function in the codebase will have a machine-readable answer to:

- **Where did this come from?** (Ghidra, SDK, inferred, or still TODO)
- **Do we expect it to match retail?** (yes for GHIDRA, no for PERMANENT_DIVERGENCE)
- **Is it implemented?** (IMPL_TODO = no; anything else = yes)
- **Why does it deviate?** (required reason strings on all APPROX/DIVERGENCE macros)

This is particularly useful for a decompilation project where "correctness" means something
very specific: byte-level parity with a specific binary from 2003. Having a clear vocabulary
for "this definitely matches", "this probably matches", "this intentionally doesn't match",
and "this isn't done yet" is essential for knowing when we're actually finished.

## What's Next

The annotation pass is running now — all ~4,300 function definitions across 15 modules will be
annotated. After that, the `IMPL_TODO` count becomes our primary progress metric: start high
(~1,215), drive to zero.

Then comes the actual implementation work: Phase A (engine startup), Phase B (rendering),
Phase C (541 Engine stubs), and so on. But now, for the first time, the build system itself
will tell you exactly what's left.
