/*=============================================================================
    EngineStubs.cpp: Stub method bodies for Engine.dll exported symbols.
    
    Why this file exists
    --------------------
    The retail Engine.dll exports ~800 C++ methods by ordinal via its .def
    file. Each ordinal must resolve to a real symbol in the DLL or the
    linker will error. For methods we haven't decompiled yet, this file
    provides trivial "stub" bodies: empty functions, return 0, return NULL,
    etc. They have the correct signature so the mangled symbol name matches
    the .def entry, but they don't do any real work.

    As each method is properly reverse-engineered, its real implementation
    goes into the appropriate per-class file (UnActor.cpp, UnLevel.cpp,
    UnMesh.cpp, etc.) and the stub here should be deleted.

    Why #pragma optimize("", off)?
    --------------------------------
    Many stubs have empty bodies or just "return 0". With optimisation
    enabled, MSVC can merge identical function bodies (ICF/COMDAT folding)
    or eliminate them entirely. That would cause multiple .def ordinals to
    point at the same address — or worse, leave ordinals unresolved. 
    Disabling optimisation for this translation unit forces each stub to
    get its own unique address, keeping the export table correct.

    This file is the largest in the Engine module and will shrink over
    time as decompilation progresses.
=============================================================================*/
#pragma optimize("", off)

#include "EnginePrivate.h"
#include "EngineDecls.h"

// Forward declarations for types used in parameters but not fully defined
class AProjector;
struct FProjectorRenderInfo;
struct FPropertyRetirement;
// FVertexComponent is now defined in EngineClasses.h
class AWarpZoneInfo;
class ATerrainInfo;
class FBspNode;
class FStaticMeshBatcherVertex;
struct FStaticMeshCollisionNode;
struct FStaticMeshCollisionTriangle;
class FStaticMeshSection;
struct FStaticMeshTriangle;

// --- ACamera ---
void ACamera::RenderEditorInfo(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
}

void ACamera::RenderEditorSelected(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
}

// --- AMover ---
void AMover::physMovingBrush(float)
{
}

void AMover::performPhysics(float)
{
}

int AMover::ShouldTrace(AActor*,DWORD TraceFlags)
{
	return TraceFlags & 2;
}

void AMover::AddMyMarker(AActor *)
{
}

int * AMover::GetOptimizedRepList(BYTE*,FPropertyRetirement *,int *,UPackageMap *,UActorChannel *)
{
	return NULL;
}

// --- ATerrainInfo ---
void ATerrainInfo::SoftSelect(float,float)
{
}

void ATerrainInfo::Update(float,int,int,int,int,int)
{
}

void ATerrainInfo::UpdateDecorations(int)
{
}

void ATerrainInfo::UpdateTriangles(int,int,int,int,int)
{
}

void ATerrainInfo::UpdateVertices(float,int,int,int,int)
{
}

FVector ATerrainInfo::WorldToHeightmap(FVector)
{
	return FVector(0,0,0);
}

void ATerrainInfo::Render(FLevelSceneNode *,FRenderInterface *,FVisibilityInterface *)
{
}

void ATerrainInfo::RenderDecorations(FLevelSceneNode *,FRenderInterface *,FVisibilityInterface *)
{
}

int ATerrainInfo::SelectVertex(FVector)
{
	return 0;
}

int ATerrainInfo::SelectVertexX(int,int)
{
	return 0;
}

void ATerrainInfo::SelectVerticesInBox(FBox &)
{
}

void ATerrainInfo::SetEdgeTurnBitmap(int,int,int)
{
}

void ATerrainInfo::SetHeightmap(int,int,_WORD)
{
}

void ATerrainInfo::SetLayerAlpha(float,float,int,BYTE,UTexture *)
{
}

void ATerrainInfo::SetPlanningFloorMap(int,int,int)
{
}

void ATerrainInfo::SetQuadVisibilityBitmap(int,int,int)
{
}

void ATerrainInfo::SetTextureColor(int,int,UTexture *,FColor &)
{
}

int ATerrainInfo::LineCheck(FCheckResult &,FVector,FVector,FVector,int)
{
	return 0;
}

int ATerrainInfo::LineCheckWithQuad(int,int,FCheckResult &,FVector,FVector,FVector,int)
{
	return 0;
}

void ATerrainInfo::MoveVertices(float)
{
}

int ATerrainInfo::PointCheck(FCheckResult &,FVector,FVector,int)
{
	return 0;
}

void ATerrainInfo::CalcCoords()
{
}

void ATerrainInfo::CalcLayerTexCoords()
{
}

void ATerrainInfo::CheckComputeDataOnLoad()
{
}

void ATerrainInfo::CombineLayerWeights()
{
}

void ATerrainInfo::ConvertHeightmapFormat()
{
}

int ATerrainInfo::GetClosestVertex(FVector &,FVector *,int *,int *)
{
	return 0;
}

int ATerrainInfo::GetEdgeTurnBitmap(int,int)
{
	return 0;
}

int ATerrainInfo::GetGlobalVertex(int,int)
{
	return 0;
}

_WORD ATerrainInfo::GetHeightmap(int,int)
{
	return 0;
}

BYTE ATerrainInfo::GetLayerAlpha(int,int,int,UTexture *)
{
	return 0;
}

int ATerrainInfo::GetPlanningFloorMap(int,int)
{
	return 0;
}

int ATerrainInfo::GetQuadVisibilityBitmap(int,int)
{
	return 0;
}

int ATerrainInfo::GetRenderCombinationNum(TArray<int> &,ETerrainRenderMethod)
{
	return 0;
}

FBox ATerrainInfo::GetSelectedVerticesBounds()
{
	return FBox();
}

FColor ATerrainInfo::GetTextureColor(int,int,UTexture *)
{
	return FColor(0,0,0,0);
}

FVector ATerrainInfo::GetVertexNormal(int,int)
{
	return FVector(0,0,0);
}

FVector ATerrainInfo::HeightmapToWorld(FVector)
{
	return FVector(0,0,0);
}

void ATerrainInfo::Serialize(FArchive &)
{
}

void ATerrainInfo::CheckForErrors()
{
}

void ATerrainInfo::Destroy()
{
}

UPrimitive * ATerrainInfo::GetPrimitive()
{
	return NULL;
}

// --- FAnimMeshVertexStream ---
int FAnimMeshVertexStream::SetPartialSize(int)
{
	return 0;
}

unsigned __int64 FAnimMeshVertexStream::GetCacheId()
{
	return *(QWORD*)(Pad + 16);
}

int FAnimMeshVertexStream::GetComponents(FVertexComponent* C)
{
	C[0].Type = 1; C[0].Function = 0;
	C[1].Type = 1; C[1].Function = 1;
	C[2].Type = 2; C[2].Function = 4;
	return 3;
}

int FAnimMeshVertexStream::GetPartialSize()
{
	return 0;
}

void FAnimMeshVertexStream::GetRawStreamData(void * *,int)
{
}

int FAnimMeshVertexStream::GetRevision()
{
	return *(INT*)(Pad + 24);
}

int FAnimMeshVertexStream::GetSize()
{
	return 0;
}

void FAnimMeshVertexStream::GetStreamData(void *)
{
}

int FAnimMeshVertexStream::GetStride()
{
	return 0x20;
}

// --- FBspVertexStream ---
unsigned __int64 FBspVertexStream::GetCacheId()
{
	return *(QWORD*)(Pad + 12);
}

int FBspVertexStream::GetComponents(FVertexComponent* C)
{
	C[0].Type = 1; C[0].Function = 0;
	C[1].Type = 1; C[1].Function = 1;
	C[2].Type = 2; C[2].Function = 4;
	C[3].Type = 2; C[3].Function = 5;
	return 4;
}

void FBspVertexStream::GetRawStreamData(void * *,int)
{
}

int FBspVertexStream::GetRevision()
{
	return *(INT*)(Pad + 20);
}

int FBspVertexStream::GetSize()
{
	return 0;
}

void FBspVertexStream::GetStreamData(void *)
{
}

int FBspVertexStream::GetStride()
{
	return 0x28;
}

// --- FCanvasUtil ---
void FCanvasUtil::BeginPrimitive(EPrimitiveType,UMaterial *)
{
}

void FCanvasUtil::DrawLine(float,float,float,float,FColor)
{
}

void FCanvasUtil::DrawPoint(float,float,float,float,float,FColor)
{
}

void FCanvasUtil::DrawTile(float,float,float,float,float,float,float,float,float,UMaterial *,FColor)
{
}

void FCanvasUtil::DrawTileRotated(float,float,float,float,float,float,float,float,float,UMaterial *,FColor,float)
{
}

void FCanvasUtil::Flush()
{
}

unsigned __int64 FCanvasUtil::GetCacheId()
{
	return 0;
}

int FCanvasUtil::GetComponents(FVertexComponent* C)
{
	C[0].Type = 1; C[0].Function = 0;
	C[1].Type = 4; C[1].Function = 2;
	C[2].Type = 2; C[2].Function = 4;
	return 3;
}

void FCanvasUtil::GetRawStreamData(void * *,int)
{
}

int FCanvasUtil::GetRevision()
{
	return 1;
}

int FCanvasUtil::GetSize()
{
	return 0;
}

void FCanvasUtil::GetStreamData(void *)
{
}

int FCanvasUtil::GetStride()
{
	return 0x18;
}

// --- FLevelSceneNode ---
void FLevelSceneNode::Render(FRenderInterface *)
{
}

int FLevelSceneNode::FilterActor(AActor *)
{
	return 0;
}

FLevelSceneNode * FLevelSceneNode::GetLevelSceneNode()
{
	return this;
}

// --- FLightMap ---
unsigned __int64 FLightMap::GetCacheId()
{
	return 0;
}

int FLightMap::GetFirstMip()
{
	return 0;
}

ETextureFormat FLightMap::GetFormat()
{
	return TEXF_BCRGB8;
}

int FLightMap::GetHeight()
{
	return *(INT*)(Pad + 28);
}

int FLightMap::GetNumMips()
{
	return 1;
}

void * FLightMap::GetRawTextureData(int)
{
	return NULL;
}

int FLightMap::GetRevision()
{
	return *(INT*)(Pad + 32);
}

void FLightMap::GetTextureData(int,void *,int,ETextureFormat,int)
{
}

ETexClampMode FLightMap::GetUClamp()
{
	return TC_Clamp;
}

UTexture * FLightMap::GetUTexture()
{
	return NULL;
}

ETexClampMode FLightMap::GetVClamp()
{
	return TC_Clamp;
}

int FLightMap::GetWidth()
{
	return *(INT*)(Pad + 24);
}

// --- FLightMapTexture ---
unsigned __int64 FLightMapTexture::GetCacheId()
{
	return *(QWORD*)(Pad + 92);
}

FTexture * FLightMapTexture::GetChild(int,int *,int *)
{
	return NULL;
}

int FLightMapTexture::GetFirstMip()
{
	return 0;
}

ETextureFormat FLightMapTexture::GetFormat()
{
	return TEXF_BCRGB8;
}

int FLightMapTexture::GetHeight()
{
	return 0x200;
}

int FLightMapTexture::GetNumChildren()
{
	// TArray at this+8; ArrayNum is 4 bytes into TArray
	return *(INT*)(Pad + 8);
}

int FLightMapTexture::GetNumMips()
{
	return 1;
}

int FLightMapTexture::GetRevision()
{
	return *(INT*)(Pad + 100);
}

ETexClampMode FLightMapTexture::GetUClamp()
{
	return TC_Wrap;
}

ETexClampMode FLightMapTexture::GetVClamp()
{
	return TC_Wrap;
}

int FLightMapTexture::GetWidth()
{
	return 0x200;
}

// --- FLineBatcher ---
void FLineBatcher::DrawBox(FBox,FColor)
{
}

void FLineBatcher::DrawCircle(FVector,FVector,FVector,FColor,float,int)
{
}

void FLineBatcher::DrawCylinder(FRenderInterface *,FVector,FVector,FVector,FVector,FColor,float,float,int)
{
}

void FLineBatcher::DrawDirectionalArrow(FVector,FRotator,FColor,float)
{
}

void FLineBatcher::DrawLine(FVector,FVector,FColor)
{
}

void FLineBatcher::DrawPoint(FSceneNode *,FVector,FColor)
{
}

void FLineBatcher::DrawSphere(FVector,FColor,float,int)
{
}

void FLineBatcher::Flush(DWORD)
{
}

unsigned __int64 FLineBatcher::GetCacheId()
{
	return *(QWORD*)(Pad + 12);
}

int FLineBatcher::GetComponents(FVertexComponent* C)
{
	C[0].Type = 1; C[0].Function = 0;
	C[1].Type = 4; C[1].Function = 2;
	return 2;
}

void FLineBatcher::GetRawStreamData(void * *,int)
{
}

int FLineBatcher::GetRevision()
{
	return 1;
}

int FLineBatcher::GetSize()
{
	return 0;
}

void FLineBatcher::GetStreamData(void *)
{
}

int FLineBatcher::GetStride()
{
	return 0;
}

// --- FRaw32BitIndexBuffer ---
unsigned __int64 FRaw32BitIndexBuffer::GetCacheId()
{
	return *(QWORD*)(Pad + 12);
}

void FRaw32BitIndexBuffer::GetContents(void *)
{
}

int FRaw32BitIndexBuffer::GetIndexSize()
{
	return 4;
}

int FRaw32BitIndexBuffer::GetRevision()
{
	return *(INT*)(Pad + 20);
}

int FRaw32BitIndexBuffer::GetSize()
{
	return 0;
}

// --- FRawColorStream ---
unsigned __int64 FRawColorStream::GetCacheId()
{
	return *(QWORD*)(Pad + 12);
}

int FRawColorStream::GetComponents(FVertexComponent* C)
{
	C[0].Type = 4; C[0].Function = 2;
	return 1;
}

void FRawColorStream::GetRawStreamData(void * *,int)
{
}

int FRawColorStream::GetRevision()
{
	return *(INT*)(Pad + 20);
}

int FRawColorStream::GetSize()
{
	return 0;
}

void FRawColorStream::GetStreamData(void *)
{
}

int FRawColorStream::GetStride()
{
	return 4;
}

// --- FRawIndexBuffer ---
void FRawIndexBuffer::CacheOptimize()
{
}

unsigned __int64 FRawIndexBuffer::GetCacheId()
{
	return *(QWORD*)(Pad + 12);
}

void FRawIndexBuffer::GetContents(void *)
{
}

int FRawIndexBuffer::GetIndexSize()
{
	return 2;
}

int FRawIndexBuffer::GetRevision()
{
	return *(INT*)(Pad + 20);
}

int FRawIndexBuffer::GetSize()
{
	return 0;
}

// --- FSkinVertexStream ---
unsigned __int64 FSkinVertexStream::GetCacheId()
{
	return *(QWORD*)(Pad + 8);
}

int FSkinVertexStream::GetComponents(FVertexComponent* C)
{
	C[0].Type = 1; C[0].Function = 0;
	C[1].Type = 1; C[1].Function = 1;
	C[2].Type = 2; C[2].Function = 4;
	return 3;
}

void FSkinVertexStream::GetRawStreamData(void * *,int)
{
}

int FSkinVertexStream::GetRevision()
{
	return *(INT*)(Pad + 16);
}

int FSkinVertexStream::GetSize()
{
	return 0;
}

void FSkinVertexStream::GetStreamData(void *)
{
}

int FSkinVertexStream::GetStride()
{
	return 0x20;
}

// --- FStaticLightMapTexture ---
unsigned __int64 FStaticLightMapTexture::GetCacheId()
{
	return *(QWORD*)(Pad + 60);
}

int FStaticLightMapTexture::GetFirstMip()
{
	return 0;
}

ETextureFormat FStaticLightMapTexture::GetFormat()
{
	return (ETextureFormat)Pad[48];
}

int FStaticLightMapTexture::GetHeight()
{
	return *(INT*)(Pad + 56);
}

int FStaticLightMapTexture::GetNumMips()
{
	return 2;
}

void * FStaticLightMapTexture::GetRawTextureData(int)
{
	return NULL;
}

int FStaticLightMapTexture::GetRevision()
{
	return *(INT*)(Pad + 68);
}

void FStaticLightMapTexture::GetTextureData(int,void *,int,ETextureFormat,int)
{
}

ETexClampMode FStaticLightMapTexture::GetUClamp()
{
	return TC_Wrap;
}

UTexture * FStaticLightMapTexture::GetUTexture()
{
	return NULL;
}

ETexClampMode FStaticLightMapTexture::GetVClamp()
{
	return TC_Wrap;
}

int FStaticLightMapTexture::GetWidth()
{
	return *(INT*)(Pad + 52);
}
unsigned __int64 FStaticMeshUVStream::GetCacheId()
{
	return *(QWORD*)(Pad + 16);
}

int FStaticMeshUVStream::GetComponents(FVertexComponent* C)
{
	C[0].Type = 2; C[0].Function = *(INT*)(Pad + 0x0C) + 4;
	return 1;
}

void FStaticMeshUVStream::GetRawStreamData(void * *,int)
{
}

int FStaticMeshUVStream::GetRevision()
{
	return *(INT*)(Pad + 24);
}

int FStaticMeshUVStream::GetSize()
{
	return 0;
}

void FStaticMeshUVStream::GetStreamData(void *)
{
}

int FStaticMeshUVStream::GetStride()
{
	return 8;
}
unsigned __int64 FStaticMeshVertexStream::GetCacheId()
{
	return *(QWORD*)(Pad + 12);
}

int FStaticMeshVertexStream::GetComponents(FVertexComponent* C)
{
	C[0].Type = 1; C[0].Function = 0;
	C[1].Type = 1; C[1].Function = 1;
	return 2;
}

void FStaticMeshVertexStream::GetRawStreamData(void * *,int)
{
}

int FStaticMeshVertexStream::GetRevision()
{
	return *(INT*)(Pad + 20);
}

int FStaticMeshVertexStream::GetSize()
{
	return 0;
}

void FStaticMeshVertexStream::GetStreamData(void *)
{
}

int FStaticMeshVertexStream::GetStride()
{
	return 0x18;
}

// --- FStaticTexture ---
unsigned __int64 FStaticTexture::GetCacheId()
{
	return 0;
}

int FStaticTexture::GetFirstMip()
{
	return 0;
}

ETextureFormat FStaticTexture::GetFormat()
{
	return TEXF_P8;
}

int FStaticTexture::GetHeight()
{
	return 0;
}

int FStaticTexture::GetNumMips()
{
	return 0;
}

void * FStaticTexture::GetRawTextureData(int)
{
	return NULL;
}

int FStaticTexture::GetRevision()
{
	return 0;
}

void FStaticTexture::GetTextureData(int,void *,int,ETextureFormat,int)
{
}

ETexClampMode FStaticTexture::GetUClamp()
{
	return TC_Wrap;
}

UTexture * FStaticTexture::GetUTexture()
{
	return NULL;
}

ETexClampMode FStaticTexture::GetVClamp()
{
	return TC_Wrap;
}

int FStaticTexture::GetWidth()
{
	return 0;
}

// --- UBinaryFileDownload ---
void UBinaryFileDownload::ReceiveData(BYTE*,int)
{
}

void UBinaryFileDownload::ReceiveFile(UNetConnection *,int,const TCHAR*,int)
{
}

void UBinaryFileDownload::Serialize(FArchive &)
{
}

void UBinaryFileDownload::Destroy()
{
}

void UBinaryFileDownload::DownloadDone()
{
}

void UBinaryFileDownload::DownloadError(const TCHAR*)
{
}

// --- UCanvas ---
void UCanvas::SetVirtualSize(float,float)
{
}

void UCanvas::StartFade(FColor,FColor,float,int)
{
}

void UCanvas::UseVirtualSize(int,float,float)
{
}

void UCanvas::SetStretch(float,float)
{
}

void UCanvas::DrawTileClipped(UMaterial *,float,float,float,float,float,float)
{
}

int UCanvas::_DrawString(UFont *,int,int,const TCHAR*,FPlane,int,int,int)
{
	return 0;
}

void UCanvas::WrappedDrawString(ERenderStyle,int &,int &,UFont *,int,const TCHAR*)
{
}

void UCanvas::SetClip(int,int,int,int)
{
}

void UCanvas::DrawIcon(UMaterial *,float,float,float,float,float,FPlane,FPlane)
{
}

void UCanvas::DrawPattern(UMaterial *,float,float,float,float,float,float,float,float,FPlane,FPlane)
{
}

void UCanvas::DrawTile(UMaterial *,float,float,float,float,float,float,float,float,float,FPlane,FPlane,float)
{
}

// --- UChannel ---
int UChannel::SendBunch(FOutBunch *,int)
{
	return 0;
}

// --- UFileChannel ---
void UFileChannel::ReceivedBunch(FInBunch &)
{
}

FString UFileChannel::Describe()
{
	return FString();
}

void UFileChannel::Destroy()
{
}

void UFileChannel::Init(UNetConnection *,int,int)
{
}

// --- UGameEngine ---
// --- UInput ---
// --- ULodMeshInstance ---
FMeshAnimSeq * ULodMeshInstance::GetAnimSeq(FName)
{
	return NULL;
}

void ULodMeshInstance::Serialize(FArchive &)
{
}

void ULodMeshInstance::SetActor(AActor *)
{
}

void ULodMeshInstance::SetMesh(UMesh *)
{
}

void ULodMeshInstance::SetStatus(int)
{
}

AActor * ULodMeshInstance::GetActor()
{
	return NULL;
}

void ULodMeshInstance::GetFrame(AActor *,FLevelSceneNode *,FVector *,int,int &,DWORD)
{
}

UMaterial * ULodMeshInstance::GetMaterial(int,AActor *)
{
	return NULL;
}

UMesh * ULodMeshInstance::GetMesh()
{
	return NULL;
}

void ULodMeshInstance::GetMeshVerts(AActor *,FVector *,int,int &)
{
}

int ULodMeshInstance::GetStatus()
{
	return 0;
}

// --- UMaterial ---
UMaterial * UMaterial::ConvertPolyFlagsToMaterial(UMaterial *,DWORD)
{
	return NULL;
}




// --- UMeshInstance ---
int UMeshInstance::StopAnimating(int)
{
	return 0;
}

int UMeshInstance::UpdateAnimation(float)
{
	return 0;
}

void UMeshInstance::Render(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
}

void UMeshInstance::SetActor(AActor *)
{
}

void UMeshInstance::SetAnimFrame(int,float)
{
}

void UMeshInstance::SetMesh(UMesh *)
{
}

void UMeshInstance::SetScale(FVector)
{
}

void UMeshInstance::SetStatus(int)
{
}

int UMeshInstance::LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD)
{
	return 0;
}

int UMeshInstance::PlayAnim(int,FName,float,float,int,int,int)
{
	return 0;
}

int UMeshInstance::PointCheck(FCheckResult &,AActor *,FVector,FVector,DWORD)
{
	return 0;
}

int UMeshInstance::AnimForcePose(FName,float,float,int)
{
	return 0;
}

float UMeshInstance::AnimGetFrameCount(void *)
{
	return 0.0f;
}

FName UMeshInstance::AnimGetGroup(void *)
{
	return FName(NAME_None);
}

FName UMeshInstance::AnimGetName(void *)
{
	return FName(NAME_None);
}

int UMeshInstance::AnimGetNotifyCount(void *)
{
	return 0;
}

UAnimNotify * UMeshInstance::AnimGetNotifyObject(void *,int)
{
	return NULL;
}

const TCHAR* UMeshInstance::AnimGetNotifyText(void *,int)
{
	return NULL;
}

float UMeshInstance::AnimGetNotifyTime(void *,int)
{
	return 0.0f;
}

float UMeshInstance::AnimGetRate(void *)
{
	return 0.0f;
}

int UMeshInstance::AnimIsInGroup(void *,FName)
{
	return 0;
}

int UMeshInstance::AnimStopLooping(int)
{
	return 0;
}

void UMeshInstance::ClearChannel(int)
{
}

int UMeshInstance::FreezeAnimAt(float,int)
{
	return 0;
}

float UMeshInstance::GetActiveAnimFrame(int)
{
	return 0.0f;
}

float UMeshInstance::GetActiveAnimRate(int)
{
	return 0.0f;
}

FName UMeshInstance::GetActiveAnimSequence(int)
{
	return FName(NAME_None);
}

AActor * UMeshInstance::GetActor()
{
	return NULL;
}

int UMeshInstance::GetAnimCount()
{
	return 0;
}

void * UMeshInstance::GetAnimIndexed(int)
{
	return NULL;
}

void * UMeshInstance::GetAnimNamed(FName)
{
	return NULL;
}

FBox UMeshInstance::GetCollisionBoundingBox(const AActor*)
{
	return FBox();
}

void UMeshInstance::GetFrame(AActor *,FLevelSceneNode *,FVector *,int,int &,DWORD)
{
}

UMaterial * UMeshInstance::GetMaterial(int,AActor *)
{
	return NULL;
}

UMesh * UMeshInstance::GetMesh()
{
	return NULL;
}

FBox UMeshInstance::GetRenderBoundingBox(const AActor*)
{
	return FBox();
}

FSphere UMeshInstance::GetRenderBoundingSphere(const AActor*)
{
	return FSphere();
}

int UMeshInstance::GetStatus()
{
	return 0;
}

int UMeshInstance::IsAnimating(int)
{
	return 0;
}

int UMeshInstance::IsAnimLooping(int)
{
	return 0;
}

int UMeshInstance::IsAnimPastLastFrame(int)
{
	return 0;
}

int UMeshInstance::IsAnimTweening(int)
{
	return 0;
}

// --- UNetConnection ---
// --- UNetDriver ---
void UNetDriver::TickDispatch(float)
{
}

void UNetDriver::Serialize(FArchive &)
{
}

void UNetDriver::NotifyActorDestroyed(AActor *)
{
}

void UNetDriver::AssertValid()
{
}

void UNetDriver::Destroy()
{
}

int UNetDriver::InitConnect(FNetworkNotify *,FURL &,FString &)
{
	return 0;
}

int UNetDriver::InitListen(FNetworkNotify *,FURL &,FString &)
{
	return 0;
}

// --- UNullRenderDevice ---
// --- USkeletalMesh ---
void USkeletalMesh::m_bLoadLbpFile(FString)
{
}

int USkeletalMesh::SetAttachAlias(FName,FName,FCoords &)
{
	return 0;
}

int USkeletalMesh::SetAttachmentLocation(AActor *,AActor *)
{
	return 0;
}

int USkeletalMesh::LODFootprint(int,int)
{
	return 0;
}

void USkeletalMesh::NormalizeInfluences(int)
{
}

void USkeletalMesh::CalculateNormals(TArray<FVector> &,int)
{
}

void USkeletalMesh::ClearAttachAliases()
{
}

void USkeletalMesh::FlipFaces()
{
}

void USkeletalMesh::GenerateLodModel(int,float,float,int,int)
{
}

void USkeletalMesh::InsertLodModel(int,USkeletalMesh *,float,int)
{
}

int USkeletalMesh::UseCylinderCollision(const AActor*)
{
	return 0;
}

int USkeletalMesh::R6LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD)
{
	return 0;
}

void USkeletalMesh::Serialize(FArchive &)
{
}

int USkeletalMesh::LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD)
{
	return 0;
}

int USkeletalMesh::MemFootprint(int)
{
	return 0;
}

void USkeletalMesh::Destroy()
{
}

FBox USkeletalMesh::GetCollisionBoundingBox(const AActor*) const
{
	return FBox();
}

FBox USkeletalMesh::GetRenderBoundingBox(const AActor*)
{
	return FBox();
}

FSphere USkeletalMesh::GetRenderBoundingSphere(const AActor*)
{
	return FSphere();
}

// --- USkeletalMeshInstance ---
int USkeletalMeshInstance::TraceHeadHit(FCheckResult &,FVector const &,FVector const &,FVector const &,float const &)
{
	return 0;
}

void USkeletalMeshInstance::UpdateBlendAlpha(int,float,float)
{
}

int USkeletalMeshInstance::ValidateAnimChannel(int)
{
	return 0;
}

void USkeletalMeshInstance::SetAnimRate(int,float)
{
}

void USkeletalMeshInstance::SetAnimSequence(int,FName)
{
}

void USkeletalMeshInstance::SetBlendAlpha(int,float)
{
}

int USkeletalMeshInstance::SetBlendParams(int,float,float,float,FName,int)
{
	return 0;
}

int USkeletalMeshInstance::SetBoneDirection(FName,FRotator,FVector,float)
{
	return 0;
}

int USkeletalMeshInstance::SetBoneLocation(FName,FVector,float)
{
	return 0;
}

int USkeletalMeshInstance::SetBonePosition(FName,FRotator,FVector,float)
{
	return 0;
}

int USkeletalMeshInstance::SetBoneRotation(FName,FRotator,int,float,float)
{
	return 0;
}

int USkeletalMeshInstance::SetBoneScale(int,float,FName)
{
	return 0;
}

int USkeletalMeshInstance::SetSkelAnim(UMeshAnimation *,USkeletalMesh *)
{
	return 0;
}

int USkeletalMeshInstance::LockRootMotion(int,int)
{
	return 0;
}

int USkeletalMeshInstance::MatchRefBone(FName)
{
	return 0;
}

void USkeletalMeshInstance::BlendToAlpha(int,float,float)
{
}

void USkeletalMeshInstance::BuildPivotsList()
{
}

void USkeletalMeshInstance::ClearSkelAnims()
{
}

void USkeletalMeshInstance::CopyAnimation(int,int)
{
}

void USkeletalMeshInstance::DrawCollisionCylinders(FSceneNode *)
{
}

int USkeletalMeshInstance::EnableChannelNotify(int,int)
{
	return 0;
}

void USkeletalMeshInstance::ForceAnimRate(int,float)
{
}

int USkeletalMeshInstance::GetAnimChannelCount()
{
	return 0;
}

float USkeletalMeshInstance::GetAnimFrame(int)
{
	return 0.0f;
}

float USkeletalMeshInstance::GetAnimRateOnChannel(int)
{
	return 0.0f;
}

FName USkeletalMeshInstance::GetAnimSequence(int)
{
	return FName(NAME_None);
}

float USkeletalMeshInstance::GetBlendAlpha(int)
{
	return 0.0f;
}

FCoords USkeletalMeshInstance::GetBoneCoords(DWORD,int)
{
	return FCoords();
}

int USkeletalMeshInstance::GetBoneCylinder(int,FCylinder &)
{
	return 0;
}

FName USkeletalMeshInstance::GetBoneName(FName)
{
	return FName(NAME_None);
}

FRotator USkeletalMeshInstance::GetBoneRotation(DWORD,int)
{
	return FRotator(0,0,0);
}

FRotator USkeletalMeshInstance::GetBoneRotation(FName,int)
{
	return FRotator(0,0,0);
}

FVector USkeletalMeshInstance::GetRootLocation()
{
	return FVector(0,0,0);
}

FVector USkeletalMeshInstance::GetRootLocationDelta()
{
	return FVector(0,0,0);
}

FRotator USkeletalMeshInstance::GetRootRotation()
{
	return FRotator(0,0,0);
}

FRotator USkeletalMeshInstance::GetRootRotationDelta()
{
	return FRotator(0,0,0);
}

FCoords USkeletalMeshInstance::GetTagCoords(FName)
{
	return FCoords();
}

FCoords USkeletalMeshInstance::GetTagPosition(FName)
{
	return FCoords();
}

int USkeletalMeshInstance::StopAnimating(int)
{
	return 0;
}

int USkeletalMeshInstance::UpdateAnimation(float)
{
	return 0;
}

void USkeletalMeshInstance::Render(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
}

void USkeletalMeshInstance::Serialize(FArchive &)
{
}

void USkeletalMeshInstance::SetAnimFrame(int,float)
{
}

void USkeletalMeshInstance::SetMesh(UMesh *)
{
}

void USkeletalMeshInstance::SetScale(FVector)
{
}

int USkeletalMeshInstance::LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD)
{
	return 0;
}

void USkeletalMeshInstance::MeshSkinVertsCallback(void *)
{
}

int USkeletalMeshInstance::PlayAnim(int,FName,float,float,int,int,int)
{
	return 0;
}

int USkeletalMeshInstance::ActiveVertStreamSize()
{
	return 0;
}

void USkeletalMeshInstance::ActualizeAnimLinkups()
{
}

int USkeletalMeshInstance::AnimForcePose(FName,float,float,int)
{
	return 0;
}

float USkeletalMeshInstance::AnimGetFrameCount(void *)
{
	return 0.0f;
}

FName USkeletalMeshInstance::AnimGetGroup(void *)
{
	return FName(NAME_None);
}

FName USkeletalMeshInstance::AnimGetName(void *)
{
	return FName(NAME_None);
}

int USkeletalMeshInstance::AnimGetNotifyCount(void *)
{
	return 0;
}

UAnimNotify * USkeletalMeshInstance::AnimGetNotifyObject(void *,int)
{
	return NULL;
}

const TCHAR* USkeletalMeshInstance::AnimGetNotifyText(void *,int)
{
	return NULL;
}

float USkeletalMeshInstance::AnimGetNotifyTime(void *,int)
{
	return 0.0f;
}

float USkeletalMeshInstance::AnimGetRate(void *)
{
	return 0.0f;
}

int USkeletalMeshInstance::AnimIsInGroup(void *,FName)
{
	return 0;
}

int USkeletalMeshInstance::AnimStopLooping(int)
{
	return 0;
}

void USkeletalMeshInstance::ClearChannel(int)
{
}

UMeshAnimation * USkeletalMeshInstance::CurrentSkelAnim(int)
{
	return NULL;
}

void USkeletalMeshInstance::Destroy()
{
}

UMeshAnimation * USkeletalMeshInstance::FindAnimObjectForSequence(FName)
{
	return NULL;
}

int USkeletalMeshInstance::FreezeAnimAt(float,int)
{
	return 0;
}

float USkeletalMeshInstance::GetActiveAnimFrame(int)
{
	return 0.0f;
}

float USkeletalMeshInstance::GetActiveAnimRate(int)
{
	return 0.0f;
}

FName USkeletalMeshInstance::GetActiveAnimSequence(int)
{
	return FName(NAME_None);
}

int USkeletalMeshInstance::GetAnimCount()
{
	return 0;
}

void * USkeletalMeshInstance::GetAnimIndexed(int)
{
	return NULL;
}

void * USkeletalMeshInstance::GetAnimNamed(FName)
{
	return NULL;
}

void USkeletalMeshInstance::GetFrame(AActor *,FLevelSceneNode *,FVector *,int,int &,DWORD)
{
}

UMaterial * USkeletalMeshInstance::GetMaterial(int,AActor *)
{
	return NULL;
}

void USkeletalMeshInstance::GetMeshVerts(AActor *,FVector *,int,int &)
{
}

FBox USkeletalMeshInstance::GetRenderBoundingBox(const AActor*)
{
	return FBox();
}

FSphere USkeletalMeshInstance::GetRenderBoundingSphere(const AActor*)
{
	return FSphere();
}

int USkeletalMeshInstance::IsAnimating(int)
{
	return 0;
}

int USkeletalMeshInstance::IsAnimLooping(int)
{
	return 0;
}

int USkeletalMeshInstance::IsAnimPastLastFrame(int)
{
	return 0;
}

int USkeletalMeshInstance::IsAnimTweening(int)
{
	return 0;
}

// --- USound ---
void USound::Serialize(FArchive &)
{
}

void USound::Destroy()
{
}

float USound::GetDuration()
{
	return 0.0f;
}

// --- UStaticMesh ---
void UStaticMesh::TriangleSphereQuery(AActor *,FSphere &,TArray<FStaticMeshCollisionTriangle *> &)
{
}

void UStaticMesh::Build()
{
}

UMaterial * UStaticMesh::GetSkin(AActor *,int)
{
	return NULL;
}

FTags * UStaticMesh::GetTag(FString)
{
	return NULL;
}

void UStaticMesh::Serialize(FArchive &)
{
}

int UStaticMesh::LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD)
{
	return 0;
}

int UStaticMesh::PointCheck(FCheckResult &,AActor *,FVector,FVector,DWORD)
{
	return 0;
}

void UStaticMesh::Destroy()
{
}

FBox UStaticMesh::GetCollisionBoundingBox(const AActor*) const
{
	return FBox();
}

FVector UStaticMesh::GetEncroachCenter(AActor *)
{
	return FVector(0,0,0);
}

FVector UStaticMesh::GetEncroachExtent(AActor *)
{
	return FVector(0,0,0);
}

FBox UStaticMesh::GetRenderBoundingBox(const AActor*)
{
	return FBox();
}

FSphere UStaticMesh::GetRenderBoundingSphere(const AActor*)
{
	return FSphere();
}

void UStaticMesh::Illuminate(AActor *,int)
{
}

// --- UTexture ---
void UTexture::SetLastUpdateTime(double)
{
}

int UTexture::Compress(ETextureFormat,int,FDXTCompressionOptions *)
{
	return 0;
}

ETextureFormat UTexture::ConvertDXT(int,int,int,void * *)
{
	return TEXF_P8;
}

ETextureFormat UTexture::ConvertDXT()
{
	return TEXF_P8;
}

void UTexture::CreateColorRange()
{
}

void UTexture::CreateMips(int,int)
{
}

int UTexture::Decompress(ETextureFormat)
{
	return 0;
}

int UTexture::DefaultLOD()
{
	return 0;
}

FColor * UTexture::GetColors()
{
	return NULL;
}

DWORD UTexture::GetColorsIndex()
{
	return 0;
}

FString UTexture::GetFormatDesc()
{
	return FString();
}

double UTexture::GetLastUpdateTime()
{
	return 0.0;
}

FMipmapBase * UTexture::GetMip(int)
{
	return NULL;
}

int UTexture::GetNumMips()
{
	return 0;
}

FColor UTexture::GetTexel(float,float,float,float)
{
	return FColor(0,0,0,0);
}

void UTexture::Tick(float)
{
}


void UTexture::ArithOp(UTexture *,ETextureArithOp)
{
}

void UTexture::Clear(DWORD)
{
}

void UTexture::Clear(FColor)
{
}

void UTexture::ConstantTimeTick()
{
}


UBitmapMaterial * UTexture::Get(double,UViewport *)
{
	return NULL;
}

FBaseTexture * UTexture::GetRenderInterface()
{
	return NULL;
}

void UTexture::Init(int,int)
{
}


// --- UVertMeshInstance ---
FMeshAnimSeq * UVertMeshInstance::GetAnimSeq(FName)
{
	return NULL;
}

int UVertMeshInstance::StopAnimating(int)
{
	return 0;
}

int UVertMeshInstance::UpdateAnimation(float)
{
	return 0;
}

void UVertMeshInstance::Render(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
}

void UVertMeshInstance::Serialize(FArchive &)
{
}

void UVertMeshInstance::SetAnimFrame(int,float)
{
}

void UVertMeshInstance::SetScale(FVector)
{
}

int UVertMeshInstance::PlayAnim(int,FName,float,float,int,int,int)
{
	return 0;
}

int UVertMeshInstance::AnimForcePose(FName,float,float,int)
{
	return 0;
}

float UVertMeshInstance::AnimGetFrameCount(void *)
{
	return 0.0f;
}

FName UVertMeshInstance::AnimGetGroup(void *)
{
	return FName(NAME_None);
}

FName UVertMeshInstance::AnimGetName(void *)
{
	return FName(NAME_None);
}

int UVertMeshInstance::AnimGetNotifyCount(void *)
{
	return 0;
}

UAnimNotify * UVertMeshInstance::AnimGetNotifyObject(void *,int)
{
	return NULL;
}

const TCHAR* UVertMeshInstance::AnimGetNotifyText(void *,int)
{
	return NULL;
}

float UVertMeshInstance::AnimGetNotifyTime(void *,int)
{
	return 0.0f;
}

float UVertMeshInstance::AnimGetRate(void *)
{
	return 0.0f;
}

int UVertMeshInstance::AnimIsInGroup(void *,FName)
{
	return 0;
}

int UVertMeshInstance::AnimStopLooping(int)
{
	return 0;
}

float UVertMeshInstance::GetActiveAnimFrame(int)
{
	return 0.0f;
}

float UVertMeshInstance::GetActiveAnimRate(int)
{
	return 0.0f;
}

FName UVertMeshInstance::GetActiveAnimSequence(int)
{
	return FName(NAME_None);
}

int UVertMeshInstance::GetAnimCount()
{
	return 0;
}

void * UVertMeshInstance::GetAnimIndexed(int)
{
	return NULL;
}

void * UVertMeshInstance::GetAnimNamed(FName)
{
	return NULL;
}

void UVertMeshInstance::GetFrame(AActor *,FLevelSceneNode *,FVector *,int,int &,DWORD)
{
}

UMaterial * UVertMeshInstance::GetMaterial(int,AActor *)
{
	return NULL;
}

void UVertMeshInstance::GetMeshVerts(AActor *,FVector *,int,int &)
{
}

FBox UVertMeshInstance::GetRenderBoundingBox(const AActor*)
{
	return FBox();
}

FSphere UVertMeshInstance::GetRenderBoundingSphere(const AActor*)
{
	return FSphere();
}

int UVertMeshInstance::IsAnimating(int)
{
	return 0;
}

int UVertMeshInstance::IsAnimLooping(int)
{
	return 0;
}

int UVertMeshInstance::IsAnimPastLastFrame(int)
{
	return 0;
}

int UVertMeshInstance::IsAnimTweening(int)
{
	return 0;
}



// --- AAIController ---
void AAIController::SetAdjustLocation(FVector NewLoc)
{
	bAdjusting = 1;
	AdjustLoc = NewLoc;
}

int AAIController::AcceptNearbyPath(AActor* Goal)
{
	if( Goal && Goal->IsA(ANavigationPoint::StaticClass()) )
		return 1;
	return 0;
}

void AAIController::AdjustFromWall(FVector,AActor *)
{
}

// --- AAIMarker ---
int AAIMarker::IsIdentifiedAs(FName)
{
	return 0;
}

// --- AAIScript ---
void AAIScript::AddMyMarker(AActor *)
{
}

// --- ADoor ---
void ADoor::PostaddReachSpecs(APawn *)
{
}

void ADoor::PostPath()
{
}

void ADoor::PrePath()
{
}

AActor * ADoor::AssociatedLevelGeometry()
{
	return NULL;
}

void ADoor::FindBase()
{
}

int ADoor::HasAssociatedLevelGeometry(AActor *)
{
	return 0;
}

void ADoor::InitForPathFinding()
{
}

int ADoor::IsIdentifiedAs(FName)
{
	return 0;
}

// --- AEmitter ---
void AEmitter::Spawned()
{
}

int AEmitter::Tick(float,ELevelTick)
{
	return 0;
}

void AEmitter::Render(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
}

void AEmitter::RenderEditorInfo(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
}

void AEmitter::Kill()
{
}

void AEmitter::PostScriptDestroyed()
{
}

int AEmitter::CheckForProjectors()
{
	return 0;
}

void AEmitter::Initialize()
{
}

// --- AFluidSurfaceInfo ---
void AFluidSurfaceInfo::UpdateOscillatorList()
{
}

void AFluidSurfaceInfo::RebuildClampedBitmap()
{
}

void AFluidSurfaceInfo::Render(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
}

void AFluidSurfaceInfo::RenderEditorInfo(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
}

void AFluidSurfaceInfo::SetClampedBitmap(int,int,int)
{
}

void AFluidSurfaceInfo::FillIndexBuffer(void *)
{
}

void AFluidSurfaceInfo::FillVertexBuffer(void *)
{
}

int AFluidSurfaceInfo::GetClampedBitmap(int,int)
{
	return 0;
}

void AFluidSurfaceInfo::GetNearestIndex(FVector const &,int &,int &)
{
}

FVector AFluidSurfaceInfo::GetVertexPos(int,int)
{
	return FVector(0,0,0);
}

// --- AFluidSurfaceOscillator ---
void AFluidSurfaceOscillator::UpdateOscillation(float)
{
}

void AFluidSurfaceOscillator::PostEditChange()
{
}

void AFluidSurfaceOscillator::Destroy()
{
}

// --- AHUD ---
void AHUD::DrawInGameMap(FCameraSceneNode *,UViewport *)
{
}

void AHUD::DrawRadar(FCameraSceneNode *,UViewport *)
{
}

void AHUD::DrawSpecificModeInfo(FCameraSceneNode *,UViewport *)
{
}

// --- AInterpolationPoint ---
void AInterpolationPoint::RenderEditorSelected(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
}

void AInterpolationPoint::PostEditChange()
{
}

void AInterpolationPoint::PostEditMove()
{
}

// --- AJumpDest ---
void AJumpDest::SetupForcedPath(APawn *,UReachSpec *)
{
}

void AJumpDest::ClearPaths()
{
}

// --- AJumpPad ---
void AJumpPad::addReachSpecs(APawn *,int)
{
}

// --- AKActor ---
void AKActor::Spawned()
{
}

// --- AKConeLimit ---
void AKConeLimit::KUpdateConstraintParams()
{
}

// --- AKConstraint ---
MdtBaseConstraint * AKConstraint::getKConstraint() const
{
	return NULL;
}

_McdModel * AKConstraint::getKModel() const
{
	return NULL;
}

void AKConstraint::physKarma(float)
{
}

void AKConstraint::postKarmaStep()
{
}

void AKConstraint::preKarmaStep(float)
{
}

void AKConstraint::RenderEditorSelected(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
}

void AKConstraint::KUpdateConstraintParams()
{
}

void AKConstraint::PostEditChange()
{
}

void AKConstraint::PostEditMove()
{
}

void AKConstraint::CheckForErrors()
{
}

int AKConstraint::CheckOwnerUpdated()
{
	return 0;
}

// --- AKHinge ---
void AKHinge::preKarmaStep(float)
{
}

void AKHinge::KUpdateConstraintParams()
{
}

// --- ALadder ---
void ALadder::addReachSpecs(APawn *,int)
{
}

int ALadder::ProscribedPathTo(ANavigationPoint *)
{
	return 0;
}

void ALadder::ClearPaths()
{
}

void ALadder::InitForPathFinding()
{
}

// --- ALadderVolume ---
void ALadderVolume::RenderEditorInfo(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
}

void ALadderVolume::AddMyMarker(AActor *)
{
}

FVector ALadderVolume::FindCenter()
{
	return FVector(0,0,0);
}

FVector ALadderVolume::FindTop(FVector)
{
	return FVector(0,0,0);
}

// --- ALiftCenter ---
void ALiftCenter::addReachSpecs(APawn *,int)
{
}

void ALiftCenter::FindBase()
{
}

// --- ALineOfSightTrigger ---
void ALineOfSightTrigger::TickAuthoritative(float)
{
}

// --- AMover ---
void AMover::SetWorldRaytraceKey()
{
}

void AMover::Spawned()
{
}

void AMover::SetBrushRaytraceKey()
{
}

void AMover::PostEditChange()
{
}

void AMover::PostEditMove()
{
}

void AMover::PostLoad()
{
}

void AMover::PostNetReceive()
{
}

void AMover::PostRaytrace()
{
}

void AMover::PreNetReceive()
{
}

void AMover::PreRaytrace()
{
}

// --- ANote ---
void ANote::CheckForErrors()
{
}

// --- APathNode ---
int APathNode::ReviewPath(APawn *)
{
	return 0;
}

void APathNode::CheckSymmetry(ANavigationPoint *)
{
}

// --- APhysicsVolume ---
void APhysicsVolume::SetZone(int,int)
{
}

int * APhysicsVolume::GetOptimizedRepList(BYTE*,FPropertyRetirement *,int *,UPackageMap *,UActorChannel *)
{
	return NULL;
}

// --- APlayerController ---
void APlayerController::SpecialDestroy()
{
}

int APlayerController::Tick(float,ELevelTick)
{
	return 0;
}

void APlayerController::R6PBKickPlayer(FString)
{
}

void APlayerController::SetPlayer(UPlayer *)
{
}

int APlayerController::LocalPlayerController()
{
	UPlayer* Player = (UPlayer*)_NativeData[50]; // offset 0x5B4
	return Player && Player->IsA(UViewport::StaticClass());
}

void APlayerController::PostNetReceive()
{
}

void APlayerController::PreNetReceive()
{
}

void APlayerController::CheckHearSound(AActor *,int,USound *,FVector,float,int)
{
}

int * APlayerController::GetOptimizedRepList(BYTE*,FPropertyRetirement *,int *,UPackageMap *,UActorChannel *)
{
	return NULL;
}

FString APlayerController::GetPlayerNetworkAddress()
{
	return FString();
}

AActor * APlayerController::GetViewTarget()
{
	AActor*& ViewTarget = *(AActor**)(&_NativeData[51]); // offset 0x5B8
	if( !ViewTarget )
	{
		if( Pawn && !Pawn->bDeleteMe && !Pawn->bPendingDelete )
		{
			ViewTarget = Pawn;
			return Pawn;
		}
		ViewTarget = this;
	}
	return ViewTarget;
}

int APlayerController::IsNetRelevantFor(APlayerController* RealViewer,AActor* Viewer,FVector SrcLocation)
{
	if( this == RealViewer )
		return 1;
	return AActor::IsNetRelevantFor( RealViewer, Viewer, SrcLocation );
}

// --- APlayerStart ---
void APlayerStart::addReachSpecs(APawn *,int)
{
}

// --- AProjector ---
int AProjector::ShouldTrace(AActor * Other, DWORD TraceFlags)
{
	if (TraceFlags & 0x4000)
		return 1;
	return AActor::ShouldTrace(Other, TraceFlags);
}

void AProjector::TickSpecial(float)
{
}

void AProjector::UpdateParticleMaterial(UParticleMaterial *,int)
{
}

void AProjector::RenderEditorSelected(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
}

void AProjector::RenderWireframe(FRenderInterface *)
{
}

void AProjector::PostEditChange()
{
}

void AProjector::PostEditLoad()
{
}

void AProjector::PostEditMove()
{
}

void AProjector::Abandon()
{
}

void AProjector::Attach()
{
}

void AProjector::CalcMatrix()
{
}

void AProjector::Destroy()
{
}

void AProjector::Detach(int)
{
}

UPrimitive * AProjector::GetPrimitive()
{
	return NULL;
}

// --- AR6AbstractCircumstantialActionQuery ---
int * AR6AbstractCircumstantialActionQuery::GetOptimizedRepList(BYTE*,FPropertyRetirement *,int *,UPackageMap *,UActorChannel *)
{
	return NULL;
}

// --- AR6ActionSpot ---
void AR6ActionSpot::RenderEditorInfo(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
}

void AR6ActionSpot::CheckForErrors()
{
}

// --- AR6ColBox ---
int AR6ColBox::ShouldTrace(AActor *,DWORD)
{
	return 0;
}

void AR6ColBox::SetBase(AActor *,FVector,int)
{
}

int AR6ColBox::CanStepUp(FVector)
{
	return 0;
}

void AR6ColBox::EnableCollision(int,int,int)
{
}

void AR6ColBox::GetColBoxLocationFromOwner(FVector &,float)
{
}

void AR6ColBox::GetDestination(FVector &,FRotator &)
{
}

float AR6ColBox::GetMaxStepUp(bool,float)
{
	return 0.0f;
}

APawn * AR6ColBox::GetPawnOrColBoxOwner() const
{
	return NULL;
}

int AR6ColBox::IsBlockedBy(AActor const *) const
{
	return 0;
}

// --- AR6DecalGroup ---
void AR6DecalGroup::Spawned()
{
}

void AR6DecalGroup::KillDecal(AR6Decal *)
{
}

void AR6DecalGroup::PostScriptDestroyed()
{
}

void AR6DecalGroup::ActivateGroup()
{
}

int AR6DecalGroup::AddDecal(FVector *,FRotator *,UTexture *,int,float,float,float,float,int)
{
	return 0;
}

// --- AR6DecalManager ---
void AR6DecalManager::Spawned()
{
}

int AR6DecalManager::AddDecal(FVector *,FRotator *,UTexture *,eDecalType,int,float,float,float,float,int)
{
	return 0;
}

AR6DecalGroup * AR6DecalManager::FindGroup(eDecalType)
{
	return NULL;
}

// --- AR6DecalsBase ---
int AR6DecalsBase::IsNetRelevantFor(APlayerController *,AActor *,FVector)
{
	return 0;
}

// --- AR6EngineWeapon ---
int AR6EngineWeapon::GetHeartBeatStatus()
{
	return 0;
}

// --- AR6RainbowStartInfo ---
void AR6RainbowStartInfo::TransferFile(FArchive &)
{
}

// --- AR6TeamStartInfo ---
void AR6TeamStartInfo::TransferFile(FArchive &,int)
{
}

// --- AR6WallHit ---
void AR6WallHit::SpawnEffects()
{
}

void AR6WallHit::SpawnSound()
{
}

void AR6WallHit::PostBeginPlay()
{
}

// --- AR6eviLTesting ---
void AR6eviLTesting::eviLTestATS()
{
}

void AR6eviLTesting::evilTestUpdateSystem()
{
}

// --- ASceneManager ---
void ASceneManager::UpdateViewerFromPct(float)
{
}

int ASceneManager::VerifyIntPoints()
{
	return 0;
}

void ASceneManager::RefreshSubActions(float)
{
}

void ASceneManager::SceneEnded()
{
}

void ASceneManager::SceneStarted()
{
}

void ASceneManager::PreparePath()
{
}

void ASceneManager::ChangeOrientation(FOrientation)
{
}

void ASceneManager::DeletePathSamples()
{
}

UMatAction * ASceneManager::GetActionFromPct(float)
{
	return NULL;
}

float ASceneManager::GetActionPctFromScenePct(float)
{
	return 0.0f;
}

FVector ASceneManager::GetLocation(TArray<FVector> *,float)
{
	return FVector(0,0,0);
}

FRotator ASceneManager::GetRotation(TArray<FVector> *,float,FVector,FRotator,UMatAction *,int)
{
	return FRotator(0,0,0);
}

void ASceneManager::InitializeActions()
{
}

// --- AScout ---
int AScout::findStart(FVector)
{
	return 0;
}

int AScout::HurtByVolume(AActor *)
{
	return 0;
}

void AScout::InitForPathing()
{
}

// --- AStaticMeshActor ---
int AStaticMeshActor::ShouldTrace(AActor *,DWORD)
{
	return 0;
}

// --- ATeleporter ---
void ATeleporter::addReachSpecs(APawn *,int)
{
}

// --- ATerrainInfo ---
void ATerrainInfo::SetupSectors()
{
}

void ATerrainInfo::SoftDeselect()
{
}

void ATerrainInfo::UpdateFromSelectedVertices()
{
}

void ATerrainInfo::ResetMove()
{
}

void ATerrainInfo::PostEditChange()
{
}

void ATerrainInfo::PostLoad()
{
}

void ATerrainInfo::PrecomputeLayerWeights()
{
}

// --- AVolume ---
void AVolume::SetVolumes(TArray<AVolume *> const &)
{
}

void AVolume::SetVolumes()
{
}

int AVolume::ShouldTrace(AActor *,DWORD)
{
	return 0;
}

void AVolume::PostBeginPlay()
{
}

int AVolume::Encompasses(FVector)
{
	return 0;
}

// --- AWarpZoneInfo ---
void AWarpZoneInfo::AddMyMarker(AActor *)
{
}

// --- AWarpZoneMarker ---
void AWarpZoneMarker::addReachSpecs(APawn *,int)
{
}

int AWarpZoneMarker::IsIdentifiedAs(FName)
{
	return 0;
}

// --- AZoneInfo ---
void AZoneInfo::PostEditChange()
{
}

// --- CBoneDescData ---
int CBoneDescData::fn_bInitFromLbpFile(const TCHAR*)
{
	return 0;
}

void CBoneDescData::m_vProcessLbpLine(int,int,FString &)
{
}

CBoneDescData::CBoneDescData(CBoneDescData const &)
{
}

CBoneDescData::CBoneDescData()
{
}

CBoneDescData::~CBoneDescData()
{
}

CBoneDescData& CBoneDescData::operator=(const CBoneDescData&)
{
	return *this;
}

// --- CCompressedLipDescData ---
int CCompressedLipDescData::fn_bInitFromMemory(BYTE*)
{
	return 0;
}

int CCompressedLipDescData::m_bReadCompressedFileFromMemory(BYTE*)
{
	return 0;
}

CCompressedLipDescData& CCompressedLipDescData::operator=(const CCompressedLipDescData&)
{
	return *this;
}

// --- FAnimMeshVertexStream ---
FAnimMeshVertexStream::FAnimMeshVertexStream(FAnimMeshVertexStream const &)
{
}

FAnimMeshVertexStream::FAnimMeshVertexStream()
{
}

FAnimMeshVertexStream::~FAnimMeshVertexStream()
{
}

FAnimMeshVertexStream& FAnimMeshVertexStream::operator=(const FAnimMeshVertexStream&)
{
	return *this;
}

// --- FBezier ---
FBezier::FBezier(FBezier const &)
{
}

FBezier::FBezier()
{
}

FBezier::~FBezier()
{
}

FBezier& FBezier::operator=(const FBezier&)
{
	return *this;
}

float FBezier::Evaluate(FVector *,int,TArray<FVector> *)
{
	return 0.0f;
}

// --- FBspSection ---
FBspSection::FBspSection(FBspSection const &)
{
}

FBspSection::FBspSection()
{
}

FBspSection::~FBspSection()
{
}

FBspSection& FBspSection::operator=(const FBspSection&)
{
	return *this;
}

// --- FBspVertex ---
FBspVertex::FBspVertex()
{
	// Ghidra: constructs two FVectors at offset 0 and 0xC (Position + Normal)
	*(FVector*)&_Data[0] = FVector(0,0,0);
	*(FVector*)&_Data[12] = FVector(0,0,0);
}

FBspVertex& FBspVertex::operator=(const FBspVertex& Other)
{
	appMemcpy( this, &Other, sizeof(FBspVertex) );
	return *this;
}

// --- FBspVertexStream ---
FBspVertexStream::FBspVertexStream(FBspVertexStream const &)
{
}

FBspVertexStream::FBspVertexStream()
{
}

FBspVertexStream::~FBspVertexStream()
{
}

FBspVertexStream& FBspVertexStream::operator=(const FBspVertexStream&)
{
	return *this;
}

// --- FCanvasUtil ---
FCanvasUtil::FCanvasUtil(FCanvasUtil const &)
{
}

FCanvasUtil::FCanvasUtil(UViewport *,FRenderInterface *,int,int)
{
}

FCanvasUtil::~FCanvasUtil()
{
}

FCanvasUtil& FCanvasUtil::operator=(const FCanvasUtil&)
{
	return *this;
}

// --- FCanvasVertex ---
FCanvasVertex::FCanvasVertex(FVector InPoint, FColor InColor, float InU, float InV)
:	Point(InPoint)
,	Color(InColor)
,	U(InU)
,	V(InV)
{
}

FCanvasVertex::FCanvasVertex()
{
}

FCanvasVertex& FCanvasVertex::operator=(const FCanvasVertex& Other)
{
	Point = Other.Point;
	Color = Other.Color;
	U     = Other.U;
	V     = Other.V;
	return *this;
}

// --- FConvexVolume ---
BYTE FConvexVolume::SphereCheck(FSphere)
{
	return 0;
}

FConvexVolume::FConvexVolume(FConvexVolume const &)
{
}

FConvexVolume::FConvexVolume()
{
}

FConvexVolume::~FConvexVolume()
{
}

FConvexVolume& FConvexVolume::operator=(const FConvexVolume&)
{
	return *this;
}

BYTE FConvexVolume::BoxCheck(FVector,FVector)
{
	return 0;
}

FPoly FConvexVolume::ClipPolygon(FPoly)
{
	return FPoly();
}

FPoly FConvexVolume::ClipPolygonPrecise(FPoly)
{
	return FPoly();
}

// --- FDXTCompressionOptions ---
FDXTCompressionOptions::FDXTCompressionOptions()
{
}

FDXTCompressionOptions& FDXTCompressionOptions::operator=(const FDXTCompressionOptions&)
{
	return *this;
}

// --- FDynamicActor ---
void FDynamicActor::Render(FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
}

FDynamicActor::FDynamicActor(FDynamicActor const &)
{
}

FDynamicActor::FDynamicActor(AActor *)
{
}

FDynamicActor::~FDynamicActor()
{
}

FDynamicActor& FDynamicActor::operator=(const FDynamicActor&)
{
	return *this;
}

// --- FDynamicLight ---
float FDynamicLight::SampleIntensity(FVector,FVector)
{
	return 0.0f;
}

FColor FDynamicLight::SampleLight(FVector,FVector)
{
	return FColor(0,0,0,0);
}

FDynamicLight::FDynamicLight(FDynamicLight const& Other)
{
	appMemcpy( this, &Other, sizeof(FDynamicLight) );
}

FDynamicLight::FDynamicLight(AActor *)
{
}

FDynamicLight& FDynamicLight::operator=(const FDynamicLight& Other)
{
	appMemcpy( this, &Other, sizeof(FDynamicLight) );
	return *this;
}

// --- FFontCharacter ---
FFontCharacter& FFontCharacter::operator=(const FFontCharacter& Other)
{
	appMemcpy( this, &Other, sizeof(FFontCharacter) );
	return *this;
}

// --- FFontPage ---
FFontPage::FFontPage(FFontPage const &)
{
}

FFontPage::FFontPage()
{
}

FFontPage::~FFontPage()
{
}

FFontPage& FFontPage::operator=(const FFontPage&)
{
	return *this;
}

// --- FKAggregateGeom ---
FKAggregateGeom::FKAggregateGeom(FKAggregateGeom const &)
{
}

FKAggregateGeom::FKAggregateGeom()
{
}

FKAggregateGeom::~FKAggregateGeom()
{
}

FKAggregateGeom& FKAggregateGeom::operator=(const FKAggregateGeom&)
{
	return *this;
}

void FKAggregateGeom::EmptyElements()
{
}

int FKAggregateGeom::GetElementCount()
{
	return 0;
}

// --- FKBoxElem ---
FKBoxElem::FKBoxElem(float InSize)
{
	// Ghidra: FMatrix::FMatrix() + set all 3 dims to same value
	X = InSize;
	Y = InSize;
	Z = InSize;
}

FKBoxElem::FKBoxElem(float InX, float InY, float InZ)
{
	X = InX;
	Y = InY;
	Z = InZ;
}

FKBoxElem::FKBoxElem()
{
	// Ghidra: just calls FMatrix::FMatrix() (default FMatrix ctor is empty)
}

FKBoxElem::~FKBoxElem()
{
}

FKBoxElem& FKBoxElem::operator=(const FKBoxElem& Other)
{
	appMemcpy( this, &Other, sizeof(FKBoxElem) );
	return *this;
}

// --- FKConvexElem ---
FKConvexElem::FKConvexElem(FKConvexElem const &)
{
}

FKConvexElem::FKConvexElem()
{
}

FKConvexElem::~FKConvexElem()
{
}

FKConvexElem& FKConvexElem::operator=(const FKConvexElem&)
{
	return *this;
}

// --- FKCylinderElem ---
FKCylinderElem::FKCylinderElem(float InRadius, float InLength)
{
	Radius = InRadius;
	Length = InLength;
}

FKCylinderElem::FKCylinderElem()
{
}

FKCylinderElem::~FKCylinderElem()
{
}

FKCylinderElem& FKCylinderElem::operator=(const FKCylinderElem& Other)
{
	appMemcpy( this, &Other, sizeof(FKCylinderElem) );
	return *this;
}

// --- FKSphereElem ---
FKSphereElem::FKSphereElem(float InRadius)
{
	Radius = InRadius;
}

FKSphereElem::FKSphereElem()
{
}

FKSphereElem::~FKSphereElem()
{
}

FKSphereElem& FKSphereElem::operator=(const FKSphereElem& Other)
{
	appMemcpy( this, &Other, sizeof(FKSphereElem) );
	return *this;
}

// --- FLightMap ---
FLightMap::FLightMap(FLightMap const &)
{
}

FLightMap::FLightMap(ULevel *,int,int)
{
}

FLightMap::FLightMap()
{
}

FLightMap::~FLightMap()
{
}

FLightMap& FLightMap::operator=(const FLightMap&)
{
	return *this;
}

// --- FLightMapIndex ---
FLightMapIndex::FLightMapIndex()
{
}

FLightMapIndex::~FLightMapIndex()
{
}

FLightMapIndex& FLightMapIndex::operator=(const FLightMapIndex&)
{
	return *this;
}

// --- FLightMapTexture ---
FLightMapTexture::FLightMapTexture(FLightMapTexture const &)
{
}

FLightMapTexture::FLightMapTexture(ULevel *)
{
}

FLightMapTexture::FLightMapTexture()
{
}

FLightMapTexture::~FLightMapTexture()
{
}

FLightMapTexture& FLightMapTexture::operator=(const FLightMapTexture&)
{
	return *this;
}

// --- FLineBatcher ---
FLineBatcher::FLineBatcher(FLineBatcher const &)
{
}

FLineBatcher::FLineBatcher(FRenderInterface *,int,int)
{
}

FLineBatcher::~FLineBatcher()
{
}

FLineBatcher& FLineBatcher::operator=(const FLineBatcher&)
{
	return *this;
}

void FLineBatcher::DrawConvexVolume(FConvexVolume,FColor)
{
}

// --- FLineVertex ---
FLineVertex::FLineVertex(FVector InPoint, FColor InColor)
:	Point(InPoint)
,	Color(InColor)
{
}

FLineVertex::FLineVertex()
{
}

FLineVertex& FLineVertex::operator=(const FLineVertex& Other)
{
	Point = Other.Point;
	Color = Other.Color;
	return *this;
}

// --- FMipmap ---
FMipmap::FMipmap(FMipmap const &)
{
}

FMipmap::FMipmap(BYTE,BYTE)
{
}

FMipmap::FMipmap(BYTE,BYTE,int)
{
}

FMipmap::FMipmap()
{
}

FMipmap::~FMipmap()
{
}

FMipmap& FMipmap::operator=(const FMipmap&)
{
	return *this;
}

void FMipmap::Clear()
{
}

// --- FMipmapBase ---
FMipmapBase::FMipmapBase(BYTE,BYTE)
{
}

FMipmapBase::FMipmapBase()
{
}

FMipmapBase& FMipmapBase::operator=(const FMipmapBase& Other)
{
	appMemcpy( this, &Other, sizeof(FMipmapBase) );
	return *this;
}

// --- FOrientation ---
FOrientation::FOrientation()
{
	*(INT*)&_Data[0x00] = 2;
	*(INT*)&_Data[0x04] = 0;
	*(INT*)&_Data[0x08] = 0;
	*(INT*)&_Data[0x0C] = 0;
	*(INT*)&_Data[0x10] = 0;
	*(INT*)&_Data[0x14] = 0;
	*(INT*)&_Data[0x18] = 0;
	*(FRotator*)&_Data[0x28] = FRotator(0,0,0);
}

FOrientation& FOrientation::operator=(FOrientation Other)
{
	appMemcpy(this, &Other, 0x34);
	return *this;
}

int FOrientation::operator!=(FOrientation const & Other) const
{
	return *(INT*)&_Data[0x18] != *(INT*)&Other._Data[0x18];
}

// --- FR6MatineePreviewProxy ---
void FR6MatineePreviewProxy::OnEndSequenceNotify(ASceneManager *)
{
}

void FR6MatineePreviewProxy::OnScrollBarUpdate()
{
}

FR6MatineePreviewProxy::FR6MatineePreviewProxy(FR6MatineePreviewProxy const &)
{
}

FR6MatineePreviewProxy::FR6MatineePreviewProxy()
{
}

FR6MatineePreviewProxy::~FR6MatineePreviewProxy()
{
}

FR6MatineePreviewProxy& FR6MatineePreviewProxy::operator=(const FR6MatineePreviewProxy&)
{
	return *this;
}

// --- FRaw32BitIndexBuffer ---
FRaw32BitIndexBuffer::FRaw32BitIndexBuffer(FRaw32BitIndexBuffer const &)
{
}

FRaw32BitIndexBuffer::FRaw32BitIndexBuffer()
{
}

FRaw32BitIndexBuffer::~FRaw32BitIndexBuffer()
{
}

FRaw32BitIndexBuffer& FRaw32BitIndexBuffer::operator=(const FRaw32BitIndexBuffer&)
{
	return *this;
}

// --- FRawColorStream ---
FRawColorStream::FRawColorStream(FRawColorStream const &)
{
}

FRawColorStream::FRawColorStream()
{
}

FRawColorStream::~FRawColorStream()
{
}

FRawColorStream& FRawColorStream::operator=(const FRawColorStream&)
{
	return *this;
}

// --- FRawIndexBuffer ---
int FRawIndexBuffer::Stripify()
{
	return 0;
}

FRawIndexBuffer::FRawIndexBuffer(FRawIndexBuffer const &)
{
}

FRawIndexBuffer::FRawIndexBuffer()
{
}

FRawIndexBuffer::~FRawIndexBuffer()
{
}

FRawIndexBuffer& FRawIndexBuffer::operator=(const FRawIndexBuffer&)
{
	return *this;
}

// --- FReachSpec ---
FReachSpec& FReachSpec::operator=(const FReachSpec& Other)
{
	appMemcpy(this, &Other, 44); // 11 dwords, shared with FStaticMeshCollisionNode
	return *this;
}

// --- FRebuildOptions ---
FRebuildOptions::FRebuildOptions(FRebuildOptions const & Other)
	: Name(Other.Name)
{
	appMemcpy(Options, Other.Options, sizeof(Options));
}

FRebuildOptions::FRebuildOptions()
{
	Options[0] = 2;    // 0x0C
	Options[1] = 79;   // 0x10
	Options[2] = 15;   // 0x14
	Options[3] = 70;   // 0x18
	Options[4] = 7;    // 0x1C
	Options[5] = 0;    // 0x20
	Options[6] = 0;    // 0x24
	Options[7] = 1;    // 0x28
	Name = TEXT("Default");
}

FRebuildOptions::~FRebuildOptions()
{
	// Name's implicit destructor handles FString cleanup
}

FRebuildOptions FRebuildOptions::operator=(FRebuildOptions Other)
{
	Name = Other.Name;
	appMemcpy(Options, Other.Options, sizeof(Options));
	return *this;
}

FString FRebuildOptions::GetName()
{
	return Name;
}

void FRebuildOptions::Init()
{
	Options[0] = 2;
	Options[1] = 79;
	Options[2] = 15;
	Options[3] = 70;
	Options[4] = 7;
	Options[5] = 0;
	Options[6] = 0;
	Options[7] = 1;
}

// --- FSkinVertexStream ---
FSkinVertexStream::FSkinVertexStream(FSkinVertexStream const &)
{
}

FSkinVertexStream::FSkinVertexStream()
{
}

FSkinVertexStream::~FSkinVertexStream()
{
}

FSkinVertexStream& FSkinVertexStream::operator=(const FSkinVertexStream&)
{
	return *this;
}

// --- FStatGraphLine ---
FStatGraphLine::FStatGraphLine(FStatGraphLine const &)
{
}

FStatGraphLine::FStatGraphLine()
{
}

FStatGraphLine::~FStatGraphLine()
{
}

FStatGraphLine& FStatGraphLine::operator=(const FStatGraphLine&)
{
	return *this;
}

int FStatGraphLine::operator==(FStatGraphLine const &) const
{
	return 0;
}

// --- FStaticCubemap ---
FStaticCubemap::FStaticCubemap(FStaticCubemap const &)
{
}

FStaticCubemap::FStaticCubemap(UCubemap *)
{
}

FStaticCubemap& FStaticCubemap::operator=(const FStaticCubemap&)
{
	return *this;
}

unsigned __int64 FStaticCubemap::GetCacheId()
{
	return 0;
}

FTexture * FStaticCubemap::GetFace(int)
{
	return NULL;
}

int FStaticCubemap::GetFirstMip()
{
	return 0;
}

ETextureFormat FStaticCubemap::GetFormat()
{
	return TEXF_P8;
}

int FStaticCubemap::GetHeight()
{
	return 0;
}

int FStaticCubemap::GetNumMips()
{
	return 0;
}

int FStaticCubemap::GetRevision()
{
	return 0;
}

ETexClampMode FStaticCubemap::GetUClamp()
{
	return TC_Wrap;
}

ETexClampMode FStaticCubemap::GetVClamp()
{
	return TC_Wrap;
}

int FStaticCubemap::GetWidth()
{
	return 0;
}

// --- FStaticLightMapTexture ---
FStaticLightMapTexture::FStaticLightMapTexture(FStaticLightMapTexture const &)
{
}

FStaticLightMapTexture::FStaticLightMapTexture()
{
}

FStaticLightMapTexture::~FStaticLightMapTexture()
{
}

FStaticLightMapTexture& FStaticLightMapTexture::operator=(const FStaticLightMapTexture&)
{
	return *this;
}

// --- FStaticMeshCollisionNode ---
FStaticMeshCollisionNode::FStaticMeshCollisionNode()
{
	// Ghidra: only constructs FBox at offset 0x10 (empty default ctor)
}

FStaticMeshCollisionNode& FStaticMeshCollisionNode::operator=(const FStaticMeshCollisionNode& Other)
{
	appMemcpy(this, &Other, 44); // 11 dwords, shared with FReachSpec
	return *this;
}

// --- FStaticMeshCollisionTriangle ---
FStaticMeshCollisionTriangle::FStaticMeshCollisionTriangle(FStaticMeshCollisionTriangle const & Other)
{
	appMemcpy(_Data, Other._Data, 84); // 21 dwords: 4 FPlanes + 5 extra dwords
}

FStaticMeshCollisionTriangle::FStaticMeshCollisionTriangle()
{
	// Ghidra: constructs 4 FPlanes (all empty default ctors)
}

FStaticMeshCollisionTriangle& FStaticMeshCollisionTriangle::operator=(const FStaticMeshCollisionTriangle& Other)
{
	appMemcpy(_Data, Other._Data, 84); // 21 dwords
	return *this;
}

// --- FStaticMeshMaterial ---
FStaticMeshMaterial::FStaticMeshMaterial(UMaterial * InMaterial)
{
	Material = InMaterial;
	Flags1 = 1;
	Flags2 = 1;
}

FStaticMeshMaterial& FStaticMeshMaterial::operator=(const FStaticMeshMaterial& Other)
{
	Material = Other.Material;
	Flags1 = Other.Flags1;
	Flags2 = Other.Flags2;
	return *this;
}

// --- FStaticMeshSection ---
FStaticMeshSection::FStaticMeshSection()
{
}

FStaticMeshSection& FStaticMeshSection::operator=(const FStaticMeshSection& Other)
{
	appMemcpy( this, &Other, sizeof(FStaticMeshSection) );
	return *this;
}

// --- FStaticMeshTriangle ---
FStaticMeshTriangle::FStaticMeshTriangle()
{
	// Ghidra: constructs 3 FVectors at offsets 0x00, 0x0C, 0x18 (all empty default ctors)
}

FStaticMeshTriangle& FStaticMeshTriangle::operator=(const FStaticMeshTriangle& Other)
{
	appMemcpy(_Data, Other._Data, 260); // 65 dwords, shared with FSortedPathList
	return *this;
}

// --- FStaticMeshUV ---
FStaticMeshUV& FStaticMeshUV::operator=(const FStaticMeshUV& Other)
{
	*(INT*)&_Data[0] = *(INT*)&Other._Data[0];
	*(INT*)&_Data[4] = *(INT*)&Other._Data[4];
	return *this;
}

// --- FStaticMeshUVStream ---
FStaticMeshUVStream::FStaticMeshUVStream(FStaticMeshUVStream const &)
{
}

FStaticMeshUVStream::FStaticMeshUVStream()
{
}

FStaticMeshUVStream::~FStaticMeshUVStream()
{
}

FStaticMeshUVStream& FStaticMeshUVStream::operator=(const FStaticMeshUVStream&)
{
	return *this;
}

// --- FStaticMeshVertex ---
FStaticMeshVertex::FStaticMeshVertex()
{
	// Ghidra: constructs two FVectors at offset 0 and 0xC (same as FBspVertex)
	*(FVector*)&_Data[0] = FVector(0,0,0);
	*(FVector*)&_Data[12] = FVector(0,0,0);
}

FStaticMeshVertex& FStaticMeshVertex::operator=(const FStaticMeshVertex& Other)
{
	appMemcpy( this, &Other, sizeof(FStaticMeshVertex) );
	return *this;
}

// --- FStaticMeshVertexStream ---
FStaticMeshVertexStream::FStaticMeshVertexStream(FStaticMeshVertexStream const &)
{
}

FStaticMeshVertexStream::FStaticMeshVertexStream()
{
}

FStaticMeshVertexStream::~FStaticMeshVertexStream()
{
}

FStaticMeshVertexStream& FStaticMeshVertexStream::operator=(const FStaticMeshVertexStream&)
{
	return *this;
}

// --- FStaticTexture ---
FStaticTexture::FStaticTexture(FStaticTexture const &)
{
}

FStaticTexture::FStaticTexture(UTexture *)
{
}

FStaticTexture& FStaticTexture::operator=(const FStaticTexture&)
{
	return *this;
}

// --- FTags ---
FTags::FTags(FTags const &)
{
}

FTags::FTags()
{
}

FTags::~FTags()
{
}

FTags& FTags::operator=(const FTags&)
{
	return *this;
}

void FTags::Init()
{
}

// --- FTempLineBatcher ---
void FTempLineBatcher::Render(FRenderInterface *,int)
{
}

FTempLineBatcher::FTempLineBatcher(FTempLineBatcher const &)
{
}

FTempLineBatcher::FTempLineBatcher()
{
}

FTempLineBatcher::~FTempLineBatcher()
{
}

FTempLineBatcher& FTempLineBatcher::operator=(const FTempLineBatcher&)
{
	return *this;
}

void FTempLineBatcher::AddBox(FBox,FColor)
{
}

void FTempLineBatcher::AddLine(FVector,FVector,FColor)
{
}

// --- FTerrainMaterialLayer ---
FTerrainMaterialLayer::FTerrainMaterialLayer()
{
}

FTerrainMaterialLayer::~FTerrainMaterialLayer()
{
}

FTerrainMaterialLayer& FTerrainMaterialLayer::operator=(const FTerrainMaterialLayer&)
{
	return *this;
}

// --- FTerrainTools ---
void FTerrainTools::SetAdjust(int)
{
}

void FTerrainTools::SetCurrentBrush(int)
{
}

void FTerrainTools::SetCurrentTerrainInfo(ATerrainInfo *)
{
}

void FTerrainTools::SetFloorOffset(int)
{
}

void FTerrainTools::SetInnerRadius(int)
{
}

void FTerrainTools::SetMirrorAxis(int)
{
}

void FTerrainTools::SetOuterRadius(int)
{
}

void FTerrainTools::SetStrength(int)
{
}

FTerrainTools::FTerrainTools(FTerrainTools const &)
{
}

FTerrainTools::~FTerrainTools()
{
}

void FTerrainTools::AdjustAlignedActors()
{
}

void FTerrainTools::FindActorsToAlign()
{
}

int FTerrainTools::GetAdjust()
{
	return 0;
}

ATerrainInfo * FTerrainTools::GetCurrentTerrainInfo()
{
	return NULL;
}

FString FTerrainTools::GetExecFromBrushName(FString &)
{
	return FString();
}

int FTerrainTools::GetFloorOffset()
{
	return 0;
}

int FTerrainTools::GetInnerRadius()
{
	return 0;
}

int FTerrainTools::GetMirrorAxis()
{
	return 0;
}

int FTerrainTools::GetOuterRadius()
{
	return 0;
}

int FTerrainTools::GetStrength()
{
	return 0;
}

void FTerrainTools::Init()
{
}

// --- FZoneProperties ---
FZoneProperties::FZoneProperties(FZoneProperties const &)
{
}

FZoneProperties::FZoneProperties()
{
}

FZoneProperties& FZoneProperties::operator=(const FZoneProperties&)
{
	return *this;
}

// --- UActorChannel ---
void UActorChannel::StaticConstructor()
{
}

void UActorChannel::Tick()
{
}

void UActorChannel::ReceivedBunch(FInBunch &)
{
}

void UActorChannel::ReceivedNak(int)
{
}

void UActorChannel::ReplicateActor()
{
}

void UActorChannel::SetChannelActor(AActor *)
{
}

void UActorChannel::SetClosingFlag()
{
}

void UActorChannel::Close()
{
}

FString UActorChannel::Describe()
{
	return FString();
}

void UActorChannel::Destroy()
{
}

AActor * UActorChannel::GetActor()
{
	return NULL;
}

void UActorChannel::Init(UNetConnection *,int,int)
{
}

// --- UAnimNotify ---
void UAnimNotify::Notify(UMeshInstance *,AActor *)
{
}

void UAnimNotify::PostEditChange()
{
}

// --- UAnimNotify_DestroyEffect ---
void UAnimNotify_DestroyEffect::Notify(UMeshInstance *,AActor *)
{
}

// --- UAnimNotify_Effect ---
void UAnimNotify_Effect::Notify(UMeshInstance *,AActor *)
{
}

// --- UAnimNotify_MatSubAction ---
void UAnimNotify_MatSubAction::Notify(UMeshInstance *,AActor *)
{
}

// --- UAnimNotify_Script ---
void UAnimNotify_Script::Notify(UMeshInstance *,AActor *)
{
}

// --- UAnimNotify_Scripted ---
void UAnimNotify_Scripted::Notify(UMeshInstance *,AActor *)
{
}

// --- UAnimNotify_Sound ---
void UAnimNotify_Sound::Notify(UMeshInstance *,AActor *)
{
}

// --- UAnimation ---
void UAnimation::Serialize(FArchive &)
{
}

// --- UBeamEmitter ---
void UBeamEmitter::SpawnParticle(int,float,int,int,FVector const &)
{
}

void UBeamEmitter::UpdateActorHitList()
{
}

int UBeamEmitter::UpdateParticles(float)
{
	return 0;
}

int UBeamEmitter::RenderParticles(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
	return 0;
}

void UBeamEmitter::Scale(float)
{
}

void UBeamEmitter::PostEditChange()
{
}

void UBeamEmitter::CleanUp()
{
}

void UBeamEmitter::Initialize(int)
{
}

// --- UBinaryFileDownload ---
void UBinaryFileDownload::StaticConstructor()
{
}

void UBinaryFileDownload::Tick()
{
}

int UBinaryFileDownload::TrySkipFile()
{
	return 0;
}

// --- UBitmapMaterial ---


UBitmapMaterial * UBitmapMaterial::Get(double,UViewport *)
{
	return this;
}

// --- UCameraEffect ---
void UCameraEffect::PostRender(UViewport *,FRenderInterface *)
{
}

void UCameraEffect::PreRender(UViewport *,FRenderInterface *)
{
}

// --- UCameraOverlay ---
void UCameraOverlay::PostRender(UViewport *,FRenderInterface *)
{
}

// --- UCanvas ---
void __cdecl UCanvas::WrappedPrint(ERenderStyle,int &,int &,UFont *,int,const TCHAR*)
{
}

void UCanvas::WrappedPrintf(UFont *,int,const TCHAR*,...)
{
}

void UCanvas::WrappedStrLenf(UFont *,int &,int &,const TCHAR*,...)
{
}

// --- UChannel ---
// --- UChannelDownload ---
void UChannelDownload::StaticConstructor()
{
}

int UChannelDownload::TrySkipFile()
{
	return 0;
}

void UChannelDownload::ReceiveFile(UNetConnection *,int,const TCHAR*,int)
{
}

void UChannelDownload::Serialize(FArchive &)
{
}

void UChannelDownload::Destroy()
{
}

// --- UClient ---
void UClient::StaticConstructor()
{
}

void UClient::UpdateGamma()
{
}

void UClient::UpdateGraphicOptions()
{
}

void UClient::RestoreGamma()
{
}

void UClient::Serialize(FArchive &)
{
}

void UClient::PostEditChange()
{
}

void UClient::Destroy()
{
}

int UClient::Exec(const TCHAR*,FOutputDevice &)
{
	return 0;
}

void UClient::Flush(int)
{
}

void UClient::Init(UEngine *)
{
}

// --- UCombiner ---







// --- UConstantColor ---
FColor UConstantColor::GetColor(float)
{
	return Color;
}

// --- UConstantMaterial ---
FColor UConstantMaterial::GetColor(float)
{
	return FColor(0,0,0,0);
}

// --- UControlChannel ---
void UControlChannel::StaticConstructor()
{
}

void UControlChannel::ReceivedBunch(FInBunch &)
{
}

void UControlChannel::Serialize(const TCHAR*,EName)
{
}

FString UControlChannel::Describe()
{
	return FString();
}

void UControlChannel::Destroy()
{
}

void UControlChannel::Init(UNetConnection *,int,int)
{
}

// --- UConvexVolume ---
void UConvexVolume::Serialize(FArchive &)
{
}

FBox UConvexVolume::GetRenderBoundingBox(AActor const *)
{
	return FBox();
}

int UConvexVolume::IsPointInside(FVector,FMatrix)
{
	return 0;
}

// --- UCubemap ---
void UCubemap::Destroy()
{
}

FBaseTexture * UCubemap::GetRenderInterface()
{
	return NULL;
}

// --- UDemoRecDriver ---
void UDemoRecDriver::SpawnDemoRecSpectator(UNetConnection *)
{
}

void UDemoRecDriver::StaticConstructor()
{
}

void UDemoRecDriver::TickDispatch(float)
{
}

void UDemoRecDriver::LowLevelDestroy()
{
}

FString UDemoRecDriver::LowLevelGetNetworkNumber()
{
	return FString();
}

int UDemoRecDriver::Exec(const TCHAR*,FOutputDevice &)
{
	return 0;
}

ULevel * UDemoRecDriver::GetLevel()
{
	return NULL;
}

int UDemoRecDriver::InitBase(int,FNetworkNotify *,FURL &,FString &)
{
	return 0;
}

int UDemoRecDriver::InitConnect(FNetworkNotify *,FURL &,FString &)
{
	return 0;
}

int UDemoRecDriver::InitListen(FNetworkNotify *,FURL &,FString &)
{
	return 0;
}

// --- UDownload ---
void UDownload::StaticConstructor()
{
}

void UDownload::Tick()
{
}

int UDownload::TrySkipFile()
{
	return 0;
}

void UDownload::ReceiveData(BYTE*,int)
{
}

void UDownload::ReceiveFile(UNetConnection *,int,const TCHAR*,int)
{
}

void UDownload::Serialize(FArchive &)
{
}

void UDownload::Destroy()
{
}

void UDownload::DownloadDone()
{
}

void UDownload::DownloadError(const TCHAR*)
{
}

// --- UEngine ---
void UEngine::StaticConstructor()
{
}

int UEngine::ReplaceTexture(FString,UTexture *)
{
	return 0;
}

void UEngine::Serialize(FArchive &)
{
}

int UEngine::Key(UViewport *,EInputKey)
{
	return 0;
}

int UEngine::LoadBackgroundImage(FString,UTexture *,UTexture *)
{
	return 0;
}

void UEngine::LoadRandomMenuBackgroundImage(FString)
{
}

int UEngine::CacheArmPatch(FGuid *,DWORD *)
{
	return 0;
}

void UEngine::Destroy()
{
}

int UEngine::ExecServerProf(const TCHAR*,int,FOutputDevice &)
{
	return 0;
}

void UEngine::InitAudio()
{
}

int UEngine::InputEvent(UViewport *,EInputKey,EInputAction,float)
{
	return 0;
}

// --- UFadeColor ---
FColor UFadeColor::GetColor(float)
{
	return FColor(0,0,0,0);
}

// --- UFileChannel ---
void UFileChannel::StaticConstructor()
{
}

void UFileChannel::Tick()
{
}

// --- UFinalBlend ---





// --- UFluidSurfacePrimitive ---
void UFluidSurfacePrimitive::Serialize(FArchive &)
{
}

int UFluidSurfacePrimitive::LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD)
{
	return 0;
}

int UFluidSurfacePrimitive::PointCheck(FCheckResult &,AActor *,FVector,FVector,DWORD)
{
	return 0;
}

FBox UFluidSurfacePrimitive::GetCollisionBoundingBox(AActor const *) const
{
	return FBox();
}

FBox UFluidSurfacePrimitive::GetRenderBoundingBox(AActor const *)
{
	return FBox();
}

FSphere UFluidSurfacePrimitive::GetRenderBoundingSphere(AActor const *)
{
	return FSphere();
}

// --- UFont ---
_WORD UFont::RemapChar(_WORD)
{
	return 0;
}

void UFont::Serialize(FArchive &)
{
}

// --- UGameEngine ---
int UGameEngine::ReplaceTexture(FString,UTexture *)
{
	return 0;
}

int UGameEngine::LoadBackgroundImage(FString,UTexture *,UTexture *)
{
	return 0;
}

void UGameEngine::LoadRandomMenuBackgroundImage(FString)
{
}

void UGameEngine::PostRenderFullScreenEffects(FLevelSceneNode *,UViewport *)
{
}

void UGameEngine::AddLinkerToMasterMap(UNetDriver *,APawn *)
{
}

void UGameEngine::AddLinkerToMasterMap(UNetDriver *,UMaterial *)
{
}

void UGameEngine::AddLinkerToMasterMap(UNetDriver *,UMesh *)
{
}

void UGameEngine::AddLinkerToMasterMap(UNetDriver *,UStaticMesh *)
{
}

void UGameEngine::DisplayGameVideo(eGameVideoType)
{
}

void UGameEngine::InitializeMissionDescription(FString &)
{
}

// --- UI3DL2Listener ---
void UI3DL2Listener::PostEditChange()
{
}

// --- UIndexBuffer ---
void UIndexBuffer::Serialize(FArchive &)
{
}

// --- UInputPlanning ---
const TCHAR* UInputPlanning::StaticConfigName()
{
	return NULL;
}

void UInputPlanning::StaticInitInput()
{
}

// --- UInteractionMaster ---
int UInteractionMaster::MasterProcessKeyEvent(EInputKey,EInputAction,float)
{
	return 0;
}

int UInteractionMaster::MasterProcessKeyType(EInputKey)
{
	return 0;
}

void UInteractionMaster::MasterProcessMessage(FString const &,float)
{
}

void UInteractionMaster::MasterProcessPostRender(UCanvas *)
{
}

void UInteractionMaster::MasterProcessPreRender(UCanvas *)
{
}

void UInteractionMaster::MasterProcessTick(float)
{
}

void UInteractionMaster::DisplayCopyright()
{
}

int UInteractionMaster::Exec(const TCHAR*,FOutputDevice &)
{
	return 0;
}

// --- UKMeshProps ---
void UKMeshProps::Serialize(FArchive &)
{
}

void UKMeshProps::Draw(FRenderInterface *,int)
{
}

// --- UKarmaParams ---
void UKarmaParams::PostEditChange()
{
}

// --- ULevelSummary ---
void ULevelSummary::PostLoad()
{
}

// --- ULodMesh ---
void ULodMesh::Serialize(FArchive &)
{
}

int ULodMesh::MemFootprint(int)
{
	return 0;
}

UClass * ULodMesh::MeshGetInstanceClass()
{
	return NULL;
}

// --- UMatAction ---
void UMatAction::PostEditChange()
{
}

void UMatAction::PostLoad()
{
}

void UMatAction::Initialize()
{
}

// --- UMatSubAction ---
int UMatSubAction::Update(float,ASceneManager *)
{
	return 0;
}

void UMatSubAction::PostEditChange()
{
}

void UMatSubAction::PreBeginPreview()
{
}

FString UMatSubAction::GetStatString()
{
	return FString();
}

FString UMatSubAction::GetStatusDesc()
{
	return FString();
}

void UMatSubAction::Initialize()
{
}

int UMatSubAction::IsEnding()
{
	return 0;
}

int UMatSubAction::IsRunning()
{
	return 0;
}

// --- UMaterial ---




void UMaterial::ClearFallbacks()
{
}

// --- UMaterialSwitch ---
void UMaterialSwitch::PostEditChange()
{
}

int UMaterialSwitch::CheckCircularReferences(TArray<UMaterial *> &)
{
	return 0;
}

// --- UMesh ---
void UMesh::Serialize(FArchive &)
{
}

UMeshInstance * UMesh::MeshGetInstance(AActor const *)
{
	return NULL;
}

UClass * UMesh::MeshGetInstanceClass()
{
	return NULL;
}

// --- UMeshAnimation ---
int UMeshAnimation::SequenceMemFootprint(FName)
{
	return 0;
}

void UMeshAnimation::Serialize(FArchive &)
{
}

int UMeshAnimation::MemFootprint()
{
	return 0;
}

void UMeshAnimation::PostLoad()
{
}

void UMeshAnimation::ClearAnimNotifys()
{
}

FMeshAnimSeq * UMeshAnimation::GetAnimSeq(FName)
{
	return NULL;
}

MotionChunk * UMeshAnimation::GetMovement(FName)
{
	return NULL;
}

void UMeshAnimation::InitForDigestion()
{
}

// --- UMeshEmitter ---
int UMeshEmitter::UpdateParticles(float)
{
	return 0;
}

int UMeshEmitter::RenderParticles(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
	return 0;
}

void UMeshEmitter::PostEditChange()
{
}

void UMeshEmitter::Initialize(int)
{
}

// --- UModel ---
void UModel::Render(FDynamicActor *,FLevelSceneNode *,FRenderInterface *)
{
}

void UModel::AttachProjector(int,FProjectorRenderInfo *,FPlane *)
{
}

// --- UModifier ---







// --- UMotionBlur ---
void UMotionBlur::PostRender(UViewport *,FRenderInterface *)
{
}

void UMotionBlur::PreRender(UViewport *,FRenderInterface *)
{
}

void UMotionBlur::Destroy()
{
}

// --- UNetDriver ---
void UNetDriver::StaticConstructor()
{
}

void UNetDriver::TickFlush()
{
}

// --- UPalette ---
UPalette * UPalette::ReplaceWithExisting()
{
	return NULL;
}


BYTE UPalette::BestMatch(FColor,int)
{
	return 0;
}

void UPalette::FixPalette()
{
}

// --- UParticleEmitter ---
void UParticleEmitter::SpawnIndividualParticles(int)
{
}

void UParticleEmitter::SpawnParticle(int,float,int,int,FVector const &)
{
}

float UParticleEmitter::SpawnParticles(float,float,float)
{
	return 0.0f;
}

int UParticleEmitter::UpdateParticles(float)
{
	return 0;
}

int UParticleEmitter::RenderParticles(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
	return 0;
}

void UParticleEmitter::Reset()
{
}

void UParticleEmitter::Scale(float)
{
}

void UParticleEmitter::PostEditChange()
{
}

void UParticleEmitter::PostLoad()
{
}

void UParticleEmitter::CleanUp()
{
}

void UParticleEmitter::Destroy()
{
}

void UParticleEmitter::HandleActorForce(AActor *,float)
{
}

void UParticleEmitter::Initialize(int)
{
}

// --- UPlayer ---
void UPlayer::Serialize(FArchive &)
{
}

void UPlayer::Destroy()
{
}

int UPlayer::Exec(const TCHAR*,FOutputDevice &)
{
	return 0;
}

// --- UPolys ---
void UPolys::Serialize(FArchive &)
{
}

// --- UProjectorPrimitive ---
int UProjectorPrimitive::LineCheck(FCheckResult &,AActor *,FVector,FVector,FVector,DWORD,DWORD)
{
	return 0;
}

int UProjectorPrimitive::PointCheck(FCheckResult &,AActor *,FVector,FVector,DWORD)
{
	return 0;
}

void UProjectorPrimitive::Destroy()
{
}

FBox UProjectorPrimitive::GetCollisionBoundingBox(AActor const *) const
{
	return FBox();
}

FVector UProjectorPrimitive::GetEncroachCenter(AActor *)
{
	return FVector(0,0,0);
}

FVector UProjectorPrimitive::GetEncroachExtent(AActor *)
{
	return FVector(0,0,0);
}

// --- UProxyBitmapMaterial ---
void UProxyBitmapMaterial::SetTextureInterface(FBaseTexture *)
{
}

UBitmapMaterial * UProxyBitmapMaterial::Get(double,UViewport *)
{
	return NULL;
}

FBaseTexture * UProxyBitmapMaterial::GetRenderInterface()
{
	return NULL;
}

// --- UR6AbstractGameManager ---
void UR6AbstractGameManager::StartJoinServer(FString,FString,int)
{
}

int UR6AbstractGameManager::StartLogInProcedure()
{
	return 0;
}

void UR6AbstractGameManager::StartPreJoinProcedure(int)
{
}

void UR6AbstractGameManager::UnInitialize()
{
}

void UR6AbstractGameManager::SetGSCreateUbiServer(int)
{
}

void UR6AbstractGameManager::LaunchListenSrv(FString,FString)
{
}

void UR6AbstractGameManager::ClientLeaveServer()
{
}

void UR6AbstractGameManager::ConnectionInterrupted(int)
{
}

void UR6AbstractGameManager::GameServiceTick(UConsole *)
{
}

int UR6AbstractGameManager::GetGSCreateUbiServer()
{
	return 0;
}

void UR6AbstractGameManager::InitializeGameService(UConsole *)
{
}

// --- UR6AbstractPlanningInfo ---
void UR6AbstractPlanningInfo::TransferFile(FArchive &)
{
}

void UR6AbstractPlanningInfo::AddPoint(AActor *)
{
}

AActor * UR6AbstractPlanningInfo::GetTeamLeader()
{
	return NULL;
}

// --- UR6FileManager ---
int UR6FileManager::FindFile(FString *)
{
	return 0;
}

void UR6FileManager::GetFileName(int,FString *)
{
}

int UR6FileManager::GetNbFile(FString *,FString *)
{
	return 0;
}

// --- UReachSpec ---
int UReachSpec::findBestReachable(AScout *)
{
	return 0;
}

int UReachSpec::supports(int,int,int,int)
{
	return 0;
}

int UReachSpec::defineFor(ANavigationPoint *,ANavigationPoint *,APawn *)
{
	return 0;
}

FPlane UReachSpec::PathColor()
{
	return FPlane();
}

int UReachSpec::PlaceScout(AScout *)
{
	return 0;
}

int UReachSpec::operator==(UReachSpec const &)
{
	return 0;
}

UReachSpec * UReachSpec::operator+(UReachSpec const &) const
{
	return NULL;
}

int UReachSpec::operator<=(UReachSpec const &)
{
	return 0;
}

int UReachSpec::BotOnlyPath()
{
	return 0;
}

void UReachSpec::Init()
{
}

// --- URenderDevice ---
void URenderDevice::StartVideo(UCanvas *,int,int,int)
{
}

void URenderDevice::StaticConstructor()
{
}

void URenderDevice::StopVideo(UCanvas *)
{
}

int URenderDevice::OpenVideo(UCanvas *,char *,char *,int)
{
	return 0;
}

void URenderDevice::ChangeDrawingSurface(ER6SwitchSurface,int)
{
}

void URenderDevice::CloseVideo(UCanvas *)
{
}

void URenderDevice::DisplayVideo(UCanvas *,void *,int)
{
}

void URenderDevice::Draw3DLine(FVector,FVector,FColor,UTexture *,float,float,float,float)
{
}

void URenderDevice::GetAvailableResolutions(TArray<FResolutionInfo> &)
{
}

DWORD URenderDevice::GetAvailableVideoMemory()
{
	return 0;
}

void URenderDevice::HandleFullScreenEffects(int,int)
{
}

// --- UShader ---



// --- UShadowBitmapMaterial ---
void UShadowBitmapMaterial::Destroy()
{
}

UBitmapMaterial * UShadowBitmapMaterial::Get(double,UViewport *)
{
	return NULL;
}

FBaseTexture * UShadowBitmapMaterial::GetRenderInterface()
{
	return NULL;
}

// --- USkeletalMesh ---
void USkeletalMesh::ReconstructRawMesh()
{
}

int USkeletalMesh::RenderPreProcess()
{
	return 0;
}

UClass * USkeletalMesh::MeshGetInstanceClass()
{
	return NULL;
}

void USkeletalMesh::PostLoad()
{
}

// --- USkeletalMeshInstance ---
int USkeletalMeshInstance::WasSkeletonUpdated()
{
	return 0;
}

void USkeletalMeshInstance::MeshBuildBounds()
{
}

FMatrix USkeletalMeshInstance::MeshToWorld()
{
	return FMatrix();
}

// --- USkinVertexBuffer ---
void USkinVertexBuffer::Serialize(FArchive &)
{
}

// --- USound ---
void USound::PostLoad()
{
}

void USound::PS2Convert()
{
}

USound::USound(const TCHAR*,int)
{
}

// --- USoundGen ---
void USoundGen::Serialize(FArchive &)
{
}

// --- USparkEmitter ---
void USparkEmitter::SpawnParticle(int,float,int,int,FVector const &)
{
}

int USparkEmitter::UpdateParticles(float)
{
	return 0;
}

int USparkEmitter::RenderParticles(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
	return 0;
}

void USparkEmitter::PostEditChange()
{
}

void USparkEmitter::CleanUp()
{
}

void USparkEmitter::Initialize(int)
{
}

// --- USpriteEmitter ---
int USpriteEmitter::UpdateParticles(float)
{
	return 0;
}

int USpriteEmitter::RenderParticles(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
	return 0;
}

void USpriteEmitter::PostEditChange()
{
}

void USpriteEmitter::CleanUp()
{
}

int USpriteEmitter::FillVertexBuffer(FSpriteParticleVertex *,FLevelSceneNode *)
{
	return 0;
}

void USpriteEmitter::Initialize(int)
{
}

// --- UStaticMesh ---
void UStaticMesh::StaticConstructor()
{
}

void UStaticMesh::PostEditChange()
{
}

void UStaticMesh::PostLoad()
{
}

// --- UStaticMeshInstance ---
void UStaticMeshInstance::Serialize(FArchive &)
{
}

void UStaticMeshInstance::AttachProjectorClipped(AActor *,AProjector *)
{
}

void UStaticMeshInstance::DetachProjectorClipped(AProjector *)
{
}

// --- USubActionCameraEffect ---
int USubActionCameraEffect::Update(float,ASceneManager *)
{
	return 0;
}

FString USubActionCameraEffect::GetStatString()
{
	return FString();
}

// --- USubActionCameraShake ---
int USubActionCameraShake::Update(float,ASceneManager *)
{
	return 0;
}

FString USubActionCameraShake::GetStatString()
{
	return FString();
}

// --- USubActionFOV ---
int USubActionFOV::Update(float,ASceneManager *)
{
	return 0;
}

FString USubActionFOV::GetStatString()
{
	return FString();
}

// --- USubActionFade ---
int USubActionFade::Update(float,ASceneManager *)
{
	return 0;
}

FString USubActionFade::GetStatString()
{
	return FString();
}

// --- USubActionGameSpeed ---
int USubActionGameSpeed::Update(float,ASceneManager *)
{
	return 0;
}

FString USubActionGameSpeed::GetStatString()
{
	return FString();
}

// --- USubActionOrientation ---
int USubActionOrientation::Update(float,ASceneManager *)
{
	return 0;
}

void USubActionOrientation::PostLoad()
{
}

FString USubActionOrientation::GetStatString()
{
	return FString();
}

int USubActionOrientation::IsRunning()
{
	return 0;
}

// --- USubActionSceneSpeed ---
int USubActionSceneSpeed::Update(float,ASceneManager *)
{
	return 0;
}

FString USubActionSceneSpeed::GetStatString()
{
	return FString();
}

// --- USubActionTrigger ---
int USubActionTrigger::Update(float,ASceneManager *)
{
	return 0;
}

FString USubActionTrigger::GetStatString()
{
	return FString();
}

// --- UTerrainBrush ---
void UTerrainBrush::MouseButtonDown(UViewport *)
{
}

void UTerrainBrush::MouseButtonUp(UViewport *)
{
}

void UTerrainBrush::MouseMove(float,float)
{
}

UTerrainBrush::UTerrainBrush(UTerrainBrush const &)
{
}

UTerrainBrush::UTerrainBrush()
{
}

UTerrainBrush::~UTerrainBrush()
{
}

UTerrainBrush& UTerrainBrush::operator=(const UTerrainBrush&)
{
	return *this;
}

int UTerrainBrush::BeginPainting(UTexture * *,ATerrainInfo * *)
{
	return 0;
}

void UTerrainBrush::EndPainting(UTexture *,ATerrainInfo *)
{
}

void UTerrainBrush::Execute(int)
{
}

FBox UTerrainBrush::GetRect()
{
	return FBox();
}

// --- UTerrainBrushColor ---
UTerrainBrushColor::UTerrainBrushColor(UTerrainBrushColor const &)
{
}

UTerrainBrushColor::UTerrainBrushColor()
{
}

UTerrainBrushColor::~UTerrainBrushColor()
{
}

UTerrainBrushColor& UTerrainBrushColor::operator=(const UTerrainBrushColor&)
{
	return *this;
}

void UTerrainBrushColor::Execute(int)
{
}

// --- UTerrainBrushEdgeTurn ---
UTerrainBrushEdgeTurn::UTerrainBrushEdgeTurn(UTerrainBrushEdgeTurn const &)
{
}

UTerrainBrushEdgeTurn::UTerrainBrushEdgeTurn()
{
}

UTerrainBrushEdgeTurn::~UTerrainBrushEdgeTurn()
{
}

UTerrainBrushEdgeTurn& UTerrainBrushEdgeTurn::operator=(const UTerrainBrushEdgeTurn&)
{
	return *this;
}

void UTerrainBrushEdgeTurn::Execute(int)
{
}

FBox UTerrainBrushEdgeTurn::GetRect()
{
	return FBox();
}

// --- UTerrainBrushFlatten ---
UTerrainBrushFlatten::UTerrainBrushFlatten(UTerrainBrushFlatten const &)
{
}

UTerrainBrushFlatten::UTerrainBrushFlatten()
{
}

UTerrainBrushFlatten::~UTerrainBrushFlatten()
{
}

UTerrainBrushFlatten& UTerrainBrushFlatten::operator=(const UTerrainBrushFlatten&)
{
	return *this;
}

void UTerrainBrushFlatten::Execute(int)
{
}

// --- UTerrainBrushNoise ---
UTerrainBrushNoise::UTerrainBrushNoise(UTerrainBrushNoise const &)
{
}

UTerrainBrushNoise::UTerrainBrushNoise()
{
}

UTerrainBrushNoise::~UTerrainBrushNoise()
{
}

UTerrainBrushNoise& UTerrainBrushNoise::operator=(const UTerrainBrushNoise&)
{
	return *this;
}

void UTerrainBrushNoise::Execute(int)
{
}

// --- UTerrainBrushPaint ---
UTerrainBrushPaint::UTerrainBrushPaint(UTerrainBrushPaint const &)
{
}

UTerrainBrushPaint::UTerrainBrushPaint()
{
}

UTerrainBrushPaint::~UTerrainBrushPaint()
{
}

UTerrainBrushPaint& UTerrainBrushPaint::operator=(const UTerrainBrushPaint&)
{
	return *this;
}

void UTerrainBrushPaint::Execute(int)
{
}

// --- UTerrainBrushPlanningPaint ---
void UTerrainBrushPlanningPaint::MouseButtonDown(UViewport *)
{
}

UTerrainBrushPlanningPaint::UTerrainBrushPlanningPaint(UTerrainBrushPlanningPaint const &)
{
}

UTerrainBrushPlanningPaint::UTerrainBrushPlanningPaint()
{
}

UTerrainBrushPlanningPaint::~UTerrainBrushPlanningPaint()
{
}

UTerrainBrushPlanningPaint& UTerrainBrushPlanningPaint::operator=(const UTerrainBrushPlanningPaint&)
{
	return *this;
}

void UTerrainBrushPlanningPaint::Execute(int)
{
}

// --- UTerrainBrushSelect ---
void UTerrainBrushSelect::MouseButtonDown(UViewport *)
{
}

void UTerrainBrushSelect::MouseMove(float,float)
{
}

UTerrainBrushSelect::UTerrainBrushSelect(UTerrainBrushSelect const &)
{
}

UTerrainBrushSelect::UTerrainBrushSelect()
{
}

UTerrainBrushSelect::~UTerrainBrushSelect()
{
}

UTerrainBrushSelect& UTerrainBrushSelect::operator=(const UTerrainBrushSelect&)
{
	return *this;
}

void UTerrainBrushSelect::Execute(int)
{
}

FBox UTerrainBrushSelect::GetRect()
{
	return FBox();
}

// --- UTerrainBrushSmooth ---
UTerrainBrushSmooth::UTerrainBrushSmooth(UTerrainBrushSmooth const &)
{
}

UTerrainBrushSmooth::UTerrainBrushSmooth()
{
}

UTerrainBrushSmooth::~UTerrainBrushSmooth()
{
}

UTerrainBrushSmooth& UTerrainBrushSmooth::operator=(const UTerrainBrushSmooth&)
{
	return *this;
}

void UTerrainBrushSmooth::Execute(int)
{
}

// --- UTerrainBrushTexPan ---
void UTerrainBrushTexPan::MouseMove(float,float)
{
}

UTerrainBrushTexPan::UTerrainBrushTexPan(UTerrainBrushTexPan const &)
{
}

UTerrainBrushTexPan::UTerrainBrushTexPan()
{
}

UTerrainBrushTexPan::~UTerrainBrushTexPan()
{
}

UTerrainBrushTexPan& UTerrainBrushTexPan::operator=(const UTerrainBrushTexPan&)
{
	return *this;
}

// --- UTerrainBrushTexRotate ---
void UTerrainBrushTexRotate::MouseMove(float,float)
{
}

UTerrainBrushTexRotate::UTerrainBrushTexRotate(UTerrainBrushTexRotate const &)
{
}

UTerrainBrushTexRotate::UTerrainBrushTexRotate()
{
}

UTerrainBrushTexRotate::~UTerrainBrushTexRotate()
{
}

UTerrainBrushTexRotate& UTerrainBrushTexRotate::operator=(const UTerrainBrushTexRotate&)
{
	return *this;
}

// --- UTerrainBrushTexScale ---
void UTerrainBrushTexScale::MouseMove(float,float)
{
}

UTerrainBrushTexScale::UTerrainBrushTexScale(UTerrainBrushTexScale const &)
{
}

UTerrainBrushTexScale::UTerrainBrushTexScale()
{
}

UTerrainBrushTexScale::~UTerrainBrushTexScale()
{
}

UTerrainBrushTexScale& UTerrainBrushTexScale::operator=(const UTerrainBrushTexScale&)
{
	return *this;
}

// --- UTerrainBrushVertexEdit ---
UTerrainBrushVertexEdit::UTerrainBrushVertexEdit(UTerrainBrushVertexEdit const &)
{
}

UTerrainBrushVertexEdit::UTerrainBrushVertexEdit()
{
}

UTerrainBrushVertexEdit::~UTerrainBrushVertexEdit()
{
}

UTerrainBrushVertexEdit& UTerrainBrushVertexEdit::operator=(const UTerrainBrushVertexEdit&)
{
	return *this;
}

// --- UTerrainBrushVisibility ---
UTerrainBrushVisibility::UTerrainBrushVisibility(UTerrainBrushVisibility const &)
{
}

UTerrainBrushVisibility::UTerrainBrushVisibility()
{
}

UTerrainBrushVisibility::~UTerrainBrushVisibility()
{
}

UTerrainBrushVisibility& UTerrainBrushVisibility::operator=(const UTerrainBrushVisibility&)
{
	return *this;
}

void UTerrainBrushVisibility::Execute(int)
{
}

FBox UTerrainBrushVisibility::GetRect()
{
	return FBox();
}

// --- UTerrainMaterial ---
UMaterial * UTerrainMaterial::CheckFallback()
{
	return NULL;
}

int UTerrainMaterial::HasFallback()
{
	return 0;
}

// --- UTexCoordMaterial ---
int UTexCoordMaterial::MaterialUSize()
{
	return 0;
}

int UTexCoordMaterial::MaterialVSize()
{
	return 0;
}

// --- UTexCoordSource ---
void UTexCoordSource::PostEditChange()
{
}

// --- UTexEnvMap ---
FMatrix * UTexEnvMap::GetMatrix(float)
{
	return NULL;
}

// --- UTexMatrix ---
FMatrix * UTexMatrix::GetMatrix(float)
{
	return NULL;
}

// --- UTexModifier ---
void UTexModifier::SetValidated(int)
{
}

BYTE UTexModifier::RequiredUVStreams()
{
	return 0;
}

int UTexModifier::MaterialUSize()
{
	return 0;
}

int UTexModifier::MaterialVSize()
{
	return 0;
}

FMatrix * UTexModifier::GetMatrix(float)
{
	return NULL;
}

int UTexModifier::GetValidated()
{
	return 0;
}

// --- UTexOscillator ---
FMatrix * UTexOscillator::GetMatrix(float)
{
	return NULL;
}

// --- UTexPanner ---
FMatrix * UTexPanner::GetMatrix(float)
{
	return NULL;
}

// --- UTexRotator ---
void UTexRotator::PostLoad()
{
}

FMatrix * UTexRotator::GetMatrix(float)
{
	return NULL;
}

// --- UTexScaler ---
FMatrix * UTexScaler::GetMatrix(float)
{
	return NULL;
}

// --- UTexture ---


void UTexture::Prime()
{
}

// --- UVertMesh ---
int UVertMesh::RenderPreProcess()
{
	return 0;
}

void UVertMesh::Serialize(FArchive &)
{
}

UClass * UVertMesh::MeshGetInstanceClass()
{
	return NULL;
}

void UVertMesh::PostLoad()
{
}

FBox UVertMesh::GetRenderBoundingBox(AActor const *)
{
	return FBox();
}

FSphere UVertMesh::GetRenderBoundingSphere(AActor const *)
{
	return FSphere();
}

// --- UVertMeshInstance ---
void UVertMeshInstance::MeshBuildBounds()
{
}

FMatrix UVertMeshInstance::MeshToWorld()
{
	return FMatrix();
}

// --- UViewport ---
void UViewport::PushHit(HHitProxy const &,int)
{
}

void UViewport::RefreshAll()
{
}

void UViewport::LockOnActor(AActor *)
{
}

int UViewport::MultiShot()
{
	return 0;
}

void UViewport::PopHit(int)
{
}

void UViewport::ChangeInputSet(BYTE)
{
}

void UViewport::ExecProfile(const TCHAR*,int,FOutputDevice &)
{
}

void UViewport::ExecuteHits(FHitCause const &,BYTE*,int,TCHAR*,FColor *,AActor * *)
{
}

int UViewport::IsDepthComplexity()
{
	return 0;
}

int UViewport::IsEditing()
{
	return 0;
}

int UViewport::IsLit()
{
	return 0;
}

int UViewport::IsTopView()
{
	return 0;
}


struct FUV2Data;
struct FProjectorRelativeRenderInfo;
struct HHitProxy;
struct _KarmaGlobals;
struct _McdGeometry;
struct McdGeomMan;
struct _KarmaTriListData;


/*-----------------------------------------------------------------------------
  Data definitions
-----------------------------------------------------------------------------*/

UEngine * g_pEngine = NULL;

int AVIRecording = 0;

FString FURL::DefaultHost;

FString FURL::DefaultLocalMap;

FString FURL::DefaultMap;

FString FURL::DefaultMapExt;

FString FURL::DefaultName;

FString FURL::DefaultPortal;

FString FURL::DefaultProtocol;

FString FURL::DefaultProtocolDescription;

FString FURL::DefaultSaveExt;

UAudioSubsystem * USound::Audio = NULL;

UClient * UTexture::__Client = NULL;

float * USkeletalMeshInstance::m_fCylindersRadius = NULL;

int * FCollisionHash::HashX = NULL;

int * FCollisionHash::HashY = NULL;

int * FCollisionHash::HashZ = NULL;

int FCollisionHash::CollisionTag = 0;

int FCollisionHash::Inited = 0;

int FURL::DefaultPort = 0;

_KarmaGlobals * KGData = NULL;

static INT bGameShutDown = 0;


/*-----------------------------------------------------------------------------
  Implementations
-----------------------------------------------------------------------------*/

// Forward declarations for element serializers needed by TArray<T> template
// instantiation in stream/buffer serializers below.
FArchive & operator<<(FArchive & Ar, FBspVertex & V);
FArchive & operator<<(FArchive & Ar, FStaticMeshVertex & V);
FArchive & operator<<(FArchive & Ar, FStaticMeshUV & V);
FArchive & operator<<(FArchive & Ar, FTerrainVertex & V);

// ??6@YAAAVFArchive@@AAV0@AAVFAnimMeshVertexStream@@@Z
// FUN_10323030 = TArray<0x20-element>::Serialize. Each element via FUN_10446ec0 = 8×ByteOrderSerialize(4).
// Layout (after vtable): Pad[4] TArray<elem>  Pad[0x18] Revision
FArchive & operator<<(FArchive & Ar, FAnimMeshVertexStream & V) {
	// TArray at Pad[4] (obj+8), element size 0x20. Manual serialization.
	FArray& Arr = *(FArray*)&V.Pad[4];
	if (Ar.IsLoading()) {
		FCompactIndex count;
		Ar << count;
		INT n = *(INT*)&count;
		Arr.Empty(0x20, n);
		for (INT i = 0; i < n; i++) {
			INT idx = Arr.Add(1, 0x20);
			BYTE* elem = (BYTE*)Arr.GetData() + idx * 0x20;
			for (INT j = 0; j < 8; j++)
				Ar.ByteOrderSerialize(elem + j * 4, 4);
		}
	} else {
		Ar << *(FCompactIndex*)&V.Pad[8];  // ArrayNum as FCompactIndex
		for (INT i = 0; i < Arr.Num(); i++) {
			BYTE* elem = (BYTE*)Arr.GetData() + i * 0x20;
			for (INT j = 0; j < 8; j++)
				Ar.ByteOrderSerialize(elem + j * 4, 4);
		}
	}
	Ar.ByteOrderSerialize(&V.Pad[0x18], 4);  // Revision at Pad[0x18] = obj+0x1C
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFBspNode@@@Z
// Decoded from Ghidra Engine @ 0xcf6f0. Complex with ZoneMask (FUN_103cc610),
// sub-struct pairs (FUN_103cba20), version-gated multi-branch INT serialization.
// All internal functions fully decoded from _unnamed.cpp.
FArchive & operator<<(FArchive & Ar, FBspNode & V) {
	BYTE* P = (BYTE*)&V;

	// FPlane at offset 0x00 (X, Y, Z, W)
	Ar.ByteOrderSerialize(P + 0x00, 4);
	Ar.ByteOrderSerialize(P + 0x04, 4);
	Ar.ByteOrderSerialize(P + 0x08, 4);
	Ar.ByteOrderSerialize(P + 0x0C, 4);

	// ZoneMask at offset 0x10: 256-bit bitmask (8 DWORDs = 32 bytes)
	// FUN_103cc610: Ravenshield format (LicenseeVer >= 9)
	if (Ar.LicenseeVer() < 9) {
		// Legacy: 8-byte QWORD (pre-Ravenshield). Read and discard.
		BYTE temp[8];
		Ar.ByteOrderSerialize(temp, 8);
	} else {
		if (Ar.IsLoading()) {
			appMemzero(P + 0x10, 32);
		}
		INT NumBytes = 0x20;  // 32
		Ar.ByteOrderSerialize((BYTE*)&NumBytes, 4);
		for (INT i = 0; i < NumBytes; i++) {
			if (!Ar.IsLoading()) {
				// Saving: pack 8 bits from DWORD array into 1 byte
				BYTE packed = 0;
				for (INT bit = 0; bit < 8; bit++) {
					INT bitIndex = bit + i * 8;
					INT dwordIndex = bitIndex >> 5;
					INT bitOffset = bitIndex & 0x1F;
					if (((DWORD*)(P + 0x10))[dwordIndex] & (1 << bitOffset))
						packed |= (BYTE)(1 << (bit & 0x1F));
				}
				Ar.Serialize(&packed, 1);
			} else {
				// Loading: read 1 byte, unpack to DWORD bits
				BYTE packed;
				Ar.Serialize(&packed, 1);
				if ((DWORD)i < 0x20) {
					for (INT bit = 0; bit < 8; bit++) {
						if (packed & (1 << (bit & 0x1F))) {
							INT bitIndex = bit + i * 8;
							INT dwordIndex = bitIndex >> 5;
							INT bitOffset = bitIndex & 0x1F;
							((DWORD*)(P + 0x10))[dwordIndex] |= (1 << bitOffset);
						}
					}
				}
			}
		}
	}

	// 1 byte at offset 0x6F (flags byte)
	Ar.Serialize(P + 0x6F, 1);

	// FCompactIndex fields
	Ar << *(FCompactIndex*)(P + 0x30);
	Ar << *(FCompactIndex*)(P + 0x34);
	Ar << *(FCompactIndex*)(P + 0x38);
	Ar << *(FCompactIndex*)(P + 0x3C);
	Ar << *(FCompactIndex*)(P + 0x40);
	Ar << *(FCompactIndex*)(P + 0x64);
	Ar << *(FCompactIndex*)(P + 0x68);

	// Sub-structures at +0x44 and +0x54 (FUN_103cba20: version-gated 3 or 4 DWORDs)
	if (Ar.Ver() > 0x45) {
		// Sub-struct at 0x44
		Ar.ByteOrderSerialize(P + 0x44, 4);
		Ar.ByteOrderSerialize(P + 0x48, 4);
		Ar.ByteOrderSerialize(P + 0x4C, 4);
		if (Ar.Ver() >= 0x3E)
			Ar.ByteOrderSerialize(P + 0x50, 4);
		// Sub-struct at 0x54
		Ar.ByteOrderSerialize(P + 0x54, 4);
		Ar.ByteOrderSerialize(P + 0x58, 4);
		Ar.ByteOrderSerialize(P + 0x5C, 4);
		if (Ar.Ver() >= 0x3E)
			Ar.ByteOrderSerialize(P + 0x60, 4);
	}

	// 3 single bytes at 0x6C, 0x6D, 0x6E
	Ar.Serialize(P + 0x6C, 1);
	Ar.Serialize(P + 0x6D, 1);
	Ar.Serialize(P + 0x6E, 1);

	// 2 INTs at 0x70 and 0x74
	Ar.ByteOrderSerialize(P + 0x70, 4);
	Ar.ByteOrderSerialize(P + 0x74, 4);

	// Version-gated block for offsets 0x78, 0x7C, 0x80 (3 INTs)
	if (Ar.Ver() < 0x5C) {
		*(INT*)(P + 0x78) = -1;
		*(INT*)(P + 0x7C) = -1;
		*(INT*)(P + 0x80) = -1;
	} else if (Ar.Ver() > 100) {
		// Ver > 0x64: real serialization
		Ar.ByteOrderSerialize(P + 0x78, 4);
		Ar.ByteOrderSerialize(P + 0x7C, 4);
		Ar.ByteOrderSerialize(P + 0x80, 4);
		if (Ar.IsLoading() && Ar.Ver() < 0x6C)
			*(INT*)(P + 0x80) = -1;
	} else {
		// 0x5C <= Ver <= 100: read temp values into locals, discard
		INT temp1 = -1, temp2 = -1;
		if (Ar.Ver() < 0x5D) {
			Ar.ByteOrderSerialize((BYTE*)&temp1, 4);
		} else {
			Ar.ByteOrderSerialize((BYTE*)&temp1, 4);
			Ar.ByteOrderSerialize((BYTE*)&temp2, 4);
		}
		*(INT*)(P + 0x78) = -1;
		*(INT*)(P + 0x7C) = -1;
		*(INT*)(P + 0x80) = -1;
	}

	// Loading: mask top bits of flags byte at 0x6F
	if (Ar.IsLoading())
		P[0x6F] &= 0x1F;

	// FUN_103cf3d0 at offset 0x84 only in counting mode (neither loading nor saving)
	// — skipped as it has no effect on actual serialization.

	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFBspSection@@@Z
// Decoded from Ghidra Engine @ 0x27ad0. Uses TArray<FBspVertex> (FUN_10322590),
// UObject* at +0x20, and version-gated INT override.
// Layout: [0x00] vtable  [0x04] TArray<FBspVertex>  [0x18] INT  [0x1C] INT
//         [0x20] UObject*  [0x24] INT  [0x28] INT (ver-gated default -1)
FArchive & operator<<(FArchive & Ar, FBspSection & V) {
	Ar << *(TArray<FBspVertex>*)&V.Pad[4];       // TArray<FBspVertex> at obj+0x04
	Ar.ByteOrderSerialize(&V.Pad[0x18], 4);      // INT at obj+0x18
	Ar << *(UObject**)&V.Pad[0x20];               // UObject* at obj+0x20
	Ar.ByteOrderSerialize(&V.Pad[0x1C], 4);      // INT at obj+0x1C
	Ar.ByteOrderSerialize(&V.Pad[0x24], 4);      // INT at obj+0x24
	Ar.ByteOrderSerialize(&V.Pad[0x28], 4);      // INT at obj+0x28
	if (Ar.Ver() < 0x6B) {
		if (Ar.IsLoading()) {
			*(INT*)&V.Pad[0x28] = -1;
		}
	}
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFBspSurf@@@Z
// Decoded from Ghidra Engine @ 0xcbf50. Uses vtable+0x18 (UObject*), FCompactIndex,
// ByteOrderSerialize, and Serialize. No FUN_xxx dependencies.
FArchive & operator<<(FArchive & Ar, FBspSurf & V) {
	Ar << V.Texture;
	Ar.ByteOrderSerialize((BYTE*)&V.PolyFlags, 4);
	Ar << *(FCompactIndex*)&V.pBase;
	Ar << *(FCompactIndex*)&V.vNormal;
	Ar << *(FCompactIndex*)&V.vTextureU;
	Ar << *(FCompactIndex*)&V.vTextureV;
	if (Ar.Ver() < 0x65) {
		FCompactIndex temp;
		*(INT*)&temp = -1;
		Ar << temp;
	}
	Ar << *(FCompactIndex*)&V.iLightMap;
	if (Ar.Ver() < 0x4e) {
		_WORD temp1 = 0, temp2 = 0;
		Ar.ByteOrderSerialize((BYTE*)&temp1, 2);
		Ar.ByteOrderSerialize((BYTE*)&temp2, 2);
	}
	Ar << V.Actor;
	if (Ar.Ver() > 0x56) {
		Ar.ByteOrderSerialize((BYTE*)&V.Plane.X, 4);
		Ar.ByteOrderSerialize((BYTE*)&V.Plane.Y, 4);
		Ar.ByteOrderSerialize((BYTE*)&V.Plane.Z, 4);
		Ar.ByteOrderSerialize((BYTE*)&V.Plane.W, 4);
	}
	if (Ar.LicenseeVer() > 3) {
		Ar.ByteOrderSerialize(&V._RvsExtra[0x00], 4);       // offset 0x48
		Ar.Serialize(&V._RvsExtra[0x08], 1);                 // offset 0x50
		Ar.Serialize(&V._RvsExtra[0x0E], 1);                 // offset 0x56
		Ar.Serialize(&V._RvsExtra[0x0D], 1);                 // offset 0x55
		Ar.Serialize(&V._RvsExtra[0x0C], 1);                 // offset 0x54
		Ar.Serialize(&V._RvsExtra[0x0F], 1);                 // offset 0x57
	}
	if (Ar.LicenseeVer() > 4) {
		Ar.Serialize(&V._RvsExtra[0x10], 1);                 // offset 0x58
	}
	if (Ar.LicenseeVer() > 6) {
		Ar.ByteOrderSerialize(&V._RvsExtra[0x04], 4);       // offset 0x4C
	}
	if (Ar.Ver() > 0x69) {
		Ar.ByteOrderSerialize((BYTE*)&V.LightMapScale, 4);
	} else if (Ar.IsLoading()) {
		V.LightMapScale = 32.0f;
	}
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFBspVertexStream@@@Z
// FUN_10322590 = TArray<FBspVertex>::Serialize (elem_size 0x28)
// Layout (after vtable): Pad[0] TArray<FBspVertex>  Pad[0x14] Revision
FArchive & operator<<(FArchive & Ar, FBspVertexStream & V) {
	Ar << *(TArray<FBspVertex>*)V.Pad;            // TArray at Pad[0] = obj+0x04
	Ar.ByteOrderSerialize(&V.Pad[0x14], 4);      // Revision at Pad[0x14] = obj+0x18
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFLightMap@@@Z
FArchive & operator<<(FArchive & p0, FLightMap & p1) { static FArchive dummy; return dummy; }

// ??6@YAAAVFArchive@@AAV0@AAVFLightMapTexture@@@Z
FArchive & operator<<(FArchive & p0, FLightMapTexture & p1) { static FArchive dummy; return dummy; }

// ??6@YAAAVFArchive@@AAV0@AAVFPoly@@@Z
FArchive & operator<<(FArchive & Ar, FPoly & V) {
	// NumVertices first (compact index)
	Ar << *(FCompactIndex*)&V.NumVertices;
	// Base(3) + Normal(3) + TextureU(3) + TextureV(3) = 12 floats
	for (INT i = 0; i < 12; i++)
		Ar.ByteOrderSerialize((BYTE*)&V.Base + i * 4, 4);
	// Variable-length vertex array
	for (INT i = 0; i < V.NumVertices; i++) {
		Ar.ByteOrderSerialize(&V.Vertex[i].X, 4);
		Ar.ByteOrderSerialize(&V.Vertex[i].Y, 4);
		Ar.ByteOrderSerialize(&V.Vertex[i].Z, 4);
	}
	// PolyFlags
	Ar.ByteOrderSerialize(&V.PolyFlags, 4);
	// Object references and name
	Ar << *(UObject**)&V.Actor;
	Ar << *(UObject**)&V.Material;
	Ar << V.ItemName;
	// Link indices
	Ar << *(FCompactIndex*)&V.iLink;
	Ar << *(FCompactIndex*)&V.iBrushPoly;
	// Legacy Ver < 0x4E path omitted (pre-Ravenshield format)
	// Ravenshield extensions (LicenseeVer > 5)
	if (Ar.LicenseeVer() > 5) {
		Ar.ByteOrderSerialize(&V._RvsExtra[0x38], 4);
		Ar.Serialize(&V._RvsExtra[0x40], 1);
		Ar.Serialize(&V._RvsExtra[0x46], 1);
		Ar.Serialize(&V._RvsExtra[0x45], 1);
		Ar.Serialize(&V._RvsExtra[0x44], 1);
		Ar.Serialize(&V._RvsExtra[0x47], 1);
		Ar.Serialize(&V._RvsExtra[0x48], 1);
	}
	if (Ar.LicenseeVer() > 6) {
		Ar.ByteOrderSerialize(&V._RvsExtra[0x3C], 4);
	}
	if (Ar.Ver() > 0x69) {
		Ar.ByteOrderSerialize(&V._RvsExtra[0x34], 4);
	} else if (Ar.IsLoading()) {
		*(FLOAT*)&V._RvsExtra[0x34] = 32.0f; // Default LightMapScale
	}
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFRaw32BitIndexBuffer@@@Z
// FUN_1037fbd0 = TArray<DWORD>::Serialize (elem_size 4, ByteOrderSerialize per element)
// Layout (after vtable): Pad[0] TArray<DWORD>  Pad[0x14] Revision
FArchive & operator<<(FArchive & Ar, FRaw32BitIndexBuffer & V) {
	Ar << *(TArray<DWORD>*)V.Pad;                 // TArray at Pad[0] = obj+0x04
	Ar.ByteOrderSerialize(&V.Pad[0x14], 4);      // Revision at Pad[0x14] = obj+0x18
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFRawColorStream@@@Z
// FUN_104170d0 = Custom TArray<FColor>::Serialize with BGRA byte order.
// Original serializes per-element bytes in order: [2]=B, [1]=G, [0]=R, [3]=A.
// Layout (after vtable): Pad[0] TArray<FColor>  Pad[0x14] Revision
FArchive & operator<<(FArchive & Ar, FRawColorStream & V) {
	TArray<FColor>& Colors = *(TArray<FColor>*)V.Pad;
	Colors.CountBytes(Ar);
	if (Ar.IsLoading()) {
		FCompactIndex count;
		Ar << count;
		INT n = *(INT*)&count;
		Colors.Empty(n);
		for (INT i = 0; i < n; i++) {
			INT idx = Colors.Add();
			BYTE* elem = (BYTE*)&Colors(idx);
			Ar.Serialize(elem + 2, 1);  // B
			Ar.Serialize(elem + 1, 1);  // G
			Ar.Serialize(elem + 0, 1);  // R
			Ar.Serialize(elem + 3, 1);  // A
		}
	} else {
		Ar << *(FCompactIndex*)&V.Pad[4];  // ArrayNum as FCompactIndex
		for (INT i = 0; i < Colors.Num(); i++) {
			BYTE* elem = (BYTE*)&Colors(i);
			Ar.Serialize(elem + 2, 1);  // B
			Ar.Serialize(elem + 1, 1);  // G
			Ar.Serialize(elem + 0, 1);  // R
			Ar.Serialize(elem + 3, 1);  // A
		}
	}
	Ar.ByteOrderSerialize(&V.Pad[0x14], 4);  // Revision at Pad[0x14] = obj+0x18
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFRawIndexBuffer@@@Z
// FUN_1031e600 = TArray<_WORD>::Serialize (elem_size 2, ByteOrderSerialize per element)
// Layout (after vtable): Pad[0] TArray<_WORD>  Pad[0x14] Revision
FArchive & operator<<(FArchive & Ar, FRawIndexBuffer & V) {
	Ar << *(TArray<_WORD>*)V.Pad;                 // TArray at Pad[0] = obj+0x04
	Ar.ByteOrderSerialize(&V.Pad[0x14], 4);      // Revision at Pad[0x14] = obj+0x18
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFSkinVertexStream@@@Z
// Decoded from Ghidra Engine @ 0x2b750. Conditionally serializes two UObject* refs
// (only when !IsPersistent), then 3 INTs, then TArray<0x20-elem> via FUN_10323030.
// Layout (after vtable): Pad[0] UObject*  Pad[4] UObject*  Pad[0x10] INT
//   Pad[0x14] INT  Pad[0x18] INT  Pad[0x1C] TArray<0x20-elem>
FArchive & operator<<(FArchive & Ar, FSkinVertexStream & V) {
	if (!Ar.IsPersistent()) {
		Ar << *(UObject**)&V.Pad[0x00];   // UObject* at Pad[0] = obj+0x04
		Ar << *(UObject**)&V.Pad[0x04];   // UObject* at Pad[4] = obj+0x08
	}
	Ar.ByteOrderSerialize(&V.Pad[0x10], 4);  // INT at Pad[0x10] = obj+0x14
	Ar.ByteOrderSerialize(&V.Pad[0x14], 4);  // INT at Pad[0x14] = obj+0x18
	Ar.ByteOrderSerialize(&V.Pad[0x18], 4);  // INT at Pad[0x18] = obj+0x1C
	// TArray<0x20-elem> at Pad[0x1C] (obj+0x20), serialized same as FAnimMeshVertexStream
	FArray& Arr = *(FArray*)&V.Pad[0x1C];
	Arr.CountBytes(Ar, 0x20);
	if (Ar.IsLoading()) {
		FCompactIndex count;
		Ar << count;
		INT n = *(INT*)&count;
		Arr.Empty(0x20, n);
		for (INT i = 0; i < n; i++) {
			INT idx = Arr.Add(1, 0x20);
			BYTE* elem = (BYTE*)Arr.GetData() + idx * 0x20;
			for (INT j = 0; j < 8; j++)
				Ar.ByteOrderSerialize(elem + j * 4, 4);
		}
	} else {
		Ar << *(FCompactIndex*)&V.Pad[0x20]; // TArray.ArrayNum at Pad[0x1C]+4
		for (INT i = 0; i < Arr.Num(); i++) {
			BYTE* elem = (BYTE*)Arr.GetData() + i * 0x20;
			for (INT j = 0; j < 8; j++)
				Ar.ByteOrderSerialize(elem + j * 4, 4);
		}
	}
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFStaticLightMapTexture@@@Z
FArchive & operator<<(FArchive & p0, FStaticLightMapTexture & p1) { static FArchive dummy; return dummy; }

// ??6@YAAAVFArchive@@AAV0@AAVFStaticMeshBatcherVertex@@@Z
FArchive & operator<<(FArchive & Ar, FStaticMeshBatcherVertex & p1) { return Ar; } // empty in original

// ??6@YAAAVFArchive@@AAV0@AAVFStaticMeshLightInfo@@@Z
// Decoded from Ghidra Engine @ 0x21750. UObject* at +0, TArray<BYTE> at +4
// (FUN_1031cce0 = bulk byte array), INT at +0x10.
FArchive & operator<<(FArchive & Ar, FStaticMeshLightInfo & V) {
	Ar << V.LightObject;
	Ar << V.LightData;
	Ar.ByteOrderSerialize((BYTE*)&V.Field10, 4);
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFStaticMeshMaterial@@@Z
FArchive & operator<<(FArchive & Ar, FStaticMeshMaterial & V) {
	Ar << *(UObject**)&V.Material;
	Ar << *(FCompactIndex*)&V.Flags1;
	Ar << *(FCompactIndex*)&V.Flags2;
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFStaticMeshSection@@@Z
FArchive & operator<<(FArchive & p0, FStaticMeshSection & p1) { static FArchive dummy; return dummy; }

// ??6@YAAAVFArchive@@AAV0@AAVFStaticMeshUVStream@@@Z
// FUN_10324510 = TArray<FStaticMeshUV>::Serialize (elem_size 8, two floats per elem)
// Layout (after vtable): Pad[0] TArray<FStaticMeshUV>  Pad[0x0C] INT  Pad[0x18] Revision
FArchive & operator<<(FArchive & Ar, FStaticMeshUVStream & V) {
	Ar << *(TArray<FStaticMeshUV>*)V.Pad;         // TArray at Pad[0] = obj+0x04
	Ar.ByteOrderSerialize(&V.Pad[0x0C], 4);      // INT at Pad[0x0C] = obj+0x10
	Ar.ByteOrderSerialize(&V.Pad[0x18], 4);      // Revision at Pad[0x18] = obj+0x1C
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFStaticMeshVertexStream@@@Z
// FUN_103243e0 = TArray<FStaticMeshVertex>::Serialize (elem_size 0x18)
// Layout (after vtable): Pad[0] TArray<FStaticMeshVertex>  Pad[0x14] Revision
FArchive & operator<<(FArchive & Ar, FStaticMeshVertexStream & V) {
	Ar << *(TArray<FStaticMeshVertex>*)V.Pad;     // TArray at Pad[0] = obj+0x04
	Ar.ByteOrderSerialize(&V.Pad[0x14], 4);      // Revision at Pad[0x14] = obj+0x18
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFTags@@@Z
// Decoded from Ghidra Engine @ 0xcc180. Inlines FUN_103cbaa0 (12×4-byte flat serialize)
// then serializes FString at offset 0x30.
FArchive & operator<<(FArchive & Ar, FTags & V) {
	for (INT i = 0; i < 12; i++)
		Ar.ByteOrderSerialize(V._Data + i * 4, 4);
	Ar << V.TagString;
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFTerrainVertexStream@@@Z
// FUN_10323cd0 = TArray<FTerrainVertex>::Serialize (elem_size 0x24)
FArchive & operator<<(FArchive & Ar, FTerrainVertexStream & V) {
	Ar << V.Vertices;
	Ar.ByteOrderSerialize((BYTE*)&V.Revision, 4);
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAVFURL@@@Z
FArchive & operator<<(FArchive& Ar, FURL& U) {
	Ar << U.Protocol << U.Host << U.Map << U.Portal << U.Op;
	Ar << U.Port << U.Valid;
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFBspVertex@@@Z
FArchive & operator<<(FArchive & Ar, FBspVertex & V) {
	// Always serialize: offsets 0x00-0x08 (3 floats), 0x18-0x24 (4 floats)
	Ar.ByteOrderSerialize(&V._Data[0x00], 4);
	Ar.ByteOrderSerialize(&V._Data[0x04], 4);
	Ar.ByteOrderSerialize(&V._Data[0x08], 4);
	Ar.ByteOrderSerialize(&V._Data[0x18], 4);
	Ar.ByteOrderSerialize(&V._Data[0x1C], 4);
	Ar.ByteOrderSerialize(&V._Data[0x20], 4);
	Ar.ByteOrderSerialize(&V._Data[0x24], 4);
	// Version > 108: serialize 3 more floats at 0x0C-0x14
	if (Ar.Ver() > 0x6C) {
		Ar.ByteOrderSerialize(&V._Data[0x0C], 4);
		Ar.ByteOrderSerialize(&V._Data[0x10], 4);
		Ar.ByteOrderSerialize(&V._Data[0x14], 4);
	}
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFPosNormTexData@@@Z
FArchive & operator<<(FArchive & Ar, FPosNormTexData & V) {
	// 10 floats: offsets 0x00-0x24
	for (INT i = 0; i < 10; i++)
		Ar.ByteOrderSerialize(&V._Data[i * 4], 4);
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFProjectorRelativeRenderInfo@@@Z
FArchive & operator<<(FArchive & p0, FProjectorRelativeRenderInfo & p1) { static FArchive dummy; return dummy; }

// ??6@YAAAVFArchive@@AAV0@PAUFProjectorRenderInfo@@@Z
FArchive & operator<<(FArchive & p0, FProjectorRenderInfo * p1) { static FArchive dummy; return dummy; }

// ??6@YAAAVFArchive@@AAV0@AAUFSkinVertex@@@Z
FArchive & operator<<(FArchive & Ar, FSkinVertex & V) {
	// 16 floats: offsets 0x00-0x3C
	for (INT i = 0; i < 16; i++)
		Ar.ByteOrderSerialize(&V._Data[i * 4], 4);
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFStaticMeshCollisionNode@@@Z
FArchive & operator<<(FArchive & Ar, FStaticMeshCollisionNode & V) {
	// 4 FCompactIndex values at offsets 0x00, 0x04, 0x08, 0x0C
	Ar << *(FCompactIndex*)&V._Data[0x00];
	Ar << *(FCompactIndex*)&V._Data[0x04];
	Ar << *(FCompactIndex*)&V._Data[0x08];
	Ar << *(FCompactIndex*)&V._Data[0x0C];
	// FBox at offset 0x10
	Ar << V.Box;
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFStaticMeshCollisionTriangle@@@Z
FArchive & operator<<(FArchive & Ar, FStaticMeshCollisionTriangle & V) {
	// 16 floats (4 FPlanes) via ByteOrderSerialize
	for (INT i = 0; i < 16; i++)
		Ar.ByteOrderSerialize(&V._Data[i * 4], 4);
	// 4 FCompactIndex values at offsets 0x40, 0x44, 0x48, 0x4C
	Ar << *(FCompactIndex*)&V._Data[0x40];
	Ar << *(FCompactIndex*)&V._Data[0x44];
	Ar << *(FCompactIndex*)&V._Data[0x48];
	Ar << *(FCompactIndex*)&V._Data[0x4C];
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFStaticMeshUV@@@Z
FArchive & operator<<(FArchive & Ar, FStaticMeshUV & V) {
	Ar.ByteOrderSerialize(&V._Data[0], 4);
	Ar.ByteOrderSerialize(&V._Data[4], 4);
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFStaticMeshVertex@@@Z
FArchive & operator<<(FArchive & Ar, FStaticMeshVertex & V) {
	// 6 floats: Position (3) + Normal (3)
	for (INT i = 0; i < 6; i++)
		Ar.ByteOrderSerialize(&V._Data[i * 4], 4);
	// Legacy version paths for Ver < 0x70 and Ver == 0x6F omitted
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFTerrainVertex@@@Z
FArchive & operator<<(FArchive & Ar, FTerrainVertex & V) {
	// 6 floats at 0x00-0x14
	for (INT i = 0; i < 6; i++)
		Ar.ByteOrderSerialize(&V._Data[i * 4], 4);
	// 4 individual bytes at 0x18-0x1B (serialized in reverse order per Ghidra)
	Ar.Serialize(&V._Data[0x1A], 1);
	Ar.Serialize(&V._Data[0x19], 1);
	Ar.Serialize(&V._Data[0x18], 1);
	Ar.Serialize(&V._Data[0x1B], 1);
	// 2 floats at 0x1C-0x20
	Ar.ByteOrderSerialize(&V._Data[0x1C], 4);
	Ar.ByteOrderSerialize(&V._Data[0x20], 4);
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFUV2Data@@@Z
FArchive & operator<<(FArchive & Ar, FUV2Data & D) {
	Ar.ByteOrderSerialize(&D, 4);
	Ar.ByteOrderSerialize((BYTE*)&D + 4, 4);
	return Ar;
}

// ??6@YAAAVFArchive@@AAV0@AAUFUntransformedVertex@@@Z
FArchive & operator<<(FArchive & Ar, FUntransformedVertex & V) {
	// 11 floats: offsets 0x00-0x28
	for (INT i = 0; i < 11; i++)
		Ar.ByteOrderSerialize(&V._Data[i * 4], 4);
	return Ar;
}

// ?GNewCollisionHash@@YAPAVFCollisionHashBase@@XZ
FCollisionHashBase * GNewCollisionHash() {
	if( !GIsEditor )
		return new FCollisionOctree();
	else
		return new FCollisionHash();
}

// ?FGetHSV@@YA?AVFPlane@@EEE@Z
FPlane FGetHSV(BYTE p0, BYTE p1, BYTE p2) { return FPlane(); }

// Forward declaration for overloaded variants below
int GetSUBSTRING(const TCHAR* Stream, const TCHAR* Match, TCHAR* Value, int MaxLen);

// ?GetFROTATOR@@YAHPBGAAVFRotator@@H@Z
int GetFROTATOR(const TCHAR* Stream, FRotator& Rotation, int ScaleFactor)
{
	FLOAT Temp = 0.f;
	int Count = 0;
	if( Parse( Stream, TEXT("PITCH="), Temp ) ) { Rotation.Pitch = (INT)(Temp * ScaleFactor); Count++; }
	if( Parse( Stream, TEXT("YAW="), Temp ) )   { Rotation.Yaw   = (INT)(Temp * ScaleFactor); Count++; }
	if( Parse( Stream, TEXT("ROLL="), Temp ) )  { Rotation.Roll  = (INT)(Temp * ScaleFactor); Count++; }
	if( Count > 0 )
		return 1;
	Rotation.Pitch = (INT)(appAtof( Stream ) * ScaleFactor);
	TCHAR* S = appStrchr( Stream, ',' );
	if( S )
	{
		Rotation.Yaw = (INT)(appAtof( S + 1 ) * ScaleFactor);
		S = appStrchr( S + 1, ',' );
		if( S )
		{
			Rotation.Roll = (INT)(appAtof( S + 1 ) * ScaleFactor);
			return 1;
		}
	}
	return 0;
}

// ?GetFROTATOR@@YAHPBG0AAVFRotator@@H@Z
int GetFROTATOR(const TCHAR* Stream, const TCHAR* Match, FRotator& Rotation, int ScaleFactor)
{
	TCHAR Temp[80];
	if( !GetSUBSTRING( Stream, Match, Temp, 80 ) )
		return 0;
	return GetFROTATOR( Temp, Rotation, ScaleFactor );
}

// ?GetFVECTOR@@YAHPBGAAVFVector@@@Z
int GetFVECTOR(const TCHAR* Stream, FVector& Value)
{
	int NumParsed = 0;
	NumParsed += Parse( Stream, TEXT("X="), Value.X );
	NumParsed += Parse( Stream, TEXT("Y="), Value.Y );
	NumParsed += Parse( Stream, TEXT("Z="), Value.Z );
	if( NumParsed > 0 )
		return NumParsed == 3;
	Value.X = appAtof( Stream );
	TCHAR* S = appStrchr( Stream, ',' );
	if( S )
	{
		Value.Y = appAtof( S + 1 );
		S = appStrchr( S + 1, ',' );
		if( S )
		{
			Value.Z = appAtof( S + 1 );
			return 1;
		}
	}
	return 0;
}

// ?GetFVECTOR@@YAHPBG0AAVFVector@@@Z
int GetFVECTOR(const TCHAR* Stream, const TCHAR* Match, FVector& Value)
{
	TCHAR Temp[80];
	if( !GetSUBSTRING( Stream, Match, Temp, 80 ) )
		return 0;
	return GetFVECTOR( Temp, Value );
}

// ?GetSUBSTRING@@YAHPBG0PAGH@Z
int GetSUBSTRING(const TCHAR* Stream, const TCHAR* Match, TCHAR* Value, int MaxLen)
{
	const TCHAR* Found = appStrfind( Stream, Match );
	if( !Found )
		return 0;
	Found += appStrlen( Match );
	int i = 0;
	while( *Found && *Found != ' ' && *Found != '\t' && i < MaxLen - 1 )
		Value[i++] = *Found++;
	Value[i] = 0;
	return 1;
}

// ?getGameShutDown@@YAHXZ
int getGameShutDown() { return bGameShutDown; }

// ?newPath@FPathBuilder@@AAEPAVANavigationPoint@@VFVector@@@Z
ANavigationPoint * FPathBuilder::newPath(FVector p0) { return NULL; }

// ?DistanceToHashPlane@FCollisionHash@@AAEMHMMH@Z
float FCollisionHash::DistanceToHashPlane(int p0, float p1, float p2, int p3) { return 0; }


// ?TestReach@FPathBuilder@@AAEHVFVector@@0@Z
int FPathBuilder::TestReach(FVector p0, FVector p1) { return 0; }

// ?TestWalk@FPathBuilder@@AAEHVFVector@@UFCheckResult@@M@Z
int FPathBuilder::TestWalk(FVector p0, FCheckResult p1, float p2) { return 0; }

// ?ValidNode@FPathBuilder@@AAEHPAVANavigationPoint@@PAVAActor@@@Z
int FPathBuilder::ValidNode(ANavigationPoint * p0, AActor * p1) { return 0; }

// ?createPaths@FPathBuilder@@AAEHXZ
int FPathBuilder::createPaths() { return 0; }

// ?StoreActor@FOctreeNode@@AAEXPAVAActor@@PAVFCollisionOctree@@PBVFPlane@@@Z
void FOctreeNode::StoreActor(AActor * p0, FCollisionOctree * p1, FPlane const * p2) {}

// ?FindBlockingNormal@FPathBuilder@@AAEXAAVFVector@@@Z
void FPathBuilder::FindBlockingNormal(FVector & p0) {}

// ?Pass2From@FPathBuilder@@AAEXVFVector@@0M@Z
void FPathBuilder::Pass2From(FVector p0, FVector p1, float p2) {}

// ?SetPathCollision@FPathBuilder@@AAEXH@Z
void FPathBuilder::SetPathCollision(int p0) {}

// ?getScout@FPathBuilder@@AAEXXZ
void FPathBuilder::getScout() {}

// ?testPathsFrom@FPathBuilder@@AAEXVFVector@@@Z
void FPathBuilder::testPathsFrom(FVector p0) {}

// ?testPathwithRadius@FPathBuilder@@AAEXVFVector@@M@Z
void FPathBuilder::testPathwithRadius(FVector p0, float p1) {}

// ??0ECLipSynchData@@QAE@PAVUMeshInstance@@PAVUSound@@1PAVAActor@@@Z
ECLipSynchData::ECLipSynchData(UMeshInstance * p0, USound * p1, USound * p2, AActor * p3) {}

// ??0ECLipSynchData@@QAE@XZ
ECLipSynchData::ECLipSynchData() {}

// ??0FActorSceneNode@@QAE@PAVUViewport@@PAVAActor@@1VFVector@@VFRotator@@M@Z
FActorSceneNode::FActorSceneNode(UViewport * p0, AActor * p1, AActor * p2, FVector p3, FRotator p4, float p5) : FSceneNode((UViewport*)NULL) {}

// ??0FCameraSceneNode@@QAE@PAVUViewport@@PAVAActor@@VFVector@@VFRotator@@M@Z
FCameraSceneNode::FCameraSceneNode(UViewport * p0, AActor * p1, FVector p2, FRotator p3, float p4) : FSceneNode((UViewport*)NULL) {}

// ??0FCollisionHash@@QAE@ABV0@@Z
FCollisionHash::FCollisionHash(FCollisionHash const & p0) {}

// ??0FCollisionHash@@QAE@XZ
FCollisionHash::FCollisionHash() {}

// ??0FCollisionOctree@@QAE@ABV0@@Z
FCollisionOctree::FCollisionOctree(FCollisionOctree const & p0) {}

// ??0FCollisionOctree@@QAE@XZ
FCollisionOctree::FCollisionOctree() {}

// ??0FDirectionalLightMapSceneNode@@QAE@PAVUViewport@@PAVAActor@@AAVFBspSurf@@PAVFLightMap@@@Z
FDirectionalLightMapSceneNode::FDirectionalLightMapSceneNode(UViewport * p0, AActor * p1, FBspSurf & p2, FLightMap * p3) : FSceneNode((UViewport*)NULL) {}

// ??0FHitCause@@QAE@PAVFHitObserver@@PAVUViewport@@KMM@Z
FHitCause::FHitCause(FHitObserver* InObserver, UViewport* InViewport, DWORD InButtons, float InMouseX, float InMouseY)
:	Observer(InObserver)
,	Viewport(InViewport)
,	Buttons(InButtons)
,	MouseX(InMouseX)
,	MouseY(InMouseY)
{}

// ??4FHitCause@@QAEAAU0@ABU0@@Z
FHitCause& FHitCause::operator=(const FHitCause& Other)
{
	Observer = Other.Observer;
	Viewport = Other.Viewport;
	Buttons  = Other.Buttons;
	MouseX   = Other.MouseX;
	MouseY   = Other.MouseY;
	return *this;
}

// ??0FLevelSceneNode@@QAE@PAV0@HVFMatrix@@@Z
FLevelSceneNode::FLevelSceneNode(FLevelSceneNode * p0, int p1, FMatrix p2) : FSceneNode((UViewport*)NULL) {}

// ??0FLevelSceneNode@@QAE@ABV0@@Z
FLevelSceneNode::FLevelSceneNode(FLevelSceneNode const & p0) : FSceneNode((UViewport*)NULL) {}

// ??0FLevelSceneNode@@QAE@PAVUViewport@@@Z
FLevelSceneNode::FLevelSceneNode(UViewport * p0) : FSceneNode((UViewport*)NULL) {}

// ??0FLightMapSceneNode@@QAE@PAVUViewport@@PAVAActor@@PAVFLightMap@@@Z
FLightMapSceneNode::FLightMapSceneNode(UViewport * p0, AActor * p1, FLightMap * p2) : FSceneNode((UViewport*)NULL) {}

// ??0FMatineeTools@@QAE@ABV0@@Z
FMatineeTools::FMatineeTools(FMatineeTools const & p0) {}

// ??0FOctreeNode@@QAE@ABV0@@Z
FOctreeNode::FOctreeNode(FOctreeNode const & p0) {}

// ??0FOctreeNode@@QAE@XZ
FOctreeNode::FOctreeNode() {}

// ??1FOctreeNode@@QAE@XZ
FOctreeNode::~FOctreeNode() {}

// ??0FPointLightMapSceneNode@@QAE@PAVUViewport@@PAVAActor@@AAVFBspSurf@@PAVFLightMap@@HHHH@Z
FPointLightMapSceneNode::FPointLightMapSceneNode(UViewport * p0, AActor * p1, FBspSurf & p2, FLightMap * p3, int p4, int p5, int p6, int p7) : FSceneNode((UViewport*)NULL) {}

// ??0FPoly@@QAE@XZ
FPoly::FPoly() {
	Init();
}

// ??0FRebuildTools@@QAE@ABV0@@Z
FRebuildTools::FRebuildTools(FRebuildTools const & p0) {}

// ??1FRebuildTools@@QAE@XZ
FRebuildTools::~FRebuildTools() {}

// ??0FRotatorF@@QAE@VFRotator@@@Z
FRotatorF::FRotatorF(FRotator R) : Pitch((FLOAT)R.Pitch), Yaw((FLOAT)R.Yaw), Roll((FLOAT)R.Roll) {}

// ??0FRotatorF@@QAE@MMM@Z
FRotatorF::FRotatorF(float InPitch, float InYaw, float InRoll) : Pitch(InPitch), Yaw(InYaw), Roll(InRoll) {}

// ??0FRotatorF@@QAE@XZ
FRotatorF::FRotatorF() {}

// ??0FSceneNode@@QAE@PAV0@@Z
FSceneNode::FSceneNode(FSceneNode * p0) {}

// ??0FSceneNode@@QAE@ABV0@@Z
FSceneNode::FSceneNode(FSceneNode const & p0) {}

// ??0FSceneNode@@QAE@PAVUViewport@@@Z
FSceneNode::FSceneNode(UViewport * p0) {}

// ??0FStatGraph@@QAE@ABV0@@Z
FStatGraph::FStatGraph(FStatGraph const & p0) {}

// ??1FStatGraph@@QAE@XZ
FStatGraph::~FStatGraph() {}

// ??0FURL@@QAE@PAV0@PBGW4ETravelType@@@Z
// Ghidra at 0x171a30. Full URL parser: handles travel types, options, protocol/host/port/map/portal.
FURL::FURL(FURL* Base, const TCHAR* TextURL, ETravelType Type) {
	// Initialize with defaults
	Protocol = DefaultProtocol;
	Host     = DefaultHost;
	Port     = DefaultPort;
	Map      = DefaultMap;
	Portal   = DefaultPortal;
	Valid    = 1;

	check(TextURL);

	// Copy to mutable local buffer
	TCHAR Temp[1024];
	appStrncpy(Temp, TextURL, ARRAY_COUNT(Temp));
	TCHAR* Str = Temp;

	// TRAVEL_Relative: copy URL fields from Base
	if (Type == TRAVEL_Relative) {
		check(Base);
		Protocol = Base->Protocol;
		Host     = Base->Host;
		Map      = Base->Map;
		Portal   = Base->Portal;
		Port     = Base->Port;
	}

	// TRAVEL_Relative and TRAVEL_Partial: copy non-transient options from Base
	if (Type == TRAVEL_Relative || Type == TRAVEL_Partial) {
		check(Base);
		for (INT i = 0; i < Base->Op.Num(); i++) {
			if (appStricmp(*Base->Op(i), TEXT("PUSH"))  != 0
			 && appStricmp(*Base->Op(i), TEXT("POP"))   != 0
			 && appStricmp(*Base->Op(i), TEXT("PEER"))  != 0
			 && appStricmp(*Base->Op(i), TEXT("LOAD"))  != 0
			 && appStricmp(*Base->Op(i), TEXT("QUIET")) != 0)
			{
				new(Op) FString(Base->Op(i));
			}
		}
	}

	// Skip leading spaces
	while (*Str == ' ')
		Str++;

	// Split off options (?) and portal (#)
	TCHAR* OptionStart = appStrchr(Str, '?');
	TCHAR* HashStart   = appStrchr(Str, '#');
	if (OptionStart == NULL || (HashStart != NULL && HashStart <= OptionStart))
		OptionStart = HashStart;

	if (OptionStart != NULL) {
		TCHAR Delim = *OptionStart;
		*OptionStart = 0;
		TCHAR* Token = OptionStart + 1;
		TCHAR  NextDelim = 0;

		do {
			TCHAR* NextQ = appStrchr(Token, '?');
			TCHAR* NextH = appStrchr(Token, '#');
			TCHAR* Next  = NextQ;
			if (Next == NULL || (NextH != NULL && NextH <= Next))
				Next = NextH;

			NextDelim = 0;
			if (Next != NULL) {
				NextDelim = *Next;
				*Next++ = 0;
			}

			// Space in option/portal token invalidates the URL
			if (appStrchr(Token, ' ') != NULL) {
				*this = FURL(NULL);
				Valid = 0;
				return;
			}

			if (Delim == '?')
				AddOption(Token);
			else
				Portal = Token;

			Delim = NextDelim;
			Token = Next;
		} while (Token != NULL);
	}

	// Parse URL structure
	UBOOL bMapChange = 0;
	UBOOL bHasMap    = 0;

	INT StrLen = appStrlen(Str);
	if (StrLen >= 3 && Str[1] == ':') {
		// Drive letter path (e.g., "C:\Maps\MyMap.rsm")
		Protocol = DefaultProtocol;
		Host     = DefaultHost;
		Map      = Str;
		Portal   = DefaultPortal;
		Str      = NULL;
		bMapChange = 1;
		bHasMap    = 1;
		Host       = TEXT("");
	} else {
		// Check for protocol (colon with >1 char before it, no dot before colon)
		if (appStrchr(Str, ':') != NULL) {
			TCHAR* Colon = appStrchr(Str, ':');
			if (Str + 1 < Colon) {
				TCHAR* Dot = appStrchr(Str, '.');
				if (Dot == NULL || Dot > Colon) {
					*Colon = 0;
					Protocol = Str;
					Str = Colon + 1;
				}
			}
		}

		// Check for authority (//)
		if (*Str == '/') {
			if (Str[1] != '/') {
				// Single / without // is invalid
				*this = FURL(NULL);
				Valid = 0;
				return;
			}
			Str += 2;
			bMapChange = 1;
			Host = TEXT("");
		}

		// Check for host (dot in remaining, not a map/save extension)
		TCHAR* Dot = appStrchr(Str, '.');
		if (Dot != NULL && Dot > Str) {
			UBOOL bIsMapExt = 0;
			if (appStrnicmp(Dot + 1, *DefaultMapExt, DefaultMapExt.Len()) == 0) {
				TCHAR After = Dot[DefaultMapExt.Len() + 1];
				if (!((After >= 'a' && After <= 'z') || (After >= 'A' && After <= 'Z') || (After >= '0' && After <= '9')))
					bIsMapExt = 1;
			}
			if (!bIsMapExt && appStrnicmp(Dot + 1, *DefaultSaveExt, DefaultSaveExt.Len()) == 0) {
				TCHAR After = Dot[DefaultSaveExt.Len() + 1];
				if (!((After >= 'a' && After <= 'z') || (After >= 'A' && After <= 'Z') || (After >= '0' && After <= '9')))
					bIsMapExt = 1;
			}

			if (!bIsMapExt) {
				// It's a host — extract host:port/path
				TCHAR* HostStr = Str;
				TCHAR* Slash = appStrchr(Str, '/');
				if (Slash != NULL) {
					*Slash = 0;
					Str = Slash + 1;
				} else {
					Str = NULL;
				}

				TCHAR* PortSep = appStrchr(HostStr, ':');
				if (PortSep != NULL) {
					*PortSep = 0;
					Port = appAtoi(PortSep + 1);
				}

				Host = HostStr;
				if (appStricmp(*Protocol, *DefaultProtocol) == 0)
					Map = DefaultMap;
				else
					Map = TEXT("");
				bMapChange = 1;
			}
		}
	}

	// TRAVEL_Absolute: forward persistent options from Base
	if (Type == TRAVEL_Absolute && Base != NULL && IsInternal()) {
		for (INT i = 0; i < Base->Op.Num(); i++) {
			if (appStrnicmp(*Base->Op(i), TEXT("Name="), 5) == 0
			 || appStrnicmp(*Base->Op(i), TEXT("Team="), 5) == 0
			 || appStrnicmp(*Base->Op(i), TEXT("Class="), 6) == 0
			 || appStrnicmp(*Base->Op(i), TEXT("Skin="), 5) == 0
			 || appStrnicmp(*Base->Op(i), TEXT("Face="), 5) == 0
			 || appStrnicmp(*Base->Op(i), TEXT("Voice="), 6) == 0
			 || appStrnicmp(*Base->Op(i), TEXT("OverrideClass="), 14) == 0)
			{
				TCHAR Match[256];
				const TCHAR* Eq = appStrchr(*Base->Op(i), '=');
				if (Eq == NULL)
					appStrcpy(Match, *Base->Op(i));
				else
					appStrncpy(Match, *Base->Op(i), (INT)(Eq - *Base->Op(i)) + 1);

				if (appStrcmp(GetOption(Match, TEXT("")), TEXT("")) == 0) {
					debugf(TEXT("URL: Carrying over <%s>"), *Base->Op(i));
					new(Op) FString(Base->Op(i));
				}
			}
		}
	}

	// Parse map from remaining string
	if (Str != NULL && *Str != 0) {
		if (IsInternal()) {
			bHasMap = 1;
			TCHAR* Slash = appStrchr(Str, '/');
			if (Slash != NULL) {
				*Slash = 0;
				TCHAR* Slash2 = appStrchr(Slash + 1, '/');
				if (Slash2 != NULL) {
					*Slash2 = 0;
					if (Slash2[1] != 0) {
						*this = FURL(NULL);
						Valid = 0;
						return;
					}
				}
				Portal = Slash + 1;
			}
		}
		Map = Str;
	}

	// Validate: no spaces in Protocol/Host/Portal, and something meaningful was parsed
	if (appStrchr(*Protocol, ' ') || appStrchr(*Host, ' ') || appStrchr(*Portal, ' ')
	 || (!bMapChange && !bHasMap && Op.Num() == 0))
	{
		*this = FURL(NULL);
		Valid = 0;
	}
}

// ??0FURL@@QAE@PBG@Z
// ??0FURL@@QAE@PBG@Z — Ghidra at 0x171950.
// Constructs a URL with defaults, optionally using the provided string as Map.
FURL::FURL(const TCHAR* Filename) {
	Protocol = DefaultProtocol;
	Host     = DefaultHost;
	Port     = DefaultPort;
	Map      = Filename ? FString(Filename) : DefaultMap;
	Portal   = DefaultPortal;
	Valid    = 1;
}

// ??0FWaveModInfo@@QAE@XZ
FWaveModInfo::FWaveModInfo() : SampleLoopsNum(0), NoiseGate(0) {}

// ?findEndAnchor@FSortedPathList@@QAEPAVANavigationPoint@@PAVAPawn@@PAVAActor@@VFVector@@H@Z
ANavigationPoint * FSortedPathList::findEndAnchor(APawn * p0, AActor * p1, FVector p2, int p3) { return NULL; }

// ?findStartAnchor@FSortedPathList@@QAEPAVANavigationPoint@@PAVAPawn@@@Z
ANavigationPoint * FSortedPathList::findStartAnchor(APawn * p0) { return NULL; }

// ?GetCurrent@FMatineeTools@@QAEPAVASceneManager@@XZ
ASceneManager * FMatineeTools::GetCurrent() { return NULL; }

// ?SetCurrent@FMatineeTools@@QAEPAVASceneManager@@PAVUEngine@@PAVULevel@@PAV2@@Z
ASceneManager * FMatineeTools::SetCurrent(UEngine * p0, ULevel * p1, ASceneManager * p2) { return NULL; }

// ?SetCurrent@FMatineeTools@@QAEPAVASceneManager@@PAVUEngine@@PAVULevel@@VFString@@@Z
ASceneManager * FMatineeTools::SetCurrent(UEngine * p0, ULevel * p1, FString p2) { return NULL; }

// ??4ECLipSynchData@@QAEAAV0@ABV0@@Z
ECLipSynchData & ECLipSynchData::operator=(ECLipSynchData const & Other) {
	appMemcpy(this, &Other, 24); // 6 dwords, shared with FCanvasVertex and FStaticMeshVertex
	return *this;
}

// ??4FCollisionHash@@QAEAAV0@ABV0@@Z
FCollisionHash & FCollisionHash::operator=(FCollisionHash const & p0) { static FCollisionHash dummy; return dummy; }

// ??4FCollisionOctree@@QAEAAV0@ABV0@@Z
FCollisionOctree & FCollisionOctree::operator=(FCollisionOctree const & Other) {
	appMemcpy(Pad, Other.Pad, sizeof(Pad)); // 272 bytes, skip vtable at offset 0
	return *this;
}

// ??4FOctreeNode@@QAEAAV0@ABV0@@Z
FOctreeNode & FOctreeNode::operator=(FOctreeNode const & p0) { static FOctreeNode dummy; return dummy; }

// ??4FPathBuilder@@QAEAAV0@ABV0@@Z
FPathBuilder & FPathBuilder::operator=(FPathBuilder const & Other) { appMemcpy(this, &Other, 8); return *this; } // 2 dwords, shared with FStaticMeshUV

// ?Project@FSceneNode@@QAE?AVFPlane@@VFVector@@@Z
FPlane FSceneNode::Project(FVector p0) { return FPlane(); }

// ??4FPoly@@QAEAAV0@ABV0@@Z
FPoly & FPoly::operator=(FPoly const & Other) {
	appMemcpy(this, &Other, sizeof(FPoly));
	return *this;
}

// ?GetCurrent@FRebuildTools@@QAEPAVFRebuildOptions@@XZ
FRebuildOptions * FRebuildTools::GetCurrent() { return NULL; }

// ?GetFromName@FRebuildTools@@QAEPAVFRebuildOptions@@VFString@@@Z
FRebuildOptions * FRebuildTools::GetFromName(FString p0) { return NULL; }

// ?Save@FRebuildTools@@QAEPAVFRebuildOptions@@VFString@@@Z
FRebuildOptions * FRebuildTools::Save(FString p0) { return NULL; }

// ?Rotator@FRotatorF@@QAE?AVFRotator@@XZ
FRotator FRotatorF::Rotator() { return FRotator((INT)Pitch, (INT)Yaw, (INT)Roll); }

// ??4FRotatorF@@QAEAAV0@ABV0@@Z
FRotatorF & FRotatorF::operator=(FRotatorF const & p0) { Pitch=p0.Pitch; Yaw=p0.Yaw; Roll=p0.Roll; return *this; }

// ??DFRotatorF@@QBE?AV0@M@Z
FRotatorF FRotatorF::operator*(float p0) const { return FRotatorF(Pitch*p0, Yaw*p0, Roll*p0); }

// ??XFRotatorF@@QAE?AV0@M@Z
FRotatorF FRotatorF::operator*=(float p0) { Pitch*=p0; Yaw*=p0; Roll*=p0; return *this; }

// ??HFRotatorF@@QBE?AV0@V0@@Z
FRotatorF FRotatorF::operator+(FRotatorF p0) const { return FRotatorF(Pitch+p0.Pitch, Yaw+p0.Yaw, Roll+p0.Roll); }

// ??YFRotatorF@@QAE?AV0@V0@@Z
FRotatorF FRotatorF::operator+=(FRotatorF p0) { Pitch+=p0.Pitch; Yaw+=p0.Yaw; Roll+=p0.Roll; return *this; }

// ??GFRotatorF@@QBE?AV0@V0@@Z
FRotatorF FRotatorF::operator-(FRotatorF p0) const { return FRotatorF(Pitch-p0.Pitch, Yaw-p0.Yaw, Roll-p0.Roll); }

// ??ZFRotatorF@@QAE?AV0@V0@@Z
FRotatorF FRotatorF::operator-=(FRotatorF p0) { Pitch-=p0.Pitch; Yaw-=p0.Yaw; Roll-=p0.Roll; return *this; }

// ??4FStatGraph@@QAEAAV0@ABV0@@Z
FStatGraph & FStatGraph::operator=(FStatGraph const & p0) { static FStatGraph dummy; return dummy; }

// ?GetOrientationDesc@FMatineeTools@@QAE?AVFString@@H@Z
FString FMatineeTools::GetOrientationDesc(int p0) { return FString(); }

// ?String@FURL@@QBE?AVFString@@H@Z
// Ghidra at 0x1710c0. Serializes URL to string form.
FString FURL::String(int FullyQualified) const {
	FString Result;
	if (Protocol != DefaultProtocol || FullyQualified) {
		Result += Protocol;
		Result += TEXT(":");
		if (Host != DefaultHost)
			Result += TEXT("//");
	}
	if (Host != DefaultHost || Port != DefaultPort) {
		Result += Host;
		if (Port != DefaultPort) {
			Result += TEXT(":");
			Result += FString::Printf(TEXT("%i"), Port);
		}
		Result += TEXT("/");
	}
	if (Map.Len())
		Result += Map;
	for (INT i = 0; i < Op.Num(); i++) {
		Result += TEXT("?");
		Result += Op(i);
	}
	if (Portal.Len()) {
		Result += TEXT("#");
		Result += Portal;
	}
	return Result;
}

// ?GetTextureSize@FPoly@@QAE?AVFVector@@XZ
FVector FPoly::GetTextureSize()
{
	if( !Material )
		return FVector( 256.f, 256.f, 0.f );
	return FVector( (FLOAT)Material->MaterialVSize(), (FLOAT)Material->MaterialUSize(), 0.f );
}

// ?Vector@FRotatorF@@QAE?AVFVector@@XZ
FVector FRotatorF::Vector() { return FVector(); }

// ?Deproject@FSceneNode@@QAE?AVFVector@@VFPlane@@@Z
FVector FSceneNode::Deproject(FPlane p0) { return FVector(); }

// ??4FWaveModInfo@@QAEAAV0@ABV0@@Z
FWaveModInfo & FWaveModInfo::operator=(FWaveModInfo const & Other) { appMemcpy(this, &Other, 64); return *this; } // 16 dwords

// ?GetCurrentAction@FMatineeTools@@QAEPAVUMatAction@@XZ
UMatAction * FMatineeTools::GetCurrentAction() { return NULL; }

// ?GetNextAction@FMatineeTools@@QAEPAVUMatAction@@PAVASceneManager@@PAV2@@Z
UMatAction * FMatineeTools::GetNextAction(ASceneManager * p0, UMatAction * p1) { return NULL; }

// ?GetNextMovementAction@FMatineeTools@@QAEPAVUMatAction@@PAVASceneManager@@PAV2@@Z
UMatAction * FMatineeTools::GetNextMovementAction(ASceneManager * p0, UMatAction * p1) { return NULL; }

// ?GetPrevAction@FMatineeTools@@QAEPAVUMatAction@@PAVASceneManager@@PAV2@@Z
UMatAction * FMatineeTools::GetPrevAction(ASceneManager * p0, UMatAction * p1) { return NULL; }

// ?SetCurrentAction@FMatineeTools@@QAEPAVUMatAction@@PAV2@@Z
UMatAction * FMatineeTools::SetCurrentAction(UMatAction * p0) { return NULL; }

// ?GetCurrentSubAction@FMatineeTools@@QAEPAVUMatSubAction@@XZ
UMatSubAction * FMatineeTools::GetCurrentSubAction() { return NULL; }

// ?SetCurrentSubAction@FMatineeTools@@QAEPAVUMatSubAction@@PAV2@@Z
UMatSubAction * FMatineeTools::SetCurrentSubAction(UMatSubAction * p0) { return NULL; }

// ?Area@FPoly@@QAEMXZ
float FPoly::Area() {
	FLOAT TotalArea = 0.f;
	FVector Side1 = Vertex[1] - Vertex[0];
	for( INT i=2; i<NumVertices; i++ ) {
		FVector Side2 = Vertex[i] - Vertex[0];
		FLOAT TriArea = (Side1 ^ Side2).Size();
		TotalArea += TriArea;
		Side1 = Side2;
	}
	return TotalArea;
}

// ?GetActionIdx@FMatineeTools@@QAEHPAVASceneManager@@PAVUMatAction@@@Z
int FMatineeTools::GetActionIdx(ASceneManager * p0, UMatAction * p1) { return 0; }

// ?GetPathStyle@FMatineeTools@@QAEHPAVUMatAction@@@Z
int FMatineeTools::GetPathStyle(UMatAction * p0) { return 0; }

// ?GetSubActionIdx@FMatineeTools@@QAEHPAVUMatSubAction@@@Z
int FMatineeTools::GetSubActionIdx(UMatSubAction * p0) { return 0; }

// ?buildPaths@FPathBuilder@@QAEHPAVULevel@@@Z
int FPathBuilder::buildPaths(ULevel * p0) { return 0; }

// ?removePaths@FPathBuilder@@QAEHPAVULevel@@@Z
int FPathBuilder::removePaths(ULevel * p0) { return 0; }

// ?CalcNormal@FPoly@@QAEHH@Z
int FPoly::CalcNormal(int bSilent) {
	Normal = FVector(0,0,0);
	for( INT i=2; i<NumVertices; i++ )
		Normal += (Vertex[i-1] - Vertex[0]) ^ (Vertex[i] - Vertex[0]);
	if( Normal.SizeSquared() < 0.0001f ) {
		return 1;
	}
	Normal.Normalize();
	return 0;
}

// ?DoesLineIntersect@FPoly@@QAEHVFVector@@0PAV2@@Z
// ?DoesLineIntersect@FPoly@@QAEHVFVector@@0PAV2@@Z — Ghidra at 0x9E760.
// Tests if a line segment intersects this polygon. Optionally returns the hit point.
int FPoly::DoesLineIntersect(FVector Start, FVector End, FVector * Intersection) {
	FLOAT d1 = (Start - Vertex[0]) | Normal;
	FLOAT d2 = (End   - Vertex[0]) | Normal;

	// Check that the line straddles the polygon's plane.
	if( (d1 >= 0.f || d2 >= 0.f) && (d1 <= 0.f || d2 <= 0.f) )
	{
		FVector Hit = FLinePlaneIntersection( Start, End, Vertex[0], Normal );
		if( Intersection )
			*Intersection = Hit;

		// Only count as intersection if hit point is not at an endpoint.
		if( !(Hit == Start) && !(Hit == End) )
			return OnPoly( Hit );
	}
	return 0;
}

// ?Faces@FPoly@@QBEHABV1@@Z
int FPoly::Faces(FPoly const & Other) const {
	if( IsCoplanar(Other) )
		return 0;
	for( INT i=0; i<Other.NumVertices; i++ ) {
		FLOAT d = (Other.Vertex[i] - Base) | Normal;
		if( d < 0.f ) {
			for( INT j=0; j<NumVertices; j++ ) {
				FLOAT d2 = (Vertex[j] - Other.Base) | Other.Normal;
				if( d2 > 0.f )
					return 1;
			}
			return 0;
		}
	}
	return 0;
}

// ?Finalize@FPoly@@QAEHH@Z — Ghidra at 0x9e190.
// Cleans up polygon: removes duplicate verts, validates, computes normal & texture vectors.
int FPoly::Finalize(int bSilent) {
	Fix();
	if( NumVertices < 3 )
	{
		debugf( NAME_Warning, TEXT("FPoly::Finalize: Not enough vertices (%i)"), NumVertices );
		if( bSilent )
			return -1;
		appErrorf( TEXT("FPoly::Finalize: Not enough vertices (%i)"), NumVertices );
	}
	if( Normal.IsZero() && NumVertices >= 3 )
	{
		if( CalcNormal(0) )
		{
			debugf( NAME_Warning, TEXT("FPoly::Finalize: Normalization failed, IsZero=%i, Size=%f"), Normal.IsZero(), Normal.Size() );
			if( bSilent )
				return -1;
			appErrorf( TEXT("FPoly::Finalize: Normalization failed, IsZero=%i, Size=%f"), Normal.IsZero(), Normal.Size() );
		}
	}
	if( TextureU.IsZero() && TextureV.IsZero() )
	{
		for( INT i=1; i<NumVertices; i++ )
		{
			TextureU = ((Vertex[0] - Vertex[i]) ^ Normal).SafeNormal();
			TextureV = (Normal ^ TextureU).SafeNormal();
			if( TextureU.SizeSquared() != 0.f && TextureV.SizeSquared() != 0.f )
				return 0;
		}
	}
	return 0;
}

// ?Fix@FPoly@@QAEHXZ
int FPoly::Fix()
{
	INT j = 0;
	INT prev = NumVertices - 1;
	for( INT i = 0; i < NumVertices; i++ )
	{
		if( !FPointsAreSame( Vertex[i], Vertex[prev] ) )
		{
			if( j != i )
				Vertex[j] = Vertex[i];
			prev = j;
			j++;
		}
		else
		{
			debugf( NAME_Warning, TEXT("FPoly::Fix: Deleted a duplicate vertex") );
		}
	}
	if( j < 3 )
		j = 0;
	NumVertices = j;
	return j;
}

// ?IsBackfaced@FPoly@@QBEHABVFVector@@@Z
int FPoly::IsBackfaced(FVector const & Point) const {
	return ((Point - Base) | Normal) < 0.f;
}

// ?IsCoplanar@FPoly@@QBEHABV1@@Z
int FPoly::IsCoplanar(FPoly const & Other) const {
	FLOAT d = (Base - Other.Base) | Normal;
	if( d < 0.f ) d = -d;
	if( d < 0.01f ) {
		FLOAT dot = Other.Normal | Normal;
		if( dot < 0.f ) dot = -dot;
		if( dot > 0.9999f )
			return 1;
	}
	return 0;
}

// ?OnPlane@FPoly@@QAEHVFVector@@@Z
int FPoly::OnPlane(FVector Point) {
	FLOAT d = (Point - Vertex[0]) | Normal;
	return (d > -0.1f && d < 0.1f) ? 1 : 0;
}

// ?OnPoly@FPoly@@QAEHVFVector@@@Z
// ?OnPoly@FPoly@@QAEHVFVector@@@Z — Ghidra at 0x9DD10.
// Returns 1 if Point lies inside the polygon, 0 otherwise.
int FPoly::OnPoly(FVector Point) {
	for( INT i=0; i<NumVertices; i++ )
	{
		INT j = i - 1;
		if( j < 0 ) j = NumVertices - 1;
		FVector Side = Vertex[i] - Vertex[j];
		FVector SideNormal = Side ^ Normal;
		SideNormal.Normalize();
		if( ((Point - Vertex[i]) | SideNormal) > 0.1f )
			return 0;
	}
	return 1;
}

// ?Split@FPoly@@QAEHABVFVector@@0H@Z
int FPoly::Split(FVector const & p0, FVector const & p1, int p2) { return 0; }

// ?SplitPrecise@FPoly@@QAEHABVFVector@@0H@Z
int FPoly::SplitPrecise(FVector const & p0, FVector const & p1, int p2) { return 0; }

// ?SplitWithNode@FPoly@@QBEHPBVUModel@@HPAV1@1H@Z
int FPoly::SplitWithNode(UModel const * p0, int p1, FPoly * p2, FPoly * p3, int p4) const { return 0; }

// ?SplitWithPlane@FPoly@@QBEHABVFVector@@0PAV1@1H@Z
int FPoly::SplitWithPlane(FVector const & p0, FVector const & p1, FPoly * p2, FPoly * p3, int p4) const { return 0; }

// ?SplitWithPlaneFast@FPoly@@QBEHVFPlane@@PAV1@1@Z
int FPoly::SplitWithPlaneFast(FPlane p0, FPoly * p1, FPoly * p2) const { return 0; }

// ?SplitWithPlaneFastPrecise@FPoly@@QBEHVFPlane@@PAV1@1@Z
int FPoly::SplitWithPlaneFastPrecise(FPlane p0, FPoly * p1, FPoly * p2) const { return 0; }

// ??9FPoly@@QAEHV0@@Z — Ghidra at 0x8bce0.
int FPoly::operator!=(FPoly Other) {
	if( NumVertices != Other.NumVertices )
		return 1;
	for( INT i=0; i<NumVertices; i++ )
		if( Vertex[i] != Other.Vertex[i] )
			return 1;
	return 0;
}

// ??8FPoly@@QAEHV0@@Z — Ghidra at 0xb4b10.
int FPoly::operator==(FPoly Other) {
	if( NumVertices != Other.NumVertices )
		return 0;
	for( INT i=0; i<NumVertices; i++ )
		if( Vertex[i] != Other.Vertex[i] )
			return 0;
	return 1;
}

// ?GetIdxFromName@FRebuildTools@@QAEHVFString@@@Z
int FRebuildTools::GetIdxFromName(FString p0) { return 0; }

// ?Exec@FStatGraph@@QAEHPBGAAVFOutputDevice@@@Z
int FStatGraph::Exec(const TCHAR* p0, FOutputDevice & p1) { return 0; }

// ?HasOption@FURL@@QBEHPBG@Z
int FURL::HasOption(const TCHAR* Test) const {
	for( INT i=0; i<Op.Num(); i++ )
		if( appStricmp(*Op(i),Test)==0 )
			return 1;
	return 0;
}

// ?IsInternal@FURL@@QBEHXZ
int FURL::IsInternal() const {
	return Protocol == DefaultProtocol;
}

// ?IsLocalInternal@FURL@@QBEHXZ
int FURL::IsLocalInternal() const {
	return IsInternal() && Host.Len()==0;
}

// ??8FURL@@QBEHABV0@@Z
int FURL::operator==(FURL const & Other) const {
	if( Protocol!=Other.Protocol )
		return 0;
	if( Host!=Other.Host )
		return 0;
	if( Map!=Other.Map )
		return 0;
	if( Port!=Other.Port )
		return 0;
	if( Op.Num()!=Other.Op.Num() )
		return 0;
	for( INT i=0; i<Op.Num(); i++ )
		if( Op(i)!=Other.Op(i) )
			return 0;
	return 1;
}

// ?ReadWaveInfo@FWaveModInfo@@QAEHAAV?$TArray@E@@@Z
INT FWaveModInfo::ReadWaveInfo(TArray<BYTE>& WavData) {
	guard(FWaveModInfo::ReadWaveInfo);

	BYTE* Start = &WavData(0);
	INT Len = WavData.Num();
	WaveDataEnd = Start + Len;

	// Check RIFF/WAVE header
	if( *(DWORD*)(Start + 8) != 0x45564157 ) // 'WAVE'
		return 0;
	pMasterSize = (DWORD*)(Start + 4);

	BYTE* Ptr;
	DWORD ChunkSize;

	// Scan for "fmt " chunk
	for( Ptr = Start + 12; Ptr + 8 < WaveDataEnd && *(DWORD*)Ptr != 0x20746d66; Ptr += Pad16Bit(*(DWORD*)(Ptr+4)) + 8 ) {}
	if( *(DWORD*)Ptr != 0x20746d66 ) // 'fmt '
		return 0;

	BYTE* FmtData = Ptr + 8; // actual format data past chunk header
	pBitsPerSample  = (_WORD*)(Ptr + 0x16);
	pSamplesPerSec  = (DWORD*)(Ptr + 12);
	pAvgBytesPerSec = (DWORD*)(Ptr + 16);
	pBlockAlign     = (_WORD*)(Ptr + 20);
	pChannels       = (_WORD*)(Ptr + 10);

	// Scan for "data" chunk
	for( Ptr = Start + 12; Ptr + 8 < WaveDataEnd && *(DWORD*)Ptr != 0x61746164; Ptr += Pad16Bit(*(DWORD*)(Ptr+4)) + 8 ) {}
	if( *(DWORD*)Ptr != 0x61746164 ) // 'data'
		return 0;

	SampleDataStart = Ptr + 8;
	pWaveDataSize   = (DWORD*)(Ptr + 4);
	SampleDataSize  = *(DWORD*)(Ptr + 4);
	OldBitsPerSample = (DWORD)*(_WORD*)(FmtData + 0x0E);
	SampleDataEnd   = SampleDataStart + SampleDataSize;
	NewDataSize     = SampleDataSize;

	// Scan for optional "smpl" chunk
	for( Ptr = Start + 12; Ptr + 8 < WaveDataEnd && *(DWORD*)Ptr != 0x6C706D73; Ptr += Pad16Bit(*(DWORD*)(Ptr+4)) + 8 ) {}
	if( Ptr + 4 < WaveDataEnd && *(DWORD*)Ptr == 0x6C706D73 ) // 'smpl'
	{
		BYTE SmplHeader[36];
		appMemcpy(SmplHeader, Ptr + 8, 36);
		SampleLoopsNum = *(INT*)(SmplHeader + 28);
		pSampleLoop    = (FSampleLoop*)(Ptr + 8 + 36);
	}

	return 1;
	unguard;
}

// ?UpdateWaveData@FWaveModInfo@@QAEHAAV?$TArray@E@@@Z
int FWaveModInfo::UpdateWaveData(TArray<BYTE> & p0) { return 0; }

// ?StaticExit@FURL@@SAXXZ
void FURL::StaticExit() {
	DefaultProtocol          = TEXT("");
	DefaultProtocolDescription = TEXT("");
	DefaultName              = TEXT("");
	DefaultMap               = TEXT("");
	DefaultLocalMap          = TEXT("");
	DefaultHost              = TEXT("");
	DefaultPortal            = TEXT("");
	DefaultMapExt            = TEXT("");
	DefaultSaveExt           = TEXT("");
}

// ?StaticInit@FURL@@SAXXZ
void FURL::StaticInit() {
	DefaultProtocol            = GConfig->GetStr( TEXT("URL"), TEXT("Protocol"), NULL );
	DefaultProtocolDescription = GConfig->GetStr( TEXT("URL"), TEXT("ProtocolDescription"), NULL );
	DefaultName                = GConfig->GetStr( TEXT("URL"), TEXT("Name"), NULL );
	if( DefaultName == TEXT("UbiPlayer") )
		DefaultName = appUserName();
	DefaultMap = TEXT("Entry.");
	DefaultMap += GConfig->GetStr( TEXT("URL"), TEXT("MapExt"), NULL );
	DefaultLocalMap = TEXT("Entry.");
	DefaultLocalMap += GConfig->GetStr( TEXT("URL"), TEXT("MapExt"), NULL );
	DefaultHost     = GConfig->GetStr( TEXT("URL"), TEXT("Host"), NULL );
	DefaultPortal   = GConfig->GetStr( TEXT("URL"), TEXT("Portal"), NULL );
	DefaultMapExt   = GConfig->GetStr( TEXT("URL"), TEXT("MapExt"), NULL );
	DefaultSaveExt  = GConfig->GetStr( TEXT("URL"), TEXT("SaveExt"), NULL );
	DefaultPort     = appAtoi( GConfig->GetStr( TEXT("URL"), TEXT("Port"), NULL ) );
}

// ?Pad16Bit@FWaveModInfo@@QAEKK@Z
DWORD FWaveModInfo::Pad16Bit(DWORD InVal) { return (InVal + 1) & ~1; }

// ?GetOption@FURL@@QBEPBGPBG0@Z
const TCHAR* FURL::GetOption(const TCHAR* Match, const TCHAR* Default) const {
	for( INT i=0; i<Op.Num(); i++ )
		if( appStrnicmp(*Op(i),Match,appStrlen(Match))==0 )
			return *Op(i) + appStrlen(Match);
	return Default;
}

// ??1FCollisionHash@@UAE@XZ
FCollisionHash::~FCollisionHash() {}

// ??1FCollisionOctree@@UAE@XZ
FCollisionOctree::~FCollisionOctree() {}

// ??1FLevelSceneNode@@UAE@XZ
FLevelSceneNode::~FLevelSceneNode() {}

// ??1FMatineeTools@@UAE@XZ
FMatineeTools::~FMatineeTools() {}

// ??1FSceneNode@@UAE@XZ
FSceneNode::~FSceneNode() {}

// ?GetActorSceneNode@FSceneNode@@UAEPAVFActorSceneNode@@XZ
FActorSceneNode * FSceneNode::GetActorSceneNode() { return NULL; }

// ?GetCameraSceneNode@FSceneNode@@UAEPAVFCameraSceneNode@@XZ
FCameraSceneNode * FSceneNode::GetCameraSceneNode() { return NULL; }

// ?GetLevelSceneNode@FSceneNode@@UAEPAVFLevelSceneNode@@XZ
FLevelSceneNode * FSceneNode::GetLevelSceneNode() { return NULL; }

// ?MeshToWorld@UMeshInstance@@UAE?AVFMatrix@@XZ
FMatrix UMeshInstance::MeshToWorld() { return FMatrix(); }

// ?GetMirrorSceneNode@FSceneNode@@UAEPAVFMirrorSceneNode@@XZ
FMirrorSceneNode * FSceneNode::GetMirrorSceneNode() { return NULL; }

// ?GetSkySceneNode@FSceneNode@@UAEPAVFSkySceneNode@@XZ
FSkySceneNode * FSceneNode::GetSkySceneNode() { return NULL; }

// ?GetWarpZoneSceneNode@FSceneNode@@UAEPAVFWarpZoneSceneNode@@XZ
FWarpZoneSceneNode * FSceneNode::GetWarpZoneSceneNode() { return NULL; }

// ?ActorEncroachmentCheck@FCollisionHash@@UAEPAUFCheckResult@@AAVFMemStack@@PAVAActor@@VFVector@@VFRotator@@KK@Z
FCheckResult * FCollisionHash::ActorEncroachmentCheck(FMemStack & p0, AActor * p1, FVector p2, FRotator p3, DWORD p4, DWORD p5) { return NULL; }

// ?ActorLineCheck@FCollisionHash@@UAEPAUFCheckResult@@AAVFMemStack@@VFVector@@11KKPAVAActor@@@Z
FCheckResult * FCollisionHash::ActorLineCheck(FMemStack & p0, FVector p1, FVector p2, FVector p3, DWORD p4, DWORD p5, AActor * p6) { return NULL; }

// ?ActorOverlapCheck@FCollisionHash@@UAEPAUFCheckResult@@AAVFMemStack@@PAVAActor@@PAVFBox@@H@Z
FCheckResult * FCollisionHash::ActorOverlapCheck(FMemStack & p0, AActor * p1, FBox * p2, int p3) { return NULL; }

// ?ActorPointCheck@FCollisionHash@@UAEPAUFCheckResult@@AAVFMemStack@@VFVector@@1KKHPAVAActor@@@Z
FCheckResult * FCollisionHash::ActorPointCheck(FMemStack & p0, FVector p1, FVector p2, DWORD p3, DWORD p4, int p5, AActor * p6) { return NULL; }

// ?ActorRadiusCheck@FCollisionHash@@UAEPAUFCheckResult@@AAVFMemStack@@VFVector@@MK@Z
FCheckResult * FCollisionHash::ActorRadiusCheck(FMemStack & p0, FVector p1, float p2, DWORD p3) { return NULL; }

// ?ActorEncroachmentCheck@FCollisionOctree@@UAEPAUFCheckResult@@AAVFMemStack@@PAVAActor@@VFVector@@VFRotator@@KK@Z
FCheckResult * FCollisionOctree::ActorEncroachmentCheck(FMemStack & p0, AActor * p1, FVector p2, FRotator p3, DWORD p4, DWORD p5) { return NULL; }

// ?ActorLineCheck@FCollisionOctree@@UAEPAUFCheckResult@@AAVFMemStack@@VFVector@@11KKPAVAActor@@@Z
FCheckResult * FCollisionOctree::ActorLineCheck(FMemStack & p0, FVector p1, FVector p2, FVector p3, DWORD p4, DWORD p5, AActor * p6) { return NULL; }

// ?ActorOverlapCheck@FCollisionOctree@@UAEPAUFCheckResult@@AAVFMemStack@@PAVAActor@@PAVFBox@@H@Z
FCheckResult * FCollisionOctree::ActorOverlapCheck(FMemStack & p0, AActor * p1, FBox * p2, int p3) { return NULL; }

// ?ActorPointCheck@FCollisionOctree@@UAEPAUFCheckResult@@AAVFMemStack@@VFVector@@1KKHPAVAActor@@@Z
FCheckResult * FCollisionOctree::ActorPointCheck(FMemStack & p0, FVector p1, FVector p2, DWORD p3, DWORD p4, int p5, AActor * p6) { return NULL; }

// ?ActorRadiusCheck@FCollisionOctree@@UAEPAUFCheckResult@@AAVFMemStack@@VFVector@@MK@Z
FCheckResult * FCollisionOctree::ActorRadiusCheck(FMemStack & p0, FVector p1, float p2, DWORD p3) { return NULL; }

// ?AddActor@FCollisionHash@@UAEXPAVAActor@@@Z
void FCollisionHash::AddActor(AActor * p0) {}

// ?CheckActorLocations@FCollisionHash@@UAEXPAVULevel@@@Z
void FCollisionHash::CheckActorLocations(ULevel * p0) {}

// ?CheckActorNotReferenced@FCollisionHash@@UAEXPAVAActor@@@Z
void FCollisionHash::CheckActorNotReferenced(AActor * p0) {}

// ?CheckIsEmpty@FCollisionHash@@UAEXXZ
void FCollisionHash::CheckIsEmpty() {}

// ?RemoveActor@FCollisionHash@@UAEXPAVAActor@@@Z
void FCollisionHash::RemoveActor(AActor * p0) {}

// ?Tick@FCollisionHash@@UAEXXZ
void FCollisionHash::Tick() {}

// ?AddActor@FCollisionOctree@@UAEXPAVAActor@@@Z
void FCollisionOctree::AddActor(AActor * p0) {}

// ?CheckActorLocations@FCollisionOctree@@UAEXPAVULevel@@@Z
void FCollisionOctree::CheckActorLocations(ULevel * p0) {}

// ?CheckActorNotReferenced@FCollisionOctree@@UAEXPAVAActor@@@Z
void FCollisionOctree::CheckActorNotReferenced(AActor * p0) {}

// ?CheckIsEmpty@FCollisionOctree@@UAEXXZ
void FCollisionOctree::CheckIsEmpty() {}

// ?RemoveActor@FCollisionOctree@@UAEXPAVAActor@@@Z
void FCollisionOctree::RemoveActor(AActor * p0) {}

// ?Tick@FCollisionOctree@@UAEXXZ
void FCollisionOctree::Tick() {}

// ?MeshBuildBounds@UMeshInstance@@UAEXXZ
void UMeshInstance::MeshBuildBounds() {}

// ?m_vStartLipsynch@ECLipSynchData@@QAEXXZ
void ECLipSynchData::m_vStartLipsynch() {}

// ?m_vStopLipsynch@ECLipSynchData@@QAEXXZ
void ECLipSynchData::m_vStopLipsynch() {}

// ?m_vUpdateBonesCompressed@ECLipSynchData@@QAEXH@Z
void ECLipSynchData::m_vUpdateBonesCompressed(int p0) {}

// ?m_vUpdateBonesCompressed_BoneView@ECLipSynchData@@QAEXH@Z
void ECLipSynchData::m_vUpdateBonesCompressed_BoneView(int p0) {}

// ?m_vUpdateBonesCompressed_PhonemsSeq@ECLipSynchData@@QAEXH@Z
void ECLipSynchData::m_vUpdateBonesCompressed_PhonemsSeq(int p0) {}

// ?m_vUpdateLipSynch@ECLipSynchData@@QAEXM@Z
void ECLipSynchData::m_vUpdateLipSynch(float p0) {}

// ?GetActorExtent@FCollisionHash@@QAEXPAVAActor@@AAH11111@Z
void FCollisionHash::GetActorExtent(AActor * p0, int & p1, int & p2, int & p3, int & p4, int & p5, int & p6) {}

// ?GetHashIndices@FCollisionHash@@QAEXVFVector@@AAH11@Z
void FCollisionHash::GetHashIndices(FVector p0, int & p1, int & p2, int & p3) {}

// ?GetSamples@FMatineeTools@@QAEXPAVASceneManager@@PAVUMatAction@@PAV?$TArray@VFVector@@@@@Z
void FMatineeTools::GetSamples(ASceneManager * p0, UMatAction * p1, TArray<FVector> * p2) {}

// ?Init@FMatineeTools@@QAEXXZ
void FMatineeTools::Init() {}

// ?ActorEncroachmentCheck@FOctreeNode@@QAEXPAVFCollisionOctree@@PBVFPlane@@@Z
void FOctreeNode::ActorEncroachmentCheck(FCollisionOctree * p0, FPlane const * p1) {}

// ?ActorNonZeroExtentLineCheck@FOctreeNode@@QAEXPAVFCollisionOctree@@PBVFPlane@@@Z
void FOctreeNode::ActorNonZeroExtentLineCheck(FCollisionOctree * p0, FPlane const * p1) {}

// ?ActorOverlapCheck@FOctreeNode@@QAEXPAVFCollisionOctree@@PBVFPlane@@@Z
void FOctreeNode::ActorOverlapCheck(FCollisionOctree * p0, FPlane const * p1) {}

// ?ActorPointCheck@FOctreeNode@@QAEXPAVFCollisionOctree@@PBVFPlane@@PAVAActor@@@Z
void FOctreeNode::ActorPointCheck(FCollisionOctree * p0, FPlane const * p1, AActor * p2) {}

// ?ActorRadiusCheck@FOctreeNode@@QAEXPAVFCollisionOctree@@PBVFPlane@@@Z
void FOctreeNode::ActorRadiusCheck(FCollisionOctree * p0, FPlane const * p1) {}

// ?ActorZeroExtentLineCheck@FOctreeNode@@QAEXPAVFCollisionOctree@@MMMMMMPBVFPlane@@@Z
void FOctreeNode::ActorZeroExtentLineCheck(FCollisionOctree * p0, float p1, float p2, float p3, float p4, float p5, float p6, FPlane const * p7) {}

// ?CheckActorNotReferenced@FOctreeNode@@QAEXPAVAActor@@@Z
void FOctreeNode::CheckActorNotReferenced(AActor * p0) {}

// ?CheckIsEmpty@FOctreeNode@@QAEXXZ
void FOctreeNode::CheckIsEmpty() {}

// ?Draw@FOctreeNode@@QAEXVFColor@@HPBVFPlane@@@Z
void FOctreeNode::Draw(FColor p0, int p1, FPlane const * p2) {}

// ?DrawFlaggedActors@FOctreeNode@@QAEXPAVFCollisionOctree@@PBVFPlane@@@Z
void FOctreeNode::DrawFlaggedActors(FCollisionOctree * p0, FPlane const * p1) {}

// ?FilterTest@FOctreeNode@@QAEXPAVFBox@@HPAV?$TArray@PAVFOctreeNode@@@@PBVFPlane@@@Z
void FOctreeNode::FilterTest(FBox * p0, int p1, TArray<FOctreeNode *> * p2, FPlane const * p3) {}

// ?MultiNodeFilter@FOctreeNode@@QAEXPAVAActor@@PAVFCollisionOctree@@PBVFPlane@@@Z
void FOctreeNode::MultiNodeFilter(AActor * p0, FCollisionOctree * p1, FPlane const * p2) {}

// ?RemoveAllActors@FOctreeNode@@QAEXPAVFCollisionOctree@@@Z
void FOctreeNode::RemoveAllActors(FCollisionOctree * p0) {}

// ?SingleNodeFilter@FOctreeNode@@QAEXPAVAActor@@PAVFCollisionOctree@@PBVFPlane@@@Z
void FOctreeNode::SingleNodeFilter(AActor * p0, FCollisionOctree * p1, FPlane const * p2) {}

// ?BuildActionSpotList@FPathBuilder@@QAEXPAVULevel@@@Z
void FPathBuilder::BuildActionSpotList(ULevel * p0) {}

// ?ReviewPaths@FPathBuilder@@QAEXPAVULevel@@@Z
void FPathBuilder::ReviewPaths(ULevel * p0) {}

// ?defineChangedPaths@FPathBuilder@@QAEXPAVULevel@@@Z
void FPathBuilder::defineChangedPaths(ULevel * p0) {}

// ?definePaths@FPathBuilder@@QAEXPAVULevel@@@Z
void FPathBuilder::definePaths(ULevel * p0) {}

// ?undefinePaths@FPathBuilder@@QAEXPAVULevel@@@Z
void FPathBuilder::undefinePaths(ULevel * p0) {}

// ?Init@FPoly@@QAEXXZ
void FPoly::Init() {
	Base     = FVector(0,0,0);
	Normal   = FVector(0,0,0);
	TextureU = FVector(0,0,0);
	TextureV = FVector(0,0,0);
	PolyFlags   = 0;
	Actor       = NULL;
	Material    = NULL;
	ItemName    = FName(NAME_None);
	NumVertices = 0;
	iLink       = INDEX_NONE;
	iBrushPoly  = INDEX_NONE;
	SavePolyIndex = INDEX_NONE;
	appMemzero(_RvsExtra, sizeof(_RvsExtra));
	// LightMapScale at _RvsExtra offset 52 (0x144 - 0x110) = 32.0f
	*(FLOAT*)&_RvsExtra[52] = 32.0f;
	// Sentinel values at known offsets within _RvsExtra
	*(INT*)&_RvsExtra[56] = INDEX_NONE;  // 0x148
	*(INT*)&_RvsExtra[60] = INDEX_NONE;  // 0x14C
	*(DWORD*)&_RvsExtra[68] = 0xFF808080; // 0x154
}

// ?InsertVertex@FPoly@@QAEXHVFVector@@@Z
// NOTE: Original uses temp TArray copy+insert+copyback. Simplified to in-place shift.
void FPoly::InsertVertex(int InPos, FVector InVtx)
{
	check(InPos <= NumVertices);
	for( INT i = NumVertices; i > InPos; i-- )
		Vertex[i] = Vertex[i - 1];
	Vertex[InPos] = InVtx;
	NumVertices++;
}

// ?Reverse@FPoly@@QAEXXZ
void FPoly::Reverse() {
	Normal *= -1.f;
	for( INT i=0; i<NumVertices/2; i++ ) {
		FVector Temp = Vertex[i];
		Vertex[i] = Vertex[NumVertices-1-i];
		Vertex[NumVertices-1-i] = Temp;
	}
}

// ?SplitInHalf@FPoly@@QAEXPAV1@@Z
// ?SplitInHalf@FPoly@@QAEXPAV1@@Z — Ghidra at 0x9C640.
// Splits a polygon in two halves along the vertex midpoint.
void FPoly::SplitInHalf(FPoly * OtherHalf) {
	INT Half = NumVertices / 2;
	if( NumVertices < 4 || NumVertices > 16 )
		appErrorf( TEXT("FPoly::SplitInHalf: Vertex count = %i"), NumVertices );

	// Copy full polygon structure to the other half.
	*OtherHalf = *this;

	// Adjust vertex counts: first half gets [0..Half], second half gets [Half..N-1, 0].
	OtherHalf->NumVertices = NumVertices - Half + 1;
	NumVertices = Half + 1;

	// Copy the right-side vertices into OtherHalf.
	for( INT i=0; i<OtherHalf->NumVertices-1; i++ )
		OtherHalf->Vertex[i] = Vertex[i + Half];

	// Close the second polygon by copying back the first vertex of the original.
	OtherHalf->Vertex[OtherHalf->NumVertices - 1] = Vertex[0];

	// Mark both halves as cut (PF_EdCut = 0x80000000).
	PolyFlags |= 0x80000000;
	OtherHalf->PolyFlags |= 0x80000000;
}

// ?Transform@FPoly@@QAEXABVFModelCoords@@ABVFVector@@1M@Z
// ?Transform@FPoly@@QAEXABVFModelCoords@@ABVFVector@@1M@Z — Ghidra at 0x9C8F0.
// Transforms all polygon data by the given coordinate system.
void FPoly::Transform(FModelCoords const & Coords, FVector const & PreSubtract, FVector const & PostAdd, float Orientation) {
	// Transform texture mapping vectors by the contravariant (vector) transform.
	TextureU = TextureU.TransformVectorBy( Coords.VectorXform );
	TextureV = TextureV.TransformVectorBy( Coords.VectorXform );

	// Transform base: subtract pivot, apply covariant transform, add destination.
	Base = (Base - PreSubtract).TransformVectorBy( Coords.PointXform ) + PostAdd;

	// Transform each vertex the same way.
	for( INT i=0; i<NumVertices; i++ )
		Vertex[i] = (Vertex[i] - PreSubtract).TransformVectorBy( Coords.PointXform ) + PostAdd;

	// If orientation is negative (mirroring), reverse the winding order.
	if( Orientation < 0.f )
	{
		for( INT i=0; i<NumVertices/2; i++ )
		{
			FVector Temp = Vertex[i];
			Vertex[i] = Vertex[(NumVertices-1) - i];
			Vertex[(NumVertices-1) - i] = Temp;
		}
	}

	// Re-compute the normal after transformation.
	Normal = Normal.TransformVectorBy( Coords.VectorXform ).SafeNormal();
}

// ?Delete@FRebuildTools@@QAEXVFString@@@Z
void FRebuildTools::Delete(FString p0) {}

// ?Init@FRebuildTools@@QAEXXZ
void FRebuildTools::Init() {}

// ?SetCurrent@FRebuildTools@@QAEXVFString@@@Z
void FRebuildTools::SetCurrent(FString p0) {}

// ?Shutdown@FRebuildTools@@QAEXXZ
void FRebuildTools::Shutdown() {}

// ?AddDataPoint@FStatGraph@@QAEXVFString@@MH@Z
void FStatGraph::AddDataPoint(FString p0, float p1, int p2) {}

// ?AddLine@FStatGraph@@QAEXVFString@@VFColor@@MM@Z
void FStatGraph::AddLine(FString p0, FColor p1, float p2, float p3) {}

// ?AddLineAutoRange@FStatGraph@@QAEXVFString@@VFColor@@@Z
void FStatGraph::AddLineAutoRange(FString p0, FColor p1) {}

// ?Render@FStatGraph@@QAEXPAVUViewport@@PAVFRenderInterface@@@Z
void FStatGraph::Render(UViewport * p0, FRenderInterface * p1) {}

// ?Reset@FStatGraph@@QAEXXZ
void FStatGraph::Reset() {}

// ?AddOption@FURL@@QAEXPBG@Z
void FURL::AddOption(const TCHAR* Str) {
	const TCHAR* Eq = appStrchr(Str,'=');
	INT PrefixLen = Eq ? (INT)(Eq - Str) + 1 : appStrlen(Str) + 1;
	INT i;
	for( i=0; i<Op.Num(); i++ )
		if( appStrnicmp(*Op(i),Str,PrefixLen)==0 )
			break;
	if( i==Op.Num() )
		new(Op)FString(Str);
	else
		Op(i) = Str;
}

// ?LoadURLConfig@FURL@@QAEXPBG0@Z
void FURL::LoadURLConfig(const TCHAR* Section, const TCHAR* Filename) {
	TCHAR Buffer[32000];
	GConfig->GetSection( Section, Buffer, ARRAY_COUNT(Buffer), Filename );
	const TCHAR* Ptr = Buffer;
	while( *Ptr ) {
		AddOption( Ptr );
		Ptr += appStrlen(Ptr) + 1;
	}
}

// ?SaveURLConfig@FURL@@QBEXPBG00@Z
void FURL::SaveURLConfig(const TCHAR* Section, const TCHAR* Key, const TCHAR* Filename) const {
	for( INT i=0; i<Op.Num(); i++ ) {
		TCHAR Temp[1024];
		appStrcpy( Temp, *Op(i) );
		TCHAR* Value = appStrchr( Temp, '=' );
		if( Value ) {
			*Value++ = 0;
			if( appStricmp(Temp, Key)==0 )
				GConfig->SetString( Section, Temp, Value, Filename );
		}
	}
}

// ?HalveData@FWaveModInfo@@QAEXXZ
void FWaveModInfo::HalveData() {}

// ?HalveReduce16to8@FWaveModInfo@@QAEXXZ
void FWaveModInfo::HalveReduce16to8() {}

// ?NoiseGateFilter@FWaveModInfo@@QAEXXZ
void FWaveModInfo::NoiseGateFilter() {}

// ?Reduce16to8@FWaveModInfo@@QAEXXZ
void FWaveModInfo::Reduce16to8() {}

// ?AVIStart@@YAXPBGPAVUEngine@@H@Z
void AVIStart(const TCHAR* p0, UEngine * p1, int p2) {}

// ?AVIStop@@YAXXZ
void AVIStop() {}

// ?AVITakeShot@@YAXPAVUEngine@@@Z
void AVITakeShot(UEngine * p0) {}

// ?DrawSprite@@YAXPAVAActor@@VFVector@@PAVUMaterial@@PAVFLevelSceneNode@@PAVFRenderInterface@@@Z
void DrawSprite(AActor * p0, FVector p1, UMaterial * p2, FLevelSceneNode * p3, FRenderInterface * p4) {}

// ?DrawSprite@@YAXMVFVector@@0PAVUMaterial@@VFPlane@@EPAVFCameraSceneNode@@PAVFRenderInterface@@MHH@Z
void DrawSprite(float p0, FVector p1, FVector p2, UMaterial * p3, FPlane p4, BYTE p5, FCameraSceneNode * p6, FRenderInterface * p7, float p8, int p9, int p10) {}

// ?KME2UPosition@@YAXPAVFVector@@QBM@Z
void KME2UPosition(FVector* Out, float const * const In) {
	Out->X = In[0] * 50.0f;
	Out->Y = In[1] * 50.0f;
	Out->Z = In[2] * 50.0f;
}

// ?KME2UVecCopy@@YAXPAVFVector@@QBM@Z
void KME2UVecCopy(FVector* Out, float const * const In) {
	Out->X = In[0];
	Out->Y = In[1];
	Out->Z = In[2];
}

// ?KTermGameKarma@@YAXXZ
void KTermGameKarma() {}

// ?KU2MEPosition@@YAXQAMVFVector@@@Z
void KU2MEPosition(float * const Out, FVector In) {
	Out[0] = In.X * 0.02f;
	Out[1] = In.Y * 0.02f;
	Out[2] = In.Z * 0.02f;
}

// ?KU2MEVecCopy@@YAXQAMVFVector@@@Z
void KU2MEVecCopy(float * const Out, FVector In) {
	Out[0] = In.X;
	Out[1] = In.Y;
	Out[2] = In.Z;
}

// ?KUpdateMassProps@@YAXPAVUKMeshProps@@@Z
void KUpdateMassProps(UKMeshProps * p0) {}

// ?KarmaTriListDataInit@@YAXPAU_KarmaTriListData@@@Z
void KarmaTriListDataInit(_KarmaTriListData * p0) {}

// =============================================================================
// UVertexStream class implementations.
// Ghidra: constructors at 0x2210 (base), 0x26280+ (derived).
// GetData/GetDataSize at 0x18b20/0x18b30+.
// =============================================================================
UVertexStreamBase::UVertexStreamBase(INT InElementSize, DWORD InFlags, DWORD InType)
: ElementSize(InElementSize), StreamFlags(InFlags), StreamType(InType) {}
void UVertexStreamBase::Serialize(FArchive& Ar) { URenderResource::Serialize(Ar); }
void UVertexStreamBase::SetPolyFlags(DWORD Flags) {
	DWORD OldFlags = StreamFlags;
	StreamFlags = Flags;
	if( OldFlags != Flags )
		Revision++;
}

// UVertexBuffer: ElementSize=0x2C (44 = sizeof FBspVertex), StreamType=4.
UVertexBuffer::UVertexBuffer()
: UVertexStreamBase(0x2C, 0, 4) {}
UVertexBuffer::UVertexBuffer(DWORD InFlags)
: UVertexStreamBase(0x2C, InFlags, 0) {}
void UVertexBuffer::Serialize(FArchive& Ar) { UVertexStreamBase::Serialize(Ar); }
void* UVertexBuffer::GetData() { return Data.GetData(); }
INT UVertexBuffer::GetDataSize() { return Data.Num() * 0x2C; }

// UVertexStreamCOLOR: ElementSize=4 (sizeof FColor), StreamType=2.
UVertexStreamCOLOR::UVertexStreamCOLOR()
: UVertexStreamBase(4, 0, 2) {}
UVertexStreamCOLOR::UVertexStreamCOLOR(DWORD InFlags)
: UVertexStreamBase(4, InFlags, 2) {}
void UVertexStreamCOLOR::Serialize(FArchive& Ar) { UVertexStreamBase::Serialize(Ar); }
void* UVertexStreamCOLOR::GetData() { return Data.GetData(); }
INT UVertexStreamCOLOR::GetDataSize() { return Data.Num() * 4; }

// UVertexStreamPosNormTex: ElementSize=0x28 (40), StreamType=5.
UVertexStreamPosNormTex::UVertexStreamPosNormTex()
: UVertexStreamBase(0x28, 0, 5) {}
UVertexStreamPosNormTex::UVertexStreamPosNormTex(DWORD InFlags)
: UVertexStreamBase(0x28, InFlags, 5) {}
void UVertexStreamPosNormTex::Serialize(FArchive& Ar) { UVertexStreamBase::Serialize(Ar); }
void* UVertexStreamPosNormTex::GetData() { return Data.GetData(); }
INT UVertexStreamPosNormTex::GetDataSize() { return Data.Num() * 0x28; }

// UVertexStreamUV: ElementSize=8 (2 floats), StreamType=3.
UVertexStreamUV::UVertexStreamUV()
: UVertexStreamBase(8, 0, 3) {}
UVertexStreamUV::UVertexStreamUV(DWORD InFlags)
: UVertexStreamBase(8, InFlags, 3) {}
void UVertexStreamUV::Serialize(FArchive& Ar) { UVertexStreamBase::Serialize(Ar); }
void* UVertexStreamUV::GetData() { return Data.GetData(); }
INT UVertexStreamUV::GetDataSize() { return Data.Num() * 8; }

// UVertexStreamVECTOR: ElementSize=0xC (12 = sizeof FVector), StreamType=1.
UVertexStreamVECTOR::UVertexStreamVECTOR()
: UVertexStreamBase(0xC, 0, 1) {}
UVertexStreamVECTOR::UVertexStreamVECTOR(DWORD InFlags)
: UVertexStreamBase(0xC, InFlags, 1) {}
void UVertexStreamVECTOR::Serialize(FArchive& Ar) { UVertexStreamBase::Serialize(Ar); }
void* UVertexStreamVECTOR::GetData() { return Data.GetData(); }
INT UVertexStreamVECTOR::GetDataSize() { return Data.Num() * 0xC; }

// =============================================================================
// FColor constructor from FPlane (out-of-line to avoid circular header deps).
// =============================================================================
FColor::FColor(const FPlane& P)
:	R((BYTE)Clamp(appFloor(P.X*255.f),0,255))
,	G((BYTE)Clamp(appFloor(P.Y*255.f),0,255))
,	B((BYTE)Clamp(appFloor(P.Z*255.f),0,255))
,	A((BYTE)Clamp(appFloor(P.W*255.f),0,255))
{}

// =============================================================================
// Explicit template instantiation for TArray<BYTE> and TLazyArray<BYTE>.
// The retail Engine.dll exports these symbols; explicit instantiation forces the
// compiler to emit out-of-line copies of all inline template members.
// =============================================================================
template class TArray<BYTE>;
template class TLazyArray<BYTE>;

// ============================================================================
// FSortedPathList
// ============================================================================
FSortedPathList::FSortedPathList() { appMemzero(this, sizeof(*this)); }
FSortedPathList& FSortedPathList::operator=(const FSortedPathList& Other) { appMemcpy(this, &Other, 260); return *this; } // 65 dwords
void FSortedPathList::addPath(ANavigationPoint*, INT) {}

// ============================================================================
// FPointRegion
// ============================================================================
FPointRegion& FPointRegion::operator=(const FPointRegion& Other)
{
	Zone = Other.Zone;
	iLeaf = Other.iLeaf;
	ZoneNumber = Other.ZoneNumber;
	return *this;
}

// ============================================================================
// FDbgVectorInfo
// ============================================================================
FDbgVectorInfo::FDbgVectorInfo() { appMemzero(this, sizeof(*this)); }
FDbgVectorInfo::FDbgVectorInfo(const FDbgVectorInfo& Other) { appMemcpy(this, &Other, sizeof(*this)); }
FDbgVectorInfo::~FDbgVectorInfo() {}
FDbgVectorInfo& FDbgVectorInfo::operator=(const FDbgVectorInfo& Other) { appMemcpy(this, &Other, sizeof(*this)); return *this; }

// ============================================================================
// FStats
// ============================================================================
FStats::FStats(const FStats& Other) { appMemcpy(this, &Other, sizeof(*this)); }
FStats::~FStats() {}
void FStats::UpdateString(FString&, INT) {}
void FStats::Render(UViewport*, UEngine*) {}
INT FStats::RegisterStats(EStatsType, EStatsDataType, FString, FString, EStatsUnit) { return 0; }
void FStats::CalcMovingAverage(INT, DWORD) {}
void FStats::Clear() { appMemzero(this, sizeof(*this)); }

// ============================================================================
// FEngineStats
// ============================================================================
void FEngineStats::Init() {}

// ============================================================================
// FSoundData
// ============================================================================
FSoundData::FSoundData(USound*) { appMemzero(this, sizeof(*this)); }
FSoundData::~FSoundData() {}
void FSoundData::Load() {}
FLOAT FSoundData::GetPeriod() { return 0.0f; }

// ============================================================================
// FRenderInterface
// ============================================================================
FRenderInterface::FRenderInterface() { appMemzero(RIPad, sizeof(RIPad)); }
FRenderInterface::FRenderInterface(const FRenderInterface& Other) { appMemcpy(this, &Other, sizeof(*this)); }
FRenderInterface& FRenderInterface::operator=(const FRenderInterface& Other) { appMemcpy(this, &Other, sizeof(*this)); return *this; }

// ============================================================================
// FSceneNode subclasses
// ============================================================================

// FActorSceneNode
void FActorSceneNode::Render(FRenderInterface*) {}
FActorSceneNode* FActorSceneNode::GetActorSceneNode() { return this; }

// FCameraSceneNode
void FCameraSceneNode::Render(FRenderInterface*) {}
FCameraSceneNode* FCameraSceneNode::GetCameraSceneNode() { return this; }
void FCameraSceneNode::UpdateMatrices() {}

// FMirrorSceneNode
FMirrorSceneNode::FMirrorSceneNode(FLevelSceneNode* Parent, FPlane Mirror, INT a, INT b)
	: FSceneNode((FSceneNode*)Parent) { appMemzero(Pad2, sizeof(Pad2)); }
FMirrorSceneNode* FMirrorSceneNode::GetMirrorSceneNode() { return this; }

// FSkySceneNode
FSkySceneNode::FSkySceneNode(FLevelSceneNode* Parent, INT Zone)
	: FSceneNode((FSceneNode*)Parent) { appMemzero(Pad2, sizeof(Pad2)); }
FSkySceneNode* FSkySceneNode::GetSkySceneNode() { return this; }

// FWarpZoneSceneNode
FWarpZoneSceneNode::FWarpZoneSceneNode(FLevelSceneNode* Parent, AWarpZoneInfo*)
	: FSceneNode((FSceneNode*)Parent) { appMemzero(Pad2, sizeof(Pad2)); }
FWarpZoneSceneNode* FWarpZoneSceneNode::GetWarpZoneSceneNode() { return this; }

// FLevelSceneNode
FConvexVolume FLevelSceneNode::GetViewFrustum() { return FConvexVolume(); }

// FLightMapSceneNode
void FLightMapSceneNode::Render(FRenderInterface*) {}
INT FLightMapSceneNode::FilterActor(AActor*) { return 0; }

// FDirectionalLightMapSceneNode
FConvexVolume FDirectionalLightMapSceneNode::GetViewFrustum() { return FConvexVolume(); }

// FPointLightMapSceneNode
FConvexVolume FPointLightMapSceneNode::GetViewFrustum() { return FConvexVolume(); }

// ============================================================================
// FHitObserver / HCoords
// ============================================================================
HCoords::HCoords(FCameraSceneNode*) {}

// ============================================================================
// FInBunch
// ============================================================================
FInBunch::FInBunch(const FInBunch& Other) : FBitReader() { appMemcpy(this, &Other, sizeof(*this)); }
FInBunch::FInBunch(UNetConnection*) : FBitReader() { appMemzero(Pad, sizeof(Pad)); }
FInBunch& FInBunch::operator=(const FInBunch& Other) { appMemcpy(this, &Other, sizeof(*this)); return *this; }
FArchive& FInBunch::operator<<(UObject*& Obj) { return *this; }
FArchive& FInBunch::operator<<(FName& N) { return *this; }

// ============================================================================
// FOutBunch
// ============================================================================
FOutBunch::FOutBunch() { appMemzero(this, sizeof(*this)); }
FOutBunch::FOutBunch(const FOutBunch& Other) { appMemcpy(this, &Other, sizeof(*this)); }
FOutBunch::FOutBunch(UChannel*, INT) { appMemzero(this, sizeof(*this)); }
FOutBunch::~FOutBunch() {}
FArchive& FOutBunch::operator<<(UObject*& Obj) { return *(FArchive*)this; }
FArchive& FOutBunch::operator<<(FName& N) { return *(FArchive*)this; }

// ============================================================================
// UInput / UInputPlanning
// ============================================================================
INT UInput::PreProcess(EInputKey Key, EInputAction Action, FLOAT Delta) { return 0; }
INT UInput::Process(FOutputDevice& Ar, EInputKey Key, EInputAction Action, FLOAT Delta) { return 0; }
void UInput::DirectAxis(EInputKey Key, FLOAT Value, FLOAT Delta) {}
const TCHAR* UInput::GetKeyName(EInputKey Key) const { return TEXT(""); }
INT UInput::FindKeyName(const TCHAR* KeyName, EInputKey& Key) const { return 0; }
void UInput::SetInputAction(EInputAction Action, FLOAT Delta) {}
EInputAction UInput::GetInputAction() { return IST_None; }
FLOAT UInput::GetInputDelta() { return 0.0f; }
const TCHAR* UInput::StaticConfigName() { return TEXT("Input"); }
void UInput::StaticInitInput() {}

// ============================================================================
// ALevelInfo
// ============================================================================
void ALevelInfo::SetVolumes(const TArray<class AVolume*>&) {}
void ALevelInfo::SetVolumes() {}
void ALevelInfo::SetZone(INT, INT) {}
void ALevelInfo::PostNetReceive() {}
void ALevelInfo::PreNetReceive() {}
void ALevelInfo::CheckForErrors() {}
INT* ALevelInfo::GetOptimizedRepList(BYTE*, FPropertyRetirement*, INT*, UPackageMap*, UActorChannel*) { return NULL; }
void ALevelInfo::CallLogThisActor(AActor*) {}
APhysicsVolume* ALevelInfo::GetDefaultPhysicsVolume() { return NULL; }
FString ALevelInfo::GetDisplayAs(FString s) { return s; }
APhysicsVolume* ALevelInfo::GetPhysicsVolume(FVector, AActor*, INT) { return NULL; }
INT ALevelInfo::IsSoundAudibleFromZone(INT, INT) { return 1; }

// ============================================================================
// AGameInfo
// ============================================================================
void AGameInfo::AbortScoreSubmission() {}
void AGameInfo::MasterServerManager() {}
void AGameInfo::InitGameInfoGameService() {}
void AGameInfo::ProcessR6Availabilty(ULevel*, FString) {}

// ============================================================================
// AGameReplicationInfo / APlayerReplicationInfo
// ============================================================================
void AGameReplicationInfo::PostNetReceive() {}
INT* AGameReplicationInfo::GetOptimizedRepList(BYTE*, FPropertyRetirement*, INT*, UPackageMap*, UActorChannel*) { return NULL; }
void APlayerReplicationInfo::PostNetReceive() {}
INT* APlayerReplicationInfo::GetOptimizedRepList(BYTE*, FPropertyRetirement*, INT*, UPackageMap*, UActorChannel*) { return NULL; }

// ============================================================================
// UNetConnection
// ============================================================================
UChannel* UNetConnection::CreateChannel(EChannelType ChType, INT bOpenedLocally, INT ChIndex) { return NULL; }
void UNetConnection::PostSend() {}

// ============================================================================
// UChannel
// ============================================================================
UClass** UChannel::ChannelClasses = NULL;

// ============================================================================
// UDemoRecConnection
// ============================================================================
UDemoRecConnection::UDemoRecConnection(UNetDriver* Driver, const FURL& URL)
{
}
void UDemoRecConnection::StaticConstructor() {}
FString UDemoRecConnection::LowLevelDescribe() { return FString(TEXT("Demo recording driver connection")); }
FString UDemoRecConnection::LowLevelGetRemoteAddress() { return FString(TEXT("")); }
void UDemoRecConnection::LowLevelSend(void* Data, INT Count) {
	// Ghidra at 0x187b80. Writes demo packet: FrameNum, DemoFrameTime, Count, Data.
	if (Driver->ServerConnection == NULL) {
		FArchive* FileAr = *(FArchive**)((BYTE*)Driver + 0xB4);
		FileAr->ByteOrderSerialize((BYTE*)Driver + 0xCC, 4);    // FrameNum (INT)
		FileAr->ByteOrderSerialize((BYTE*)Driver + 0x48, 8);    // DemoFrameTime (DOUBLE)
		FileAr->ByteOrderSerialize(&Count, 4);                  // packet size
		FileAr->Serialize(Data, Count);                          // packet data
	}
}

// Ghidra at 0x187cf0 (16 bytes). Only flushes if not a client connection.
void UDemoRecConnection::FlushNet() {
	if (Driver->ServerConnection == NULL)
		UNetConnection::FlushNet();
}
INT UDemoRecConnection::IsNetReady(INT) { return 1; }
void UDemoRecConnection::HandleClientPlayer(APlayerController*) {}
UDemoRecDriver* UDemoRecConnection::GetDriver() { return (UDemoRecDriver*)Driver; }

// ============================================================================
// UPackageMapLevel
// ============================================================================
UPackageMapLevel::UPackageMapLevel(UNetConnection*) {}
INT UPackageMapLevel::SerializeObject(FArchive&, UClass*, UObject*&) { return 0; }
// Ghidra at 0x48BCD0: default return is 1 (can serialize), returns 0 only for specific Actor flag checks.
INT UPackageMapLevel::CanSerializeObject(UObject*) { return 1; }

// ============================================================================
// UNullRenderDevice
// ============================================================================
void UNullRenderDevice::SetEmulationMode(EHardwareEmulationMode) {}
INT UNullRenderDevice::SupportsTextureFormat(ETextureFormat) { return 1; }

// ============================================================================
// UEngine / UGameEngine
// ============================================================================
void UGameEngine::BuildServerMasterMap(UNetDriver*, ULevel*) {}

// ============================================================================
// UTerrainPrimitive
// ============================================================================
UTerrainPrimitive::UTerrainPrimitive(ATerrainInfo*) {}
void UTerrainPrimitive::Serialize(FArchive& Ar) { UPrimitive::Serialize(Ar); }
INT UTerrainPrimitive::LineCheck(FCheckResult&, AActor*, FVector, FVector, FVector, DWORD, DWORD) { return 1; }
INT UTerrainPrimitive::PointCheck(FCheckResult&, AActor*, FVector, FVector, DWORD) { return 1; }
void UTerrainPrimitive::Illuminate(AActor*, INT) {}
FBox UTerrainPrimitive::GetRenderBoundingBox(const AActor*, INT) { return FBox(); }

// ============================================================================
// UTerrainSector
// ============================================================================
UTerrainSector::UTerrainSector(ATerrainInfo*, INT, INT, INT, INT) {}
void UTerrainSector::Serialize(FArchive& Ar) { UObject::Serialize(Ar); }
void UTerrainSector::PostLoad() {}
void UTerrainSector::StaticLight(INT) {}
void UTerrainSector::GenerateTriangles() {}
// Ghidra at 0x156550. Returns linear index in the global heightmap grid.
INT UTerrainSector::GetGlobalVertex(INT X, INT Y) {
	// TerrainInfo->HeightmapX is at offset 0x12E0 in ATerrainInfo
	INT HeightmapX = *(INT*)((BYTE*)TerrainInfo + 0x12E0);
	return (OffsetY + Y) * HeightmapX + OffsetX + X;
}

// Ghidra at 0x153a0. Returns linear index within this sector.
INT UTerrainSector::GetLocalVertex(INT X, INT Y) {
	return (SectorSizeX + 1) * Y + X;
}
INT UTerrainSector::PassShouldRenderTriangle(INT, INT, INT, INT, INT) { return 1; }
INT UTerrainSector::IsSectorAll(INT, BYTE) { return 0; }
INT UTerrainSector::IsTriangleAll(INT, INT, INT, INT, INT, BYTE) { return 0; }
void UTerrainSector::AttachProjector(AProjector*, FProjectorRenderInfo*) {}

// ============================================================================
// FStaticMeshColorStream
// ============================================================================
INT FStaticMeshColorStream::GetComponents(FVertexComponent* C) {
	C[0].Type = 4; C[0].Function = 3;
	return 1;
}

// ============================================================================
// FCollisionHash
// ============================================================================
FCollisionHash::FCollisionLink*& FCollisionHash::GetHashLink(INT, INT, INT, INT&)
{
	static FCollisionHash::FCollisionLink* dummy = NULL;
	return dummy;
}

// ============================================================================
// URenderResource — Ghidra at 0x110D00.
// Serializes UObject + Revision (4 bytes at 0x2C).
// ============================================================================
void URenderResource::Serialize(FArchive& Ar)
{
	UObject::Serialize(Ar);
	Ar << Revision;
}

// ============================================================================
// FPoly
// ============================================================================
INT FPoly::RemoveColinears() { return 0; }

// ============================================================================
// Karma free functions
// ============================================================================
struct _McdGeometry;
struct McdGeomMan;

_McdGeometry* KAggregateGeomInstance(FKAggregateGeom*, FVector, McdGeomMan*, const _WORD*) { return NULL; }
void KME2UCoords(FCoords* Out, const FLOAT (* const tm)[4]) {
	*Out = FCoords(
		FVector(tm[3][0]*50.f, tm[3][1]*50.f, tm[3][2]*50.f),
		FVector(tm[0][0], tm[0][1], tm[0][2]),
		FVector(tm[1][0], tm[1][1], tm[1][2]),
		FVector(tm[2][0], tm[2][1], tm[2][2])
	);
}
void KME2UMatrixCopy(FMatrix* Out, FLOAT (* const In)[4]) {
	appMemcpy(Out, In, sizeof(FLOAT)*16);
}
void KME2UTransform(FVector* OutPos, FRotator* OutRot, const FLOAT (* const tm)[4]) {
	OutPos->X = tm[3][0] * 50.0f;
	OutPos->Y = tm[3][1] * 50.0f;
	OutPos->Z = tm[3][2] * 50.0f;
	FCoords Coords;
	KME2UCoords(&Coords, tm);
	*OutRot = Coords.OrthoRotation();
}
void KModelToHulls(FKAggregateGeom*, UModel*, FVector) {}
void KU2MEMatrixCopy(FLOAT (* const Out)[4], FMatrix* In) {
	appMemcpy(Out, In, sizeof(FLOAT)*16);
}
void KU2METransform(FLOAT (* const tm)[4], FVector Pos, FRotator Rot) {
	FCoords Coords(FVector(0.f,0.f,0.f));
	Coords *= Rot;
	tm[0][0] = Coords.XAxis.X; tm[0][1] = Coords.XAxis.Y; tm[0][2] = Coords.XAxis.Z; tm[0][3] = 0.f;
	tm[1][0] = Coords.YAxis.X; tm[1][1] = Coords.YAxis.Y; tm[1][2] = Coords.YAxis.Z; tm[1][3] = 0.f;
	tm[2][0] = Coords.ZAxis.X; tm[2][1] = Coords.ZAxis.Y; tm[2][2] = Coords.ZAxis.Z; tm[2][3] = 0.f;
	tm[3][0] = Pos.X * 0.02f; tm[3][1] = Pos.Y * 0.02f; tm[3][2] = Pos.Z * 0.02f; tm[3][3] = 1.0f;
}

// ============================================================================
// TArray<BYTE> operators
// ============================================================================
TArray<BYTE>& TArray<BYTE>::operator+(const TArray<BYTE>& Other) { return *this; }
TArray<BYTE>& TArray<BYTE>::operator+=(const TArray<BYTE>& Other) { return *this; }

// ============================================================================
// TLazyArray<BYTE> — copy ctor and operator= are compiler-generated;
// cannot provide explicit definitions. Left as linker stubs.
// ============================================================================


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
// ============================================================================

// ============================================================================
// UMeshInstance
// ============================================================================
// Default ctor now inline in header

// ============================================================================
// FLevelSceneNode
// ============================================================================
FLevelSceneNode& FLevelSceneNode::operator=(const FLevelSceneNode& Other) { appMemcpy(this, &Other, sizeof(*this)); return *this; }

// ============================================================================
// FSceneNode
// ============================================================================
FSceneNode& FSceneNode::operator=(const FSceneNode& Other) { appMemcpy(this, &Other, sizeof(*this)); return *this; }



// ============================================================================
// TLazyArray<BYTE> — force emission of implicitly-declared special members
// (copy ctor, operator=, default constructor closure).
// Explicit template instantiation only emits explicitly-defined members;
// these three are compiler-generated and need actual usage to be emitted.
// ============================================================================
template class TLazyArray<BYTE>;

// new[] forces default constructor closure (??_F); copy ctor and operator= are
// triggered by direct use. The function itself is unreachable but the symbols
// it references have external linkage and remain in the object file.
void _ForceTLazyArrayByteEmit() {
    TLazyArray<BYTE>* p = new TLazyArray<BYTE>[1];
    TLazyArray<BYTE> copy(*p);
    *p = copy;
    delete[] p;
}

/*-----------------------------------------------------------------------------
  AReplicationInfo virtual method stubs.
  Only methods NOT defined in EngineClassImpl.cpp remain here.
-----------------------------------------------------------------------------*/
void AReplicationInfo::DisplayVideo(UCanvas*, void*, INT) {}
void AReplicationInfo::Draw3DLine(FVector, FVector, FColor, UTexture*, FLOAT, FLOAT, FLOAT, FLOAT) {}
void AReplicationInfo::GetAvailableResolutions(TArray<FResolutionInfo>&) {}
DWORD AReplicationInfo::GetAvailableVideoMemory() { return 0; }
void AReplicationInfo::HandleFullScreenEffects(INT, INT) {}
