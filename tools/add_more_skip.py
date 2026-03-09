"""Add more classes to KNOWN_DECLARED_ELSEWHERE in gen_impl3.py"""
path = 'tools/gen_impl3.py'
with open(path) as f:
    content = f.read()

more = (
    "'FInBunch', 'FMirrorSceneNode', 'FSceneNode', 'FSkySceneNode',\n"
    "    'FStaticMeshColorStream', 'FStats', 'FWarpZoneSceneNode',\n"
    "    'UDemoRecConnection', 'UInput', 'UMeshInstance', 'UNullRenderDevice',\n"
    "    'UPackageMapLevel', 'URenderResource', 'UTerrainPrimitive',\n"
    "    'UVertexBuffer', 'UVertexStreamBase', 'UVertexStreamCOLOR',\n"
    "    'UVertexStreamPosNormTex', 'UVertexStreamUV', 'UVertexStreamVECTOR',\n"
    "    'UNetConnection',\n"
)

old = "'FSortedPathList', 'FSoundData', 'FStatGraph', 'FRenderCaps',\n}"
new = "'FSortedPathList', 'FSoundData', 'FStatGraph', 'FRenderCaps',\n    " + more + "}"
content = content.replace(old, new)

with open(path, 'w') as f:
    f.write(content)
print("Done")
