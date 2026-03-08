"""Extract and demangle all remaining stub symbols, grouped by class."""
import subprocess
import re
import sys
from collections import defaultdict

UNDNAME = r"C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\undname.exe"
STUB_FILES = [
    "src/engine/EngineStubs1.cpp",
    "src/engine/EngineStubs2.cpp",
    "src/engine/EngineStubs3.cpp",
    "src/engine/EngineStubs4.cpp",
]

def extract_stubs():
    """Extract all (mangled, target) pairs from stub files."""
    stubs = []
    for fpath in STUB_FILES:
        with open(fpath, "r") as f:
            for line in f:
                m = re.search(r'alternatename:(\S+)=(\S+)', line.rstrip('")\n'))
                if m:
                    stubs.append((m.group(1), m.group(2)))
    return stubs

def demangle(symbol):
    """Demangle a single MSVC symbol."""
    try:
        result = subprocess.run([UNDNAME, symbol], capture_output=True, text=True, timeout=5)
        # Look for the 'is :-' line
        for line in result.stdout.split('\n'):
            if 'is :-' in line:
                return line.split('is :-')[1].strip().strip('"')
    except:
        pass
    return None

def get_class_from_symbol(sym):
    """Extract class name from mangled symbol."""
    # vtable: ??_7ClassName@@
    m = re.match(r'\?\?_7(\w+)@@', sym)
    if m: return m.group(1)
    # ctor: ??0ClassName@@
    m = re.match(r'\?\?0(\w+)@@', sym)
    if m: return m.group(1)
    # dtor: ??1ClassName@@
    m = re.match(r'\?\?1(\w+)@@', sym)
    if m: return m.group(1)
    # operator: ??[4-9BH]ClassName@@
    m = re.match(r'\?\?[0-9A-Z](\w+)@@', sym)
    if m: return m.group(1)
    # method: ?MethodName@ClassName@@
    m = re.match(r'\?\w+@(\w+)@@', sym)
    if m: return m.group(1)
    return "UNKNOWN"

def classify_symbol(sym, target):
    """Classify a symbol as vtable/ctor/dtor/virtual/nonvirtual/static/data."""
    if sym.startswith('??_7'): return 'vtable'
    if sym.startswith('??0'): return 'ctor'
    if sym.startswith('??1'): return 'dtor'
    if target == '_dummy_stub_data': return 'data'
    # Check calling convention for virtual vs non-virtual
    if '@@UAE' in sym or '@@UBE' in sym: return 'virtual'
    if '@@QAE' in sym or '@@QBE' in sym: return 'public'
    if '@@IAE' in sym or '@@IBE' in sym: return 'protected'
    if '@@AAE' in sym or '@@ABE' in sym: return 'private'
    if '@@SA' in sym: return 'static'
    if '@@2' in sym: return 'static_data'
    return 'unknown'

def main():
    stubs = extract_stubs()
    print(f"Total stubs: {len(stubs)}")
    
    # Group by class
    by_class = defaultdict(list)
    for sym, target in stubs:
        cls = get_class_from_symbol(sym)
        by_class[cls].append((sym, target))
    
    # Sort classes by count
    sorted_classes = sorted(by_class.items(), key=lambda x: -len(x[1]))
    
    # Demangle and print 
    for cls, members in sorted_classes:
        print(f"\n{'='*70}")
        print(f"CLASS: {cls} ({len(members)} stubs)")
        print(f"{'='*70}")
        
        for sym, target in sorted(members, key=lambda x: classify_symbol(x[0], x[1])):
            kind = classify_symbol(sym, target)
            demangled = demangle(sym)
            if demangled:
                print(f"  [{kind:10s}] {demangled}")
            else:
                print(f"  [{kind:10s}] {sym} (demangle failed)")

if __name__ == '__main__':
    main()
