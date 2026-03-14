/*=============================================================================
	R6GameServiceClasses.h: R6GameService class declarations.
	Reconstructed from Ravenshield 1.56 SDK and Ghidra analysis.
=============================================================================*/

#if _MSC_VER
#pragma pack(push, 4)
#endif

#ifndef R6GAMESERVICE_API
#define R6GAMESERVICE_API DLL_IMPORT
#endif

#ifndef NAMES_ONLY
#undef  AUTOGENERATE_NAME
#undef  AUTOGENERATE_FUNCTION
#define AUTOGENERATE_NAME(name) extern R6GAMESERVICE_API FName R6GAMESERVICE_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name)
#endif

AUTOGENERATE_NAME(EndOfRoundDataSent)
AUTOGENERATE_NAME(FillCreateGameInfo)
AUTOGENERATE_NAME(GetConsoleStoreIP)
AUTOGENERATE_NAME(GetLobbyAndGroupID)
AUTOGENERATE_NAME(GetLocallyBoundIpAddr)
AUTOGENERATE_NAME(GetMaxAvailPorts)
AUTOGENERATE_NAME(HandleNewLobbyConnection)
AUTOGENERATE_NAME(InitializeMod)
AUTOGENERATE_NAME(IsGlobalIDBanned)
AUTOGENERATE_NAME(ProcessServerMsg)
AUTOGENERATE_NAME(TempGetPBConnectStatus)

#ifndef NAMES_ONLY

class AClientBeaconReceiver;

enum eSortCategory{
	 eSG_Favorite=0
	,eSG_Locked=1
	,eSG_Dedicated=2
	,eSG_PunkBuster=3
	,eSG_PingTime=4
	,eSG_Name=5
	,eSG_GameType=6
	,eSG_GameMode=7
	,eSG_Map=8
	,eSG_NumPlayers=9
};

enum ExitCause{
	 EC_Unknown=0
	,EC_PatchStarted=1
	,EC_NoPatchNeeded=2
	,EC_FatalDownloadError=3
	,EC_PartialDownloadError=4
	,EC_UserAborted=5
	,EC_UserQuit=6
};

struct FstRemotePlayers
{
public:
	class FString szAlias;
	INT iPing;
	INT iGroupID;
	INT iLobbySrvID;
	INT iSkills;
	INT iRank;
	class FString szTime;
};

struct FstGameTypeAndMap
{
public:
	class FString szMap;
	class FString szGameType;
};

struct FstGameData
{
public:
	BITFIELD bUsePassword : 1;
	BITFIELD bDedicatedServer : 1;
	INT iRoundsPerMatch;
	INT iRoundTime;
	INT iBetTime;
	INT iBombTime;
	BITFIELD bShowNames : 1;
	BITFIELD bInternetServer : 1;
	BITFIELD bFriendlyFire : 1;
	BITFIELD bAutoBalTeam : 1;
	BITFIELD bTKPenalty : 1;
	BITFIELD bRadar : 1;
	BITFIELD bAdversarial : 1;
	BITFIELD bRotateMap : 1;
	BITFIELD bAIBkp : 1;
	BITFIELD bForceFPWeapon : 1;
	BITFIELD bPunkBuster : 1;
	INT iNumMaps;
	INT iNumTerro;
	INT iPort;
	class FString szName;
	class FString szModName;
	INT iMaxPlayer;
	INT iNbrPlayer;
	class FString szGameDataGameType;
	class FString szGameType;
	class FString szCurrentMap;
	class FString szMessageOfDay;
	class FString szGameVersion;
	TArray<struct FstGameTypeAndMap> gameMapList;
	TArray<struct FstRemotePlayers> PlayerList;
	class FString szPassword;
};

struct FstGameServer
{
public:
	INT iGroupID;
	INT iLobbySrvID;
	INT iBeaconPort;
	INT iPing;
	class FString szIPAddress;
	class FString szAltIPAddress;
	BITFIELD bUseAltIP : 1;
	BITFIELD bDisplay : 1;
	BITFIELD bFavorite : 1;
	BITFIELD bSameVersion : 1;
	class FString szOptions;
	struct FstGameData sGameData;
};

struct FIpAddr
{
public:
	INT Addr;
	INT Port;
};

struct FstValidationResponse
{
public:
	INT iReqID;
	BYTE eStatus;
	BITFIELD bSuceeded : 1;
	BITFIELD bTimeout : 1;
	BYTE ucGlobalID[16];
};

class R6GAMESERVICE_API UR6ServerList : public UR6AbstractGameService
{
public:
	DECLARE_CLASS(UR6ServerList, UR6AbstractGameService, 0, R6GameService)

	INT m_iSelSrvIndex;
	INT m_iIndRefrIndex;
	BITFIELD m_bDedicatedServer : 1;
	BITFIELD m_bServerListChanged : 1;
	BITFIELD m_bServerInfoChanged : 1;
	BITFIELD m_bSavePWSave : 1;
	BITFIELD m_bAutoLISave : 1;
	AClientBeaconReceiver* m_ClientBeacon;
	TArray<FString> m_favoriteServersList;
	TArray<FstGameServer> m_GameServerList;
	TArray<FstValidationResponse> m_ValidResponseList;
	TArray<FstValidationResponse> m_ModValidResponseList;
	TArray<INT> m_GSLSortIdx;
	FstGameServer m_CrGameSrvInfo;
	FString m_szGameVersion;

	virtual void SetOwnSvrPort(INT);
	virtual INT GetLobbyID();
	virtual INT GetGroupID();
	void eventGetLobbyAndGroupID(INT &, INT &);
	void execGetDisplayListSize(struct FFrame &, void * const);
	void execNativeGetMaxPlayers(struct FFrame &, void * const);
	void execNativeGetMilliSeconds(struct FFrame &, void * const);
	void execNativeGetOwnSvrPort(struct FFrame &, void * const);
	void execNativeGetPingTime(struct FFrame &, void * const);
	void execNativeGetPingTimeOut(struct FFrame &, void * const);
	void execNativeInitFavorites(struct FFrame &, void * const);
	void execNativeUpdateFavorites(struct FFrame &, void * const);
	void execSortServers(struct FFrame &, void * const);
	void FillSvrContainer();
	void InitFavorites();
	void ResetSvrContainer();

	UR6ServerList() {}
};

class R6GAMESERVICE_API UR6ModGSInfo : public UObject
{
public:
	DECLARE_CLASS(UR6ModGSInfo, UObject, 0, R6GameService)

	BYTE m_ucModActivationID[16];
	BITFIELD m_bModValidActivationID : 1;
	FString m_szModGlobalID;

	void execNativeInitModInfo(struct FFrame &, void * const);
	void InitMODCDKey();

	UR6ModGSInfo() {}
};

class R6GAMESERVICE_API UR6LanServers : public UR6ServerList
{
public:
	DECLARE_CLASS(UR6LanServers, UR6ServerList, 0, R6GameService)

	INT m_iIndRefrAttempts;
	INT m_iIndRefrEndTime;
	BITFIELD m_bIndRefrInProgress : 1;


protected:
	UR6LanServers() {}
};

class R6GAMESERVICE_API UR6GSServers : public UR6ServerList
{
public:
	DECLARE_CLASS(UR6GSServers, UR6ServerList, 0, R6GameService)

	BYTE m_ucActivationID[16];
	INT m_iRSCDKeyPort;
	INT m_iModCDKeyPort;
	INT m_iRegSvrPort;
	INT m_iGSNumPlayers;
	BITFIELD m_bValidActivationID : 1;
	BITFIELD m_bUseCDKey : 1;
	BITFIELD m_bStartedByGSClient : 1;
	BITFIELD m_bUbiComClientDied : 1;
	BITFIELD m_bUbiComRoomDestroyed : 1;
	BITFIELD m_bUbiAccntInfoEntered : 1;
	BITFIELD m_bInitGame : 1;
	BITFIELD m_bLoggedInUbiDotCom : 1;
	BITFIELD m_bAutoLoginInProgress : 1;
	BITFIELD m_bAutoLoginFailed : 1;
	BITFIELD m_bRefreshFinished : 1;
	FLOAT m_fMaxTimeForResponse;
	UR6ModGSInfo* m_ModGSInfo;
	FString m_szUbiRemFileURL;
	FString m_szGSVersion;
	FString m_szGlobalID;
	FString m_szSavedPwd;
	FString m_szUbiHomePage;
	FString m_szPassword;
	FString m_szGSInitFileName;
	FString m_szGSClientIP;
	FString m_szGSServerName;
	FString m_szGSPassword;

	virtual void Destroy();
	virtual INT InitGSCDKey();
	virtual INT GetRegServerInitialized();
	virtual void SetGameServiceRequestState(BYTE);
	virtual void SetRegServerLoginRequest(BYTE);
	virtual void SetLoginRegServer(BYTE);
	virtual BYTE GetLoginRegServer();
	virtual INT GetServerRegistered();
	virtual void ServerRoundStart(INT);
	virtual void ServerRoundFinish();
	virtual void SubmitMatchResult();
	virtual void DisconnectAllCDKeyPlayers();
	virtual void CDKeyDisconnecUser(FString);
	virtual void GameServiceManager(INT, INT, INT, INT);
	virtual void ProcessLoginMasterSrv(INT, FLOAT *);
	virtual void ProcessUbiComJoinServer(INT, INT, FString, FLOAT *);
	virtual void ProcessIsRouterDisconnect(FLOAT *);
	virtual void ProcessIsLobbyDisconnect(FLOAT *);
	virtual void ProcessJoinServer(FLOAT *);
	virtual void MasterServerManager(AR6AbstractGameInfo *, ALevelInfo *);
	virtual void RequestModCDKeyProcess(INT);
	virtual void RequestGSCDKeyAuthID();
	virtual void ResetAuthId();
	virtual FString GetAuthID(INT);
	virtual INT InitGSClient();
	virtual INT SetGSClientComInterface();
	virtual void SetGSGameState(BYTE);
	virtual BYTE GetGSGameState();
	virtual void GSClientPostMessage(BYTE);
	virtual INT MSCLientLeaveServer();
	virtual INT IsMSClientIsInRequest();
	virtual INT GetLoggedInUbiDotCom();
	virtual INT IsServerJoined();
	void eventEndOfRoundDataSent();
	void eventFillCreateGameInfo(AGameInfo *, ALevelInfo *);
	INT eventGetMaxAvailPorts();
	void eventHandleNewLobbyConnection(ALevelInfo *);
	void eventInitializeMod();
	DWORD eventIsGlobalIDBanned(AR6AbstractGameInfo *, FString const &);
	void eventProcessServerMsg(APlayerController *, FString const &);
	void execEnterCDKey(struct FFrame &, void * const);
	void execGetMaxUbiServerNameSize(struct FFrame &, void * const);
	void execHandleAnyLobbyConnectionFail(struct FFrame &, void * const);
	void execInitGSCDKey(struct FFrame &, void * const);
	void execInitialize(struct FFrame &, void * const);
	void execInitializeMSClient(struct FFrame &, void * const);
	void execIsRefreshServersInProgress(struct FFrame &, void * const);
	void execNativeGetMSClientInitialized(struct FFrame &, void * const);
	void execNativeGetSeconds(struct FFrame &, void * const);
	void execNativeIsGSReadyToChangeMod(struct FFrame &, void * const);
	void execNativeIsRouterDisconnect(struct FFrame &, void * const);
	void execNativeIsWaitingForGSInit(struct FFrame &, void * const);
	void execNativeLogOutServer(struct FFrame &, void * const);
	void execNativeMSCLientJoinServer(struct FFrame &, void * const);
	void execNativeMSClientReqAltInfo(struct FFrame &, void * const);
	void execNativeProcessIcmpPing(struct FFrame &, void * const);
	void execNativeSetMatchResult(struct FFrame &, void * const);
	void execNativeUpdateServer(struct FFrame &, void * const);
	void execRefreshOneServer(struct FFrame &, void * const);
	void execRefreshServers(struct FFrame &, void * const);
	void execSetLastServerQueried(struct FFrame &, void * const);
	void execStopRefreshServers(struct FFrame &, void * const);
	void execUnInitializeMSClient(struct FFrame &, void * const);
	void AddPlayerToIDList(FString, FString, FString, INT);
	INT CDKeyValidateUser(FString, INT, INT);
	void CancelGSCDKeyActID();
	void CancelGSCDKeyAuthID();
	void CopyActivationIDInByteArray(BYTE *, BYTE *);
	void CreatedCDKey();
	void EnterCDKey(FString);
	void GSClientUpdateServerInfo();
	FString GetGlobalIdFromPlayerIDList(FString);
	void Init(FString);
	void InitCDKey(INT, INT);
	void InitMSClient();
	void InitProcessUpdateUbiServer(AGameInfo *, ALevelInfo *);
	INT InitializeMSClient();
	INT InitializeRegServer();
	INT IsAuthIDSuccess();
	void LogGSVersion();
	void LogOutServer();
	void MSCLientJoinServer(INT, INT, FString);
	void MSClientServerConnected(INT, INT);
	void NativeCDKeyPlayerStatusReply(FString, BYTE, INT);
	INT OnSameSubNet(FString);
	void PingRequest(FString, FString);
	INT PlayerIsInIDList(FString, FString, INT);
	void PollCallbacks(INT, INT, INT, INT);
	void PollClientCDKeyCallbacks(INT, INT, INT);
	void PollGSClientCallbacks(INT);
	void PollMSClientCallbacks(INT);
	void PollPingManager(INT);
	void PollRegServerCallbacks(INT);
	void ProcessAuthIdRequest(AController *);
	void ProcessInternetSrv(AR6AbstractGameInfo *, ALevelInfo *);
	void ProcessJoinServerRequest();
	void ProcessMSClientInitRequest();
	void ProcessPC_CDKeyRequest(AR6AbstractGameInfo *, ALevelInfo *, APlayerController *, INT);
	void ProcessRegServerGetLobbiesRequest();
	void ProcessRegServerLoginRequest();
	void ProcessRegServerLoginRouterRequest();
	void ProcessRegServerRegOnLobbyRequest();
	void ProcessRegServerUpdateRequest();
	void ProcessSubmitMatchResultReply();
	INT ReceiveAltInfo();
	INT ReceiveServer();
	void ReceiveValidation();
	void RefreshOneServer(INT);
	void RefreshServers();
	void RegServerGetLobbies();
	void RegServerRouterLogin();
	void RegisterServer();
	void RequestActivation(FString, INT);
	void RequestAuthorization(INT);
	void RequestGSCDKeyActID();
	void RouterDisconnect();
	void ServerLogin();
	void UnInitCDKey();
	INT UnInitMSClient();
	void UnInitRegServer();
	void UpdateServer();
	FString eventGetConsoleStoreIP(APlayerController *);
	FString eventGetLocallyBoundIpAddr();
	FString eventTempGetPBConnectStatus(APlayerController *);
	void registerCDKeySDKCallbacks(UR6GSServers *, void *, void *);

	UR6GSServers() {}
};

class R6GAMESERVICE_API UeviLPatchService : public UR6AbstractEviLPatchService
{
public:
	DECLARE_CLASS(UeviLPatchService, UR6AbstractEviLPatchService, 0, R6GameService)

	FLOAT m_bLastUpdateTime;

	void execAbortPatchService(struct FFrame &, void * const);
	void execCanRunUpdateService(struct FFrame &, void * const);
	void execGetDownloadProgress(struct FFrame &, void * const);
	void execGetExitCause(struct FFrame &, void * const);
	void execGetState(struct FFrame &, void * const);
	void execStartPatch(struct FFrame &, void * const);
	static void FinalDestroy();
	static DWORD GetPatchServiceState();
	void StartPatch();

	UeviLPatchService() {}
};

#endif // !NAMES_ONLY

#ifndef NAMES_ONLY
#undef AUTOGENERATE_NAME
#undef AUTOGENERATE_FUNCTION
#endif

#if _MSC_VER
#pragma pack(pop)
#endif
