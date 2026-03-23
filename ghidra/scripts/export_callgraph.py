# -*- coding: utf-8 -*-
# =============================================================================
# export_callgraph.py - Export intra-DLL call graph from Ghidra analysis
# =============================================================================
# For each function, walks outgoing call references to build a caller->callee
# edge list. Also identifies leaf functions (no outgoing calls) and root
# functions (no incoming calls from within the DLL).
#
# Output: ghidra/exports/reports/{binary}_callgraph.json
#   - edges: [{caller, callee, call_type}]
#   - leaf_functions: functions with no outgoing calls
#   - root_functions: functions with no incoming internal calls
#   - statistics: total edges, avg fan-out, etc.
#
# This data enables dependency tracing and dead-code detection.
# =============================================================================

# @category RavenShield
# @menupath Tools.RavenShield.Export Call Graph

import os
import json
from ghidra.program.model.symbol import RefType

def get_project_root():
    script_dir = getSourceFile().getParentFile().getParentFile().getParentFile()
    return script_dir.getAbsolutePath()

def export_callgraph():
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
    println("Exporting call graph: " + program.getName())
    println("=" * 60)

    fm = program.getFunctionManager()
    ref_mgr = program.getReferenceManager()

    # Build caller -> callee edges
    edges = []
    callers_set = set()   # functions that call something
    callees_set = set()   # functions that are called
    all_funcs = set()

    func_iter = fm.getFunctions(True)
    count = 0
    while func_iter.hasNext():
        func = func_iter.next()
        caller_addr = str(func.getEntryPoint())
        caller_name = func.getName(True)
        all_funcs.add(caller_addr)
        count += 1

        # Walk all call references FROM this function
        call_refs = []
        for inst_addr in func.getBody().getAddresses(True):
            refs = ref_mgr.getReferencesFrom(inst_addr)
            for ref in refs:
                if not ref.getReferenceType().isCall():
                    continue

                target = ref.getToAddress()
                target_func = fm.getFunctionContaining(target)
                if target_func is None:
                    continue

                callee_addr = str(target_func.getEntryPoint())
                callee_name = target_func.getName(True)

                # Classify call type
                rt = ref.getReferenceType()
                if rt == RefType.COMPUTED_CALL:
                    call_type = "indirect"
                else:
                    call_type = "direct"

                call_refs.append((callee_addr, callee_name, call_type))

        # Deduplicate edges per caller-callee pair
        seen = set()
        for callee_addr, callee_name, call_type in call_refs:
            key = caller_addr + "->" + callee_addr
            if key in seen:
                continue
            seen.add(key)

            edges.append({
                "caller": caller_name,
                "caller_addr": caller_addr,
                "callee": callee_name,
                "callee_addr": callee_addr,
                "type": call_type
            })
            callers_set.add(caller_addr)
            callees_set.add(callee_addr)

        if count % 1000 == 0:
            println("  Processed " + str(count) + " functions, " +
                    str(len(edges)) + " edges so far...")

    # Identify leaf and root functions
    leaf_funcs = []
    root_funcs = []

    func_iter = fm.getFunctions(True)
    while func_iter.hasNext():
        func = func_iter.next()
        addr = str(func.getEntryPoint())
        name = func.getName(True)

        if addr not in callers_set:
            leaf_funcs.append({"name": name, "addr": addr})
        if addr not in callees_set:
            root_funcs.append({"name": name, "addr": addr})

    # Compute stats
    fan_outs = {}
    for e in edges:
        ca = e["caller_addr"]
        fan_outs[ca] = fan_outs.get(ca, 0) + 1

    avg_fanout = 0.0
    max_fanout = 0
    max_fanout_func = ""
    if fan_outs:
        avg_fanout = sum(fan_outs.values()) / float(len(fan_outs))
        max_fanout_addr = max(fan_outs, key=fan_outs.get)
        max_fanout = fan_outs[max_fanout_addr]
        # Resolve name
        for e in edges:
            if e["caller_addr"] == max_fanout_addr:
                max_fanout_func = e["caller"]
                break

    output = {
        "binary": program.getName(),
        "total_functions": count,
        "total_edges": len(edges),
        "leaf_function_count": len(leaf_funcs),
        "root_function_count": len(root_funcs),
        "avg_fan_out": round(avg_fanout, 2),
        "max_fan_out": max_fanout,
        "max_fan_out_function": max_fanout_func,
        "leaf_functions": leaf_funcs,
        "root_functions": root_funcs,
        "edges": edges
    }

    out_path = os.path.join(reports_dir, prog_name + "_callgraph.json")
    with open(out_path, "w") as f:
        json.dump(output, f, indent=2)

    println("")
    println("Functions: " + str(count))
    println("Call edges: " + str(len(edges)))
    println("Leaf functions (no calls out): " + str(len(leaf_funcs)))
    println("Root functions (no calls in): " + str(len(root_funcs)))
    println("Avg fan-out: " + str(round(avg_fanout, 2)))
    println("Max fan-out: " + max_fanout_func + " (" + str(max_fanout) + " calls)")
    println("Output: " + out_path)

export_callgraph()
