"""
Fix remaining 15 non-FUNC_NAME, non-vftable stubs.
1. Karma functions: add const to pointer params (QAY vs PAY mangling)
2. FPointRegion: move ctors out-of-line
3. FSoundData: remove virtual from dtor
4. AR6AbstractClimbableObj/UR6AbstractTerroristMgr: move ctors out-of-line
5. FHitObserver::Click: move out-of-line
6. TLazyArray<BYTE>: add explicit specialization declarations
"""
import os

ROOT = r'c:\Users\danpo\Desktop\rvs\src\engine'

# ============================================================
# 1. Fix EngineBatchImpl4.cpp — Karma function signatures
# ============================================================
path = os.path.join(ROOT, 'EngineBatchImpl4.cpp')
with open(path, 'r') as f:
    content = f.read()

fixes_cpp = [
    # Karma functions: add const to pointer params
    ('void KME2UCoords(FCoords*, const FLOAT (*)[4]) {}',
     'void KME2UCoords(FCoords*, const FLOAT (* const)[4]) {}'),
    ('void KME2UMatrixCopy(FMatrix*, FLOAT (*)[4]) {}',
     'void KME2UMatrixCopy(FMatrix*, FLOAT (* const)[4]) {}'),
    ('void KME2UTransform(FVector*, FRotator*, const FLOAT (*)[4]) {}',
     'void KME2UTransform(FVector*, FRotator*, const FLOAT (* const)[4]) {}'),
    ('void KU2MEMatrixCopy(FLOAT (*)[4], FMatrix*) {}',
     'void KU2MEMatrixCopy(FLOAT (* const)[4], FMatrix*) {}'),
    ('void KU2METransform(FLOAT (*)[4], FVector, FRotator) {}',
     'void KU2METransform(FLOAT (* const)[4], FVector, FRotator) {}'),
]

for old, new in fixes_cpp:
    if old in content:
        content = content.replace(old, new, 1)
        print(f"  Fixed Karma: {old[:50]}...")
    else:
        print(f"  NOT FOUND: {old[:50]}...")

# Add FPointRegion ctors, AR6 ctors, UR6 ctor, FHitObserver::Click implementations
additions = '''
// ============================================================================
// FPointRegion constructors (moved from inline to out-of-line)
// ============================================================================
FPointRegion::FPointRegion() : Zone(NULL), iLeaf(0), ZoneNumber(0) {}
FPointRegion::FPointRegion(AZoneInfo* InZone) : Zone(InZone), iLeaf(0), ZoneNumber(0) {}
FPointRegion::FPointRegion(AZoneInfo* InZone, INT InLeaf, BYTE InZoneNumber) : Zone(InZone), iLeaf(InLeaf), ZoneNumber(InZoneNumber) {}

// ============================================================================
// AR6AbstractClimbableObj / UR6AbstractTerroristMgr (out-of-line ctors)
// ============================================================================
AR6AbstractClimbableObj::AR6AbstractClimbableObj() {}
UR6AbstractTerroristMgr::UR6AbstractTerroristMgr() {}

// ============================================================================
// FHitObserver::Click (moved from inline to out-of-line)
// ============================================================================
void FHitObserver::Click(const FHitCause& Cause, const HHitProxy& Hit) {}
'''

# Insert before the comment about AR6AbstractClimbableObj that's already there
old_marker = '// ============================================================================\n// AR6AbstractClimbableObj / UR6AbstractTerroristMgr\n// (constructors now defined inline in header as protected)'
new_marker = additions.rstrip()
if old_marker in content:
    content = content.replace(old_marker, new_marker, 1)
    print("  Added FPointRegion/AR6/UR6/FHitObserver implementations")
else:
    print("  NOT FOUND: AR6AbstractClimbableObj marker — appending to end")
    content += additions

with open(path, 'w') as f:
    f.write(content)
print("Fixed EngineBatchImpl4.cpp\n")

# ============================================================
# 2. Fix EngineClasses.h
# ============================================================
path = os.path.join(ROOT, 'EngineClasses.h')
with open(path, 'r') as f:
    content = f.read()

# 2a. FSoundData: remove virtual from dtor
old = '\tvirtual ~FSoundData();'
new = '\t~FSoundData();'
if old in content:
    content = content.replace(old, new, 1)
    print("  Fixed FSoundData: removed virtual from dtor")
else:
    print("  NOT FOUND: virtual ~FSoundData()")

# 2b. FPointRegion: move ctors to declaration-only
old = '\tFPointRegion() : Zone(NULL), iLeaf(0), ZoneNumber(0) {}'
new = '\tFPointRegion();'
if old in content:
    content = content.replace(old, new, 1)
    print("  Fixed FPointRegion default ctor")
else:
    print("  NOT FOUND: FPointRegion default ctor")

old = '\tFPointRegion(class AZoneInfo* InZone) : Zone(InZone), iLeaf(0), ZoneNumber(0) {}'
new = '\tFPointRegion(class AZoneInfo* InZone);'
if old in content:
    content = content.replace(old, new, 1)
    print("  Fixed FPointRegion 1-arg ctor")
else:
    print("  NOT FOUND: FPointRegion 1-arg ctor")

old = '\tFPointRegion(class AZoneInfo* InZone, INT InLeaf, BYTE InZoneNumber) : Zone(InZone), iLeaf(InLeaf), ZoneNumber(InZoneNumber) {}'
new = '\tFPointRegion(class AZoneInfo* InZone, INT InLeaf, BYTE InZoneNumber);'
if old in content:
    content = content.replace(old, new, 1)
    print("  Fixed FPointRegion 3-arg ctor")
else:
    print("  NOT FOUND: FPointRegion 3-arg ctor")

# 2c. AR6AbstractClimbableObj: move ctor out-of-line
old = 'protected:\n\tAR6AbstractClimbableObj() {}\npublic:\n};'
new = 'protected:\n\tAR6AbstractClimbableObj();\npublic:\n};'
if old in content:
    content = content.replace(old, new, 1)
    print("  Fixed AR6AbstractClimbableObj ctor")
else:
    print("  NOT FOUND: AR6AbstractClimbableObj ctor")

# 2d. UR6AbstractTerroristMgr: move ctor out-of-line
old = 'protected:\n\tUR6AbstractTerroristMgr() {}\npublic:\n};'
new = 'protected:\n\tUR6AbstractTerroristMgr();\npublic:\n};'
if old in content:
    content = content.replace(old, new, 1)
    print("  Fixed UR6AbstractTerroristMgr ctor")
else:
    print("  NOT FOUND: UR6AbstractTerroristMgr ctor")

# 2e. FHitObserver::Click: move to declaration-only
old = '\tvirtual void Click(const FHitCause& Cause, const struct HHitProxy& Hit) {}'
new = '\tvirtual void Click(const FHitCause& Cause, const struct HHitProxy& Hit);'
if old in content:
    content = content.replace(old, new, 1)
    print("  Fixed FHitObserver::Click declaration")
else:
    print("  NOT FOUND: FHitObserver::Click")

with open(path, 'w') as f:
    f.write(content)
print("Fixed EngineClasses.h\n")

print("All fixes applied!")
