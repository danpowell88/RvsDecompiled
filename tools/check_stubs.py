"""check_stubs.py - Check retail DLL implementations for guard-only stub functions.

Export file format (dumpbin /exports):
   ordinal  hint  RVA      name
   13       C     0003D2C0 ??0AActor@@QAE@ABV0@@Z
"""
import sys, os, re, struct

EXPORTS_TXT = r"build\retail_engine_exports.txt"
DLL_PATH    = r"retail\system\Engine.dll"

# Load exports: {mangled_name -> RVA}
# dumpbin writes UTF-16 LE with BOM
exports = {}
with open(EXPORTS_TXT, encoding='utf-16', errors='ignore') as f:
    for line in f:
        parts = line.strip().split()
        # Valid symbol lines have at least 4 parts: ordinal hint RVA name
        if len(parts) >= 4:
            try:
                rva  = int(parts[2], 16)
                name = parts[3]
                exports[name] = rva
            except (ValueError, IndexError):
                pass

data = open(DLL_PATH, "rb").read()

targets = [
    ("ProcessRemoteFunction", "AActor"), ("GetNetPriority",   "AActor"),
    ("IsNetRelevantFor",      "AActor"), ("ShouldTrace",       "AActor"),
    ("CheckOwnerUpdated",     "AActor"), ("FindSlopeRotation", "AActor"),
    ("TestCanSeeMe",          "AActor"), ("GetR6AvailabilityPtr","AActor"),
    ("IsFriend",  "APawn"),  ("IsNeutral",       "APawn"),
    ("IsEnemy",   "APawn"),  ("CheckOwnerUpdated","APawn"),
    ("HurtByVolume","APawn"),("IsNetRelevantFor", "APawn"),
    ("ShouldTrace","APawn"), ("ValidAnchor",      "APawn"),
    ("walkReachable","APawn"),("swimReachable",   "APawn"),
    ("flyReachable","APawn"), ("jumpReachable",   "APawn"),
    ("pointReachable","APawn"),("ladderReachable","APawn"),
    ("Reachable", "APawn"),  ("Swim",             "APawn"),
    ("GetViewTarget","AController"),  ("LineOfSightTo","AController"),
    ("FindPath",    "AController"),   ("HandleSpecial","AController"),
    ("SetPath",     "AController"),   ("CanHear",      "AController"),
    ("CanHearSound","AController"),
]

def classify(data, off):
    snippet = data[off:off+6]
    if not snippet:
        return "EMPTY(no data)"
    if snippet[0] == 0xC3:
        return "EMPTY(ret)"
    if snippet[0] == 0xC2:
        return "EMPTY(ret {})".format(snippet[1])
    if snippet[:2] == bytes([0x33, 0xC0]):
        return "return_0_then..."
    if snippet[:3] == bytes([0x55, 0x8B, 0xEC]):
        # Has a prolog — estimate size to first ret
        for end in range(off + 3, min(off + 600, len(data))):
            b = data[end]
            if b == 0xC3 or b == 0xC2:
                return "HAS_BODY(~{}b)".format(end - off + 1)
        return "HAS_BODY(>600b)"
    return "bytes:{}".format(" ".join(f"{b:02x}" for b in snippet))

for fname, cls in targets:
    matches = [(k, v) for k, v in exports.items() if fname in k and cls in k]
    if not matches:
        print(f"{cls}::{fname}: NOT FOUND")
        continue
    k, rva = matches[0]
    status = classify(data, rva)
    print(f"{cls}::{fname}: RVA=0x{rva:05X}  {status}")
