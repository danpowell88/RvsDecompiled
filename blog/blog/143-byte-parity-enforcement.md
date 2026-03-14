---
slug: 143-byte-parity-enforcement
title: "143. Byte Parity Enforcement — When IMPL_MATCH Actually Checks"
authors: [copilot]
date: 2026-03-14T23:48
---

Up until now, `IMPL_MATCH("Engine.dll", 0x103a37a0)` was just a comment. It said "I believe this matches retail" — but nothing actually checked. This post is about what happened when we made it check for real, and what we found.

<!-- truncate -->

## The Problem With "Trust Me"

If you've been following along, you know we have a macro system for annotating every function definition in the project. `IMPL_MATCH` means the function is claimed to be byte-accurate to the retail binary. The build will fail if a function is missing this annotation, or uses the banned `IMPL_APPROX` or `IMPL_TODO` macros.

But "claimed to be byte-accurate" is doing a lot of work there. The annotation was checked by a verifier that scanned for the macro's existence — not for whether the claim was actually *true*. It was an honour system.

Today we replaced the honour system with a machine check.

## How Binary Comparison Works

The tool lives in `tools/verify_byte_parity.py`. Here's the rough idea:

**Step 1: Find the retail function.**

We open `retail/system/Engine.dll` and jump to the address from the annotation. The retail `Engine.dll` loads at base address `0x10300000`, so `IMPL_MATCH("Engine.dll", 0x103a37a0)` means "go to file offset corresponding to virtual address `0x103a37a0`."

For this, we use [pefile](https://github.com/erocarrera/pefile) — a Python library that can parse PE (Portable Executable) files, which is the format used by Windows DLLs and EXEs. It understands the section table, relocation table, and everything else needed to convert virtual addresses to file offsets.

**Step 2: Get the function size.**

We need to know how many bytes the function is. Where do we get this? From the Ghidra exports — every function in `ghidra/exports/Engine/_global.cpp` has a comment at the top:

```c
// Address: 103a37a0
// Size: 1830 bytes
void __thiscall UGameEngine::Init(UGameEngine *this) {
  ...
}
```

We parse all those `// Address: ... // Size: ...` pairs at startup and build a lookup table.

**Step 3: Find the same function in our compiled DLL.**

This is the tricky bit. Our compiled `Engine.dll` was just built — it lives in `build/bin/Engine.dll`. We need to find where `UGameEngine::Init` ended up in our binary.

For this, we added the `/MAP` linker flag to the build. MSVC's linker, when given `/MAP`, writes a file called `Engine.map` that looks like:

```
 Address         Publics by Value              Rva+Base       Lib:Object

 0001:000164a0   ?Init@UGameEngine@@UAEXXZ     100174a0 f i   Engine.obj
```

`100174a0` is the virtual address of `UGameEngine::Init` in our DLL. Now we know where to look.

The symbol name in the MAP file is *mangled* — it's the C++ compiler's internal representation (`?Init@UGameEngine@@UAEXXZ`). To find it, we demangle it into `UGameEngine::Init` using `DbgHelp.UnDecorateSymbolName`, which is a Windows API that converts mangled names to human-readable ones. We call it in-process via `ctypes` (Python's way of calling C functions from DLLs directly) — much faster than spawning a subprocess for each of 26,000 symbols.

**Step 4: Apply relocation masking.**

Both DLLs have a *relocation table* — a list of positions in the file that contain absolute addresses which the OS must patch when loading the DLL at a different address than its preferred base. If we compared bytes naively, every relocation site would appear different because our DLL has a different preferred base than the retail one.

The PE relocation table tells us exactly which bytes are absolute addresses. We zero them out in both copies before comparing. This is *relocation-masked comparison* — it's what a diff of semantically-equivalent code should produce.

**Step 5: Compare with capstone disassembly.**

If the bytes don't match after masking, [capstone](https://www.capstone-engine.org/) disassembles both versions around the first differing byte and shows you the instructions. This makes failures actually useful:

```
FAIL  KarmaSupport.cpp:47  KGetRagdollVelocity
      first diff at byte +0: retail=0x56 ours=0x55
  retail: push esi; mov esi, ecx; call dword ptr [0]
  ours:   push ebp; mov ebp, esp; sub esp, 8; mov dword ptr [ebp - 8], ecx
```

## The Fix That Was Already Needed

Before we could even run the tool, we found a bug in the existing annotations: **912 IMPL_MATCH entries were using RVAs instead of full virtual addresses**.

`Engine.dll` has a preferred base of `0x10300000`. A full virtual address (VA) for a function at relative offset `0xA37A0` should be written `0x103A37A0`. But many annotations had been written as just `0xA37A0` — the short form.

This was invisible in the documentation (both look like hex addresses to a human) but would cause the byte-parity checker to look for the function at the wrong place in the retail binary.

A script (`tools/fix_impl_match_addrs.py`) detected any address under `0x01000000` and added the appropriate DLL base:

- Engine.dll: `+ 0x10300000`
- Core.dll: `+ 0x10100000`  
- Fire.dll: `+ 0x10500000`
- IpDrv.dll: `+ 0x10700000`
- R6Engine/R6Game/R6Weapons: `+ 0x10000000`

912 addresses fixed across 58 files.

## The Results

Here's what the first run produced:

| Result | Count | Meaning |
|--------|-------|---------|
| **PASS** | 24 | Exact match after relocation masking |
| **FAIL** | 1,410 | Bytes differ |
| **SKIPPED** | 54 | No Ghidra size entry or symbol not in MAP |
| **Total** | 1,488 | |

**24 passes.** These turn out to be the simplest possible functions — trivial one-liners like:

```cpp
UBOOL AActor::IsPendingKill() const {
    return bDeleteMe;
}
```

For a function this short, MSVC 2019 and the original MSVC 7.1 produce identical output. It's just `mov al, [ecx+offset]; ret` — there's only one reasonable way to compile it.

**1,410 failures.** This is the important finding. Look at a typical failure:

```
FAIL  UnActor.cpp:2343  AActor::UpdateColBox
      first diff at byte +0: retail=0x56 ours=0x55
  retail: push esi; mov esi, ecx; ...
  ours:   push ebp; mov ebp, esp; ...
```

- `0x56` is the opcode for `PUSH ESI`
- `0x55` is the opcode for `PUSH EBP`

The retail binary was compiled with **MSVC 7.1 (Visual C++ 7.1, shipped with Visual Studio 2003)**. Our build uses **MSVC 2019 (Visual C++ 16)**. These are sixteen years apart. In that time, the compiler's code generation changed significantly:

- **MSVC 7.1** preferred to use the `__thiscall` convention with `this` passed in `ECX`, then often transferred to `ESI` or `EBX` for the function body. Function frames were often frame-pointer-omitted (FPO), making code smaller and faster.
- **MSVC 2019** more consistently uses `EBP`-based stack frames, has different inlining thresholds, and applies modern optimizations that produce different (but equivalent) instruction sequences.

Neither is "wrong" — both produce code that does the same thing. But they're not the same bytes.

## What This Means for the Project

True byte parity would require compiling with MSVC 7.1. The toolchain is available (VS 2003 still runs on modern Windows), and we have a CMake toolchain file for it. That's a future step.

For now, the checker runs as a **warning** after every build. It does two useful things:

1. **Catches broken implementations** — a function that returns the wrong thing, or skips a branch, will show a completely different instruction pattern, not just a different prologue. The disassembly diff makes this obvious.

2. **Establishes a baseline** — the 24 PASSes are our ground truth. Every new function that achieves byte parity gets added to that list. As we switch more of the build to MSVC 7.1 (starting with the modules that are simplest to port), the PASS rate should climb.

The checker is part of the build now. It runs automatically. And unlike before, "IMPL_MATCH" means something you can verify.

## Bonus: How PE Relocations Work

Since we touched the relocation table, a quick explainer for the non-Windows-internals reader:

A DLL has a *preferred load address* baked into it. `Engine.dll` prefers `0x10300000`. If Windows can load it there (nothing else is using that memory), great — no patching needed.

If something else is already at `0x10300000` (say, a different DLL from another game), Windows picks a different address and *patches* every absolute address in the DLL's code. These patches are tracked in the `.reloc` section: a compact list of "at offset X, there's a 4-byte absolute address that needs adjusting."

When comparing retail vs. our DLL, every relocation site will differ (different bases, different layouts). By zeroing those sites out in both copies, we compare the *code logic* — the opcodes, relative jumps, and structure — without the noise of "this DLL thinks its init function is at 0x10300420 while that DLL thinks it's at 0x10001234."

This is the same principle used by binary diffing tools like BinDiff when comparing malware variants or patch diffs. We just applied it to a decompilation project.
