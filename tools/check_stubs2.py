import os, sys

def get_func_info(data, rva):
    off = rva
    if off >= len(data): return "OOB"
    b = data[off:off+8]
    if b[0] == 0xC3: return "EMPTY(ret)"
    if b[0] == 0xC2: return f"EMPTY(ret {b[1]})"
    if b[:3] == bytes([0x55,0x8b,0xec]):
        for end in range(off+3, min(off+2000,len(data))):
            if data[end]==0xC3 or data[end]==0xC2:
                return f"HAS_BODY(~{end-off+1}b)"
        return "HAS_BODY(>2000b)"
    return "bytes:" + " ".join(f"{x:02x}" for x in b[:6])

exports = {}
with open("build/retail_engine_exports.txt", encoding="utf-8", errors="ignore") as f:
    for line in f:
        p = line.strip().split()
        if len(p) >= 2:
            try: exports[" ".join(p[2:])] = int(p[1],16)
            except: pass

data = open(r"retail\system\Engine.dll","rb").read()

tgts = [
    ("AActor","ProcessRemoteFunction"),("AActor","GetNetPriority"),
    ("AActor","IsNetRelevantFor"),("AActor","ShouldTrace"),("AActor","CheckOwnerUpdated"),
    ("AActor","FindSlopeRotation"),("AActor","TestCanSeeMe"),("AActor","GetR6AvailabilityPtr"),
    ("APawn","IsFriend"),("APawn","IsNeutral"),("APawn","CheckOwnerUpdated"),
    ("APawn","HurtByVolume"),("APawn","IsNetRelevantFor"),("APawn","ShouldTrace"),
    ("APawn","ValidAnchor"),("APawn","walkReachable"),("APawn","swimReachable"),
    ("APawn","flyReachable"),("APawn","jumpReachable"),("APawn","pointReachable"),
    ("APawn","ladderReachable"),("APawn","Reachable"),("APawn","Swim"),
    ("APawn","CheckForLedges"),("APawn","FindSlopeRotation"),("APawn","findNewFloor"),
    ("APawn","findPathToward"),("APawn","findWaterLine"),("APawn","checkFloor"),
    ("APawn","breadthPathTo"),("APawn","FindBestJump"),("APawn","FindJumpUp"),
    ("APawn","Pick3DWallAdjust"),("APawn","PickWallAdjust"),("APawn","SuggestJumpVelocity"),
    ("APawn","CanCrouchWalk"),("APawn","CanProneWalk"),
    ("APawn","walkMove"),("APawn","swimMove"),("APawn","flyMove"),("APawn","jumpLanding"),
    ("AController","Tick"),("AController","CheckAnimFinished"),
    ("AController","GetViewTarget"),("AController","LineOfSightTo"),
    ("AController","FindPath"),("AController","HandleSpecial"),
    ("AController","SetPath"),("AController","CanHear"),("AController","CanHearSound"),
]

for cls, fn in tgts:
    hits = [(k,v) for k,v in exports.items() if fn+"@"+cls in k or (fn in k and "@"+cls in k)]
    if not hits:
        hits = [(k,v) for k,v in exports.items() if fn in k and cls in k]
    if not hits: print(f"{cls}::{fn}: NOT FOUND"); continue
    hits.sort(key=lambda x:len(x[0]))
    k,rva = hits[0]
    print(f"{cls}::{fn}: RVA=0x{rva:05x} {get_func_info(data,rva)}")
