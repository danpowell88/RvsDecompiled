# -*- coding: utf-8 -*-
# =============================================================================
# symbol_recovery.py - Recover class/method names from MSVC mangled exports
# =============================================================================
# MSVC 7.1 uses decorated (mangled) names for C++ exports. This script:
# 1. Reads export tables from each binary
# 2. Demangles MSVC decorated names to recover class::method signatures
# 3. Cross-references against SDK header declarations
# 4. Applies recovered names to Ghidra's function database
#
# MSVC mangling format: ?MethodName@ClassName@@<calling_convention><return_type><params>
# Example: ?Tick@AActor@@UAEXMHHPAUFVector@@@Z -> void AActor::Tick(float, int, int, FVector*)
#
# Run via Ghidra GUI or headless after batch_import.py
# =============================================================================

# @category RavenShield
# @menupath Tools.RavenShield.Recover Symbols

import os
import re
import json
from ghidra.program.model.symbol import SymbolTable, SourceType
from ghidra.app.util.demangler import DemanglerUtil
from ghidra.app.util.demangler.microsoft import MicrosoftDemangler

# Map of DLL names to their SDK header file
DLL_TO_HEADER = {
    "Core":          "CoreClasses.h",
    "Engine":        "EngineClasses.h",
    "R6Abstract":    "R6AbstractClasses.h",
    "R6Engine":      "R6EngineClasses.h",
    "R6Game":        "R6GameClasses.h",
    "R6Weapons":     "R6WeaponsClasses.h",
    "R6GameService": "R6GameServiceClasses.h",
    "D3DDrv":        "D3DDrvClasses.h",
    "WinDrv":        "WinDrvClasses.h",
    "IpDrv":         "IpDrvClasses.h",
    "DareAudio":     "DareAudioClasses.h",
    "R6WeaponGadgets": "R6WeaponGadgetsClasses.h",
    "R6Characters":  "R6CharactersClasses.h",
    "R6Description": "R6DescriptionClasses.h",
    "R6Menu":        "R6MenuClasses.h",
    "R6SFX":         "R6SFXClasses.h",
    "R6Window":      "R6WindowClasses.h",
    "UWindow":       "UWindowClasses.h",
    "R61stWeapons":  "R61stWeaponsClasses.h",
    "R63rdWeapons":  "R63rdWeaponsClasses.h",
}

def get_project_root():
    script_dir = getSourceFile().getParentFile().getParentFile().getParentFile()
    return script_dir.getAbsolutePath()

def parse_class_names_from_header(header_path):
    """Extract class names and method signatures from SDK header."""
    classes = {}
    current_class = None
    
    if not os.path.isfile(header_path):
        return classes
    
    with open(header_path, "r") as f:
        for line in f:
            line = line.strip()
            
            # Match class declarations: class DLL_IMPORT ClassName : public BaseClass
            cls_match = re.match(
                r'class\s+(?:DLL_IMPORT\s+)?(\w+)\s*(?::\s*public\s+(\w+))?', line
            )
            if cls_match:
                current_class = cls_match.group(1)
                base_class = cls_match.group(2)
                classes[current_class] = {
                    "base": base_class,
                    "methods": [],
                    "properties": [],
                }
                continue
            
            # Match method declarations inside classes
            if current_class and line and not line.startswith("//") and not line.startswith("/*"):
                # Match: virtual void MethodName(params);
                method_match = re.match(
                    r'(?:virtual\s+)?(?:static\s+)?(\w[\w\s\*&]*?)\s+(\w+)\s*\(([^)]*)\)',
                    line
                )
                if method_match and current_class in classes:
                    classes[current_class]["methods"].append({
                        "return_type": method_match.group(1).strip(),
                        "name": method_match.group(2),
                        "params": method_match.group(3).strip(),
                    })
                
                # Match property with CPF flags comment
                prop_match = re.match(
                    r'(\w[\w\s\*&]*?)\s+(\w+)\s*;.*//\s*(CPF_\w+)',
                    line
                )
                if prop_match and current_class in classes:
                    classes[current_class]["properties"].append({
                        "type": prop_match.group(1).strip(),
                        "name": prop_match.group(2),
                        "flags": prop_match.group(3),
                    })
    
    return classes

def demangle_and_apply(program):
    """Demangle all export symbols and apply recovered names."""
    st = program.getSymbolTable()
    fm = program.getFunctionManager()
    demangler = MicrosoftDemangler()
    
    root = get_project_root()
    sdk_inc = os.path.join(root, "sdk", "Raven_Shield_C_SDK", "inc")
    
    # Determine which header to use based on program name
    prog_name = program.getName().replace(".dll", "").replace(".exe", "")
    header_name = DLL_TO_HEADER.get(prog_name)
    
    sdk_classes = {}
    if header_name:
        header_path = os.path.join(sdk_inc, header_name)
        println("Loading SDK header: " + header_name)
        sdk_classes = parse_class_names_from_header(header_path)
        println("  Found " + str(len(sdk_classes)) + " classes")
    
    # Process all symbols
    recovered = 0
    matched_sdk = 0
    recovered_symbols = []
    
    sym_iter = st.getAllSymbols(True)
    for sym in sym_iter:
        name = sym.getName()
        
        # Skip non-mangled names
        if not name.startswith("?"):
            continue
        
        try:
            result = demangler.demangle(name)
            if result:
                result.applyTo(program, sym.getAddress(), 
                             demangler.createDefaultOptions(), monitor)
                recovered += 1
                
                demangled = str(result)
                sdk_match = False
                
                # Check against SDK
                for cls_name in sdk_classes:
                    if cls_name in demangled:
                        matched_sdk += 1
                        sdk_match = True
                        break
                
                recovered_symbols.append({
                    "mangled": name,
                    "demangled": demangled,
                    "address": str(sym.getAddress()),
                    "sdk_match": sdk_match,
                })
        except Exception as e:
            # Some symbols may not demangle cleanly
            pass
    
    println("\nSymbol Recovery Summary:")
    println("  Demangled:    " + str(recovered))
    println("  SDK matched:  " + str(matched_sdk))
    println("  SDK classes:  " + str(len(sdk_classes)))
    
    return recovered, matched_sdk, recovered_symbols

def run():
    program = getCurrentProgram()
    if program is None:
        printerr("No program loaded.")
        return
    
    println("=" * 60)
    println("Symbol Recovery: " + program.getName())
    println("=" * 60)
    
    txn = program.startTransaction("Symbol Recovery")
    try:
        recovered, matched_sdk, symbols = demangle_and_apply(program)
        program.endTransaction(txn, True)
        
        # Save report
        root = get_project_root()
        output_dir = os.path.join(root, "ghidra", "exports", "reports")
        if not os.path.isdir(output_dir):
            os.makedirs(output_dir)
        
        prog_name = program.getName().replace(".", "_")
        report = {
            "binary": program.getName(),
            "recovered_count": recovered,
            "sdk_matched_count": matched_sdk,
            "symbols": symbols,
        }
        filepath = os.path.join(output_dir, prog_name + "_symbols.json")
        with open(filepath, "w") as f:
            json.dump(report, f, indent=2)
        println("Report saved: " + filepath)
    except Exception as e:
        program.endTransaction(txn, False)
        printerr("Error: " + str(e))
        raise

run()
