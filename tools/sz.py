data = open(r"retail\system\Engine.dll","rb").read()
import re
exports = {}
with open("build/retail_engine_exports.txt", encoding="utf-8", errors="ignore") as f:
    for line in f:
        m = re.match(r"\s+\d+\s+[0-9A-F]+\s+([0-9A-F]{8})\s+(\?[^\s]+)", line)
        if m: exports[m.group(2)] = int(m.group(1),16)
def sz(rva):
    for i in range(rva, rva+3000):
        b = data[i]
        if b == 0xC3 or b == 0xC2: return i - rva + (1 if b==0xC3 else 3)
    return 9999
fns = ["IsNetRelevantFor","ProcessRemoteFunction","TestCanSeeMe","GetR6AvailabilityPtr",
       "IsFriend","IsNeutral","CheckForLedges","HurtByVolume","FindSlopeRotation",
       "ValidAnchor","GetViewTarget","LineOfSightTo","FindPath","HandleSpecial",
       "SetPath","CanHear","CanHearSound",
       "swimReachable","jumpReachable","pointReachable","ladderReachable","Reachable","Swim",
       "findNewFloor","findPathToward","findWaterLine","checkFloor","breadthPathTo",
       "FindBestJump","FindJumpUp","PickWallAdjust","SuggestJumpVelocity",
       "CanCrouchWalk","CanProneWalk","swimMove","flyMove","jumpLanding","walkMove"]
for fn in fns:
    hits = [(k,v) for k,v in exports.items() if fn in k and any(c in k for c in ["APawn","AActor","AController"])]
    for k,v in sorted(hits, key=lambda x: len(x[0]))[:1]:
        cls = k.split("@")[1] if "@" in k else "?"
        print(fn + " (" + cls + "): " + str(sz(v)) + "b")

