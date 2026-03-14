//=============================================================================
// GameReplicationInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// GameReplicationInfo.
//=============================================================================
class GameReplicationInfo extends ReplicationInfo
    native
    nativereplication
    config
    notplaceable
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

const RSS_PlayersConnectingStage = 0;
const RSS_CountDownStage = 1;
const RSS_InPreGameState = 2;
const RSS_InGameState = 3;
const RSS_EndOfMatch = 4;

var byte m_bReceivedGameType;
var byte m_eOldServerState;
var byte m_eCurrectServerState;
var byte m_iNbWeaponsTerro;
var byte m_aRepMObjCompleted[16];
var byte m_aRepMObjFailed[16];
var byte m_bRepMObjInProgress;
var byte m_bRepMObjSuccess;
var byte m_bRepLastRoundSuccess;  // 0 = none, 1 = success, 2 = failed
var int TimeLimit;
var() globalconfig int ServerRegion;  // Region of the game server.
var int m_iMapIndex;  // assigned by game info and used by the clients to determine if map changed between rounds
// Variables used for connection to ubi.com
var int m_iGameSvrGroupID;  // ubi.com group ID
var int m_iGameSvrLobbyID;  // ubi.com lobby ID
var bool m_bShowPlayerStates;
//R6CODE
var bool m_bInPostBetweenRoundTime;  // are we in the PostBetweenRoundTime state
var bool m_bServerAllowRadar;  // if the server allow the radar (a game type CAN restrict this EVEN IF the option is checked by the player)
var bool m_bRepAllowRadarOption;
var bool m_bGameOverRep;
var bool m_bRestartableByJoin;
//#ifdefR6PUNKBUSTER
var bool m_bPunkBuster;  // server is a PunkBuster server
var string GameName;  // Assigned by GameInfo.
var string GameClass;  // Assigned by GameInfo.
var() globalconfig string ServerName;  // Name of the server, i.e.: Bob's Server.
var() globalconfig string ShortName;  // Abbreviated name of server, i.e.: B's Serv (stupid example)
var() globalconfig string AdminName;  // Name of the server admin.
var() globalconfig string AdminEmail;  // Email address of the server admin.
var() globalconfig string MOTDLine1;  // Message
var() globalconfig string MOTDLine2;  // Of
var() globalconfig string MOTDLine3;  // The
var() globalconfig string MOTDLine4;  // Day
var string m_szGameTypeFlagRep;
// struct did not replicated well...
var string m_aRepMObjDescription[16];
var string m_aRepMObjDescriptionLocFile[16];

replication
{
	// Pos:0x000
	reliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		m_aRepMObjCompleted, m_aRepMObjDescription, 
		m_aRepMObjDescriptionLocFile, m_aRepMObjFailed, 
		m_bGameOverRep, m_bInPostBetweenRoundTime, 
		m_bPunkBuster, m_bRepAllowRadarOption, 
		m_bRepLastRoundSuccess, m_bRepMObjInProgress, 
		m_bRepMObjSuccess, m_bRestartableByJoin, 
		m_bServerAllowRadar, m_eCurrectServerState, 
		m_iGameSvrGroupID, m_iGameSvrLobbyID, 
		m_iNbWeaponsTerro;

	// Pos:0x00D
	reliable if(__NFUN_130__(bNetInitial, __NFUN_154__(int(Role), int(ROLE_Authority))))
		AdminEmail, AdminName, 
		GameClass, GameName, 
		MOTDLine1, MOTDLine2, 
		MOTDLine3, MOTDLine4, 
		ServerName, ServerRegion, 
		ShortName, TimeLimit, 
		m_iMapIndex, m_szGameTypeFlagRep;
}

//#ifdef R6CODE
simulated function ControllerStarted(R6GameMenuCom NewMenuCom)
{
	return;
}

simulated event NewServerState()
{
	return;
}

simulated event SaveRemoteServerSettings(string NewServerFile)
{
	return;
}

function SetServerState(byte NewState)
{
	// End:0x3D
	if(__NFUN_155__(int(NewState), int(m_eCurrectServerState)))
	{
		m_eCurrectServerState = NewState;
		// End:0x3D
		if(__NFUN_154__(int(Level.NetMode), int(NM_ListenServer)))
		{
			NewServerState();
		}
	}
	return;
}

simulated function PostBeginPlay()
{
	// End:0x51
	if(__NFUN_154__(int(Level.NetMode), int(NM_Client)))
	{
		ServerName = "";
		AdminName = "";
		AdminEmail = "";
		MOTDLine1 = "";
		MOTDLine2 = "";
		MOTDLine3 = "";
		MOTDLine4 = "";
	}
	return;
}

function Reset()
{
	super(Actor).Reset();
	return;
}

//#ifdef R6CODE
simulated function ResetOriginalData()
{
	super(Actor).ResetOriginalData();
	m_bInPostBetweenRoundTime = false;
	m_bGameOverRep = false;
	return;
}

//#ifdef R6CODE
function RefreshMPlayerInfo()
{
	return;
}

function SetRepMObjInfo(int Index, bool bFailed, bool bCompleted)
{
	// End:0x1A
	if(bFailed)
	{
		m_aRepMObjFailed[Index] = 1;		
	}
	else
	{
		m_aRepMObjFailed[Index] = 0;
	}
	// End:0x42
	if(bCompleted)
	{
		m_aRepMObjCompleted[Index] = 1;		
	}
	else
	{
		m_aRepMObjCompleted[Index] = 0;
	}
	return;
}

function SetRepMObjString(int Index, string szDesc, string szLocFile)
{
	m_aRepMObjDescription[Index] = szDesc;
	m_aRepMObjDescriptionLocFile[Index] = szLocFile;
	return;
}

simulated function string GetRepMObjStringLocFile(int Index)
{
	return m_aRepMObjDescriptionLocFile[Index];
	return;
}

simulated function string GetRepMObjString(int Index)
{
	return m_aRepMObjDescription[Index];
	return;
}

simulated function bool IsRepMObjCompleted(int Index)
{
	return __NFUN_154__(int(m_aRepMObjCompleted[Index]), 1);
	return;
}

simulated function bool IsRepMObjFailed(int Index)
{
	return __NFUN_154__(int(m_aRepMObjFailed[Index]), 1);
	return;
}

simulated function ResetRepMObjInfo()
{
	local int i;

	i = 0;
	J0x07:

	// End:0x46 [Loop If]
	if(__NFUN_150__(i, 16))
	{
		m_aRepMObjDescription[i] = "";
		m_aRepMObjDescriptionLocFile[i] = "";
		SetRepMObjInfo(i, false, false);
		__NFUN_163__(i);
		// [Loop Continue]
		goto J0x07;
	}
	m_bRepMObjSuccess = 0;
	m_bRepMObjInProgress = 1;
	return;
}

simulated function int GetRepMObjInfoArraySize()
{
	return 16;
	return;
}

simulated function SetRepMObjInProgress(bool bInProgress)
{
	// End:0x14
	if(bInProgress)
	{
		m_bRepMObjInProgress = 1;		
	}
	else
	{
		m_bRepMObjInProgress = 0;
	}
	return;
}

simulated function SetRepMObjSuccess(bool bSuccess)
{
	// End:0x14
	if(bSuccess)
	{
		m_bRepMObjSuccess = 1;		
	}
	else
	{
		m_bRepMObjSuccess = 0;
	}
	return;
}

simulated function SetRepLastRoundSuccess(byte bLastRoundSuccess)
{
	m_bRepLastRoundSuccess = bLastRoundSuccess;
	return;
}

simulated function bool IsInAGameState()
{
	return __NFUN_132__(__NFUN_154__(int(m_eCurrectServerState), 2), __NFUN_154__(int(m_eCurrectServerState), 3));
	return;
}

defaultproperties
{
	m_bRestartableByJoin=true
	ServerName="Another Server"
	ShortName="Server"
	m_szGameTypeFlagRep="RGM_AllMode"
	RemoteRole=2
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var bTeamGame
// REMOVED IN 1.60: var GoalScore
// REMOVED IN 1.60: var Teams2
// REMOVED IN 1.60: var Winner
