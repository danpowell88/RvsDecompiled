/*=============================================================================
    ImplSource.h — Function source attribution macros

    Every function definition in a .cpp file MUST be immediately preceded by
    exactly one IMPL_xxx macro. These macros expand to nothing at compile time
    (zero overhead) but are machine-parseable by tools/verify_impl_sources.py.

    VALID MACROS (use one of these):

      IMPL_MATCH(dll, addr)   — Exact decompilation from Ghidra. Claims byte parity.
      IMPL_EMPTY(reason)      — Retail is also empty/trivial (Ghidra confirmed).
      IMPL_DIVERGE(reason)    — PERMANENT divergence only. Not for pending work.
      IMPL_TODO(reason)       — Temporary: Ghidra body identified, implementation
                                 pending. Must NOT be used for permanent divergences.

    BANNED MACROS (build fails if present):

      IMPL_APPROX             — Never use. Replaced by IMPL_MATCH + IMPL_DIVERGE.

    KEY DISTINCTION — IMPL_TODO vs IMPL_DIVERGE:
      Use IMPL_TODO when:  the Ghidra export is found and the function CAN be
                           implemented, but hasn't been yet. These are work items.
      Use IMPL_DIVERGE when: the function will NEVER match retail (defunct live
                           services, Karma/MeSDK proprietary, not in export table,
                           rdtsc profiling with hardware-specific CPUID chains).

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
// IMPL_TODO(reason)
//   Temporary placeholder. The Ghidra body for this function has been
//   identified and the implementation is planned but not yet written.
//   Use this when:
//     - The function is in the Ghidra export at a known address
//     - The implementation would be correct but needs more work
//     - The function is blocked by an unresolved helper (FUN_xxx)
//       that is itself being tracked as a TODO
//
//   Do NOT use for functions that will never match retail — use IMPL_DIVERGE.
//
//   Example:
//     IMPL_TODO("Ghidra 0x10318850: DXT decompressor — dispatch table not yet mapped")
//     void UTexture::Decompress() { guard(UTexture::Decompress); unguard; }
// ---------------------------------------------------------------------------
#define IMPL_TODO(reason)

// ---------------------------------------------------------------------------
// IMPL_APPROX(reason) — BANNED. BUILD FAILS when present (IMPL_STRICT mode).
//   Never use this in committed code. Use IMPL_MATCH, IMPL_EMPTY, IMPL_DIVERGE,
//   or IMPL_TODO instead.
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
//   Implementation exists and is the best achievable, but will NEVER match
//   the retail binary exactly. Must document why this is permanent.
//
//   Valid reasons (must be genuinely permanent):
//     - Defunct live services (GameSpy, CD-key servers shut down)
//     - Karma/MeSDK proprietary — binary-only SDK, no source
//     - rdtsc profiling chains referencing hardware CPUID results
//     - Function not in Ghidra export table (inlined/static in retail)
//
//   NOT valid reasons (use IMPL_TODO instead):
//     - "Not yet implemented"
//     - "Pending decompilation"
//     - "FUN_xxx helper not yet resolved" (unless the helper itself is permanent)
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

// ---------------------------------------------------------------------------
// __rdtsc() compatibility
//   MSVC 7.1 does not expose __rdtsc() as a C++ intrinsic. Use inline asm.
//   This is guarded so VS2019+ continues to use the real intrinsic from
//   <intrin.h>. All sites that include <intrin.h> should guard that include
//   with #if _MSC_VER > 1310.
// ---------------------------------------------------------------------------
#if _MSC_VER <= 1310
    static inline unsigned __int64 _RVS_RDTSC()
    {
        unsigned long _lo, _hi;
        __asm {
            rdtsc
            mov _lo, eax
            mov _hi, edx
        }
        return ((unsigned __int64)_hi << 32) | _lo;
    }
    #define __rdtsc _RVS_RDTSC
#endif

#endif // IMPL_SOURCE_H
