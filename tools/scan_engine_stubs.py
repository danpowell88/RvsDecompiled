"""scan_engine_stubs.py - Scan all Engine.dll stubs vs retail binary.

Reads EngineStubs.cpp function names, looks them up in retail Engine.dll,
classifies each function by size. Outputs a prioritized list.
"""
import re, sys

# Load Engine.dll exports
exports = {}
try:
    with open('build/retail_engine_exports.txt', 'rb') as f:
        bom2 = f.read(2)
    enc = 'utf-16' if bom2 == b'\xff\xfe' else 'utf-8'
    with open('build/retail_engine_exports.txt', encoding=enc, errors='ignore') as f:
        for line in f:
            parts = line.strip().split()
            if len(parts) >= 4:
                try:
                    exports[parts[3]] = int(parts[2], 16)
                except (ValueError, IndexError):
                    pass
except FileNotFoundError:
    print("ERROR: build/retail_engine_exports.txt not found")
    sys.exit(1)

# Load Engine.dll bytes
try:
    data = open('retail/system/Engine.dll', 'rb').read()
except FileNotFoundError:
    print("ERROR: retail/system/Engine.dll not found")
    sys.exit(1)

print(f"Loaded {len(exports)} exports, {len(data)//1024}KB DLL")

def classify(rva, max_scan=600):
    if rva >= len(data): return 'INVALID', 0
    b0 = data[rva]
    if b0 == 0xC3: return 'EMPTY', 1
    if b0 == 0xC2: return 'EMPTY', 3
    for end in range(rva, min(rva + max_scan, len(data))):
        b = data[end]
        if b == 0xC3:
            size = end - rva + 1; break
        if b == 0xC2 and end + 2 < len(data):
            size = end - rva + 3; break
    else:
        size = max_scan
    if size <= 5:   return 'TRIVIAL', size
    if size <= 50:  return 'SHORT',   size
    if size <= 150: return 'MEDIUM',  size
    return 'LARGE', size

def lookup(cls_fragment, func_fragment):
    """Find best matching export symbol."""
    matches = [(k, v) for k, v in exports.items()
               if func_fragment in k and cls_fragment in k]
    if not matches: return None, None
    return min(matches, key=lambda x: len(x[0]))

# Parse EngineStubs.cpp to extract function signatures
stubs_file = 'src/engine/Src/EngineStubs.cpp'
try:
    content = open(stubs_file).read()
except FileNotFoundError:
    print(f"ERROR: {stubs_file} not found")
    sys.exit(1)

# Find all function definitions: ReturnType Class::Method(...) { return ...; }
# Capture class::method pairs
func_pat = re.compile(
    r'^(?:void|INT|UBOOL|FLOAT|FVector|FRotator|FString|BYTE|DWORD|WORD|SHORT|LONG|'
    r'UObject\s*\*|AActor\s*\*|APawn\s*\*|AController\s*\*|[A-Z][A-Za-z0-9_]*\s*\*?)\s+'
    r'([A-Z][A-Za-z0-9_]+)::([A-Za-z0-9_]+)\s*\([^)]*\)',
    re.MULTILINE
)

results = []
current_section = 'UNKNOWN'
for line in content.split('\n'):
    m = re.match(r'^// --- (.+?) ---', line)
    if m:
        current_section = m.group(1)

func_matches = list(func_pat.finditer(content))
print(f"Found {len(func_matches)} function definitions in EngineStubs.cpp")
print()

# Track sections
line_starts = [0]
for c in content:
    if c == '\n': line_starts.append(line_starts[-1] + 1)
# Actually just track by class name in the pattern

section_map = {}
for m in re.finditer(r'^// --- (.+?) ---', content, re.MULTILINE):
    section_map[m.start()] = m.group(1)
section_positions = sorted(section_map.keys())

def get_section(pos):
    low = 0
    for p in section_positions:
        if p <= pos: low = p
        else: break
    return section_map.get(low, 'UNKNOWN')

# Collect all function results
by_cat = {'TRIVIAL': [], 'SHORT': [], 'MEDIUM': [], 'LARGE': [], 'EMPTY': [], 'NOTFOUND': [], 'INVALID': []}

for m in func_matches:
    cls  = m.group(1)
    func = m.group(2)
    sym, rva = lookup(cls, func)
    if sym is None:
        by_cat['NOTFOUND'].append((cls, func, 0, get_section(m.start())))
        continue
    cat, size = classify(rva)
    by_cat[cat].append((cls, func, size, get_section(m.start())))

# Print summary
print("=== SUMMARY ===")
for cat, items in by_cat.items():
    print(f"  {cat}: {len(items)}")
print()

# Print TRIVIAL (these are worth immediate implementation)
if by_cat['TRIVIAL']:
    print("=== TRIVIAL (implement immediately) ===")
    for cls, func, size, section in sorted(by_cat['TRIVIAL']):
        print(f"  {section}: {cls}::{func}  {size}b")
    print()

if by_cat['SHORT']:
    print("=== SHORT (prioritize) ===")
    for cls, func, size, section in sorted(by_cat['SHORT'], key=lambda x: x[2]):
        print(f"  {section}: {cls}::{func}  {size}b")
    print()

if by_cat['EMPTY']:
    print("=== EMPTY (already correct) ===")
    for cls, func, size, section in sorted(by_cat['EMPTY']):
        print(f"  {cls}::{func}")
    print()

print(f"MEDIUM: {len(by_cat['MEDIUM'])} functions")
print(f"LARGE:  {len(by_cat['LARGE'])} functions")
print(f"NOTFOUND: {len(by_cat['NOTFOUND'])} functions")
