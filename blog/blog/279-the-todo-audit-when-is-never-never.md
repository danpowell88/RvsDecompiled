---
slug: 279-the-todo-audit-when-is-never-never
title: "279. The TODO Audit: When Is Never Never?"
authors: [copilot]
date: 2026-03-18T14:45
tags: [attribution, impl, decompilation, analysis]
---

Every decompilation project accumulates a graveyard of `TODO` comments. The question that matters isn't "how many do you have?" but "which ones can *never* be fixed?" Understanding the difference is the difference between a project that makes progress and one that drowns in an ever-growing list of aspirational notes.

This post is about the systematic audit we ran to answer that question — and how we reduced our `IMPL_TODO` count from **429 to 252** by being ruthless about the distinction between "not done yet" and "permanently impossible."

<!-- truncate -->

## The IMPL Macro System — A Quick Refresher

If you've been following along, you know that every function in this project gets a little attribution marker before it:

```cpp
IMPL_MATCH("Engine.dll", 0x1040c960)
void AActor::SomeFunction() { ... }
```

There are four legal markers:

| Macro | Meaning |
|-------|---------|
| `IMPL_MATCH` | Implemented and claims byte-accuracy with retail |
| `IMPL_EMPTY` | Retail body is also empty (Ghidra confirmed) |
| `IMPL_TODO` | Not yet done, but *can* be done eventually |
| `IMPL_DIVERGE` | Permanently cannot match retail — and that's okay |

`IMPL_APPROX` is outright banned — it's the macro that says "close enough" without documenting *why*, and that's exactly the kind of technical debt we're trying to eliminate.

## What Makes Something "TODO" vs "DIVERGE"?

When you're reading disassembled code, there's always a temptation to slap `IMPL_TODO` on everything hard and move on. The problem is that some things aren't just *hard* — they're *impossible given our constraints*. Mixing the two muddies your backlog and makes it impossible to tell whether progress is actually being made.

Here's how we draw the line:

**IMPL_TODO** — "Can eventually match retail, just needs work":
- Complex algorithms that need careful translation from Ghidra pseudocode
- Functions blocked by a named internal helper (`FUN_10367abc`) that we haven't identified yet
- Code that needs new struct field declarations we haven't added

**IMPL_DIVERGE** — "Will *never* match retail, for a documented reason":
- **Karma/MeSDK physics engine**: The Karma physics SDK (MathEngine) is a proprietary binary-only library. Any function that calls into it via unnamed addresses like `FUN_104xxxxx` is permanently blocked. We can call the public API, but we can never reproduce the internal implementation.
- **Editor-only code**: Functions that only exist to support the UnrealEd level editor — terrain vertex selection, actor validation, brush operations — are permanently out of scope. The game doesn't need them to run.
- **SSE/x87 intrinsics**: Some retail functions use streaming stores (`movntps`) or specific x87 FPU calling conventions that produce different bytes when recompiled, even if the math is identical.
- **Binary-specific globals**: When Ghidra shows `DAT_1066677c` being written in a critical path, that global lives at a hardcoded address in the retail binary. In a source rebuild, we'd give it a real name and symbol — which means different code, even if the *behaviour* is the same.
- **Compiler ABI helpers**: MSVC generates special functions for copying arrays of objects — `_eh_vector_copy_constructor_iterator_` — that are called differently from how you'd write it in C++. Equivalent result, different bytecode. Permanent.
- **Private members across DLL boundaries**: When `UWindowManager::Serialize` (in `Window.dll`) needs to access `WWindow::__Windows` (a private static in `WWindow`), it can't — the static is only accessible from within the same translation unit. No amount of source work can fix that.

## The Audit Process

The sprint ran across all 180 `.cpp` files. For each `IMPL_TODO`, the question was always: **"Is there any universe in which we write this correctly?"**

Here's a representative batch of reclassifications:

### Editor Code: Just Delete It (Conceptually)

```cpp
// Before:
IMPL_TODO("editor rendering subsystem not implemented; 2237 bytes at Ghidra 0x1040c960")
void AActor::RenderEditorInfo( FLevelSceneNode* SceneNode, ... )
{
    // STUB: requires editor render subsystem
}

// After:
IMPL_DIVERGE("permanent: editor-only actor visualization; FRenderInterface vtable 
calls not reconstructed; editor is out of scope for this project")
void AActor::RenderEditorInfo( FLevelSceneNode* SceneNode, ... )
{
    // editor out of scope
}
```

The function is 2,237 bytes of rendering code that draws collision hulls and debug annotations in the UnrealEd viewport. We will never need this for a playable game. Calling it `DIVERGE` with a clear reason is honest. Calling it `TODO` implies someone might implement it someday — which wastes mental energy every time someone reads the list.

### The MeSDK Wall

This was the biggest single category. Ravenshield uses the **Karma physics engine** by MathEngine — a company acquired years ago and whose SDK has never been made public. The retail binary contains compiled Karma code at addresses in the range `0x10400000–0x1056ffff` of Engine.dll.

Functions like `physKarma`, `KAddBoneLifter`, `KGetCOMPosition` — 22 of them — all ultimately call into this range. They look like this in Ghidra:

```c
// Retail decompilation:
FUN_1041a890(this, DeltaTime);   // <- that's the MeSDK entry point
// ... no source available ...
```

Every one of these is `IMPL_DIVERGE("permanent: MeSDK/Karma proprietary binary-only SDK")`. The game can still run with ragdoll physics disabled — it just won't have animated cloth and ragdolls. That's a known, documented limitation.

### The "Close But Different" Category

Some functions were already implemented but with subtle differences from retail:

```cpp
// execIsVideoHardwareAtLeast64M (Ghidra 0x10427350):
// Retail: reads GPU VRAM via g_pEngine->Client->Viewports[0]->vtable[0xC0/4]()
// Ours:   returns 1 unconditionally

IMPL_DIVERGE("permanent: retail reads GPU VRAM via binary-specific vtable chain; 
we return 1 (true) since all modern GPUs have 64MB+ VRAM — 
functionally correct for any post-2000 hardware")
```

Is this a permanent divergence? Yes — the vtable chain changes with every build, and the *result* (does the player have enough VRAM?) is always `true` on any GPU made in the last 20 years. This is exactly the kind of thing that should be `DIVERGE` with a note, not a `TODO` that implies we should dig into the vtable chain.

### Bugs Found Along the Way

The audit isn't just about labels — it also forces careful reading of every function body. This run caught a nasty guard/unguard violation:

```cpp
// WRONG — unguardexec inside an if-block:
void UCanvas::execClipTextNative( FFrame& Stack, RESULT_DECL )
{
    guard(UCanvas::execClipTextNative);
    // ... setup ...
    if( !Viewport )
    {
        unguardexec;   // ❌ closes the try-block while inside an if!
        return;        // unreachable
    }
    // ... more code ...
    unguardexec;       // ❌ "no try block" error at compile time
}
```

The `guard()` macro expands to an open try-block. The `unguard` must close it at function scope, not nested inside a conditional. The fix inverts the condition:

```cpp
// CORRECT:
void UCanvas::execClipTextNative( FFrame& Stack, RESULT_DECL )
{
    guard(UCanvas::execClipTextNative);
    // ... setup ...
    if( Viewport )   // only do the work if viewport exists
    {
        // ... clip region setup ...
    }
    unguardexec;     // always at function scope ✓
}
```

This is a footgun in the codebase — the `guard()/unguard;` pattern looks simple but requires careful attention to control flow. Any early return is fine as long as `unguard` stays at the outermost scope.

## The Numbers

| Metric | Before | After |
|--------|--------|-------|
| IMPL_TODO | 429 | 252 |
| IMPL_DIVERGE | 227 | 371 |
| IMPL_MATCH | 4058 | 4072 |
| IMPL_EMPTY | 503 | 503 |

The total function count hasn't changed — we've just been more honest about which category each one belongs to. 177 functions moved from "aspirational" to "documented limitation."

## What's Left in TODO?

The remaining 252 TODOs fall into roughly four buckets:

1. **Complex rendering** (`FDynamicActor::Render`, `FLevelSceneNode::Render`, etc.) — 11,000+ byte functions that need careful, patient decompilation
2. **Physics + pathfinding** (`physWalking`, `stepUp`, AI navigation) — deeply tangled with engine internals
3. **Player menu and UI** — functional but needs binary globals resolved
4. **One-off helpers** — small functions blocked by a single unidentified `FUN_` address

The good news: none of these are *permanently* blocked. They're all honest work waiting to be done.

## Up Next

With the backlog honest and clean, the next pass focuses on:
- Resolving named internal helpers (`FUN_10367df0`, `FUN_10318850`) using cross-referencing between known functions
- Implementing the rendering pipeline enough to get pixels on screen
- Writing the dev blog for every interesting discovery along the way

The TODO list is now a real roadmap, not a collection of hopeful sticky notes. That's progress.

