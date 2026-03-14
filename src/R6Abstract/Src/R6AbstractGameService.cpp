/*=============================================================================
	R6AbstractGameService.cpp
=============================================================================*/

#include "R6AbstractPrivate.h"

IMPLEMENT_CLASS(UR6AbstractGameService)

IMPLEMENT_FUNCTION(UR6AbstractGameService, -1, execNativeSubmitMatchResult)

// --- UR6AbstractGameService ---

IMPL_INTENTIONALLY_EMPTY("retail: empty")
void UR6AbstractGameService::Created() {}
IMPL_INTENTIONALLY_EMPTY("retail: empty")
void UR6AbstractGameService::DisconnectAllCDKeyPlayers() {}
IMPL_INTENTIONALLY_EMPTY("retail: empty")
void UR6AbstractGameService::RequestGSCDKeyAuthID() {}
IMPL_INTENTIONALLY_EMPTY("retail: empty")
void UR6AbstractGameService::ResetAuthId() {}
IMPL_INTENTIONALLY_EMPTY("retail: empty")
void UR6AbstractGameService::ServerRoundFinish() {}
IMPL_INTENTIONALLY_EMPTY("retail: empty")
void UR6AbstractGameService::SubmitMatchResult() {}
IMPL_INTENTIONALLY_EMPTY("retail: empty")
void UR6AbstractGameService::UnInitializeGSClientSPW() {}

IMPL_INTENTIONALLY_EMPTY("retail: empty")
INT UR6AbstractGameService::GetGroupID()              { return 0; } // retail: empty
IMPL_INTENTIONALLY_EMPTY("retail: empty")
INT UR6AbstractGameService::GetLobbyID()              { return 0; } // retail: empty
IMPL_INTENTIONALLY_EMPTY("retail: empty")
INT UR6AbstractGameService::GetLoggedInUbiDotCom()    { return 0; } // retail: empty
IMPL_INTENTIONALLY_EMPTY("retail: empty")
INT UR6AbstractGameService::GetRegServerInitialized() { return 0; } // retail: empty
IMPL_INTENTIONALLY_EMPTY("retail: empty")
INT UR6AbstractGameService::GetServerRegistered()     { return 0; } // retail: empty
IMPL_INTENTIONALLY_EMPTY("retail: empty")
INT UR6AbstractGameService::InitGSCDKey()             { return 0; } // retail: empty
IMPL_INTENTIONALLY_EMPTY("retail: empty")
INT UR6AbstractGameService::InitGSClient()            { return 0; } // retail: empty
IMPL_INTENTIONALLY_EMPTY("retail: empty")
INT UR6AbstractGameService::IsMSClientIsInRequest()   { return 0; } // retail: empty
IMPL_INTENTIONALLY_EMPTY("retail: empty")
INT UR6AbstractGameService::IsServerJoined()          { return 0; } // retail: empty
IMPL_INTENTIONALLY_EMPTY("retail: empty")
INT UR6AbstractGameService::MSCLientLeaveServer()     { return 0; } // retail: empty
IMPL_INTENTIONALLY_EMPTY("retail: empty")
INT UR6AbstractGameService::SetGSClientComInterface() { return 0; } // retail: empty

IMPL_INTENTIONALLY_EMPTY("retail: empty")
void UR6AbstractGameService::GSClientPostMessage(BYTE) {}
IMPL_INTENTIONALLY_EMPTY("retail: empty")
void UR6AbstractGameService::ProcessIsLobbyDisconnect(FLOAT*) {}
IMPL_INTENTIONALLY_EMPTY("retail: empty")
void UR6AbstractGameService::ProcessIsRouterDisconnect(FLOAT*) {}
IMPL_INTENTIONALLY_EMPTY("retail: empty")
void UR6AbstractGameService::ProcessJoinServer(FLOAT*) {}
IMPL_INTENTIONALLY_EMPTY("retail: empty")
void UR6AbstractGameService::RequestModCDKeyProcess(INT) {}
IMPL_INTENTIONALLY_EMPTY("retail: empty")
void UR6AbstractGameService::ServerRoundStart(INT) {}
IMPL_INTENTIONALLY_EMPTY("retail: empty")
void UR6AbstractGameService::SetGSGameState(BYTE) {}
IMPL_INTENTIONALLY_EMPTY("retail: empty")
void UR6AbstractGameService::SetGameServiceRequestState(BYTE) {}
IMPL_INTENTIONALLY_EMPTY("retail: empty")
void UR6AbstractGameService::SetLoginRegServer(BYTE) {}
IMPL_INTENTIONALLY_EMPTY("retail: empty")
void UR6AbstractGameService::SetOwnSvrPort(INT) {}
IMPL_INTENTIONALLY_EMPTY("retail: empty")
void UR6AbstractGameService::SetRegServerLoginRequest(BYTE) {}
IMPL_INTENTIONALLY_EMPTY("retail: empty")
BYTE UR6AbstractGameService::GetGSGameState()     { return 0; } // retail: empty
IMPL_INTENTIONALLY_EMPTY("retail: empty")
BYTE UR6AbstractGameService::GetLoginRegServer()  { return 0; } // retail: empty

IMPL_INTENTIONALLY_EMPTY("retail: empty")
void UR6AbstractGameService::CDKeyDisconnecUser(FString) {}
IMPL_INTENTIONALLY_EMPTY("retail: empty")
void UR6AbstractGameService::GameServiceManager(INT, INT, INT, INT) {}
IMPL_INTENTIONALLY_EMPTY("retail: empty")
void UR6AbstractGameService::MasterServerManager(AR6AbstractGameInfo*, ALevelInfo*) {}
IMPL_INTENTIONALLY_EMPTY("retail: empty")
void UR6AbstractGameService::ProcessLoginMasterSrv(INT, FLOAT*) {}
IMPL_INTENTIONALLY_EMPTY("retail: empty")
void UR6AbstractGameService::ProcessUbiComJoinServer(INT, INT, FString, FLOAT*) {}
IMPL_INTENTIONALLY_EMPTY("retail: empty")
FString UR6AbstractGameService::GetAuthID(INT) { return TEXT(""); }

IMPL_INTENTIONALLY_EMPTY("exec thunk for intentionally empty native")
void UR6AbstractGameService::execNativeSubmitMatchResult(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
