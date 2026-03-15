#!/usr/bin/env python3
"""
Audit IMPL_DIVERGE entries and reclassify to IMPL_TODO where appropriate.

IMPL_DIVERGE = permanent external constraint (can NEVER match retail)
IMPL_TODO = Ghidra body exists but implementation incomplete (CAN eventually match)

Run from repo root:
    python tools/audit_impl_diverge.py [--dry-run]
"""
import re
import sys
from pathlib import Path

DRY_RUN = "--dry-run" in sys.argv

# Patterns that indicate a TRUE permanent divergence (keep IMPL_DIVERGE)
PERMANENT_PATTERNS = [
    re.compile(r"Karma|MeSDK|MathEngine|physKarma|physRagDoll|ragdoll", re.IGNORECASE),
    re.compile(r"GameSpy|CDKey|cdkey|master server", re.IGNORECASE),
    re.compile(r"binkw32|Bink Video", re.IGNORECASE),
    re.compile(r"PunkBuster", re.IGNORECASE),
    re.compile(r"SafeDisc", re.IGNORECASE),
    re.compile(r"rdtsc|CPUID", re.IGNORECASE),
    re.compile(r"absent from export|not in.*export|free func.*inlined|static.*inlined|not exported", re.IGNORECASE),
    re.compile(r"NullDrv|null renderer", re.IGNORECASE),
    re.compile(r"Ogg Vorbis.*not available", re.IGNORECASE),
]

# Patterns that indicate should be IMPL_TODO (Ghidra body exists)
TODO_PATTERNS = [
    re.compile(r"Ghidra 0x[0-9a-fA-F]+"),
    re.compile(r"retail 0x[0-9a-fA-F]+"),
    re.compile(r"R6Engine\.dll 0x[0-9a-fA-F]+"),
    re.compile(r"Core\.dll 0x[0-9a-fA-F]+"),
    re.compile(r"Window\.dll 0x[0-9a-fA-F]+"),
    re.compile(r"found at 0x[0-9a-fA-F]+"),
    re.compile(r"found at Core\.dll"),
    re.compile(r"FUN_[0-9a-fA-F]{6,}"),  # blocked by unresolved FUN_ helper
    re.compile(r"audio subsystem not implemented"),
    re.compile(r"audio.*not.*implement", re.IGNORECASE),
    re.compile(r"vtable.*slot.*not declared"),
    re.compile(r"not declared.*vtable"),
]

def is_permanent(reason: str) -> bool:
    return any(p.search(reason) for p in PERMANENT_PATTERNS)

def should_be_todo(reason: str) -> bool:
    if is_permanent(reason):
        return False
    return any(p.search(reason) for p in TODO_PATTERNS)

def process_file(path: Path) -> tuple[int, int]:
    """Returns (conversions, kept) count."""
    text = path.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines(keepends=True)
    
    new_lines = []
    conversions = 0
    kept = 0
    
    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.rstrip('\n\r')
        
        if stripped.startswith("IMPL_DIVERGE("):
            m = re.match(r'^(IMPL_DIVERGE\(")([^"]*)("\))', stripped)
            if m:
                prefix, reason, suffix = m.group(1), m.group(2), m.group(3)
                if should_be_todo(reason):
                    new_line = line.replace(
                        f'IMPL_DIVERGE("{reason}")',
                        f'IMPL_TODO("{reason}")'
                    )
                    new_lines.append(new_line)
                    conversions += 1
                    i += 1
                    continue
                else:
                    kept += 1
            else:
                kept += 1
        
        new_lines.append(line)
        i += 1
    
    if conversions > 0 and not DRY_RUN:
        path.write_text("".join(new_lines), encoding="utf-8")
    
    return conversions, kept

def main():
    src = Path("src")
    total_converted = 0
    total_kept = 0
    files_changed = []
    
    for cpp in sorted(src.rglob("*.cpp")):
        converted, kept = process_file(cpp)
        if converted > 0:
            total_converted += converted
            files_changed.append((cpp.name, converted))
        total_kept += kept
    
    mode = "[DRY RUN] " if DRY_RUN else ""
    print(f"{mode}Converted IMPL_DIVERGE → IMPL_TODO: {total_converted}")
    print(f"{mode}Kept as IMPL_DIVERGE: {total_kept}")
    print(f"\nFiles changed ({len(files_changed)}):")
    for fname, count in sorted(files_changed, key=lambda x: -x[1]):
        print(f"  {fname}: {count} converted")

if __name__ == "__main__":
    main()
