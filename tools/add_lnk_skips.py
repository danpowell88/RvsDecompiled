"""Add LNK2005 duplicate symbols to SKIP_MANGLES."""
import re

LNK_DUPES = {
    '??1FAnimMeshVertexStream@@UAE@XZ',
    '??1FBspVertexStream@@UAE@XZ',
    '??1FCanvasUtil@@UAE@XZ',
    '??1FLightMap@@UAE@XZ',
    '??1FLightMapTexture@@UAE@XZ',
    '??1FLineBatcher@@UAE@XZ',
    '??1FRaw32BitIndexBuffer@@UAE@XZ',
    '??1FRawColorStream@@UAE@XZ',
    '??1FRawIndexBuffer@@UAE@XZ',
    '??1FSkinVertexStream@@UAE@XZ',
    '??1FStaticLightMapTexture@@UAE@XZ',
    '??1FStaticMeshUVStream@@UAE@XZ',
    '??1FStaticMeshVertexStream@@UAE@XZ',
    '?FillVertexBuffer@USpriteEmitter@@UAEHPAUFSpriteParticleVertex@@PAVFLevelSceneNode@@@Z',
    '?getKConstraint@AKConstraint@@UBEPAVMdtBaseConstraint@@XZ',
    '?GetMovement@UMeshAnimation@@UAEPAUMotionChunk@@VFName@@@Z',
    '?findNewFloor@APawn@@QAEHVFVector@@MMH@Z',
}

with open('tools/gen_impl4.py') as f:
    content = f.read()

m = re.search(r'SKIP_MANGLES = \{([^}]*)\}', content, re.DOTALL)
existing = set()
for line in m.group(1).split('\n'):
    line = line.strip().rstrip(',')
    if line.startswith("'") and line.endswith("'"):
        existing.add(line[1:-1])

all_skips = existing | LNK_DUPES
print(f"Existing: {len(existing)}, Adding: {len(LNK_DUPES - existing)}, Total: {len(all_skips)}")

new_set = "SKIP_MANGLES = {\n"
for s in sorted(all_skips):
    new_set += f"    '{s}',\n"
new_set += "}"

content = re.sub(r'SKIP_MANGLES = \{[^}]*\}', new_set, content, flags=re.DOTALL)

with open('tools/gen_impl4.py', 'w') as f:
    f.write(content)

print("Done")
