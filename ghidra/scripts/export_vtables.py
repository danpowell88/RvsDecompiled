# -*- coding: utf-8 -*-
# =============================================================================
# export_vtables.py - Export vtable layouts from Ghidra analysis
# =============================================================================
# Walks the symbol table for vftable symbols (MSVC ??_7 mangling pattern)
# and extracts the slot layout for each virtual class.
#
# Output: ghidra/exports/reports/{binary}_vtables.json
#   - Per-class vtable: base address, slot count, method at each slot
#
# This data enables quick validation of virtual dispatch during decompilation.
# =============================================================================

# @category RavenShield
# @menupath Tools.RavenShield.Export Vtables

import os
import json
from ghidra.program.model.symbol import SymbolTable, SymbolType

def get_project_root():
    script_dir = getSourceFile().getParentFile().getParentFile().getParentFile()
    return script_dir.getAbsolutePath()

def resolve_function_at(program, addr):
    """Try to resolve a function name at a given address."""
    fm = program.getFunctionManager()
    func = fm.getFunctionAt(addr)
    if func is not None:
        return func.getName(True)  # include namespace

    # Try symbol table
    st = program.getSymbolTable()
    syms = st.getSymbols(addr)
    for sym in syms:
        return sym.getName(True)
    return None

def extract_vtables(program):
    """Extract all vtable layouts from the program."""
    st = program.getSymbolTable()
    fm = program.getFunctionManager()
    listing = program.getListing()
    mem = program.getMemory()
    addr_factory = program.getAddressFactory()
    ptr_size = program.getDefaultPointerSize()  # 4 for x86

    vtables = []

    # Find all symbols that look like vtables
    # MSVC pattern: ??_7ClassName@@6B@ (vftable)
    sym_iter = st.getAllSymbols(True)
    while sym_iter.hasNext():
        sym = sym_iter.next()
        name = sym.getName()

        # Match vftable symbols
        is_vftable = False
        class_name = ""

        if name.startswith("??_7") and "@@6B" in name:
            # MSVC mangled vftable: ??_7ClassName@@6B@
            # Extract class name between ??_7 and @@
            raw = name[4:]
            at_pos = raw.find("@@")
            if at_pos > 0:
                class_name = raw[:at_pos]
                is_vftable = True
        elif "vftable" in name.lower() or "vtable" in name.lower():
            class_name = name.replace("_vftable_", "").replace("vftable", "").strip("_")
            if class_name:
                is_vftable = True

        if not is_vftable or not class_name:
            continue

        vtable_addr = sym.getAddress()
        slots = []
        offset = 0
        max_slots = 500  # safety limit

        while offset < max_slots * ptr_size:
            slot_addr = vtable_addr.add(offset)

            # Read pointer value at this slot
            try:
                if ptr_size == 4:
                    ptr_val = mem.getInt(slot_addr) & 0xFFFFFFFF
                else:
                    ptr_val = mem.getLong(slot_addr) & 0xFFFFFFFFFFFFFFFF
            except:
                break

            # Convert to address
            try:
                target = addr_factory.getDefaultAddressSpace().getAddress(ptr_val)
            except:
                break

            # Check if this points to executable code
            block = mem.getBlock(target)
            if block is None or not block.isExecute():
                break

            method_name = resolve_function_at(program, target)
            if method_name is None:
                method_name = "FUN_" + str(target)

            slots.append({
                "index": offset // ptr_size,
                "offset": offset,
                "target_addr": str(target),
                "method": method_name
            })

            offset += ptr_size

        if len(slots) > 0:
            vtables.append({
                "class": class_name,
                "vtable_addr": str(vtable_addr),
                "slot_count": len(slots),
                "slots": slots
            })

    return vtables

def export_vtables():
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
    println("Exporting vtables: " + program.getName())
    println("=" * 60)

    vtables = extract_vtables(program)

    # Sort by class name
    vtables.sort(key=lambda v: v["class"])

    output = {
        "binary": program.getName(),
        "vtable_count": len(vtables),
        "total_slots": sum(v["slot_count"] for v in vtables),
        "vtables": vtables
    }

    out_path = os.path.join(reports_dir, prog_name + "_vtables.json")
    with open(out_path, "w") as f:
        json.dump(output, f, indent=2)

    println("Found " + str(len(vtables)) + " vtables with " +
            str(output["total_slots"]) + " total slots")
    println("Output: " + out_path)

export_vtables()
