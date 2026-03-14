/*=============================================================================
    ImplSource.h — Function source attribution macros

    Every function definition in a .cpp file MUST be immediately preceded by
    exactly one IMPL_xxx macro. These macros expand to nothing at compile time
    (zero overhead) but are machine-parseable by tools/verify_impl_sources.py
    and tools/check_byte_parity.py.

    BUILD RULE: IMPL_APPROX causes a build failure. It is a placeholder only —
    every function must eventually be attributed with a real IMPL_xxx.

    See docs/impl_source_guide.md for full authoring guidance.
=============================================================================*/

#pragma once

#ifndef IMPL_SOURCE_H
#define IMPL_SOURCE_H

// ---------------------------------------------------------------------------
// IMPL_GHIDRA(dll, addr)
//   Exact decompilation from Ghidra analysis of the named retail DLL at the
//   given virtual address. Claims byte-level parity with the retail binary.
//   The parity checker (check_byte_parity.py) will fail the build if the
//   compiled function's size diverges from the retail counterpart.
//
//   Example:
//     IMPL_GHIDRA("Engine.dll", 0x10078b40)
//     void AActor::SetBase(AActor* NewBase, FVector NewFloor, FVector Normal)
//     { ... }
// ---------------------------------------------------------------------------
#define IMPL_GHIDRA(dll, addr)

// ---------------------------------------------------------------------------
// IMPL_GHIDRA_APPROX(dll, addr, reason)
//   Ghidra decompilation with a documented, intentional deviation from retail.
//   'reason' is mandatory — describes what differs and why.
//   Exempt from the parity size check (the documented reason covers it).
//
//   Example:
//     IMPL_GHIDRA_APPROX("Engine.dll", 0x100bd2a0,
//         "BSP early-exit path not reconstructed; returns empty region")
//     FPointRegion AActor::GetRegion() const { return FPointRegion(); }
// ---------------------------------------------------------------------------
#define IMPL_GHIDRA_APPROX(dll, addr, reason)

// ---------------------------------------------------------------------------
// IMPL_SDK(path)
//   Taken directly from the official Unreal Engine 1.56 SDK source at 'path'.
//   No intentional modifications; the code matches the SDK verbatim.
//
//   Example:
//     IMPL_SDK("sdk/Ut99PubSrc/Engine/Src/UnLevel.cpp")
//     ULevel::ULevel(UEngine* InOwner) : ... { ... }
// ---------------------------------------------------------------------------
#define IMPL_SDK(path)

// ---------------------------------------------------------------------------
// IMPL_SDK_MODIFIED(path, reason)
//   Sourced from the 1.56 SDK but with documented changes (e.g. D3D7→D3D8
//   port, platform-specific code removed, API difference worked around).
//
//   Example:
//     IMPL_SDK_MODIFIED("sdk/Ut99PubSrc/D3DDrv/Src/D3DRender.cpp",
//         "Ported from D3D7 to D3D8 interface")
//     void FD3DRenderInterface::SetMaterial(...) { ... }
// ---------------------------------------------------------------------------
#define IMPL_SDK_MODIFIED(path, reason)

// ---------------------------------------------------------------------------
// IMPL_INFERRED(reason)
//   Logic inferred from context: naming conventions, calling code, UT99
//   reference source, or related functions in the same file. No direct
//   binary reference — cannot claim byte parity.
//
//   Example:
//     IMPL_INFERRED("Derived from UActorChannel::Close() calling pattern")
//     void UActorChannel::StopReplicating() { ... }
// ---------------------------------------------------------------------------
#define IMPL_INFERRED(reason)

// ---------------------------------------------------------------------------
// IMPL_INTENTIONALLY_EMPTY(reason)
//   The retail binary also has a trivial or empty body here. Confirmed via
//   Ghidra. This is the correct final state — no implementation needed.
//
//   Example:
//     IMPL_INTENTIONALLY_EMPTY("NullDrv — headless renderer; retail body is identical empty stub")
//     void UNullRenderDevice::Lock(UViewport*, BYTE*) {}
// ---------------------------------------------------------------------------
#define IMPL_INTENTIONALLY_EMPTY(reason)

// ---------------------------------------------------------------------------
// IMPL_PERMANENT_DIVERGENCE(reason)
//   Implementation exists and is the best we can do, but will never match
//   the retail binary exactly. Must document why.
//   Common cases: Karma physics (proprietary SDK), GameSpy live servers
//   (defunct), rdtsc profiling counters (binary-specific globals).
//
//   Example:
//     IMPL_PERMANENT_DIVERGENCE("Karma physics — MathEngine SDK proprietary; source unavailable")
//     void AActor::physKarma(FLOAT DeltaTime) { guard(...); unguard; }
// ---------------------------------------------------------------------------
#define IMPL_PERMANENT_DIVERGENCE(reason)

// ---------------------------------------------------------------------------
// IMPL_APPROX(reason)
//   Not yet implemented. BUILD FAILS when any function carries this marker.
//   Replace with a real IMPL_xxx once the function is implemented, or with
//   IMPL_INTENTIONALLY_EMPTY / IMPL_PERMANENT_DIVERGENCE if appropriate.
//
//   Example:
//     IMPL_APPROX("Needs Ghidra analysis of Engine.dll 0x1009a0c0")
//     void UAudioSubsystem::RegisterMusic(UMusic* Music) { guard(...); unguard; }
// ---------------------------------------------------------------------------
#define IMPL_APPROX(reason)

// IMPL_TODO(reason) - stub body pending full Ghidra reconstruction
#define IMPL_TODO(reason)

// IMPL_MATCH(dll, addr) - exact match synonym for IMPL_GHIDRA
#define IMPL_MATCH(dll, addr)

// IMPL_EMPTY(reason) - retail also has trivial/empty body (Ghidra confirmed)
#define IMPL_EMPTY(reason)

// IMPL_DIVERGE(reason) - permanent divergence; will never match retail
#define IMPL_DIVERGE(reason)

#endif // IMPL_SOURCE_H
