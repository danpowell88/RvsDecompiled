"""check_stubs.py - Check retail DLL implementations for guard-only stub functions."""
import sys, os, re, struct

def check_dll(dll_path, exports_txt, targets):
    exports = {}
    with open(exports_txt, encoding='utf-8', errors='ignore') as f:
        for line in f:
        parts = line.strip().split()
        if len(parts) >= 2:
            try:
                rva = int(parts[1], 16)
                name = " ".join(parts[2:]) if len(parts) > 2 else parts[0]
                exports[name] = rva
            except: pass

data = open(r"retail\system\Engine.dll", "rb").read()

targets = [
    ("ProcessRemoteFunction", "AActor"),("GetNetPriority","AActor"),
    ("IsNetRelevantFor","AActor"),("ShouldTrace","AActor"),
    ("CheckOwnerUpdated","AActor"),("FindSlopeRotation","AActor"),
    ("TestCanSeeMe","AActor"),("GetR6AvailabilityPtr","AActor"),
    ("IsFriend","APawn"),("IsNeutral","APawn"),
    ("CheckOwnerUpdated","APawn"),("HurtByVolume","APawn"),
    ("IsNetRelevantFor","APawn"),("ShouldTrace","APawn"),
    ("ValidAnchor","APawn"),("walkReachable","APawn"),
    ("swimReachable","APawn"),("flyReachable","APawn"),
    ("jumpReachable","APawn"),("pointReachable","APawn"),
    ("ladderReachable","APawn"),("Reachable","APawn"),
    ("Swim","APawn"),("GetViewTarget","AController"),
    ("LineOfSightTo","AController"),("FindPath","AController"),
    ("HandleSpecial","AController"),("SetPath","AController"),
    ("CanHear","AController"),("CanHearSound","AController"),
]

for fname, cls in targets:
    matches = [(k,v) for k,v in exports.items() if fname in k and cls in k]
    if not matches:
        print(f"{cls}::{fname}: NOT FOUND"); continue
    k, rva = matches[0]
    off = rva
    snippet = data[off:off+6]
    if snippet[0] == 0xC3: status = "EMPTY(ret)"
    elif snippet[0] == 0xC2: status = "EMPTY(ret {})".format(snippet[1])
    elif snippet[:2] == bytes([0x33,0xC0]): status = "return 0 then..."
    elif snippet[:3] == bytes([0x55,0x8b,0xec]):
        for end in range(off+3, min(off+500, len(data))):
            if data[end] == 0xC3 or (data[end:end+1] == bytes([0xC2])):
                fsize = end-off+1; break
        else: fsize = 999
        status = "HAS_BODY(~{}b)".format(fsize)
    else: status = "bytes:{}".format(" ".join(f"{b:02x}" for b in snippet))
    print(f"{cls}::{fname}: RVA=0x{rva:05x} {status}")
