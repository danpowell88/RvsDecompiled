# do_impl_convert.py
import re

def is_permanent(line_text):
    """Return True if this IMPL_DIVERGE should be kept (permanent divergence)."""
    t = line_text
    permanent_markers = [
        # rdtsc
        'omits rdtsc',
        'rdtsc profiling omitted',
        'omitting rdtsc',
        'binary-specific rdtsc',
        # catch-only / not exported
        'catch-only',
        'body not exported',
        'APawn override not found',
        'not exported',
        'not in Ghidra export',
        'not found in Engine exports',
        # FNetworkNotify this-pointer
        'this-pointer offset differs',
        # Karma SDK
        'full Karma SDK',
        'unresolved Karma internal',
        # Audio subsystem
        'UAudioSubsystem::PlaySound',
        'UAudioSubsystem::PlayOwnedSound',
        'UAudioSubsystem::DemoPlaySound',
        'audio subsystem not implemented',
        # PunkBuster
        'PunkBuster client not implemented',
        'PunkBuster server not implemented',
        'PunkBuster not implemented',
        'PunkBuster INIT',
        'FUN_1047f210',  # PB status lookup
        'FUN_1047e850',  # PB enabled check
        # Compiler codegen (permanent)
        'ECX-based thiscall, no push ebp',
        'ECX thiscall, integer regs for FVector), our compiler uses SSE2',
        'codegen differs from retail MSVC 7.1',
        'ESI-based frame, MSVC 2019 generates EBP+SEH',
        # Binary-specific globals
        'DAT_1066679c',
        'DAT_10666790',
        'DAT_1066677c',
        'DAT_10666b50',
        'DAT_10650414',
        'DAT_106666f4',
        'DAT_10666b2c',
        # Binary-specific vtables/render subsystem
        'binary-specific vtable',
        'binary-specific FUN_',
        'binary-specific global',
        # Projector / static mesh render
        'projector render subsystem not implemented',
        'retail rebuilds static mesh batches',
        # String literal differences
        'our build string literals differ',
        # Intentional null guard
        'Ghidra has no null guard; added for safety',
        # Music/audio subsystem
        'music playback not implemented',
        'music stop not implemented',
        # Specific audio stubs (not UAudioSubsystem declaration, but uses audio subsystem)
        'parses aActor but performs no action \u2014 audio subsystem',
        'parses Sound but performs no action \u2014 audio subsystem',
        'parses fTime/iFade/eSlot but performs no action \u2014 audio subsystem',
        'parses BankName but performs no action \u2014 audio subsystem',
        'parses VolumeType and NewVolume but performs no action \u2014 audio subsystem',
        'no-op stub \u2014 audio subsystem',
        'always returns 0 \u2014 audio subsystem',
        'always returns 0 \u2014 music playback',
        'always returns 0 \u2014 music stop',
        'always returns 0 \u2014 PunkBuster',
        # Resolution/VRAM vtable
        'binary-specific vtable; hardcoded fallback',
        'binary-specific vtable; texture replacement',
        # Karma
        'too complex to reconstruct without full Karma SDK',
        'requires full Karma SDK',
        # Pre/post net receive binary globals
        'retail writes actor state snapshot to binary globals',
        'reads binary globals saved by PreNetReceive',
        'calls XLevel MoveActor via vtable[0x9c] with location from DAT_',
        'retail also optimises via DAT_10650414',
        'loading tick uses local static instead of retail binary global DAT_',
    ]
    for marker in permanent_markers:
        if marker.lower() in t.lower():
            return True
    return False

def convert_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    changed = 0
    kept = 0
    for i, line in enumerate(lines):
        if 'IMPL_DIVERGE(' in line:
            if not is_permanent(line):
                lines[i] = line.replace('IMPL_DIVERGE(', 'IMPL_TODO(', 1)
                changed += 1
                print(f"  L{i+1}: CONVERTED: {line.strip()[:120]}")
            else:
                kept += 1
                print(f"  L{i+1}: KEPT:      {line.strip()[:120]}")

    with open(filepath, 'w', encoding='utf-8') as f:
        f.writelines(lines)

    print(f"\n{filepath}:")
    print(f"  Converted {changed} entries to IMPL_TODO")
    print(f"  Kept      {kept} entries as IMPL_DIVERGE")
    return changed, kept

total_converted = 0
total_kept = 0
for fp in [
    r'C:\Users\danpo\Desktop\rvs\src\Engine\Src\UnPawn.cpp',
    r'C:\Users\danpo\Desktop\rvs\src\Engine\Src\UnActor.cpp',
    r'C:\Users\danpo\Desktop\rvs\src\Engine\Src\UnLevel.cpp',
]:
    c, k = convert_file(fp)
    total_converted += c
    total_kept += k

print(f"\n{'='*60}")
print(f"Total converted: {total_converted}")
print(f"Total kept:      {total_kept}")
