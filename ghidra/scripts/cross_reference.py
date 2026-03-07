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

def aggregate_cross_references(reports_dir):
    """Merge all per-binary _xrefs.json reports into a full dependency graph."""
    println("\n=== Aggregating Cross-Reference Matrix ===")
    
    # Load all per-binary xref reports
    binaries = {}
    for fname in os.listdir(reports_dir):
        if fname.endswith("_xrefs.json"):
            filepath = os.path.join(reports_dir, fname)
            with open(filepath, "r") as f:
                data = json.load(f)
            binaries[data["binary"]] = data
    
    if not binaries:
        printerr("No xref reports found in: " + reports_dir)
        return
    
    println("  Loaded " + str(len(binaries)) + " binary reports")
    
    # Build set of in-scope binary names (lowercase for matching)
    in_scope = set()
    for name in binaries:
        in_scope.add(name.lower())
    
    # Build adjacency matrix: matrix[importer][exporter] = [function_list]
    all_names = sorted(binaries.keys())
    adjacency = {}
    for name in all_names:
        adjacency[name] = {}
    
    # Function-level cross-reference list
    function_xrefs = []
    
    for importer_name, data in binaries.items():
        for dll_name, import_info in data.get("imports_by_dll", {}).items():
            # Normalize DLL name for matching
            dll_lower = dll_name.lower()
            if not dll_lower.endswith(".dll"):
                dll_lower += ".dll"
            
            # Find the matching exporter
            exporter = None
            for candidate in all_names:
                if candidate.lower() == dll_lower:
                    exporter = candidate
                    break
            
            if exporter:
                adjacency[importer_name][exporter] = import_info["functions"]
                
                for func_name in import_info["functions"]:
                    function_xrefs.append({
                        "caller_dll": importer_name,
                        "callee_dll": exporter,
                        "function": func_name,
                    })
    
    # Build summary adjacency (counts only)
    adjacency_counts = {}
    for importer in all_names:
        adjacency_counts[importer] = {}
        for exporter in all_names:
            funcs = adjacency[importer].get(exporter, [])
            adjacency_counts[importer][exporter] = len(funcs)
    
    result = {
        "binary_count": len(all_names),
        "binaries": all_names,
        "adjacency_matrix": adjacency_counts,
        "adjacency_detail": {k: {ek: ev for ek, ev in v.items() if ev}
                             for k, v in adjacency.items()},
        "function_xref_count": len(function_xrefs),
        "function_xrefs": function_xrefs,
    }
    
    filepath = os.path.join(reports_dir, "cross_reference.json")
    with open(filepath, "w") as f:
        json.dump(result, f, indent=2)
    
    # Print matrix summary
    println("\n  Dependency Matrix (import counts):")
    header = "  {:20s}".format("")
    for name in all_names:
        short = name.replace(".dll", "").replace(".exe", "")[:8]
        header += " {:>8s}".format(short)
    println(header)
    
    for importer in all_names:
        short = importer.replace(".dll", "").replace(".exe", "")[:8]
        row = "  {:20s}".format(short)
        for exporter in all_names:
            count = adjacency_counts[importer].get(exporter, 0)
            row += " {:>8s}".format(str(count) if count > 0 else ".")
        println(row)
    
    println("\n  Total function-level cross-references: " + str(len(function_xrefs)))
    println("  Aggregated report saved: " + filepath)

def run():
    root = get_project_root()
    output_dir = os.path.join(root, "ghidra", "exports", "reports")
    if not os.path.isdir(output_dir):
        os.makedirs(output_dir)
    
    # Check if aggregate mode was requested via script args
    args = getScriptArgs()
    if args and len(args) > 0 and args[0] == "aggregate":
        aggregate_cross_references(output_dir)
        return
    
    # Standard mode: analyze current program
    result = build_cross_reference()
    if result:
        filename = result["binary"].replace(".", "_") + "_xrefs.json"
        filepath = os.path.join(output_dir, filename)
        with open(filepath, "w") as f:
            json.dump(result, f, indent=2)
        println("Cross-reference saved: " + filepath)

run()
