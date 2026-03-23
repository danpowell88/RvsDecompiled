/*=============================================================================
	R6AbstractGameService.cpp
=============================================================================*/

#include "R6AbstractPrivate.h"

IMPLEMENT_CLASS(UR6AbstractGameService)

IMPLEMENT_FUNCTION(UR6AbstractGameService, -1, execNativeSubmitMatchResult)

// --- UR6AbstractGameService ---

IMPL_EMPTY("retail: empty")
void UR6AbstractGameService::Created() {}
IMPL_EMPTY("retail: empty")
void UR6AbstractGameService::DisconnectAllCDKeyPlayers() {}
IMPL_EMPTY("retail: empty")
void UR6AbstractGameService::RequestGSCDKeyAuthID() {}
IMPL_EMPTY("retail: empty")
void UR6AbstractGameService::ResetAuthId() {}
IMPL_EMPTY("retail: empty")
void UR6AbstractGameService::ServerRoundFinish() {}
IMPL_EMPTY("retail: empty")
void UR6AbstractGameService::SubmitMatchResult() {}
IMPL_MATCH("R6Abstract.dll", 0x10002d40)
void UR6AbstractGameService::UnInitializeGSClientSPW() {}

IMPL_EMPTY("retail: empty")
INT UR6AbstractGameService::GetGroupID()              { return 0; } // retail: empty
IMPL_EMPTY("retail: empty")
INT UR6AbstractGameService::GetLobbyID()              { return 0; } // retail: empty
IMPL_EMPTY("retail: empty")
INT UR6AbstractGameService::GetLoggedInUbiDotCom()    { return 0; } // retail: empty
IMPL_EMPTY("retail: empty")
INT UR6AbstractGameService::GetRegServerInitialized() { return 0; } // retail: empty
IMPL_EMPTY("retail: empty")
INT UR6AbstractGameService::GetServerRegistered()     { return 0; } // retail: empty
IMPL_EMPTY("retail: empty")
INT UR6AbstractGameService::InitGSCDKey()             { return 0; } // retail: empty
IMPL_EMPTY("retail: empty")
INT UR6AbstractGameService::InitGSClient()            { return 0; } // retail: empty
IMPL_EMPTY("retail: empty")
INT UR6AbstractGameService::IsMSClientIsInRequest()   { return 0; } // retail: empty
IMPL_EMPTY("retail: empty")
INT UR6AbstractGameService::IsServerJoined()          { return 0; } // retail: empty
IMPL_EMPTY("retail: empty")
INT UR6AbstractGameService::MSCLientLeaveServer()     { return 0; } // retail: empty
IMPL_MATCH("R6Abstract.dll", 0x10002cf0)
INT UR6AbstractGameService::SetGSClientComInterface() { return 0; } // retail: empty

IMPL_EMPTY("retail: empty")
void UR6AbstractGameService::GSClientPostMessage(BYTE) {}
IMPL_EMPTY("retail: empty")
void UR6AbstractGameService::ProcessIsLobbyDisconnect(FLOAT*) {}
IMPL_EMPTY("retail: empty")
void UR6AbstractGameService::ProcessIsRouterDisconnect(FLOAT*) {}
IMPL_EMPTY("retail: empty")
void UR6AbstractGameService::ProcessJoinServer(FLOAT*) {}
IMPL_EMPTY("retail: empty")
void UR6AbstractGameService::RequestModCDKeyProcess(INT) {}
IMPL_EMPTY("retail: empty")
void UR6AbstractGameService::ServerRoundStart(INT) {}
IMPL_EMPTY("retail: empty")
void UR6AbstractGameService::SetGSGameState(BYTE) {}
IMPL_EMPTY("retail: empty")
void UR6AbstractGameService::SetGameServiceRequestState(BYTE) {}
IMPL_EMPTY("retail: empty")
void UR6AbstractGameService::SetLoginRegServer(BYTE) {}
IMPL_EMPTY("retail: empty")
void UR6AbstractGameService::SetOwnSvrPort(INT) {}
IMPL_MATCH("R6Abstract.dll", 0x10002d20)
void UR6AbstractGameService::SetRegServerLoginRequest(BYTE) {}
IMPL_EMPTY("retail: empty")
BYTE UR6AbstractGameService::GetGSGameState()     { return 0; } // retail: empty
IMPL_MATCH("R6Abstract.dll", 0x10002ce0)
BYTE UR6AbstractGameService::GetLoginRegServer()  { return 0; } // retail: empty

IMPL_TODO("retail: empty - retail has 13B at 0x10002d00")
void UR6AbstractGameService::CDKeyDisconnecUser(FString) {}
IMPL_MATCH("R6Abstract.dll", 0x100028d0)
void UR6AbstractGameService::GameServiceManager(INT, INT, INT, INT) {}
IMPL_EMPTY("retail: empty")
void UR6AbstractGameService::MasterServerManager(AR6AbstractGameInfo*, ALevelInfo*) {}
IMPL_MATCH("R6Abstract.dll", 0x10002d30)
void UR6AbstractGameService::ProcessLoginMasterSrv(INT, FLOAT*) {}
IMPL_TODO("retail: empty - retail has 13B at 0x10002d10")
void UR6AbstractGameService::ProcessUbiComJoinServer(INT, INT, FString, FLOAT*) {}
IMPL_TODO("retail: empty - retail has 34B at 0x10002d50")
FString UR6AbstractGameService::GetAuthID(INT) { return TEXT(""); }

IMPL_TODO("exec thunk for intentionally empty native - retail has 107B at 0x10003420")
void UR6AbstractGameService::execNativeSubmitMatchResult(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
