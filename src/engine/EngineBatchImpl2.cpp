// EngineBatchImpl2.cpp - Auto-generated implementations round 2
#include "Engine.h"
#include "EngineDecls.h"

// Disable optimization so trivial function bodies (empty {}, return 0, etc.)
// still produce exported symbols in the .obj file. MSVC's optimizer will
// eliminate dllexport symbols whose bodies are trivial.
#pragma optimize("", off)

// --- AAIController ---
void AAIController::SetAdjustLocation(FVector)
{
}

int AAIController::AcceptNearbyPath(AActor *)
{
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
	return 0;
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
	return NULL;
}

int APlayerController::IsNetRelevantFor(APlayerController *,AActor *,FVector)
{
	return 0;
}

// --- APlayerStart ---
void APlayerStart::addReachSpecs(APawn *,int)
{
}

// --- AProjector ---
int AProjector::ShouldTrace(AActor *,DWORD)
{
	return 0;
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
}

FBspVertex& FBspVertex::operator=(const FBspVertex&)
{
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
FCanvasVertex::FCanvasVertex(FVector,FColor,float,float)
{
}

FCanvasVertex::FCanvasVertex()
{
}

FCanvasVertex& FCanvasVertex::operator=(const FCanvasVertex&)
{
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

FDynamicLight::FDynamicLight(FDynamicLight const &)
{
}

FDynamicLight::FDynamicLight(AActor *)
{
}

FDynamicLight& FDynamicLight::operator=(const FDynamicLight&)
{
	return *this;
}

// --- FFontCharacter ---
FFontCharacter& FFontCharacter::operator=(const FFontCharacter&)
{
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
FKBoxElem::FKBoxElem(float)
{
}

FKBoxElem::FKBoxElem(float,float,float)
{
}

FKBoxElem::FKBoxElem()
{
}

FKBoxElem::~FKBoxElem()
{
}

FKBoxElem& FKBoxElem::operator=(const FKBoxElem&)
{
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
FKCylinderElem::FKCylinderElem(float,float)
{
}

FKCylinderElem::FKCylinderElem()
{
}

FKCylinderElem::~FKCylinderElem()
{
}

FKCylinderElem& FKCylinderElem::operator=(const FKCylinderElem&)
{
	return *this;
}

// --- FKSphereElem ---
FKSphereElem::FKSphereElem(float)
{
}

FKSphereElem::FKSphereElem()
{
}

FKSphereElem::~FKSphereElem()
{
}

FKSphereElem& FKSphereElem::operator=(const FKSphereElem&)
{
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
FLineVertex::FLineVertex(FVector,FColor)
{
}

FLineVertex::FLineVertex()
{
}

FLineVertex& FLineVertex::operator=(const FLineVertex&)
{
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

FMipmapBase& FMipmapBase::operator=(const FMipmapBase&)
{
	return *this;
}

// --- FOrientation ---
FOrientation::FOrientation()
{
}

FOrientation& FOrientation::operator=(const FOrientation&)
{
	return *this;
}

int FOrientation::operator!=(FOrientation const &) const
{
	return 0;
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
FReachSpec& FReachSpec::operator=(const FReachSpec&)
{
	return *this;
}

// --- FRebuildOptions ---
FRebuildOptions::FRebuildOptions(FRebuildOptions const &)
{
}

FRebuildOptions::FRebuildOptions()
{
}

FRebuildOptions::~FRebuildOptions()
{
}

FRebuildOptions& FRebuildOptions::operator=(const FRebuildOptions&)
{
	return *this;
}

FString FRebuildOptions::GetName()
{
	return FString();
}

void FRebuildOptions::Init()
{
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
}

FStaticMeshCollisionNode& FStaticMeshCollisionNode::operator=(const FStaticMeshCollisionNode&)
{
	return *this;
}

// --- FStaticMeshCollisionTriangle ---
FStaticMeshCollisionTriangle::FStaticMeshCollisionTriangle(FStaticMeshCollisionTriangle const &)
{
}

FStaticMeshCollisionTriangle::FStaticMeshCollisionTriangle()
{
}

FStaticMeshCollisionTriangle& FStaticMeshCollisionTriangle::operator=(const FStaticMeshCollisionTriangle&)
{
	return *this;
}

// --- FStaticMeshMaterial ---
FStaticMeshMaterial::FStaticMeshMaterial(UMaterial *)
{
}

FStaticMeshMaterial& FStaticMeshMaterial::operator=(const FStaticMeshMaterial&)
{
	return *this;
}

// --- FStaticMeshSection ---
FStaticMeshSection::FStaticMeshSection()
{
}

FStaticMeshSection& FStaticMeshSection::operator=(const FStaticMeshSection&)
{
	return *this;
}

// --- FStaticMeshTriangle ---
FStaticMeshTriangle::FStaticMeshTriangle()
{
}

FStaticMeshTriangle& FStaticMeshTriangle::operator=(const FStaticMeshTriangle&)
{
	return *this;
}

// --- FStaticMeshUV ---
FStaticMeshUV& FStaticMeshUV::operator=(const FStaticMeshUV&)
{
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
}

FStaticMeshVertex& FStaticMeshVertex::operator=(const FStaticMeshVertex&)
{
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
int UBitmapMaterial::MaterialUSize()
{
	return 0;
}

int UBitmapMaterial::MaterialVSize()
{
	return 0;
}

UBitmapMaterial * UBitmapMaterial::Get(double,UViewport *)
{
	return NULL;
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
void UCanvas::WrappedPrint(ERenderStyle,int &,int &,UFont *,int,const TCHAR*)
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
BYTE UCombiner::RequiredUVStreams()
{
	return 0;
}

int UCombiner::RequiresSorting()
{
	return 0;
}

int UCombiner::MaterialUSize()
{
	return 0;
}

int UCombiner::MaterialVSize()
{
	return 0;
}

void UCombiner::PostEditChange()
{
}

int UCombiner::CheckCircularReferences(TArray<UMaterial *> &)
{
	return 0;
}

int UCombiner::IsTransparent()
{
	return 0;
}

// --- UConstantColor ---
FColor UConstantColor::GetColor(float)
{
	return FColor(0,0,0,0);
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
int UFinalBlend::RequiresSorting()
{
	return 0;
}

void UFinalBlend::SetValidated(int)
{
}

void UFinalBlend::PostEditChange()
{
}

int UFinalBlend::GetValidated()
{
	return 0;
}

int UFinalBlend::IsTransparent()
{
	return 0;
}

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
BYTE UMaterial::RequiredUVStreams()
{
	return 0;
}

int UMaterial::RequiresSorting()
{
	return 0;
}

int UMaterial::MaterialUSize()
{
	return 0;
}

int UMaterial::MaterialVSize()
{
	return 0;
}

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
BYTE UModifier::RequiredUVStreams()
{
	return 0;
}

int UModifier::RequiresSorting()
{
	return 0;
}

int UModifier::MaterialUSize()
{
	return 0;
}

int UModifier::MaterialVSize()
{
	return 0;
}

void UModifier::PostEditChange()
{
}

int UModifier::CheckCircularReferences(TArray<UMaterial *> &)
{
	return 0;
}

int UModifier::IsTransparent()
{
	return 0;
}

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

void UPalette::Serialize(FArchive &)
{
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
BYTE UShader::RequiredUVStreams()
{
	return 0;
}

int UShader::RequiresSorting()
{
	return 0;
}

int UShader::MaterialUSize()
{
	return 0;
}

int UShader::MaterialVSize()
{
	return 0;
}

void UShader::PostEditChange()
{
}

int UShader::CheckCircularReferences(TArray<UMaterial *> &)
{
	return 0;
}

UMaterial * UShader::CheckFallback()
{
	return NULL;
}

UMaterial * UShader::GetDiffuse()
{
	return NULL;
}

int UShader::HasFallback()
{
	return 0;
}

int UShader::IsTransparent()
{
	return 0;
}

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
int UTexture::RequiresSorting()
{
	return 0;
}

void UTexture::PostLoad()
{
}

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

