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
int AR6ColBox::ShouldTrace(AActor* param_1, DWORD param_2)
{
	guard(AR6ColBox::ShouldTrace);
	typedef INT (__fastcall *FShouldTraceFn)(void*, void*, AActor*, DWORD);
	INT* pOwner;
	FShouldTraceFn fn;

	// this+0x15c = owner actor, this+0x394 = collision flags byte
	if ((*(INT*)((BYTE*)this + 0x15c) != 0) && ((*(BYTE*)((BYTE*)this + 0x394) & 1) != 0))
	{
		// this+0x398 = activation radius; NAN(x)==(x==0.0) means x != 0
		if (*(FLOAT*)((BYTE*)this + 0x398) != 0.0f)
		{
			if (param_1 == NULL) goto LAB_10476755;
			if (*(AR6ColBox**)((BYTE*)param_1 + 0x184) == this)
				return 0;
			if ((*(INT*)((BYTE*)param_1 + 0x140) != 0) &&
				(*(AR6ColBox**)(*(INT*)((BYTE*)param_1 + 0x140) + 0x184) == this))
				return 0;
		}
		if ((param_1 == NULL) || (*(AR6ColBox**)((BYTE*)param_1 + 0x180) != this))
		{
		LAB_10476755:
			pOwner = *(INT**)((BYTE*)this + 0x15c);
			fn = *(FShouldTraceFn*)((BYTE*)*pOwner + 0xbc);
			return fn(pOwner, 0, param_1, param_2);
		}
	}
	return 0;
	unguard;
}

void AR6ColBox::SetBase(AActor* NewBase, FVector FloorNormal, int bNotifyActor)
{
	// Retail: 21b. If NewBase is NULL, calls error handler (3x null push + call).
	// If non-NULL, cross-function-jumps to AActor::SetBase.
	if (!NewBase) return;
	AActor::SetBase(NewBase, FloorNormal, bNotifyActor);
}

int AR6ColBox::CanStepUp(FVector vec)
{
	guard(AR6ColBox::CanStepUp);
	// FVector passed as 3 scalar args in Ghidra; only Z component (vec.Z) is used
	// this+0x15c = owner actor, this+0x394 = collision flags, this+0x23c = CollisionHeight
	INT* pOwner = *(INT**)((BYTE*)this + 0x15c);
	if (((*(DWORD*)((BYTE*)this + 0x394) & 4) != 0) &&
		(pOwner != NULL) &&
		(*(INT*)((BYTE*)pOwner + 0x3a8) == 0) &&
		((*(DWORD*)((BYTE*)this + 0x394) & 1) != 0))
	{
		FLOAT fVar1 = *(FLOAT*)((BYTE*)this + 0x23c);  // this CollisionHeight
		FLOAT stepHeight = 25.0f;
		FLOAT fVar2 = *(FLOAT*)((BYTE*)pOwner + 0x23c);  // owner CollisionHeight
		UObject* pCol = *(UObject**)((BYTE*)pOwner + 0x15c);
		if (pCol != NULL)
		{
			// TODO: ATerrainInfo::PrivateStaticClass — terrain gets 50-unit step height
			if (pCol->IsA(ATerrainInfo::StaticClass()))
				stepHeight = 50.0f;
		}
		if (stepHeight <= (fVar1 - fVar2) + vec.Z)
			return 0;
	}
	return 1;
	unguard;
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

float AR6ColBox::GetMaxStepUp(bool param_1, float param_2)
{
	guard(AR6ColBox::GetMaxStepUp);
	// this+0x15c = owner actor, this+0x394 = collision flags
	INT* pOwner = *(INT**)((BYTE*)this + 0x15c);

	if ((!param_1 &&
		((*(DWORD*)((BYTE*)this + 0x394) & 4) == 0 ||
		 (*(DWORD*)((BYTE*)this + 0x394) & 1) == 0)) ||
		(pOwner == NULL) ||
		(*(INT*)((BYTE*)pOwner + 0x3a8) != 0))
	{
		return 33.0f;
	}

	INT* pBase = *(INT**)((BYTE*)pOwner + 0x180);  // owner's Base (floor actor)
	FLOAT fVar1 = *(FLOAT*)((BYTE*)pBase + 0x23c) - *(FLOAT*)((BYTE*)pOwner + 0x23c);
	if (param_1)
		fVar1 = param_2;  // override with explicit param

	FLOAT stepHeight = 25.0f;
	UObject* pCol = *(UObject**)((BYTE*)pOwner + 0x15c);
	if (pCol != NULL)
	{
		// TODO: ATerrainInfo::PrivateStaticClass — terrain gets 50-unit step height
		if (pCol->IsA(ATerrainInfo::StaticClass()))
			stepHeight = 50.0f;
	}

	// Ghidra NaN check translates to: fVar1 > 0.0f && stepHeight <= fVar1 → return 0
	if (fVar1 > 0.0f && stepHeight <= fVar1)
		return 0.0f;

	return stepHeight - fVar1;
	unguard;
}

APawn * AR6ColBox::GetPawnOrColBoxOwner() const
{
	guard(AR6ColBox::GetPawnOrColBoxOwner);
	typedef APawn* (__fastcall *FGetPawnFn)(void*, void*);

	// this+0x140 = owner/attached-actor, this+0x398 = activation radius
	INT* piVar1 = *(INT**)((BYTE*)this + 0x140);

	if (*(FLOAT*)((BYTE*)this + 0x398) != 0.0f)  // NAN check => float != 0
	{
		if (piVar1 != NULL)
		{
			FGetPawnFn fn = *(FGetPawnFn*)((BYTE*)*piVar1 + 0x6c);
			return fn(piVar1, 0);
		}
	}
	else if (piVar1 != NULL)
	{
		FGetPawnFn fn = *(FGetPawnFn*)((BYTE*)*piVar1 + 0x68);
		return fn(piVar1, 0);
	}
	return NULL;
	unguard;
}

int AR6ColBox::IsBlockedBy(AActor const* param_1) const
{
	guard(AR6ColBox::IsBlockedBy);
	// this+0x15c = owner actor, this+0x394 = collision flags byte
	if ((*(INT*)((BYTE*)this + 0x15c) != 0) && ((*(BYTE*)((BYTE*)this + 0x394) & 1) != 0))
	{
		typedef INT (__fastcall *FIsBlockedByFn)(void*, void*);
		INT* pOwner = *(INT**)((BYTE*)this + 0x15c);
		FIsBlockedByFn fn = *(FIsBlockedByFn*)((BYTE*)*pOwner + 0x70);
		return fn(pOwner, 0);
	}
	return 0;
	unguard;
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

int AR6DecalGroup::AddDecal(FVector* param_1, FRotator* param_2, UTexture* param_3, int param_4,
	float param_5, float param_6, float param_7, float param_8, int param_9)
{
	guard(AR6DecalGroup::AddDecal);
	// this+0x3a0 = group active flag, this+0x3a4 = decal actor array data ptr
	// this+0x39c = current decal index, this+0x398 = group capacity
	if (((*(BYTE*)((BYTE*)this + 0x3a0) & 1) != 0) && (param_3 != NULL))
	{
		AActor* this_00 = *(AActor**)(*(INT*)((BYTE*)this + 0x3a4) + *(INT*)((BYTE*)this + 0x39c) * 4);
		// TODO: FUN_1050557c — sets decal data on this_00+0x39c
		DWORD uVar2 = 0;
		*(DWORD*)((BYTE*)this_00 + 0x39c) = uVar2;
		if ((*(BYTE*)((BYTE*)this_00 + 0x51c) & 1) != 0)
		{
			typedef void (__fastcall *FVtFn1)(void*, void*, INT);
			typedef void (__fastcall *FVtFn0)(void*, void*);
			*(DWORD*)((BYTE*)this_00 + 0xa0) |= 2;
			(*(FVtFn1*)((BYTE*)**(INT**)this_00 + 0x188))(this_00, 0, 1);
			(*(FVtFn0*)((BYTE*)**(INT**)this_00 + 0x18c))(this_00, 0);
		}
		*(INT*)((BYTE*)this_00 + 0x398) = param_4;
		// copy Location from param_1, Rotation from param_2
		*(FVector*)((BYTE*)this_00 + 0x234) = *param_1;
		*(FRotator*)((BYTE*)this_00 + 0x240) = *param_2;
		// clear dirty bit, set active bit
		*(DWORD*)((BYTE*)this_00 + 0xa0) &= ~2u;
		*(DWORD*)((BYTE*)this_00 + 0x51c) |= 1;
		// set texture
		*(UTexture**)((BYTE*)this_00 + 0x3a4) = param_3;
		if (param_8 != 0.0f)
			*(FLOAT*)((BYTE*)this_00 + 0xe8) = param_8;

		// Handle by group type (this+0x394 = eDecalType byte)
		BYTE groupType = *(BYTE*)((BYTE*)this + 0x394);
		if (groupType == 3)
		{
			// TODO: blood decal extra processing (FName, scale)
		}
		if (groupType == 2)
		{
			// TODO: GIsNightmare check for nighttime scale (2.0f night, 0.3f day)
			// CORE_API extern UBOOL GIsNightmare;
			// float scale = GIsNightmare ? 2.0f : 0.3f;
			// AActor::SetDrawScale(this_00, scale);
		}
		if (groupType == 0)
		{
			// TODO: bullet decal life/randomness flags
		}
		// groupType == 1: TODO: smoke flag
		*(DWORD*)((BYTE*)this_00 + 0x3a0) ^= (param_9 << 0x11 ^ *(DWORD*)((BYTE*)this_00 + 0x3a0)) & 0x20000;
		typedef void (__fastcall *FVtFn0)(void*, void*);
		(*(FVtFn0*)((BYTE*)**(INT**)this_00 + 0x184))(this_00, 0);
		*(INT*)(*(INT*)((BYTE*)this_00 + 0x48c) + 0x14) = 0;
		if (param_5 != 0.0f)
		{
			// TODO: FUN_10301000 — timer/time helper for decal lifetime
			// DOUBLE fVar5 = FUN_10301000();
			// *(DOUBLE*)(*(INT*)((BYTE*)this_00 + 0x48c) + 0xc) = (fVar5 + param_5) - param_6;
			// *(FLOAT*)(*(INT*)((BYTE*)this_00 + 0x48c) + 0x14) = param_5;
		}
		INT iVar3 = *(INT*)((BYTE*)this + 0x39c);
		*(INT*)((BYTE*)this + 0x39c) = iVar3 + 1;
		if (*(INT*)((BYTE*)this + 0x398) <= iVar3 + 1)
			*(INT*)((BYTE*)this + 0x39c) = 0;
		return 1;
	}
	return 0;
	unguard;
}


// --- AR6DecalManager ---
void AR6DecalManager::Spawned()
{
	guard(AR6DecalManager::Spawned);
	unguard;
}

int AR6DecalManager::AddDecal(FVector* param_1, FRotator* param_2, UTexture* param_3, eDecalType param_4,
	int param_5, float param_6, float param_7, float param_8, float param_9, int param_10)
{
	guard(AR6DecalManager::AddDecal);
	DWORD uVar4 = 1;

	if (param_4 == 1)
	{
		// Distance/angle culling for type-1 (bullet) decals.
		// TODO: viewport access via GEngine->Client->Viewports[0], FRotator::Vector forward,
		// dot product against camera forward, global counters DAT_1079dedc/DAT_1079ded8/DAT_1079ded4,
		// GUseCullDistanceProjector check and FVector::SizeSquared distance cull.
	}

	// this+0x394 = active flag
	if ((*(BYTE*)((BYTE*)this + 0x394) & 1) != 0)
	{
		AR6DecalGroup* this_00 = FindGroup(param_4);
		if (this_00 != NULL)
		{
			this_00->AddDecal(param_1, param_2, param_3, param_5,
				param_6, param_7, param_8, param_9, param_10);
			return uVar4;
		}
	}
	return 0;
	unguard;
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
int AR6DecalsBase::IsNetRelevantFor(APlayerController* param_1, AActor* param_2, FVector param_3)
{
	guard(AR6DecalsBase::IsNetRelevantFor);
	// param_1 + 0x3d8 = PlayerController's Pawn
	INT* pPawn = (INT*)*(INT*)((BYTE*)param_1 + 0x3d8);
	if (pPawn == NULL)
		return 0;

	// pawn's zone (pawn+0x228 = Region.Zone) team byte at zone+0x397
	BYTE bVar1 = *(BYTE*)(*(INT*)((BYTE*)pPawn + 0x228) + 0x397);
	// this zone team byte
	DWORD uVar3 = (DWORD)*(BYTE*)(*(INT*)((BYTE*)this + 0x228) + 0x397);

	if (uVar3 != (DWORD)bVar1)
	{
		DWORD uVar2 = 1u << (bVar1 & 0x1f);
		// this+0x144 = Level; zone visibility table at Level+0x650/+0x654
		INT* pLevel = *(INT**)((BYTE*)this + 0x144);
		if ((uVar2 & *(DWORD*)((BYTE*)pLevel + 0x650 + uVar3 * 8)) == 0 &&
			((INT)uVar2 >> 0x1f & *(DWORD*)((BYTE*)pLevel + 0x654 + uVar3 * 8)) == 0)
			return 0;
	}
	return 1;
	unguard;
}


// --- AR6EngineWeapon ---
int AR6EngineWeapon::GetHeartBeatStatus()
{
	// Verified from Ghidra: shared stub at 0x114310 — just returns 0.
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
	// Verified from Ghidra: shared stub at 0x114310 — just returns 0.
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
	// Verified from Ghidra: shared stub at 0x114310 — just returns 0.
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
	// Verified from Ghidra: shared stub at 0x114310 — just returns NULL.
	return NULL;
}


// --- UR6FileManager ---
int UR6FileManager::FindFile(FString* param_1)
{
	guard(UR6FileManager::FindFile);
	// GFileManager vtable slot 1 (+4 bytes) = CreateFileReader
	const TCHAR* puVar1 = **param_1;
	typedef void* (__fastcall *FCreateReaderFn)(void*, void*, const TCHAR*, INT, INT);
	INT* vtbl = *(INT**)GFileManager;
	FCreateReaderFn createReader = *(FCreateReaderFn*)((BYTE*)vtbl + 4);
	INT* piVar2 = (INT*)createReader(GFileManager, 0, puVar1, 0, 0);
	if (piVar2 != NULL)
	{
		INT* objVtbl = (INT*)*piVar2;
		// vtable[0x4c/4 = 19]: close/release
		typedef void (__fastcall *FCloseFn)(void*, void*);
		FCloseFn closeFn = *(FCloseFn*)((BYTE*)objVtbl + 0x4c);
		closeFn(piVar2, 0);
		// vtable[0]: destructor (arg = 1 to free memory)
		typedef void (__fastcall *FDestructFn)(void*, void*, INT);
		FDestructFn destructFn = *(FDestructFn*)objVtbl;
		destructFn(piVar2, 0, 1);
		return 1;
	}
	return 0;
	unguard;
}

void UR6FileManager::GetFileName(int param_1, FString* param_2)
{
	guard(UR6FileManager::GetFileName);
	// this+0x2c is the Data pointer of a TArray of FStrings (12 bytes each).
	FString* elem = (FString*)(*(INT*)((BYTE*)this + 0x2c) + param_1 * 0xc);
	*param_2 = elem->Caps();
	unguard;
}

int UR6FileManager::GetNbFile(FString* param_1, FString* param_2)
{
	guard(UR6FileManager::GetNbFile);
	// TODO: FUN_1031f060, FUN_103217e0, FUN_1031efc0 — string/path helpers
	// Builds search pattern from param_1 (dir) + param_2 (ext, adds "*." prefix if no wildcard)
	// Calls GFileManager->FindFiles(pattern) to count matching files
	// Returns count stored in this's TArray<FString> at +0x2c
	return 0;
	unguard;
}


// ============================================================================
// UR6AbstractTerroristMgr constructor
// (moved from EngineStubs.cpp)
// ============================================================================

// ??0UR6AbstractTerroristMgr@@QAE@XZ
UR6AbstractTerroristMgr::UR6AbstractTerroristMgr() {}

// --- Moved from EngineStubs.cpp ---
AR6AbstractClimbableObj::AR6AbstractClimbableObj() {}
