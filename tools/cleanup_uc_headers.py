#!/usr/bin/env python3
"""
UC code quality cleanup:
1. Remove "// From SDK 1.56 - verify still applicable" placeholder lines (1707 files)
2. Convert /*=====*/ block-comment headers to //===== line-comment style
3. Add SDK revision history to files that are missing it (728 files with SDK equiv)

Run from repo root:
    python tools/cleanup_uc_headers.py [--dry-run] [--task 1|2|3|all]
"""
import re
import sys
from pathlib import Path

DRY_RUN = "--dry-run" in sys.argv
TASKS = set()
for arg in sys.argv[1:]:
    if arg.startswith("--task"):
        val = arg.split("=", 1)[1] if "=" in arg else sys.argv[sys.argv.index(arg) + 1]
        TASKS.add(val)
if not TASKS:
    TASKS = {"all"}

SDK_BASE = Path("sdk/1.56 Source Code")
SRC_BASE = Path("src")

# ─── Task 1: Remove "verify still applicable" placeholder ──────────────────

PLACEHOLDER_PATTERN = re.compile(
    r"//={10,}\n// From SDK 1\.56 - verify still applicable\n//={10,}\n",
    re.MULTILINE,
)

def task1_remove_placeholder(text: str) -> tuple[str, bool]:
    """Remove the redundant 'verify still applicable' block."""
    new_text, n = PLACEHOLDER_PATTERN.subn("", text)
    return new_text, n > 0

# ─── Task 2: Fix /*=====*/ block-comment headers ───────────────────────────

BLOCK_HEADER_PATTERN = re.compile(
    r"^/\*={10,}\n(.*?)\n={10,}\s*\*/",
    re.MULTILINE | re.DOTALL,
)

def task2_fix_block_headers(text: str) -> tuple[str, bool]:
    """Convert /*==...*/ block comments to //==... line comments."""
    def replace_block(m):
        inner = m.group(1)
        lines = inner.splitlines()
        result = ["//=" * 23 + "//"]
        for line in lines:
            line = line.lstrip("/ *")
            result.append("// " + line.strip() if line.strip() else "//")
        result.append("//=" * 23 + "//")
        return "\n".join(result)
    
    new_text, n = BLOCK_HEADER_PATTERN.subn(replace_block, text)
    return new_text, n > 0

# ─── Task 3: Add SDK revision history ──────────────────────────────────────

def get_sdk_header(sdk_path: Path) -> str | None:
    """Extract the header comment block from an SDK file."""
    if not sdk_path.exists():
        return None
    try:
        text = sdk_path.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return None
    
    # Find the //===...=== header block(s) before the class declaration
    lines = text.splitlines()
    header_lines = []
    in_header = False
    found_class = False
    
    for line in lines:
        stripped = line.strip()
        if re.match(r"class\s+\w", stripped):
            found_class = True
            break
        if stripped.startswith("//") or stripped == "" or stripped.startswith("/*"):
            header_lines.append(line)
        elif not in_header:
            header_lines.append(line)
    
    if not header_lines:
        return None
    
    # Only return if it contains meaningful content (revision history, copyright, description)
    combined = "\n".join(header_lines)
    if not re.search(r"Revision history|Created by|Copyright.*Ubi|:.*\.uc", combined, re.IGNORECASE):
        return None
    
    return "\n".join(header_lines).strip()

def has_revision_history(text: str) -> bool:
    return bool(re.search(r"Revision history|Created by|Copyright.*Ubi", text, re.IGNORECASE))

def task3_add_sdk_history(text: str, sdk_path: Path) -> tuple[str, bool]:
    """Add SDK header content to files missing revision history."""
    if has_revision_history(text):
        return text, False
    
    sdk_header = get_sdk_header(sdk_path)
    if not sdk_header:
        return text, False
    
    # Find end of our standard header (after the first //=====...===== block)
    lines = text.splitlines(keepends=True)
    insert_after = 0
    in_header_block = False
    
    for i, line in enumerate(lines):
        stripped = line.strip()
        if re.match(r"//={10,}", stripped):
            if not in_header_block:
                in_header_block = True
            else:
                insert_after = i + 1
                break
    
    if insert_after == 0:
        return text, False
    
    # Build the new SDK block
    sdk_block = "\n" + sdk_header + "\n"
    
    new_lines = lines[:insert_after] + [sdk_block + "\n"] + lines[insert_after:]
    return "".join(new_lines), True

# ─── Main processing ────────────────────────────────────────────────────────

def process_file(path: Path) -> tuple[int, list[str]]:
    """Process one source UC file. Returns (change_count, change_descriptions)."""
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except Exception as e:
        return 0, [f"ERROR reading: {e}"]
    
    original = text
    changes = []
    
    if "all" in TASKS or "1" in TASKS:
        text, changed = task1_remove_placeholder(text)
        if changed:
            changes.append("removed placeholder")
    
    if "all" in TASKS or "2" in TASKS:
        text, changed = task2_fix_block_headers(text)
        if changed:
            changes.append("fixed block header")
    
    if "all" in TASKS or "3" in TASKS:
        # Find SDK equivalent
        rel = path.relative_to(SRC_BASE)
        parts = rel.parts  # e.g. ('Engine', 'Classes', 'Actor.uc')
        if len(parts) == 3:
            module = parts[0]
            filename = parts[2]
            sdk_path = SDK_BASE / module / "Classes" / filename
            if not sdk_path.exists():
                # Try case-insensitive match
                sdk_dir = SDK_BASE / module / "Classes"
                if sdk_dir.exists():
                    matches = [f for f in sdk_dir.iterdir() if f.name.lower() == filename.lower()]
                    sdk_path = matches[0] if matches else sdk_path
            
            text, changed = task3_add_sdk_history(text, sdk_path)
            if changed:
                changes.append("added SDK history")
    
    if text != original:
        if not DRY_RUN:
            path.write_text(text, encoding="utf-8")
        return len(changes), changes
    
    return 0, []

def main():
    total_files = 0
    total_changes = 0
    change_summary = {}
    
    for uc in sorted(SRC_BASE.rglob("*.uc")):
        n, descriptions = process_file(uc)
        if n > 0:
            total_files += 1
            total_changes += n
            for d in descriptions:
                change_summary[d] = change_summary.get(d, 0) + 1
    
    mode = "[DRY RUN] " if DRY_RUN else ""
    print(f"{mode}Files changed: {total_files}")
    print(f"{mode}Total changes: {total_changes}")
    print(f"\nChange breakdown:")
    for action, count in sorted(change_summary.items(), key=lambda x: -x[1]):
        print(f"  {action}: {count}")

if __name__ == "__main__":
    main()
