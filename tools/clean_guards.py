"""Remove guard/unguard-only boilerplate from stub functions.

Usage: python tools/clean_guards.py <file>

Replaces:
{
    guard(Foo::Bar);
    unguard;
}

With:
{
}
"""
import re, sys, os

def clean_file(path):
    content = open(path, 'r', errors='replace').read()
    original = content

    # Pattern: function body that has ONLY guard(X); unguard; (no other code)
    # Handles optional whitespace/tabs
    pattern = re.compile(
        r'(\{[ \t]*\n)'           # opening brace + newline
        r'([ \t]*guard\([^)]+\)[ \t]*;[ \t]*\n)'  # guard(X);
        r'([ \t]*unguard[ \t]*;[ \t]*\n)'          # unguard;
        r'([ \t]*\})'             # closing brace
    )

    count = [0]
    def replace(m):
        count[0] += 1
        return m.group(1) + m.group(4)

    result = pattern.sub(replace, content)

    if result != original:
        open(path, 'w', errors='replace').write(result)
        print(f'{path}: cleaned {count[0]} guard-only stubs')
    else:
        print(f'{path}: no changes')

if __name__ == '__main__':
    for f in sys.argv[1:]:
        clean_file(f)
