"""
repair_ordinals.py — Fix IMPLEMENT_FUNCTION ordinals in UnScript.cpp

Based on NATIVE_ORDINALS.md analysis. Fixes 42 wrong ordinals, removes 2
conflicting bare-native registrations, and adds 6 missing IMPLEMENT_FUNCTION
macros with correct ordinals from Core.u.
"""

import re
import sys

FILE = r"c:\Users\danpo\Desktop\rvs\src\core\UnScript.cpp"

# ===== 42 ordinal corrections =====
# Format: (function_name, wrong_ordinal_pattern, correct_ordinal)
FIXES = [
    # Byte operators (swapped)
    ("execMultiplyEqual_ByteByte", r"137", "133"),
    ("execDivideEqual_ByteByte", r"138", "134"),
    ("execAddAdd_PreByte", r"139", "137"),
    ("execSubtractSubtract_PreByte", r"140", "138"),
    ("execAddAdd_Byte", r"133", "139"),
    ("execSubtractSubtract_Byte", r"134", "140"),

    # Int assignment operators (swapped)
    ("execMultiplyEqual_IntFloat", r"165", "159"),
    ("execDivideEqual_IntFloat", r"166", "160"),
    ("execAddEqual_IntInt", r"159", "161"),
    ("execSubtractEqual_IntInt", r"160", "162"),
    ("execAddAdd_Int", r"161", "165"),
    ("execSubtractSubtract_Int", r"162", "166"),

    # String operators (shifted)
    ("execLess_StringString", r"197", "115"),
    ("execGreater_StringString", r"198", "116"),
    ("execLessEqual_StringString", r"199", "120"),
    ("execGreaterEqual_StringString", r"200", "121"),
    ("execEqualEqual_StringString", r"201", "122"),
    ("execNotEqual_StringString", r"202", "123"),
    ("execComplementEqual_StringString", r"203", "124"),
    ("execLen", r"204", "125"),
    ("execInStr", r"205", "126"),
    ("execMid", r"206", "127"),
    ("execLeft", r"207", "128"),
    ("execRight", r"208", "234"),
    ("execCaps", r"209", "235"),

    # Vector operators (shifted +1)
    ("execDot_VectorVector", r"220", "219"),
    ("execCross_VectorVector", r"221", "220"),
    ("execMultiplyEqual_VectorFloat", r"222", "221"),
    ("execDivideEqual_VectorFloat", r"223", "222"),
    ("execAddEqual_VectorVector", r"224", "223"),
    ("execSubtractEqual_VectorVector", r"225", "224"),
    ("execVSize", r"225\+1", "225"),
    ("execNormal", r"226\+1", "226"),

    # Rotator operators (shifted)
    ("execMultiply_RotatorFloat", r"313", "287"),
    ("execMultiply_FloatRotator", r"314", "288"),
    ("execDivide_RotatorFloat", r"315", "289"),
    ("execMultiplyEqual_RotatorFloat", r"318", "290"),
    ("execDivideEqual_RotatorFloat", r"319", "291"),
    ("execAddEqual_RotatorRotator", r"320", "318"),
    ("execSubtractEqual_RotatorRotator", r"321", "319"),
    ("execNotEqual_RotatorRotator", r"203\+100", "203"),

    # Other
    ("execWarn", r"232\+3", "232"),
]

# Bare native registrations to REMOVE (iNative=0 in Core.u, conflicting ordinals)
REMOVE_REGISTRATIONS = [
    ("execDynamicLoadObject", r"232"),   # conflicts with Warn=232
    ("execLocalize", r"238"),            # conflicts with RemoveInvalidChars=238
]

# Missing IMPLEMENT_FUNCTION macros to ADD after function body
ADD_MACROS = [
    ("execSubtract_PreFloat", "169"),
    ("execSubtract_PreVector", "211"),
    ("execInvert", "227"),
    ("execClassIsChildOf", "258"),
    ("execRotRand", "320"),
]


def main():
    with open(FILE, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content
    changes = 0
    errors = []

    # Phase 1: Fix wrong ordinals
    for func_name, wrong_pattern, correct_ordinal in FIXES:
        pattern = re.compile(
            r'(IMPLEMENT_FUNCTION\(\s*UObject\s*,\s*)' + wrong_pattern +
            r'(\s*,\s*' + re.escape(func_name) + r'\s*\))',
            re.MULTILINE
        )
        match = pattern.search(content)
        if match:
            old_text = match.group(0)
            new_text = f"IMPLEMENT_FUNCTION( UObject, {correct_ordinal}, {func_name} )"
            content = content[:match.start()] + new_text + content[match.end():]
            changes += 1
            print(f"  FIXED: {func_name}: {old_text.strip()} -> ordinal {correct_ordinal}")
        else:
            errors.append(f"  NOT FOUND: {func_name} with ordinal pattern {wrong_pattern}")

    # Phase 2: Remove conflicting bare-native registrations
    for func_name, ordinal_pattern in REMOVE_REGISTRATIONS:
        pattern = re.compile(
            r'IMPLEMENT_FUNCTION\(\s*UObject\s*,\s*' + ordinal_pattern +
            r'\s*,\s*' + re.escape(func_name) + r'\s*\)\s*;[^\n]*\n',
            re.MULTILINE
        )
        match = pattern.search(content)
        if match:
            old_text = match.group(0).strip()
            # Comment it out instead of removing (preserves context)
            content = content[:match.start()] + f"// REMOVED: bare native (iNative=0 in Core.u) — {old_text}\n" + content[match.end():]
            changes += 1
            print(f"  REMOVED: {func_name} (bare native, conflicting ordinal)")
        else:
            errors.append(f"  NOT FOUND for removal: {func_name} with ordinal {ordinal_pattern}")

    # Phase 3: Add missing IMPLEMENT_FUNCTION macros
    for func_name, ordinal in ADD_MACROS:
        # Check if already has IMPLEMENT_FUNCTION
        existing = re.search(
            r'IMPLEMENT_FUNCTION\(\s*UObject\s*,\s*\d+\s*,\s*' + re.escape(func_name) + r'\s*\)',
            content
        )
        if existing:
            print(f"  SKIP: {func_name} already has IMPLEMENT_FUNCTION")
            continue

        # Find the function's closing unguardexecSlow; or unguard; and add after
        # Look for the function body end pattern
        func_pattern = re.compile(
            r'(void UObject::' + re.escape(func_name) + r'\(.*?\n'
            r'(?:.*?\n)*?'
            r'\s*unguardexecSlow;\s*\n\})',
            re.MULTILINE
        )
        match = func_pattern.search(content)
        if match:
            insert_pos = match.end()
            macro = f"\nIMPLEMENT_FUNCTION( UObject, {ordinal}, {func_name} );\n"
            content = content[:insert_pos] + macro + content[insert_pos:]
            changes += 1
            print(f"  ADDED: IMPLEMENT_FUNCTION( UObject, {ordinal}, {func_name} );")
        else:
            errors.append(f"  NOT FOUND for add: {func_name} body not found")

    # Report
    print(f"\n--- Summary ---")
    print(f"Changes applied: {changes}")
    print(f"Errors: {len(errors)}")
    for e in errors:
        print(e)

    if changes > 0:
        with open(FILE, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"\nFile written: {FILE}")
    else:
        print("\nNo changes made.")


if __name__ == "__main__":
    main()
