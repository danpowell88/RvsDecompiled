"""
Fix EngineClasses.h include guard structure.
Move #pragma pack inside the NAMES_ONLY-guarded section and close the include guard.
"""

path = r'c:\Users\danpo\Desktop\rvs\src\engine\EngineClasses.h'
with open(path, 'r') as f:
    content = f.read()

# 1. Remove the orphaned #pragma pack(push,4) from the top (before AUTOGENERATE_NAME section)
# It's currently at lines 10-12: #if _MSC_VER\n#pragma pack (push,4)\n#endif
old_top = '''#if _MSC_VER
#pragma pack (push,4)
#endif

#ifndef ENGINE_API
#define ENGINE_API DLL_IMPORT
#endif

#ifndef NAMES_ONLY'''
new_top = '''#ifndef ENGINE_API
#define ENGINE_API DLL_IMPORT
#endif

#ifndef NAMES_ONLY'''
assert old_top in content, "Cannot find top section"
content = content.replace(old_top, new_top, 1)
print("Removed top #pragma pack(push,4)")

# 2. Add #pragma pack(push,4) right after the second #ifndef NAMES_ONLY + include guard
old_guard = '''#ifndef NAMES_ONLY
#ifndef _INC_ENGINE_CLASSES_DECLS
#define _INC_ENGINE_CLASSES_DECLS

/*==========================================================================
\tForward declarations.'''
new_guard = '''#ifndef NAMES_ONLY
#ifndef _INC_ENGINE_CLASSES_DECLS
#define _INC_ENGINE_CLASSES_DECLS

#if _MSC_VER
#pragma pack (push,4)
#endif

/*==========================================================================
\tForward declarations.'''
assert old_guard in content, "Cannot find guard + Forward declarations"
content = content.replace(old_guard, new_guard, 1)
print("Added #pragma pack(push,4) inside guarded section")

# 3. Fix the end: add #endif for _INC_ENGINE_CLASSES_DECLS before NAMES_ONLY #endif
# Current end: #pragma pack (pop)\n#endif
# Need:        #pragma pack (pop)\n#endif // _INC_ENGINE_CLASSES_DECLS\n#endif // NAMES_ONLY
old_end = '#pragma pack (pop)\n#endif'
new_end = '#if _MSC_VER\n#pragma pack (pop)\n#endif\n#endif // _INC_ENGINE_CLASSES_DECLS\n#endif // NAMES_ONLY'
# But wait - the current #pragma pack(pop) might not be inside #if _MSC_VER
# Let me find the exact end
assert old_end in content, "Cannot find file ending"
# Make sure to replace only the LAST occurrence
idx = content.rfind(old_end)
content = content[:idx] + new_end + content[idx + len(old_end):]
print("Fixed file ending with proper include guard closure")

with open(path, 'w') as f:
    f.write(content)

# Verify balance
opens = 0
closes = 0
for line in content.split('\n'):
    ls = line.strip()
    if ls.startswith('#if ') or ls.startswith('#ifdef') or ls.startswith('#ifndef'):
        opens += 1
    elif ls.startswith('#endif'):
        closes += 1
print(f"Preprocessor balance: {opens} opens, {closes} closes")
assert opens == closes, f"IMBALANCED! {opens} != {closes}"
print("Done - balanced!")
