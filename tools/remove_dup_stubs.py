"""Remove duplicate function definitions from EngineStubs.cpp.

These functions are already implemented in UnMaterial.cpp, UnPawn.cpp,
or EngineClassImpl.cpp and should not also exist in EngineStubs.cpp.
"""
import re

STUBS_FILE = "src/engine/Src/EngineStubs.cpp"

# Exact function signatures to remove (as they appear at start of line)
DUPLICATES = [
    # UnMaterial.cpp duplicates - UMaterial
    "void UMaterial::Serialize(FArchive &)",
    "void UMaterial::SetValidated(int)",
    "int UMaterial::CheckCircularReferences(TArray<UMaterial *> &)",
    "int UMaterial::GetValidated()",
    "int UMaterial::HasFallback()",
    "int UMaterial::IsTransparent()",
    "BYTE UMaterial::RequiredUVStreams()",
    "int UMaterial::RequiresSorting()",
    "int UMaterial::MaterialUSize()",
    "int UMaterial::MaterialVSize()",
    # UBitmapMaterial
    "int UBitmapMaterial::MaterialUSize()",
    "int UBitmapMaterial::MaterialVSize()",
    # UTexture
    "void UTexture::Serialize(FArchive &)",
    "void UTexture::Destroy()",
    "int UTexture::IsTransparent()",
    "int UTexture::RequiresSorting()",
    "void UTexture::PostLoad()",
    # UShader
    "BYTE UShader::RequiredUVStreams()",
    "int UShader::RequiresSorting()",
    "int UShader::MaterialUSize()",
    "int UShader::MaterialVSize()",
    "void UShader::PostEditChange()",
    "int UShader::CheckCircularReferences(TArray<UMaterial *> &)",
    "int UShader::HasFallback()",
    "int UShader::IsTransparent()",
    # UModifier
    "BYTE UModifier::RequiredUVStreams()",
    "int UModifier::RequiresSorting()",
    "int UModifier::MaterialUSize()",
    "int UModifier::MaterialVSize()",
    "void UModifier::PostEditChange()",
    "int UModifier::CheckCircularReferences(TArray<UMaterial *> &)",
    "int UModifier::IsTransparent()",
    # UCombiner
    "BYTE UCombiner::RequiredUVStreams()",
    "int UCombiner::RequiresSorting()",
    "int UCombiner::MaterialUSize()",
    "int UCombiner::MaterialVSize()",
    "void UCombiner::PostEditChange()",
    "int UCombiner::CheckCircularReferences(TArray<UMaterial *> &)",
    "int UCombiner::IsTransparent()",
    # UFinalBlend
    "int UFinalBlend::RequiresSorting()",
    "void UFinalBlend::SetValidated(int)",
    "void UFinalBlend::PostEditChange()",
    "int UFinalBlend::GetValidated()",
    "int UFinalBlend::IsTransparent()",
    # UPalette
    "void UPalette::Serialize(FArchive &)",
    # UnPawn.cpp duplicate
    "int APawn::findNewFloor(FVector,float,float,int)",
    # EngineClassImpl.cpp duplicates - UViewport
    "int UViewport::Exec(TCHAR const *,FOutputDevice &)",
    "void UViewport::Serialize(TCHAR const *,EName)",
    "void UViewport::Destroy()",
    "void UViewport::Serialize(FArchive &)",
    # UNetConnection
    "int UNetConnection::Exec(TCHAR const *,FOutputDevice &)",
    "void UNetConnection::Serialize(TCHAR const *,EName)",
    "void UNetConnection::Destroy()",
    "void UNetConnection::Serialize(FArchive &)",
    # AReplicationInfo
    "void AReplicationInfo::StaticConstructor()",
    "void AReplicationInfo::StartVideo(UCanvas *,int,int,int)",
    "void AReplicationInfo::StopVideo(UCanvas *)",
    "int AReplicationInfo::OpenVideo(UCanvas *,char *,char *,int)",
    "void AReplicationInfo::ChangeDrawingSurface(ER6SwitchSurface,int)",
    "void AReplicationInfo::CloseVideo(UCanvas *)",
]

def remove_function(content, sig):
    """Remove a function definition: signature + { body }"""
    escaped = re.escape(sig)
    # Match: signature\n{\nbody\n}\n
    pattern = escaped + r'\s*\n\{[^}]*\}\n?'
    new_content, count = re.subn(pattern, '', content)
    return new_content, count

with open(STUBS_FILE, 'r') as f:
    content = f.read()

orig_len = len(content)
removed = 0
not_found = []

for sig in DUPLICATES:
    new_content, count = remove_function(content, sig)
    if count > 0:
        content = new_content
        removed += count
    else:
        not_found.append(sig)

with open(STUBS_FILE, 'w') as f:
    f.write(content)

print(f"Removed {removed} duplicate stubs")
print(f"Size reduction: {orig_len - len(content)} chars")
if not_found:
    print(f"\nNot found ({len(not_found)}):")
    for s in not_found:
        print(f"  {s}")
