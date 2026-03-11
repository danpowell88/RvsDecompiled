import re

with open('src/engine/Src/UnPawn.cpp', encoding='utf-8', errors='ignore') as f:
    content = f.read()

pattern = re.compile(r'(\w[\w\s\*&:<>]+?)\s+(\w+::\w+)\s*\(([^)]*)\)\s*\{[^{}]*guard\([^)]+\);?\s*(return\s+[^;]+;|)\s*unguard;?\s*\}', re.DOTALL)
stubs = []
for m in pattern.finditer(content):
    func = m.group(2)
    body = m.group(4).strip()
    if body in ('return 0;', 'return NULL;', 'return FALSE;', 'return 1;', 'return TRUE;', ''):
        stubs.append((func, body if body else '(void)'))

print(f"Total stubs in UnPawn.cpp: {len(stubs)}")
for func, body in stubs:
    print(f"  {func}: {body}")
