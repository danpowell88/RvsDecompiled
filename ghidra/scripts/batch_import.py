# -*- coding: utf-8 -*-
# =============================================================================
# batch_import.py - Ghidra headless script for mass binary analysis
# =============================================================================
# Imports all in-scope Ravenshield binaries into the Ghidra project,
# runs auto-analysis with aggressive settings, applies SDK type libraries,
# and generates a per-binary analysis report.
#
# Usage (headless):
#   tools/run_headless.bat -preScript ghidra/scripts/batch_import.py
#
# Or import each binary individually:
#   tools/run_headless.bat -import retail/system/Core.dll -postScript ghidra/scripts/batch_import.py
# =============================================================================

# @category RavenShield
# @menupath Tools.RavenShield.Batch Import & Analyze

import os
import json
import time
from ghidra.program.model.listing import FunctionManager
from ghidra.program.model.symbol import SymbolTable, SourceType
from ghidra.app.decompiler import DecompInterface
from java.io import File

# --- Binaries to analyze (in dependency order) ---
TARGET_BINARIES = [
    # Core engine
    "Core.dll",
    "Engine.dll",
    "Window.dll",
    # Drivers
    "D3DDrv.dll",
    "WinDrv.dll",
    "IpDrv.dll",
    # Effects
    "Fire.dll",
    # R6 game modules
    "R6Abstract.dll",
    "R6Engine.dll",
    "R6Game.dll",
    "R6Weapons.dll",
    "R6GameService.dll",
    # Audio
    "DareAudio.dll",
    "DareAudioRelease.dll",
    "DareAudioScript.dll",
    # Main executable
    "RavenShield.exe",
]

def get_project_root():
    """Walk up from script location to find project root."""
    script_dir = getSourceFile().getParentFile().getParentFile().getParentFile()
    return script_dir.getAbsolutePath()

def analyze_current_program():
    """Generate analysis report for the currently loaded program."""
    program = getCurrentProgram()
    if program is None:
        printerr("No program loaded.")
        return None
    
    name = program.getName()
    println("\n" + "=" * 60)
    println("Analyzing: " + name)
    println("=" * 60)
    
    fm = program.getFunctionManager()
    st = program.getSymbolTable()
    mem = program.getMemory()
    
    # Collect function info
    functions = []
    func_iter = fm.getFunctions(True)
    while func_iter.hasNext():
        func = func_iter.next()
        functions.append({
            "name": func.getName(),
            "address": str(func.getEntryPoint()),
            "size": func.getBody().getNumAddresses(),
            "is_thunk": func.isThunk(),
            "calling_convention": str(func.getCallingConventionName()),
            "param_count": func.getParameterCount(),
        })
    
    # Collect export symbols
    exports = []
    sym_iter = st.getExternalEntryPointIterator()
    while sym_iter.hasNext():
        addr = sym_iter.next()
        syms = st.getSymbols(addr)
        for sym in syms:
            exports.append({
                "name": sym.getName(),
                "address": str(addr),
                "source": str(sym.getSource()),
            })
    
    # Collect import symbols
    imports = []
    ext_syms = st.getExternalSymbols()
    while ext_syms.hasNext():
        sym = ext_syms.next()
        imports.append({
            "name": sym.getName(),
            "library": str(sym.getParentNamespace()),
        })
    
    # Collect strings
    defined_strings = []
    for data in program.getListing().getDefinedData(True):
        if data.hasStringValue():
            val = data.getValue()
            if val and len(str(val)) > 3:
                defined_strings.append({
                    "address": str(data.getAddress()),
                    "value": str(val)[:200],  # Truncate long strings
                })
    
    # Memory sections
    sections = []
    for block in mem.getBlocks():
        sections.append({
            "name": block.getName(),
            "start": str(block.getStart()),
            "size": block.getSize(),
            "permissions": ("R" if block.isRead() else "") +
                          ("W" if block.isWrite() else "") +
                          ("X" if block.isExecute() else ""),
        })
    
    report = {
        "binary": name,
        "image_base": str(program.getImageBase()),
        "language": str(program.getLanguageID()),
        "compiler": str(program.getCompilerSpec().getCompilerSpecID()),
        "function_count": len(functions),
        "export_count": len(exports),
        "import_count": len(imports),
        "string_count": len(defined_strings),
        "sections": sections,
        "functions": functions,
        "exports": exports,
        "imports": imports,
        "strings": defined_strings[:500],  # Cap at 500 for report size
    }
    
    # Print summary
    println("  Functions:  " + str(report["function_count"]))
    println("  Exports:    " + str(report["export_count"]))
    println("  Imports:    " + str(report["import_count"]))
    println("  Strings:    " + str(report["string_count"]))
    println("  Sections:   " + str(len(sections)))
    
    return report

def save_report(report, output_dir):
    """Save analysis report as JSON."""
    if report is None:
        return
    
    if not os.path.isdir(output_dir):
        os.makedirs(output_dir)
    filename = report["binary"].replace(".", "_") + "_report.json"
    filepath = os.path.join(output_dir, filename)
    
    with open(filepath, "w") as f:
        json.dump(report, f, indent=2)
    
    println("  Report saved: " + filepath)

def apply_type_libraries(program):
    """Apply SDK type libraries to improve decompilation quality."""
    root = get_project_root()
    apply_types_script = os.path.join(root, "ghidra", "scripts", "apply_types.py")
    if os.path.isfile(apply_types_script):
        println("  Applying SDK type libraries...")
        try:
            # Import and run apply_types inline
            import importlib
            import sys
            sys.path.insert(0, os.path.dirname(apply_types_script))
            # The apply_types module uses getCurrentProgram() which is already set
            exec(open(apply_types_script).read())
            println("  Type libraries applied successfully.")
        except Exception as e:
            printerr("  Type library application failed (non-fatal): " + str(e))
    else:
        println("  Skipping type libraries -- apply_types.py not found.")

def validate_binaries():
    """Check which target binaries actually exist in retail/system/."""
    root = get_project_root()
    system_dir = os.path.join(root, "retail", "system")
    found = []
    missing = []
    for binary in TARGET_BINARIES:
        path = os.path.join(system_dir, binary)
        if os.path.isfile(path):
            found.append(binary)
        else:
            missing.append(binary)
    return found, missing

def run():
    root = get_project_root()
    output_dir = os.path.join(root, "ghidra", "exports", "reports")

    # Report which binaries are available
    found, missing = validate_binaries()
    println("Target binaries found:   " + str(len(found)) + "/" + str(len(TARGET_BINARIES)))
    if missing:
        println("Missing binaries: " + ", ".join(missing))

    # Apply type libraries for improved decompilation
    program = getCurrentProgram()
    if program:
        apply_type_libraries(program)

    # Analyze the currently loaded program and generate report
    report = analyze_current_program()
    save_report(report, output_dir)

    println("\nAnalysis complete.")

run()
