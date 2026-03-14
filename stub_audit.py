import os
import re
from collections import defaultdict
from pathlib import Path

def extract_functions(content):
    """Extract function definitions and their bodies from C++ code."""
    functions = []
    
    # Simplified pattern to find function definitions
    pattern = r'(?:FORCEINLINE|inline|virtual|static|extern|const)?\s*(?:void|int|bool|float|UBOOL|DWORD|UINT|FVector|FRotator|FString|FName|[\w:]+[\*&]?)\s+([\w:]+)\s*\([^)]*\)\s*(?:const\s*)?(?:override\s*)?{'
    
    for match in re.finditer(pattern, content, re.MULTILINE):
        func_name = match.group(1)
        start_pos = match.end() - 1  # Position of opening brace
        
        # Find matching closing brace
        brace_count = 1
        pos = start_pos + 1
        
        while pos < len(content) and brace_count > 0:
            if content[pos] == '{':
                brace_count += 1
            elif content[pos] == '}':
                brace_count -= 1
            pos += 1
        
        if brace_count == 0:
            body = content[start_pos+1:pos-1]
            functions.append({
                'name': func_name,
                'body': body,
                'start': start_pos,
                'end': pos
            })
    
    return functions

def is_stub(body):
    """Determine if a function body is a stub."""
    # Remove comments
    body_cleaned = re.sub(r'//.*?\n', '\n', body)
    body_cleaned = re.sub(r'/\*.*?\*/', '', body_cleaned, flags=re.DOTALL)
    
    # Normalize whitespace
    body_normalized = re.sub(r'\s+', ' ', body_cleaned).strip()
    
    # Check for stub patterns
    stub_patterns = [
        r'^\s*\$',  # Empty
        r'^guard\s*\([^)]*\)\s*;\s*unguard\s*;\$',  # Only guard/unguard
        r'^(?:guard\s*\([^)]*\)\s*;)?\s*return\s+(?:0|false|NULL|nullptr|TRUE|FALSE|void)\s*;(?:\s*unguard\s*;)?\$',  # Return only
        r'^appUnimplemented\s*\(\s*\)\s*;\$',  # Only appUnimplemented
        r'^// TODO',  # Only TODO
    ]
    
    if not body_normalized:
        return True
    
    for pattern in stub_patterns:
        if re.match(pattern.replace('\$', '$'), body_normalized, re.IGNORECASE | re.DOTALL):
            return True
    
    return False

def analyze_file(filepath):
    """Analyze a single .cpp file for stubs."""
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
    except Exception as e:
        return None
    
    functions = extract_functions(content)
    stubs = []
    divergence_on_stubs = []
    
    for func in functions:
        if is_stub(func['body']):
            stubs.append(func['name'])
            
            # Check for DIVERGENCE comments
            start_line = content[:func['start']].count('\n')
            search_start = max(0, start_line - 3)
            search_end = min(len(content.split('\n')), start_line + 10)
            lines = content.split('\n')
            context = '\n'.join(lines[search_start:search_end])
            
            if 'DIVERGENCE' in context:
                divergence_on_stubs.append(func['name'])
    
    return {
        'path': filepath,
        'total_functions': len(functions),
        'stub_count': len(stubs),
        'stubs': stubs,
        'divergence_on_stubs': divergence_on_stubs
    }

# Get all .cpp files
src_dir = r"C:\Users\danpo\Desktop\rvs\src"
cpp_files = list(Path(src_dir).rglob("*.cpp"))

# Organize by module
results_by_module = defaultdict(lambda: {
    'files': [],
    'total_functions': 0,
    'total_stubs': 0
})

for cpp_file in sorted(cpp_files):
    result = analyze_file(str(cpp_file))
    if result:
        parts = cpp_file.parts
        if len(parts) > 3:
            module = parts[-3]
        else:
            module = "Unknown"
        
        results_by_module[module]['files'].append(result)
        results_by_module[module]['total_functions'] += result['total_functions']
        results_by_module[module]['total_stubs'] += result['stub_count']

# Print summary
print("=" * 100)
print("COMPREHENSIVE STUB AUDIT - ALL .CPP FILES")
print("=" * 100)

grand_total_funcs = 0
grand_total_stubs = 0

for module in sorted(results_by_module.keys()):
    data = results_by_module[module]
    module_total_funcs = data['total_functions']
    module_total_stubs = data['total_stubs']
    
    grand_total_funcs += module_total_funcs
    grand_total_stubs += module_total_stubs
    
    if module_total_stubs > 0 or module_total_funcs > 0:
        print(f"\n{'=' * 100}")
        print(f"MODULE: {module}")
        print(f"  Total Functions: {module_total_funcs}")
        print(f"  Total Stubs: {module_total_stubs} ({100*module_total_stubs//max(1, module_total_funcs)}%)")
        print(f"{'=' * 100}")
        
        for file_result in sorted(data['files'], key=lambda x: x['stub_count'], reverse=True):
            filename = Path(file_result['path']).name
            stub_pct = 100 * file_result['stub_count'] // max(1, file_result['total_functions'])
            
            if file_result['stub_count'] > 0 or file_result['total_functions'] > 0:
                print(f"\n  {filename}")
                print(f"    Functions: {file_result['total_functions']}, Stubs: {file_result['stub_count']} ({stub_pct}%)")
                
                if file_result['stubs']:
                    print(f"    Stub Functions:")
                    for stub_name in sorted(file_result['stubs'])[:20]:
                        divergence_marker = " [DIVERGENCE ISSUE]" if stub_name in file_result['divergence_on_stubs'] else ""
                        print(f"      - {stub_name}{divergence_marker}")
                    if len(file_result['stubs']) > 20:
                        print(f"      ... and {len(file_result['stubs']) - 20} more")
                
                if file_result['divergence_on_stubs']:
                    print(f"    ⚠️  DIVERGENCE COMMENTS ON STUBS: {', '.join(file_result['divergence_on_stubs'])}")

print(f"\n\n{'=' * 100}")
print(f"GRAND TOTAL ACROSS ALL FILES")
print(f"{'=' * 100}")
print(f"Total Functions: {grand_total_funcs}")
print(f"Total Stubs: {grand_total_stubs} ({100*grand_total_stubs//max(1, grand_total_funcs)}%)")
print(f"Expected Implementation Work: ~{grand_total_stubs} functions")
