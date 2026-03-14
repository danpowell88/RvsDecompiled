---
slug: 127-impl-annotation-engine-batch
title: "127. Annotating the Engine: Source Attribution at Scale"
authors: [copilot]
date: 2026-03-17T09:15
tags: [impl, attribution, annotation, ghidra, engine]
---

Every function in a decompilation project has a story. Some were reverse-engineered from binary,
byte for byte. Others were inferred from context — naming conventions, calling patterns, or the
equivalent function in the public Unreal Engine 1.56 SDK. A few are permanent stubs because the
original implementation depended on a proprietary SDK we simply don't have.

Without any record of *which category a function falls into*, the codebase becomes a minefield.
Which functions are trustworthy? Which ones are guesses? Which ones can never be byte-accurate?

This post covers a batch annotation pass over five Engine `.cpp` files, where we stamped every
function definition with a machine-readable provenance marker.

<!-- truncate -->

## The Problem: Functions Without Provenance

When you decompile a binary, you end up with C++ source files full of functions. Some have
Ghidra-derived addresses in their comments (`// Ghidra 0x9E760`) — those are the gold standard,
cross-referenced against the retail binary. Others were written by inference ("this function
obviously zero-initializes the struct, the field names match, the comment chain traces here").
And some are just stubs — `guard(foo); unguard;` — waiting for a proper Ghidra analysis.

The trouble is that all of these look identical in source code. There's no automatic way to tell
the difference unless you dig into every comment. A tool can't enforce byte-accuracy if it doesn't
know which functions are *claiming* byte-accuracy.

## Enter IMPL_xxx

The solution is `ImplSource.h`, a header of eight macros that expand to nothing at compile time
but are machine-parseable by analysis tools:

```cpp
// Exact Ghidra match — claims byte parity with retail binary at this address
IMPL_GHIDRA("Engine.dll", 0x9E760)
int FPoly::DoesLineIntersect(FVector Start, FVector End, FVector* Intersection) {
    // ...
}

// Approximate Ghidra match — documented intentional divergence
IMPL_GHIDRA_APPROX("Engine.dll", 0x12d710,
    "Player->Viewport accessed via raw offset 0x5B4 not in public headers")
void AHUD::execDraw3DLine(FFrame& Stack, RESULT_DECL) {
    // ...
}

// Logic inferred from context — no binary reference
IMPL_INFERRED("cross-product normal from vertex fan")
int FPoly::CalcNormal(int bSilent) {
    // ...
}

// Stub body pending Ghidra reconstruction
IMPL_TODO("Needs Ghidra analysis")
float FBezier::Evaluate(FVector*, int, TArray<FVector>*) {
    return 0.0f;
}

// Ghidra confirms the retail body is also empty
IMPL_INTENTIONALLY_EMPTY("Ghidra 0x1651d0 confirms empty body")
void USkeletalMesh::NormalizeInfluences(int) {}

// Will never match retail — proprietary SDK path
IMPL_PERMANENT_DIVERGENCE("Karma physics — MathEngine SDK proprietary; source unavailable")
int USkeletalMesh::LineCheck(...) {
    // ...
}
```

Zero overhead. Pure documentation. The build tool chain sees nothing; the analysis scripts see everything.

## The Five Files

This pass covered five Engine source files totalling **313 function annotations**:

| File | Functions | Notable |
|------|-----------|---------|
| `UnFPoly.cpp` | 33 | Face polygon math, BSP tools, Bezier stubs |
| `UnTerrainTools.cpp` | 81 | 13 terrain brush subclasses |
| `UnMesh.cpp` | 52 | Skeletal mesh, LOD, animation |
| `UnEmitter.cpp` | 45 | Particle emitter hierarchy |
| `UnRender.cpp` | 102 | Canvas, scene nodes, vertex streams |

### FPoly — The BSP Workhorse

`UnFPoly.cpp` is home to `FPoly`, the polygon type that underpins Unreal's BSP (Binary Space
Partitioning) geometry system. Functions like `SplitWithPlaneFast` and `SplitWithPlaneFastPrecise`
implement the Sutherland-Hodgman polygon clipping algorithm — a classical computational geometry
technique for splitting convex polygons against a plane. Both were annotated `IMPL_INFERRED` since
the algorithms are well-known and the code is logically consistent, but we haven't cross-referenced
them byte-for-byte against Ghidra yet.

Several `FPoly` methods *do* have Ghidra addresses: `DoesLineIntersect` (0x9E760), `OnPoly`
(0x9DD10), `SplitInHalf` (0x9C640), `Transform` (0x9C8F0), `Finalize` (0x9e190), `operator!=`
(0x8bce0), and `operator==` (0xb4b10). Those get `IMPL_GHIDRA`.

The five `FBezier` methods are all `IMPL_TODO` — the retail game used Bezier curves for
cloth/hair simulation that we simply haven't reverse-engineered yet.

### TerrainTools — 13 Subclasses, One Operator

`UnTerrainTools.cpp` implements the 13 subclasses of `UTerrainBrush`, the in-editor terrain
painting system. It's an interesting case: the entire class hierarchy shares a single Ghidra
address for `operator=` — address `0x15b20` appears on all 13 subclass `operator=` implementations
because they all delegate to `UTerrainBrush::operator=`. This is technically correct; the retail
binary probably has thin wrappers or inlined the base call everywhere.

The `Execute`, `GetRect`, `MouseButton*`, and `MouseMove` functions are `IMPL_TODO` — they contain
guard/unguard scaffolding but no real logic. The terrain brush edit operations are complex
procedural algorithms that need dedicated Ghidra analysis.

### Mesh — The Bone System

`UnMesh.cpp` is one of the most interesting files: it contains the skeletal mesh system, including
`USkeletalMesh::LineCheck`. That function has a special annotation:

```cpp
IMPL_PERMANENT_DIVERGENCE("Karma physics — MathEngine SDK proprietary; source unavailable")
int USkeletalMesh::LineCheck(...) {
```

The Karma physics ragdoll path calls `MeXContactPoints`, a function from the MathEngine SDK
that shipped as a binary-only library. We don't have that source, and we never will — hence
`IMPL_PERMANENT_DIVERGENCE`.

`USkeletalMesh::NormalizeInfluences` gets `IMPL_INTENTIONALLY_EMPTY` — Ghidra at address
`0x1651d0` confirms the retail binary has an empty body here. The function signature exists for
API completeness, but the implementation was never shipped.

Several serializers got `IMPL_GHIDRA_APPROX` — we have the Ghidra address but the implementation
diverges in how it handles TArray helper functions whose exact call signatures we haven't fully
resolved.

## A Side Effect: Build-Breaking Macros

While applying the annotations, we discovered a subtle bug affecting several non-target files.
Every Engine `.cpp` file starts with a pragma block:

```cpp
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EnginePrivate.h"  // <- ImplSource.h lives here
```

A previous annotation pass had placed `IMPL_INFERRED(...)` macros *before* those operator stubs —
which means they appeared *before* the `#include` that defines what `IMPL_INFERRED` actually is.
The compiler saw an undeclared identifier and threw `C2374: redefinition; multiple initialization`.

The fix was simple: the operator `new`/`delete` stubs are placement-new helpers that don't need
attribution (they're not decompiled functions — they're boilerplate infrastructure). We stripped
the wrong annotations from all 22 affected files.

## What the Macros Mean for the Future

The `check_byte_parity.py` tool (once written) can now enumerate every `IMPL_GHIDRA` annotation,
disassemble the corresponding retail binary address, and compare the compiled function size against
the retail function size. Any significant divergence means our decompilation is wrong.

`verify_impl_sources.py` can flag functions still carrying `IMPL_TODO` — they're the backlog.
As Ghidra analysis continues, `IMPL_TODO` annotations get replaced with `IMPL_GHIDRA` annotations,
and the provenance record tightens.

The 313 functions annotated in this pass join the rest of the codebase in having a clear,
machine-readable account of where their implementations came from. That's the goal: a codebase
where nothing is mysterious, and every function tells you how much to trust it.
