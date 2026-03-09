"""
Fix EngineClasses.h: Replace #pragma once with targeted include guard.
The NAMES_ONLY pattern requires the file to be includable twice:
once for declarations, once for FName definitions.
#pragma once breaks this pattern.
"""

path = r'c:\Users\danpo\Desktop\rvs\src\engine\EngineClasses.h'
with open(path, 'r') as f:
    content = f.read()

# 1. Remove #pragma once
assert '#pragma once\n' in content, "Cannot find #pragma once"
content = content.replace('#pragma once\n', '', 1)
print("Removed #pragma once")

# 2. Add include guard around #ifndef NAMES_ONLY section
# The second #ifndef NAMES_ONLY (around class declarations) needs a guard
# Find the second occurrence of "#ifndef NAMES_ONLY"
first = content.find('#ifndef NAMES_ONLY')
assert first != -1, "Cannot find first NAMES_ONLY"
second = content.find('#ifndef NAMES_ONLY', first + 1)
assert second != -1, "Cannot find second NAMES_ONLY"

# Insert include guard just after the second #ifndef NAMES_ONLY line
# We need to wrap the inner content with an additional guard
old_marker = '#ifndef NAMES_ONLY\n\n/*==========================================================================\n\tForward declarations.'
assert old_marker in content, "Cannot find NAMES_ONLY + Forward declarations marker"
new_marker = '#ifndef NAMES_ONLY\n#ifndef _INC_ENGINE_CLASSES_DECLS\n#define _INC_ENGINE_CLASSES_DECLS\n\n/*==========================================================================\n\tForward declarations.'
content = content.replace(old_marker, new_marker, 1)
print("Added include guard open after #ifndef NAMES_ONLY")

# Find the closing #endif of the NAMES_ONLY block and the #pragma pack(pop)
# The file ends with:
# #endif  // NAMES_ONLY
# #if _MSC_VER
# #pragma pack (pop)
# #endif
old_end = '#endif\n\n#if _MSC_VER\n#pragma pack (pop)\n#endif'
new_end = '#endif // _INC_ENGINE_CLASSES_DECLS\n#endif // NAMES_ONLY\n\n#if _MSC_VER\n#pragma pack (pop)\n#endif'
if old_end in content:
    content = content.replace(old_end, new_end, 1)
    print("Added include guard close before pragma pack pop")
else:
    # Try alternate ending
    print("Could not find expected file ending, trying alternate...")
    # Let's look for the last #endif pattern
    # The file should end with #endif for NAMES_ONLY then #pragma pack(pop)
    import re
    # Find the very last #endif before #pragma pack(pop)
    m = re.search(r'(#endif)\s*\n\s*#if _MSC_VER\s*\n\s*#pragma pack \(pop\)\s*\n\s*#endif\s*$', content)
    if m:
        pos = m.start()
        content = content[:pos] + '#endif // _INC_ENGINE_CLASSES_DECLS\n' + content[pos:]
        print("Inserted include guard close via regex")
    else:
        print("ERROR: Could not find file ending pattern!")

with open(path, 'w') as f:
    f.write(content)
print("Done!")
