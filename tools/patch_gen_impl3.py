"""Patch gen_impl3.py to add KNOWN_DECLARED_ELSEWHERE set."""
import os

path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'gen_impl3.py')
with open(path) as f:
    content = f.read()

# Add KNOWN_DECLARED_ELSEWHERE after SKIP_IMPLS
known_classes = """
# Classes defined in SDK headers (Core, etc.) that should NOT go in EngineDecls.h
KNOWN_DECLARED_ELSEWHERE = {
    'AR6AbstractClimbableObj', 'FCollisionHash', 'FCollisionOctree', 'FColor',
    'FDbgVectorInfo', 'FHitCause', 'FOctreeNode', 'FPointRegion', 'FPoly',
    'FRenderInterface', 'FRotatorF', 'FURL', 'FWaveModInfo',
    'HActor', 'HBspSurf', 'HCoords', 'HHitProxy', 'HMaterialTree',
    'HMatineeAction', 'HMatineeScene', 'HMatineeSubAction', 'HMatineeTimePath',
    'HTerrain', 'HTerrainToolLayer', 'UR6AbstractTerroristMgr',
    'ECLipSynchData', 'FEngineStats', 'FHitObserver', 'FMatineeTools',
    'FOutBunch', 'FPathBuilder', 'FRebuildTools', 'FSceneNode',
    'FSortedPathList', 'FSoundData', 'FStatGraph', 'FRenderCaps',
}
"""

# Insert after SKIP_IMPLS closing brace
insert_after = "('UEngine', 'edDrawAxisIndicator'),\n}"
content = content.replace(insert_after, insert_after + known_classes)

# Modify declared_classes to include KNOWN_DECLARED_ELSEWHERE
content = content.replace(
    'declared_classes = get_declared_classes()',
    'declared_classes = get_declared_classes() | KNOWN_DECLARED_ELSEWHERE'
)

with open(path, 'w') as f:
    f.write(content)

print("Patched gen_impl3.py with KNOWN_DECLARED_ELSEWHERE")
