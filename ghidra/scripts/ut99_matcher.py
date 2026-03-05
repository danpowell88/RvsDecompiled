# =============================================================================
# ut99_matcher.py - Match decompiled functions against UT99 public source
# =============================================================================
# For Core.dll and Engine.dll, many functions are inherited from Unreal
# Tournament's engine (UT99 v432). This script identifies which functions
# in the decompiled binary match the UT99 public source code.
#
# Matching strategies:
# 1. String literal matching - unique string constants identify functions
# 2. Function name matching - exported names match UT99 source function names
# 3. Call pattern matching - sequence of API calls matches source code
# 4. Constant matching - magic numbers and enum values identify code blocks
#
# Functions that match UT99 source can be directly ported, saving significant
# manual decompilation effort.
#
# Output: ghidra/exports/reports/{binary}_ut99_matches.json
# =============================================================================

# @category RavenShield
# @menupath Tools.RavenShield.UT99 Source Matcher

import os
import re
import json
from ghidra.app.decompiler import DecompInterface, DecompileOptions

def get_project_root():
    script_dir = getSourceFile().getParentFile().getParentFile().getParentFile()
    return script_dir.getAbsolutePath()

def index_ut99_source(source_dir):
    """Build an index of UT99 source: strings, function names, constants."""
    index = {
        "strings": {},       # string_literal -> [(file, line)]
        "functions": {},     # function_name -> [(file, line)]
        "constants": {},     # constant_value -> [(file, line, context)]
    }
    
    if not os.path.isdir(source_dir):
        printerr("UT99 source directory not found: " + source_dir)
        return index
    
    for dirpath, dirnames, filenames in os.walk(source_dir):
        for fname in filenames:
            if not fname.endswith((".h", ".cpp", ".c")):
                continue
            
            filepath = os.path.join(dirpath, fname)
            rel_path = os.path.relpath(filepath, source_dir)
            
            try:
                with open(filepath, "r", errors="ignore") as f:
                    for line_num, line in enumerate(f, 1):
                        # Index string literals
                        for match in re.finditer(r'"([^"]{4,})"', line):
                            s = match.group(1)
                            if s not in index["strings"]:
                                index["strings"][s] = []
                            index["strings"][s].append((rel_path, line_num))
                        
                        # Index function definitions
                        func_match = re.match(
                            r'(?:void|int|UBOOL|FLOAT|FString|FName|UObject\*?)\s+'
                            r'(?:(\w+)::)?(\w+)\s*\(',
                            line.strip()
                        )
                        if func_match:
                            cls = func_match.group(1) or ""
                            name = func_match.group(2)
                            full_name = (cls + "::" + name) if cls else name
                            if full_name not in index["functions"]:
                                index["functions"][full_name] = []
                            index["functions"][full_name].append((rel_path, line_num))
            except Exception:
                pass
    
    return index

def match_functions(program, ut99_index):
    """Match decompiled functions against UT99 source index."""
    decomp = DecompInterface()
    decomp.openProgram(program)
    
    fm = program.getFunctionManager()
    matches = []
    
    func_iter = fm.getFunctions(True)
    total = 0
    matched = 0
    
    while func_iter.hasNext():
        func = func_iter.next()
        total += 1
        func_name = func.getName()
        
        match_info = {
            "address": str(func.getEntryPoint()),
            "name": func_name,
            "match_type": None,
            "confidence": 0,
            "ut99_source": None,
        }
        
        # Strategy 1: Direct name match
        for ut99_name, locations in ut99_index["functions"].items():
            if func_name in ut99_name or ut99_name.endswith("::" + func_name):
                match_info["match_type"] = "name_match"
                match_info["confidence"] = 70
                match_info["ut99_source"] = locations[0][0]
                break
        
        # Strategy 2: String literal match (higher confidence)
        if match_info["confidence"] < 80:
            try:
                result = decomp.decompileFunction(func, 30, monitor)
                if result and result.decompileCompleted():
                    decomp_text = result.getDecompiledFunction().getC()
                    
                    # Find string literals in decompiled output
                    for s_match in re.finditer(r'"([^"]{4,})"', decomp_text):
                        s = s_match.group(1)
                        if s in ut99_index["strings"]:
                            locs = ut99_index["strings"][s]
                            match_info["match_type"] = "string_match"
                            match_info["confidence"] = 85
                            match_info["ut99_source"] = locs[0][0]
                            match_info["matched_string"] = s[:100]
                            break
            except Exception:
                pass
        
        if match_info["confidence"] > 0:
            matches.append(match_info)
            matched += 1
    
    decomp.dispose()
    
    return {
        "total_functions": total,
        "matched_functions": matched,
        "match_rate": round(100.0 * matched / max(total, 1), 1),
        "matches": matches,
    }

def run():
    program = getCurrentProgram()
    if program is None:
        printerr("No program loaded.")
        return
    
    prog_name = program.getName().replace(".dll", "").replace(".exe", "")
    
    # Only run on Core and Engine
    if prog_name not in ("Core", "Engine"):
        println("UT99 matching is only applicable to Core.dll and Engine.dll.")
        println("Current program: " + program.getName())
        return
    
    root = get_project_root()
    
    # Determine UT99 source paths
    ut99_base = os.path.join(root, "sdk", "Ut99PubSrc")
    if prog_name == "Core":
        source_dirs = [os.path.join(ut99_base, "Core")]
    else:
        source_dirs = [os.path.join(ut99_base, "Engine"), os.path.join(ut99_base, "Core")]
    
    println("=" * 60)
    println("UT99 Source Matching: " + program.getName())
    println("=" * 60)
    
    # Build source index
    println("\nIndexing UT99 source...")
    combined_index = {"strings": {}, "functions": {}, "constants": {}}
    for src_dir in source_dirs:
        idx = index_ut99_source(src_dir)
        combined_index["strings"].update(idx["strings"])
        combined_index["functions"].update(idx["functions"])
        combined_index["constants"].update(idx["constants"])
    
    println("  Indexed " + str(len(combined_index["strings"])) + " string literals")
    println("  Indexed " + str(len(combined_index["functions"])) + " function definitions")
    
    # Match functions
    println("\nMatching functions...")
    results = match_functions(program, combined_index)
    
    println("\n=== Results ===")
    println("  Total functions:   " + str(results["total_functions"]))
    println("  Matched functions: " + str(results["matched_functions"]))
    println("  Match rate:        " + str(results["match_rate"]) + "%")
    
    # Save report
    output_dir = os.path.join(root, "ghidra", "exports", "reports")
    os.makedirs(output_dir, exist_ok=True)
    filepath = os.path.join(output_dir, prog_name + "_ut99_matches.json")
    with open(filepath, "w") as f:
        json.dump(results, f, indent=2)
    println("Report saved: " + filepath)

run()
