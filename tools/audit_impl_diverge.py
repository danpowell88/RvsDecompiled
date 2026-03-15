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
    re.compile(r"Karma|MeSDK|MathEngine|physKarma|physRagDoll", re.IGNORECASE),
    re.compile(r"GameSpy|CDKey|cdkey|master server", re.IGNORECASE),
    re.compile(r"binkw32|Bink Video", re.IGNORECASE),
    re.compile(r"PunkBuster", re.IGNORECASE),
    re.compile(r"SafeDisc|no Ghidra match found", re.IGNORECASE),
    re.compile(r"rdtsc|CPUID", re.IGNORECASE),
    re.compile(r"absent from.*export|not in.*export|absent from retail|absent from Core\.dll|absent from Engine\.dll", re.IGNORECASE),
    re.compile(r"free func.*inlined|static.*inlined|not exported|no.*standalone retail.*export|no retail equivalent function", re.IGNORECASE),
    re.compile(r"NullDrv|null renderer", re.IGNORECASE),
    re.compile(r"Ogg Vorbis.*not available", re.IGNORECASE),
    re.compile(r"CPP_PROPERTY cannot address bitfield", re.IGNORECASE),
    re.compile(r"PERMANENT:", re.IGNORECASE),
    re.compile(r"intentionally disabled", re.IGNORECASE),
    re.compile(r"UMaterial does not override PostEditChange in retail"),
    re.compile(r"C\+\+ compiler-generated.*no corresponding"),
    re.compile(r"uses FCoordsFromFMatrix instead of FMatrix::Coords\(\) to avoid Core\.dll link dependency"),
    re.compile(r"template instantiation helper; no retail equivalent"),
    re.compile(r"not a standalone function in the retail DLL"),
    re.compile(r"field layout diverges from binary; Paths/Suppress"),  # struct layout, complex fix
]

# Patterns that indicate should be IMPL_TODO (Ghidra body exists, or retail behavior known)
TODO_PATTERNS = [
    # Has Ghidra / retail address reference
    re.compile(r"Ghidra 0x[0-9a-fA-F]+"),
    re.compile(r"Ghidra ~"),
    re.compile(r"Ghidra catch at 0x"),
    re.compile(r"retail 0x[0-9a-fA-F]+"),
    re.compile(r"R6Engine\.dll 0x[0-9a-fA-F]+"),
    re.compile(r"Core\.dll 0x[0-9a-fA-F]+"),
    re.compile(r"Window\.dll 0x[0-9a-fA-F]+"),
    re.compile(r"found at 0x[0-9a-fA-F]+"),
    re.compile(r"found at Core\.dll"),
    re.compile(r"\(0x[0-9a-fA-F]+\)"),  # e.g., "(0x103b4bd0)"
    # Blocked by unresolved FUN_ helper
    re.compile(r"FUN_[0-9a-fA-F]{3,}"),
    re.compile(r"FUN_ blocker"),
    # Retail behavior described (can be implemented once we understand it)
    re.compile(r"retail is \d+-byte"),
    re.compile(r"retail calls"),
    re.compile(r"retail checks"),
    re.compile(r"retail busy-waits"),
    re.compile(r"retail registers"),
    re.compile(r"retail writes"),
    re.compile(r"retail appends"),
    re.compile(r"retail stores"),
    re.compile(r"retail rebuilds"),
    re.compile(r"retail reads"),
    re.compile(r"retail uses"),
    re.compile(r"DIVERGENCE: retail"),
    # Audio stubs — audio phase will implement
    re.compile(r"audio subsystem not implemented"),
    re.compile(r"audio.*not.*implement", re.IGNORECASE),
    re.compile(r"DIVERGENCE: UAudioSubsystem::"),
    re.compile(r"always returns 0 — music"),
    re.compile(r"always returns 0 — PunkBuster"),
    re.compile(r"EAX toggle is handled at Init"),
    re.compile(r"audio dispatch via vtable"),
    # Structural issues (fixable)
    re.compile(r"vtable.*slot.*not declared"),
    re.compile(r"not declared.*vtable"),
    re.compile(r"vtable\[0x[0-9a-fA-F]+\]"),
    re.compile(r"vtable\[\d+\]"),
    re.compile(r"PrivateStaticClass_exref unresolved"),
    re.compile(r"static file-scope helper"),
    re.compile(r"field layout diverges from binary"),
    # Functional description without explicit permanence
    re.compile(r"MaybeDestroy not called"),
    re.compile(r"DIVERGENCE: uses GViewportHWnd"),
    re.compile(r"complex FCanvasUtil"),
    re.compile(r"875-byte spawn function"),
    re.compile(r"uses unnamed DAT_[0-9a-fA-F]+"),
    re.compile(r"spawn function; FCoords"),
]

def is_permanent(reason: str) -> bool:
    return any(p.search(reason) for p in PERMANENT_PATTERNS)

def should_be_todo(reason: str) -> bool:
    # Special case: "omits rdtsc profiling" with a Ghidra address means the function
    # logic IS implemented but profiling counters are omitted. rdtsc profiling CAN be
    # added back once globals are identified → IMPL_TODO, not a permanent divergence.
    if re.search(r"omits rdtsc", reason, re.IGNORECASE) and re.search(r"Ghidra 0x[0-9a-fA-F]+", reason):
        return True
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
