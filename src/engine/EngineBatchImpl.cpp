// EngineBatchImpl.cpp - Auto-generated stub implementations
// Only includes methods that are declared in EngineClasses.h
#include "Engine.h"

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

int AMover::ShouldTrace(AActor *,DWORD)
{
	return 0;
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
	return 0;
}

int FAnimMeshVertexStream::GetComponents(FVertexComponent *)
{
	return 0;
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
	return 0;
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
	return 0;
}

// --- FBspVertexStream ---
unsigned __int64 FBspVertexStream::GetCacheId()
{
	return 0;
}

int FBspVertexStream::GetComponents(FVertexComponent *)
{
	return 0;
}

void FBspVertexStream::GetRawStreamData(void * *,int)
{
}

int FBspVertexStream::GetRevision()
{
	return 0;
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
	return 0;
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

int FCanvasUtil::GetComponents(FVertexComponent *)
{
	return 0;
}

void FCanvasUtil::GetRawStreamData(void * *,int)
{
}

int FCanvasUtil::GetRevision()
{
	return 0;
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
	return 0;
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
	return NULL;
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
	return TEXF_P8;
}

int FLightMap::GetHeight()
{
	return 0;
}

int FLightMap::GetNumMips()
{
	return 0;
}

void * FLightMap::GetRawTextureData(int)
{
	return NULL;
}

int FLightMap::GetRevision()
{
	return 0;
}

void FLightMap::GetTextureData(int,void *,int,ETextureFormat,int)
{
}

ETexClampMode FLightMap::GetUClamp()
{
	return TC_Wrap;
}

UTexture * FLightMap::GetUTexture()
{
	return NULL;
}

ETexClampMode FLightMap::GetVClamp()
{
	return TC_Wrap;
}

int FLightMap::GetWidth()
{
	return 0;
}

// --- FLightMapTexture ---
unsigned __int64 FLightMapTexture::GetCacheId()
{
	return 0;
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
	return TEXF_P8;
}

int FLightMapTexture::GetHeight()
{
	return 0;
}

int FLightMapTexture::GetNumChildren()
{
	return 0;
}

int FLightMapTexture::GetNumMips()
{
	return 0;
}

int FLightMapTexture::GetRevision()
{
	return 0;
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
	return 0;
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
	return 0;
}

int FLineBatcher::GetComponents(FVertexComponent *)
{
	return 0;
}

void FLineBatcher::GetRawStreamData(void * *,int)
{
}

int FLineBatcher::GetRevision()
{
	return 0;
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
	return 0;
}

void FRaw32BitIndexBuffer::GetContents(void *)
{
}

int FRaw32BitIndexBuffer::GetIndexSize()
{
	return 0;
}

int FRaw32BitIndexBuffer::GetRevision()
{
	return 0;
}

int FRaw32BitIndexBuffer::GetSize()
{
	return 0;
}

// --- FRawColorStream ---
unsigned __int64 FRawColorStream::GetCacheId()
{
	return 0;
}

int FRawColorStream::GetComponents(FVertexComponent *)
{
	return 0;
}

void FRawColorStream::GetRawStreamData(void * *,int)
{
}

int FRawColorStream::GetRevision()
{
	return 0;
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
	return 0;
}

// --- FRawIndexBuffer ---
void FRawIndexBuffer::CacheOptimize()
{
}

unsigned __int64 FRawIndexBuffer::GetCacheId()
{
	return 0;
}

void FRawIndexBuffer::GetContents(void *)
{
}

int FRawIndexBuffer::GetIndexSize()
{
	return 0;
}

int FRawIndexBuffer::GetRevision()
{
	return 0;
}

int FRawIndexBuffer::GetSize()
{
	return 0;
}

// --- FSkinVertexStream ---
unsigned __int64 FSkinVertexStream::GetCacheId()
{
	return 0;
}

int FSkinVertexStream::GetComponents(FVertexComponent *)
{
	return 0;
}

void FSkinVertexStream::GetRawStreamData(void * *,int)
{
}

int FSkinVertexStream::GetRevision()
{
	return 0;
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
	return 0;
}

// --- FStaticLightMapTexture ---
unsigned __int64 FStaticLightMapTexture::GetCacheId()
{
	return 0;
}

int FStaticLightMapTexture::GetFirstMip()
{
	return 0;
}

ETextureFormat FStaticLightMapTexture::GetFormat()
{
	return TEXF_P8;
}

int FStaticLightMapTexture::GetHeight()
{
	return 0;
}

int FStaticLightMapTexture::GetNumMips()
{
	return 0;
}

void * FStaticLightMapTexture::GetRawTextureData(int)
{
	return NULL;
}

int FStaticLightMapTexture::GetRevision()
{
	return 0;
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
	return 0;
}

// --- FStaticMeshUVStream ---
unsigned __int64 FStaticMeshUVStream::GetCacheId()
{
	return 0;
}

int FStaticMeshUVStream::GetComponents(FVertexComponent *)
{
	return 0;
}

void FStaticMeshUVStream::GetRawStreamData(void * *,int)
{
}

int FStaticMeshUVStream::GetRevision()
{
	return 0;
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
	return 0;
}

// --- FStaticMeshVertexStream ---
unsigned __int64 FStaticMeshVertexStream::GetCacheId()
{
	return 0;
}

int FStaticMeshVertexStream::GetComponents(FVertexComponent *)
{
	return 0;
}

void FStaticMeshVertexStream::GetRawStreamData(void * *,int)
{
}

int FStaticMeshVertexStream::GetRevision()
{
	return 0;
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
	return 0;
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

void UMaterial::Serialize(FArchive &)
{
}

void UMaterial::SetValidated(int)
{
}

int UMaterial::CheckCircularReferences(TArray<UMaterial *> &)
{
	return 0;
}

UMaterial * UMaterial::CheckFallback()
{
	return NULL;
}

UMaterial * UMaterial::GetDiffuse()
{
	return NULL;
}

int UMaterial::GetValidated()
{
	return 0;
}

int UMaterial::HasFallback()
{
	return 0;
}

int UMaterial::IsTransparent()
{
	return 0;
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

void UTexture::Serialize(FArchive &)
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

void UTexture::Destroy()
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

int UTexture::IsTransparent()
{
	return 0;
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

