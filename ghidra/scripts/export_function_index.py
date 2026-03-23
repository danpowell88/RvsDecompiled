# -*- coding: utf-8 -*-
# =============================================================================
# export_function_index.py - Export comprehensive per-function metadata
# =============================================================================
# For every function in the binary, extracts: address, size, calling convention,
# parameter count, return type, demangled name, mangled name, export status.
#
# Output: ghidra/exports/reports/{binary}_function_index.json
#   - Per-function metadata record, sorted by address
#   - Summary statistics
#
# This index enables quick queries: sort by size for quick wins, filter by
# calling convention, find all unexported helpers, etc.
# =============================================================================

# @category RavenShield
# @menupath Tools.RavenShield.Export Function Index

import os
import json

def get_project_root():
    script_dir = getSourceFile().getParentFile().getParentFile().getParentFile()
    return script_dir.getAbsolutePath()

def export_function_index():
    program = getCurrentProgram()
    if program is None:
        printerr("No program loaded.")
        return

    root = get_project_root()
    prog_name = program.getName().replace(".dll", "").replace(".exe", "")
    reports_dir = os.path.join(root, "ghidra", "exports", "reports")
    if not os.path.isdir(reports_dir):
        os.makedirs(reports_dir)

    println("=" * 60)
    println("Exporting function index: " + program.getName())
    println("=" * 60)

    fm = program.getFunctionManager()
    st = program.getSymbolTable()

    # Collect exported addresses
    exported_addrs = set()
    entry_iter = st.getExternalEntryPointIterator()
    while entry_iter.hasNext():
        addr = entry_iter.next()
        exported_addrs.add(str(addr))

    functions = []
    size_buckets = {"tiny": 0, "small": 0, "medium": 0, "large": 0, "huge": 0}
    convention_counts = {}

    func_iter = fm.getFunctions(True)
    while func_iter.hasNext():
        func = func_iter.next()

        addr = str(func.getEntryPoint())
        name = func.getName(True)  # with namespace
        short_name = func.getName()
        body_size = func.getBody().getNumAddresses()

        # Calling convention
        cc = ""
        if func.getCallingConventionName():
            cc = func.getCallingConventionName()
        convention_counts[cc] = convention_counts.get(cc, 0) + 1

        # Parameters
        param_count = func.getParameterCount()

        # Return type
        ret_type = ""
        try:
            ret_type = str(func.getReturnType())
        except:
            ret_type = "unknown"

        # Mangled name (from symbol)
        mangled = ""
        syms = st.getSymbols(func.getEntryPoint())
        for sym in syms:
            sn = sym.getName()
            # MSVC mangled names start with ? or _
            if sn.startswith("?") or (sn.startswith("_") and "@" in sn):
                mangled = sn
                break

        # Classification
        is_thunk = func.isThunk()
        is_unnamed = short_name.startswith("FUN_")
        is_exported = addr in exported_addrs

        # Size bucket
        if body_size <= 10:
            size_buckets["tiny"] += 1
        elif body_size <= 50:
            size_buckets["small"] += 1
        elif body_size <= 200:
            size_buckets["medium"] += 1
        elif body_size <= 1000:
            size_buckets["large"] += 1
        else:
            size_buckets["huge"] += 1

        entry = {
            "addr": addr,
            "size": body_size,
            "name": name,
            "mangled": mangled,
            "convention": cc,
            "params": param_count,
            "return_type": ret_type,
            "exported": is_exported,
            "thunk": is_thunk,
            "unnamed": is_unnamed
        }
        functions.append(entry)

    # Sort by address
    functions.sort(key=lambda f: f["addr"])

    total = len(functions)
    exported_count = sum(1 for f in functions if f["exported"])
    unnamed_count = sum(1 for f in functions if f["unnamed"])
    thunk_count = sum(1 for f in functions if f["thunk"])

    output = {
        "binary": program.getName(),
        "total_functions": total,
        "exported_count": exported_count,
        "unnamed_count": unnamed_count,
        "thunk_count": thunk_count,
        "size_distribution": size_buckets,
        "calling_conventions": convention_counts,
        "functions": functions
    }

    out_path = os.path.join(reports_dir, prog_name + "_function_index.json")
    with open(out_path, "w") as f:
        json.dump(output, f, indent=2)

    println("Total functions: " + str(total))
    println("Exported: " + str(exported_count))
    println("Unnamed (FUN_): " + str(unnamed_count))
    println("Thunks: " + str(thunk_count))
    println("Size distribution: " + str(size_buckets))
    println("Calling conventions: " + str(convention_counts))
    println("Output: " + out_path)

export_function_index()
