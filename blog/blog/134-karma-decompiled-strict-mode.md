---
slug: 134-karma-decompiled-strict-mode
title: "134. The SDK Was In There All Along"
authors: [dan]
tags: [karma, mathengine, physics, strict-mode, decompilation]
date: 2026-03-14
---

There's a comment that sat in `KarmaSupport.cpp` for a while:

```cpp
IMPL_DIVERGE("Karma physics — MathEngine SDK proprietary; source unavailable")
void AKConstraint::physKarma(float) { guard(...); unguard; }
```

The idea was that MathEngine shipped Karma as a binary-only static library, so we'd never be able to reconstruct it. It seemed reasonable. The SDK wasn't public. The company is long gone.

Except — it wasn't unavailable. It was sitting right there inside `Engine.dll`.

<!-- truncate -->

## What Is Karma?

Before we dig in, a quick primer for anyone who hasn't heard of it.

[Karma](https://web.archive.org/web/20040204051540/http://www.mathengine.com/products/karma.html) was a physics middleware product from MathEngine Ltd., a UK company. Epic licensed it for Unreal Engine 2 (which Ravenshield runs on) to get proper rigid body physics — things like:

- **Ragdolls**: when you shoot an enemy and their body crumples realistically
- **KActors**: physics-enabled props like crates and barrels that roll and tumble
- **KConstraints**: joints connecting two physics bodies (hinges, cones, ball-joints)

The core of Karma was two libraries:
- **Mdt** (MathEngine Dynamics Toolkit): the rigid body solver — it runs Newton's equations of motion each frame
- **Mcd** (MathEngine Collision Detection): detects when shapes intersect

These were distributed as pre-compiled static libraries. You'd `#include` the headers and `#pragma comment(lib, "karma.lib")`. Your game linked in the code, but you didn't get the source.

## Static Linking: The Hidden Source

Here's the key thing about static linking.

When you statically link a library into a DLL, the library's compiled machine code gets *copied* into that DLL. There's no separate `Karma.dll` to look for — the functions live inside `Engine.dll` as if they were compiled there.

We can verify this with `dumpbin`:

```
dumpbin /IMPORTS retail\system\Engine.dll
```

Output:
```
Dump of file Engine.dll
  Image has the following dependencies:
    Core.dll
    binkw32.dll
    KERNEL32.dll
    MSVCR71.dll
```

No Karma DLL. The physics engine is baked in.

And sure enough, searching `Engine.dll` for strings:

```
0x002F9130: MdtContactParamsSetRestitution: Negative restitution not valid...
0x002F9278: MdtContactParamsSetFriction: Negative friction not valid...
0x0023E0A7: ?MdtContactGroupGetCount(cg) == 1
```

Those are assertion strings from the Karma SDK source code. They were compiled in along with the function bodies.

## Ghidra Sees All

We already had a Ghidra decompilation of `Engine.dll`. The main exports are in `ghidra/exports/Engine/_global.cpp` — that's the 592,944-line file containing the decompiled bodies of all *exported* functions.

But there's also `ghidra/exports/Engine/_unnamed.cpp`. That's the 306,056-line file containing all the *internal* functions — the ones that don't appear in the DLL's export table.

The Karma SDK functions don't need to be exported. They're just internal helpers. They're all in `_unnamed.cpp` as `FUN_10xxxxxx` entries.

Here's a taste — this is the real `MdtBodyGetPosition`:

```c
// Address: 104946d0
// Size: 37 bytes
void FUN_104946d0(int param_1, undefined4 *param_2)
{
    *param_2       = *(undefined4 *)(param_1 + 0x160);
    param_2[1]     = *(undefined4 *)(param_1 + 0x164);
    param_2[2]     = *(undefined4 *)(param_1 + 0x168);
    return;
}
```

Reads three floats at offsets 0x160, 0x164, 0x168 from a `MdtBody*` — that's the x, y, z position. And here's `MdtBodySetPosition`:

```c
// Address: 10494890
// Size: 37 bytes
void FUN_10494890(int param_1, undefined4 param_2, undefined4 param_3, undefined4 param_4)
{
    *(undefined4 *)(param_1 + 0x160) = param_2;
    *(undefined4 *)(param_1 + 0x164) = param_3;
    *(undefined4 *)(param_1 + 0x168) = param_4;
    return;
}
```

Same offsets, reversed direction. Simple struct accessors. The Karma SDK, at this level, is mostly tiny functions like these — property getters and setters on opaque C structs. It's very amenable to decompilation.

## The Scale

Running a scan over the `_unnamed.cpp` file reveals:

- **1,448 functions** in the Karma SDK address range (VA `0x10490000`–`0x10510000`)
- **381 KB** of total code
- **490 small functions** (≤ 50 bytes) — mostly struct accessors
- **490 medium functions** (51–200 bytes) — parameter validation, simple algorithms
- **468 large functions** (> 200 bytes) — physics solver, constraint algorithms, collision detection

The largest function (`FUN_104B7800`) is 9,173 bytes. That's the core physics integrator, most likely.

## What "MeXContactPoints" Actually Was

The original `IMPL_DIVERGE` comment mentioned `MeXContactPoints`. Let's trace where that actually comes from.

`USkeletalMesh::LineCheck` — the function that checks if a bullet ray hits a ragdoll — does this:

```c
// For each Karma body in the ragdoll:
uVar5 = FUN_104aa520(iVar2);       // Get collision model from body
pcVar6 = FUN_104aa700(uVar5);      // Get ray-test function from model
iVar2 = (*pcVar6)(iVar2, &start, &end, results);  // Call it
```

`FUN_104aa700` reads from a geometry dispatch table:

```c
return *(undefined4 *)(*(int *)(param_1[3] + 0x18) + 0x1c + (*param_1 & 0xff) * 0x28);
```

This is C-style virtual dispatch — each geometry type (sphere, box, cylinder, convex mesh) has its own row in a table, and the row contains function pointers for operations like `Intersect`, `RayTest`, `DebugDraw`. "MeXContactPoints" was the name for one of those function pointer slots.

There isn't a single `MeXContactPoints` function to find — it's a *slot* in a geometry dispatch table, with different implementations for each shape type. We need to reconstruct the table and the per-shape implementations.

## Building src/MeSDK/

We've created `src/MeSDK/` as a static library project that will hold the reconstructed Karma code. The initial commit includes:

- `Inc/MeTypes.h` — opaque handle typedefs (`MdtBody`, `MdtWorld`, `MdtContactGroup`, etc.)
- `Src/MdtBody.cpp` — 13 accessor functions (position, velocity, constraint iterator)
- `Src/MdtContact.cpp` — 8 contact parameter functions (friction, restitution, softness)
- `Src/McdModel.cpp` — geometry/model functions
- `Src/MeWorld.cpp` — world-level functions

These are all `IMPL_MATCH` with their Ghidra virtual addresses. The work of reconstructing the full 1,448-function SDK is now well underway.

## The Macro Cleanup

Alongside this, we cleaned up the implementation attribution system.

Originally, we had macros like `IMPL_SDK` (code taken from an SDK) and `IMPL_INFERRED` (logic inferred from context). But the SDK we have is a *community* project — not official, not always correct. And "inferred" is just a fancy word for "approximation."

The new system is simpler:

| Macro | Meaning |
|-------|---------|
| `IMPL_MATCH` | Confirmed from Ghidra — this matches retail |
| `IMPL_EMPTY` | Ghidra confirms retail is also trivially empty |
| `IMPL_DIVERGE` | Intentionally different from retail, permanently |

No `IMPL_APPROX`. No `IMPL_SDK`. Either you've verified it against the binary, or you haven't. If you haven't, get it done before committing.

All 49 `IMPL_DIVERGE("Karma physics — MathEngine SDK proprietary; source unavailable")` stubs have been reclassified as `IMPL_APPROX` pending MeSDK implementation — and now that `IMPL_APPROX` is a build-breaker, those functions are in the queue to be properly decompiled and matched.

The build currently has **3,829 remaining violations** to resolve. The physics engine is no longer a wall — it's a list.
