"""
Measure retail function sizes and identify short functions suitable for decompilation.
"""
import struct, sys

def load_dll(path):
    with open(path, 'rb') as f:
        data = f.read()
    pe_offset = struct.unpack_from('<I', data, 0x3C)[0]
    opt_header_size = struct.unpack_from('<H', data, pe_offset + 0x14)[0]
    sec_offset = pe_offset + 0x18 + opt_header_size
    num_sections = struct.unpack_from('<H', data, pe_offset + 6)[0]
    sections = []
    for i in range(num_sections):
        offs = sec_offset + i * 40
        vaddr, vsize, raw_offs = struct.unpack_from('<III', data, offs + 12)
        sections.append((vaddr, vsize, raw_offs))
    def r2r(rva):
        for (va, vsize, raw) in sections:
            if va <= rva < va + vsize:
                return raw + (rva - va)
        return None
    exp_rva = struct.unpack_from('<I', data, pe_offset + 0x78)[0]
    raw = r2r(exp_rva)
    num_funcs, num_names = struct.unpack_from('<II', data, raw + 0x14)
    funcs_rva = struct.unpack_from('<I', data, raw + 0x1C)[0]
    names_rva = struct.unpack_from('<I', data, raw + 0x20)[0]
    ords_rva  = struct.unpack_from('<I', data, raw + 0x24)[0]
    exports = {}
    export_rvas = []
    for i in range(num_names):
        name_rva = struct.unpack_from('<I', data, r2r(names_rva) + i*4)[0]
        ord_idx  = struct.unpack_from('<H', data, r2r(ords_rva)  + i*2)[0]
        func_rva = struct.unpack_from('<I', data, r2r(funcs_rva) + ord_idx*4)[0]
        nr = r2r(name_rva)
        name = b''
        while data[nr] != 0:
            name += bytes([data[nr]]); nr += 1
        exports[name.decode(errors='replace')] = func_rva
        export_rvas.append(func_rva)
    return exports, data, r2r, sorted(set(export_rvas))

def find_func_size(data, r2r, rva, sorted_rvas, max_size=512):
    """Approximate function size by finding the next function or ret instruction."""
    raw = r2r(rva)
    if raw is None:
        return 0
    # Find next export RVA to bound search
    import bisect
    idx = bisect.bisect_right(sorted_rvas, rva)
    next_rva = sorted_rvas[idx] if idx < len(sorted_rvas) else rva + max_size
    bound = min(next_rva - rva, max_size)
    
    # Scan for ret instruction
    b = data[raw:raw + bound]
    for i, byte in enumerate(b):
        if byte == 0xc3:  # ret
            return i + 1
        if byte == 0xc2 and i + 2 < len(b):  # ret N
            return i + 3
    return bound  # function is longer than bound

eng_exports, eng_data, eng_r2r, eng_rvas = load_dll('retail/system/Engine.dll')

# Targets from our stub list - complex functions
targets = [
    'CheckOwnerUpdated', 'AssociatedLevelGeometry', 'TickSimulated',
    'HurtByVolume', 'R6LineOfSightTo', 'R6SeePawn', 'Reachable',
    'CanCrouchWalk', 'CanProneWalk', 'Pick3DWallAdjust', 'PickWallAdjust',
    'SpiderstepUp', 'StartNewSerpentine', 'ValidAnchor', 'ZeroMovementAlpha',
    'checkFloor', 'clearPaths', 'findNewFloor', 'flyReachable', 'jumpReachable',
    'ladderReachable', 'pointReachable', 'swimReachable', 'walkReachable',
    'startSwimming', 'rotateToward', 'setMoveTimer',
    'GetTeamManager', 'AdjustFromWall', 'AcceptNearbyPath',
    'CanHear', 'CheckHearSound', 'ShowSelf', 'SetPath', 'SetRouteCache',
    'LineOfSightTo', 'CanHearSound', 'CheckEnemyVisible', 'FindPath',
    'preKarmaStep', 'postKarmaStep', 'PostNetReceiveLocation', 'TestCanSeeMe',
    'CheckForErrors', 'AddMyMarker', 'SaveServerOptions',
    'SetGameType', 'PreNetReceive', 'PostNetReceive',
    'DbgAddLine', 'DbgVectorAdd', 'DbgVectorDraw', 'DbgVectorReset',
    'KMP2DynKarmaInterface',
]

sizes = []
for t in targets:
    hits = [(k, v) for k, v in eng_exports.items() if t in k.split('@')[0] if '@' in k]
    if not hits:
        hits = [(k, v) for k, v in eng_exports.items() if t in k]
    if hits:
        # take the smallest size (first unique function)
        seen_rvas = set()
        for name, rva in hits[:3]:
            if rva in seen_rvas:
                continue
            seen_rvas.add(rva)
            sz = find_func_size(eng_data, eng_r2r, rva, eng_rvas)
            raw = eng_r2r(rva)
            hex_bytes = eng_data[raw:raw+min(sz, 32)].hex() if raw else '?'
            sizes.append((sz, t, name, hex_bytes))

sizes.sort()
for sz, t, name, hx in sizes[:40]:
    print(f'{sz:4d}  {t:35s}  {hx[:40]}')
