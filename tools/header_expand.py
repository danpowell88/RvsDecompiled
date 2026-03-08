#!/usr/bin/env python3
"""
header_expand.py — Extract member fields from SDK EngineClasses.h
and replace opaque data blobs in our EngineClasses.h with real fields.

Phase 1: AActor — replace OpaqueActorData[0x394 - sizeof(UObject)]
Phase 2: APawn  — add member fields (currently has none)

Also adds virtual method declarations and native C++ methods needed
for .bak file compilation (UnActor.cpp.bak, UnPawn.cpp.bak, etc.)
"""

import re
import sys
import os

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SDK_HEADER = os.path.join(PROJECT_ROOT, "sdk", "Raven_Shield_C_SDK", "inc", "EngineClasses.h")
OUR_HEADER = os.path.join(PROJECT_ROOT, "src", "engine", "EngineClasses.h")


def extract_sdk_class_body(class_name, parent_class):
    """
    Extract the full class body from the SDK header.
    Returns (member_fields_text, virtual_methods, native_methods).
    
    member_fields_text: raw lines of member field declarations
    virtual_methods: list of virtual method declaration strings
    native_methods: list of non-virtual, non-exec, non-event method strings
    """
    with open(SDK_HEADER, "r", encoding="utf-8", errors="replace") as f:
        content = f.read()

    # Find class definition — SDK uses DLL_IMPORT
    # Use a brace-counting approach since regex with nested braces is unreliable
    pattern = rf'class DLL_IMPORT {re.escape(class_name)}\s*:\s*public\s+{re.escape(parent_class)}\s*\{{'
    m = re.search(pattern, content)
    if not m:
        print(f"  ERROR: Could not find 'class DLL_IMPORT {class_name} : public {parent_class}' in SDK header")
        return None, None, None

    start = m.end()
    depth = 1
    pos = start
    while depth > 0 and pos < len(content):
        if content[pos] == '{':
            depth += 1
        elif content[pos] == '}':
            depth -= 1
        pos += 1

    body = content[start:pos - 1]  # everything between { and }
    lines = body.split('\n')

    member_fields = []
    virtual_methods = []
    native_methods = []  # non-virtual, non-exec, non-event
    in_private = False

    for line in lines:
        stripped = line.strip()
        if not stripped:
            continue
        if stripped == 'public:':
            in_private = False
            continue
        if stripped == 'private:':
            in_private = True
            continue
        if in_private:
            continue

        # Strip trailing comment (SDK adds //CPF_... or //0 annotations)
        code_part = stripped.split('//')[0].strip() if '//' in stripped else stripped

        # Check what kind of line this is
        is_function = '(' in code_part
        is_virtual = code_part.startswith('virtual ')
        is_exec = code_part.startswith('void exec') and is_function
        is_event = False
        if is_function:
            for ret_type in ['void event', 'DWORD event', 'INT event',
                             'FVector event', 'FRotator event', 'FString event']:
                if code_part.startswith(ret_type):
                    is_event = True
                    break
            # Also catch 'class AActor * eventXxx' style
            if not is_event and ' event' in code_part and 'class ' in code_part:
                is_event = True
        is_static_class = 'StaticClass' in code_part or 'PrivateStaticClass' in code_part

        if is_static_class:
            continue

        if is_virtual and is_function:
            # Virtual method declaration
            decl = code_part.rstrip(';').strip()
            virtual_methods.append(decl)
        elif is_exec or is_event:
            # Skip — handled by DECLARE_FUNCTION macros and event thunks
            pass
        elif is_function:
            # Non-virtual method (constructor, operator, native helper)
            decl = code_part.rstrip(';').strip()
            native_methods.append(decl)
        elif ';' in code_part:
            # Member field declaration
            field_decl = code_part.rstrip(';').strip() + ';'
            member_fields.append(field_decl)

    return member_fields, virtual_methods, native_methods


def format_member_fields(fields, indent='\t'):
    """Format member fields as C++ code."""
    lines = []
    prev_type = None
    for field in fields:
        # Detect type changes for readability grouping
        # Extract the leading type keyword
        type_match = re.match(r'^(BYTE|INT|BITFIELD|FLOAT|class|struct|TArray|FName|FString)\b', field)
        curr_type = type_match.group(1) if type_match else 'other'
        if prev_type and curr_type != prev_type and prev_type != 'BITFIELD' and curr_type != 'BITFIELD':
            pass  # Could add blank line between type groups
        prev_type = curr_type
        lines.append(f'{indent}{field}')
    return '\n'.join(lines)


def format_virtual_methods(methods, indent='\t'):
    """Format virtual method declarations, filtering DECLARE_CLASS-provided ones
    and UObject-inherited virtuals."""
    lines = []
    for m in methods:
        # Skip methods already provided by DECLARE_CLASS
        if any(m.startswith(provided.rstrip(')') ) for provided in DECLARE_CLASS_PROVIDED):
            continue
        # Normalize: remove 'CDECL' for comparison
        simplified = m.replace(' CDECL ', ' ')
        if any(simplified.startswith(provided.rstrip(')')) for provided in DECLARE_CLASS_PROVIDED):
            continue
        # Skip methods already declared in UObject base class
        # Extract the method name from "virtual RetType MethodName(...)"
        name_match = re.search(r'virtual\s+(?:\w+\s+\*?\s*)*?(\w+)\s*\(', m)
        if name_match:
            method_name = name_match.group(1)
            if method_name in UOBJECT_VIRTUALS:
                continue
        lines.append(f'{indent}{m};')
    return '\n'.join(lines)


def format_native_methods(methods, indent='\t'):
    """Format native (non-virtual, non-exec, non-event) method declarations.
    Filter out operators and constructors that DECLARE_CLASS or event thunks handle."""
    lines = []
    for m in methods:
        # Skip operator new (defined by DECLARE_CLASS)
        if 'operator new' in m:
            continue
        # Skip operator= (not needed for compilation)
        if 'operator=' in m:
            continue
        # Skip copy constructor (handled separately)
        if m.startswith('AActor(class AActor const') or m.startswith('APawn(class APawn const'):
            continue
        # Skip InternalConstructor (provided by DECLARE_CLASS)
        if 'InternalConstructor' in m:
            continue
        # Skip StaticClass (provided by DECLARE_CLASS)
        if 'StaticClass' in m:
            continue
        lines.append(f'{indent}{m};')
    return '\n'.join(lines)


# Methods already provided by DECLARE_CLASS macro — filter these from SDK output
DECLARE_CLASS_PROVIDED = {
    'virtual ~AActor()',
    'virtual ~APawn()',
    'virtual ~AController()',
    'virtual ~APlayerController()',
    'static void InternalConstructor(void *)',
    'static void CDECL InternalConstructor(void *)',
}

# Methods already declared in UObject (parent of AActor) — don't redeclare
# These are inherited and overriding them with different default params causes issues
UOBJECT_VIRTUALS = {
    'ProcessEvent',       # has default param void*=NULL in UObject
    'PostLoad',
    'Destroy',
    'Serialize',
    'IsPendingKill',
    'InitExecution',
    'PostEditChange',
    'IsPendingDelete',
    'NetDirty',
    'ProcessRemoteFunction',
    'ProcessState',
}


def patch_aactor(our_content):
    """Add member fields, virtual methods, and native methods to AActor.
    Currently AActor has DECLARE_CLASS followed immediately by DECLARE_FUNCTION.
    We insert member fields between them."""
    print("=== Extracting AActor from SDK ===")
    fields, virtuals, natives = extract_sdk_class_body("AActor", "UObject")
    if fields is None:
        return our_content

    print(f"  {len(fields)} member fields")
    print(f"  {len(virtuals)} virtual methods")
    print(f"  {len(natives)} native methods")

    # Find insertion point: after DECLARE_CLASS(AActor,...) line,
    # before the first DECLARE_FUNCTION
    aactor_pattern = r'(\tDECLARE_CLASS\(AActor,UObject,[^)]+\)\n)'
    match = re.search(aactor_pattern, our_content)
    if not match:
        print("  ERROR: Could not find AActor DECLARE_CLASS")
        return our_content

    insert_after = match.end()

    # Check if member fields already exist (idempotency)
    next_chunk = our_content[insert_after:insert_after + 200]
    if 'BYTE Physics;' in next_chunk:
        print("  Member fields already present, skipping")
        return our_content

    # Build insertion text
    insert_text = '\t// Member fields (extracted from SDK class definition)\n'
    insert_text += format_member_fields(fields) + '\n'
    insert_text += '\n'
    insert_text += '\t// Virtual methods\n'
    insert_text += format_virtual_methods(virtuals) + '\n'
    insert_text += '\n'
    insert_text += '\t// Native C++ methods\n'
    insert_text += format_native_methods(natives) + '\n'
    insert_text += '\n'

    our_content = our_content[:insert_after] + insert_text + our_content[insert_after:]
    print("  Inserted AActor member fields and method declarations")

    # Remove old "AActor virtual interface" section at the bottom of AActor
    # This contains a handful of virtual methods that are now in the SDK-extracted section
    old_interface = re.search(
        r'\n\t// AActor virtual interface \(from AActor\.h\)\.\n.*?\n\};',
        our_content, re.DOTALL
    )
    if old_interface:
        # Replace with just the closing brace
        our_content = our_content[:old_interface.start()] + '\n};\n' + our_content[old_interface.end() + 1:]
        print("  Removed old AActor virtual interface block (now in SDK section)")

    return our_content


def patch_apawn(our_content):
    """Add member fields to APawn (currently has none)."""
    print("\n=== Extracting APawn from SDK ===")
    fields, virtuals, natives = extract_sdk_class_body("APawn", "AActor")
    if fields is None:
        return our_content

    print(f"  {len(fields)} member fields")
    print(f"  {len(virtuals)} virtual methods")
    print(f"  {len(natives)} native methods")

    # APawn currently has no member fields — just DECLARE_CLASS followed by DECLARE_FUNCTION
    # We need to insert member fields + virtual/native methods after DECLARE_CLASS
    # and before the first DECLARE_FUNCTION

    # Find the insertion point: after DECLARE_CLASS(APawn,AActor,...) line
    apawn_pattern = r'(\tDECLARE_CLASS\(APawn,AActor,[^)]+\)\n)'
    match = re.search(apawn_pattern, our_content)
    if not match:
        print("  ERROR: Could not find APawn DECLARE_CLASS")
        return our_content

    insert_after = match.end()

    # Build insertion text
    insert_text = '\t// Member fields (extracted from SDK class definition)\n'
    insert_text += format_member_fields(fields) + '\n'
    insert_text += '\n'
    insert_text += '\t// Virtual methods\n'
    insert_text += format_virtual_methods(virtuals) + '\n'
    insert_text += '\n'
    insert_text += '\t// Native C++ methods\n'
    insert_text += format_native_methods(natives) + '\n'
    insert_text += '\n'

    our_content = our_content[:insert_after] + insert_text + our_content[insert_after:]
    print("  Inserted APawn member fields and method declarations")

    return our_content


def main():
    print(f"SDK header: {SDK_HEADER}")
    print(f"Our header: {OUR_HEADER}")
    print()

    with open(OUR_HEADER, 'r', encoding='utf-8') as f:
        content = f.read()

    content = patch_aactor(content)
    content = patch_apawn(content)

    with open(OUR_HEADER, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"\nDone. Updated {OUR_HEADER}")


if __name__ == "__main__":
    main()
