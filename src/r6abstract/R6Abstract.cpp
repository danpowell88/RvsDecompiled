/*=============================================================================
	R6Abstract.cpp: R6Abstract package — abstract base classes for R6 game.
	Reconstructed for Ravenshield decompilation project.

	13 classes, 207 exports. Smallest R6 module — foundation for all
	game-specific code (R6Weapons, R6Engine, R6Game, R6GameService).
=============================================================================*/

#include "R6AbstractPrivate.h"

/*-----------------------------------------------------------------------------
	Package.
-----------------------------------------------------------------------------*/

IMPLEMENT_PACKAGE(R6Abstract)

/*-----------------------------------------------------------------------------
	FName event/callback tokens.
-----------------------------------------------------------------------------*/

#define NAMES_ONLY
#define AUTOGENERATE_NAME(name) R6ABSTRACT_API FName R6ABSTRACT_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)
#include "R6AbstractClasses.h"
#undef AUTOGENERATE_FUNCTION
#undef AUTOGENERATE_NAME
#undef NAMES_ONLY

/*-----------------------------------------------------------------------------
	IMPLEMENT_CLASS for all 13 exported classes.
	Order matches the autoclass ordinals in the retail DLL.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(AR6AbstractBullet)
IMPLEMENT_CLASS(AR6AbstractCorpse)
IMPLEMENT_CLASS(AR6AbstractExtractionZone)
IMPLEMENT_CLASS(AR6AbstractFirstPersonWeapon)
IMPLEMENT_CLASS(AR6AbstractGadget)
IMPLEMENT_CLASS(AR6AbstractGameInfo)
IMPLEMENT_CLASS(AR6AbstractHUD)
IMPLEMENT_CLASS(AR6AbstractInsertionZone)
IMPLEMENT_CLASS(AR6AbstractPawn)
IMPLEMENT_CLASS(AR6AbstractWeapon)
IMPLEMENT_CLASS(UR6AbstractEviLPatchService)
IMPLEMENT_CLASS(UR6AbstractGameService)
IMPLEMENT_CLASS(UR6AbstractNoiseMgr)

/*-----------------------------------------------------------------------------
	Native function exports (IMPLEMENT_FUNCTION).
	Native indices are stored as intXXX exports. All are dispatched
	by name (INDEX_NONE / -1) in R6Abstract.
-----------------------------------------------------------------------------*/

IMPLEMENT_FUNCTION(AR6AbstractCorpse, -1, execAddImpulseToBone)
IMPLEMENT_FUNCTION(AR6AbstractCorpse, -1, execFirstInit)
IMPLEMENT_FUNCTION(AR6AbstractCorpse, -1, execRenderBones)
IMPLEMENT_FUNCTION(UR6AbstractEviLPatchService, -1, execGetState)
IMPLEMENT_FUNCTION(UR6AbstractGameService, -1, execNativeSubmitMatchResult)

/*-----------------------------------------------------------------------------
	UR6AbstractGameService — virtual method stubs.
	Most virtuals in the base class are empty or return 0/false.
	Derived classes (in R6GameService.dll) override with real logic.
-----------------------------------------------------------------------------*/

void UR6AbstractGameService::Created() {}
void UR6AbstractGameService::DisconnectAllCDKeyPlayers() {}
void UR6AbstractGameService::RequestGSCDKeyAuthID() {}
void UR6AbstractGameService::ResetAuthId() {}
void UR6AbstractGameService::ServerRoundFinish() {}
void UR6AbstractGameService::SubmitMatchResult() {}
void UR6AbstractGameService::UnInitializeGSClientSPW() {}

INT UR6AbstractGameService::GetGroupID()              { return 0; }
INT UR6AbstractGameService::GetLobbyID()              { return 0; }
INT UR6AbstractGameService::GetLoggedInUbiDotCom()    { return 0; }
INT UR6AbstractGameService::GetRegServerInitialized() { return 0; }
INT UR6AbstractGameService::GetServerRegistered()     { return 0; }
INT UR6AbstractGameService::InitGSCDKey()             { return 0; }
INT UR6AbstractGameService::InitGSClient()            { return 0; }
INT UR6AbstractGameService::IsMSClientIsInRequest()   { return 0; }
INT UR6AbstractGameService::IsServerJoined()          { return 0; }
INT UR6AbstractGameService::MSCLientLeaveServer()     { return 0; }
INT UR6AbstractGameService::SetGSClientComInterface() { return 0; }

void UR6AbstractGameService::GSClientPostMessage(BYTE) {}
void UR6AbstractGameService::ProcessIsLobbyDisconnect(FLOAT*) {}
void UR6AbstractGameService::ProcessIsRouterDisconnect(FLOAT*) {}
void UR6AbstractGameService::ProcessJoinServer(FLOAT*) {}
void UR6AbstractGameService::RequestModCDKeyProcess(INT) {}
void UR6AbstractGameService::ServerRoundStart(INT) {}
void UR6AbstractGameService::SetGSGameState(BYTE) {}
void UR6AbstractGameService::SetGameServiceRequestState(BYTE) {}
void UR6AbstractGameService::SetLoginRegServer(BYTE) {}
void UR6AbstractGameService::SetOwnSvrPort(INT) {}
void UR6AbstractGameService::SetRegServerLoginRequest(BYTE) {}
BYTE UR6AbstractGameService::GetGSGameState()     { return 0; }
BYTE UR6AbstractGameService::GetLoginRegServer()  { return 0; }

void UR6AbstractGameService::CDKeyDisconnecUser(FString) {}
void UR6AbstractGameService::GameServiceManager(INT, INT, INT, INT) {}
void UR6AbstractGameService::MasterServerManager(AR6AbstractGameInfo*, ALevelInfo*) {}
void UR6AbstractGameService::ProcessLoginMasterSrv(INT, FLOAT*) {}
void UR6AbstractGameService::ProcessUbiComJoinServer(INT, INT, FString, FLOAT*) {}
FString UR6AbstractGameService::GetAuthID(INT) { return TEXT(""); }

void UR6AbstractGameService::execNativeSubmitMatchResult(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	UR6AbstractEviLPatchService
-----------------------------------------------------------------------------*/

// Global callback pointer stored by SetFunctionPtr, read by execGetState.
// Ghidra: DAT_10010df0 — static storage, not a class member.
static DWORD (CDECL* GEviLPatchCallback)(void) = NULL;

void UR6AbstractEviLPatchService::SetFunctionPtr(DWORD (CDECL* Func)(void))
{
	GEviLPatchCallback = Func;
}

void UR6AbstractEviLPatchService::execGetState(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	if (GEviLPatchCallback != NULL)
		*(DWORD*)Result = GEviLPatchCallback();
	else
		*(DWORD*)Result = 0;
}

/*-----------------------------------------------------------------------------
	AR6AbstractExtractionZone / AR6AbstractInsertionZone
-----------------------------------------------------------------------------*/

void AR6AbstractExtractionZone::CheckForErrors()
{
	Super::CheckForErrors();
}

void AR6AbstractInsertionZone::CheckForErrors()
{
	Super::CheckForErrors();
}

/*-----------------------------------------------------------------------------
	AR6AbstractCorpse
-----------------------------------------------------------------------------*/

void AR6AbstractCorpse::FirstInit(AR6AbstractPawn*) {}
void AR6AbstractCorpse::RenderBones(UCanvas*) {}
void AR6AbstractCorpse::AddImpulseToBone(INT, FVector) {}

void AR6AbstractCorpse::execAddImpulseToBone(FFrame& Stack, RESULT_DECL)
{
	P_GET_INT(iTracedBone);
	P_GET_STRUCT(FVector, vMomentum);
	P_FINISH;
	AddImpulseToBone(iTracedBone, vMomentum);
}

void AR6AbstractCorpse::execFirstInit(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AR6AbstractPawn, pawnOwner);
	P_FINISH;
	FirstInit(pawnOwner);
}

void AR6AbstractCorpse::execRenderBones(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(UCanvas, C);
	P_FINISH;
	RenderBones(C);
}

/*-----------------------------------------------------------------------------
	AR6AbstractGadget
-----------------------------------------------------------------------------*/

INT* AR6AbstractGadget::GetOptimizedRepList(BYTE* Recent, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Channel)
{
	return Super::GetOptimizedRepList(Recent, Retire, Ptr, Map, Channel);
}

/*-----------------------------------------------------------------------------
	AR6AbstractWeapon
-----------------------------------------------------------------------------*/

void AR6AbstractWeapon::PreNetReceive()
{
	Super::PreNetReceive();
}

void AR6AbstractWeapon::PostNetReceive()
{
	Super::PostNetReceive();
}

void AR6AbstractWeapon::eventSpawnSelectedGadget()
{
	ProcessEvent(FindFunctionChecked(R6ABSTRACT_SpawnSelectedGadget), NULL);
}

/*-----------------------------------------------------------------------------
	AR6AbstractPawn
-----------------------------------------------------------------------------*/

FLOAT AR6AbstractPawn::eventGetSkill(BYTE eSkillName)
{
	struct { BYTE eSkillName; FLOAT ReturnValue; } Parms;
	Parms.eSkillName = eSkillName;
	Parms.ReturnValue = 0.f;
	ProcessEvent(FindFunctionChecked(R6ABSTRACT_GetSkill), &Parms);
	return Parms.ReturnValue;
}

/*-----------------------------------------------------------------------------
	UR6AbstractNoiseMgr
-----------------------------------------------------------------------------*/

void UR6AbstractNoiseMgr::eventR6MakeNoise(BYTE eType, AActor* Source)
{
	struct { BYTE eType; AActor* Source; } Parms;
	Parms.eType = eType;
	Parms.Source = Source;
	ProcessEvent(FindFunctionChecked(R6ABSTRACT_R6MakeNoise), &Parms);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
