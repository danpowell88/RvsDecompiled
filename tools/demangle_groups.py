"""Demangle VertexStream, FColor, FRotatorF, FRenderInterface stubs."""
import subprocess

UNDNAME = r'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86\undname.exe'

groups = {
    'VertexStream': [],
    'FColor': [],
    'FRotatorF': [],
    'FRenderInterface': [],
    'FOctreeNode': [],
}

stubs_all = []
for i in range(1, 5):
    with open(f'src/engine/EngineStubs{i}.cpp') as f:
        for line in f:
            if '/alternatename:' in line and '=_dummy' in line:
                idx1 = line.index('/alternatename:') + len('/alternatename:')
                idx2 = line.index('=_dummy')
                s = line[idx1:idx2]
                stubs_all.append(s)
                if 'UVertexStream' in s or 'UVertexBuffer' in s:
                    groups['VertexStream'].append(s)
                elif 'FColor' in s:
                    groups['FColor'].append(s)
                elif 'FRotatorF' in s:
                    groups['FRotatorF'].append(s)
                elif 'FRenderInterface' in s:
                    groups['FRenderInterface'].append(s)
                elif 'FOctreeNode' in s:
                    groups['FOctreeNode'].append(s)

for name, stubs in groups.items():
    if not stubs:
        continue
    print(f'\n=== {name} ({len(stubs)} stubs) ===')
    proc = subprocess.run([UNDNAME] + stubs, capture_output=True, text=True)
    lines = proc.stdout.strip().split('\n')
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if line.startswith('Undecoration of :- "') and line.endswith('"'):
            if i+1 < len(lines):
                dem = lines[i+1].strip()
                if dem.startswith('is :- "') and dem.endswith('"'):
                    print(f'  {dem[7:-1]}')
            i += 2
        else:
            i += 1
