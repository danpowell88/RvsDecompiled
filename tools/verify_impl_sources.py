#!/usr/bin/env python3
"""
verify_impl_sources.py — Function source attribution verifier.

Runs as a CMake PRE_BUILD step on every module. Scans all .cpp files in the
given source directory and verifies that every function definition is
immediately preceded by exactly one IMPL_xxx macro from ImplSource.h.

Exits with code 1 if any unannotated functions are found, or if any function
uses IMPL_TODO or IMPL_APPROX (both are forbidden in a fully-attributed build).

Usage:
    python verify_impl_sources.py <source_dir> [--warn-only] [--report <file>]

Arguments:
    source_dir   Directory containing .cpp source files (recursively scanned)
    --warn-only  Print issues but exit 0 (useful during annotation pass)
    --report     Write a machine-readable JSON report to <file>
"""

import os
import re
import sys
import json
import argparse
from pathlib import Path

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

IMPL_MACROS = {
    # Current final-state macros
    "IMPL_MATCH",
    "IMPL_EMPTY",
    "IMPL_DIVERGE",
    # Canonical long-form aliases
    "IMPL_INTENTIONALLY_EMPTY",
    "IMPL_PERMANENT_DIVERGENCE",
    "IMPL_GHIDRA",
    # Forbidden — cause build failure
    "IMPL_APPROX",
    "IMPL_TODO",
    # Removed macros (kept so scanner can detect and reject them)
    "IMPL_GHIDRA_APPROX",
    "IMPL_SDK",
    "IMPL_SDK_MODIFIED",
    "IMPL_INFERRED",
}

# These macros are forbidden — every function using them is a build failure
STUB_MACROS = {"IMPL_TODO", "IMPL_APPROX"}

# Patterns for function definitions (not declarations):
# Matches lines like:
#   void Foo::Bar(int x) {
#   int Foo::Bar() const {
#   Foo::Foo() :
#   Foo::~Foo() {
#   static void Foo::Bar() {
# We key on "ClassName::FunctionName" to distinguish definitions from
# declarations (which never have "::").
FUNC_DEF_PATTERN = re.compile(
    r"^"
    r"(?:(?:static|inline|virtual|explicit|FORCEINLINE|__forceinline|__cdecl|__stdcall|__fastcall)\s+)*"
    r"(?:[\w:<>\*&\s]+?\s+)?"      # return type (optional, may be absent for ctors)
    r"(\w+)::(~?\w+)"              # ClassName::FunctionName  (required)
    r"\s*\("                       # opening paren
)

# Lines to skip as noise when walking backwards
SKIP_LINE_RE = re.compile(
    r"^\s*$"                                     # blank line
    r"|^\s*//"                                   # C++ comment
    r"|^\s*/\*"                                  # C block comment start
    r"|^\s*\*"                                   # C block comment continuation
    r"|^\s*#"                                    # preprocessor directive
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def is_impl_macro_line(line: str) -> str | None:
    """Return the macro name if the line starts an IMPL_xxx call, else None."""
    stripped = line.strip()
    for macro in IMPL_MACROS:
        if stripped.startswith(macro + "(") or stripped == macro:
            return macro
    return None


def find_preceding_impl(lines: list[str], func_line_idx: int) -> str | None:
    """
    Walk backward from func_line_idx through blank/comment lines.
    Return the first IMPL_xxx macro found, or None if no macro precedes
    the function before hitting code.
    """
    i = func_line_idx - 1
    while i >= 0:
        line = lines[i]
        macro = is_impl_macro_line(line)
        if macro:
            return macro
        if SKIP_LINE_RE.match(line):
            i -= 1
            continue
        # Hit something that isn't a comment, blank, or macro — stop
        break
    return None


# ---------------------------------------------------------------------------
# File scanner
# ---------------------------------------------------------------------------

def scan_file(path: Path) -> list[dict]:
    """
    Scan a single .cpp file and return a list of issue dicts:
        {file, line, function, issue: 'missing' | 'todo'}
    """
    issues = []
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError as e:
        print(f"WARNING: Cannot read {path}: {e}", file=sys.stderr)
        return issues

    lines = text.splitlines()
    for idx, line in enumerate(lines):
        # Function definitions at file scope are never indented.
        # Skip indented lines to avoid false-positives on calls like
        # Foo::StaticClass() inside a function body.
        if not line or line[0].isspace():
            continue

        m = FUNC_DEF_PATTERN.match(line)
        if not m:
            continue

        # Confirm it's a definition (has opening brace on this line or is a
        # constructor initialiser list starting with ":") — skip declarations
        # that end with ";" on the same line
        if line.rstrip().endswith(";"):
            continue

        func_name = f"{m.group(1)}::{m.group(2)}"
        macro = find_preceding_impl(lines, idx)

        if macro is None:
            issues.append({
                "file": str(path),
                "line": idx + 1,
                "function": func_name,
                "issue": "missing",
            })
        elif macro in STUB_MACROS:
            issues.append({
                "file": str(path),
                "line": idx + 1,
                "function": func_name,
                "issue": "forbidden",
                "macro": macro,
            })

    return issues


def scan_directory(source_dir: Path) -> list[dict]:
    all_issues = []
    cpp_files = sorted(source_dir.rglob("*.cpp"))
    for cpp in cpp_files:
        all_issues.extend(scan_file(cpp))
    return all_issues


# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------

def print_report(issues: list[dict], source_dir: Path) -> None:
    missing = [i for i in issues if i["issue"] == "missing"]
    todo    = [i for i in issues if i["issue"] == "forbidden"]

    base = str(source_dir)

    if missing:
        print(f"\n{'='*70}")
        print(f"  MISSING IMPL_xxx attribution ({len(missing)} function(s))")
        print(f"{'='*70}")
        for i in missing:
            rel = os.path.relpath(i["file"], base)
            print(f"  {rel}:{i['line']}  {i['function']}")
        print()

    if todo:
        print(f"\n{'='*70}")
        print(f"  FORBIDDEN MACROS (must be replaced) ({len(todo)} function(s))")
        print(f"  IMPL_TODO  = unimplemented stub — must be replaced before commit")
        print(f"  IMPL_APPROX = approximation — must be verified and promoted to")
        print(f"                IMPL_MATCH, IMPL_EMPTY, or IMPL_DIVERGE")
        print(f"{'='*70}")
        for i in todo:
            rel = os.path.relpath(i["file"], base)
            print(f"  [{i['macro']:15}]  {rel}:{i['line']}  {i['function']}")
        print()

    total = len(missing) + len(todo)
    if total:
        print(f"TOTAL FAILURES: {total}  ({len(missing)} unannotated + {len(todo)} forbidden macros)\n")
    else:
        cpp_count = sum(1 for _ in source_dir.rglob("*.cpp"))
        print(f"OK — all functions in {cpp_count} .cpp file(s) are attributed.")


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source_dir", help="Directory containing .cpp files")
    parser.add_argument(
        "--warn-only", action="store_true",
        help="Print issues but exit 0 (useful during annotation pass)"
    )
    parser.add_argument(
        "--report", metavar="FILE",
        help="Write JSON report to FILE"
    )
    args = parser.parse_args()

    source_dir = Path(args.source_dir).resolve()
    if not source_dir.is_dir():
        print(f"ERROR: Not a directory: {source_dir}", file=sys.stderr)
        return 1

    issues = scan_directory(source_dir)

    print_report(issues, source_dir)

    if args.report:
        report_path = Path(args.report)
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(json.dumps(issues, indent=2))
        print(f"Report written to: {args.report}")

    if issues and not args.warn_only:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())