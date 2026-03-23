# -*- coding: utf-8 -*-
# =============================================================================
# export_structs.py - Export struct/class layouts from Ghidra type system
# =============================================================================
# Walks Ghidra's DataTypeManager for all struct and class definitions,
# recording member offsets, sizes, and types.
#
# Output: ghidra/exports/reports/{binary}_structs.json
#   - Per-struct: name, size, alignment, member list with offsets
#
# This data enables sizeof() validation during decompilation.
# =============================================================================

# @category RavenShield
# @menupath Tools.RavenShield.Export Struct Layouts

import os
import json
from ghidra.program.model.data import Structure, Union, Composite

def get_project_root():
    script_dir = getSourceFile().getParentFile().getParentFile().getParentFile()
    return script_dir.getAbsolutePath()

def extract_structs(program):
    """Extract all struct/class definitions from the program's type system."""
    dtm = program.getDataTypeManager()
    structs = []

    # Walk all data types
    all_types = dtm.getAllDataTypes()
    while all_types.hasNext():
        dt = all_types.next()

        if not isinstance(dt, Structure):
            continue

        name = dt.getName()
        path = dt.getCategoryPath().getPath()

        members = []
        for i in range(dt.getNumComponents()):
            comp = dt.getComponent(i)
            if comp is None:
                continue
            members.append({
                "offset": comp.getOffset(),
                "size": comp.getLength(),
                "type": str(comp.getDataType().getName()),
                "name": comp.getFieldName() if comp.getFieldName() else ("field_0x%x" % comp.getOffset()),
            })

        entry = {
            "name": name,
            "category": path,
            "size": dt.getLength(),
            "alignment": dt.getAlignment(),
            "member_count": len(members),
            "members": members
        }

        # Only include structs with meaningful data
        if dt.getLength() > 0:
            structs.append(entry)

    return structs

def export_structs():
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
    println("Exporting struct layouts: " + program.getName())
    println("=" * 60)

    structs = extract_structs(program)

    # Sort by name
    structs.sort(key=lambda s: s["name"])

    output = {
        "binary": program.getName(),
        "struct_count": len(structs),
        "structs": structs
    }

    out_path = os.path.join(reports_dir, prog_name + "_structs.json")
    with open(out_path, "w") as f:
        json.dump(output, f, indent=2)

    println("Found " + str(len(structs)) + " struct/class definitions")
    println("Output: " + out_path)

export_structs()
