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
	guard(AR6ActionSpot::RenderEditorInfo);
	unguard;
}

void AR6ActionSpot::CheckForErrors()
{
	guard(AR6ActionSpot::CheckForErrors);
	AActor::CheckForErrors();
	if (m_Anchor == NULL)
	{
		// Deviation: GWarn vtable slot 0x28 (MapCheck) not declared; use debugf.
		debugf(NAME_Warning, TEXT("No paths from %s"), GetName());
	}
	unguard;
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
	guard(AR6ColBox::EnableCollision);
	unguard;
}

void AR6ColBox::GetColBoxLocationFromOwner(FVector& result, float height)
{
	guard(AR6ColBox::GetColBoxLocationFromOwner);
	AActor* owner = *(AActor**)((BYTE*)this + 0x140);
	if (owner)
	{
		FVector dir = ((FRotator*)((BYTE*)owner + 0x240))->Vector();
		FVector offset = dir * height;
		result.X = offset.X + *(FLOAT*)((BYTE*)owner + 0x234);
		result.Y = offset.Y + *(FLOAT*)((BYTE*)owner + 0x238);
		result.Z = offset.Z + *(FLOAT*)((BYTE*)owner + 0x23c);
		return;
	}
	result = FVector(0.f, 0.f, 0.f);
	unguard;
}

void AR6ColBox::GetDestination(FVector &,FRotator &)
{
	guard(AR6ColBox::GetDestination);
	unguard;
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
	guard(AR6DecalGroup::Spawned);
	unguard;
}

void AR6DecalGroup::KillDecal(AR6Decal *)
{
	guard(AR6DecalGroup::KillDecal);
	unguard;
}

void AR6DecalGroup::PostScriptDestroyed()
{
	guard(AR6DecalGroup::PostScriptDestroyed);
	unguard;
}

void AR6DecalGroup::ActivateGroup()
{
	guard(AR6DecalGroup::ActivateGroup);
	unguard;
}

int AR6DecalGroup::AddDecal(FVector *,FRotator *,UTexture *,int,float,float,float,float,int)
{
	return 0;
}


// --- AR6DecalManager ---
void AR6DecalManager::Spawned()
{
	guard(AR6DecalManager::Spawned);
	unguard;
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
void AR6RainbowStartInfo::TransferFile(FArchive& Ar)
{
	guard(AR6RainbowStartInfo::TransferFile);
	Ar.ByteOrderSerialize((BYTE*)this + 0x398, 4);
	Ar << *(FString*)((BYTE*)this + 0x3e0);
	Ar << *(FString*)((BYTE*)this + 0x3f8);
	Ar << *(FString*)((BYTE*)this + 0x404);
	Ar << *(FString*)((BYTE*)this + 0x410);
	Ar << *(FString*)((BYTE*)this + 0x41c);
	Ar << *(FString*)((BYTE*)this + 0x428);
	Ar << *(FString*)((BYTE*)this + 0x434);
	Ar << *(FString*)((BYTE*)this + 0x440);
	Ar << *(FString*)((BYTE*)this + 0x44c);
	if (!Ar.IsSaving() && Ar.Ver() < 5)
	{
		*(FString*)((BYTE*)this + 0x3ec) = TEXT("ASSAULT");
		return;
	}
	Ar << *(FString*)((BYTE*)this + 0x3ec);
	unguard;
}


// --- AR6TeamStartInfo ---
void AR6TeamStartInfo::TransferFile(FArchive &,int)
{
	guard(AR6TeamStartInfo::TransferFile);
	unguard;
}


// --- AR6WallHit ---
void AR6WallHit::SpawnEffects()
{
	guard(AR6WallHit::SpawnEffects);
	unguard;
}

void AR6WallHit::SpawnSound()
{
	guard(AR6WallHit::SpawnSound);
	unguard;
}

void AR6WallHit::PostBeginPlay()
{
	guard(AR6WallHit::PostBeginPlay);
	unguard;
}


// --- AR6eviLTesting ---
void AR6eviLTesting::eviLTestATS()
{
	guard(AR6eviLTesting::eviLTestATS);
	unguard;
}

void AR6eviLTesting::evilTestUpdateSystem()
{
	guard(AR6eviLTesting::evilTestUpdateSystem);
	unguard;
}


// --- UR6AbstractGameManager ---
void UR6AbstractGameManager::StartJoinServer(FString,FString,int)
{
	guard(UR6AbstractGameManager::StartJoinServer);
	unguard;
}

int UR6AbstractGameManager::StartLogInProcedure()
{
	return 0;
}

void UR6AbstractGameManager::StartPreJoinProcedure(int)
{
	guard(UR6AbstractGameManager::StartPreJoinProcedure);
	unguard;
}

void UR6AbstractGameManager::UnInitialize()
{
	guard(UR6AbstractGameManager::UnInitialize);
	unguard;
}

void UR6AbstractGameManager::SetGSCreateUbiServer(int)
{
	guard(UR6AbstractGameManager::SetGSCreateUbiServer);
	unguard;
}

void UR6AbstractGameManager::LaunchListenSrv(FString,FString)
{
	guard(UR6AbstractGameManager::LaunchListenSrv);
	unguard;
}

void UR6AbstractGameManager::ClientLeaveServer()
{
	guard(UR6AbstractGameManager::ClientLeaveServer);
	unguard;
}

void UR6AbstractGameManager::ConnectionInterrupted(int)
{
	guard(UR6AbstractGameManager::ConnectionInterrupted);
	unguard;
}

void UR6AbstractGameManager::GameServiceTick(UConsole *)
{
	guard(UR6AbstractGameManager::GameServiceTick);
	unguard;
}

int UR6AbstractGameManager::GetGSCreateUbiServer()
{
	return 0;
}

void UR6AbstractGameManager::InitializeGameService(UConsole *)
{
	guard(UR6AbstractGameManager::InitializeGameService);
	unguard;
}


// --- UR6AbstractPlanningInfo ---
void UR6AbstractPlanningInfo::TransferFile(FArchive &)
{
	guard(UR6AbstractPlanningInfo::TransferFile);
	unguard;
}

void UR6AbstractPlanningInfo::AddPoint(AActor *)
{
	guard(UR6AbstractPlanningInfo::AddPoint);
	unguard;
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

void UR6FileManager::GetFileName(int param_1, FString* param_2)
{
	guard(UR6FileManager::GetFileName);
	// this+0x2c is the Data pointer of a TArray of FStrings (12 bytes each).
	FString* elem = (FString*)(*(INT*)((BYTE*)this + 0x2c) + param_1 * 0xc);
	*param_2 = elem->Caps();
	unguard;
}

int UR6FileManager::GetNbFile(FString *,FString *)
{
	return 0;
}

