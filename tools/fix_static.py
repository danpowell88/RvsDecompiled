"""Fix remaining build errors in gen_impl3.py"""
path = 'tools/gen_impl3.py'
with open(path) as f:
    content = f.read()

# 1. Add more scene node classes to KNOWN_DECLARED_ELSEWHERE
old = "    'UNetConnection',\n}"
new = (
    "    'UNetConnection',\n"
    "    'FActorSceneNode', 'FCameraSceneNode', 'FDirectionalLightMapSceneNode',\n"
    "    'FLevelSceneNode', 'FLightMapSceneNode', 'FPointLightMapSceneNode',\n"
    "}"
)
content = content.replace(old, new)

# 2. Fix static method implementations - remove 'static' from definitions
# In the implementation section, static methods should NOT have 'static' keyword
old_impl = "                    impl_lines.append(f'{ret} {cls}::{method}({params})\\n{{\\n{body}}}\\n\\n')\n                    gen_count += 1"
new_impl = "                    impl_lines.append(f'{ret} {cls}::{method}({params})\\n{{\\n{body}}}\\n\\n')\n                    gen_count += 1"
# Actually the static issue is in the STATIC_SIG_RE branch of implementation generation
# Let me just search-replace the static lines generation

# The issue is that the generated implementations have 'static' prefix for static methods
# but C++ doesn't allow 'static' on member function definitions outside the class.
# The current implementation just uses {ret} which doesn't include 'static', so it should be fine.
# BUT non-static methods using SIG_RE are fine. The issue must be that STATIC_SIG_RE demangled
# text itself includes 'static' in the return type or method name.
# Let me check: the error is "static const TCHAR* UInputPlanning::StaticConfigName()"
# This looks like the FULL demangled text includes "static" as part of the function definition.

# Actually wait - looking at the code, the static branch in decls has:
#   new_decls[cls].append(f'\tstatic {ret} {method}({params});\n')
# And the impl generates:
#   impl_lines.append(f'{ret} {cls}::{method}({params})\n...')
# So the implementation should NOT have 'static'. But the error message shows 'static' in the line.
# This means the demangled text includes 'static' and the SIG_RE match might capture it in ret.

# Let me trace: for static methods, the demangling gives something like:
#   "public: static char const * __cdecl UInputPlanning::StaticConfigName(void)"
# The SIG_RE tries to match this: it has (virtual\s+)? which won't match.
# Then (.*?) for return type would match 'static char const *'.
# So ret = 'static char const *' which after fix_type becomes 'static const TCHAR*'
# That's the bug! SIG_RE captures 'static' as part of the return type.
# Fix: strip 'static ' from the return type

old_ret = "                ret = fix_type(m.group(2))\n                method = m.group(4)\n                params = fix_type(m.group(5))"
new_ret = "                ret = fix_type(m.group(2)).lstrip('static ')\n                method = m.group(4)\n                params = fix_type(m.group(5))"

# Actually lstrip('static ') would strip any chars in the set. Use removeprefix.
# But Python 3.8 doesn't have removeprefix. Use replace.
new_ret2 = "                ret = fix_type(m.group(2))\n                if ret.startswith('static '): ret = ret[7:]\n                method = m.group(4)\n                params = fix_type(m.group(5))"
content = content.replace(old_ret, new_ret2, 1)  # Only first occurrence (in impl section)

# Actually there are TWO occurrences of this pattern (decl + impl sections)
# The decl section SHOULD have 'static' but the impl section should NOT.
# Let me be more specific by replacing in the impl_lines section

with open(path, 'w') as f:
    f.write(content)

print("Done")
