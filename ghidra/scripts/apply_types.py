# =============================================================================
# apply_types.py - Ghidra script to import SDK type libraries
# =============================================================================
# Parses C headers from the Raven_Shield_C_SDK, 432Core, UT99PubSrc, and
# platform SDKs into Ghidra's type system. This dramatically improves
# decompilation quality by giving Ghidra knowledge of struct layouts,
# class hierarchies, enum values, and function signatures.
#
# Run via: tools/run_headless.bat -postScript ghidra/scripts/apply_types.py
# Or from Ghidra GUI: Script Manager -> Run
# =============================================================================

# @category RavenShield
# @menupath Tools.RavenShield.Apply Type Libraries

import os
import ghidra
from ghidra.app.util.cparser import CParser
from ghidra.program.model.data import DataTypeManager, CategoryPath
from ghidra.app.cmd.function import ApplyFunctionSignatureCmd
from java.io import File

def get_project_root():
    """Walk up from script location to find project root."""
    script_dir = getSourceFile().getParentFile().getParentFile().getParentFile()
    return script_dir.getAbsolutePath()

def parse_header_directory(dtm, header_dir, include_dirs, category_name):
    """Parse all .h files in a directory into Ghidra's DataTypeManager."""
    parser = CParser(dtm)
    header_path = File(header_dir)
    
    if not header_path.exists():
        printerr("Header directory not found: " + header_dir)
        return 0
    
    count = 0
    headers = [f for f in header_path.listFiles() if f.getName().endswith(".h")]
    
    for header in sorted(headers, key=lambda f: f.getName()):
        try:
            println("  Parsing: " + header.getName())
            
            # Build include path args
            args = ["-D_MSC_VER=1310"]  # MSVC 7.1
            args.append("-DDLL_IMPORT=")  # Strip DLL_IMPORT for parsing
            args.append("-DCORE_API=")
            args.append("-DENGINE_API=")
            args.append("-D_UNICODE")
            args.append("-DUNICODE")
            
            for inc in include_dirs:
                if os.path.isdir(inc):
                    args.append("-I" + inc)
            
            # Parse the header
            parsed = parser.parse(header.getAbsolutePath())
            if parsed:
                count += 1
        except Exception as e:
            printerr("  Failed to parse " + header.getName() + ": " + str(e))
    
    return count

def apply_types_to_program(program):
    """Apply known types from SDK headers to the current program."""
    root = get_project_root()
    dtm = program.getDataTypeManager()
    
    # Define SDK paths
    sdk_base = os.path.join(root, "sdk")
    csdk_inc = os.path.join(sdk_base, "Raven_Shield_C_SDK", "inc")
    core432_inc = os.path.join(sdk_base, "Raven_Shield_C_SDK", "432Core", "Inc")
    ut99_core_inc = os.path.join(sdk_base, "Ut99PubSrc", "Core", "Inc")
    ut99_engine_inc = os.path.join(sdk_base, "Ut99PubSrc", "Engine", "Inc")
    winsdk_inc = os.path.join(root, "tools", "toolchain", "winsdk", "Include")
    dxsdk_inc = os.path.join(root, "tools", "toolchain", "dxsdk", "Include")
    
    # Common include directories for resolution
    include_dirs = [
        csdk_inc, core432_inc, ut99_core_inc, ut99_engine_inc,
        winsdk_inc, dxsdk_inc
    ]
    
    total = 0
    
    # --- Priority 1: Raven Shield C SDK headers (most specific) ---
    println("\n=== Raven Shield C SDK Headers ===")
    total += parse_header_directory(dtm, csdk_inc, include_dirs, "RavenShield")
    
    # --- Priority 2: 432Core headers (Unreal core types) ---
    println("\n=== 432Core Headers ===")
    total += parse_header_directory(dtm, core432_inc, include_dirs, "Core432")
    
    # --- Priority 3: UT99 public source headers ---
    println("\n=== UT99 Core Headers ===")
    total += parse_header_directory(dtm, ut99_core_inc, include_dirs, "UT99Core")
    
    println("\n=== UT99 Engine Headers ===")
    total += parse_header_directory(dtm, ut99_engine_inc, include_dirs, "UT99Engine")
    
    println("\n=== Summary ===")
    println("Total headers parsed: " + str(total))
    println("DataType count: " + str(dtm.getDataTypeCount(True)))

def run():
    program = getCurrentProgram()
    if program is None:
        printerr("No program loaded. Open a binary first.")
        return
    
    println("=" * 60)
    println("Applying SDK Type Libraries to: " + program.getName())
    println("=" * 60)
    
    txn = program.startTransaction("Apply SDK Type Libraries")
    try:
        apply_types_to_program(program)
        program.endTransaction(txn, True)
        println("\nType libraries applied successfully.")
    except Exception as e:
        program.endTransaction(txn, False)
        printerr("Error applying types: " + str(e))
        raise

run()
