/*=============================================================================
	R6GSServers.cpp: UR6GSServers — GameSpy / Ubi.com server browser integration.
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "R6GameServicePrivate.h"

IMPLEMENT_CLASS(UR6GSServers)

IMPLEMENT_FUNCTION(UR6GSServers, -1, execEnterCDKey)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execGetMaxUbiServerNameSize)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execHandleAnyLobbyConnectionFail)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execInitGSCDKey)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execInitialize)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execInitializeMSClient)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execIsRefreshServersInProgress)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execNativeGetMSClientInitialized)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execNativeGetSeconds)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execNativeIsGSReadyToChangeMod)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execNativeIsRouterDisconnect)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execNativeIsWaitingForGSInit)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execNativeLogOutServer)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execNativeMSCLientJoinServer)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execNativeMSClientReqAltInfo)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execNativeProcessIcmpPing)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execNativeSetMatchResult)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execNativeUpdateServer)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execRefreshOneServer)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execRefreshServers)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execSetLastServerQueried)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execStopRefreshServers)
IMPLEMENT_FUNCTION(UR6GSServers, -1, execUnInitializeMSClient)

// --- UR6GSServers ---

void UR6GSServers::AddPlayerToIDList(FString, FString, FString, INT)
{
}

void UR6GSServers::CDKeyDisconnecUser(FString)
{
}

INT UR6GSServers::CDKeyValidateUser(FString, INT, INT)
{
	return 0;
}

void UR6GSServers::CancelGSCDKeyActID()
{
}

void UR6GSServers::CancelGSCDKeyAuthID()
{
}

void UR6GSServers::CopyActivationIDInByteArray(BYTE *, BYTE *)
{
}

void UR6GSServers::CreatedCDKey()
{
}

void UR6GSServers::Destroy()
{
}

void UR6GSServers::DisconnectAllCDKeyPlayers()
{
}

void UR6GSServers::EnterCDKey(FString)
{
}

void UR6GSServers::GSClientPostMessage(BYTE)
{
}

void UR6GSServers::GSClientUpdateServerInfo()
{
}

void UR6GSServers::GameServiceManager(INT, INT, INT, INT)
{
}

FString UR6GSServers::GetAuthID(INT)
{
	return TEXT("");
}

BYTE UR6GSServers::GetGSGameState()
{
	return 0;
}

FString UR6GSServers::GetGlobalIdFromPlayerIDList(FString)
{
	return TEXT("");
}

INT UR6GSServers::GetLoggedInUbiDotCom()
{
	return 0;
}

BYTE UR6GSServers::GetLoginRegServer()
{
	return 0;
}

INT UR6GSServers::GetRegServerInitialized()
{
	return 0;
}

INT UR6GSServers::GetServerRegistered()
{
	return 0;
}

void UR6GSServers::Init(FString)
{
}

void UR6GSServers::InitCDKey(INT, INT)
{
}

INT UR6GSServers::InitGSCDKey()
{
	return 0;
}

INT UR6GSServers::InitGSClient()
{
	return 0;
}

void UR6GSServers::InitMSClient()
{
}

void UR6GSServers::InitProcessUpdateUbiServer(AGameInfo *, ALevelInfo *)
{
}

INT UR6GSServers::InitializeMSClient()
{
	return 0;
}

INT UR6GSServers::InitializeRegServer()
{
	return 0;
}

INT UR6GSServers::IsAuthIDSuccess()
{
	return 0;
}

INT UR6GSServers::IsMSClientIsInRequest()
{
	return 0;
}

INT UR6GSServers::IsServerJoined()
{
	return 0;
}

void UR6GSServers::LogGSVersion()
{
}

void UR6GSServers::LogOutServer()
{
}

void UR6GSServers::MSCLientJoinServer(INT, INT, FString)
{
}

INT UR6GSServers::MSCLientLeaveServer()
{
	return 0;
}

void UR6GSServers::MSClientServerConnected(INT, INT)
{
}

void UR6GSServers::MasterServerManager(AR6AbstractGameInfo *, ALevelInfo *)
{
}

void UR6GSServers::NativeCDKeyPlayerStatusReply(FString, BYTE, INT)
{
}

INT UR6GSServers::OnSameSubNet(FString)
{
	return 0;
}

void UR6GSServers::PingRequest(FString, FString)
{
}

INT UR6GSServers::PlayerIsInIDList(FString, FString, INT)
{
	return 0;
}

void UR6GSServers::PollCallbacks(INT, INT, INT, INT)
{
}

void UR6GSServers::PollClientCDKeyCallbacks(INT, INT, INT)
{
}

void UR6GSServers::PollGSClientCallbacks(INT)
{
}

void UR6GSServers::PollMSClientCallbacks(INT)
{
}

void UR6GSServers::PollPingManager(INT)
{
}

void UR6GSServers::PollRegServerCallbacks(INT)
{
}

void UR6GSServers::ProcessAuthIdRequest(AController *)
{
}

void UR6GSServers::ProcessInternetSrv(AR6AbstractGameInfo *, ALevelInfo *)
{
}

void UR6GSServers::ProcessIsLobbyDisconnect(FLOAT *)
{
}

void UR6GSServers::ProcessIsRouterDisconnect(FLOAT *)
{
}

void UR6GSServers::ProcessJoinServer(FLOAT *)
{
}

void UR6GSServers::ProcessJoinServerRequest()
{
}

void UR6GSServers::ProcessLoginMasterSrv(INT, FLOAT *)
{
}

void UR6GSServers::ProcessMSClientInitRequest()
{
}

void UR6GSServers::ProcessPC_CDKeyRequest(AR6AbstractGameInfo *, ALevelInfo *, APlayerController *, INT)
{
}

void UR6GSServers::ProcessRegServerGetLobbiesRequest()
{
}

void UR6GSServers::ProcessRegServerLoginRequest()
{
}

void UR6GSServers::ProcessRegServerLoginRouterRequest()
{
}

void UR6GSServers::ProcessRegServerRegOnLobbyRequest()
{
}

void UR6GSServers::ProcessRegServerUpdateRequest()
{
}

void UR6GSServers::ProcessSubmitMatchResultReply()
{
}

void UR6GSServers::ProcessUbiComJoinServer(INT, INT, FString, FLOAT *)
{
}

INT UR6GSServers::ReceiveAltInfo()
{
	return 0;
}

INT UR6GSServers::ReceiveServer()
{
	return 0;
}

void UR6GSServers::ReceiveValidation()
{
}

void UR6GSServers::RefreshOneServer(INT)
{
}

void UR6GSServers::RefreshServers()
{
}

void UR6GSServers::RegServerGetLobbies()
{
}

void UR6GSServers::RegServerRouterLogin()
{
}

void UR6GSServers::RegisterServer()
{
}

void UR6GSServers::RequestActivation(FString, INT)
{
}

void UR6GSServers::RequestAuthorization(INT)
{
}

void UR6GSServers::RequestGSCDKeyActID()
{
}

void UR6GSServers::RequestGSCDKeyAuthID()
{
}

void UR6GSServers::RequestModCDKeyProcess(INT)
{
}

void UR6GSServers::ResetAuthId()
{
}

void UR6GSServers::RouterDisconnect()
{
}

void UR6GSServers::ServerLogin()
{
}

void UR6GSServers::ServerRoundFinish()
{
}

void UR6GSServers::ServerRoundStart(INT)
{
}

INT UR6GSServers::SetGSClientComInterface()
{
	return 0;
}

void UR6GSServers::SetGSGameState(BYTE)
{
}

void UR6GSServers::SetGameServiceRequestState(BYTE)
{
}

void UR6GSServers::SetLoginRegServer(BYTE)
{
}

void UR6GSServers::SetRegServerLoginRequest(BYTE)
{
}

void UR6GSServers::SubmitMatchResult()
{
}

void UR6GSServers::UnInitCDKey()
{
}

INT UR6GSServers::UnInitMSClient()
{
	return 0;
}

void UR6GSServers::UnInitRegServer()
{
}

void UR6GSServers::UpdateServer()
{
}

void UR6GSServers::eventEndOfRoundDataSent()
{
	ProcessEvent(FindFunctionChecked(R6GAMESERVICE_EndOfRoundDataSent), NULL);
}

void UR6GSServers::eventFillCreateGameInfo(AGameInfo *pGameInfo, ALevelInfo *pLevelInfo)
{
	struct {
		AGameInfo *pGameInfo;
		ALevelInfo *pLevelInfo;
	} Parms;
	Parms.pGameInfo = pGameInfo;
	Parms.pLevelInfo = pLevelInfo;
	ProcessEvent(FindFunctionChecked(R6GAMESERVICE_FillCreateGameInfo), &Parms);
}

FString UR6GSServers::eventGetConsoleStoreIP(APlayerController *pPC)
{
	struct {
		APlayerController *pPC;
		FString ReturnValue;
	} Parms;
	Parms.ReturnValue = TEXT("");
	Parms.pPC = pPC;
	ProcessEvent(FindFunctionChecked(R6GAMESERVICE_GetConsoleStoreIP), &Parms);
	return Parms.ReturnValue;
}

FString UR6GSServers::eventGetLocallyBoundIpAddr()
{
	struct {
		FString ReturnValue;
	} Parms;
	Parms.ReturnValue = TEXT("");
	ProcessEvent(FindFunctionChecked(R6GAMESERVICE_GetLocallyBoundIpAddr), &Parms);
	return Parms.ReturnValue;
}

INT UR6GSServers::eventGetMaxAvailPorts()
{
	struct {
		INT ReturnValue;
	} Parms;
	Parms.ReturnValue = 0;
	ProcessEvent(FindFunctionChecked(R6GAMESERVICE_GetMaxAvailPorts), &Parms);
	return Parms.ReturnValue;
}

void UR6GSServers::eventHandleNewLobbyConnection(ALevelInfo *pLevelInfo)
{
	struct {
		ALevelInfo *pLevelInfo;
	} Parms;
	Parms.pLevelInfo = pLevelInfo;
	ProcessEvent(FindFunctionChecked(R6GAMESERVICE_HandleNewLobbyConnection), &Parms);
}

void UR6GSServers::eventInitializeMod()
{
	ProcessEvent(FindFunctionChecked(R6GAMESERVICE_InitializeMod), NULL);
}

DWORD UR6GSServers::eventIsGlobalIDBanned(AR6AbstractGameInfo *pGameInfo, FString const &szGlobalID)
{
	struct {
		AR6AbstractGameInfo *pGameInfo;
		FString szGlobalID;
		DWORD ReturnValue;
	} Parms;
	Parms.ReturnValue = 0;
	Parms.pGameInfo = pGameInfo;
	Parms.szGlobalID = szGlobalID;
	ProcessEvent(FindFunctionChecked(R6GAMESERVICE_IsGlobalIDBanned), &Parms);
	return Parms.ReturnValue;
}

void UR6GSServers::eventProcessServerMsg(APlayerController *pPC, FString const &szMsg)
{
	struct {
		APlayerController *pPC;
		FString szMsg;
	} Parms;
	Parms.pPC = pPC;
	Parms.szMsg = szMsg;
	ProcessEvent(FindFunctionChecked(R6GAMESERVICE_ProcessServerMsg), &Parms);
}

FString UR6GSServers::eventTempGetPBConnectStatus(APlayerController *pPC)
{
	struct {
		APlayerController *pPC;
		FString ReturnValue;
	} Parms;
	Parms.ReturnValue = TEXT("");
	Parms.pPC = pPC;
	ProcessEvent(FindFunctionChecked(R6GAMESERVICE_TempGetPBConnectStatus), &Parms);
	return Parms.ReturnValue;
}

void UR6GSServers::execEnterCDKey(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6GSServers::execGetMaxUbiServerNameSize(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6GSServers::execHandleAnyLobbyConnectionFail(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6GSServers::execInitGSCDKey(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6GSServers::execInitialize(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6GSServers::execInitializeMSClient(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6GSServers::execIsRefreshServersInProgress(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6GSServers::execNativeGetMSClientInitialized(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6GSServers::execNativeGetSeconds(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6GSServers::execNativeIsGSReadyToChangeMod(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6GSServers::execNativeIsRouterDisconnect(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6GSServers::execNativeIsWaitingForGSInit(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6GSServers::execNativeLogOutServer(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6GSServers::execNativeMSCLientJoinServer(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6GSServers::execNativeMSClientReqAltInfo(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6GSServers::execNativeProcessIcmpPing(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6GSServers::execNativeSetMatchResult(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6GSServers::execNativeUpdateServer(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6GSServers::execRefreshOneServer(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6GSServers::execRefreshServers(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6GSServers::execSetLastServerQueried(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6GSServers::execStopRefreshServers(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6GSServers::execUnInitializeMSClient(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6GSServers::registerCDKeySDKCallbacks(UR6GSServers *, void *, void *)
{
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
