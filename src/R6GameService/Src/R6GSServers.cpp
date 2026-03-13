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
	guard(UR6GSServers::AddPlayerToIDList);
	unguard;
}

void UR6GSServers::CDKeyDisconnecUser(FString)
{
	guard(UR6GSServers::CDKeyDisconnecUser);
	unguard;
}

INT UR6GSServers::CDKeyValidateUser(FString, INT, INT)
{
	return 0;
}

void UR6GSServers::CancelGSCDKeyActID()
{
	guard(UR6GSServers::CancelGSCDKeyActID);
	unguard;
}

void UR6GSServers::CancelGSCDKeyAuthID()
{
	guard(UR6GSServers::CancelGSCDKeyAuthID);
	unguard;
}

void UR6GSServers::CopyActivationIDInByteArray(BYTE *, BYTE *)
{
	guard(UR6GSServers::CopyActivationIDInByteArray);
	unguard;
}

void UR6GSServers::CreatedCDKey()
{
	guard(UR6GSServers::CreatedCDKey);
	unguard;
}

void UR6GSServers::Destroy()
{
	guard(UR6GSServers::Destroy);
	unguard;
}

void UR6GSServers::DisconnectAllCDKeyPlayers()
{
	guard(UR6GSServers::DisconnectAllCDKeyPlayers);
	unguard;
}

void UR6GSServers::EnterCDKey(FString)
{
	guard(UR6GSServers::EnterCDKey);
	unguard;
}

void UR6GSServers::GSClientPostMessage(BYTE)
{
	guard(UR6GSServers::GSClientPostMessage);
	unguard;
}

void UR6GSServers::GSClientUpdateServerInfo()
{
	guard(UR6GSServers::GSClientUpdateServerInfo);
	unguard;
}

void UR6GSServers::GameServiceManager(INT, INT, INT, INT)
{
	guard(UR6GSServers::GameServiceManager);
	unguard;
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
	guard(UR6GSServers::Init);
	unguard;
}

void UR6GSServers::InitCDKey(INT, INT)
{
	guard(UR6GSServers::InitCDKey);
	unguard;
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
	guard(UR6GSServers::InitMSClient);
	unguard;
}

void UR6GSServers::InitProcessUpdateUbiServer(AGameInfo *, ALevelInfo *)
{
	guard(UR6GSServers::InitProcessUpdateUbiServer);
	unguard;
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
	guard(UR6GSServers::LogGSVersion);
	unguard;
}

void UR6GSServers::LogOutServer()
{
	guard(UR6GSServers::LogOutServer);
	unguard;
}

void UR6GSServers::MSCLientJoinServer(INT, INT, FString)
{
	guard(UR6GSServers::MSCLientJoinServer);
	unguard;
}

INT UR6GSServers::MSCLientLeaveServer()
{
	return 0;
}

void UR6GSServers::MSClientServerConnected(INT, INT)
{
	guard(UR6GSServers::MSClientServerConnected);
	unguard;
}

void UR6GSServers::MasterServerManager(AR6AbstractGameInfo *, ALevelInfo *)
{
	guard(UR6GSServers::MasterServerManager);
	unguard;
}

void UR6GSServers::NativeCDKeyPlayerStatusReply(FString, BYTE, INT)
{
	guard(UR6GSServers::NativeCDKeyPlayerStatusReply);
	unguard;
}

INT UR6GSServers::OnSameSubNet(FString)
{
	return 0;
}

void UR6GSServers::PingRequest(FString, FString)
{
	guard(UR6GSServers::PingRequest);
	unguard;
}

INT UR6GSServers::PlayerIsInIDList(FString, FString, INT)
{
	return 0;
}

void UR6GSServers::PollCallbacks(INT, INT, INT, INT)
{
	guard(UR6GSServers::PollCallbacks);
	unguard;
}

void UR6GSServers::PollClientCDKeyCallbacks(INT, INT, INT)
{
	guard(UR6GSServers::PollClientCDKeyCallbacks);
	unguard;
}

void UR6GSServers::PollGSClientCallbacks(INT)
{
	guard(UR6GSServers::PollGSClientCallbacks);
	unguard;
}

void UR6GSServers::PollMSClientCallbacks(INT)
{
	guard(UR6GSServers::PollMSClientCallbacks);
	unguard;
}

void UR6GSServers::PollPingManager(INT)
{
	guard(UR6GSServers::PollPingManager);
	unguard;
}

void UR6GSServers::PollRegServerCallbacks(INT)
{
	guard(UR6GSServers::PollRegServerCallbacks);
	unguard;
}

void UR6GSServers::ProcessAuthIdRequest(AController *)
{
	guard(UR6GSServers::ProcessAuthIdRequest);
	unguard;
}

void UR6GSServers::ProcessInternetSrv(AR6AbstractGameInfo *, ALevelInfo *)
{
	guard(UR6GSServers::ProcessInternetSrv);
	unguard;
}

void UR6GSServers::ProcessIsLobbyDisconnect(FLOAT *)
{
	guard(UR6GSServers::ProcessIsLobbyDisconnect);
	unguard;
}

void UR6GSServers::ProcessIsRouterDisconnect(FLOAT *)
{
	guard(UR6GSServers::ProcessIsRouterDisconnect);
	unguard;
}

void UR6GSServers::ProcessJoinServer(FLOAT *)
{
	guard(UR6GSServers::ProcessJoinServer);
	unguard;
}

void UR6GSServers::ProcessJoinServerRequest()
{
	guard(UR6GSServers::ProcessJoinServerRequest);
	unguard;
}

void UR6GSServers::ProcessLoginMasterSrv(INT, FLOAT *)
{
	guard(UR6GSServers::ProcessLoginMasterSrv);
	unguard;
}

void UR6GSServers::ProcessMSClientInitRequest()
{
	guard(UR6GSServers::ProcessMSClientInitRequest);
	unguard;
}

void UR6GSServers::ProcessPC_CDKeyRequest(AR6AbstractGameInfo *, ALevelInfo *, APlayerController *, INT)
{
	guard(UR6GSServers::ProcessPC_CDKeyRequest);
	unguard;
}

void UR6GSServers::ProcessRegServerGetLobbiesRequest()
{
	guard(UR6GSServers::ProcessRegServerGetLobbiesRequest);
	unguard;
}

void UR6GSServers::ProcessRegServerLoginRequest()
{
	guard(UR6GSServers::ProcessRegServerLoginRequest);
	unguard;
}

void UR6GSServers::ProcessRegServerLoginRouterRequest()
{
	guard(UR6GSServers::ProcessRegServerLoginRouterRequest);
	unguard;
}

void UR6GSServers::ProcessRegServerRegOnLobbyRequest()
{
	guard(UR6GSServers::ProcessRegServerRegOnLobbyRequest);
	unguard;
}

void UR6GSServers::ProcessRegServerUpdateRequest()
{
	guard(UR6GSServers::ProcessRegServerUpdateRequest);
	unguard;
}

void UR6GSServers::ProcessSubmitMatchResultReply()
{
	guard(UR6GSServers::ProcessSubmitMatchResultReply);
	unguard;
}

void UR6GSServers::ProcessUbiComJoinServer(INT, INT, FString, FLOAT *)
{
	guard(UR6GSServers::ProcessUbiComJoinServer);
	unguard;
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
	guard(UR6GSServers::ReceiveValidation);
	unguard;
}

void UR6GSServers::RefreshOneServer(INT)
{
	guard(UR6GSServers::RefreshOneServer);
	unguard;
}

void UR6GSServers::RefreshServers()
{
	guard(UR6GSServers::RefreshServers);
	unguard;
}

void UR6GSServers::RegServerGetLobbies()
{
	guard(UR6GSServers::RegServerGetLobbies);
	unguard;
}

void UR6GSServers::RegServerRouterLogin()
{
	guard(UR6GSServers::RegServerRouterLogin);
	unguard;
}

void UR6GSServers::RegisterServer()
{
	guard(UR6GSServers::RegisterServer);
	unguard;
}

void UR6GSServers::RequestActivation(FString, INT)
{
	guard(UR6GSServers::RequestActivation);
	unguard;
}

void UR6GSServers::RequestAuthorization(INT)
{
	guard(UR6GSServers::RequestAuthorization);
	unguard;
}

void UR6GSServers::RequestGSCDKeyActID()
{
	guard(UR6GSServers::RequestGSCDKeyActID);
	unguard;
}

void UR6GSServers::RequestGSCDKeyAuthID()
{
	guard(UR6GSServers::RequestGSCDKeyAuthID);
	unguard;
}

void UR6GSServers::RequestModCDKeyProcess(INT)
{
	guard(UR6GSServers::RequestModCDKeyProcess);
	unguard;
}

void UR6GSServers::ResetAuthId()
{
	guard(UR6GSServers::ResetAuthId);
	unguard;
}

void UR6GSServers::RouterDisconnect()
{
	guard(UR6GSServers::RouterDisconnect);
	unguard;
}

void UR6GSServers::ServerLogin()
{
	guard(UR6GSServers::ServerLogin);
	unguard;
}

void UR6GSServers::ServerRoundFinish()
{
	guard(UR6GSServers::ServerRoundFinish);
	unguard;
}

void UR6GSServers::ServerRoundStart(INT)
{
	guard(UR6GSServers::ServerRoundStart);
	unguard;
}

INT UR6GSServers::SetGSClientComInterface()
{
	return 0;
}

void UR6GSServers::SetGSGameState(BYTE)
{
	guard(UR6GSServers::SetGSGameState);
	unguard;
}

void UR6GSServers::SetGameServiceRequestState(BYTE)
{
	guard(UR6GSServers::SetGameServiceRequestState);
	unguard;
}

void UR6GSServers::SetLoginRegServer(BYTE)
{
	guard(UR6GSServers::SetLoginRegServer);
	unguard;
}

void UR6GSServers::SetRegServerLoginRequest(BYTE)
{
	guard(UR6GSServers::SetRegServerLoginRequest);
	unguard;
}

void UR6GSServers::SubmitMatchResult()
{
	guard(UR6GSServers::SubmitMatchResult);
	unguard;
}

void UR6GSServers::UnInitCDKey()
{
	guard(UR6GSServers::UnInitCDKey);
	unguard;
}

INT UR6GSServers::UnInitMSClient()
{
	return 0;
}

void UR6GSServers::UnInitRegServer()
{
	guard(UR6GSServers::UnInitRegServer);
	unguard;
}

void UR6GSServers::UpdateServer()
{
	guard(UR6GSServers::UpdateServer);
	unguard;
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
	guard(UR6GSServers::registerCDKeySDKCallbacks);
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
