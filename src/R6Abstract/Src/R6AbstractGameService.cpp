/*=============================================================================
	R6AbstractGameService.cpp
	UR6AbstractGameService, UR6AbstractEviLPatchService — abstract game
	service base classes for master server, CD key, and lobby management.
=============================================================================*/

#include "R6AbstractPrivate.h"

IMPLEMENT_CLASS(UR6AbstractEviLPatchService)
IMPLEMENT_CLASS(UR6AbstractGameService)

IMPLEMENT_FUNCTION(UR6AbstractEviLPatchService, -1, execGetState)
IMPLEMENT_FUNCTION(UR6AbstractGameService, -1, execNativeSubmitMatchResult)

/*-----------------------------------------------------------------------------
	UR6AbstractGameService
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
	The End.
-----------------------------------------------------------------------------*/
