#!/usr/bin/env python3
"""
stub_codegen.py — Code generator for trivial Engine stubs.
Reads the triage CSV and generates C++ implementations that replace
/alternatename pragma redirects.

Strategy:
- __FUNC_NAME__ data symbols: Generate const wchar_t arrays  
- Constructors: Generate empty bodies (Unreal handles init via StaticConstructor)
- Destructors: Generate empty virtual destructors
- Assignment operators: Generate { return *this; }
- Simple getters: Generate return statements for known member patterns
- Vtable/RTTI: Handled by class definitions, just needs the class to exist
"""

import csv
import re
import os
import sys
from collections import defaultdict

BUILD_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "build")
SRC_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "src", "engine")

CSV_PATH = os.path.join(BUILD_DIR, "stub_triage.csv")


def load_stubs():
    """Load classified stubs from CSV."""
    stubs = []
    with open(CSV_PATH) as f:
        for row in csv.DictReader(f):
            stubs.append(row)
    return stubs


def parse_func_name_data(demangled):
    """Extract the function name string from a __FUNC_NAME__ data symbol."""
    # Pattern: "unsigned short const * const `...ClassName::Method(...)'::`3'::__FUNC_NAME__"
    m = re.search(r"`[^`]*?(\w+)::(\w+)\([^)]*\)'", demangled)
    if m:
        return f"{m.group(1)}::{m.group(2)}"
    return None


def generate_func_name_array(name_str, var_name):
    """Generate a const wchar array for __FUNC_NAME__ export."""
    chars = ','.join(f"'{c}'" for c in name_str) + ",0"
    return f'extern "C" __declspec(dllexport) const unsigned short {var_name}[] = {{{chars}}};'


def parse_constructor(demangled, mangled):
    """Parse constructor info from demangled name."""
    # "public: __thiscall ClassName::ClassName(...)"
    m = re.search(r'(\w+(?:<[^>]+>)?)::(\w+(?:<[^>]+>)?)\(([^)]*)\)', demangled)
    if m:
        return {
            "class": m.group(1),
            "name": m.group(2),
            "params": m.group(3),
        }
    return None


def parse_destructor(demangled, mangled):
    """Parse destructor info."""
    m = re.search(r'(\w+(?:<[^>]+>)?)::~(\w+(?:<[^>]+>)?)\(', demangled)
    if m:
        return {"class": m.group(1)}
    return None


def parse_method(demangled, mangled):
    """Parse general method info from demangled name."""
    # "access: [virtual] rettype __callconv ClassName::Method(params)"
    m = re.match(
        r'(public|protected|private):\s*(virtual\s+)?'
        r'([\w\s\*&<>,]+?)\s+__\w+call\s+'
        r'(\w+(?:<[^>]+>)?)::(\w+)\(([^)]*)\)',
        demangled
    )
    if m:
        return {
            "access": m.group(1),
            "virtual": bool(m.group(2)),
            "return_type": m.group(3).strip(),
            "class": m.group(4),
            "method": m.group(5),
            "params": m.group(6),
        }
    return None


def get_default_return(return_type):
    """Get a sensible default return value for a type."""
    rt = return_type.strip()
    if rt == "void":
        return ""
    if rt in ("int", "long", "unsigned int", "unsigned long", "short", "unsigned short",
              "char", "unsigned char", "signed char"):
        return "return 0;"
    if rt in ("float", "double"):
        return "return 0.0f;"
    if rt == "bool" or rt == "UBOOL":
        return "return 0;"
    if "*" in rt:
        return "return NULL;"
    if rt == "class FString":
        return 'return FString(TEXT(""));'
    if rt == "class FVector" or rt == "struct FVector":
        return "return FVector(0,0,0);"
    if rt == "class FRotator" or rt == "struct FRotator":
        return "return FRotator(0,0,0);"
    if rt == "class FCoords" or rt == "struct FCoords":
        return "FCoords C; return C;"
    if rt == "class FMatrix" or rt == "struct FMatrix":
        return "FMatrix M; M.SetIdentity(); return M;"
    if rt == "class FPlane" or rt == "struct FPlane":
        return "return FPlane(0,0,0,0);"
    if rt == "class FBox" or rt == "struct FBox":
        return "return FBox(FVector(0,0,0), FVector(0,0,0));"
    if rt == "class FScale" or rt == "struct FScale":
        return "return FScale();"
    if rt == "class FSphere" or rt == "struct FSphere":
        return "return FSphere(0,0,0,0);"
    if rt == "enum EShaderType":
        return "return (EShaderType)0;"
    if rt.startswith("enum "):
        return "return (" + rt.replace("enum ", "") + ")0;"
    # Class/struct by value - try default constructor
    clean = rt.replace("class ", "").replace("struct ", "")
    return f"return {clean}();"


def generate_implementations(stubs):
    """Generate C++ implementation code grouped by class."""
    
    by_class = defaultdict(list)
    data_symbols = []
    unhandled = []
    
    for s in stubs:
        if s["category"] != "TRIVIAL":
            continue
            
        demangled = s["demangled"]
        mangled = s["mangled"]
        subcat = s["subcategory"]
        
        if subcat == "data_symbol":
            data_symbols.append(s)
        elif subcat in ("constructor", "destructor", "assignment_op",
                        "simple_getter", "simple_setter", "operator",
                        "deleting_dtor", "container_op"):
            # Extract class name
            m = re.search(r'(\w+(?:<[^>]+>)?)::', demangled)
            cls = m.group(1) if m else "global"
            by_class[cls].append(s)
        elif subcat in ("vtable", "rtti"):
            # These are handled by the class definition existing
            data_symbols.append(s)
        else:
            unhandled.append(s)
    
    return by_class, data_symbols, unhandled


def write_stub_implementations(by_class, data_symbols):
    """Write generated implementation files."""
    
    # Count stats
    total_generated = 0
    total_data = 0
    
    # Generate __FUNC_NAME__ data implementations
    func_name_code = []
    regular_data = []
    
    for s in data_symbols:
        demangled = s["demangled"]
        mangled = s["mangled"]
        
        if "__FUNC_NAME__" in demangled:
            name_str = parse_func_name_data(demangled)
            if name_str:
                # Create a safe C identifier from the mangled name
                safe_id = mangled.replace("?", "_q").replace("@", "_a").replace(":", "_c")
                safe_id = re.sub(r'[^a-zA-Z0-9_]', '_', safe_id)
                safe_id = safe_id[:60]  # Limit length
                code = generate_func_name_array(name_str, f"_gfn_{safe_id}")
                func_name_code.append((mangled, code, safe_id))
                total_data += 1
        elif s["subcategory"] in ("vtable", "rtti"):
            # These just need to be emitted by the class definition
            pass
    
    # Generate method implementations
    method_code = defaultdict(list)
    pragma_removals = []  # Track which pragmas to remove
    
    for cls, stubs_list in sorted(by_class.items()):
        for s in stubs_list:
            demangled = s["demangled"]
            mangled = s["mangled"]
            subcat = s["subcategory"]
            
            code = None
            
            if subcat == "constructor":
                info = parse_constructor(demangled, mangled)
                if info:
                    params = info["params"]
                    if params == "void" or params == "":
                        code = f'{cls}::{info["name"]}() {{}}'
                    elif "class" in params or "struct" in params or "enum" in params:
                        # Copy constructor or parameterized
                        # Clean params for declaration
                        code = f'// {demangled}\n// {cls}::{info["name"]}({params}) {{ }}'
                    else:
                        code = f'// {demangled}\n// TODO: constructor with params: {params}'
                        
            elif subcat == "destructor":
                info = parse_destructor(demangled, mangled)
                if info:
                    code = f'{cls}::~{cls}() {{}}'
                    
            elif subcat == "deleting_dtor":
                # Scalar/vector deleting destructor - compiler generates these
                pass
                
            elif subcat == "assignment_op":
                # operator=(const ClassName&)
                m = re.search(r'(\w+)::operator=\(', demangled)
                if m:
                    code = f'{cls}& {cls}::operator=(const {cls}& Other) {{ return *this; }}'
                    
            elif subcat == "simple_getter":
                info = parse_method(demangled, mangled)
                if info:
                    ret = get_default_return(info["return_type"])
                    code = f'{info["return_type"]} {cls}::{info["method"]}() {{ {ret} }}'
                    
            elif subcat == "simple_setter":
                info = parse_method(demangled, mangled)
                if info:
                    code = f'void {cls}::{info["method"]}({info["params"]}) {{}}'
                    
            elif subcat == "operator":
                info = parse_method(demangled, mangled)
                if info:
                    ret = get_default_return(info["return_type"])
                    code = f'{info["return_type"]} {cls}::{info["method"]}({info["params"]}) {{ {ret} }}'
                    
            elif subcat == "container_op":
                # TArray operations - simple
                info = parse_method(demangled, mangled)
                if info:
                    ret = get_default_return(info["return_type"])
                    code = f'{info["return_type"]} {cls}::{info["method"]}({info["params"]}) {{ {ret} }}'
            
            if code:
                method_code[cls].append(code)
                pragma_removals.append(mangled)
                total_generated += 1
    
    print(f"\nGenerated {total_generated} method implementations across {len(method_code)} classes")
    print(f"Generated {total_data} __FUNC_NAME__ data symbols")
    print(f"Total pragmas that can be removed: {total_generated + total_data}")
    
    # Write to file
    output_path = os.path.join(BUILD_DIR, "generated_trivial_stubs.cpp")
    with open(output_path, "w") as f:
        f.write("// AUTO-GENERATED trivial stub implementations\n")
        f.write("// Generated by tools/stub_codegen.py\n")
        f.write("// Review and integrate into appropriate source files\n\n")
        
        f.write(f"// Total: {total_generated} methods + {total_data} data symbols\n\n")
        
        # Write data symbols
        if func_name_code:
            f.write("// ============================================\n")
            f.write("// __FUNC_NAME__ data symbols\n") 
            f.write("// ============================================\n\n")
            f.write('extern "C" {\n')
            for mangled, code, safe_id in func_name_code:
                f.write(f"// pragma: {mangled}\n")
                f.write(f"{code}\n\n")
            f.write('} // extern "C"\n\n')
            
            # Write pragma aliases
            f.write("// Pragma aliases for __FUNC_NAME__ symbols\n")
            for mangled, code, safe_id in func_name_code:
                f.write(f'#pragma comment(linker, "/alternatename:{mangled}=__gfn_{safe_id}")\n')
            f.write("\n")
        
        # Write method implementations
        for cls in sorted(method_code.keys()):
            f.write(f"// ============================================\n")
            f.write(f"// {cls}\n")
            f.write(f"// ============================================\n\n")
            for code in method_code[cls]:
                f.write(f"{code}\n\n")
    
    # Write the list of pragmas to remove
    removal_path = os.path.join(BUILD_DIR, "pragmas_to_remove.txt")
    with open(removal_path, "w") as f:
        for m in pragma_removals:
            f.write(f"{m}\n")
    
    print(f"\nOutput: {output_path}")
    print(f"Removal list: {removal_path}")


def main():
    print("Loading triage data...")
    stubs = load_stubs()
    
    print(f"Loaded {len(stubs)} stubs")
    trivial = [s for s in stubs if s["category"] == "TRIVIAL"]
    print(f"TRIVIAL stubs: {len(trivial)}")
    
    print("Generating implementations...")
    by_class, data_symbols, unhandled = generate_implementations(stubs)
    
    print(f"Classes with methods: {len(by_class)}")
    print(f"Data symbols: {len(data_symbols)}")
    print(f"Unhandled: {len(unhandled)}")
    
    write_stub_implementations(by_class, data_symbols)


if __name__ == "__main__":
    main()
