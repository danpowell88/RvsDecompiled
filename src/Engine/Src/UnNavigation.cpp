#pragma optimize("", off)
#include "EnginePrivate.h"
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


// --- ALadder ---
void ALadder::addReachSpecs(APawn *,int)
{
}

int ALadder::ProscribedPathTo(ANavigationPoint * Nav)
{
	// Ghidra 0xd7130, 131B: if Nav is ALadder with same MyLadder ptr, proscribed
	if (Nav)
	{
		if (Nav->IsA(ALadder::StaticClass()))
		{
			if (*(INT*)((BYTE*)this + 0x3E8) == *(INT*)((BYTE*)Nav + 0x3E8))
				return 1;
		}
	}
	return ANavigationPoint::ProscribedPathTo(Nav);
}

void ALadder::ClearPaths()
{
	// Ghidra 0xd6a60, 90B: call base, clear ladder reference, zero pointers
	ANavigationPoint::ClearPaths();
	INT* MyLadder = (INT*)((BYTE*)this + 0x3E8);
	if (*MyLadder != 0)
		*(INT*)(*MyLadder + 0x47c) = 0;
	*(INT*)((BYTE*)this + 0x3ec) = 0;
	*MyLadder = 0;
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


// --- ANote ---
void ANote::CheckForErrors()
{
	// Ghidra 0x980f0: log the Note text via GWarn, then call super.
	FString& noteStr = *(FString*)((BYTE*)this + 0x394);
	GWarn->Logf(TEXT("%s"), *noteStr);
	AActor::CheckForErrors();
}


// --- APathNode ---
int APathNode::ReviewPath(APawn *)
{
	return 0;
}

void APathNode::CheckSymmetry(ANavigationPoint *)
{
}



// --- APlayerStart ---
void APlayerStart::addReachSpecs(APawn *,int)
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
	// Retail: 0xfc9b0, ordinal 3354. Initialises the scout's pathfinding state:
	// - Sets BYTE at this+0x2C to 1 (bPathfinding flag)
	// - Sets this+0x43C = 0x43D20000 (FLOAT 424.0f — max step height)
	// - Sets this+0x3E0 = (existing value & ~0x00020000) | 0x0005C000 (reach flags)
	// - Sets this+0x428 = 0x44160000 (FLOAT 600.0f — jump Z velocity)
	// - Sets this+0x44C = 0x44138000 (FLOAT 590.0f — ground speed)
	*(BYTE*)((BYTE*)this + 0x2C) = 1;
	*(DWORD*)((BYTE*)this + 0x43C) = 0x43D20000;  // 424.0f
	*(DWORD*)((BYTE*)this + 0x3E0) = (*(DWORD*)((BYTE*)this + 0x3E0) & ~0x00020000u) | 0x0005C000u;
	*(DWORD*)((BYTE*)this + 0x428) = 0x44160000;  // 600.0f
	*(DWORD*)((BYTE*)this + 0x44C) = 0x44138000;  // 590.0f
}



// =============================================================================
// ANavigationPoint (moved from EngineClassImpl.cpp)
// =============================================================================

// ANavigationPoint
// =============================================================================

void ANavigationPoint::Destroy() { Super::Destroy(); }
void ANavigationPoint::PostEditMove() {}
void ANavigationPoint::Spawned()
{
	// Retail (27b, RVA 0xD5B50): clear bit 11 (bPathsChanged) of Zone's flags at +0x450,
	// then mark our own bPathsChanged = 1.
	AZoneInfo* Z = Region.Zone;
	*(DWORD*)((BYTE*)Z + 0x450) &= ~0x800u;
	bPathsChanged = 1;
}
void ANavigationPoint::InitForPathFinding() {}
void ANavigationPoint::CheckSymmetry(ANavigationPoint* Other) {}
void ANavigationPoint::PostaddReachSpecs(APawn* Scout) {}
void ANavigationPoint::SetVolumes(const TArray<AVolume*>& Volumes) {}
void ANavigationPoint::CheckForErrors() { Super::CheckForErrors(); }
INT ANavigationPoint::ProscribedPathTo(ANavigationPoint* Nav) { return 0; }
void ANavigationPoint::addReachSpecs(APawn* Scout, INT bOnlyChanged) {}
void ANavigationPoint::SetupForcedPath(APawn* Scout, UReachSpec* Spec) {}
void ANavigationPoint::ClearPaths()
{
	// Retail: 104b SEH. Zeros the 4 path-chain pointer fields, then empties PathList.
	// PathList confirmed at this+0x3D8 via disassembly; chain ptrs from +0x3A8.
	nextNavigationPoint = NULL;
	nextOrdered         = NULL;
	prevOrdered         = NULL;
	previousPath        = NULL;
	((TArray<UReachSpec*>*)((BYTE*)this + 0x3D8))->Empty();
}
void ANavigationPoint::FindBase() {}
INT ANavigationPoint::PrunePaths() { return 0; }
INT ANavigationPoint::IsIdentifiedAs(FName Name) { return 0; }
INT ANavigationPoint::ReviewPath(APawn* Scout) { return 0; }
INT ANavigationPoint::CanReach(ANavigationPoint* Nav, FLOAT Dist) { return 0; }
void ANavigationPoint::CleanUpPruned()
{
	// Retail: 124b SEH. Iterates PathList backwards, removing specs with bPruned set.
	// Finishes with TArray::Shrink to release excess memory.
	TArray<UReachSpec*>* myPathList = (TArray<UReachSpec*>*)((BYTE*)this + 0x3D8);
	for (INT i = myPathList->Num() - 1; i >= 0; i--)
	{
		UReachSpec* Spec = (*myPathList)(i);
		if (Spec && Spec->bPruned)
			myPathList->Remove(i, 1);
	}
	myPathList->Shrink();
}
INT ANavigationPoint::FindAlternatePath(UReachSpec* Spec, INT bOnlyChanged) { return 0; }
UReachSpec* ANavigationPoint::GetReachSpecTo(ANavigationPoint* Nav)
{
	// Retail: 103b SEH. Linear scan of PathList (at this+0x3D8) for spec->End == Nav.
	TArray<UReachSpec*>* myPathList = (TArray<UReachSpec*>*)((BYTE*)this + 0x3D8);
	for (INT i = 0; i < myPathList->Num(); i++)
	{
		UReachSpec* Spec = (*myPathList)(i);
		if (Spec->End == Nav)
			return Spec;
	}
	return NULL;
}
INT ANavigationPoint::ShouldBeBased()
{
	// Retail: 32b (JNZ at +24 uses shared return-0 epilog 3 bytes past function end).
	// Check the object at this+0x164 (Level): if [Level+0x410] bit 6 is set => always base nav point.
	// Otherwise check bNotBased (bit 10 of bitfield DWORD at this+0x3A4): if set => return 0.
	BYTE* levelObj = *(BYTE**)((BYTE*)this + 0x164);
	if (*(BYTE*)(levelObj + 0x410) & 0x40)
		return 1;
	return bNotBased ? 0 : 1;
}

/*-- UInteraction screen/world transforms ------------------------------*/

void UInteraction::execScreenToWorld( FFrame& Stack, RESULT_DECL )
{
	guard(UInteraction::execScreenToWorld);
	P_GET_VECTOR(ScreenLoc);
	P_GET_VECTOR_REF(WorldLoc);
	P_FINISH;
	*WorldLoc = FVector(0,0,0);
	unguard;
}
IMPLEMENT_FUNCTION( UInteraction, INDEX_NONE, execScreenToWorld );

void UInteraction::execWorldToScreen( FFrame& Stack, RESULT_DECL )
{
	guard(UInteraction::execWorldToScreen);
	P_GET_VECTOR(WorldLoc);
	P_GET_VECTOR_REF(ScreenLoc);
	P_FINISH;
	*ScreenLoc = FVector(0,0,0);
	unguard;
}
IMPLEMENT_FUNCTION( UInteraction, INDEX_NONE, execWorldToScreen );

/*-- UInteractionMaster ------------------------------------------------*/

void UInteractionMaster::execTravel( FFrame& Stack, RESULT_DECL )
{
	guard(UInteractionMaster::execTravel);
	P_GET_STR(URL);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UInteractionMaster, INDEX_NONE, execTravel );

/*-- UR6AbstractGameManager -------------------------------------------*/

void UR6AbstractGameManager::execClientLeaveServer( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execClientLeaveServer);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execClientLeaveServer );

void UR6AbstractGameManager::execConnectionInterrupted( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execConnectionInterrupted);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execConnectionInterrupted );

void UR6AbstractGameManager::execIsGSCreateUbiServer( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execIsGSCreateUbiServer);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execIsGSCreateUbiServer );

void UR6AbstractGameManager::execLaunchListenSrv( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execLaunchListenSrv);
	P_GET_STR(URL);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execLaunchListenSrv );

void UR6AbstractGameManager::execSetGSCreateUbiServer( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execSetGSCreateUbiServer);
	P_GET_UBOOL(bCreate);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execSetGSCreateUbiServer );

void UR6AbstractGameManager::execStartJoinServer( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execStartJoinServer);
	P_GET_STR(URL);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execStartJoinServer );

void UR6AbstractGameManager::execStartLogInProcedure( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execStartLogInProcedure);
	P_GET_STR(Username);
	P_GET_STR(Password);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execStartLogInProcedure );

void UR6AbstractGameManager::execStartPreJoinProcedure( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execStartPreJoinProcedure);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execStartPreJoinProcedure );

void UR6AbstractGameManager::execStopGSClientProcedure( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execStopGSClientProcedure);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execStopGSClientProcedure );

/*-- UR6FileManager ----------------------------------------------------*/

void UR6FileManager::execDeleteFile( FFrame& Stack, RESULT_DECL )
{
	guard(UR6FileManager::execDeleteFile);
	P_GET_STR(Filename);
	P_FINISH;
	*(DWORD*)Result = GFileManager->Delete( *Filename );
	unguard;
}
IMPLEMENT_FUNCTION( UR6FileManager, 1527, execDeleteFile );

void UR6FileManager::execFindFile( FFrame& Stack, RESULT_DECL )
{
	guard(UR6FileManager::execFindFile);
	P_GET_STR(Pattern);
	P_FINISH;
	TArray<FString> Files = GFileManager->FindFiles( *Pattern, 1, 0 );
	*(INT*)Result = Files.Num();
	unguard;
}
IMPLEMENT_FUNCTION( UR6FileManager, 1528, execFindFile );

void UR6FileManager::execGetFileName( FFrame& Stack, RESULT_DECL )
{
	guard(UR6FileManager::execGetFileName);
	P_GET_INT(Index);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( UR6FileManager, 1526, execGetFileName );

void UR6FileManager::execGetNbFile( FFrame& Stack, RESULT_DECL )
{
	guard(UR6FileManager::execGetNbFile);
	P_FINISH;
	*(INT*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( UR6FileManager, 1525, execGetNbFile );

/*-- UR6ModMgr ---------------------------------------------------------*/

void UR6ModMgr::execAddNewModExtraPath( FFrame& Stack, RESULT_DECL )
{
	guard(UR6ModMgr::execAddNewModExtraPath);
	P_GET_STR(Path);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6ModMgr, 2020, execAddNewModExtraPath );

void UR6ModMgr::execCallSndEngineInit( FFrame& Stack, RESULT_DECL )
{
	guard(UR6ModMgr::execCallSndEngineInit);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6ModMgr, 3003, execCallSndEngineInit );

void UR6ModMgr::execGetASBuildVersion( FFrame& Stack, RESULT_DECL )
{
	guard(UR6ModMgr::execGetASBuildVersion);
	P_FINISH;
	*(FString*)Result = TEXT("1.60");
	unguard;
}
IMPLEMENT_FUNCTION( UR6ModMgr, INDEX_NONE, execGetASBuildVersion );

void UR6ModMgr::execGetIWBuildVersion( FFrame& Stack, RESULT_DECL )
{
	guard(UR6ModMgr::execGetIWBuildVersion);
	P_FINISH;
	*(FString*)Result = TEXT("1.60");
	unguard;
}
IMPLEMENT_FUNCTION( UR6ModMgr, INDEX_NONE, execGetIWBuildVersion );

void UR6ModMgr::execIsOfficialMod( FFrame& Stack, RESULT_DECL )
{
	guard(UR6ModMgr::execIsOfficialMod);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( UR6ModMgr, INDEX_NONE, execIsOfficialMod );

void UR6ModMgr::execSetGeneralModSettings( FFrame& Stack, RESULT_DECL )
{
	guard(UR6ModMgr::execSetGeneralModSettings);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6ModMgr, INDEX_NONE, execSetGeneralModSettings );

void UR6ModMgr::execSetSystemMod( FFrame& Stack, RESULT_DECL )
{
	guard(UR6ModMgr::execSetSystemMod);
	P_GET_STR(ModName);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6ModMgr, 2021, execSetSystemMod );

// =============================================================================
