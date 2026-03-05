# =============================================================================
# cross_reference.py - Build inter-DLL dependency graph from import tables
# =============================================================================
# Analyzes import tables across all Ravenshield binaries to build a complete
# dependency graph showing which DLL calls which functions in which other DLL.
#
# Output: ghidra/exports/reports/cross_reference.json
#   - Per-DLL import/export summary
#   - Full dependency adjacency matrix
#   - Function-level cross-reference list
#
# Run after batch_import.py has analyzed all binaries.
# =============================================================================

# @category RavenShield
# @menupath Tools.RavenShield.Cross Reference Analysis

import os
import json
from ghidra.program.model.symbol import SymbolTable

def get_project_root():
    script_dir = getSourceFile().getParentFile().getParentFile().getParentFile()
    return script_dir.getAbsolutePath()

def build_cross_reference():
    """Build cross-reference from the currently loaded program."""
    program = getCurrentProgram()
    if program is None:
        printerr("No program loaded.")
        return None
    
    name = program.getName()
    st = program.getSymbolTable()
    
    println("Building cross-references for: " + name)
    
    # Collect imports grouped by source DLL
    imports_by_dll = {}
    ext_syms = st.getExternalSymbols()
    while ext_syms.hasNext():
        sym = ext_syms.next()
        lib_name = str(sym.getParentNamespace())
        func_name = sym.getName()
        
        if lib_name not in imports_by_dll:
            imports_by_dll[lib_name] = []
        imports_by_dll[lib_name].append(func_name)
    
    # Collect exports
    exports = []
    entry_iter = st.getExternalEntryPointIterator()
    while entry_iter.hasNext():
        addr = entry_iter.next()
        for sym in st.getSymbols(addr):
            exports.append(sym.getName())
    
    result = {
        "binary": name,
        "export_count": len(exports),
        "exports": exports,
        "imports_by_dll": {},
    }
    
    for dll, funcs in imports_by_dll.items():
        result["imports_by_dll"][dll] = {
            "count": len(funcs),
            "functions": sorted(funcs),
        }
        println("  Imports from " + dll + ": " + str(len(funcs)) + " functions")
    
    return result

def run():
    root = get_project_root()
    output_dir = os.path.join(root, "ghidra", "exports", "reports")
    os.makedirs(output_dir, exist_ok=True)
    
    result = build_cross_reference()
    if result:
        filename = result["binary"].replace(".", "_") + "_xrefs.json"
        filepath = os.path.join(output_dir, filename)
        with open(filepath, "w") as f:
            json.dump(result, f, indent=2)
        println("Cross-reference saved: " + filepath)

run()
