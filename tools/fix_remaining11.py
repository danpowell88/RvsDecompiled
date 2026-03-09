"""Fix remaining 11 stubs with mangling mismatches.

Issues to fix:
1. FIndexBuffer/FTexture: virtual dtor -> non-virtual (fixes 5 derived dtors)
2. FOrientation::operator=: signature to pass by value
3. FRebuildOptions::operator=: signature to return by value + pass by value
4. APawn::findNewFloor: public -> private access
5. UInputPlanning::StaticConfigName: public static -> private static
6. UCanvas::WrappedPrint: public __thiscall -> private __cdecl
7. URenderResource() ctor: protected -> public
"""
import re
import sys

errors = []

def fix_file(path, replacements, label):
    """Apply replacement pairs to a file."""
    content = open(path).read()
    for old, new, desc in replacements:
        if old not in content:
            errors.append(f"  WARNING: {desc} NOT FOUND in {path}")
            print(f"  WARNING: {desc} NOT FOUND")
            # Show nearby context
            key = desc.split(':')[0] if ':' in desc else desc[:20]
            idx = content.find(key)
            if idx >= 0:
                print(f"  Context: ...{content[max(0,idx-40):idx+80]}...")
            continue
        count = content.count(old)
        if count > 1:
            errors.append(f"  WARNING: {desc} found {count} times (expected 1)")
            print(f"  WARNING: {desc} found {count} times")
        content = content.replace(old, new, 1)
        print(f"  OK: {desc}")
    open(path, 'w').write(content)
    print(f"  Written {path}")

# === EngineClasses.h fixes ===
print("=== EngineClasses.h ===")
fix_file('src/engine/EngineClasses.h', [
    # 1a. FIndexBuffer: virtual dtor -> non-virtual
    ('virtual ~FIndexBuffer() {}', '~FIndexBuffer() {}',
     'FIndexBuffer dtor -> non-virtual'),
    
    # 1b. FTexture: virtual dtor -> non-virtual
    ('virtual ~FTexture() {}', '~FTexture() {}',
     'FTexture dtor -> non-virtual'),
    
    # 4. APawn::findNewFloor: make private
    ('\tINT findNewFloor(class FVector, FLOAT, FLOAT, INT);',
     'private:\n\tINT findNewFloor(class FVector, FLOAT, FLOAT, INT);\npublic:',
     'APawn::findNewFloor -> private'),
    
    # 5. UInputPlanning::StaticConfigName: make private
    ('\tstatic const TCHAR* StaticConfigName();',
     'private:\n\tstatic const TCHAR* StaticConfigName();\npublic:',
     'UInputPlanning::StaticConfigName -> private'),
    
    # 6. UCanvas::WrappedPrint: make private + __cdecl
    ('\tvoid WrappedPrint(ERenderStyle,int &,int &,UFont *,int,const TCHAR*);',
     'private:\n\tvoid __cdecl WrappedPrint(ERenderStyle,int &,int &,UFont *,int,const TCHAR*);\npublic:',
     'UCanvas::WrappedPrint -> private + __cdecl'),
    
    # 7. URenderResource: NO_DEFAULT_CONSTRUCTOR -> public default ctor
    ('NO_DEFAULT_CONSTRUCTOR(URenderResource)',
     'URenderResource() {}',
     'URenderResource ctor -> public'),
], 'EngineClasses.h')

# === EngineDecls.h fixes ===
print("\n=== EngineDecls.h ===")
fix_file('src/engine/EngineDecls.h', [
    # 2. FOrientation::operator= declaration: const ref -> by value
    ('FOrientation& operator=(const FOrientation&);',
     'FOrientation& operator=(FOrientation);',
     'FOrientation::operator= decl -> by value'),
    
    # 3. FRebuildOptions::operator= declaration: return by ref + const ref -> by value both
    ('FRebuildOptions& operator=(const FRebuildOptions&);',
     'FRebuildOptions operator=(FRebuildOptions);',
     'FRebuildOptions::operator= decl -> return+param by value'),
], 'EngineDecls.h')

# === EngineBatchImpl2.cpp fixes ===
print("\n=== EngineBatchImpl2.cpp ===")
fix_file('src/engine/EngineBatchImpl2.cpp', [
    # 2. FOrientation::operator= implementation
    ('FOrientation& FOrientation::operator=(const FOrientation&)\n{\n\treturn *this;\n}',
     'FOrientation& FOrientation::operator=(FOrientation)\n{\n\treturn *this;\n}',
     'FOrientation::operator= impl -> by value'),
    
    # 3. FRebuildOptions::operator= implementation
    ('FRebuildOptions& FRebuildOptions::operator=(const FRebuildOptions&)\n{\n\treturn *this;\n}',
     'FRebuildOptions FRebuildOptions::operator=(FRebuildOptions)\n{\n\treturn FRebuildOptions();\n}',
     'FRebuildOptions::operator= impl -> return+param by value'),
    
    # 6. UCanvas::WrappedPrint: add __cdecl to implementation
    ('void UCanvas::WrappedPrint(ERenderStyle,int &,int &,UFont *,int,const TCHAR*)',
     'void __cdecl UCanvas::WrappedPrint(ERenderStyle,int &,int &,UFont *,int,const TCHAR*)',
     'UCanvas::WrappedPrint impl -> __cdecl'),
], 'EngineBatchImpl2.cpp')

print()
if errors:
    print(f"ERRORS ({len(errors)}):")
    for e in errors:
        print(e)
    sys.exit(1)
else:
    print("All 11 fixes applied successfully!")
