/*=============================================================================
    ImplSource.h — Function source attribution macros

    Every function definition in a .cpp file MUST be immediately preceded by
    exactly one IMPL_xxx macro. These macros expand to nothing at compile time
    (zero overhead) but are machine-parseable by tools/verify_impl_sources.py.

    The classification is binary: either the function body was derived from
    Ghidra analysis of the retail binary (IMPL_MATCH), or it wasn't (IMPL_APPROX).
    Everything else is a variant of those two, or a documented special case.

    BUILD RULE: IMPL_TODO and IMPL_APPROX are BOTH forbidden — build fails (IMPL_STRICT mode is ON).
    IMPL_MATCH, IMPL_EMPTY, and IMPL_DIVERGE are the only valid macros.

    See AGENTS.md for authoring guidance.
=============================================================================*/

#pragma once

#ifndef IMPL_SOURCE_H
#define IMPL_SOURCE_H

// ---------------------------------------------------------------------------
// IMPL_MATCH(dll, addr)
//   Exact decompilation from Ghidra analysis of the named retail DLL at the
//   given virtual address. Claims byte-level parity with the retail binary.
//
//   'addr' is the virtual address as shown in Ghidra (includes DLL load base).
//   For Engine.dll loaded at 0x10300000: VA = 0x10300000 + RVA.
//
//   Example:
//     IMPL_MATCH("Engine.dll", 0x10367670)
//     void AActor::physKarmaRagDoll_internal(FLOAT DeltaTime) { ... }
// ---------------------------------------------------------------------------
#define IMPL_MATCH(dll, addr)

// ---------------------------------------------------------------------------
// IMPL_APPROX(reason) — BANNED. BUILD FAILS when present (IMPL_STRICT mode).
//   Never use this in committed code. It is only here so the verifier can
//   detect and reject it. Use IMPL_MATCH, IMPL_EMPTY, or IMPL_DIVERGE instead.
// ---------------------------------------------------------------------------
#define IMPL_APPROX(reason)

// ---------------------------------------------------------------------------
// IMPL_INTENTIONALLY_EMPTY(reason)
//   The retail binary also has a trivial or empty body here, confirmed via
//   Ghidra. This is the correct final state — no implementation needed.
//
//   Example:
//     IMPL_INTENTIONALLY_EMPTY("NullDrv — retail body is an identical empty stub")
//     void UNullRenderDevice::Lock(UViewport*, BYTE*) {}
// ---------------------------------------------------------------------------
#define IMPL_INTENTIONALLY_EMPTY(reason)

// ---------------------------------------------------------------------------
// IMPL_PERMANENT_DIVERGENCE(reason)
//   Implementation exists and is the best achievable, but will never match
//   the retail binary exactly. Must document why.
//   Common cases: defunct live services (GameSpy), hardware-specific globals.
//
//   Note: "proprietary SDK unavailable" is NOT a valid reason here — if a
//   function is statically linked into a retail DLL it can be decompiled.
//   Use IMPL_APPROX for functions pending decompilation instead.
//
//   Example:
//     IMPL_PERMANENT_DIVERGENCE("GameSpy servers shut down 2014; auth always fails")
//     UBOOL UGameSpyAuth::Authenticate(...) { return FALSE; }
// ---------------------------------------------------------------------------
#define IMPL_PERMANENT_DIVERGENCE(reason)

// ---------------------------------------------------------------------------
// Aliases for backward compatibility — prefer the canonical names above.
// ---------------------------------------------------------------------------

// IMPL_GHIDRA — alias for IMPL_MATCH
#define IMPL_GHIDRA(dll, addr)

// IMPL_EMPTY — alias for IMPL_INTENTIONALLY_EMPTY
#define IMPL_EMPTY(reason)

// IMPL_DIVERGE — alias for IMPL_PERMANENT_DIVERGENCE
#define IMPL_DIVERGE(reason)

// ---------------------------------------------------------------------------
// IMPL_TODO(reason) — BANNED. BUILD FAILS when present (IMPL_STRICT mode).
//   Never use this in committed code. It is only here so the verifier can
//   detect and reject it. Use IMPL_MATCH, IMPL_EMPTY, or IMPL_DIVERGE.
// ---------------------------------------------------------------------------
#define IMPL_TODO(reason)


// ---------------------------------------------------------------------------
// COMPILE_CHECK(expr, tag)
//   Compile-time assertion compatible with MSVC 7.1 and later.
//   'tag' must be a valid C identifier (no spaces/quotes).
//   On C++11+ compilers, expands to static_assert for a better error message.
//
//   Example:
//     COMPILE_CHECK(sizeof(FStream) == 0x28, FStream_size_must_be_0x28);
// ---------------------------------------------------------------------------
#if _MSC_VER < 1600
    // MSVC 7.1 – 9.0: no static_assert. Use negative-size array trick.
    #define COMPILE_CHECK(expr, tag) typedef char _compile_check_##tag[(expr) ? 1 : -1]
#else
    #define COMPILE_CHECK(expr, tag) static_assert(expr, #tag)
#endif

// ---------------------------------------------------------------------------
// noexcept compatibility
//   MSVC 7.1 (1310) predates C++11 and does not have the noexcept keyword.
//   Use the C++98 empty throw() specification as an equivalent.
//   Modern compilers have noexcept as a keyword, so no macro is needed there.
// ---------------------------------------------------------------------------
#if _MSC_VER <= 1310
    #define noexcept throw()
#endif

#endif // IMPL_SOURCE_H
