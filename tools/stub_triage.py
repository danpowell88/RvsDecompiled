#!/usr/bin/env python3
"""
stub_triage.py — Stub triage tool for Ravenshield decompilation project.
Parses /alternatename pragmas from EngineStubs1-4.cpp, demangles them,
and classifies each into TRIVIAL / MEDIUM / COMPLEX categories.

Output: Markdown report + CSV for further processing.
"""

import re
import subprocess
import sys
import os
from collections import defaultdict

UNDNAME_PATH = r"C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64\undname.exe"

STUBS_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "src", "engine")
STUBS_FILES = [
    os.path.join(STUBS_DIR, f"EngineStubs{i}.cpp") for i in range(1, 5)
]

# Regex to extract mangled symbol from pragma
PRAGMA_RE = re.compile(r'/alternatename:([^=]+)=_dummy_stub_(func|data)')


def extract_pragmas():
    """Extract all mangled symbols from EngineStubs files."""
    symbols = []
    for path in STUBS_FILES:
        if not os.path.exists(path):
            print(f"Warning: {path} not found", file=sys.stderr)
            continue
        with open(path, "r") as f:
            for line_num, line in enumerate(f, 1):
                m = PRAGMA_RE.search(line)
                if m:
                    symbols.append({
                        "file": os.path.basename(path),
                        "line": line_num,
                        "mangled": m.group(1),
                        "kind": m.group(2),  # func or data
                    })
    return symbols


def demangle_batch(symbols):
    """Demangle all symbols using undname.exe (command-line args mode)."""
    mangled_list = [s["mangled"] for s in symbols]
    
    # undname takes symbols as command-line arguments
    # Process in batches to avoid command line length limits
    batch_size = 50
    demangled_map = {}
    
    for i in range(0, len(mangled_list), batch_size):
        batch = mangled_list[i:i+batch_size]
        
        result = subprocess.run(
            [UNDNAME_PATH] + batch,
            capture_output=True,
            text=True,
            timeout=30
        )
        
        # Parse output: 'Undecoration of :- "mangled"\nis :- "demangled"\n'
        output = result.stdout
        for m in re.finditer(r'Undecoration of :- "([^"]+)"\nis :- "([^"]+)"', output):
            demangled_map[m.group(1)] = m.group(2)
    
    # Assign demangled names back
    for s in symbols:
        s["demangled"] = demangled_map.get(s["mangled"], s["mangled"])
    
    return symbols


def extract_class(demangled):
    """Extract class name from demangled symbol."""
    # Pattern: "access: rettype __callconv ClassName::Method(...)"
    m = re.search(r'(\w+)::', demangled)
    return m.group(1) if m else "global"


def classify_symbol(sym):
    """Classify a symbol as TRIVIAL, MEDIUM, or COMPLEX."""
    mangled = sym["mangled"]
    demangled = sym["demangled"]
    kind = sym["kind"]
    
    # Data symbols (vtables, RTTI) are TRIVIAL
    if kind == "data":
        return "TRIVIAL", "data_symbol"
    
    # Constructors ??0
    if mangled.startswith("??0"):
        return "TRIVIAL", "constructor"
    
    # Destructors ??1
    if mangled.startswith("??1"):
        return "TRIVIAL", "destructor"
    
    # Assignment operators ??4
    if mangled.startswith("??4"):
        return "TRIVIAL", "assignment_op"
    
    # Vtable pointers ??_7
    if mangled.startswith("??_7"):
        return "TRIVIAL", "vtable"
    
    # RTTI descriptors ??_R
    if mangled.startswith("??_R"):
        return "TRIVIAL", "rtti"
    
    # Scalar/vector deleting destructors ??_G, ??_E
    if mangled.startswith("??_G") or mangled.startswith("??_E"):
        return "TRIVIAL", "deleting_dtor"
    
    # Simple getters: Get*, Is*, Has* with no complex args
    lower = demangled.lower()
    if re.search(r'::(Get\w+|Is\w+|Has\w+)\(void\)', demangled):
        return "TRIVIAL", "simple_getter"
    
    # Simple setters: Set* with single arg
    if re.search(r'::Set\w+\([^,)]+\)', demangled) and ',' not in demangled.split('(')[1]:
        return "TRIVIAL", "simple_setter"
    
    # operator<< and operator>> (streaming)
    if "operator<<" in demangled or "operator>>" in demangled:
        return "MEDIUM", "streaming_op"
    
    # Serialize methods
    if "::Serialize" in demangled:
        return "MEDIUM", "serialize"
    
    # PostLoad, PreLoad lifecycle
    if "::PostLoad" in demangled or "::PreLoad" in demangled or "::PostEditChange" in demangled:
        return "MEDIUM", "lifecycle"
    
    # Material property accessors
    if any(x in demangled for x in ["MaterialUSize", "MaterialVSize", "GetValidated", "IsTransparent"]):
        return "MEDIUM", "material_accessor"
    
    # Animation accessors
    if any(x in demangled for x in ["AnimGet", "GetAnim", "SetAnim", "AnimBlend", "AnimForce"]):
        return "MEDIUM", "animation_accessor"
    
    # Physics functions - COMPLEX
    if any(x in lower for x in ["phys", "physics", "karma", "ragdoll"]):
        return "COMPLEX", "physics"
    
    # Movement functions - COMPLEX
    if any(x in lower for x in ["movesmooth", "stepup", "move_", "walkfloor", "adjustfloor"]):
        return "COMPLEX", "movement"
    
    # Pathfinding - COMPLEX  
    if any(x in lower for x in ["pathfind", "findpath", "route", "reachable", "navigation"]):
        return "COMPLEX", "pathfinding"
    
    # Rendering pipeline - COMPLEX
    if any(x in lower for x in ["render", "drawprimitive", "drawmesh", "viewport", "scene"]):
        return "COMPLEX", "rendering"
    
    # Collision - COMPLEX
    if any(x in lower for x in ["collision", "linecheck", "pointcheck", "overlapcheck", "octree", "trace"]):
        return "COMPLEX", "collision"
    
    # Terrain - COMPLEX
    if any(x in lower for x in ["terrain", "deformation", "fillvertexbuffer"]):
        return "COMPLEX", "terrain"
    
    # Networking - COMPLEX
    if any(x in lower for x in ["replicate", "netdriver", "channel", "bunch", "packagemap"]):
        return "COMPLEX", "networking"
    
    # Spawn/destroy actor - COMPLEX
    if any(x in lower for x in ["spawnactor", "destroyactor", "createchannel"]):
        return "COMPLEX", "actor_lifecycle"
    
    # Event routing - COMPLEX
    if any(x in lower for x in ["processevent", "callfunction", "sendevent"]):
        return "COMPLEX", "event_routing"
    
    # TArray template operations
    if "TArray" in demangled or "TMap" in demangled or "TMultiMap" in demangled:
        if any(x in demangled for x in ["::Add", "::Remove", "::Empty", "::Shrink", "::Num"]):
            return "TRIVIAL", "container_op"
        return "MEDIUM", "container_complex"
    
    # Remaining operators
    if "operator" in demangled:
        return "TRIVIAL", "operator"
    
    # Default: MEDIUM for methods with simple signatures, COMPLEX for rest
    # Count parameters as a heuristic
    if '(' in demangled:
        params = demangled.split('(')[1].split(')')[0]
        if params in ('void', ''):
            return "MEDIUM", "no_arg_method"
        param_count = params.count(',') + 1
        if param_count <= 2:
            return "MEDIUM", "simple_method"
        return "COMPLEX", "complex_method"
    
    return "MEDIUM", "unknown"


def generate_report(symbols):
    """Generate markdown report and CSV."""
    # Classify all symbols
    for s in symbols:
        s["class"] = extract_class(s["demangled"])
        category, subcat = classify_symbol(s)
        s["category"] = category
        s["subcategory"] = subcat
    
    # Statistics
    by_category = defaultdict(int)
    by_subcat = defaultdict(int)
    by_class = defaultdict(lambda: defaultdict(int))
    
    for s in symbols:
        by_category[s["category"]] += 1
        by_subcat[s["subcategory"]] += 1
        by_class[s["class"]][s["category"]] += 1
    
    # Write markdown report
    report_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "build", "stub_triage_report.md")
    with open(report_path, "w") as f:
        f.write("# Stub Triage Report\n\n")
        f.write(f"Total stubs: {len(symbols)}\n\n")
        
        f.write("## By Category\n\n")
        f.write("| Category | Count | % |\n")
        f.write("|----------|-------|---|\n")
        total = len(symbols)
        for cat in ["TRIVIAL", "MEDIUM", "COMPLEX"]:
            count = by_category[cat]
            pct = 100.0 * count / total if total else 0
            f.write(f"| {cat} | {count} | {pct:.1f}% |\n")
        
        f.write("\n## By Subcategory\n\n")
        f.write("| Subcategory | Count |\n")
        f.write("|-------------|-------|\n")
        for subcat, count in sorted(by_subcat.items(), key=lambda x: -x[1]):
            f.write(f"| {subcat} | {count} |\n")
        
        f.write("\n## By Class (Top 30)\n\n")
        f.write("| Class | TRIVIAL | MEDIUM | COMPLEX | Total |\n")
        f.write("|-------|---------|--------|---------|-------|\n")
        class_totals = [(cls, sum(cats.values())) for cls, cats in by_class.items()]
        for cls, total_count in sorted(class_totals, key=lambda x: -x[1])[:30]:
            cats = by_class[cls]
            f.write(f"| {cls} | {cats.get('TRIVIAL', 0)} | {cats.get('MEDIUM', 0)} | {cats.get('COMPLEX', 0)} | {total_count} |\n")
    
    # Write CSV
    csv_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "build", "stub_triage.csv")
    with open(csv_path, "w") as f:
        f.write("file,line,mangled,demangled,class,category,subcategory,kind\n")
        for s in symbols:
            # Escape commas in demangled names
            demangled = s["demangled"].replace('"', '""')
            f.write(f'{s["file"]},{s["line"]},"{s["mangled"]}","{demangled}",{s["class"]},{s["category"]},{s["subcategory"]},{s["kind"]}\n')
    
    print(f"Report: {report_path}")
    print(f"CSV:    {csv_path}")
    print(f"\nSummary:")
    for cat in ["TRIVIAL", "MEDIUM", "COMPLEX"]:
        count = by_category[cat]
        pct = 100.0 * count / len(symbols) if symbols else 0
        print(f"  {cat}: {count} ({pct:.1f}%)")
    
    return symbols


def main():
    print("Extracting pragmas from EngineStubs files...")
    symbols = extract_pragmas()
    print(f"Found {len(symbols)} pragma directives")
    
    print("Demangling symbols...")
    symbols = demangle_batch(symbols)
    
    print("Classifying and generating report...")
    symbols = generate_report(symbols)


if __name__ == "__main__":
    main()
