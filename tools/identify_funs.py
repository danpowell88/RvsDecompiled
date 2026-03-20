#!/usr/bin/env python3
"""
identify_funs.py - Identify unnamed FUN_ functions from Ghidra exports.

Reads _unnamed.cpp (and _thunks.cpp) for a given DLL, classifies each FUN_
by pattern matching against known template instantiation signatures, and
cross-references which FUN_ addresses are blocking IMPL_TODOs in src/.

Usage:
    python tools/identify_funs.py [--dll Engine] [--blockers-only]
"""

import re
import os
import sys
import json
from collections import defaultdict

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)

# ============================================================================
# Pattern recognition for common unnamed function types
# ============================================================================

PATTERNS = [
    # TArray destructor: checks ArrayNum>=0, calls FArray::Remove(0,N,stride), then FArray::~FArray
    {
        'name': 'TArray<T>::~TArray',
        'match': lambda body: (
            'FArray::Remove' in body and 'FArray::~FArray' in body
            and 'appFailAssert' in body
            and 'UnTemplate.h' in body
        ),
        'extract_stride': lambda body: _extract_remove_stride(body),
    },
    # TArray destructor (simple): just calls element dtors + FArray::~FArray, no Remove
    {
        'name': 'TArray<T>::~TArray (element-dtor)',
        'match': lambda body: (
            'FArray::~FArray' in body
            and 'appFailAssert' not in body
            and body.count('FUN_') >= 1
            and 'FArray::Remove' not in body
        ),
        'extract_stride': lambda body: None,
    },
    # TArray empty/clear: FArray::Remove only, no destructor
    {
        'name': 'TArray<T>::Empty',
        'match': lambda body: (
            'FArray::Remove' in body
            and 'FArray::~FArray' not in body
        ),
        'extract_stride': lambda body: _extract_remove_stride(body),
    },
    # appSeconds / rdtsc wrapper
    {
        'name': 'appSeconds (rdtsc)',
        'match': lambda body: 'rdtsc' in body and 'GSecondsPerCycle' in body,
        'extract_stride': lambda body: None,
    },
    # appMemcpy (SSE check + copy)
    {
        'name': 'appMemcpy',
        'match': lambda body: 'GIsSSE' in body and 'movntq' in body.lower() or (
            'GIsSSE' in body and len(body) > 400
        ),
        'extract_stride': lambda body: None,
    },
    # FVector math: small functions with float math and 3 components
    {
        'name': 'FVector operator (math)',
        'match': lambda body: (
            body.count('float') >= 3
            and ('param_1 + 4' in body or 'param_1 + 8' in body)
            and len(body) < 500
            and 'FArray' not in body
        ),
        'extract_stride': lambda body: None,
    },
    # FRotator::Vector — converts rotation to direction vector
    {
        'name': 'FRotator::Vector',
        'match': lambda body: (
            'GMath' in body
            and ('0x3fff' in body or '16383' in body or '0x3FFF' in body)
        ),
        'extract_stride': lambda body: None,
    },
    # FString helpers — reference to TCHAR or wchar
    {
        'name': 'FString helper',
        'match': lambda body: (
            ('appStrcpy' in body or 'appStrlen' in body or 'appSprintf' in body
             or 'GLog' in body)
            and 'FArray' not in body
        ),
        'extract_stride': lambda body: None,
    },
    # Guard/unguard SEH wrapper (small, just has exception list setup)
    {
        'name': 'SEH guard wrapper',
        'match': lambda body: (
            'ExceptionList' in body
            and len(body) < 300
            and 'FArray' not in body
            and 'appFailAssert' not in body
        ),
        'extract_stride': lambda body: None,
    },
    # FCoords / matrix transform
    {
        'name': 'FCoords/Matrix transform',
        'match': lambda body: (
            body.count('float') >= 6
            and ('XAxis' in body or 'YAxis' in body or 'Origin' in body
                 or (body.count('* ') >= 6 and body.count('+ ') >= 3))
            and len(body) > 300
        ),
        'extract_stride': lambda body: None,
    },
    # TMap operations
    {
        'name': 'TMap operation',
        'match': lambda body: (
            'Rehash' in body or 'HashIndex' in body
            or ('GetData' in body and 'HashCount' in body)
        ),
        'extract_stride': lambda body: None,
    },
    # Serialize helper (reads/writes archive)  
    {
        'name': 'Serialize/Archive helper',
        'match': lambda body: (
            ('FArchive' in body or 'Serialize' in body or 'operator<<' in body)
            and 'FArray' not in body
        ),
        'extract_stride': lambda body: None,
    },
]


def _extract_remove_stride(body):
    """Extract the element stride from FArray::Remove(ecx, 0, count, STRIDE)."""
    m = re.search(r'FArray::Remove\([^,]+,\s*0\s*,\s*[^,]+,\s*(0x[0-9a-fA-F]+|\d+)\)', body)
    if m:
        val = m.group(1)
        return int(val, 16) if val.startswith('0x') else int(val)
    return None


# ============================================================================
# Parser: extract FUN_ entries from _unnamed.cpp / _thunks.cpp
# ============================================================================

def parse_functions(filepath):
    """Parse Ghidra export file into a list of {addr, size, name, body}."""
    if not os.path.isfile(filepath):
        return []
    
    with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
        content = f.read()

    functions = []
    # Split on "// Address:" markers
    parts = re.split(r'(?=// Address: [0-9a-fA-F]+\n)', content)
    
    for part in parts:
        m_addr = re.match(r'// Address: ([0-9a-fA-F]+)\n', part)
        if not m_addr:
            continue
        addr = m_addr.group(1)
        
        m_size = re.search(r'// Size: (\d+) bytes', part)
        size = int(m_size.group(1)) if m_size else 0
        
        # Extract function name (FUN_xxx or thunk_FUN_xxx)
        m_name = re.search(r'(?:void|int|float\d*|undefined\d*|FUN_\w+|[A-Z]\w+)\s+((?:thunk_)?FUN_[0-9a-fA-F]+)\s*\(', part)
        if not m_name:
            m_name = re.search(r'(FUN_[0-9a-fA-F]+)\(', part)
        name = m_name.group(1) if m_name else f'FUN_{addr}'
        
        functions.append({
            'addr': addr,
            'size': size,
            'name': name,
            'body': part,
        })
    
    return functions


def classify_function(func):
    """Classify a function based on pattern matching."""
    body = func['body']
    
    for pattern in PATTERNS:
        if pattern['match'](body):
            stride = pattern.get('extract_stride', lambda b: None)(body)
            return {
                'classification': pattern['name'],
                'stride': stride,
            }
    
    return {'classification': 'unknown', 'stride': None}


# ============================================================================
# Blocker cross-reference: find which FUN_ addrs appear in IMPL_TODOs
# ============================================================================

def find_blocker_refs():
    """Scan src/ for IMPL_TODO strings and extract FUN_ references."""
    src_dir = os.path.join(PROJECT_ROOT, 'src')
    blockers = defaultdict(list)  # addr -> [(file, line, context)]
    
    for root, dirs, files in os.walk(src_dir):
        for fname in files:
            if not fname.endswith('.cpp'):
                continue
            fpath = os.path.join(root, fname)
            try:
                with open(fpath, 'r', encoding='utf-8', errors='replace') as f:
                    for i, line in enumerate(f, 1):
                        if 'IMPL_TODO' in line:
                            for m in re.finditer(r'FUN_([0-9a-fA-F]+)', line):
                                addr = m.group(1).lower()
                                rel = os.path.relpath(fpath, PROJECT_ROOT)
                                blockers[addr].append({
                                    'file': rel,
                                    'line': i,
                                    'context': line.strip()[:200],
                                })
            except:
                pass
    
    return blockers


# ============================================================================
# Main
# ============================================================================

def main():
    import argparse
    parser = argparse.ArgumentParser(description='Identify unnamed FUN_ functions')
    parser.add_argument('--dll', default='Engine', help='DLL name (default: Engine)')
    parser.add_argument('--blockers-only', action='store_true', help='Only show functions that block TODOs')
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    args = parser.parse_args()

    exports_dir = os.path.join(PROJECT_ROOT, 'ghidra', 'exports', args.dll)
    
    # Parse all unnamed and thunk functions
    unnamed = parse_functions(os.path.join(exports_dir, '_unnamed.cpp'))
    thunks = parse_functions(os.path.join(exports_dir, '_thunks.cpp'))
    all_funcs = unnamed + thunks
    
    # Find blocker references
    blockers = find_blocker_refs()
    
    # Classify each function
    results = []
    for func in all_funcs:
        cls = classify_function(func)
        addr_lower = func['addr'].lower()
        blocking = blockers.get(addr_lower, [])
        
        entry = {
            'address': func['addr'],
            'name': func['name'],
            'size': func['size'],
            'classification': cls['classification'],
            'stride': cls['stride'],
            'blocks_todos': len(blocking),
            'blocked_locations': blocking,
        }
        
        if args.blockers_only and not blocking:
            continue
        results.append(entry)
    
    # Sort by blocks_todos descending, then by address
    results.sort(key=lambda x: (-x['blocks_todos'], x['address']))
    
    if args.json:
        print(json.dumps(results, indent=2))
    else:
        # Summary
        classifications = defaultdict(int)
        for r in results:
            classifications[r['classification']] += 1
        
        print(f"{'='*70}")
        print(f"FUN_ Identifier Report — {args.dll}.dll")
        print(f"{'='*70}")
        print(f"Total unnamed functions: {len(all_funcs)}")
        print(f"Classified: {len(all_funcs) - classifications.get('unknown', 0)}")
        print(f"Unknown: {classifications.get('unknown', 0)}")
        print()
        
        print("Classification breakdown:")
        for cls, count in sorted(classifications.items(), key=lambda x: -x[1]):
            print(f"  {cls}: {count}")
        print()
        
        # Show blocker functions
        blocker_funcs = [r for r in results if r['blocks_todos'] > 0]
        if blocker_funcs:
            print(f"{'='*70}")
            print(f"Functions blocking IMPL_TODOs ({len(blocker_funcs)} functions)")
            print(f"{'='*70}")
            for r in blocker_funcs:
                stride_info = f" (stride={r['stride']})" if r['stride'] else ""
                print(f"\n  {r['name']} @ 0x{r['address']} — {r['size']}b")
                print(f"  Classification: {r['classification']}{stride_info}")
                print(f"  Blocks {r['blocks_todos']} TODO(s):")
                for loc in r['blocked_locations']:
                    print(f"    {loc['file']}:{loc['line']}")

    return results


if __name__ == '__main__':
    main()
