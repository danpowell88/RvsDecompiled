//=============================================================================
// R6GameReplicationInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6GameReplicationInfo.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/10 * Created by Aristomenis Kolokathis
//=============================================================================
class R6GameReplicationInfo extends GameReplicationInfo
    native
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

const m_MapLength = 32;

var int m_iDeathCameraMode;  // Camer mode used for dead players
var int m_MaxPlayers;
//var FLOAT         m_fTimeMap;
var int m_iCurrentRound;  // this is the current round in this match
var int m_iRoundsPerMatch;
var int m_iDiffLevel;  // The difficulty level of the terro -- in coop
var int m_iNbOfTerro;  // The number of terro -- in coop
var int m_iMenuCountDownTime;
var int m_aTeamScore[2];
var const int c_iTeamNumBravo;
var bool bShowLog;
var bool m_bPasswordReq;
var bool m_bAdminPasswordReq;
var bool m_bFriendlyFire;
var bool m_bAutoBalance;
var bool m_bTKPenalty;  // this is the Team killer penalty setting as seen by the game mode
var bool m_bMenuTKPenaltySetting;  // This is the Team killer penalty setting as set in the menus
var bool m_bShowNames;
var bool m_bInternetSvr;  // The server is a internet server
var bool m_bFFPWeapon;  // Force first person weapons
var bool m_bDedicatedSvr;  // The server is a dedicated server
var bool m_bAIBkp;  // AI backup
var bool m_bRotateMap;  // in coop, rotate map automatically if it's true
var bool m_bRepMenuCountDownTimePaused;
var bool m_bRepMenuCountDownTimeUnlimited;
var bool m_bIsWritableMapAllowed;  // in some game type, the writablemap can't be used (ie: deathmatch)
var float m_fTimeBetRounds;
var float m_fBombTime;
var float m_fRepMenuCountDownTime;
var float m_fRepMenuCountDownTimeLastUpdate;
var R6RainbowTeam m_RainbowTeam[3];
var R6GameMenuCom m_MenuCommunication;
var string m_szCurrGameType;
// NEW IN 1.60
var string m_mapArray[32];
// NEW IN 1.60
var string m_gameModeArray[32];
var string m_szSubMachineGunsRes[32];  // Primary weapon: List of restricted sub maching guns
var string m_szShotGunRes[32];  // Primary weapon: Shotguns restricted
var string m_szAssRifleRes[32];  // Primary weapon: Assault rifles restricted
var string m_szMachGunRes[32];  // Primary weapon: Machine Guns restricted
var string m_szSnipRifleRes[32];  // Primary weapon: Sniper rifles restricted
var string m_szPistolRes[32];  // Secondary weapon: Pistols restricted
var string m_szMachPistolRes[32];  // Secondary weapon: Machine pistols restricted
var string m_szGadgPrimaryRes[32];  // Gadget: primary weapon restricted
var string m_szGadgSecondayRes[32];  // Gadget: secondary restricted
var string m_szGadgMiscRes[32];  // Gadget: misceleaneous restricted

replication
{
	// Pos:0x000
	reliable if((int(Role) == int(ROLE_Authority)))
		m_aTeamScore, m_bRepMenuCountDownTimePaused, 
		m_bRepMenuCountDownTimeUnlimited, m_fRepMenuCountDownTime, 
		m_iCurrentRound;

	// Pos:0x00D
	reliable if((bNetInitial && (int(Role) == int(ROLE_Authority))))
		m_MaxPlayers, m_bAIBkp, 
		m_bAdminPasswordReq, m_bAutoBalance, 
		m_bDedicatedSvr, m_bFFPWeapon, 
		m_bFriendlyFire, m_bInternetSvr, 
		m_bIsWritableMapAllowed, m_bMenuTKPenaltySetting, 
		m_bPasswordReq, m_bRotateMap, 
		m_bShowNames, m_bTKPenalty, 
		m_fBombTime, m_fTimeBetRounds, 
		m_gameModeArray, m_iDeathCameraMode, 
		m_iDiffLevel, m_iNbOfTerro, 
		m_iRoundsPerMatch, m_mapArray, 
		m_szCurrGameType;

	// Pos:0x025
	reliable if((int(Role) == int(ROLE_Authority)))
		m_szAssRifleRes, m_szGadgMiscRes, 
		m_szGadgPrimaryRes, m_szGadgSecondayRes, 
		m_szMachGunRes, m_szMachPistolRes, 
		m_szPistolRes, m_szShotGunRes, 
		m_szSnipRifleRes, m_szSubMachineGunsRes;
}

simulated function FirstPassReset()
{
	m_RainbowTeam[0] = none;
	m_RainbowTeam[1] = none;
	m_RainbowTeam[2] = none;
	return;
}

simulated event Tick(float fDeltaTime)
{
	super(Actor).Tick(fDeltaTime);
	// End:0x64
	if((((int(Level.NetMode) == int(NM_Client)) && (!m_bRepMenuCountDownTimePaused)) && (!m_bRepMenuCountDownTimeUnlimited)))
	{
		(m_fRepMenuCountDownTime -= fDeltaTime);
		// End:0x64
		if((m_fRepMenuCountDownTime < 0.0000000))
		{
			m_fRepMenuCountDownTime = 0.0000000;
		}
	}
	return;
}

simulated event float GetRoundTime()
{
	// End:0x21
	if((int(Level.NetMode) == int(NM_ListenServer)))
	{
		return float(m_iMenuCountDownTime);
	}
	return m_fRepMenuCountDownTime;
	return;
}

simulated function ControllerStarted(R6GameMenuCom NewMenuCom)
{
	m_MenuCommunication = NewMenuCom;
	return;
}

simulated event Destroyed()
{
	super(Actor).Destroyed();
	// End:0x20
	if((m_MenuCommunication != none))
	{
		m_MenuCommunication.ClearLevelReferences();
	}
	return;
}

function PlaySoundStatus()
{
	return;
}

simulated function RefreshMPlayerInfo()
{
	m_MenuCommunication.m_iLastValidIndex = 0;
	m_MenuCommunication.m_szServerName = ServerName;
	RefreshMPInfoPlayerStats();
	return;
}

simulated function RefreshMPInfoPlayerStats()
{
	local PlayerReplicationInfo PRI;
	local PlayerMenuInfo _PlayerMenuInfo;
	local int _iLastValidIndex;

	// End:0x33A
	foreach DynamicActors(Class'Engine.PlayerReplicationInfo', PRI)
	{
		// End:0x6D
		if(bShowLog)
		{
			Log(((((("RefreshMPlayerInfo Index:" @ string(_iLastValidIndex)) @ "PRI is") @ string(PRI)) @ "Name is") @ PRI.PlayerName));
		}
		// End:0xE2
		if((PRI.m_iRoundsHit > 0))
		{
			// End:0xD2
			if((PRI.m_iRoundsHit < PRI.m_iRoundFired))
			{
				_PlayerMenuInfo.iEfficiency = ((PRI.m_iRoundsHit * 100) / PRI.m_iRoundFired);				
			}
			else
			{
				_PlayerMenuInfo.iEfficiency = 100;
			}			
		}
		else
		{
			_PlayerMenuInfo.iEfficiency = 0;
		}
		_PlayerMenuInfo.szPlayerName = PRI.PlayerName;
		_PlayerMenuInfo.iKills = PRI.m_iKillCount;
		_PlayerMenuInfo.iRoundsFired = PRI.m_iRoundFired;
		_PlayerMenuInfo.iRoundsHit = PRI.m_iRoundsHit;
		_PlayerMenuInfo.szKilledBy = PRI.m_szKillersName;
		_PlayerMenuInfo.iPingTime = PRI.Ping;
		_PlayerMenuInfo.iHealth = PRI.m_iHealth;
		_PlayerMenuInfo.bJoinedTeamLate = PRI.m_bJoinedTeamLate;
		_PlayerMenuInfo.iTeamSelection = PRI.TeamID;
		_PlayerMenuInfo.iRoundsPlayed = PRI.m_iRoundsPlayed;
		_PlayerMenuInfo.iRoundsWon = PRI.m_iRoundsWon;
		_PlayerMenuInfo.iDeathCount = int(PRI.Deaths);
		_PlayerMenuInfo.bPlayerReady = PRI.m_bPlayerReady;
		_PlayerMenuInfo.bSpectator = ((PRI.TeamID == int(0)) || (PRI.TeamID == int(4)));
		// End:0x2D1
		if(m_bShowPlayerStates)
		{
			Log(((((("DBG: " $ PRI.PlayerName) $ " bSpectator=") $ string(_PlayerMenuInfo.bSpectator)) $ " TeamID=") $ string(PRI.TeamID)));
		}
		// End:0x2F5
		if((PRI.Owner == none))
		{
			_PlayerMenuInfo.bOwnPlayer = false;			
		}
		else
		{
			_PlayerMenuInfo.bOwnPlayer = (Viewport(PlayerController(PRI.Owner).Player) != none);
		}
		SetFPlayerMenuInfo(_iLastValidIndex, _PlayerMenuInfo);
		(_iLastValidIndex++);		
	}	
	SortFPlayerMenuInfo(_iLastValidIndex, m_szCurrGameType);
	// End:0x367
	if((m_MenuCommunication != none))
	{
		m_MenuCommunication.m_iLastValidIndex = _iLastValidIndex;
	}
	return;
}

simulated event NewServerState()
{
	// End:0x30
	if(((m_MenuCommunication != none) && (!m_MenuCommunication.m_bImCurrentlyDisconnect)))
	{
		m_MenuCommunication.NewServerState();
	}
	return;
}

simulated event SaveRemoteServerSettings(string NewServerFile)
{
	local R6ServerInfo pServerOptions;
	local int _iCount;
	local WindowConsole _console;

	pServerOptions = new Class'Engine.R6ServerInfo';
	pServerOptions.m_ServerMapList = Spawn(Class'Engine.R6MapList');
	pServerOptions.ServerName = ServerName;
	pServerOptions.CamFirstPerson = ((m_iDeathCameraMode & 1) > 0);
	pServerOptions.CamThirdPerson = ((m_iDeathCameraMode & 2) > 0);
	pServerOptions.CamFreeThirdP = ((m_iDeathCameraMode & 4) > 0);
	pServerOptions.CamGhost = ((m_iDeathCameraMode & 8) > 0);
	pServerOptions.CamFadeToBlack = ((m_iDeathCameraMode & 16) > 0);
	pServerOptions.CamTeamOnly = ((m_iDeathCameraMode & 32) > 0);
	pServerOptions.MaxPlayers = m_MaxPlayers;
	pServerOptions.NbTerro = m_iNbOfTerro;
	pServerOptions.UsePassword = false;
	pServerOptions.GamePassword = "";
	pServerOptions.MOTD = MOTDLine1;
	pServerOptions.RoundTime = TimeLimit;
	pServerOptions.RoundsPerMatch = m_iRoundsPerMatch;
	pServerOptions.BetweenRoundTime = int(m_fTimeBetRounds);
	pServerOptions.UseAdminPassword = false;
	pServerOptions.AdminPassword = "";
	pServerOptions.BombTime = int(m_fBombTime);
	pServerOptions.DiffLevel = m_iDiffLevel;
	pServerOptions.ShowNames = m_bShowNames;
	pServerOptions.InternetServer = m_bInternetSvr;
	pServerOptions.DedicatedServer = m_bDedicatedSvr;
	pServerOptions.FriendlyFire = m_bFriendlyFire;
	pServerOptions.Autobalance = m_bAutoBalance;
	pServerOptions.TeamKillerPenalty = m_bMenuTKPenaltySetting;
	pServerOptions.AllowRadar = m_bRepAllowRadarOption;
	pServerOptions.ForceFPersonWeapon = m_bFFPWeapon;
	pServerOptions.AIBkp = m_bAIBkp;
	pServerOptions.RotateMap = m_bRotateMap;
	pServerOptions.ClearSettings();
	_console = WindowConsole(m_MenuCommunication.m_PlayerController.Player.Console);
	_console.GetRestKitDescName(self, pServerOptions);
	_iCount = 0;
	J0x2FB:

	// End:0x345 [Loop If]
	if(((_iCount < 32) && (m_szGadgPrimaryRes[_iCount] != "")))
	{
		pServerOptions.RestrictedPrimary[_iCount] = m_szGadgPrimaryRes[_iCount];
		(_iCount++);
		// [Loop Continue]
		goto J0x2FB;
	}
	_iCount = 0;
	J0x34C:

	// End:0x396 [Loop If]
	if(((_iCount < 32) && (m_szGadgSecondayRes[_iCount] != "")))
	{
		pServerOptions.RestrictedSecondary[_iCount] = m_szGadgSecondayRes[_iCount];
		(_iCount++);
		// [Loop Continue]
		goto J0x34C;
	}
	_iCount = 0;
	J0x39D:

	// End:0x3E7 [Loop If]
	if(((_iCount < 32) && (m_szGadgMiscRes[_iCount] != "")))
	{
		pServerOptions.RestrictedMiscGadgets[_iCount] = m_szGadgMiscRes[_iCount];
		(_iCount++);
		// [Loop Continue]
		goto J0x39D;
	}
	_iCount = 0;
	J0x3EE:

	// End:0x456 [Loop If]
	if((_iCount < 32))
	{
		pServerOptions.m_ServerMapList.GameType[_iCount] = m_gameModeArray[_iCount];
		pServerOptions.m_ServerMapList.Maps[_iCount] = m_mapArray[_iCount];
		(_iCount++);
		// [Loop Continue]
		goto J0x3EE;
	}
	pServerOptions.SaveConfig(NewServerFile);
	pServerOptions.m_ServerMapList.SaveConfig(NewServerFile);
	return;
}

defaultproperties
{
	c_iTeamNumBravo=3
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_mapArraym_MapLength
// REMOVED IN 1.60: var m_gameModeArraym_MapLength
