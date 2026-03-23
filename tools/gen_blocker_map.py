# -*- coding: utf-8 -*-
# =============================================================================
# gen_blocker_map.py - Map FUN_ references to find implementation blockers
# =============================================================================
# Scans Ghidra decompilation exports (_global.cpp, _unnamed.cpp) for
# FUN_XXXXXXXX references and builds a map showing which named functions
# depend on unresolved helpers.
#
# Usage:
#   python tools/gen_blocker_map.py
#
# Output: ghidra/exports/reports/blocker_map.json
#   - Per FUN_: address, reference count, list of functions that call it
#   - Sorted by impact (most-blocking FUN_ first)
# =============================================================================

import os
import re
import json
import sys

def find_project_root():
    """Walk up from script location to find project root."""
    d = os.path.dirname(os.path.abspath(__file__))
    while d != os.path.dirname(d):
        if os.path.isfile(os.path.join(d, "AGENTS.md")):
            return d
        d = os.path.dirname(d)
    return os.path.dirname(os.path.abspath(__file__))

def parse_cpp_exports(cpp_path):
    """Parse a Ghidra _global.cpp file and extract function blocks with their FUN_ references."""
    results = []

    with open(cpp_path, "r", encoding="utf-8", errors="replace") as f:
        content = f.read()

    # Find all function blocks: // Address: XXXX ... next // Address:
    func_pattern = re.compile(
        r'// Address: ([0-9a-fA-F]+)\s*\n'
        r'// Size: (\d+) bytes\s*\n'
        r'(.*?)(?=\n// Address:|\Z)',
        re.DOTALL
    )

    for m in func_pattern.finditer(content):
        addr = m.group(1)
        size = int(m.group(2))
        body = m.group(3)

        # Extract function name from signature comment
        sig_match = re.search(r'/\*\s*(.+?)\s*\*/', body)
        func_name = sig_match.group(1).strip() if sig_match else "unknown_" + addr

        # Find all FUN_ references in this function's body
        fun_refs = set(re.findall(r'\b(FUN_[0-9a-fA-F]+)\b', body))

        if fun_refs:
            results.append({
                "addr": addr,
                "name": func_name,
                "size": size,
                "fun_refs": sorted(fun_refs)
            })

    return results

def main():
    root = find_project_root()
    exports_dir = os.path.join(root, "ghidra", "exports")
    reports_dir = os.path.join(exports_dir, "reports")

    if not os.path.isdir(exports_dir):
        print("ERROR: ghidra/exports/ not found at: " + exports_dir)
        sys.exit(1)

    os.makedirs(reports_dir, exist_ok=True)

    print("=" * 60)
    print("Generating FUN_ blocker map")
    print("=" * 60)

    # Map: FUN_addr -> list of functions that reference it
    blocker_map = {}  # FUN_addr -> {"count": N, "callers": [...]}

    # Per-module stats
    module_stats = {}

    # Scan all module export directories
    for module_name in sorted(os.listdir(exports_dir)):
        module_dir = os.path.join(exports_dir, module_name)
        if not os.path.isdir(module_dir) or module_name == "reports":
            continue

        cpp_files = [f for f in os.listdir(module_dir) if f.endswith(".cpp")]
        if not cpp_files:
            continue

        module_fun_count = 0
        module_func_with_fun = 0

        for cpp_file in cpp_files:
            cpp_path = os.path.join(module_dir, cpp_file)
            funcs = parse_cpp_exports(cpp_path)

            for func in funcs:
                if func["fun_refs"]:
                    module_func_with_fun += 1

                for fun_ref in func["fun_refs"]:
                    module_fun_count += 1

                    if fun_ref not in blocker_map:
                        blocker_map[fun_ref] = {
                            "address": fun_ref.replace("FUN_", ""),
                            "ref_count": 0,
                            "callers": []
                        }

                    blocker_map[fun_ref]["ref_count"] += 1
                    blocker_map[fun_ref]["callers"].append({
                        "module": module_name,
                        "function": func["name"],
                        "addr": func["addr"]
                    })

        module_stats[module_name] = {
            "functions_with_FUN_refs": module_func_with_fun,
            "total_FUN_references": module_fun_count
        }

        print("  %s: %d functions reference FUN_ helpers" % (module_name, module_func_with_fun))

    # Sort blockers by impact (most references first)
    sorted_blockers = sorted(blocker_map.items(), key=lambda x: -x[1]["ref_count"])

    # Build output
    blockers_list = []
    for fun_name, info in sorted_blockers:
        blockers_list.append({
            "fun_name": fun_name,
            "address": info["address"],
            "blocked_count": info["ref_count"],
            "callers": info["callers"]
        })

    output = {
        "total_unique_FUN_helpers": len(blocker_map),
        "total_references": sum(b["ref_count"] for b in blocker_map.values()),
        "top_blockers": [
            {"name": b["fun_name"], "blocks": b["blocked_count"]}
            for b in blockers_list[:50]
        ],
        "module_stats": module_stats,
        "blockers": blockers_list
    }

    out_path = os.path.join(reports_dir, "blocker_map.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(output, f, indent=2)

    print("")
    print("Unique FUN_ helpers: %d" % len(blocker_map))
    print("Total references: %d" % output["total_references"])
    print("")
    print("Top 10 blockers:")
    for b in blockers_list[:10]:
        print("  %s: blocks %d functions" % (b["fun_name"], b["blocked_count"]))

    print("")
    print("Output: " + out_path)

if __name__ == "__main__":
    main()
