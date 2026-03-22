# -*- coding: utf-8 -*-
# =============================================================================
# reexport_r6hud.py  - Re-export just AR6HUD::execDrawNativeHUD
# =============================================================================
# Targeted re-export for the one function that failed with an ASCII codec error
# in the full export_cpp.py run.  Writes the decompiled C directly into the
# existing ghidra/exports/R6Game/_global.cpp, replacing the FAILED placeholder.
#
# Run headlessly:
#   analyzeHeadless.bat <proj_dir> RavenShield -process "R6Game.dll"
#     -postScript reexport_r6hud.py -noanalysis
#     -scriptPath <repo>/ghidra/scripts
# =============================================================================

# @category RavenShield
# @menupath Tools.RavenShield.Re-export R6HUD

import os
import io
import codecs
from ghidra.app.decompiler import DecompInterface, DecompileOptions

TARGET_FUNC = "AR6HUD::execDrawNativeHUD"

def get_project_root():
    script_dir = getSourceFile().getParentFile().getParentFile().getParentFile()
    return script_dir.getAbsolutePath()

def run():
    program = getCurrentProgram()
    if program is None:
        printerr("No program loaded.")
        return

    prog_name = program.getName().replace(".dll", "").replace(".exe", "")
    println("Program: " + program.getName())

    # Find the target function
    fm = program.getFunctionManager()
    target = None
    func_iter = fm.getFunctions(True)
    while func_iter.hasNext():
        f = func_iter.next()
        if f.getName(True) == TARGET_FUNC or f.getName() == "execDrawNativeHUD":
            target = f
            break

    if target is None:
        printerr("Function not found: " + TARGET_FUNC)
        return

    println("Found: " + target.getName(True) + " @ " + str(target.getEntryPoint()))
    println("Size:  " + str(target.getBody().getNumAddresses()) + " bytes")

    # Decompile with UTF-8 aware output
    decomp = DecompInterface()
    opts = DecompileOptions()
    decomp.setOptions(opts)
    decomp.openProgram(program)

    result = decomp.decompileFunction(target, 120, monitor)
    if not (result and result.decompileCompleted()):
        printerr("Decompilation did not complete: " + str(result.getErrorMessage() if result else "null"))
        decomp.dispose()
        return

    decomp_func = result.getDecompiledFunction()
    if not decomp_func:
        printerr("No decompiled function returned.")
        decomp.dispose()
        return

    c_code = decomp_func.getC()
    println("Got decompiled C, length: " + str(len(c_code)))

    # Write the result to a separate file so it can be inspected / merged
    root = get_project_root()
    out_dir  = os.path.join(root, "ghidra", "exports", prog_name)
    out_path = os.path.join(out_dir, "_r6hud_execDrawNativeHUD.cpp")

    if not os.path.isdir(out_dir):
        os.makedirs(out_dir)

    with codecs.open(out_path, "w", encoding="utf-8") as f:
        f.write(u"// ============================================================\n")
        f.write(u"// Re-export: " + TARGET_FUNC + u"\n")
        f.write(u"// Address: " + str(target.getEntryPoint()) + u"\n")
        f.write(u"// Size: " + str(target.getBody().getNumAddresses()) + u" bytes\n")
        f.write(u"// ============================================================\n\n")
        # Ensure c_code is unicode
        if hasattr(c_code, "toString"):
            c_code = c_code.toString()  # Jython Java String -> Python unicode
        f.write(c_code)

    println("Written to: " + out_path)
    decomp.dispose()

run()
