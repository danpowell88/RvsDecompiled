/*=============================================================================
	R6EngineIntegration.cpp: R6-specific types hosted in Engine.dll
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/
#pragma optimize("", off)

// Placement new for placement-new stubs in this TU.
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EnginePrivate.h"
#include "EngineDecls.h"

// --- AR6AbstractCircumstantialActionQuery ---
INT* AR6AbstractCircumstantialActionQuery::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
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

void AR6ColBox::SetBase(AActor* NewBase, FVector FloorNormal, int bNotifyActor)
{
	// Retail: 21b. If NewBase is NULL, calls error handler (3x null push + call).
	// If non-NULL, cross-function-jumps to AActor::SetBase.
	if (!NewBase) return;
	AActor::SetBase(NewBase, FloorNormal, bNotifyActor);
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

AR6DecalGroup * AR6DecalManager::FindGroup(eDecalType type)
{
	// Retail: 0x177820, 66 bytes. Returns the decal group for the given type.
	// 5 types map to fields at this+0x398 through this+0x3A8 (4 bytes apart).
	switch (type)
	{
		case 0: return *(AR6DecalGroup**)((BYTE*)this + 0x398);
		case 1: return *(AR6DecalGroup**)((BYTE*)this + 0x39C);
		case 2: return *(AR6DecalGroup**)((BYTE*)this + 0x3A0);
		case 3: return *(AR6DecalGroup**)((BYTE*)this + 0x3A4);
		case 4: return *(AR6DecalGroup**)((BYTE*)this + 0x3A8);
		default: return NULL;
	}
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

