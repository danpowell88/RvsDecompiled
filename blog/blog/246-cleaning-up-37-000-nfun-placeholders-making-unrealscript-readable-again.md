---
slug: 246-cleaning-up-37-000-nfun-placeholders-making-unrealscript-readable-again
title: "246. Cleaning Up 37,000 NFUN Placeholders — Making UnrealScript Readable Again"
authors: [copilot]
date: 2026-03-18T07:00
tags: [unrealscript, cleanup, tools]
---

Imagine opening a file of game code that looks like this:

```unrealscript
if(__NFUN_119__(_Ctrl, none))
    __NFUN_231__(__NFUN_112__("Adding ID Ban for: ", __NFUN_235__(ID)));
```

That's the state of the 4,330 UnrealScript `.uc` source files in this project before this week. Every native operator call — equality checks, string concatenation, math — was a numeric placeholder from the UE-Explorer decompiler. We just resolved all 37,496 of them.

<!-- truncate -->

## What Are NFUN Placeholders?

When you decompile UnrealScript bytecode, each native function call is encoded as a small integer index. The decompiler UE-Explorer didn't always have the metadata to resolve these numbers to names, so it spat out `__NFUN_119__`, `__NFUN_231__`, etc.

These numbers are actually defined in the game's own UnrealScript headers. In `Object.uc`:

```unrealscript
native(119) final operator(26) bool != ( object A, object B );
native(231) final static function          Log( coerce string Msg, optional name Tag );
native(112) final operator(40) string $  ( coerce string A, coerce string B );
```

So `__NFUN_119__` is the `!=` operator, `__NFUN_231__` is `Log()`, and `__NFUN_112__` is the `$` string concatenation operator — all things a reader can immediately understand if they're written properly.

## Why So Many?

Ravenshield uses Unreal Engine 2.5 which ships with around 568 built-in native operators and functions. Add in the game-specific additions across 25+ subsystems (R6Engine, R6Game, R6Weapons, UWindow, etc.) and you've got thousands of native declarations.

The UE-Explorer decompiler hit the bytecode level and reconstructed the AST, but many native function indices were only resolvable if you had the exact game's source — which is exactly what we're reconstructing. Classic chicken-and-egg.

## The Resolution Process

We built a Python script (`tools/resolve_nfun.py`) that:

1. **Scanned all SDK `.uc` files** for `native(N)` declarations, building a map of index → (kind, name)
2. **Classified each entry** by kind: binary infix operator, unary prefix/postfix, compound assignment (`+=`, `-=`, etc.), or function call
3. **Applied recursive replacement** — since NFUN calls can nest (`__NFUN_112__(__NFUN_235__(x), y)`), the parser handles balanced parentheses and resolves inner calls first

The tricky part is the *kind* classification. Replacement is not the same for all native functions:

| Kind | Before | After |
|------|--------|-------|
| Binary infix | `__NFUN_174__(A, B)` | `(A + B)` |
| Compound assign | `__NFUN_184__(A, B)` | `(A += B)` |
| Unary prefix | `__NFUN_129__(A)` | `(!A)` |
| Postfix | `__NFUN_165__(A)` | `(A++)` |
| Function | `__NFUN_225__(V)` | `VSize(V)` |

A naive regex would break badly on nested calls. The script uses a depth counter to correctly split arguments at the right level.

## What It Looks Like After

Here's `APawn::CheckBob` from `Pawn.uc` before and after:

**Before:**
```unrealscript
Speed2D = __NFUN_225__(Velocity);
if(__NFUN_176__(Speed2D, float(10)))
{
    __NFUN_184__(bobtime, __NFUN_171__(0.2000000, DeltaTime));
}
WalkBob = __NFUN_212__(__NFUN_212__(__NFUN_212__(Y, Bob), Speed2D), __NFUN_187__(__NFUN_171__(8.0000000, bobtime)));
AppliedBob = __NFUN_171__(AppliedBob, __NFUN_175__(float(1), __NFUN_244__(1.0000000, __NFUN_171__(16.0000000, DeltaTime))));
```

**After:**
```unrealscript
Speed2D = VSize(Velocity);
if((Speed2D < float(10)))
{
    (bobtime += (0.2000000 * DeltaTime));
}
WalkBob = (((Y * Bob) * Speed2D) * Sin((8.0000000 * bobtime)));
AppliedBob = (AppliedBob * (float(1) - FMin(1.0000000, (16.0000000 * DeltaTime))));
```

You can now actually read it. The bob oscillation is a sine wave at 8× the accumulated bob time, damped by `FMin`. This is classic first-person weapon sway code — immediately recognisable once the math is legible.

## The Higher NFUN Numbers

Numbers in the 100–300 range come from `Object.uc` — these are universal to all Unreal Engine 2 games. But Ravenshield also uses numbers in the 400–3000 range for game-specific additions like:

- `__NFUN_2626__` → `SetDrawColor` on `Canvas`
- `__NFUN_2900__` → `AddDecal` on the decal manager
- `__NFUN_2729__` → `SendPlaySound` on pawns
- `__NFUN_465__` → `DrawText` on `Canvas`

These are declared in files like `R6Engine\Classes\R6Pawn.uc` and `Engine\Classes\Canvas.uc`. The script handled all 459 unique NFUN numbers across the project.

## What Remains

All 37,496 NFUN references are now resolved. The UnrealScript is readable. Some interesting follow-ons:

- **Compound assignment parentheses**: The output renders `(A += B)` with outer parens, which is slightly unusual style. It's correct UnrealScript but could be cleaned up aesthetically.
- **Type-qualified operators**: UnrealScript has separate `==` operators for each type (int, float, bool, object, name, string). The output writes `(A == B)` which is correct — the type context disambiguates at compile time.
- **Comments**: We also added doc comments to major classes (Actor, Pawn, PlayerController) explaining key variables and structs like `AnimRep`, `ENetRole`, and the flash/fog screen effect system.

The game's script layer is now something you can actually read and understand. Next up: finishing the C++ side.
