"""Fix build errors from the first round of changes."""

CLASSES_H = 'src/engine/EngineClasses.h'
content = open(CLASSES_H).read()

# 1. Remove duplicate FSortedPathList at early position (line 312 area)
# Replace first FSortedPathList definition with just forward decl
old_first_sorted = '''class ENGINE_API FSortedPathList
{
public:
\tBYTE Pad[64];
\tFSortedPathList();
\tvoid addPath(ANavigationPoint*, INT);
};'''
# This should be the first occurrence
idx1 = content.find(old_first_sorted)
idx2 = content.find(old_first_sorted, idx1+1) if idx1 >= 0 else -1
if idx1 >= 0 and idx1 < 500:  # Should be early in file
    content = content[:idx1] + 'class FSortedPathList;' + content[idx1+len(old_first_sorted):]
    print('OK: Removed duplicate FSortedPathList definition at early position')

# 2. Add addPath + FSortedPathList() ctor to existing FSortedPathList definition
content = content.replace(
    '''class ENGINE_API FSortedPathList
{
public:
\tBYTE Pad[64];
\tANavigationPoint* findEndAnchor(APawn*, AActor*, FVector, INT);
\tANavigationPoint* findStartAnchor(APawn*);
};''',
    '''class ENGINE_API FSortedPathList
{
public:
\tBYTE Pad[64];
\tFSortedPathList();
\tvoid addPath(ANavigationPoint*, INT);
\tANavigationPoint* findEndAnchor(APawn*, AActor*, FVector, INT);
\tANavigationPoint* findStartAnchor(APawn*);
};''', 1)
print('OK: Added FSortedPathList methods to existing definition')

# 3. Add AWarpZoneInfo forward declaration before scene node classes
content = content.replace(
    'class ENGINE_API FWarpZoneSceneNode : public FSceneNode',
    'class AWarpZoneInfo;\n\nclass ENGINE_API FWarpZoneSceneNode : public FSceneNode', 1)
print('OK: Added AWarpZoneInfo forward declaration')

# 4. Move EChannelType before UNetConnection (which uses it)
# Remove from current position (before UChannel)
content = content.replace(
    'enum EChannelType { CHTYPE_None=0, CHTYPE_Control=1, CHTYPE_Actor=2, CHTYPE_File=3, CHTYPE_MAX=8 };\n\nclass ENGINE_API UChannel : public UObject',
    'class ENGINE_API UChannel : public UObject', 1)
# Add before UNetConnection
content = content.replace(
    'class ENGINE_API UNetConnection : public UPlayer',
    'enum EChannelType { CHTYPE_None=0, CHTYPE_Control=1, CHTYPE_Actor=2, CHTYPE_File=3, CHTYPE_MAX=8 };\n\nclass ENGINE_API UNetConnection : public UPlayer', 1)
print('OK: Moved EChannelType enum before UNetConnection')

# 5. UPackageMapLevel needs default ctor (DECLARE_CLASS requires it)
content = content.replace(
    '''class ENGINE_API UPackageMapLevel : public UPackageMap
{
public:
\tDECLARE_CLASS(UPackageMapLevel,UPackageMap,0,Engine)
\tUPackageMapLevel(UNetConnection*);''',
    '''class ENGINE_API UPackageMapLevel : public UPackageMap
{
public:
\tDECLARE_CLASS(UPackageMapLevel,UPackageMap,0,Engine)
\tUPackageMapLevel() {}
\tUPackageMapLevel(UNetConnection*);''', 1)
print('OK: Added UPackageMapLevel default ctor')

# 6. FConvexVolume: check if it's in EngineDecls.h too 
decls_h = 'src/engine/EngineDecls.h'
decls_content = open(decls_h).read()

# FConvexVolume in EngineDecls.h - may have been redefined
# Check if it exists there
if 'class ENGINE_API FConvexVolume' in decls_content:
    # Remove from EngineDecls.h since EngineClasses.h already has it
    decls_content = decls_content.replace('class ENGINE_API FConvexVolume { public: BYTE Pad[256]; };', 
                                          '// FConvexVolume defined in EngineClasses.h', 1)
    open(decls_h, 'w').write(decls_content)
    print('OK: Removed duplicate FConvexVolume from EngineDecls.h')
elif 'FConvexVolume' in decls_content:
    # Find it
    idx = decls_content.find('FConvexVolume')
    print(f'WARN: FConvexVolume in EngineDecls.h at pos {idx}: ...{decls_content[max(0,idx-20):idx+80]}...')
else:
    print('SKIP: FConvexVolume not in EngineDecls.h')

open(CLASSES_H, 'w').write(content)
print(f'Written {CLASSES_H}')
