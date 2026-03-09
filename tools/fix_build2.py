"""
Fix build errors across EngineExtra.cpp, EngineBatchImpl4.cpp, and EngineClasses.h.

1. EngineExtra.cpp: Remove functions that now have new-signature versions in EngineBatchImpl4.cpp
2. EngineClasses.h: Add URenderResource::Serialize, fix FPoly::RemoveColinears return type  
3. EngineBatchImpl4.cpp: Remove TLazyArray<BYTE> definitions (can't override compiler-generated)
"""
import os

ROOT = r'c:\Users\danpo\Desktop\rvs\src\engine'

# ============================================================
# 1. Fix EngineExtra.cpp — remove conflicting old-signature implementations
# ============================================================
path = os.path.join(ROOT, 'EngineExtra.cpp')
with open(path, 'r') as f:
    content = f.read()

# Functions to remove from EngineExtra.cpp (now in EngineBatchImpl4.cpp with correct signatures)
removals = [
    # UGameEngine::BuildServerMasterMap (old returns UNetDriver*, new returns void)
    'UNetDriver* UGameEngine::BuildServerMasterMap( UNetDriver* NetDriver, ULevel* InLevel ) { return NULL; }',
    # UNetConnection::CreateChannel (old has INT, new has EChannelType)
    'UChannel* UNetConnection::CreateChannel( INT ChType, INT bOpenedLocally, INT ChIndex ) { return NULL; }',
    # UNetConnection::PostSend (old has INT param, new has none)
    'void UNetConnection::PostSend( INT PacketId ) {}',
    # UChannel::ChannelClasses (old is function, new is static data member)
    'UClass** UChannel::ChannelClasses() { return NULL; }',
    # UInput methods with INT -> enum types
    'INT UInput::PreProcess( INT Key, INT Action, FLOAT Delta ) { return 0; }',
    'INT UInput::Process( FOutputDevice& Ar, INT Key, INT Action, FLOAT Delta ) { return 0; }',
    'void UInput::DirectAxis( INT Key, FLOAT Value, FLOAT Delta ) {}',
    'const TCHAR* UInput::GetKeyName( INT Key ) const { return TEXT(""); }',
    'INT UInput::FindKeyName( const TCHAR* KeyName, INT& Key ) const { return 0; }',
    'void UInput::SetInputAction( INT Action, FLOAT Delta ) {}',
    # UNullRenderDevice methods with INT -> enum types
    'void UNullRenderDevice::SetEmulationMode( INT Mode ) {}',
    'INT UNullRenderDevice::SupportsTextureFormat( INT Format ) { return 0; }',
]

for line in removals:
    if line in content:
        content = content.replace(line + '\n', '', 1)
        print(f"  Removed: {line[:60]}...")
    else:
        print(f"  NOT FOUND: {line[:60]}...")

with open(path, 'w') as f:
    f.write(content)
print("Fixed EngineExtra.cpp\n")

# ============================================================
# 2. Fix EngineClasses.h
# ============================================================
path = os.path.join(ROOT, 'EngineClasses.h')
with open(path, 'r') as f:
    content = f.read()

# 2a. Add Serialize to URenderResource
old = '''class ENGINE_API URenderResource : public UObject
{
	DECLARE_CLASS(URenderResource,UObject,0,Engine)
	URenderResource() {}
};'''
new = '''class ENGINE_API URenderResource : public UObject
{
	DECLARE_CLASS(URenderResource,UObject,0,Engine)
	URenderResource() {}
	void Serialize(FArchive& Ar);
};'''
if old in content:
    content = content.replace(old, new, 1)
    print("  Added URenderResource::Serialize declaration")
else:
    print("  NOT FOUND: URenderResource class")

# 2b. Fix FPoly::RemoveColinears return type (void -> INT)
old2 = '\tvoid RemoveColinears();'
new2 = '\tINT RemoveColinears();'
if old2 in content:
    content = content.replace(old2, new2, 1)
    print("  Fixed FPoly::RemoveColinears return type to INT")
else:
    print("  NOT FOUND: void RemoveColinears")

with open(path, 'w') as f:
    f.write(content)
print("Fixed EngineClasses.h\n")

# ============================================================
# 3. Fix EngineBatchImpl4.cpp — remove TLazyArray<BYTE> definitions
# ============================================================
path = os.path.join(ROOT, 'EngineBatchImpl4.cpp')
with open(path, 'r') as f:
    content = f.read()

# Remove TLazyArray<BYTE> section
old3 = '''// ============================================================================
// TLazyArray<BYTE>
// ============================================================================
TLazyArray<BYTE>::TLazyArray(const TLazyArray<BYTE>&) {}
TLazyArray<BYTE>& TLazyArray<BYTE>::operator=(const TLazyArray<BYTE>&) { return *this; }'''
new3 = '''// ============================================================================
// TLazyArray<BYTE> — copy ctor and operator= are compiler-generated;
// cannot provide explicit definitions. Left as linker stubs.
// ============================================================================'''
if old3 in content:
    content = content.replace(old3, new3, 1)
    print("  Removed TLazyArray<BYTE> definitions")
else:
    print("  NOT FOUND: TLazyArray<BYTE> section")

with open(path, 'w') as f:
    f.write(content)
print("Fixed EngineBatchImpl4.cpp\n")

print("All fixes applied!")
