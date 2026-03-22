# -*- coding: utf-8 -*-
# =============================================================================
# export_cpp.py - Export Ghidra decompilation as structured C++ source files
# =============================================================================
# Exports the decompiled output for the current binary as organized C++ files:
# - One .h per class (struct/class declarations)
# - One .cpp per class (function implementations)
# - Uses recovered symbol names where available
#
# Output: ghidra/exports/{module_name}/
#
# This is RAW decompiler output -- a starting point, not final code.
# The src/ directory is where cleaned-up, compilable code lives.
# =============================================================================

# @category RavenShield
# @menupath Tools.RavenShield.Export C++ Source

import os
import re
import io
import codecs
from ghidra.app.decompiler import DecompInterface, DecompileOptions
from ghidra.program.model.symbol import SymbolTable

def get_project_root():
    script_dir = getSourceFile().getParentFile().getParentFile().getParentFile()
    return script_dir.getAbsolutePath()

def classify_function(func):
    """Determine which class a function belongs to based on its name."""
    name = func.getName()
    
    # MSVC demangled: ClassName::MethodName
    if "::" in name:
        parts = name.split("::")
        return parts[0]
    
    # Thunk functions
    if name.startswith("thunk_"):
        return "_thunks"
    
    # FUN_ prefix (unnamed functions) - group by address range
    if name.startswith("FUN_") or name.startswith("entry"):
        return "_unnamed"
    
    return "_global"

def export_program():
    """Export all decompiled functions as C++ source files."""
    program = getCurrentProgram()
    if program is None:
        printerr("No program loaded.")
        return
    
    root = get_project_root()
    prog_name = program.getName().replace(".dll", "").replace(".exe", "")
    output_dir = os.path.join(root, "ghidra", "exports", prog_name)
    if not os.path.isdir(output_dir):
        os.makedirs(output_dir)
    
    println("=" * 60)
    println("Exporting C++: " + program.getName())
    println("Output: " + output_dir)
    println("=" * 60)
    
    # Setup decompiler
    decomp = DecompInterface()
    opts = DecompileOptions()
    decomp.setOptions(opts)
    decomp.openProgram(program)
    
    fm = program.getFunctionManager()
    
    # Group functions by class
    classes = {}
    func_iter = fm.getFunctions(True)
    while func_iter.hasNext():
        func = func_iter.next()
        cls_name = classify_function(func)
        if cls_name not in classes:
            classes[cls_name] = []
        classes[cls_name].append(func)
    
    println("Found " + str(len(classes)) + " classes/groups")
    
    # Export each class
    exported = 0
    failed = 0
    
    for cls_name, functions in sorted(classes.items()):
        cpp_path = os.path.join(output_dir, cls_name + ".cpp")
        
        # codecs.open() works in both Jython 2 and CPython 3: it accepts both
        # str and unicode writes, encoding to UTF-8 on the way out.  io.open()
        # in Jython 2 rejects str literals ("can't write str to text stream").
        with codecs.open(cpp_path, "w", encoding="utf-8") as cpp_file:
            cpp_file.write("// " + "=" * 70 + "\n")
            cpp_file.write("// " + cls_name + " -- Raw Ghidra decompilation\n")
            cpp_file.write("// Source: " + program.getName() + "\n")
            cpp_file.write("// WARNING: This is auto-generated output, NOT compilable code.\n")
            cpp_file.write("// " + "=" * 70 + "\n\n")
            
            for func in sorted(functions, key=lambda f: f.getName()):
                try:
                    result = decomp.decompileFunction(func, 60, monitor)
                    if result and result.decompileCompleted():
                        decomp_func = result.getDecompiledFunction()
                        if decomp_func:
                            c_code = decomp_func.getC()
                            cpp_file.write("// Address: " + str(func.getEntryPoint()) + "\n")
                            cpp_file.write("// Size: " + str(func.getBody().getNumAddresses()) + " bytes\n")
                            cpp_file.write(c_code)
                            cpp_file.write("\n\n")
                            exported += 1
                            continue
                except Exception as e:
                    cpp_file.write("// DECOMPILATION FAILED: " + func.getName() + "\n")
                    # repr(e) is always ASCII-safe; str(e) can throw if the exception
                    # message itself contains non-ASCII (e.g. embedded string literals).
                    try:
                        err_text = repr(e)
                    except Exception:
                        err_text = "(error converting exception to string)"
                    cpp_file.write("// Error: " + err_text + "\n\n")
                
                failed += 1
        
        println("  " + cls_name + ": " + str(len(functions)) + " functions")
    
    decomp.dispose()
    
    println("\n=== Export Summary ===")
    println("  Classes/groups: " + str(len(classes)))
    println("  Exported:       " + str(exported))
    println("  Failed:         " + str(failed))
    println("  Output:         " + output_dir)

def run():
    export_program()

run()
