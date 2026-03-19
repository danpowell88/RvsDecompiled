# -*- coding: utf-8 -*-
# =============================================================================
# export_asm.py - Export Ghidra disassembly as structured assembly files
# =============================================================================
# Exports the disassembled output for the current binary as organized .asm files:
# - _global.asm   -- named exported functions (ClassName::MethodName etc.)
# - _thunks.asm   -- thunk_ prefixed functions
# - _unnamed.asm  -- FUN_ / entry / unrecognized functions
#
# Output: ghidra/exports/{module_name}/
#
# This is RAW disassembler output -- a reference companion to _global.cpp.
# When the decompiler output is ambiguous, check the .asm for ground truth.
# =============================================================================

# @category RavenShield
# @menupath Tools.RavenShield.Export Assembly

import os
from ghidra.program.model.listing import CodeUnit

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

def disassemble_function(program, func):
    """Disassemble a single function, returning a list of formatted lines."""
    listing = program.getListing()
    lines = []
    for inst in listing.getInstructions(func.getBody(), True):
        addr = inst.getAddress()
        raw_bytes = inst.getBytes()
        hex_str = ''.join('%02x ' % (b & 0xff) for b in raw_bytes).rstrip()

        # Build operand string from all operands
        num_ops = inst.getNumOperands()
        if num_ops > 0:
            ops = ', '.join(
                inst.getDefaultOperandRepresentation(i)
                for i in range(num_ops)
            )
            line = "%-12s %-24s %-8s %s" % (str(addr) + ':', hex_str, inst.getMnemonicString(), ops)
        else:
            line = "%-12s %-24s %s" % (str(addr) + ':', hex_str, inst.getMnemonicString())
        lines.append(line)

        # Include any EOL comment from Ghidra analysis
        comment = inst.getComment(CodeUnit.EOL_COMMENT)
        if comment:
            lines[-1] += "    ; " + comment

    return lines

def export_program():
    """Export all disassembled functions as .asm source files."""
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
    println("Exporting ASM: " + program.getName())
    println("Output: " + output_dir)
    println("=" * 60)

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
        asm_path = os.path.join(output_dir, cls_name + ".asm")

        with open(asm_path, "w") as asm_file:
            asm_file.write("; " + "=" * 70 + "\n")
            asm_file.write("; " + cls_name + " -- Raw Ghidra disassembly\n")
            asm_file.write("; Source: " + program.getName() + "\n")
            asm_file.write("; WARNING: This is auto-generated output, NOT hand-written assembly.\n")
            asm_file.write("; " + "=" * 70 + "\n\n")

            for func in sorted(functions, key=lambda f: f.getName()):
                try:
                    sig = func.getSignature().getPrototypeString()
                except:
                    sig = func.getName()

                try:
                    lines = disassemble_function(program, func)
                    asm_file.write("; Address: " + str(func.getEntryPoint()) + "\n")
                    asm_file.write("; Size: " + str(func.getBody().getNumAddresses()) + " bytes\n")
                    asm_file.write("; " + sig + "\n")
                    asm_file.write("\n")
                    for line in lines:
                        asm_file.write(line + "\n")
                    asm_file.write("\n\n")
                    exported += 1
                except Exception as e:
                    asm_file.write("; DISASSEMBLY FAILED: " + func.getName() + "\n")
                    asm_file.write("; Error: " + str(e) + "\n\n")
                    failed += 1

        println("  " + cls_name + ": " + str(len(functions)) + " functions")

    println("")
    println("Export complete: " + str(exported) + " exported, " + str(failed) + " failed")

export_program()
