#!/usr/bin/env python3
"""
vtable_mapper.py - Map vtable slot numbers to named methods using Ghidra exports.

For each class found in _global.cpp, this tool:
1. Finds all known exported methods and their addresses
2. Reads the .def file to find all mangled exports with ordinals  
3. Cross-references IMPL_TODO mentions of "vtable[N]" or "vtable slot N"
4. Uses the _global.cpp vftable entries (if present) to map slots

Usage:
    python tools/vtable_mapper.py [--dll Engine] [--class APawn]
"""

import re
import os
import sys
import json
from collections import defaultdict

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)


def find_vtable_refs_in_todos():
    """Scan IMPL_TODOs for vtable slot references."""
    src_dir = os.path.join(PROJECT_ROOT, 'src')
    refs = []  # (file, line, class_hint, slot_offset, slot_index, context)
    
    for root, dirs, files in os.walk(src_dir):
        for fname in files:
            if not fname.endswith('.cpp'):
                continue
            fpath = os.path.join(root, fname)
            try:
                with open(fpath, 'r', encoding='utf-8', errors='replace') as f:
                    for i, line in enumerate(f, 1):
                        if 'IMPL_TODO' not in line and '// IMPL_TODO' not in line:
                            continue
                        # Match patterns like "vtable[0x62]", "vtable[97]", "vtable slot 98"
                        for m in re.finditer(r'vtable\[(?:0x([0-9a-fA-F]+)|(\d+))\]', line):
                            if m.group(1):
                                offset = int(m.group(1), 16)
                            else:
                                offset = int(m.group(2))
                            slot = offset // 4 if offset > 100 else offset  # heuristic: large = byte offset
                            
                            # Try to infer class from context  
                            cls_match = re.search(r'(A\w+|U\w+)\s+vtable|(\w+)\s+vtable\[', line)
                            cls_hint = cls_match.group(1) or cls_match.group(2) if cls_match else None
                            
                            rel = os.path.relpath(fpath, PROJECT_ROOT)
                            refs.append({
                                'file': rel,
                                'line': i,
                                'class_hint': cls_hint,
                                'byte_offset': offset if offset > 100 else offset * 4,
                                'slot_index': slot,
                                'context': line.strip()[:200],
                            })
                        
                        # Also match "vtable+0xNN" or "vtable[0xNN/4]"
                        for m in re.finditer(r'vtable\+?(0x[0-9a-fA-F]+)(?:/4)?', line):
                            offset = int(m.group(1), 16)
                            slot = offset // 4
                            cls_match = re.search(r'(A\w+|U\w+)\s', line)
                            cls_hint = cls_match.group(1) if cls_match else None
                            
                            rel = os.path.relpath(fpath, PROJECT_ROOT)
                            refs.append({
                                'file': rel,
                                'line': i,
                                'class_hint': cls_hint,
                                'byte_offset': offset,
                                'slot_index': slot,
                                'context': line.strip()[:200],
                            })
            except:
                pass
    
    # Deduplicate
    seen = set()
    unique = []
    for r in refs:
        key = (r['file'], r['line'], r['slot_index'])
        if key not in seen:
            seen.add(key)
            unique.append(r)
    
    return unique


def parse_def_exports(dll_name):
    """Parse the .def file to get all exported function names."""
    src_dir = os.path.join(PROJECT_ROOT, 'src')
    # Search for the .def file
    def_path = None
    for root, dirs, files in os.walk(src_dir):
        for f in files:
            if f.lower() == f'{dll_name.lower()}.def':
                def_path = os.path.join(root, f)
                break
    
    if not def_path:
        return {}
    
    exports = {}  # mangled_name -> ordinal
    with open(def_path, 'r') as f:
        for line in f:
            line = line.strip()
            m = re.match(r'\s*(\?\S+)\s+@(\d+)', line)
            if m:
                exports[m.group(1)] = int(m.group(2))
    
    return exports


def extract_virtual_methods_from_global(dll_name):
    """Extract class::method names and addresses from _global.cpp."""
    global_path = os.path.join(PROJECT_ROOT, 'ghidra', 'exports', dll_name, '_global.cpp')
    if not os.path.isfile(global_path):
        return {}
    
    methods = defaultdict(list)  # class_name -> [(method_name, address)]
    
    with open(global_path, 'r', encoding='utf-8', errors='replace') as f:
        content = f.read()
    
    # Find patterns like: 
    # // Address: XXXXXXXX
    # ... Class::Method ...
    pattern = re.compile(
        r'// Address: ([0-9a-fA-F]+)\n'
        r'// Size: \d+ bytes\n\n'
        r'.*?(\w+)::(\w+)\s*\(',
        re.DOTALL
    )
    
    for m in pattern.finditer(content):
        addr = m.group(1)
        cls = m.group(2)
        method = m.group(3)
        methods[cls].append({
            'method': method,
            'address': addr,
            'full_name': f'{cls}::{method}',
        })
    
    return methods


def extract_virtual_from_header(class_name):
    """Extract virtual method declarations from EngineClasses.h in order."""
    headers = [
        os.path.join(PROJECT_ROOT, 'src', 'Engine', 'Inc', 'EngineClasses.h'),
        os.path.join(PROJECT_ROOT, 'src', 'Core', 'Inc', 'CorePrivate.h'),
    ]
    
    virtuals = []
    for hpath in headers:
        if not os.path.isfile(hpath):
            continue
        with open(hpath, 'r', encoding='utf-8', errors='replace') as f:
            content = f.read()
        
        # Find the class declaration and extract virtual methods
        # Look for "class ... ClassName" section
        class_pattern = re.compile(
            rf'class\s+\w*\s*{re.escape(class_name)}\b.*?\{{(.*?)(?:\n\}};)',
            re.DOTALL
        )
        for cm in class_pattern.finditer(content):
            body = cm.group(1)
            for vm in re.finditer(r'virtual\s+[\w:*&<>\s]+\s+(\w+)\s*\(', body):
                virtuals.append(vm.group(1))
    
    return virtuals


def main():
    import argparse
    parser = argparse.ArgumentParser(description='Map vtable slots to methods')
    parser.add_argument('--dll', default='Engine', help='DLL name')
    parser.add_argument('--class', dest='cls', help='Filter to specific class')
    parser.add_argument('--json', action='store_true')
    args = parser.parse_args()
    
    # Find vtable references in TODOs
    vtable_refs = find_vtable_refs_in_todos()
    
    # Get known methods from Ghidra
    known_methods = extract_virtual_methods_from_global(args.dll)
    
    # Get header-declared virtuals for referenced classes
    referenced_classes = set()
    for ref in vtable_refs:
        if ref['class_hint']:
            referenced_classes.add(ref['class_hint'])
    
    # Build report
    print(f"{'='*70}")
    print(f"Vtable Slot Mapper Report")
    print(f"{'='*70}")
    print(f"Found {len(vtable_refs)} vtable slot references in IMPL_TODOs")
    print()
    
    # Group by class
    by_class = defaultdict(list)
    for ref in vtable_refs:
        cls = ref['class_hint'] or 'Unknown'
        by_class[cls].append(ref)
    
    for cls, refs in sorted(by_class.items()):
        print(f"\n--- {cls} ---")
        
        # Get header virtuals for this class
        header_virtuals = extract_virtual_from_header(cls)
        if header_virtuals:
            print(f"  Header declares {len(header_virtuals)} virtual methods")
        
        # Get known Ghidra methods
        ghidra_methods = known_methods.get(cls, [])
        if ghidra_methods:
            print(f"  Ghidra knows {len(ghidra_methods)} methods")
        
        for ref in sorted(refs, key=lambda x: x['slot_index']):
            slot = ref['slot_index']
            byte_ofs = ref['byte_offset']
            
            # Try to find the method name from header virtual list
            # UObject has ~26 vtable slots, AActor adds more
            suggested = None
            if header_virtuals and slot < len(header_virtuals):
                suggested = header_virtuals[slot]
            
            print(f"\n  Slot {slot} (byte offset 0x{byte_ofs:X}):")
            print(f"    Ref: {ref['file']}:{ref['line']}")
            if suggested:
                print(f"    Suggested method: {cls}::{suggested}")
            else:
                print(f"    No header match found (slot {slot}, {len(header_virtuals)} virtuals known)")
            
            # Check if any Ghidra method at nearby pattern
            # (this is approximate - real vtable extraction would read .rdata)

    if args.json:
        print(json.dumps({
            'vtable_refs': vtable_refs,
            'by_class': {k: v for k, v in by_class.items()},
        }, indent=2, default=str))


if __name__ == '__main__':
    main()
