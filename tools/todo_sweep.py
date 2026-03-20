#!/usr/bin/env python3
"""
todo_sweep.py - Scan all IMPL_TODO functions for promotability.

Reads each IMPL_TODO, checks the function body, and categorizes:
1. PROMOTABLE_MATCH - Body is implemented, just needs verification
2. PROMOTABLE_EMPTY - Body is trivially empty (return only)  
3. HAS_BODY - Has significant code but still marked TODO
4. STUB_ONLY - Only has a stub/placeholder
5. NEEDS_HELPER - References FUN_ or unknown vtable calls
6. BLOCKED - Has explicit blocker comment

Usage:
    python tools/todo_sweep.py [--promotable-only] [--json]
"""

import re
import os
import sys
from collections import defaultdict

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)


def scan_impl_todos():
    """Find all IMPL_TODO occurrences and analyze surrounding function code."""
    src_dir = os.path.join(PROJECT_ROOT, 'src')
    results = []
    
    for root, dirs, files in os.walk(src_dir):
        for fname in files:
            if not fname.endswith('.cpp'):
                continue
            fpath = os.path.join(root, fname)
            try:
                with open(fpath, 'r', encoding='utf-8', errors='replace') as f:
                    lines = f.readlines()
            except:
                continue
            
            for i, line in enumerate(lines):
                m = re.match(r'^\s*IMPL_TODO\s*\(\s*"(.+?)"\s*\)', line)
                if not m:
                    continue
                
                reason = m.group(1)
                todo_line = i  # 0-based
                
                # Extract the function body: look forward for the function definition
                # Usually IMPL_TODO is followed by the function signature and body
                func_start = None
                func_name = None
                brace_depth = 0
                func_body_lines = []
                in_body = False
                
                for j in range(i + 1, min(i + 500, len(lines))):
                    l = lines[j]
                    
                    # Look for function signature
                    if func_start is None:
                        sig = re.match(r'^(?:void|int|UBOOL|FLOAT|FVector|FRotator|BYTE|DWORD|FString|FName|UObject|AActor|APawn|class|static|bool|unsigned|signed|long|short|char|double|INT|BITFIELD)\s', l)
                        if sig or ('{' in l and not l.strip().startswith('//')):
                            func_start = j
                    
                    if func_start is not None:
                        func_body_lines.append(l)
                        brace_depth += l.count('{') - l.count('}')
                        if brace_depth > 0:
                            in_body = True
                        if in_body and brace_depth <= 0:
                            break
                
                # Extract function name from signature
                for bl in func_body_lines[:3]:
                    nm = re.search(r'(\w+::[\w~]+|\w+)\s*\(', bl)
                    if nm:
                        func_name = nm.group(1)
                        break
                
                body_text = ''.join(func_body_lines)
                body_size = len(body_text)
                
                # Analyze the body
                category = classify_body(body_text, reason)
                
                rel = os.path.relpath(fpath, PROJECT_ROOT)
                results.append({
                    'file': rel,
                    'line': todo_line + 1,  # 1-based
                    'func_name': func_name,
                    'reason': reason,
                    'category': category,
                    'body_size': body_size,
                    'body_lines': len(func_body_lines),
                    'body_preview': body_text[:300].strip(),
                })
    
    return results


def classify_body(body_text, reason):
    """Classify a TODO function body."""
    # Remove comments
    clean = re.sub(r'//.*', '', body_text)
    clean = re.sub(r'/\*.*?\*/', '', clean, flags=re.DOTALL)
    
    # Check for FUN_ references (blocked by unknown helpers)
    if re.search(r'FUN_[0-9a-fA-F]+', body_text):
        return 'NEEDS_HELPER'
    
    # Check for vtable references  
    if re.search(r'vtable\[', body_text, re.IGNORECASE):
        return 'NEEDS_VTABLE'
    
    # Check for explicit blocker comments
    if re.search(r'blocked|BLOCKED|unknown.*struct|unknown.*layout', reason):
        return 'BLOCKED'
    
    # Check for "stub" or placeholder patterns
    stub_patterns = [
        r'appErrorf\s*\(\s*TEXT\s*\(\s*"Stub"\s*\)',  # Stub error call
        r'//\s*TODO',
        r'//\s*STUB',
    ]
    for pat in stub_patterns:
        if re.search(pat, body_text, re.IGNORECASE):
            # But check if there's significant code too
            code_lines = [l for l in clean.split('\n') 
                         if l.strip() and not l.strip().startswith('{') and not l.strip().startswith('}')]
            if len(code_lines) < 5:
                return 'STUB_ONLY'
    
    # Count meaningful code lines (not just braces/whitespace/comments)
    code_lines = []
    for l in clean.split('\n'):
        l = l.strip()
        if l and l not in ('{', '}', 'guard;', 'unguard;') and not l.startswith('//'):
            code_lines.append(l)
    
    # Trivially empty
    if len(code_lines) <= 2:  # just signature + return
        return 'PROMOTABLE_EMPTY'
    
    # Has real implementation code
    has_assignments = bool(re.search(r'\w+\s*=\s*', clean))
    has_calls = bool(re.search(r'\w+\s*\(', clean))
    has_loops = bool(re.search(r'\b(for|while|do)\b', clean))
    has_conditionals = bool(re.search(r'\b(if|switch|case)\b', clean))
    
    complexity = sum([has_assignments, has_calls, has_loops, has_conditionals])
    
    if len(code_lines) > 10 and complexity >= 2:
        # Substantial implementation - check if it looks complete
        # Heuristic: if it has guard/unguard and multiple operations, likely implemented
        has_guard = 'guard' in body_text.lower()
        if has_guard and complexity >= 3:
            return 'PROMOTABLE_MATCH'
        return 'HAS_BODY'
    
    if len(code_lines) > 3:
        return 'HAS_BODY'
    
    return 'STUB_ONLY'


def main():
    import argparse
    parser = argparse.ArgumentParser(description='Sweep IMPL_TODOs for promotability')
    parser.add_argument('--promotable-only', action='store_true')
    parser.add_argument('--json', action='store_true')
    args = parser.parse_args()
    
    todos = scan_impl_todos()
    
    if args.promotable_only:
        todos = [t for t in todos if t['category'].startswith('PROMOTABLE')]
    
    # Group by category
    by_cat = defaultdict(list)
    for t in todos:
        by_cat[t['category']].append(t)
    
    print(f"{'='*70}")
    print(f"IMPL_TODO Promotion Sweep Report")
    print(f"{'='*70}")
    print(f"Total IMPL_TODOs found: {len(todos)}")
    print()
    
    print("Category Summary:")
    cat_order = ['PROMOTABLE_MATCH', 'PROMOTABLE_EMPTY', 'HAS_BODY', 'STUB_ONLY', 'NEEDS_HELPER', 'NEEDS_VTABLE', 'BLOCKED']
    for cat in cat_order:
        items = by_cat.get(cat, [])
        if items:
            total_bytes = sum(i['body_size'] for i in items)
            print(f"  {cat:20s}: {len(items):3d} functions ({total_bytes:,d} bytes)")
    print()
    
    # Details per category
    for cat in cat_order:
        items = by_cat.get(cat, [])
        if not items:
            continue
        print(f"\n{'='*50}")
        print(f"  {cat}")
        print(f"{'='*50}")
        for t in sorted(items, key=lambda x: -x['body_size']):
            print(f"\n  {t['func_name'] or '???'} ({t['body_size']}b)")
            print(f"    File: {t['file']}:{t['line']}")
            print(f"    Reason: {t['reason'][:100]}")
            if cat in ('PROMOTABLE_MATCH', 'HAS_BODY'):
                preview = t['body_preview'][:150].replace('\n', ' | ')
                print(f"    Preview: {preview}")
    
    if args.json:
        import json
        print(json.dumps(todos, indent=2))


if __name__ == '__main__':
    main()
