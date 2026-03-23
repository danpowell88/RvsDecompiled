# -*- coding: utf-8 -*-
# =============================================================================
# gen_progress_report.py - Generate implementation progress dashboard
# =============================================================================
# Scans all src/**/*.cpp for IMPL_MATCH, IMPL_TODO, IMPL_EMPTY, IMPL_DIVERGE
# annotations and produces a per-DLL and overall progress report.
#
# Usage:
#   python tools/gen_progress_report.py
#
# Output:
#   ghidra/exports/reports/progress_report.json  (machine-readable)
#   ghidra/exports/reports/progress_summary.txt  (human-readable)
# =============================================================================

import os
import re
import json
import sys

# Map source directories to their DLL names
SRC_TO_DLL = {
    "Core": "Core.dll",
    "Engine": "Engine.dll",
    "Window": "Window.dll",
    "D3DDrv": "D3DDrv.dll",
    "WinDrv": "WinDrv.dll",
    "IpDrv": "IpDrv.dll",
    "Fire": "Fire.dll",
    "R6Abstract": "R6Abstract.dll",
    "R6Engine": "R6Engine.dll",
    "R6Game": "R6Game.dll",
    "R6Weapons": "R6Weapons.dll",
    "R6GameService": "R6GameService.dll",
    "DareAudio": "DareAudio.dll",
    "DareAudioRelease": "DareAudioRelease.dll",
    "DareAudioScript": "DareAudioScript.dll",
    "RavenShield": "RavenShield.exe",
}

def find_project_root():
    d = os.path.dirname(os.path.abspath(__file__))
    while d != os.path.dirname(d):
        if os.path.isfile(os.path.join(d, "AGENTS.md")):
            return d
        d = os.path.dirname(d)
    return os.path.dirname(os.path.abspath(__file__))

def scan_source_files(src_dir):
    """Scan all .cpp files for IMPL_ macros and collect per-DLL stats."""
    # Pattern matches IMPL_MATCH("DLL", 0xADDR), IMPL_TODO("reason"), etc.
    impl_match_re = re.compile(r'IMPL_MATCH\s*\(\s*"([^"]+)"\s*,\s*(0x[0-9a-fA-F]+)\s*\)')
    impl_todo_re = re.compile(r'IMPL_TODO\s*\(\s*"([^"]*)"')
    impl_empty_re = re.compile(r'IMPL_EMPTY\s*\(\s*"([^"]*)"')
    impl_diverge_re = re.compile(r'IMPL_DIVERGE\s*\(\s*"([^"]*)"')

    # Per-DLL tracking
    dll_stats = {}
    all_matches = []

    for dirpath, dirnames, filenames in os.walk(src_dir):
        for fname in filenames:
            if not fname.endswith((".cpp", ".h")):
                continue

            fpath = os.path.join(dirpath, fname)
            rel_path = os.path.relpath(fpath, src_dir)

            with open(fpath, "r", encoding="utf-8", errors="replace") as f:
                content = f.read()

            # IMPL_MATCH
            for m in impl_match_re.finditer(content):
                dll = m.group(1)
                addr = m.group(2)
                if dll not in dll_stats:
                    dll_stats[dll] = {"match": 0, "todo": 0, "empty": 0, "diverge": 0,
                                      "match_addrs": [], "files": set()}
                dll_stats[dll]["match"] += 1
                dll_stats[dll]["match_addrs"].append(addr)
                dll_stats[dll]["files"].add(rel_path)

            # IMPL_TODO
            for m in impl_todo_re.finditer(content):
                reason = m.group(1)
                # Try to figure out which DLL from file path
                dll = guess_dll_from_path(rel_path)
                if dll not in dll_stats:
                    dll_stats[dll] = {"match": 0, "todo": 0, "empty": 0, "diverge": 0,
                                      "match_addrs": [], "files": set()}
                dll_stats[dll]["todo"] += 1
                dll_stats[dll]["files"].add(rel_path)

            # IMPL_EMPTY
            for m in impl_empty_re.finditer(content):
                dll = guess_dll_from_path(rel_path)
                if dll not in dll_stats:
                    dll_stats[dll] = {"match": 0, "todo": 0, "empty": 0, "diverge": 0,
                                      "match_addrs": [], "files": set()}
                dll_stats[dll]["empty"] += 1
                dll_stats[dll]["files"].add(rel_path)

            # IMPL_DIVERGE
            for m in impl_diverge_re.finditer(content):
                dll = guess_dll_from_path(rel_path)
                if dll not in dll_stats:
                    dll_stats[dll] = {"match": 0, "todo": 0, "empty": 0, "diverge": 0,
                                      "match_addrs": [], "files": set()}
                dll_stats[dll]["diverge"] += 1
                dll_stats[dll]["files"].add(rel_path)

    return dll_stats

def guess_dll_from_path(rel_path):
    """Guess the DLL name from a source file path."""
    parts = rel_path.replace("\\", "/").split("/")
    if len(parts) >= 1:
        top = parts[0]
        if top in SRC_TO_DLL:
            return SRC_TO_DLL[top]
    return "Unknown"

def load_function_counts(exports_dir):
    """Load total function counts from Ghidra analysis reports."""
    counts = {}
    reports_dir = os.path.join(exports_dir, "reports")
    if not os.path.isdir(reports_dir):
        return counts

    for fname in os.listdir(reports_dir):
        if fname.endswith("_function_index.json"):
            fpath = os.path.join(reports_dir, fname)
            with open(fpath, "r") as f:
                data = json.load(f)
            binary = data.get("binary", fname.replace("_function_index.json", ""))
            counts[binary] = {
                "total": data.get("total_functions", 0),
                "exported": data.get("exported_count", 0),
                "unnamed": data.get("unnamed_count", 0),
            }

    # Fallback: count from _global.cpp Address: lines
    for module_name in os.listdir(exports_dir):
        module_dir = os.path.join(exports_dir, module_name)
        if not os.path.isdir(module_dir) or module_name == "reports":
            continue

        # Check if we already have a count
        dll_name = module_name + ".dll"
        exe_name = module_name + ".exe"
        if dll_name in counts or exe_name in counts:
            continue

        global_cpp = os.path.join(module_dir, "_global.cpp")
        if os.path.isfile(global_cpp):
            with open(global_cpp, "r", encoding="utf-8", errors="replace") as f:
                content = f.read()
            addr_count = len(re.findall(r'// Address:', content))
            binary_name = dll_name if os.path.isfile(os.path.join(os.path.dirname(exports_dir),
                "..", "retail", "system", dll_name)) else exe_name
            counts[binary_name] = {
                "total": addr_count,
                "exported": addr_count,  # approximate
                "unnamed": 0,
            }

    return counts

def main():
    root = find_project_root()
    src_dir = os.path.join(root, "src")
    exports_dir = os.path.join(root, "ghidra", "exports")
    reports_dir = os.path.join(exports_dir, "reports")

    if not os.path.isdir(src_dir):
        print("ERROR: src/ not found at: " + src_dir)
        sys.exit(1)

    os.makedirs(reports_dir, exist_ok=True)

    print("=" * 60)
    print("Generating implementation progress report")
    print("=" * 60)

    # Scan source files
    dll_stats = scan_source_files(src_dir)

    # Load function counts from Ghidra
    func_counts = load_function_counts(exports_dir)

    # Build per-DLL report
    dll_reports = []
    total_match = 0
    total_todo = 0
    total_empty = 0
    total_diverge = 0
    total_functions = 0

    for dll_name in sorted(set(list(dll_stats.keys()) + list(func_counts.keys()))):
        stats = dll_stats.get(dll_name, {"match": 0, "todo": 0, "empty": 0, "diverge": 0,
                                          "match_addrs": [], "files": set()})
        fc = func_counts.get(dll_name, {"total": 0, "exported": 0, "unnamed": 0})

        match = stats["match"]
        todo = stats["todo"]
        empty = stats["empty"]
        diverge = stats["diverge"]
        accounted = match + todo + empty + diverge
        ghidra_total = fc["total"]
        exported = fc["exported"]

        pct = (float(match + empty) / ghidra_total * 100) if ghidra_total > 0 else 0.0

        total_match += match
        total_todo += todo
        total_empty += empty
        total_diverge += diverge
        total_functions += ghidra_total

        dll_reports.append({
            "dll": dll_name,
            "ghidra_total_functions": ghidra_total,
            "ghidra_exported": exported,
            "impl_match": match,
            "impl_empty": empty,
            "impl_todo": todo,
            "impl_diverge": diverge,
            "accounted": accounted,
            "unaccounted": max(0, ghidra_total - accounted),
            "done_pct": round(pct, 1),
            "source_files": sorted(stats.get("files", set()) if isinstance(stats.get("files"), set) else [])
        })

    # Overall
    total_done = total_match + total_empty
    overall_pct = (float(total_done) / total_functions * 100) if total_functions > 0 else 0.0

    output = {
        "summary": {
            "total_functions": total_functions,
            "impl_match": total_match,
            "impl_empty": total_empty,
            "impl_todo": total_todo,
            "impl_diverge": total_diverge,
            "done": total_done,
            "done_pct": round(overall_pct, 1),
        },
        "per_dll": dll_reports
    }

    # Write JSON
    json_path = os.path.join(reports_dir, "progress_report.json")
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(output, f, indent=2)

    # Write human-readable summary
    txt_path = os.path.join(reports_dir, "progress_summary.txt")
    with open(txt_path, "w", encoding="utf-8") as f:
        f.write("=" * 78 + "\n")
        f.write("RAVENSHIELD DECOMPILATION PROGRESS REPORT\n")
        f.write("=" * 78 + "\n\n")

        f.write("%-25s %7s %7s %7s %7s %7s %7s\n" % (
            "DLL", "Total", "MATCH", "EMPTY", "TODO", "DIVERGE", "Done%"))
        f.write("-" * 78 + "\n")

        for r in dll_reports:
            if r["ghidra_total_functions"] == 0 and r["impl_match"] == 0:
                continue
            f.write("%-25s %7d %7d %7d %7d %7d %6.1f%%\n" % (
                r["dll"],
                r["ghidra_total_functions"],
                r["impl_match"],
                r["impl_empty"],
                r["impl_todo"],
                r["impl_diverge"],
                r["done_pct"]
            ))

        f.write("-" * 78 + "\n")
        f.write("%-25s %7d %7d %7d %7d %7d %6.1f%%\n" % (
            "TOTAL",
            total_functions,
            total_match,
            total_empty,
            total_todo,
            total_diverge,
            overall_pct
        ))
        f.write("\n")
        f.write("Done = MATCH + EMPTY (functions with verified byte parity or confirmed empty)\n")

    # Print summary to console
    print("")
    with open(txt_path, "r") as f:
        print(f.read())

    print("JSON: " + json_path)
    print("Text: " + txt_path)

if __name__ == "__main__":
    main()
