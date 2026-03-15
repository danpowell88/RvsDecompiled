//=============================================================================
// R6GameInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6GameInfo.uc : This is class where all the Rainbow game rules will be defined.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/20 * Created by Rima Brek
//    2001/05/25 * Joel Tremblay added the heat textures initialisation
//    2001/07/31 * Chaouky Garram added the game mode and the TeamInfo
//============================================================================//
class R6GameInfo extends R6
    AbstractGameInfo
    native
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

const CMaxRainbowAI = 6;
const CMaxPlayers = 16;
const CMaxCoOpPlayers = 8;
const K_InGamePauseTime = 5;

var byte R6DefaultWeaponInput;
var UWindowRootWindow.eGameWidgetID m_eEndGameWidgetID;
var byte m_bCurrentFemaleId;
var byte m_bCurrentMaleId;
var byte m_bRainbowFaces[30];
var int m_iCurrentID;
var int m_iMaxOperatives;  // max of operatives available for a mission in single player
var int m_iJumpMapIndex;
var int m_iRoundsPerMatch;  // number of rounds in each match/map
//var FLOAT  m_fMapTimeLimit;     // Time limit per map (seconds)
var int m_iDeathCameraMode;  // Camera Mode used when plyer dead
var int m_iSubMachineGunsResMask;
var int m_iShotGunResMask;  // Primary weapon: Shotguns restricted
var int m_iAssRifleResMask;  // Primary weapon: Assault rifles restricted
var int m_iMachGunResMask;  // Primary weapon: Machine Guns restricted
var int m_iSnipRifleResMask;  // Primary weapon: Sniper rifles restricted
var int m_iPistolResMask;  // Secondary weapon: Pistols restricted
var int m_iMachPistolResMask;  // Secondary weapon: Machine pistols restricted
var int m_iGadgPrimaryResMask;  // Gadget: primary weapon restricted
var int m_iGadgSecondaryResMask;  // Gadget: secondary restricted
var int m_iGadgMiscResMask;  // Gadget: misceleaneous restricted
var int m_iNbOfRestart;
var int m_iIDVoicesMgr;
// NEW IN 1.60
var int m_iUbiComGameMode;
var(Debug) bool bShowLog;
//#ifdef R6Cheat
var bool bNoRestart;  // AK: this is a cheat
var bool m_bServerAllowRadarRep;  // replicated bool
var bool m_bRepAllowRadarOption;
var bool m_bIsRadarAllowed;  // in some game type, the radar can't be used (ie: deathmatch)
var bool m_bIsWritableMapAllowed;  // in some game type, the writablemap can't be used (ie: deathmatch)
var bool m_bUsingPlayerCampaign;  // A game mode with this set to true allows saving through a player campaign
var bool m_bUsingCampaignBriefing;  // A game mode with this set to true allows having sweeney and clark briefing
var bool m_bUnlockAllDoors;  // a game mode can forces to unlock all doors
// used in conjunction with the admin Map command
var bool m_bJumpingMaps;
// These variables can be set in the menus, but the results are not yet 
// integrated in the game.
// *** and there's some in r6AbstractGameInfo
var bool m_bAutoBalance;
var bool m_bTKPenalty;
var bool m_bPWSubMachGunRes;  // Primary weapon: Sub machine guns restricted
var bool m_bPWShotGunRes;  // Primary weapon: Shotguns restricted
var bool m_bPWAssRifleRes;  // Primary weapon: Assault rifles restricted
var bool m_bPWMachGunRes;  // Primary weapon: Machine Guns restricted
var bool m_bPWSnipRifleRes;  // Primary weapon: Sniper rifles restricted
var bool m_bSWPistolRes;  // Secondary weapon: Pistols restricted
var bool m_bSWMachPistolRes;  // Secondary weapon: Machine pistols restricted
var bool m_bGadgPrimaryRes;  // Gadget: primary weapon restricted
var bool m_bGadgSecondayRes;  // Gadget: secondary restricted
var bool m_bGadgMiscRes;  // Gadget: misceleaneous restricted
var bool m_bShowNames;  // show the name of players (enemies or not)
var bool m_bFFPWeapon;  // Force first person weapons
var bool m_bAdminPasswordReq;  // Administration password required
var bool m_bAIBkp;  // AI backup
var bool m_bRotateMap;  // in coop, rotate map automatically if it's true
var bool m_bFadeStarted;  // in single player before the DebriefingWidget stat the fade
var bool m_bFeedbackHostageKilled;
var bool m_bFeedbackHostageExtracted;
// NEW IN 1.60
var bool m_bStopPostBetweenRoundCountdown;
var float m_fRoundStartTime;  // this is the time that the round will start at
var float m_fRoundEndTime;
var float m_fPausedAtTime;  // count down paused at time
var float m_fBombTime;
// NEW IN 1.60
var float m_fInGameStartTime;
var R6CommonRainbowVoices m_CommonRainbowPlayerVoicesMgr;
var R6CommonRainbowVoices m_CommonRainbowMemberVoicesMgr;
var R6RainbowPlayerVoices m_RainbowPlayerVoicesMgr;
var R6RainbowMemberVoices m_RainbowMemberVoicesMgr;
var R6MultiCoopVoices m_MultiCoopMemberVoicesMgr;
var R6PreRecordedMsgVoices m_PreRecordedMsgVoicesMgr;
var R6MultiCommonVoices m_MultiCommonVoicesMgr;
var NavigationPoint LastStartSpot;  // last place any player started from
var R6GSServers m_GameService;  // Manages servers from game service
var R6GSServers m_PersistantGameService;
var Material DefaultFaceTexture;
// NEW IN 1.60
var Class<HUD> m_HudClass;
var array<R6RainbowOtherTeamVoices> m_RainbowOtherTeamVoicesMgr;
var array<R6MultiCoopVoices> m_MultiCoopPlayerVoicesMgr;
var array<R6TerroristVoices> m_TerroristVoicesMgr;
var array<R6HostageVoices> m_HostageVoicesMaleMgr;
var array<R6HostageVoices> m_HostageVoicesFemaleMgr;
var array<R6Terrorist> m_listAllTerrorists;
var array<R6RainbowAI> m_RainbowAIBackup;
var array<string> m_mapList;  // List of maps in multi player mode
var array<string> m_gameModeList;  // list of game modes used in multi player mode
var Plane DefaultFaceCoords;
// Variables used to hold information passed via the command line options string
var string m_szMessageOfDay;  // Message of the day passed as comand line argument
var string m_szSvrName;  // Server name passed as comand line argument

// Export UR6GameInfo::execSetController(FFrame&, void* const)
native(2010) final function bool SetController(PlayerController PController, Player pPlayer);

// Export UR6GameInfo::execNativeLogout(FFrame&, void* const)
// NEW IN 1.60
native(1502) final function NativeLogout(PlayerController Exiting);

// Export UR6GameInfo::execGetSystemUserName(FFrame&, void* const)
native(1504) final function GetSystemUserName(out string szUserName);

// Export UR6GameInfo::execInitScoreSubmission(FFrame&, void* const)
// NEW IN 1.60
native(1240) final function InitScoreSubmission(bool _bStatsSetting);

// Export UR6GameInfo::execSubmissionSrvRoundStart(FFrame&, void* const)
// NEW IN 1.60
native(1241) final function SubmissionSrvRoundStart();

// Export UR6GameInfo::execSubmissionNotifySendStartMatch(FFrame&, void* const)
// NEW IN 1.60
native(1242) final function bool SubmissionNotifySendStartMatch();

// Export UR6GameInfo::execSubmissionSrvRoundFinish(FFrame&, void* const)
// NEW IN 1.60
native(1243) final function SubmissionSrvRoundFinish();

// Export UR6GameInfo::execLogoutUpdatePlayersCtrlInfo(FFrame&, void* const)
// NEW IN 1.60
native(1244) final function LogoutUpdatePlayersCtrlInfo(Controller Exiting);

// Export UR6GameInfo::execSubmissionUpdateLadderStat(FFrame&, void* const)
// NEW IN 1.60
native(1245) final function bool SubmissionUpdateLadderStat();

function SetUdpBeacon(InternetInfo _udpBeacon)
{
	m_UdpBeacon = UdpBeacon(_udpBeacon);
	return;
}

function GetNbHumanPlayerInTeam(out int iAlphaNb, out int iBravoNb)
{
	return;
}

simulated function FirstPassReset()
{
	local int i;

	// End:0x64
	if((m_missionMgr != none))
	{
		i = 0;
		J0x12:

		// End:0x53 [Loop If]
		if((i < m_missionMgr.m_aMissionObjectives.Length))
		{
			m_missionMgr.m_aMissionObjectives[i].Reset();
			(++i);
			// [Loop Continue]
			goto J0x12;
		}
		m_missionMgr.SetMissionObjStatus(0);
	}
	ResetRepMissionObjectives();
	m_listAllTerrorists.Remove(0, m_listAllTerrorists.Length);
	// End:0x90
	if((m_RainbowAIBackup.Length > 0))
	{
		m_RainbowAIBackup.Remove(0, m_RainbowAIBackup.Length);
	}
	return;
}

function R6AbstractInsertionZone GetAStartSpot()
{
	local R6AbstractInsertionZone aZone;

	// End:0x2C
	foreach AllActors(Class'R6Abstract.R6AbstractInsertionZone', aZone)
	{
		// End:0x2B
		if(aZone.IsAvailableInGameType(m_szGameTypeFlag))
		{			
			return aZone;
		}		
	}	
	return none;
	return;
}

function Object GetRainbowTeam(int eTeamName)
{
	return R6GameReplicationInfo(GameReplicationInfo).m_RainbowTeam[eTeamName];
	return;
}

function SetRainbowTeam(int eTeamName, R6RainbowTeam newTeam)
{
	R6GameReplicationInfo(GameReplicationInfo).m_RainbowTeam[eTeamName] = newTeam;
	return;
}

// AK: yes we are using this function. 01/Feb/2002
//function AcceptInventory(pawn PlayerPawn)
simulated event AcceptInventory(Pawn PlayerPawn)
{
	local PlayerPrefInfo m_PlayerPrefs;
	local R6Pawn aPawn;
	local R6Rainbow aRainbow;
	local string szSecWeapon, caps_szSecGadget;

	aPawn = R6Pawn(PlayerPawn);
	// End:0x596
	if(((aPawn != none) && (aPawn.EngineWeapon == none)))
	{
		m_PlayerPrefs = PlayerController(aPawn.Controller).m_PlayerPrefs;
		// End:0x17E
		if((((!IsPrimaryWeaponRestrictedToPawn(aPawn)) && (m_PlayerPrefs.m_WeaponName1 != "")) && (!IsPrimaryWeaponRestricted(m_PlayerPrefs.m_WeaponName1))))
		{
			// End:0xCB
			if(bShowLog)
			{
				Log(((("NOW GIVING " $ m_PlayerPrefs.m_WeaponName1) $ " to ") $ string(aPawn.Controller)));
			}
			// End:0x118
			if(((m_PlayerPrefs.m_WeaponGadgetName1 != "") && IsPrimaryGadgetRestricted(m_PlayerPrefs.m_WeaponGadgetName1)))
			{
				aPawn.ServerGivesWeaponToClient(m_PlayerPrefs.m_WeaponName1, 1, m_PlayerPrefs.m_BulletType1);				
			}
			else
			{
				aPawn.ServerGivesWeaponToClient(m_PlayerPrefs.m_WeaponName1, 1, m_PlayerPrefs.m_BulletType1, m_PlayerPrefs.m_WeaponGadgetName1);
			}
			// End:0x17E
			if(bShowLog)
			{
				Log(("AcceptInventory PrimaryWeapon =" @ m_PlayerPrefs.m_WeaponName1));
			}
		}
		// End:0x2CE
		if(((!IsSecondaryWeaponRestrictedToPawn(aPawn)) && (m_PlayerPrefs.m_WeaponName2 != "")))
		{
			// End:0x1DC
			if(IsSecondaryWeaponRestricted(m_PlayerPrefs.m_WeaponName2))
			{
				szSecWeapon = "R63rdWeapons.NormalPistol92FS";				
			}
			else
			{
				szSecWeapon = m_PlayerPrefs.m_WeaponName2;
			}
			// End:0x225
			if(bShowLog)
			{
				Log(((("NOW GIVING " $ szSecWeapon) $ " to ") $ string(aPawn.Controller)));
			}
			// End:0x26E
			if(((m_PlayerPrefs.m_WeaponGadgetName2 != "") && IsSecondaryGadgetRestricted(m_PlayerPrefs.m_WeaponGadgetName2)))
			{
				aPawn.ServerGivesWeaponToClient(szSecWeapon, 2, m_PlayerPrefs.m_BulletType2);				
			}
			else
			{
				aPawn.ServerGivesWeaponToClient(szSecWeapon, 2, m_PlayerPrefs.m_BulletType2, m_PlayerPrefs.m_WeaponGadgetName2);
			}
			// End:0x2CE
			if(bShowLog)
			{
				Log(("AcceptInventory SecondaryWeapon = " $ szSecWeapon));
			}
		}
		// End:0x3A2
		if(((((!IsTertiaryWeaponRestrictedToPawn(aPawn)) && (m_PlayerPrefs.m_GadgetName1 != "")) && (!IsTertiaryWeaponRestricted(m_PlayerPrefs.m_GadgetName1))) && (!IsTertiaryWeaponRestrictedForGamePlay(aPawn, m_PlayerPrefs.m_GadgetName1))))
		{
			// End:0x352
			if(bShowLog)
			{
				Log(((" AND " $ m_PlayerPrefs.m_GadgetName1) $ "  (gadget 1)"));
			}
			aPawn.ServerGivesWeaponToClient(m_PlayerPrefs.m_GadgetName1, 3);
			// End:0x3A2
			if(bShowLog)
			{
				Log(("AcceptInventory GadgetOne = " $ m_PlayerPrefs.m_GadgetName1));
			}
		}
		// End:0x4F4
		if(((((!IsTertiaryWeaponRestrictedToPawn(aPawn)) && (m_PlayerPrefs.m_GadgetName2 != "")) && (!IsTertiaryWeaponRestricted(m_PlayerPrefs.m_GadgetName2))) && (!IsTertiaryWeaponRestrictedForGamePlay(aPawn, m_PlayerPrefs.m_GadgetName2))))
		{
			// End:0x426
			if(bShowLog)
			{
				Log(((" AND " $ m_PlayerPrefs.m_GadgetName2) $ "  (gadget 2)"));
			}
			caps_szSecGadget = Caps(m_PlayerPrefs.m_GadgetName2);
			// End:0x4A4
			if((((caps_szSecGadget != "PRIMARYMAGS") && (caps_szSecGadget != "SECONDARYMAGS")) && (caps_szSecGadget == Caps(m_PlayerPrefs.m_GadgetName1))))
			{
				aPawn.ServerGivesWeaponToClient("DoubleGadget", 4);				
			}
			else
			{
				aPawn.ServerGivesWeaponToClient(m_PlayerPrefs.m_GadgetName2, 4);
			}
			// End:0x4F4
			if(bShowLog)
			{
				Log(("AcceptInventory GadgetTwo = " $ m_PlayerPrefs.m_GadgetName2));
			}
		}
		aRainbow = R6Rainbow(PlayerPawn);
		// End:0x56E
		if((aRainbow != none))
		{
			aRainbow.m_szPrimaryWeapon = m_PlayerPrefs.m_WeaponName1;
			aRainbow.m_szSecondaryWeapon = szSecWeapon;
			aRainbow.m_szPrimaryItem = m_PlayerPrefs.m_GadgetName1;
			aRainbow.m_szSecondaryItem = m_PlayerPrefs.m_GadgetName2;
		}
		// End:0x596
		if((int(Level.NetMode) == int(NM_ListenServer)))
		{
			aPawn.ReceivedWeapons();
		}
	}
	return;
}

//------------------------------------------------------------------
// IsPrimaryWeaponRestrictedToPawn
//	
//------------------------------------------------------------------
function bool IsPrimaryWeaponRestrictedToPawn(Pawn aPawn)
{
	return false;
	return;
}

//------------------------------------------------------------------
// IsSecondaryWeaponRestrictedToPawn
//	
//------------------------------------------------------------------
function bool IsSecondaryWeaponRestrictedToPawn(Pawn aPawn)
{
	return false;
	return;
}

//------------------------------------------------------------------
// IsTertiaryWeaponRestrictedToPawn
//	
//------------------------------------------------------------------
function bool IsTertiaryWeaponRestrictedToPawn(Pawn aPawn)
{
	return false;
	return;
}

// MPF1
///////////////Begin MissionPack1
///////////////////////////
function bool IsTertiaryWeaponRestrictedForGamePlay(Pawn aPawn, string szWeaponName)
{
	return false;
	return;
}

function bool IsPrimaryWeaponRestricted(string szWeaponName)
{
	local Class<R6AbstractWeapon> WeaponClass;
	local R6GameReplicationInfo _GRI;
	local string WeaponClassNameId;

	_GRI = R6GameReplicationInfo(GameReplicationInfo);
	// End:0x36
	if((InStr(szWeaponName, "PrimaryWeaponNone") != -1))
	{
		return true;
	}
	WeaponClass = Class<R6AbstractWeapon>(DynamicLoadObject(szWeaponName, Class'Core.Class'));
	WeaponClassNameId = WeaponClass.default.m_NameID;
	// End:0x135
	if(((((IsInResArray(WeaponClassNameId, _GRI.m_szSubMachineGunsRes) || IsInResArray(WeaponClassNameId, _GRI.m_szShotGunRes)) || IsInResArray(WeaponClassNameId, _GRI.m_szAssRifleRes)) || IsInResArray(WeaponClassNameId, _GRI.m_szMachGunRes)) || IsInResArray(WeaponClassNameId, _GRI.m_szSnipRifleRes)))
	{
		// End:0x133
		if(bShowLog)
		{
			Log((szWeaponName $ " is restricted and will not be spawned"));
		}
		return true;
	}
	return false;
	return;
}

function bool IsPrimaryGadgetRestricted(string szWeaponGadgetName)
{
	local int i;
	local R6GameReplicationInfo _GRI;
	local Class<R6AbstractGadget> WeaponGadgetClass;
	local string RequestedGadget;

	// End:0x0E
	if((szWeaponGadgetName == ""))
	{
		return true;
	}
	WeaponGadgetClass = Class<R6AbstractGadget>(DynamicLoadObject(szWeaponGadgetName, Class'Core.Class'));
	RequestedGadget = WeaponGadgetClass.default.m_NameID;
	_GRI = R6GameReplicationInfo(GameReplicationInfo);
	// End:0x6B
	if(IsInResArray(RequestedGadget, _GRI.m_szGadgPrimaryRes))
	{
		return true;
	}
	return false;
	return;
}

function bool IsSecondaryGadgetRestricted(string szWeaponGadgetName)
{
	local int i;
	local R6GameReplicationInfo _GRI;
	local Class<R6AbstractGadget> WeaponGadgetClass;
	local string RequestedGadget;

	// End:0x0E
	if((szWeaponGadgetName == ""))
	{
		return true;
	}
	WeaponGadgetClass = Class<R6AbstractGadget>(DynamicLoadObject(szWeaponGadgetName, Class'Core.Class'));
	RequestedGadget = WeaponGadgetClass.default.m_NameID;
	_GRI = R6GameReplicationInfo(GameReplicationInfo);
	// End:0xA5
	if(IsInResArray(RequestedGadget, _GRI.m_szGadgSecondayRes))
	{
		// End:0xA3
		if(bShowLog)
		{
			Log((szWeaponGadgetName $ " is restricted and will not be spawned"));
		}
		return true;
	}
	return false;
	return;
}

function bool IsSecondaryWeaponRestricted(string szWeaponName)
{
	local int i;
	local R6GameReplicationInfo _GRI;
	local Class<R6AbstractWeapon> WeaponClass;
	local string RequestedWeapon;
	local Class<R6SecondaryWeaponDescription> SecondaryWeaponClass;

	_GRI = R6GameReplicationInfo(GameReplicationInfo);
	WeaponClass = Class<R6AbstractWeapon>(DynamicLoadObject(szWeaponName, Class'Core.Class'));
	RequestedWeapon = WeaponClass.default.m_NameID;
	// End:0xB5
	if((IsInResArray(RequestedWeapon, _GRI.m_szPistolRes) || IsInResArray(RequestedWeapon, _GRI.m_szMachPistolRes)))
	{
		// End:0xB3
		if(bShowLog)
		{
			Log((szWeaponName $ " is restricted and will not be spawned"));
		}
		return true;
	}
	return false;
	return;
}

// granades, frags, flashbangs, HB sensors etc
function bool IsTertiaryWeaponRestricted(string szWeaponName)
{
	local int i;
	local R6GameReplicationInfo _GRI;
	local Class<R6AbstractWeapon> WeaponClass;
	local string RequestedWeapon;
	local Class<R6SecondaryWeaponDescription> SecondaryWeaponClass;
	local Class<R6GadgetDescription> _GadgetClass;

	_GRI = R6GameReplicationInfo(GameReplicationInfo);
	// End:0x1E
	if((szWeaponName == ""))
	{
		return true;
	}
	// End:0x78
	if((Class<R6AbstractWeapon>(FindObject(szWeaponName, Class'Core.Class')) != none))
	{
		WeaponClass = Class<R6AbstractWeapon>(DynamicLoadObject(szWeaponName, Class'Core.Class'));
		// End:0x61
		if((WeaponClass == none))
		{
			return false;
		}
		RequestedWeapon = WeaponClass.default.m_NameID;		
	}
	else
	{
		RequestedWeapon = szWeaponName;
	}
	// End:0xDB
	if(IsInResArray(RequestedWeapon, _GRI.m_szGadgMiscRes))
	{
		// End:0xD9
		if(bShowLog)
		{
			Log((szWeaponName $ " is restricted and will not be spawned"));
		}
		return true;
	}
	return false;
	return;
}

function bool IsInResArray(string szWeaponNameId, string RestrictionArray[32])
{
	local int i;

	i = 0;
	J0x07:

	// End:0x82 [Loop If]
	if(((i < 32) && (RestrictionArray[i] != "")))
	{
		// End:0x78
		if((RestrictionArray[i] ~= szWeaponNameId))
		{
			// End:0x76
			if(bShowLog)
			{
				Log((szWeaponNameId $ " is restricted and will not be spawned"));
			}
			return true;
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return false;
	return;
}

//============================================================================
// PostBeginPlay - 
//============================================================================
function PostBeginPlay()
{
	local R6DeploymentZone PZone;
	local int i;
	local bool bFound;
	local array<string> AGadgetNameID;
	local R6ServerInfo pServerOptions;

	super.PostBeginPlay();
	pServerOptions = Class'Engine.Actor'.static.GetServerOptions();
	Level.m_ServerSettings = pServerOptions;
	CreateMissionObjectiveMgr();
	m_missionMgr.m_bEnableCheckForErrors = false;
	InitObjectives();
	// End:0x79
	if((int(Level.NetMode) != int(NM_Standalone)))
	{
		R6GameReplicationInfo(GameReplicationInfo).m_iMapIndex = GetCurrentMapNum();
	}
	R6GameReplicationInfo(GameReplicationInfo).m_szGameTypeFlagRep = m_szGameTypeFlag;
	R6GameReplicationInfo(GameReplicationInfo).m_iDeathCameraMode = m_iDeathCameraMode;
	// End:0x129
	if(((int(Level.NetMode) == int(NM_DedicatedServer)) || (int(Level.NetMode) == int(NM_ListenServer))))
	{
		bPauseable = false;
		m_szSvrName = Left(pServerOptions.ServerName, m_GameService.GetMaxUbiServerNameSize());
		// End:0x129
		if((m_szSvrName != ""))
		{
			GameReplicationInfo.ServerName = m_szSvrName;
		}
	}
	R6GameReplicationInfo(GameReplicationInfo).m_iRoundsPerMatch = m_iRoundsPerMatch;
	R6GameReplicationInfo(GameReplicationInfo).m_iDiffLevel = m_iDiffLevel;
	R6GameReplicationInfo(GameReplicationInfo).m_iNbOfTerro = m_iNbOfTerroristToSpawn;
	R6GameReplicationInfo(GameReplicationInfo).m_fTimeBetRounds = m_fTimeBetRounds;
	R6GameReplicationInfo(GameReplicationInfo).m_bPasswordReq = AccessControl.GamePasswordNeeded();
	R6GameReplicationInfo(GameReplicationInfo).m_bFriendlyFire = m_bFriendlyFire;
	R6GameReplicationInfo(GameReplicationInfo).m_bAutoBalance = m_bAutoBalance;
	R6GameReplicationInfo(GameReplicationInfo).m_bMenuTKPenaltySetting = m_bTKPenalty;
	m_bTKPenalty = (m_bTKPenalty && Level.IsGameTypeTeamAdversarial(m_szGameTypeFlag));
	R6GameReplicationInfo(GameReplicationInfo).m_bTKPenalty = m_bTKPenalty;
	R6GameReplicationInfo(GameReplicationInfo).m_bShowNames = m_bShowNames;
	R6GameReplicationInfo(GameReplicationInfo).m_MaxPlayers = MaxPlayers;
	R6GameReplicationInfo(GameReplicationInfo).m_fBombTime = m_fBombTime;
	R6GameReplicationInfo(GameReplicationInfo).m_bInternetSvr = m_bInternetSvr;
	R6GameReplicationInfo(GameReplicationInfo).m_bFFPWeapon = m_bFFPWeapon;
	R6GameReplicationInfo(GameReplicationInfo).m_bAIBkp = m_bAIBkp;
	R6GameReplicationInfo(GameReplicationInfo).m_bRotateMap = m_bRotateMap;
	R6GameReplicationInfo(GameReplicationInfo).m_bAdminPasswordReq = m_bAdminPasswordReq;
	R6GameReplicationInfo(GameReplicationInfo).m_bDedicatedSvr = (int(Level.NetMode) == int(NM_DedicatedServer));
	R6GameReplicationInfo(GameReplicationInfo).m_bIsWritableMapAllowed = m_bIsWritableMapAllowed;
	R6GameReplicationInfo(GameReplicationInfo).m_bPunkBuster = IsPBServerEnabled();
	// End:0x398
	if(m_bIsWritableMapAllowed)
	{
		AddSoundBankName("Common_Multiplayer");
	}
	SetTimer(2.0000000, true);
	i = 0;
	J0x3A8:

	// End:0x474 [Loop If]
	if((i < R6GameReplicationInfo(GameReplicationInfo).32))
	{
		// End:0x3FA
		if((i < m_mapList.Length))
		{
			R6GameReplicationInfo(GameReplicationInfo).m_mapArray[i] = m_mapList[i];			
		}
		else
		{
			R6GameReplicationInfo(GameReplicationInfo).m_mapArray[i] = "";
		}
		// End:0x44E
		if((i < m_gameModeList.Length))
		{
			R6GameReplicationInfo(GameReplicationInfo).m_gameModeArray[i] = m_gameModeList[i];
			// [Explicit Continue]
			goto J0x46A;
		}
		R6GameReplicationInfo(GameReplicationInfo).m_gameModeArray[i] = "";
		J0x46A:

		(i++);
		// [Loop Continue]
		goto J0x3A8;
	}
	UpdateRepResArrays();
	// End:0x4A1
	if((int(Level.NetMode) == int(NM_DedicatedServer)))
	{
		m_PersistantGameService = m_GameService;		
	}
	else
	{
		// End:0x4EC
		if((int(Level.NetMode) == int(NM_ListenServer)))
		{
			m_PersistantGameService = R6Console(Class'Engine.Actor'.static.GetCanvas().Viewport.Console).m_GameService;
		}
	}
	return;
}

function UpdateRepResArrays()
{
	local Class<R6SubGunDescription> SubGunClass;
	local Class<R6ShotgunDescription> ShotGunClass;
	local Class<R6AssaultDescription> AssaultRifleClass;
	local Class<R6LMGDescription> MachGunClass;
	local Class<R6SniperDescription> SniperRifleClass;
	local Class<R6PistolsDescription> PistolClass;
	local Class<R6MachinePistolsDescription> MachPistolClass;
	local Class<R6WeaponGadgetDescription> PriGadgClass, SecGadgClass;
	local Class<R6GadgetDescription> MiscGadgClass;
	local R6ServerInfo pServerOptions;
	local int i;
	local R6GameReplicationInfo _GRI;

	pServerOptions = Level.m_ServerSettings;
	_GRI = R6GameReplicationInfo(GameReplicationInfo);
	// End:0x6A9
	if((int(Level.NetMode) != int(NM_Standalone)))
	{
		i = 0;
		J0x44:

		// End:0x71 [Loop If]
		if((i < 32))
		{
			_GRI.m_szSubMachineGunsRes[i] = "";
			(i++);
			// [Loop Continue]
			goto J0x44;
		}
		i = 0;
		J0x78:

		// End:0xEE [Loop If]
		if((i < pServerOptions.RestrictedSubMachineGuns.Length))
		{
			SubGunClass = Class<R6SubGunDescription>(DynamicLoadObject(("" $ string(pServerOptions.RestrictedSubMachineGuns[i])), Class'Core.Class'));
			_GRI.m_szSubMachineGunsRes[i] = SubGunClass.default.m_NameID;
			(i++);
			// [Loop Continue]
			goto J0x78;
		}
		i = 0;
		J0xF5:

		// End:0x122 [Loop If]
		if((i < 32))
		{
			_GRI.m_szShotGunRes[i] = "";
			(i++);
			// [Loop Continue]
			goto J0xF5;
		}
		i = 0;
		J0x129:

		// End:0x19F [Loop If]
		if((i < pServerOptions.RestrictedShotGuns.Length))
		{
			ShotGunClass = Class<R6ShotgunDescription>(DynamicLoadObject(("" $ string(pServerOptions.RestrictedShotGuns[i])), Class'Core.Class'));
			_GRI.m_szShotGunRes[i] = ShotGunClass.default.m_NameID;
			(i++);
			// [Loop Continue]
			goto J0x129;
		}
		i = 0;
		J0x1A6:

		// End:0x1D3 [Loop If]
		if((i < 32))
		{
			_GRI.m_szAssRifleRes[i] = "";
			(i++);
			// [Loop Continue]
			goto J0x1A6;
		}
		i = 0;
		J0x1DA:

		// End:0x250 [Loop If]
		if((i < pServerOptions.RestrictedAssultRifles.Length))
		{
			AssaultRifleClass = Class<R6AssaultDescription>(DynamicLoadObject(("" $ string(pServerOptions.RestrictedAssultRifles[i])), Class'Core.Class'));
			_GRI.m_szAssRifleRes[i] = AssaultRifleClass.default.m_NameID;
			(i++);
			// [Loop Continue]
			goto J0x1DA;
		}
		i = 0;
		J0x257:

		// End:0x284 [Loop If]
		if((i < 32))
		{
			_GRI.m_szMachGunRes[i] = "";
			(i++);
			// [Loop Continue]
			goto J0x257;
		}
		i = 0;
		J0x28B:

		// End:0x301 [Loop If]
		if((i < pServerOptions.RestrictedMachineGuns.Length))
		{
			MachGunClass = Class<R6LMGDescription>(DynamicLoadObject(("" $ string(pServerOptions.RestrictedMachineGuns[i])), Class'Core.Class'));
			_GRI.m_szMachGunRes[i] = MachGunClass.default.m_NameID;
			(i++);
			// [Loop Continue]
			goto J0x28B;
		}
		i = 0;
		J0x308:

		// End:0x335 [Loop If]
		if((i < 32))
		{
			_GRI.m_szSnipRifleRes[i] = "";
			(i++);
			// [Loop Continue]
			goto J0x308;
		}
		i = 0;
		J0x33C:

		// End:0x3B2 [Loop If]
		if((i < pServerOptions.RestrictedSniperRifles.Length))
		{
			SniperRifleClass = Class<R6SniperDescription>(DynamicLoadObject(("" $ string(pServerOptions.RestrictedSniperRifles[i])), Class'Core.Class'));
			_GRI.m_szSnipRifleRes[i] = SniperRifleClass.default.m_NameID;
			(i++);
			// [Loop Continue]
			goto J0x33C;
		}
		i = 0;
		J0x3B9:

		// End:0x3E6 [Loop If]
		if((i < 32))
		{
			_GRI.m_szPistolRes[i] = "";
			(i++);
			// [Loop Continue]
			goto J0x3B9;
		}
		i = 0;
		J0x3ED:

		// End:0x463 [Loop If]
		if((i < pServerOptions.RestrictedPistols.Length))
		{
			PistolClass = Class<R6PistolsDescription>(DynamicLoadObject(("" $ string(pServerOptions.RestrictedPistols[i])), Class'Core.Class'));
			_GRI.m_szPistolRes[i] = PistolClass.default.m_NameID;
			(i++);
			// [Loop Continue]
			goto J0x3ED;
		}
		i = 0;
		J0x46A:

		// End:0x497 [Loop If]
		if((i < 32))
		{
			_GRI.m_szMachPistolRes[i] = "";
			(i++);
			// [Loop Continue]
			goto J0x46A;
		}
		i = 0;
		J0x49E:

		// End:0x514 [Loop If]
		if((i < pServerOptions.RestrictedMachinePistols.Length))
		{
			MachPistolClass = Class<R6MachinePistolsDescription>(DynamicLoadObject(("" $ string(pServerOptions.RestrictedMachinePistols[i])), Class'Core.Class'));
			_GRI.m_szMachPistolRes[i] = MachPistolClass.default.m_NameID;
			(i++);
			// [Loop Continue]
			goto J0x49E;
		}
		i = 0;
		J0x51B:

		// End:0x548 [Loop If]
		if((i < 32))
		{
			_GRI.m_szGadgPrimaryRes[i] = "";
			(i++);
			// [Loop Continue]
			goto J0x51B;
		}
		i = 0;
		J0x54F:

		// End:0x59B [Loop If]
		if((i < pServerOptions.RestrictedPrimary.Length))
		{
			_GRI.m_szGadgPrimaryRes[i] = pServerOptions.RestrictedPrimary[i];
			(i++);
			// [Loop Continue]
			goto J0x54F;
		}
		i = 0;
		J0x5A2:

		// End:0x5CF [Loop If]
		if((i < 32))
		{
			_GRI.m_szGadgSecondayRes[i] = "";
			(i++);
			// [Loop Continue]
			goto J0x5A2;
		}
		i = 0;
		J0x5D6:

		// End:0x622 [Loop If]
		if((i < pServerOptions.RestrictedSecondary.Length))
		{
			_GRI.m_szGadgSecondayRes[i] = pServerOptions.RestrictedSecondary[i];
			(i++);
			// [Loop Continue]
			goto J0x5D6;
		}
		i = 0;
		J0x629:

		// End:0x656 [Loop If]
		if((i < 32))
		{
			_GRI.m_szGadgMiscRes[i] = "";
			(i++);
			// [Loop Continue]
			goto J0x629;
		}
		i = 0;
		J0x65D:

		// End:0x6A9 [Loop If]
		if((i < pServerOptions.RestrictedMiscGadgets.Length))
		{
			_GRI.m_szGadgMiscRes[i] = pServerOptions.RestrictedMiscGadgets[i];
			(i++);
			// [Loop Continue]
			goto J0x65D;
		}
	}
	return;
}

//============================================================================
// InitGame -  Initialize the game.
// The GameInfo's InitGame() function is called before any other scripts (including 
// PreBeginPlay() ), and is used by the GameInfo to initialize parameters and spawn 
// its helper classes.
// Warning: this is called before actors' PreBeginPlay.
//  restriction kit is taken care of in PostBeginPlay
//============================================================================
event InitGame(string Options, out string Error)
{
	local string InOpt;
	local MapList myList;
	local Class<MapList> ML;
	local string KeyName;
	local int iCounter;
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.GetServerOptions();
	// End:0x2C
	if((pServerOptions == none))
	{
		pServerOptions = new Class'Engine.R6ServerInfo';
	}
	pServerOptions.m_GameInfo = self;
	m_szGameOptions = Options;
	super(GameInfo).InitGame(Options, Error);
	// End:0x95
	if((pServerOptions.m_ServerMapList == none))
	{
		myList = Spawn(Class'Engine.R6MapList');
		pServerOptions.m_ServerMapList = R6MapList(myList);		
	}
	else
	{
		myList = pServerOptions.m_ServerMapList;
	}
	// End:0x106
	if((BroadcastHandler == none))
	{
		Log(((("failed to create BroadcastHandlerClass=" $ BroadcastHandlerClass) $ "  BroadcastHandler=") $ string(BroadcastHandler)));
	}
	// End:0x14C
	if((pServerOptions.UsePassword && (pServerOptions.GamePassword != "")))
	{
		AccessControl.SetGamePassword(pServerOptions.GamePassword);
	}
	MaxPlayers = Min(16, pServerOptions.MaxPlayers);
	m_szMessageOfDay = pServerOptions.MOTD;
	m_szSvrName = pServerOptions.ServerName;
	m_bInternetSvr = pServerOptions.InternetServer;
	Level.m_fTimeLimit = float(pServerOptions.RoundTime);
	m_iRoundsPerMatch = pServerOptions.RoundsPerMatch;
	m_fTimeBetRounds = float(pServerOptions.BetweenRoundTime);
	m_fBombTime = float(pServerOptions.BombTime);
	m_bFriendlyFire = pServerOptions.FriendlyFire;
	m_bAutoBalance = pServerOptions.Autobalance;
	m_bAdminPasswordReq = pServerOptions.UseAdminPassword;
	m_bFFPWeapon = pServerOptions.ForceFPersonWeapon;
	m_bTKPenalty = pServerOptions.TeamKillerPenalty;
	m_bShowNames = pServerOptions.ShowNames;
	m_bAIBkp = pServerOptions.AIBkp;
	// End:0x30B
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		// End:0x2C9
		if(IsA('R6TrainingMgr'))
		{
			m_iDiffLevel = 1;			
		}
		else
		{
			m_iDiffLevel = Class'Engine.Actor'.static.GetCanvas().Viewport.Console.Master.m_StartGameInfo.m_DifficultyLevel;
		}		
	}
	else
	{
		m_iDiffLevel = pServerOptions.DiffLevel;
	}
	m_bRepAllowRadarOption = pServerOptions.AllowRadar;
	// End:0x34E
	if(m_bIsRadarAllowed)
	{
		m_bServerAllowRadarRep = m_bRepAllowRadarOption;		
	}
	else
	{
		m_bServerAllowRadarRep = false;
	}
	// End:0x3DF
	if(bShowLog)
	{
		Log(((((("RADAR: m_bIsRadarAllowed =" $ string(m_bIsRadarAllowed)) $ " pServerOptions.AllowRadar=") $ string(pServerOptions.AllowRadar)) $ " m_bServerAllowRadarRep=") $ string(m_bServerAllowRadarRep)));
	}
	m_mapList.Remove(0, m_mapList.Length);
	m_gameModeList.Remove(0, m_gameModeList.Length);
	iCounter = 0;
	J0x400:

	// End:0x4A5 [Loop If]
	if((iCounter < 32))
	{
		Level.PreBeginPlay();
		// End:0x456
		if((iCounter == GetCurrentMapNum()))
		{
			m_szCurrGameType = Level.GetGameTypeFromClassName(R6MapList(myList).GameType[iCounter]);
		}
		m_mapList[iCounter] = myList.Maps[iCounter];
		m_gameModeList[iCounter] = R6MapList(myList).GameType[iCounter];
		(iCounter++);
		// [Loop Continue]
		goto J0x400;
	}
	m_iNbOfTerroristToSpawn = pServerOptions.NbTerro;
	m_iDeathCameraMode = 0;
	// End:0x4E2
	if(pServerOptions.CamFirstPerson)
	{
		m_iDeathCameraMode = Level.1;
	}
	// End:0x50C
	if(pServerOptions.CamThirdPerson)
	{
		m_iDeathCameraMode = (m_iDeathCameraMode | Level.2);
	}
	// End:0x536
	if(pServerOptions.CamFreeThirdP)
	{
		m_iDeathCameraMode = (m_iDeathCameraMode | Level.4);
	}
	// End:0x560
	if(pServerOptions.CamGhost)
	{
		m_iDeathCameraMode = (m_iDeathCameraMode | Level.8);
	}
	// End:0x5D7
	if(pServerOptions.CamTeamOnly)
	{
		// End:0x5D7
		if((!((Level.IsGameTypeAdversarial(m_szCurrGameType) || Level.IsGameTypeSquad(m_szCurrGameType)) && (!Level.IsGameTypeTeamAdversarial(m_szCurrGameType)))))
		{
			m_iDeathCameraMode = (m_iDeathCameraMode | Level.32);
		}
	}
	// End:0x5FA
	if(pServerOptions.CamFadeToBlack)
	{
		m_iDeathCameraMode = Level.16;
	}
	// End:0x62A
	if(Level.IsGameTypeCooperative(m_szGameTypeFlag))
	{
		m_bRotateMap = pServerOptions.RotateMap;		
	}
	else
	{
		m_bRotateMap = false;
	}
	return;
}

function SetGamePassword(string szPasswd)
{
	super(GameInfo).SetGamePassword(szPasswd);
	m_GameService.NativeUpdateServer();
	return;
}

function CreateBackupRainbowAI()
{
	local R6RainbowAI rainbowAI;
	local int i;
	local R6ModMgr pModManager;

	// End:0x1B
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		return;
	}
	pModManager = Class'Engine.Actor'.static.GetModMgr();
	i = 0;
	J0x34:

	// End:0x8A [Loop If]
	if((i < 6))
	{
		rainbowAI = R6RainbowAI(Spawn(pModManager.GetDefaultRainbowAI()));
		rainbowAI.bStasis = true;
		m_RainbowAIBackup[m_RainbowAIBackup.Length] = rainbowAI;
		(i++);
		// [Loop Continue]
		goto J0x34;
	}
	return;
}

//============================================================================
// GetRainbowAIFromTable 
//============================================================================
function Actor GetRainbowAIFromTable()
{
	local R6RainbowAI rainbowAI;
	local int i;

	// End:0x36
	if(((int(Level.NetMode) == int(NM_Standalone)) || (int(Level.NetMode) == int(NM_Client))))
	{
		return none;
	}
	// End:0x44
	if((m_RainbowAIBackup.Length == 0))
	{
		return none;
	}
	rainbowAI = m_RainbowAIBackup[0];
	rainbowAI.bStasis = false;
	m_RainbowAIBackup.Remove(0, 1);
	return rainbowAI;
	return;
}

//============================================================================
// DeployRainbowTeam 
//  spawn a Rainbow Team in multiplayer 
//============================================================================
function DeployRainbowTeam(PlayerController NewPlayer)
{
	local R6RainbowTeam newTeam;
	local int iMembers, iActiveTotal, iActiveGreen;
	local R6RainbowStartInfo Info;

	// End:0x4E9
	if((int(Level.NetMode) != int(NM_Standalone)))
	{
		// End:0x75
		if(bShowLog)
		{
			Log(((("DeployRainbowTeam newPlayer=" $ string(NewPlayer)) $ " iNbOfRainbowAIToSpawn=") $ string(GetNbOfRainbowAIToSpawn(NewPlayer))));
		}
		newTeam = Spawn(Class'R6Engine.R6RainbowTeam');
		newTeam.SetOwner(NewPlayer);
		// End:0x132
		if(((m_bAIBkp && (!R6PlayerController(NewPlayer).m_bPenaltyBox)) && Level.IsGameTypeCooperative(m_szGameTypeFlag)))
		{
			GetNbHumanPlayerInTeam(iActiveTotal, iActiveGreen);
			(iActiveTotal += iActiveGreen);
			switch(iActiveTotal)
			{
				// End:0xF8
				case 1:
				// End:0x108
				case 2:
					iMembers = 4;
					// End:0x132
					break;
				// End:0x118
				case 3:
					iMembers = 2;
					// End:0x132
					break;
				// End:0x128
				case 4:
					iMembers = 2;
					// End:0x132
					break;
				// End:0xFFFF
				default:
					iMembers = 1;
					break;
			}
		}
		SetRainbowTeam(0, newTeam);
		Info = Spawn(Class'Engine.R6RainbowStartInfo');
		// End:0x186
		if((NewPlayer.PlayerReplicationInfo != none))
		{
			Info.m_CharacterName = NewPlayer.PlayerReplicationInfo.PlayerName;
		}
		Info.m_ArmorName = ("" $ string(NewPlayer.PawnClass));
		// End:0x1EB
		if((!IsPrimaryWeaponRestricted(NewPlayer.m_PlayerPrefs.m_WeaponName1)))
		{
			Info.m_WeaponName[0] = NewPlayer.m_PlayerPrefs.m_WeaponName1;
		}
		// End:0x230
		if((!IsSecondaryWeaponRestricted(NewPlayer.m_PlayerPrefs.m_WeaponName2)))
		{
			Info.m_WeaponName[1] = NewPlayer.m_PlayerPrefs.m_WeaponName2;			
		}
		else
		{
			Info.m_WeaponName[1] = "R63rdWeapons.NormalPistol92FS";
		}
		Info.m_BulletType[0] = NewPlayer.m_PlayerPrefs.m_BulletType1;
		Info.m_BulletType[1] = NewPlayer.m_PlayerPrefs.m_BulletType2;
		// End:0x2EA
		if((!IsPrimaryGadgetRestricted(NewPlayer.m_PlayerPrefs.m_WeaponGadgetName1)))
		{
			Info.m_WeaponGadgetName[0] = NewPlayer.m_PlayerPrefs.m_WeaponGadgetName1;
		}
		// End:0x32C
		if((!IsSecondaryGadgetRestricted(NewPlayer.m_PlayerPrefs.m_WeaponGadgetName2)))
		{
			Info.m_WeaponGadgetName[1] = NewPlayer.m_PlayerPrefs.m_WeaponGadgetName2;
		}
		// End:0x36E
		if((!IsTertiaryWeaponRestricted(NewPlayer.m_PlayerPrefs.m_GadgetName1)))
		{
			Info.m_GadgetName[0] = NewPlayer.m_PlayerPrefs.m_GadgetName1;
		}
		// End:0x3B0
		if((!IsTertiaryWeaponRestricted(NewPlayer.m_PlayerPrefs.m_GadgetName2)))
		{
			Info.m_GadgetName[1] = NewPlayer.m_PlayerPrefs.m_GadgetName2;
		}
		Info.m_iOperativeID = R6Rainbow(NewPlayer.Pawn).m_iOperativeID;
		Info.m_bIsMale = (!NewPlayer.Pawn.bIsFemale);
		Info.m_iHealth = 0;
		Info.m_FaceTexture = DefaultFaceTexture;
		Info.m_FaceCoords = DefaultFaceCoords;
		newTeam.CreateMPPlayerTeam(NewPlayer, Info, iMembers, PlayerStart(NewPlayer.StartSpot));
		newTeam.SetMultiVoicesMgr(self, R6Pawn(NewPlayer.Pawn).m_iTeam, iMembers);
		ServerSendBankToLoad();
		R6PlayerController(NewPlayer).m_TeamManager = newTeam;
		newTeam.SetMemberTeamID(R6Pawn(NewPlayer.Pawn).m_iTeam);
	}
	return;
}

// NEW IN 1.60
event PlayerController Login(string Portal, string Options, out string Error)
{
	local NavigationPoint StartSpot;
	local PlayerController NewPlayer;
	local Pawn TestPawn;
	local string InName, InPassword, InChecksum, InClass;
	local byte InTeam;
	local int i;
	local Actor A;
	local int iSpawnPointNum;
	local Rotator rStartSpotRot;

	StartSpot = R6FindPlayerStart(none, iSpawnPointNum, Portal);
	// End:0x60
	if((StartSpot == none))
	{
		Error = Localize("MPMiscMessages", "FailedPlaceMessage", "R6GameInfo");
		return none;
	}
	// End:0xB1
	if(((PlayerControllerClass == none) && (int(Level.NetMode) == int(NM_Standalone))))
	{
		PlayerControllerClass = Class<PlayerController>(DynamicLoadObject(PlayerControllerClassName, Class'Core.Class'));
		Log((string(PlayerControllerClass) @ PlayerControllerClassName));
	}
	rStartSpotRot = StartSpot.Rotation;
	rStartSpotRot.Roll = 0;
	NewPlayer = Spawn(PlayerControllerClass,,, StartSpot.Location, rStartSpotRot);
	NewPlayer.StartSpot = StartSpot;
	// End:0x188
	if((NewPlayer == none))
	{
		Log(("Couldn't spawn player controller of class " $ string(PlayerControllerClass)));
		Error = Localize("MPMiscMessages", "FailedSpawnMessage", "R6GameInfo");
		return none;
	}
	// End:0x19F
	if((InName == ""))
	{
		InName = DefaultPlayerName;
	}
	// End:0x202
	if(((int(Level.NetMode) != int(NM_Standalone)) || ((NewPlayer.PlayerReplicationInfo != none) && (NewPlayer.PlayerReplicationInfo.PlayerName == DefaultPlayerName))))
	{
		ChangeName(NewPlayer, InName, false);
	}
	NewPlayer.GameReplicationInfo = GameReplicationInfo;
	NewPlayer.GotoState('Spectating');
	// End:0x259
	if((NewPlayer.PlayerReplicationInfo != none))
	{
		NewPlayer.PlayerReplicationInfo.PlayerID = (CurrentID++);
	}
	// End:0x298
	if(((int(Level.NetMode) != int(NM_Standalone)) && (InClass == "")))
	{
		InClass = ParseOption(Options, "Class");
	}
	// End:0x2C8
	if((InClass != ""))
	{
		NewPlayer.PawnClass = Class<Pawn>(DynamicLoadObject(InClass, Class'Core.Class'));
	}
	// End:0x2E7
	if((StatLog != none))
	{
		StatLog.LogPlayerConnect(NewPlayer);
	}
	NewPlayer.ReceivedSecretChecksum = (!(InChecksum ~= "NoChecksum"));
	(NumPlayers++);
	bRestartLevel = false;
	StartMatch();
	NotifyMatchStart();
	bRestartLevel = default.bRestartLevel;
	m_Player = NewPlayer;
	// End:0x3A5
	if(bShowLog)
	{
		Log((((" ********  Login() is called....playerCont = " $ string(NewPlayer)) $ "  and pawn = ") $ string(NewPlayer.Pawn)));
	}
	return NewPlayer;
	return;
}

event PreLogOut(PlayerController ExitingPlayer)
{
	Logout(ExitingPlayer);
	return;
}

// remove this player's AI Backup if there are any
function RemoveAIBackup(R6PlayerController _playerController)
{
	local int iMember, iMemberCount;

	// End:0x16
	if((_playerController.m_TeamManager == none))
	{
		return;
	}
	iMember = 1;
	J0x1D:

	// End:0x99 [Loop If]
	if((iMember < 4))
	{
		// End:0x8F
		if((_playerController.m_TeamManager.m_Team[iMember] != none))
		{
			_playerController.m_TeamManager.m_Team[iMember].Destroy();
			_playerController.m_TeamManager.m_Team[iMember] = none;
		}
		(iMember++);
		// [Loop Continue]
		goto J0x1D;
	}
	_playerController.m_TeamManager.m_iMemberCount = 0;
	return;
}

function Logout(Controller Exiting)
{
	local bool bMessage;
	local Controller P;
	local R6PlayerController _playerController, _iterController;
	local int iAlphaNb, iBravoNb;

	m_GameService.NativeUpdateServer();
	bMessage = true;
	_playerController = R6PlayerController(Exiting);
	// End:0x31
	if((_playerController == none))
	{
		return;
	}
	// End:0x48
	if((_playerController.m_PreLogOut == true))
	{
		return;
	}
	_playerController.m_PreLogOut = true;
	// End:0x76
	if(_playerController.bOnlySpectator)
	{
		bMessage = false;		
	}
	else
	{
		// End:0xC4
		if(bShowLog)
		{
			Log((((string(Exiting) $ "Player has quit the game ") $ string(Exiting.Pawn)) $ ": suicide"));
		}
		// End:0xF1
		if((m_bAIBkp && Level.IsGameTypeCooperative(m_szGameTypeFlag)))
		{
			RemoveAIBackup(_playerController);
		}
		// End:0x151
		if(((Exiting.Pawn != none) && R6Pawn(Exiting.Pawn).IsAlive()))
		{
			// End:0x151
			if((!bChangeLevels))
			{
				R6Pawn(Exiting.Pawn).ServerSuicidePawn(1);
			}
		}
	}
	(NumPlayers--);
	// End:0x244
	if(((int(Level.NetMode) == int(NM_DedicatedServer)) || (int(Level.NetMode) == int(NM_ListenServer))))
	{
		GetNbHumanPlayerInTeam(iAlphaNb, iBravoNb);
		// End:0x1BC
		if((int(_playerController.m_TeamSelection) == int(2)))
		{
			(iAlphaNb--);
		}
		// End:0x1EF
		if(Level.IsGameTypeCooperative(m_szGameTypeFlag))
		{
			SetCompilingStats((iAlphaNb > 0));
			SetRoundRestartedByJoinFlag((iAlphaNb == 0));
		}
		NativeRouterDisconnect(Exiting);
		// End:0x220
		if((Exiting == m_PlayerKick))
		{
			m_PlayerKick = none;
			m_VoteInstigatorName = "";
			m_fEndVoteTime = 0.0000000;
		}
		// End:0x244
		if(bMessage)
		{
			BroadcastLocalizedMessage(GameMessageClass, 4, Exiting.PlayerReplicationInfo);
		}
	}
	// End:0x263
	if((StatLog != none))
	{
		StatLog.LogPlayerDisconnect(Exiting);
	}
	return;
}

//============================================================================
// BOOL SpawnNumberToNavPoint - 
//============================================================================
function bool SpawnNumberToNavPoint(int _iSpawnNumber, out NavigationPoint _StartNavPoint)
{
	local R6AbstractInsertionZone NavPoint;
	local Controller OtherPlayer;
	local float NextDist;

	// End:0x191
	foreach AllActors(Class'R6Abstract.R6AbstractInsertionZone', NavPoint)
	{
		// End:0x190
		if(((NavPoint.m_iInsertionNumber == _iSpawnNumber) && NavPoint.IsAvailableInGameType(m_szGameTypeFlag)))
		{
			OtherPlayer = Level.ControllerList;
			J0x52:

			// End:0x182 [Loop If]
			if((OtherPlayer != none))
			{
				// End:0x16B
				if(((OtherPlayer.bIsPlayer && (OtherPlayer.Pawn != none)) && (OtherPlayer.Pawn.Region.Zone == NavPoint.Region.Zone)))
				{
					NextDist = VSize((OtherPlayer.Pawn.Location - NavPoint.Location));
					// End:0x16B
					if((NextDist < (OtherPlayer.Pawn.CollisionRadius + OtherPlayer.Pawn.CollisionHeight)))
					{
						Log((("SPAWNNUMBERTONAVPOINT: Player" @ string(OtherPlayer.Pawn)) @ "is in the way"));						
						return false;
					}
				}
				OtherPlayer = OtherPlayer.nextController;
				// [Loop Continue]
				goto J0x52;
			}
			_StartNavPoint = NavPoint;			
			return true;
		}		
	}	
	return false;
	return;
}

//============================================================================
// NavigationPoint R6FindPlayerStart - 
//============================================================================
function NavigationPoint R6FindPlayerStart(Controller Player, optional int SpawnPointNumber, optional string incomingName)
{
	local NavigationPoint NavPoint;
	local PlayerStart _tempStart, _checkStarts;

	// End:0x61
	if(bShowLog)
	{
		Log(((((((string(self) @ ": R6FindPlayerStart for") @ string(Player)) @ "Name is") @ incomingName) @ " spawn number is") @ string(SpawnPointNumber)));
	}
	return FindPlayerStart(Player, byte(SpawnPointNumber));
	return;
}

//============================================================================
// NavigationPoint FindPlayerStart - 
//============================================================================
function NavigationPoint FindPlayerStart(Controller Player, optional byte InTeam, optional string incomingName)
{
	local R6AbstractInsertionZone NavPoint, BestStart;
	local PlayerStart _tempStart;
	local float BestRating, NewRating;
	local PlayerStart _checkStarts;
	local string szGameType;

	szGameType = R6AbstractGameInfo(Level.Game).m_szGameTypeFlag;
	// End:0x85
	if(bShowLog)
	{
		Log(((((((string(self) @ ": R6GameInfo FindPlayerStart for") @ string(Player)) @ "Name is") @ incomingName) @ "Spawn num") @ string(InTeam)));
	}
	// End:0x166
	foreach AllActors(Class'Engine.PlayerStart', _checkStarts)
	{
		// End:0xBC
		if(bShowLog)
		{
			Log(("Found PlayerStart" @ string(_checkStarts)));
		}
		// End:0x165
		if((!_checkStarts.IsA('R6AbstractInsertionZone')))
		{
			_tempStart = _checkStarts;
			// End:0x165
			if((!_checkStarts.IsA('MP2FreeBackupInsertionZone')))
			{
				Log((("WARNING - Please make sure that the PlayerStart " $ string(_checkStarts)) $ " is replaced with an R6InsertionZone type instead"));
			}
		}		
	}	
	// End:0x1D2
	foreach AllActors(Class'R6Abstract.R6AbstractInsertionZone', NavPoint)
	{
		// End:0x191
		if((!NavPoint.IsAvailableInGameType(m_szGameTypeFlag)))
		{
			continue;			
		}
		NewRating = RatePlayerStart(NavPoint, InTeam, Player);
		// End:0x1D1
		if((NewRating > BestRating))
		{
			BestRating = NewRating;
			BestStart = NavPoint;
		}		
	}	
	// End:0x26B
	if((BestStart == none))
	{
		Log("WARNING - NO R6INSERTIONZONE FOUND - WARNING");
		Log("WARNING - Make sure you are using R6InsertionZone instead of PlayerStart");
		LastStartSpot = _checkStarts;
		return _tempStart;
	}
	// End:0x281
	if((BestStart != none))
	{
		LastStartSpot = BestStart;
	}
	return BestStart;
	return;
}

//============================================================================
// float RatePlayerStart - 
//============================================================================
function float RatePlayerStart(NavigationPoint NavPoint, byte Team, Controller Player)
{
	local R6AbstractInsertionZone _startPoint;
	local float Score, NextDist;
	local Controller OtherPlayer;

	_startPoint = R6AbstractInsertionZone(NavPoint);
	// End:0x21
	if((_startPoint == none))
	{
		return 0.0000000;
	}
	Score = 16000000.0000000;
	// End:0x50
	if((!_startPoint.IsAvailableInGameType(m_szGameTypeFlag)))
	{
		(Score -= float(1000000));
	}
	(Score += (float(10000) * FRand()));
	// End:0x8D
	if((_startPoint.m_iInsertionNumber == int(Team)))
	{
		(Score += float(40000));		
	}
	else
	{
		(Score -= float(1000000));
	}
	OtherPlayer = Level.ControllerList;
	J0xAF:

	// End:0x2E5 [Loop If]
	if((OtherPlayer != none))
	{
		// End:0x2CE
		if((OtherPlayer.bIsPlayer && (OtherPlayer.Pawn != none)))
		{
			// End:0x296
			if((OtherPlayer.Pawn.Region.Zone == _startPoint.Region.Zone))
			{
				(Score -= float(1500));
				NextDist = VSize((OtherPlayer.Pawn.Location - _startPoint.Location));
				// End:0x19C
				if((NextDist < (OtherPlayer.Pawn.CollisionRadius + OtherPlayer.Pawn.CollisionHeight)))
				{
					(Score -= 1000000.0000000);					
				}
				else
				{
					// End:0x1F0
					if(((NextDist < float(3000)) && FastTrace(_startPoint.Location, OtherPlayer.Pawn.Location)))
					{
						(Score -= (10000.0000000 - NextDist));						
					}
					else
					{
						// End:0x296
						if(((Level.Game.NumPlayers + Level.Game.NumBots) == 2))
						{
							(Score += (float(2) * VSize((OtherPlayer.Pawn.Location - _startPoint.Location))));
							// End:0x296
							if(FastTrace(_startPoint.Location, OtherPlayer.Pawn.Location))
							{
								(Score -= float(10000));
							}
						}
					}
				}
			}
			// End:0x2CE
			if((OtherPlayer.bIsPlayer && (OtherPlayer.StartSpot == _startPoint)))
			{
				(Score -= 1000000.0000000);
			}
		}
		OtherPlayer = OtherPlayer.nextController;
		// [Loop Continue]
		goto J0xAF;
	}
	return Score;
	return;
}

//============================================================================
// bool Stats_getPlayerInfo - 
//============================================================================
function bool Stats_getPlayerInfo(out string sz, R6Pawn pPawn, PlayerReplicationInfo pInfo)
{
	local string szHealth;
	local int iKills;

	// End:0x15
	if((pInfo == none))
	{
		sz = "";
		return false;
	}
	// End:0x99
	if((pPawn != none))
	{
		// End:0x4B
		if((int(pPawn.m_eHealth) == int(0)))
		{
			szHealth = "healthy";			
		}
		else
		{
			// End:0x76
			if((int(pPawn.m_eHealth) == int(1)))
			{
				szHealth = "wounded";				
			}
			else
			{
				szHealth = "dead";
			}
		}
		iKills = pInfo.m_iKillCount;		
	}
	else
	{
		szHealth = "unknow";
	}
	sz = ((((((("" $ pInfo.PlayerName) $ " kills: ") $ string(iKills)) $ " (deaths: ")) $ ") status : " $ ???) $ szHealth);
	return true;
	return;
}

//============================================================================
// RestartPlayer - 
//============================================================================
function RestartPlayer(Controller aPlayer)
{
	local NavigationPoint StartSpot;
	local int iStartPos;
	local Class<Pawn> DefaultPlayerClass;
	local Rotator rStartingPointRot;

	// End:0x41
	if(((bRestartLevel && (int(Level.NetMode) != int(NM_DedicatedServer))) && (int(Level.NetMode) != int(NM_ListenServer))))
	{
		return;
	}
	// End:0x7B
	if(((R6PlayerController(aPlayer) != none) && (int(R6PlayerController(aPlayer).m_TeamSelection) == int(3))))
	{
		iStartPos = 1;		
	}
	else
	{
		iStartPos = 0;
	}
	StartSpot = FindPlayerStart(aPlayer, byte(iStartPos));
	// End:0xC5
	if((StartSpot == none))
	{
		Log(" Player start not found!!!");
		return;
	}
	rStartingPointRot = StartSpot.Rotation;
	rStartingPointRot.Roll = 0;
	R6SetPawnClassInMultiPlayer(aPlayer);
	// End:0x18E
	if((aPlayer.PawnClass != none))
	{
		// End:0x13F
		if((int(R6PlayerController(aPlayer).m_TeamSelection) == int(3)))
		{
			aPlayer.PawnClass.default.m_iDefaultTeam = 3;			
		}
		else
		{
			aPlayer.PawnClass.default.m_iDefaultTeam = 2;
		}
		aPlayer.Pawn = Spawn(aPlayer.PawnClass,,, StartSpot.Location, rStartingPointRot);
	}
	// End:0x1ED
	if((aPlayer.Pawn == none))
	{
		aPlayer.PawnClass = GetDefaultPlayerClass();
		aPlayer.Pawn = Spawn(aPlayer.PawnClass,,, StartSpot.Location, rStartingPointRot, true);
	}
	// End:0x258
	if((aPlayer.Pawn == none))
	{
		Log(((("Couldn't spawn player of type " $ string(aPlayer.PawnClass)) $ " at ") $ string(StartSpot)));
		aPlayer.GotoState('Dead');
		return;
	}
	aPlayer.StartSpot = StartSpot;
	aPlayer.PreviousPawnClass = aPlayer.Pawn.Class;
	aPlayer.Possess(aPlayer.Pawn);
	aPlayer.PawnClass = aPlayer.Pawn.Class;
	aPlayer.PlayTeleportEffect(true, true);
	aPlayer.ClientSetRotation(aPlayer.Pawn.Rotation);
	TriggerEvent(StartSpot.Event, StartSpot, aPlayer.Pawn);
	R6Pawn(aPlayer.Pawn).m_iUniqueID = m_iCurrentID;
	(m_iCurrentID++);
	return;
}

//------------------------------------------------------------------
// R6SetPawnClassInMultiPlayer
//	
//------------------------------------------------------------------
function R6SetPawnClassInMultiPlayer(Controller _playerController)
{
	local Class<Pawn> CurrentPawnClass;
	local R6ModMgr pModManager;

	// End:0x38
	if((!((int(Level.NetMode) == int(NM_DedicatedServer)) || (int(Level.NetMode) == int(NM_ListenServer)))))
	{
		return;
	}
	// End:0xAC
	if((int(R6PlayerController(_playerController).m_TeamSelection) == int(3)))
	{
		CurrentPawnClass = Class<Pawn>(DynamicLoadObject(Level.RedTeamPawnClass, Class'Core.Class'));
		// End:0xA9
		if((CurrentPawnClass == none))
		{
			CurrentPawnClass = Class<Pawn>(DynamicLoadObject(Level.default.RedTeamPawnClass, Class'Core.Class'));
		}		
	}
	else
	{
		CurrentPawnClass = Class<Pawn>(DynamicLoadObject(Level.GreenTeamPawnClass, Class'Core.Class'));
		// End:0xFF
		if((CurrentPawnClass == none))
		{
			CurrentPawnClass = Class<Pawn>(DynamicLoadObject(Level.default.GreenTeamPawnClass, Class'Core.Class'));
		}
	}
	pModManager = Class'Engine.Actor'.static.GetModMgr();
	R6PlayerController(_playerController).PawnClass = pModManager.GetDefaultRainbowPawn(int(Class<R6Pawn>(CurrentPawnClass).default.m_eArmorType));
	return;
}

function Find2DTexture(string TeamClass, out Material MenuTexture, out Region TextureRegion)
{
	local Class<R6ArmorDescription> DescriptionClass;
	local bool bTeamFound;
	local int i;
	local R6Mod pCurrentMod;
	local R6ModMgr pModManager;

	pModManager = Class'Engine.Actor'.static.GetModMgr();
	pCurrentMod = pModManager.m_pCurrentMod;
	i = 0;
	J0x2D:

	// End:0xEB [Loop If]
	if((i < pCurrentMod.m_aDescriptionPackage.Length))
	{
		DescriptionClass = Class<R6ArmorDescription>(GetFirstPackageClass((pCurrentMod.m_aDescriptionPackage[i] $ ".u"), Class'R6Description.R6ArmorDescription'));
		J0x73:

		// End:0xE1 [Loop If]
		if((DescriptionClass != none))
		{
			// End:0xD0
			if((DescriptionClass.default.m_ClassName == TeamClass))
			{
				bTeamFound = true;
				MenuTexture = DescriptionClass.default.m_2DMenuTexture;
				TextureRegion = DescriptionClass.default.m_2dMenuRegion;
				DescriptionClass = none;				
			}
			else
			{
				DescriptionClass = Class<R6ArmorDescription>(GetNextClass());
			}
			// [Loop Continue]
			goto J0x73;
		}
		(i++);
		// [Loop Continue]
		goto J0x2D;
	}
	// End:0x1FE
	if(((bTeamFound == false) && (pModManager.m_pCurrentMod.m_bUseCustomOperatives == true)))
	{
		i = 0;
		J0x11E:

		// End:0x1FE [Loop If]
		if((i < pModManager.GetPackageMgr().m_aPackageList.Length))
		{
			DescriptionClass = Class<R6ArmorDescription>(pModManager.GetPackageMgr().GetFirstClassFromPackage(i, Class'R6Description.R6ArmorDescription'));
			J0x16F:

			// End:0x1F4 [Loop If]
			if((DescriptionClass != none))
			{
				// End:0x1E3
				if((DescriptionClass.default.m_ClassName == TeamClass))
				{
					MenuTexture = DescriptionClass.default.m_2DMenuTexture;
					TextureRegion = DescriptionClass.default.m_2dMenuRegion;
					DescriptionClass = none;
					i = pModManager.GetPackageMgr().m_aPackageList.Length;					
				}
				else
				{
					DescriptionClass = Class<R6ArmorDescription>(GetNextClass());
				}
				// [Loop Continue]
				goto J0x16F;
			}
			(i++);
			// [Loop Continue]
			goto J0x11E;
		}
	}
	return;
}

function LoadPlanningInTraining()
{
	return;
}

//============================================================================
// PostLogin - 
//============================================================================
event PostLogin(PlayerController NewPlayer)
{
	local R6FileManagerPlanning pFileManager;

	super(GameInfo).PostLogin(NewPlayer);
	// End:0x33
	if(NewPlayer.IsA('R6PlanningCtrl'))
	{
		R6PlanningCtrl(NewPlayer).SetPlanningInfo();
	}
	// End:0x295
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		// End:0xC7
		if((NewPlayer.Player.Console.Master.m_StartGameInfo.m_GameMode == "R6Game.R6TrainingMgr"))
		{
			LoadPlanningInTraining();
			R6Console(NewPlayer.Player.Console).StartR6Game();
			return;
		}
		// End:0x1FA
		if((NewPlayer.Player.Console.Master.m_StartGameInfo.m_ReloadPlanning == true))
		{
			pFileManager = new (none) Class'R6Game.R6FileManagerPlanning';
			pFileManager.LoadPlanning("Backup", "Backup", "Backup", "", "Backup.pln", NewPlayer.Player.Console.Master.m_StartGameInfo);
			NewPlayer.Player.Console.Master.m_StartGameInfo.m_ReloadPlanning = false;
			// End:0x1FA
			if((NewPlayer.Player.Console.Master.m_StartGameInfo.m_SkipPlanningPhase == false))
			{
				R6PlanningCtrl(NewPlayer).InitNewPlanning(pFileManager.m_iCurrentTeam);
			}
		}
		// End:0x291
		if((NewPlayer.Player.Console.Master.m_StartGameInfo.m_SkipPlanningPhase == true))
		{
			R6Console(NewPlayer.Player.Console).StartR6Game();
			NewPlayer.Player.Console.Master.m_StartGameInfo.m_SkipPlanningPhase = false;			
		}
		else
		{
			SetPlanningMode(true);
		}
	}
	// End:0x2F7
	if((int(Level.NetMode) != int(NM_Standalone)))
	{
		// End:0x2D1
		if((m_HudClass != none))
		{
			NewPlayer.ClientSetHUD(m_HudClass, none);			
		}
		else
		{
			NewPlayer.ClientSetHUD(Class'Engine.Actor'.static.GetModMgr().GetDefaultHUD(), none);
		}
	}
	return;
}

//============================================================================
// DeployCharacters - 
//============================================================================
function DeployCharacters(PlayerController ControlledByPlayer)
{
	local R6StartGameInfo StartGameInfo;
	local int CurrentTeam;
	local Player CurrentPlayer;
	local Interaction CurrentConsole;
	local R6DeploymentZone PZone;
	local R6ActionPoint pActionPoint;
	local R6Terrorist pTerrorist;
	local int iSoundNb;
	local R6ModMgr pModManager;

	assert((int(Level.NetMode) == int(NM_Standalone)));
	CurrentPlayer = ControlledByPlayer.Player;
	CurrentConsole = ControlledByPlayer.Player.Console;
	// End:0xA2
	if((ControlledByPlayer.Pawn != none))
	{
		ControlledByPlayer.Pawn.SetCollision(false, false, false);
		ControlledByPlayer.Pawn.SetPhysics(0);
		ControlledByPlayer.Pawn.Destroy();
	}
	ControlledByPlayer.Destroy();
	ControlledByPlayer = none;
	StartGameInfo = CurrentConsole.Master.m_StartGameInfo;
	pModManager = Class'Engine.Actor'.static.GetModMgr();
	// End:0x13C
	if((pModManager.m_pCurrentMod.m_PlayerCtrlToSpawn != ""))
	{
		ControlledByPlayer = Spawn(Class<PlayerController>(DynamicLoadObject(pModManager.m_pCurrentMod.m_PlayerCtrlToSpawn, Class'Core.Class')),,, Location);		
	}
	else
	{
		ControlledByPlayer = Spawn(Class'R6Engine.R6PlayerController',,, Location);
	}
	CurrentTeam = 0;
	J0x158:

	// End:0x1F9 [Loop If]
	if((CurrentTeam < 3))
	{
		// End:0x1EF
		if((StartGameInfo.m_TeamInfo[CurrentTeam].m_iNumberOfMembers > 0))
		{
			StartGameInfo.m_TeamInfo[CurrentTeam].m_pPlanning.ResetID();
			CreateRainbowTeam(CurrentTeam, StartGameInfo.m_TeamInfo[CurrentTeam], StartGameInfo.m_bIsPlaying, StartGameInfo.m_iTeamStart, ControlledByPlayer);
		}
		(CurrentTeam++);
		// [Loop Continue]
		goto J0x158;
	}
	// End:0x251
	if(StartGameInfo.m_bIsPlaying)
	{
		ControlledByPlayer = PlayerController(R6RainbowTeam(GetRainbowTeam(StartGameInfo.m_iTeamStart)).m_TeamLeader.Controller);
		SetController(ControlledByPlayer, CurrentPlayer);		
	}
	else
	{
		ControlledByPlayer.SetLocation(R6RainbowTeam(GetRainbowTeam(StartGameInfo.m_iTeamStart)).m_TeamLeader.Location);
		ControlledByPlayer.m_CurrentAmbianceObject = R6RainbowTeam(GetRainbowTeam(StartGameInfo.m_iTeamStart)).m_TeamLeader.Region.Zone;
		m_Player = ControlledByPlayer;
		m_Player.GameReplicationInfo = GameReplicationInfo;
		m_Player.bOnlySpectator = true;
		SetController(ControlledByPlayer, CurrentPlayer);
		m_Player.GotoState('CameraPlayer');
	}
	CurrentTeam = 0;
	J0x31B:

	// End:0x394 [Loop If]
	if((CurrentTeam < 3))
	{
		// End:0x38A
		if((StartGameInfo.m_TeamInfo[CurrentTeam].m_iNumberOfMembers == 0))
		{
			StartGameInfo.m_TeamInfo[CurrentTeam].m_pPlanning.m_pTeamManager = R6RainbowTeam(GetRainbowTeam(StartGameInfo.m_iTeamStart));
		}
		(CurrentTeam++);
		// [Loop Continue]
		goto J0x31B;
	}
	// End:0x3EB
	foreach AllActors(Class'R6Game.R6ActionPoint', pActionPoint)
	{
		pActionPoint.SetDrawType(0);
		pActionPoint.bHidden = true;
		// End:0x3EA
		if((pActionPoint.m_pActionIcon != none))
		{
			pActionPoint.m_pActionIcon = none;
		}		
	}	
	// End:0x409
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		SetPlanningMode(false);
	}
	return;
}

//============================================================================
// CreateRainbowTeam - 
//============================================================================
function CreateRainbowTeam(int NewTeamNumber, R6TeamStartInfo TeamInfo, bool bIsPlaying, int iTeamStart, PlayerController aRainbowPC)
{
	local NavigationPoint StartingPoint;
	local R6RainbowTeam newTeam;

	newTeam = Spawn(Class'R6Engine.R6RainbowTeam');
	TeamInfo.m_pPlanning.m_pTeamManager = newTeam;
	newTeam.m_TeamPlanning = TeamInfo.m_pPlanning;
	// End:0x7E
	if((newTeam.m_TeamPlanning.GetNbActionPoint() != 0))
	{
		newTeam.m_TeamPlanning.ResetPointsOrientation();
	}
	// End:0xE1
	if(((TeamInfo.m_pPlanning.m_NodeList.Length > 0) || (TeamInfo.m_pPlanning.m_iStartingPointNumber != 0)))
	{
		StartingPoint = FindTeamInsertionZone(TeamInfo.m_pPlanning.m_iStartingPointNumber);		
	}
	else
	{
		StartingPoint = FindTeamInsertionZone(-1);
	}
	// End:0x18F
	if((StartingPoint == none))
	{
		// End:0x16C
		if(bShowLog)
		{
			Warn((("Couldn't find insertion zone #" $ string(TeamInfo.m_pPlanning.m_iStartingPointNumber)) $ " Finding Insertion #0 or player start"));
		}
		StartingPoint = FindTeamInsertionZone(0);
		// End:0x18F
		if((StartingPoint == none))
		{
			FindPlayerStart(m_Player);
		}
	}
	SetRainbowTeam(NewTeamNumber, newTeam);
	// End:0x20A
	if(((NewTeamNumber == iTeamStart) && bIsPlaying))
	{
		newTeam.CreatePlayerTeam(TeamInfo, StartingPoint, aRainbowPC);
		R6PlayerController(m_Player).m_TeamManager = newTeam;
		newTeam.SetVoicesMgr(self, true, true, m_iIDVoicesMgr);		
	}
	else
	{
		newTeam.CreateAITeam(TeamInfo, StartingPoint);
		newTeam.SetVoicesMgr(self, false, (NewTeamNumber == iTeamStart), m_iIDVoicesMgr);
		// End:0x26F
		if(((NewTeamNumber != iTeamStart) && (GetGameOptions().SndQuality == 1)))
		{
			(m_iIDVoicesMgr++);
		}
	}
	newTeam.m_iRainbowTeamName = NewTeamNumber;
	return;
}

//============================================================================
// R6InsertionZone FindTeamInsertionZone - 
//============================================================================
function R6InsertionZone FindTeamInsertionZone(int iSpawningPointNumber)
{
	local int iCurrentZoneNumber;
	local R6InsertionZone anInsertionZone, pSelectedInsertionZone;

	iCurrentZoneNumber = 2147483647;
	pSelectedInsertionZone = none;
	// End:0xE5
	foreach AllActors(Class'R6Game.R6InsertionZone', anInsertionZone)
	{
		// End:0x98
		if((iSpawningPointNumber == -1))
		{
			// End:0x95
			if((anInsertionZone.IsAvailableInGameType(R6AbstractGameInfo(Level.Game).m_szGameTypeFlag) && (anInsertionZone.m_iInsertionNumber < iCurrentZoneNumber)))
			{
				iCurrentZoneNumber = anInsertionZone.m_iInsertionNumber;
				pSelectedInsertionZone = anInsertionZone;
			}
			// End:0xE4
			continue;
		}
		// End:0xE4
		if(((anInsertionZone.m_iInsertionNumber == iSpawningPointNumber) && anInsertionZone.IsAvailableInGameType(R6AbstractGameInfo(Level.Game).m_szGameTypeFlag)))
		{			
			return anInsertionZone;
		}		
	}	
	return pSelectedInsertionZone;
	return;
}

//============================================================================
// bool RainbowOperativesStillAlive - 
//============================================================================
function bool RainbowOperativesStillAlive()
{
	local R6GameReplicationInfo repInfo;

	repInfo = R6GameReplicationInfo(GameReplicationInfo);
	// End:0x49
	if(((repInfo.m_RainbowTeam[0] != none) && (repInfo.m_RainbowTeam[0].m_iMemberCount > 0)))
	{
		return true;
	}
	// End:0x82
	if(((repInfo.m_RainbowTeam[1] != none) && (repInfo.m_RainbowTeam[1].m_iMemberCount > 0)))
	{
		return true;
	}
	// End:0xBD
	if(((repInfo.m_RainbowTeam[2] != none) && (repInfo.m_RainbowTeam[2].m_iMemberCount > 0)))
	{
		return true;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// IsARainbowAlive (slower version!)
// - different from RainbowOperativesStillAlive 
// - can't look the iMemberCount because of an order of execution problem
//------------------------------------------------------------------
function bool IsARainbowAlive()
{
	local R6GameReplicationInfo gInfo;
	local int iTeam, iRainbow;

	gInfo = R6GameReplicationInfo(GameReplicationInfo);
	iTeam = 0;
	J0x17:

	// End:0xB3 [Loop If]
	if(((iTeam < 3) && (gInfo.m_RainbowTeam[iTeam] != none)))
	{
		iRainbow = 0;
		J0x46:

		// End:0xA9 [Loop If]
		if((iRainbow < gInfo.m_RainbowTeam[iTeam].m_iMemberCount))
		{
			// End:0x9F
			if(gInfo.m_RainbowTeam[iTeam].m_Team[iRainbow].IsAlive())
			{
				return true;
			}
			(++iRainbow);
			// [Loop Continue]
			goto J0x46;
		}
		(++iTeam);
		// [Loop Continue]
		goto J0x17;
	}
	return false;
	return;
}

//============================================================================
// Actor GetNewTeam - 
//============================================================================
function Actor GetNewTeam(Actor aCurrentTeam, optional bool bNextTeam)
{
	local R6RainbowTeam aRainbowTeam[3], aNewTeam;
	local int i, iCurrentTeam, iNewTeam;

	// End:0x0D
	if((aCurrentTeam == none))
	{
		return none;
	}
	aRainbowTeam[0] = R6RainbowTeam(GetRainbowTeam(0));
	aRainbowTeam[1] = R6RainbowTeam(GetRainbowTeam(1));
	aRainbowTeam[2] = R6RainbowTeam(GetRainbowTeam(2));
	// End:0x77
	if(((aRainbowTeam[1] != none) && aRainbowTeam[1].m_bPreventUsingTeam))
	{
		aRainbowTeam[1] = none;
	}
	// End:0xA6
	if(((aRainbowTeam[2] != none) && aRainbowTeam[2].m_bPreventUsingTeam))
	{
		aRainbowTeam[2] = none;
	}
	// End:0xC5
	if(((aRainbowTeam[1] == none) && (aRainbowTeam[2] == none)))
	{
		return none;
	}
	// End:0x11A
	if((aRainbowTeam[2] == none))
	{
		// End:0xF4
		if((aCurrentTeam == aRainbowTeam[0]))
		{
			aNewTeam = aRainbowTeam[1];			
		}
		else
		{
			aNewTeam = aRainbowTeam[0];
		}
		// End:0x117
		if((aNewTeam.m_iMemberCount == 0))
		{
			return none;
		}		
	}
	else
	{
		i = 0;
		J0x121:

		// End:0x15A [Loop If]
		if((i < 3))
		{
			// End:0x150
			if((aRainbowTeam[i] == aCurrentTeam))
			{
				iCurrentTeam = i;
				// [Explicit Break]
				goto J0x15A;
			}
			(i++);
			// [Loop Continue]
			goto J0x121;
		}
		J0x15A:

		iNewTeam = iCurrentTeam;
		J0x165:

		// End:0x178 [Loop If]
		if(bNextTeam)
		{
			(iNewTeam++);
			goto J0x17F;
		}
		(iNewTeam--);
		J0x17F:

		// End:0x196
		if((iNewTeam == -1))
		{
			iNewTeam = 2;
		}
		// End:0x1A9
		if((iNewTeam == 3))
		{
			iNewTeam = 0;
		}
		// End:0x165
		if(!((((aRainbowTeam[iNewTeam] != none) && (aRainbowTeam[iNewTeam].m_iMemberCount != 0)) || (aRainbowTeam[iNewTeam] == aCurrentTeam))))
			goto J0x165;
		// End:0x204
		if((aRainbowTeam[iNewTeam] == aCurrentTeam))
		{
			return none;
		}
		aNewTeam = aRainbowTeam[iNewTeam];
	}
	return aNewTeam;
	return;
}

//============================================================================
// ChangeOperatives - 
//============================================================================
function ChangeOperatives(PlayerController inPlayerController, int iTeamId, int iOperativeID)
{
	local R6RainbowTeam aNewTeam;
	local R6PlayerController aPlayerController;

	aPlayerController = R6PlayerController(inPlayerController);
	// End:0x40
	if((int(Level.NetMode) != int(NM_Standalone)))
	{
		aNewTeam = aPlayerController.m_TeamManager;		
	}
	else
	{
		aNewTeam = R6RainbowTeam(GetRainbowTeam(iTeamId));
	}
	// End:0xE8
	if(aPlayerController.bOnlySpectator)
	{
		// End:0x83
		if((int(aPlayerController.m_eCameraMode) == int(3)))
		{
			return;
		}
		J0x83:

		// End:0xAE [Loop If]
		if((aPlayerController.m_TeamManager != aNewTeam))
		{
			aPlayerController.ChangeTeams(true);
			// [Loop Continue]
			goto J0x83;
		}
		J0xAE:

		// End:0xE6 [Loop If]
		if((R6Pawn(aPlayerController.ViewTarget).m_iID != iOperativeID))
		{
			aPlayerController.NextMember();
			// [Loop Continue]
			goto J0xAE;
		}
		return;
	}
	// End:0x120
	if((aPlayerController.m_TeamManager == aNewTeam))
	{
		aPlayerController.m_TeamManager.SwapPlayerControlWithTeamMate(iOperativeID);		
	}
	else
	{
		aNewTeam.AssignNewTeamLeader(iOperativeID);
		ChangeTeams(inPlayerController,, aNewTeam);
	}
	return;
}

//============================================================================
// ChangeTeams - 
//============================================================================
function ChangeTeams(PlayerController inPlayerController, optional bool bNextTeam, optional Actor newRainbowTeam)
{
	local R6PawnReplicationInfo aPawnRepInfo;
	local R6PlayerController aPC;
	local R6RainbowAI tempAIController;
	local R6RainbowTeam aCurrentTeam, aNewTeam;
	local bool bPlayerDied;

	aPC = R6PlayerController(inPlayerController);
	// End:0x2B
	if((int(Level.NetMode) != int(NM_Standalone)))
	{
		return;
	}
	// End:0x41
	if((aPC.Pawn == none))
	{
		return;
	}
	bPlayerDied = (!aPC.Pawn.IsAlive());
	aCurrentTeam = aPC.m_TeamManager;
	// End:0xA0
	if((newRainbowTeam == none))
	{
		aNewTeam = R6RainbowTeam(GetNewTeam(aCurrentTeam, bNextTeam));		
	}
	else
	{
		aNewTeam = R6RainbowTeam(newRainbowTeam);
	}
	// End:0xCA
	if(((aCurrentTeam == none) || (aNewTeam == none)))
	{
		return;
	}
	// End:0xE9
	if(bPlayerDied)
	{
		aPC.ClientFadeCommonSound(0.5000000, 100);
	}
	aCurrentTeam.PlayerHasAbandonedTeam();
	aPC.ResetPlayerVisualEffects();
	aPC.m_bLockWeaponActions = false;
	tempAIController = R6RainbowAI(aNewTeam.m_TeamLeader.Controller);
	aPawnRepInfo = tempAIController.m_PawnRepInfo;
	tempAIController.m_PawnRepInfo = aPC.m_PawnRepInfo;
	tempAIController.m_PawnRepInfo.m_ControllerOwner = tempAIController;
	aPC.m_PawnRepInfo = aPawnRepInfo;
	aPC.m_PawnRepInfo.m_ControllerOwner = aPC;
	aPC.m_CurrentAmbianceObject = tempAIController.Pawn.Region.Zone;
	aPC.m_TeamManager = aNewTeam;
	// End:0x21B
	if((!bPlayerDied))
	{
		aCurrentTeam.m_TeamLeader.UnPossessed();
	}
	aNewTeam.AssociatePlayerAndPawn(aPC, aNewTeam.m_TeamLeader);
	aNewTeam.m_bLeaderIsAPlayer = true;
	aNewTeam.m_TeamLeader.m_bIsPlayer = true;
	aNewTeam.SetPlayerControllerState(aPC);
	aNewTeam.InstructPlayerTeamToFollowLead();
	aCurrentTeam.m_bLeaderIsAPlayer = false;
	// End:0x2B4
	if(bPlayerDied)
	{
		tempAIController.Destroy();		
	}
	else
	{
		aCurrentTeam.m_TeamLeader.m_bIsPlayer = false;
		aCurrentTeam.m_TeamLeader.Controller = tempAIController;
		aCurrentTeam.m_TeamLeader.Controller.Possess(aCurrentTeam.m_TeamLeader);
		tempAIController.m_TeamManager = aCurrentTeam;
		tempAIController.StopMoving();
		aCurrentTeam.SetAILeadControllerState();
		// End:0x36D
		if(aPC.m_bAllTeamsHold)
		{
			aCurrentTeam.AITeamHoldPosition();
		}
	}
	aCurrentTeam.m_TeamLeader.PawnLook(rot(0, 0, 0));
	aCurrentTeam.UpdateFirstPersonWeaponMemory(aCurrentTeam.m_TeamLeader, aNewTeam.m_TeamLeader);
	aCurrentTeam.UpdatePlayerWeapon(aNewTeam.m_TeamLeader);
	// End:0x45A
	if((aNewTeam.m_TeamLeader.m_bPawnIsReloading == true))
	{
		aNewTeam.m_TeamLeader.ServerSwitchReloadingWeapon(false);
		aNewTeam.m_TeamLeader.m_bPawnIsReloading = false;
		aNewTeam.m_TeamLeader.GotoState('None');
		aNewTeam.m_TeamLeader.PlayWeaponAnimation();
	}
	aCurrentTeam.SetVoicesMgr(self, false, false, aNewTeam.m_iIDVoicesMgr);
	aNewTeam.SetVoicesMgr(self, true, true);
	aNewTeam.UpdateTeamGrenadeStatus();
	// End:0x4D6
	if(((aNewTeam.m_iMemberCount == 1) && (aNewTeam.m_iMembersLost > 0)))
	{
		aNewTeam.SetTeamState(21);
	}
	aPC.UpdatePlayerPostureAfterSwitch();
	return;
}

//============================================================================
// InstructAllTeamsToHoldPosition - 
//============================================================================
function InstructAllTeamsToHoldPosition()
{
	local R6RainbowTeam aRainbowTeam[3];
	local int i, iNbTeam;

	i = 0;
	J0x07:

	// End:0x6D [Loop If]
	if((i < 3))
	{
		aRainbowTeam[i] = R6RainbowTeam(GetRainbowTeam(i));
		// End:0x63
		if(((aRainbowTeam[i] != none) && (aRainbowTeam[i].m_iMemberCount > 0)))
		{
			(iNbTeam++);
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	i = 0;
	J0x74:

	// End:0xFF [Loop If]
	if((i < 3))
	{
		// End:0xF5
		if((aRainbowTeam[i] != none))
		{
			// End:0xC9
			if(aRainbowTeam[i].m_bLeaderIsAPlayer)
			{
				aRainbowTeam[i].InstructPlayerTeamToHoldPosition((iNbTeam > 1));				
			}
			else
			{
				aRainbowTeam[i].AITeamHoldPosition();
			}
			aRainbowTeam[i].m_bAllTeamsHold = true;
		}
		(i++);
		// [Loop Continue]
		goto J0x74;
	}
	return;
}

//============================================================================
// InstructAllTeamsToFollowPlanning - 
//============================================================================
function InstructAllTeamsToFollowPlanning()
{
	local R6RainbowTeam aRainbowTeam[3];
	local int i, iNbTeam;

	i = 0;
	J0x07:

	// End:0x6D [Loop If]
	if((i < 3))
	{
		aRainbowTeam[i] = R6RainbowTeam(GetRainbowTeam(i));
		// End:0x63
		if(((aRainbowTeam[i] != none) && (aRainbowTeam[i].m_iMemberCount > 0)))
		{
			(iNbTeam++);
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	i = 0;
	J0x74:

	// End:0xFF [Loop If]
	if((i < 3))
	{
		// End:0xF5
		if((aRainbowTeam[i] != none))
		{
			// End:0xC9
			if(aRainbowTeam[i].m_bLeaderIsAPlayer)
			{
				aRainbowTeam[i].InstructPlayerTeamToFollowLead((iNbTeam > 1));				
			}
			else
			{
				aRainbowTeam[i].AITeamFollowPlanning();
			}
			aRainbowTeam[i].m_bAllTeamsHold = false;
		}
		(i++);
		// [Loop Continue]
		goto J0x74;
	}
	return;
}

// Object GetCommonRainbowPlayerVoicesMgr - 
//============================================================================
function Object GetMultiCoopPlayerVoicesMgr(int iTeam)
{
	local int iIndex;

	switch(iTeam)
	{
		// End:0x0B
		case 1:
		// End:0x10
		case 4:
		// End:0x1F
		case 7:
			iIndex = 0;
			// End:0x57
			break;
		// End:0x24
		case 2:
		// End:0x29
		case 5:
		// End:0x38
		case 8:
			iIndex = 1;
			// End:0x57
			break;
		// End:0x3D
		case 3:
		// End:0x4D
		case 6:
			iIndex = 2;
			// End:0x57
			break;
		// End:0xFFFF
		default:
			iIndex = 0;
			break;
	}
	// End:0x74
	if((m_MultiCoopPlayerVoicesMgr.Length <= iIndex))
	{
		m_MultiCoopPlayerVoicesMgr[iIndex] = none;
	}
	// End:0xFA
	if((m_MultiCoopPlayerVoicesMgr[iIndex] == none))
	{
		switch(iIndex)
		{
			// End:0xA8
			case 0:
				m_MultiCoopPlayerVoicesMgr[iIndex] = new Class'R6Engine.R6MultiCoopPlayerVoices1';
				// End:0xE4
				break;
			// End:0xC4
			case 1:
				m_MultiCoopPlayerVoicesMgr[iIndex] = new Class'R6Engine.R6MultiCoopPlayerVoices2';
				// End:0xE4
				break;
			// End:0xE1
			case 2:
				m_MultiCoopPlayerVoicesMgr[iIndex] = new Class'R6Engine.R6MultiCoopPlayerVoices3';
				// End:0xE4
				break;
			// End:0xFFFF
			default:
				break;
		}
		m_MultiCoopPlayerVoicesMgr[iIndex].Init(self);
	}
	return m_MultiCoopPlayerVoicesMgr[iIndex];
	return;
}

// Object GetCommonRainbowPlayerVoicesMgr - 
//============================================================================
function Object GetMultiCoopMemberVoicesMgr()
{
	// End:0x2A
	if((m_MultiCoopMemberVoicesMgr == none))
	{
		m_MultiCoopMemberVoicesMgr = new Class'R6Engine.R6MultiCoopMemberVoices';
		m_MultiCoopMemberVoicesMgr.Init(self);
	}
	return m_MultiCoopMemberVoicesMgr;
	return;
}

// Object GetCommonRainbowPlayerVoicesMgr - 
//============================================================================
function Object GetPreRecordedMsgVoicesMgr()
{
	// End:0x2A
	if((m_PreRecordedMsgVoicesMgr == none))
	{
		m_PreRecordedMsgVoicesMgr = new Class'R6Engine.R6PreRecordedMsgVoices';
		m_PreRecordedMsgVoicesMgr.Init(self);
	}
	return m_PreRecordedMsgVoicesMgr;
	return;
}

// Object GetCommonRainbowPlayerVoicesMgr - 
//============================================================================
function Object GetMultiCommonVoicesMgr()
{
	// End:0x2A
	if((m_MultiCommonVoicesMgr == none))
	{
		m_MultiCommonVoicesMgr = new Class'R6Engine.R6MultiCommonVoices';
		m_MultiCommonVoicesMgr.Init(self);
	}
	return m_MultiCommonVoicesMgr;
	return;
}

//============================================================================
// Object GetCommonRainbowPlayerVoicesMgr - 
//============================================================================
function Object GetCommonRainbowPlayerVoicesMgr()
{
	// End:0x2A
	if((m_CommonRainbowPlayerVoicesMgr == none))
	{
		m_CommonRainbowPlayerVoicesMgr = new Class'R6Engine.R6CommonRainbowPlayerVoices';
		m_CommonRainbowPlayerVoicesMgr.Init(self);
	}
	return m_CommonRainbowPlayerVoicesMgr;
	return;
}

//============================================================================
// Object GetCommonRainbowMemberVoicesMgr - 
//============================================================================
function Object GetCommonRainbowMemberVoicesMgr()
{
	// End:0x2A
	if((m_CommonRainbowMemberVoicesMgr == none))
	{
		m_CommonRainbowMemberVoicesMgr = new Class'R6Engine.R6CommonRainbowMemberVoices';
		m_CommonRainbowMemberVoicesMgr.Init(self);
	}
	return m_CommonRainbowMemberVoicesMgr;
	return;
}

//============================================================================
// Object GetRainbowPlayerVoicesMgr - 
//============================================================================
function Object GetRainbowPlayerVoicesMgr()
{
	// End:0x2A
	if((m_RainbowPlayerVoicesMgr == none))
	{
		m_RainbowPlayerVoicesMgr = new Class'R6Engine.R6RainbowPlayerVoices';
		m_RainbowPlayerVoicesMgr.Init(self);
	}
	return m_RainbowPlayerVoicesMgr;
	return;
}

//============================================================================
// Object GetRainbowMemberVoicesMgr - 
//============================================================================
function Object GetRainbowMemberVoicesMgr()
{
	// End:0x2A
	if((m_RainbowMemberVoicesMgr == none))
	{
		m_RainbowMemberVoicesMgr = new Class'R6Engine.R6RainbowMemberVoices';
		m_RainbowMemberVoicesMgr.Init(self);
	}
	return m_RainbowMemberVoicesMgr;
	return;
}

//============================================================================
// Object GetRainbowOtherTeamVoicesMgr - 
//============================================================================
function Object GetRainbowOtherTeamVoicesMgr(int iIDVoicesMgr)
{
	// End:0x1D
	if((m_RainbowOtherTeamVoicesMgr.Length <= iIDVoicesMgr))
	{
		m_RainbowOtherTeamVoicesMgr[iIDVoicesMgr] = none;
	}
	// End:0x7C
	if((m_RainbowOtherTeamVoicesMgr[iIDVoicesMgr] == none))
	{
		// End:0x51
		if((iIDVoicesMgr == 0))
		{
			m_RainbowOtherTeamVoicesMgr[iIDVoicesMgr] = new Class'R6Engine.R6RainbowOtherTeamVoices1';			
		}
		else
		{
			m_RainbowOtherTeamVoicesMgr[iIDVoicesMgr] = new Class'R6Engine.R6RainbowOtherTeamVoices2';
		}
		m_RainbowOtherTeamVoicesMgr[iIDVoicesMgr].Init(self);
	}
	return m_RainbowOtherTeamVoicesMgr[iIDVoicesMgr];
	return;
}

//============================================================================
// Object GetTerroristVoicesMgr - 
//============================================================================
function Object GetTerroristVoicesMgr(Actor.ETerroristNationality eNationality)
{
	// End:0x21
	if((m_TerroristVoicesMgr.Length <= int(eNationality)))
	{
		m_TerroristVoicesMgr[int(eNationality)] = none;
	}
	// End:0xF1
	if((m_TerroristVoicesMgr[int(eNationality)] == none))
	{
		switch(eNationality)
		{
			// End:0x5A
			case 0:
				m_TerroristVoicesMgr[int(eNationality)] = new Class'R6Engine.R6TerroristVoicesSpanish1';
				// End:0xD9
				break;
			// End:0x79
			case 1:
				m_TerroristVoicesMgr[int(eNationality)] = new Class'R6Engine.R6TerroristVoicesSpanish2';
				// End:0xD9
				break;
			// End:0x98
			case 2:
				m_TerroristVoicesMgr[int(eNationality)] = new Class'R6Engine.R6TerroristVoicesGerman1';
				// End:0xD9
				break;
			// End:0xB7
			case 3:
				m_TerroristVoicesMgr[int(eNationality)] = new Class'R6Engine.R6TerroristVoicesGerman2';
				// End:0xD9
				break;
			// End:0xD6
			case 4:
				m_TerroristVoicesMgr[int(eNationality)] = new Class'R6Engine.R6TerroristVoicesPortuguese';
				// End:0xD9
				break;
			// End:0xFFFF
			default:
				break;
		}
		m_TerroristVoicesMgr[int(eNationality)].Init(self);
	}
	return m_TerroristVoicesMgr[int(eNationality)];
	return;
}

//============================================================================
// Object GetHostageVoicesMgr - 
//============================================================================
function Object GetHostageVoicesMgr(Actor.EHostageNationality eNationality, bool IsFemale)
{
	// End:0x10B
	if(IsFemale)
	{
		// End:0x2A
		if((m_HostageVoicesFemaleMgr.Length <= int(eNationality)))
		{
			m_HostageVoicesFemaleMgr[int(eNationality)] = none;
		}
		// End:0xFA
		if((m_HostageVoicesFemaleMgr[int(eNationality)] == none))
		{
			switch(eNationality)
			{
				// End:0x63
				case 0:
					m_HostageVoicesFemaleMgr[int(eNationality)] = new Class'R6Engine.R6HostageVoicesFemaleFrench';
					// End:0xE2
					break;
				// End:0x82
				case 1:
					m_HostageVoicesFemaleMgr[int(eNationality)] = new Class'R6Engine.R6HostageVoicesFemaleBritish';
					// End:0xE2
					break;
				// End:0xA1
				case 2:
					m_HostageVoicesFemaleMgr[int(eNationality)] = new Class'R6Engine.R6HostageVoicesFemaleSpanish';
					// End:0xE2
					break;
				// End:0xC0
				case 4:
					m_HostageVoicesFemaleMgr[int(eNationality)] = new Class'R6Engine.R6HostageVoicesFemaleNorwegian';
					// End:0xE2
					break;
				// End:0xDF
				case 3:
					m_HostageVoicesFemaleMgr[int(eNationality)] = new Class'R6Engine.R6HostageVoicesFemalePortuguese';
					// End:0xE2
					break;
				// End:0xFFFF
				default:
					break;
			}
			m_HostageVoicesFemaleMgr[int(eNationality)].Init(self);
		}
		return m_HostageVoicesFemaleMgr[int(eNationality)];		
	}
	else
	{
		// End:0x12C
		if((m_HostageVoicesMaleMgr.Length <= int(eNationality)))
		{
			m_HostageVoicesMaleMgr[int(eNationality)] = none;
		}
		// End:0x1FC
		if((m_HostageVoicesMaleMgr[int(eNationality)] == none))
		{
			switch(eNationality)
			{
				// End:0x165
				case 0:
					m_HostageVoicesMaleMgr[int(eNationality)] = new Class'R6Engine.R6HostageVoicesMaleFrench';
					// End:0x1E4
					break;
				// End:0x184
				case 1:
					m_HostageVoicesMaleMgr[int(eNationality)] = new Class'R6Engine.R6HostageVoicesMaleBritish';
					// End:0x1E4
					break;
				// End:0x1A3
				case 2:
					m_HostageVoicesMaleMgr[int(eNationality)] = new Class'R6Engine.R6HostageVoicesMaleSpanish';
					// End:0x1E4
					break;
				// End:0x1C2
				case 4:
					m_HostageVoicesMaleMgr[int(eNationality)] = new Class'R6Engine.R6HostageVoicesMaleNorwegian';
					// End:0x1E4
					break;
				// End:0x1E1
				case 3:
					m_HostageVoicesMaleMgr[int(eNationality)] = new Class'R6Engine.R6HostageVoicesMalePortuguese';
					// End:0x1E4
					break;
				// End:0xFFFF
				default:
					break;
			}
			m_HostageVoicesMaleMgr[int(eNationality)].Init(self);
		}
		return m_HostageVoicesMaleMgr[int(eNationality)];
	}
	return;
}

//============================================================================
// Object GetTrainingMgr - 
//============================================================================
function R6TrainingMgr GetTrainingMgr(R6Pawn P)
{
	return none;
	return;
}

//============================================================================
// R6AbstractNoiseMgr GetNoiseMgr - 
//============================================================================
function R6AbstractNoiseMgr GetNoiseMgr()
{
	// End:0x29
	if((m_noiseMgr == none))
	{
		m_noiseMgr = new Class'R6Game.R6NoiseMgr';
		m_noiseMgr.Init();
	}
	return m_noiseMgr;
	return;
}

//============================================================================
// RestartGame - At the end of a round or if we switch maps
//============================================================================
function RestartGame()
{
	local R6PlayerController P;

	m_bStopPostBetweenRoundCountdown = true;
	GameReplicationInfo.SetServerState(GameReplicationInfo.4);
	// End:0x30
	if((bNoRestart == true))
	{
		return;
	}
	// End:0x5A
	if(bChangeLevels)
	{
		// End:0x59
		foreach DynamicActors(Class'R6Engine.R6PlayerController', P)
		{
			P.ClientChangeMap();			
		}		
	}
	super(GameInfo).RestartGame();
	Level.ResetLevelInNative();
	DestroyBeacon();
	return;
}

//============================================================================
// R6GameInfoMakeNoise - 
//============================================================================
function R6GameInfoMakeNoise(Actor.ESoundType eType, Actor soundsource)
{
	GetNoiseMgr().R6MakeNoise(eType, soundsource);
	return;
}

//============================================================================
// PlayTeleportEffect - Overided to remove MakeNoise of base class
//============================================================================
function PlayTeleportEffect(bool bOut, bool bSound)
{
	return;
}

//============================================================================
// InitGameReplicationInfo - 
//============================================================================
function InitGameReplicationInfo()
{
	super(GameInfo).InitGameReplicationInfo();
	GameReplicationInfo.m_bServerAllowRadar = m_bServerAllowRadarRep;
	GameReplicationInfo.m_bRepAllowRadarOption = m_bRepAllowRadarOption;
	GameReplicationInfo.TimeLimit = int(Level.m_fTimeLimit);
	GameReplicationInfo.MOTDLine1 = m_szMessageOfDay;
	R6GameReplicationInfo(GameReplicationInfo).m_szCurrGameType = m_szCurrGameType;
	return;
}

function IncrementRoundsFired(Pawn Instigator, bool ForceIncrement)
{
	local R6RainbowPawn _pawnIterator;
	local PlayerController _playerController;

	// End:0x30
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		R6Pawn(Instigator).IncrementBulletsFired();		
	}
	else
	{
		// End:0xBA
		if(((m_bCompilingStats == true) || (ForceIncrement == true)))
		{
			// End:0x7A
			if((Instigator.PlayerReplicationInfo != none))
			{
				(Instigator.PlayerReplicationInfo.m_iRoundFired++);				
			}
			else
			{
				_playerController = R6Pawn(Instigator).GetHumanLeaderForAIPawn();
				// End:0xA1
				if((_playerController == none))
				{
					return;
				}
				(_playerController.PlayerReplicationInfo.m_iRoundFired++);
			}
		}
	}
	return;
}

//------------------------------------------------------------------
// SetPawnTeamFriendlies
//	
//------------------------------------------------------------------
function SetPawnTeamFriendlies(Pawn aPawn)
{
	SetDefaultTeamFriendlies(aPawn);
	return;
}

//------------------------------------------------------------------
// GetTeamNumBit
//	
//------------------------------------------------------------------
function int GetTeamNumBit(int Num)
{
	return (1 << Num);
	return;
}

//------------------------------------------------------------------
// SetDefaultTeamFriendlies: set the default value based on single
//	player mode. 
//------------------------------------------------------------------
function SetDefaultTeamFriendlies(Pawn aPawn)
{
	switch(aPawn.m_iTeam)
	{
		// End:0xCE
		case 1:
			// End:0x86
			if((int(aPawn.m_ePawnType) != int(2)))
			{
				Log(("WARNING SetDefaultTeamFriendlies m_ePawnType != PAWN_Terrorist for " $ string(aPawn.Name)));
			}
			aPawn.m_iFriendlyTeams = GetTeamNumBit(1);
			aPawn.m_iEnemyTeams = GetTeamNumBit(2);
			(aPawn.m_iEnemyTeams += GetTeamNumBit(3));
			// End:0x2BD
			break;
		// End:0x18A
		case 0:
			// End:0x142
			if((int(aPawn.m_ePawnType) != int(3)))
			{
				Log(("WARNING SetDefaultTeamFriendlies m_ePawnType != PAWN_Hostage for " $ string(aPawn.Name)));
			}
			aPawn.m_iFriendlyTeams = GetTeamNumBit(2);
			(aPawn.m_iFriendlyTeams += GetTeamNumBit(3));
			aPawn.m_iEnemyTeams = GetTeamNumBit(1);
			// End:0x2BD
			break;
		// End:0x18F
		case 2:
		// End:0x24C
		case 3:
			// End:0x204
			if((int(aPawn.m_ePawnType) != int(1)))
			{
				Log(("WARNING SetDefaultTeamFriendlies m_ePawnType != PAWN_Rainbow for " $ string(aPawn.Name)));
			}
			aPawn.m_iFriendlyTeams = GetTeamNumBit(2);
			(aPawn.m_iFriendlyTeams += GetTeamNumBit(3));
			aPawn.m_iEnemyTeams = GetTeamNumBit(1);
			// End:0x2BD
			break;
		// End:0xFFFF
		default:
			Log(((("warning: SetDefaultTeamFriendlies team not supported for " $ string(aPawn.Name)) $ " team=") $ string(aPawn.m_iTeam)));
			// End:0x2BD
			break;
			break;
	}
	return;
}

//------------------------------------------------------------------
// CheckForExtractionZone
//	
//------------------------------------------------------------------
function CheckForExtractionZone(R6MissionObjectiveBase mo)
{
	local int iTotal;
	local R6ExtractionZone aExtractZone;

	iTotal = 0;
	// End:0x22
	foreach AllActors(Class'R6Game.R6ExtractionZone', aExtractZone)
	{
		(iTotal++);
		// End:0x22
		break;		
	}	
	// End:0x85
	if((iTotal == 0))
	{
		Log(("WARNING: there is no R6ExtractionZone to complete this objective: " $ mo.getDescription()));
	}
	return;
}

//------------------------------------------------------------------
// CheckForTerrorist
//	
//------------------------------------------------------------------
function CheckForTerrorist(R6MissionObjectiveBase mo, int iMinNum)
{
	local int iTotal;
	local R6Terrorist aTerrorist;

	// End:0x18
	foreach DynamicActors(Class'R6Engine.R6Terrorist', aTerrorist)
	{
		(iTotal++);		
	}	
	// End:0x80
	if((iTotal < iMinNum))
	{
		Log(("WARNING: there is no terrorist spawned to complete this objective: " $ mo.getDescription()));
	}
	return;
}

//------------------------------------------------------------------
// CheckForHostage
//	
//------------------------------------------------------------------
function CheckForHostage(R6MissionObjectiveBase mo, int iMinNum)
{
	local int iTotal;
	local R6Hostage aHostage;

	// End:0x18
	foreach DynamicActors(Class'R6Engine.R6Hostage', aHostage)
	{
		(iTotal++);		
	}	
	// End:0x96
	if((iTotal < iMinNum))
	{
		Log(((("WARNING: there is not enough (", string(iMinNum)) $ ") hostage spawned to complete this objective: " $ ???) $ mo.getDescription()));
	}
	return;
}

///////////////////////////////////////////////////////////////////////////////
// InitObjectives()
///////////////////////////////////////////////////////////////////////////////
function InitObjectives()
{
	local int Index, iMaxRep, iRep, i;
	local GameReplicationInfo G;

	// End:0xE0
	if(Level.m_bUseDefaultMoralityRules)
	{
		Index = m_missionMgr.m_aMissionObjectives.Length;
		m_missionMgr.m_aMissionObjectives[Index] = new (none) Class'R6Game.R6MObjAcceptableCivilianLossesByRainbow';
		(Index++);
		m_missionMgr.m_aMissionObjectives[Index] = new (none) Class'R6Game.R6MObjAcceptableCivilianLossesByTerro';
		(Index++);
		m_missionMgr.m_aMissionObjectives[Index] = new (none) Class'R6Game.R6MObjAcceptableHostageLossesByRainbow';
		(Index++);
		m_missionMgr.m_aMissionObjectives[Index] = new (none) Class'R6Game.R6MObjAcceptableHostageLossesByTerro';
		(Index++);
		m_missionMgr.m_aMissionObjectives[Index] = new (none) Class'R6Game.R6MObjAcceptableRainbowLosses';
		(Index++);
	}
	m_missionMgr.Init(self);
	G = GameReplicationInfo;
	iRep = 0;
	iMaxRep = G.GetRepMObjInfoArraySize();
	i = 0;
	J0x11E:

	// End:0x231 [Loop If]
	if((i < m_missionMgr.m_aMissionObjectives.Length))
	{
		// End:0x227
		if((m_missionMgr.m_aMissionObjectives[i].m_bVisibleInMenu && (!m_missionMgr.m_aMissionObjectives[i].m_bMoralityObjective)))
		{
			// End:0x1EA
			if((i < iMaxRep))
			{
				G.SetRepMObjString(iRep, m_missionMgr.m_aMissionObjectives[i].m_szDescriptionInMenu, Level.GetMissionObjLocFile(m_missionMgr.m_aMissionObjectives[i]));
				(iRep++);
				// [Explicit Continue]
				goto J0x227;
			}
			Log("Warning: array of m_aRepMObj is to small for this mission");
		}
		J0x227:

		(++i);
		// [Loop Continue]
		goto J0x11E;
	}
	return;
}

//------------------------------------------------------------------
// ResetRepMissionObjectives
//	
//------------------------------------------------------------------
function ResetRepMissionObjectives()
{
	GameReplicationInfo.ResetRepMObjInfo();
	return;
}

//------------------------------------------------------------------
// UpdateRepMissionObjectivesStatus
//	
//------------------------------------------------------------------
function UpdateRepMissionObjectivesStatus()
{
	GameReplicationInfo.SetRepMObjInProgress((int(m_missionMgr.m_eMissionObjectiveStatus) == int(0)));
	GameReplicationInfo.SetRepMObjSuccess((int(m_missionMgr.m_eMissionObjectiveStatus) == int(1)));
	return;
}

//------------------------------------------------------------------
// UpdateRepMissionObjectives
//	
//------------------------------------------------------------------
function UpdateRepMissionObjectives()
{
	local int i, iRep, iMaxRep;

	iRep = 0;
	i = 0;
	J0x0E:

	// End:0xCE [Loop If]
	if((i < m_missionMgr.m_aMissionObjectives.Length))
	{
		// End:0xC4
		if((m_missionMgr.m_aMissionObjectives[i].m_bVisibleInMenu && (!m_missionMgr.m_aMissionObjectives[i].m_bMoralityObjective)))
		{
			GameReplicationInfo.SetRepMObjInfo(iRep, m_missionMgr.m_aMissionObjectives[i].m_bFailed, m_missionMgr.m_aMissionObjectives[i].m_bCompleted);
			(iRep++);
		}
		(++i);
		// [Loop Continue]
		goto J0x0E;
	}
	return;
}

//------------------------------------------------------------------
// CheckEndGame
//	
//------------------------------------------------------------------
function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local R6GameOptions pGameOptions;

	m_missionMgr.Update();
	UpdateRepMissionObjectives();
	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	// End:0x44
	if(pGameOptions.UnlimitedPractice)
	{
		// End:0x44
		if(IsARainbowAlive())
		{
			return false;
		}
	}
	return (int(m_missionMgr.m_eMissionObjectiveStatus) != int(0));
	return;
}

//------------------------------------------------------------------
// BaseEndGame
//	
//------------------------------------------------------------------
function BaseEndGame()
{
	m_bGameOver = true;
	m_bPlayOutroVideo = default.m_bPlayOutroVideo;
	SetCompilingStats(false);
	SetRoundRestartedByJoinFlag(true);
	// End:0x41
	if(bShowLog)
	{
		Log(("***STATE: " $ string(GetStateName())));
	}
	// End:0x6B
	if((int(m_missionMgr.m_eMissionObjectiveStatus) == int(0)))
	{
		m_missionMgr.SetMissionObjStatus(2);
	}
	GameReplicationInfo.SetRepLastRoundSuccess(m_missionMgr.m_eMissionObjectiveStatus);
	m_fRoundEndTime = Level.TimeSeconds;
	return;
}

///////////////////////////////////////////////////////////////////////////////
// EndGame()
///////////////////////////////////////////////////////////////////////////////
function EndGame(PlayerReplicationInfo Winner, string Reason)
{
	local R6PlayerController PlayerController;

	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	BaseEndGame();
	super(GameInfo).EndGame(Winner, Reason);
	// End:0x39
	if(bShowLog)
	{
		Log(" ** EndGame");
	}
	return;
}

function InitObjectivesOfStoryMode()
{
	local int i, Index;

	i = 0;
	J0x07:

	// End:0x9B [Loop If]
	if((i < Level.m_aMissionObjectives.Length))
	{
		Level.m_aMissionObjectives[i].Reset();
		// End:0x91
		if((!Level.m_aMissionObjectives[i].m_bEndOfListOfObjectives))
		{
			m_missionMgr.m_aMissionObjectives[Index] = Level.m_aMissionObjectives[i];
			(++Index);
		}
		(++i);
		// [Loop Continue]
		goto J0x07;
	}
	i = 0;
	J0xA2:

	// End:0x116 [Loop If]
	if((i < Level.m_aMissionObjectives.Length))
	{
		// End:0x10C
		if(Level.m_aMissionObjectives[i].m_bEndOfListOfObjectives)
		{
			m_missionMgr.m_aMissionObjectives[Index] = Level.m_aMissionObjectives[i];
			(++Index);
		}
		(++i);
		// [Loop Continue]
		goto J0xA2;
	}
	return;
}

function PlayerReadySelected(PlayerController _Controller)
{
	local Controller _aController;
	local int iHumanCount;

	// End:0x1F
	if(((R6PlayerController(_Controller) == none) || IsInState('InBetweenRoundMenu')))
	{
		return;
	}
	_aController = Level.ControllerList;
	J0x33:

	// End:0x8C [Loop If]
	if((_aController != none))
	{
		// End:0x75
		if(((R6PlayerController(_aController) != none) && (int(R6PlayerController(_aController).m_TeamSelection) == int(2))))
		{
			(iHumanCount++);
		}
		_aController = _aController.nextController;
		// [Loop Continue]
		goto J0x33;
	}
	// End:0xB9
	if(((!R6PlayerController(_Controller).IsPlayerPassiveSpectator()) && (iHumanCount <= 2)))
	{
		ResetRound();
	}
	return;
}

//------------------------------------------------------------------
// SetJumpingMaps
//	
//------------------------------------------------------------------
function SetJumpingMaps(bool _flagSetting, int iNextMapIndex)
{
	m_bJumpingMaps = true;
	m_iJumpMapIndex = iNextMapIndex;
	return;
}

//------------------------------------------------------------------
// IsLastRoundOfTheMatch
//	
//------------------------------------------------------------------
function bool IsLastRoundOfTheMatch()
{
	// End:0x11
	if((m_bJumpingMaps == true))
	{
		return true;		
	}
	else
	{
		// End:0x1C
		if(m_bRotateMap)
		{
			return false;
		}
	}
	return ((R6GameReplicationInfo(GameReplicationInfo).m_iCurrentRound + 1) >= R6GameReplicationInfo(GameReplicationInfo).m_iRoundsPerMatch);
	return;
}

//------------------------------------------------------------------
// ProcessChangeLevelSystem
//  Determine if we have exceeded the time for this map	
//------------------------------------------------------------------
function ProcessChangeLevelSystem()
{
	// End:0x24
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		bChangeLevels = true;		
	}
	else
	{
		// End:0x5B
		if((m_bRotateMap && (m_bJumpingMaps == false)))
		{
			bChangeLevels = (int(m_missionMgr.m_eMissionObjectiveStatus) == int(1));			
		}
		else
		{
			bChangeLevels = IsLastRoundOfTheMatch();
		}
	}
	(R6GameReplicationInfo(GameReplicationInfo).m_iCurrentRound++);
	// End:0x9B
	if(bChangeLevels)
	{
		R6GameReplicationInfo(GameReplicationInfo).m_iCurrentRound = 0;
	}
	// End:0xD9
	if(bShowLog)
	{
		Log(("ProcessChangeLevelSystem bChangeLevels=" $ string(bChangeLevels)));
	}
	return;
}

//------------------------------------------------------------------
// ApplyTeamKillerPenalty
//	kill all pawn who's in the penalty box and check end game when
//  they are all dead
//------------------------------------------------------------------
function ApplyTeamKillerPenalty(Pawn aPawn)
{
	local R6PlayerController PController;

	PController = R6PlayerController(aPawn.Controller);
	PController.m_bPenaltyBox = false;
	PController.m_bHasAPenalty = false;
	R6Pawn(aPawn).ServerSuicidePawn(2);
	return;
}

//------------------------------------------------------------------
// tick
//	
//------------------------------------------------------------------
function Tick(float DeltaTime)
{
	local Controller _playerController;
	local R6PlayerController _R6PlayerController;
	local Controller P;
	local R6PlayerController _iterController;
	local R6HostageAI CurrentHostage;
	local bool bLoggedIntoGS;
	local R6Console aConsole;

	super(Actor).Tick(DeltaTime);
	// End:0x4E3
	if((m_bGameOver && (!bChangeLevels)))
	{
		// End:0x46
		if((int(Level.NetMode) != int(NM_Standalone)))
		{
			m_PersistantGameService.HandleAnyLobbyConnectionFail();
		}
		// End:0x1B4
		if((!m_bTimerStarted))
		{
			GameReplicationInfo.m_bGameOverRep = true;
			bLoggedIntoGS = NativeServerLogin();
			_playerController = Level.ControllerList;
			J0x80:

			// End:0x130 [Loop If]
			if((_playerController != none))
			{
				_R6PlayerController = R6PlayerController(_playerController);
				// End:0x119
				if((_R6PlayerController != none))
				{
					// End:0x119
					if(((_R6PlayerController.Pawn != none) && (_R6PlayerController.Pawn.EngineWeapon != none)))
					{
						// End:0x119
						if((int(_R6PlayerController.Pawn.m_bIsFiringWeapon) != 0))
						{
							_R6PlayerController.Pawn.EngineWeapon.LocalStopFire();
						}
					}
				}
				_playerController = _playerController.nextController;
				// [Loop Continue]
				goto J0x80;
			}
			// End:0x196
			if(((int(Level.NetMode) == int(NM_DedicatedServer)) || (int(Level.NetMode) == int(NM_ListenServer))))
			{
				// End:0x195
				foreach DynamicActors(Class'R6Engine.R6HostageAI', CurrentHostage)
				{
					CurrentHostage.StopFollowingPawn(false);
					CurrentHostage.GotoState('Freed');					
				}				
			}
			m_bTimerStarted = true;
			m_fTimerStartTime = int(Level.TimeSeconds);
		}
		// End:0x316
		if(((!m_bFadeStarted) && ((Level.TimeSeconds - float(m_fTimerStartTime)) > (GetEndGamePauseTime() - 2.0000000))))
		{
			m_bFadeStarted = true;
			// End:0x282
			if((int(Level.NetMode) == int(NM_Standalone)))
			{
				_R6PlayerController = R6PlayerController(m_Player);
				R6AbstractHUD(m_Player.myHUD).StartFadeToBlack(2, 100);
				_R6PlayerController.ClientFadeCommonSound(2.0000000, 0);
				_R6PlayerController.ClientFadeSound(2.0000000, 0, 5);
				_R6PlayerController.ClientFadeSound(2.0000000, 0, 7);				
			}
			else
			{
				_playerController = Level.ControllerList;
				J0x296:

				// End:0x316 [Loop If]
				if((_playerController != none))
				{
					_R6PlayerController = R6PlayerController(_playerController);
					// End:0x2FF
					if((_R6PlayerController != none))
					{
						_R6PlayerController.ClientFadeCommonSound(2.0000000, 0);
						_R6PlayerController.ClientFadeSound(2.0000000, 0, 5);
						_R6PlayerController.ClientFadeSound(2.0000000, 0, 7);
					}
					_playerController = _playerController.nextController;
					// [Loop Continue]
					goto J0x296;
				}
			}
		}
		// End:0x4E3
		if(((Level.TimeSeconds - float(m_fTimerStartTime)) > GetEndGamePauseTime()))
		{
			// End:0x425
			if((int(Level.NetMode) != int(NM_Standalone)))
			{
				_playerController = Level.ControllerList;
				J0x365:

				// End:0x3D0 [Loop If]
				if((_playerController != none))
				{
					_R6PlayerController = R6PlayerController(_playerController);
					// End:0x3B9
					if((_R6PlayerController != none))
					{
						// End:0x3B9
						if((((!m_bEndGameIgnoreGamePlayCheck) && bLoggedIntoGS) && (!_R6PlayerController.m_bEndOfRoundDataReceived)))
						{
							return;
						}
					}
					_playerController = _playerController.nextController;
					// [Loop Continue]
					goto J0x365;
				}
				// End:0x425
				if(bShowLog)
				{
					// End:0x425
					if(((!m_bEndGameIgnoreGamePlayCheck) && bLoggedIntoGS))
					{
						Log("Received ServerEndOfRoundDataSent from all clients");
					}
				}
			}
			m_fTimerStartTime = 2147483647;
			// End:0x4DA
			if((int(Level.NetMode) == int(NM_Standalone)))
			{
				StopAllSounds();
				ResetBroadcastGameMsg();
				// End:0x4A3
				if(IsA('R6TrainingMgr'))
				{
					aConsole = R6Console(Class'Engine.Actor'.static.GetCanvas().Viewport.Console);
					aConsole.LeaveR6Game(aConsole.2);					
				}
				else
				{
					WindowConsole(m_Player.Player.Console).Root.ChangeCurrentWidget(m_eEndGameWidgetID);
				}				
			}
			else
			{
				NativeRegisterServer();
				RestartGameMgr();
			}
		}
	}
	return;
}

function int SearchOperativesArray(bool bIsFemale, int iStartIndex)
{
	local int i;

	// End:0x12
	if((iStartIndex < 0))
	{
		iStartIndex = 0;
	}
	i = iStartIndex;
	J0x1D:

	// End:0x71 [Loop If]
	if((i < 30))
	{
		// End:0x4E
		if(bIsFemale)
		{
			// End:0x4B
			if((int(m_bRainbowFaces[i]) > 0))
			{
				return i;
			}
			// [Explicit Continue]
			goto J0x67;
		}
		// End:0x67
		if((int(m_bRainbowFaces[i]) == 0))
		{
			return i;
		}
		J0x67:

		(i++);
		// [Loop Continue]
		goto J0x1D;
	}
	return -1;
	return;
}

// for multiplayer only, an arbitrary face is selected based on sex
function int MPSelectOperativeFace(bool bIsFemale)
{
	local int iOperativeID;

	iOperativeID = -1;
	// End:0x86
	if(bIsFemale)
	{
		iOperativeID = SearchOperativesArray(bIsFemale, int(m_bCurrentFemaleId));
		// End:0x5D
		if((iOperativeID == -1))
		{
			m_bCurrentFemaleId = 0;
			iOperativeID = SearchOperativesArray(bIsFemale, int(m_bCurrentFemaleId));
		}
		m_bCurrentFemaleId = byte((iOperativeID + 1));
		// End:0x83
		if((int(m_bCurrentFemaleId) >= 30))
		{
			m_bCurrentFemaleId = 0;
		}		
	}
	else
	{
		iOperativeID = SearchOperativesArray(bIsFemale, int(m_bCurrentMaleId));
		// End:0xCF
		if((iOperativeID == -1))
		{
			m_bCurrentMaleId = 0;
			iOperativeID = SearchOperativesArray(bIsFemale, int(m_bCurrentMaleId));
		}
		m_bCurrentMaleId = byte((iOperativeID + 1));
		// End:0xF5
		if((int(m_bCurrentMaleId) >= 30))
		{
			m_bCurrentMaleId = 0;
		}
	}
	return iOperativeID;
	return;
}

//------------------------------------------------------------------
// ResetMatchStat
//	- used in adversarial
//------------------------------------------------------------------
function ResetMatchStat()
{
	local PlayerReplicationInfo PRI;

	// End:0x97
	foreach DynamicActors(Class'Engine.PlayerReplicationInfo', PRI)
	{
		PRI.m_iKillCount = 0;
		PRI.m_iRoundFired = 0;
		PRI.m_iRoundsHit = 0;
		PRI.m_iRoundsPlayed = 0;
		PRI.m_iRoundsWon = 0;
		PRI.Deaths = 0.0000000;
		PRI.m_szKillersName = "";
		PRI.m_bJoinedTeamLate = false;		
	}	
	return;
}

//special rset for stats if an admin wants to reset the round 
// thus reseting stats to what they were at the beginnning of last round.
function AdminResetRound()
{
	local PlayerReplicationInfo _PRI;

	// End:0x20
	foreach AllActors(Class'Engine.PlayerReplicationInfo', _PRI)
	{
		_PRI.AdminResetRound();		
	}	
	return;
}

//------------------------------------------------------------------
// ResetOriginalData
//	
//------------------------------------------------------------------
simulated function ResetOriginalData()
{
	// End:0x10
	if(m_bResetSystemLog)
	{
		LogResetSystem(false);
	}
	super(Actor).ResetOriginalData();
	m_bGameStarted = false;
	bGameEnded = false;
	bOverTime = false;
	bWaitingToStartMatch = true;
	m_bGameOver = false;
	m_bTimerStarted = false;
	m_fEndingTime = 0.0000000;
	m_bFadeStarted = false;
	m_bEndGameIgnoreGamePlayCheck = false;
	m_pCurPlayerCtrlMdfSrvInfo = none;
	SetUnlimitedPractice(false, false);
	return;
}

//------------------------------------------------------------------
// SetPlayerInPenaltyBox
//	
//------------------------------------------------------------------
function SetPlayerInPenaltyBox()
{
	local R6PlayerController PlayerController;

	// End:0x98
	foreach DynamicActors(Class'R6Engine.R6PlayerController', PlayerController)
	{
		PlayerController.m_bPenaltyBox = false;
		// End:0x97
		if(PlayerController.m_bHasAPenalty)
		{
			PlayerController.m_bPenaltyBox = true;
			// End:0x86
			if(((PlayerController.m_pawn != none) && PlayerController.m_pawn.InGodMode()))
			{
				PlayerController.m_bPenaltyBox = false;
			}
			PlayerController.m_bHasAPenalty = false;
		}		
	}	
	return;
}

//------------------------------------------------------------------
// ResetPlayerBlur
//	
//------------------------------------------------------------------
function ResetPlayerBlur()
{
	local R6PlayerController PlayerController;

	// End:0x20
	foreach DynamicActors(Class'R6Engine.R6PlayerController', PlayerController)
	{
		PlayerController.ResetBlur();		
	}	
	return;
}

//------------------------------------------------------------------
// ResetPenalty
//	
//------------------------------------------------------------------
function ResetPenalty()
{
	local R6PlayerController PlayerController;

	// End:0x33
	foreach DynamicActors(Class'R6Engine.R6PlayerController', PlayerController)
	{
		PlayerController.m_bPenaltyBox = false;
		PlayerController.m_bHasAPenalty = false;		
	}	
	return;
}

//------------------------------------------------------------------
// RestartGameMgr
//	when we want to restart a game, we check if it's a restart game
//  or a reset level that is required
//------------------------------------------------------------------
function RestartGameMgr()
{
	local R6MapList myList;
	local bool bChangeLevelAllowed;
	local PlayerController _playerController;
	local R6ServerInfo pServerOptions;

	// End:0x4E
	if((Level.NextURL ~= "?Restart"))
	{
		// End:0x4C
		if(bShowLog)
		{
			Log("You are ALREADY IN RESTART PROCESS");
		}
		return;
	}
	pServerOptions = Class'Engine.Actor'.static.GetServerOptions();
	ResetBroadcastGameMsg();
	ProcessChangeLevelSystem();
	SetPlayerInPenaltyBox();
	ResetPlayerBlur();
	// End:0x3A1
	if(bChangeLevels)
	{
		bChangeLevelAllowed = true;
		GameReplicationInfo.SetRepLastRoundSuccess(0);
		ResetPenalty();
		// End:0xC1
		if((int(Level.NetMode) == int(NM_Standalone)))
		{
			bChangeLevelAllowed = false;
		}
		// End:0x2AA
		if(bChangeLevelAllowed)
		{
			myList = pServerOptions.m_ServerMapList;
			// End:0x1FC
			if(((m_bJumpingMaps == true) || (m_bChangedServerConfig == true)))
			{
				// End:0x19D
				if((((m_bChangedServerConfig == false) && (myList.CheckNextMapIndex(m_iJumpMapIndex) == myList.CheckCurrentMap())) && (myList.CheckNextGameTypeIndex(m_iJumpMapIndex) == myList.CheckCurrentGameType())))
				{
					// End:0x195
					if(bShowLog)
					{
						Log("RESET: it's the same map and the same game type ");
					}
					bChangeLevelAllowed = false;
				}
				// End:0x1D5
				if((m_bChangedServerConfig == true))
				{
					BroadcastGameMsg("", "", "ServerOption");
					myList.GetNextMap(1);					
				}
				else
				{
					myList.GetNextMap(m_iJumpMapIndex);
				}
				m_bJumpingMaps = false;
				m_iJumpMapIndex = 0;				
			}
			else
			{
				// End:0x2A7
				if(((myList.CheckNextMap() == myList.CheckCurrentMap()) && (myList.CheckNextGameType() == myList.CheckCurrentGameType())))
				{
					// End:0x281
					if(bShowLog)
					{
						Log("RESET: it's the same map and the same game type ");
					}
					bChangeLevelAllowed = false;
					myList.GetNextMap(myList.-2);
				}
			}			
		}
		else
		{
			// End:0x2E5
			if(bShowLog)
			{
				Log("RESET: game type does not allow changing level");
			}
			bChangeLevelAllowed = false;
		}
		// End:0x332
		if(bChangeLevelAllowed)
		{
			// End:0x319
			if(bShowLog)
			{
				Log("RESET: changing level!");
			}
			RestartGame();
			ResetMatchStat();
			m_bChangedServerConfig = false;
			return;			
		}
		else
		{
			// End:0x392
			foreach DynamicActors(Class'Engine.PlayerController', _playerController)
			{
				_playerController.PlayerReplicationInfo.m_iRoundsPlayed = 0;
				_playerController.PlayerReplicationInfo.m_iRoundsWon = 0;
				_playerController.PlayerReplicationInfo.Deaths = 0.0000000;				
			}			
			bChangeLevels = false;
		}
		ResetMatchStat();
	}
	ResetRound();
	return;
}

function ResetRound()
{
	ResetOriginalData();
	(m_iNbOfRestart++);
	Level.ResetLevel(m_iNbOfRestart);
	// End:0x44
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		GotoState('None');		
	}
	else
	{
		// End:0x58
		if(IsInState('InBetweenRoundMenu'))
		{
			BeginState();			
		}
		else
		{
			GotoState('InBetweenRoundMenu');
		}
	}
	return;
}

//------------------------------------------------------------------
// SpawnAI
//	
//------------------------------------------------------------------
function SpawnAI()
{
	local R6DeploymentZone PZone;
	local R6Terrorist pTerrorist;

	// End:0x35
	if(bShowLog)
	{
		Log("SpawnAI: load terrorsit/hostage/civilian");
	}
	// End:0x55
	foreach AllActors(Class'R6Engine.R6DeploymentZone', PZone)
	{
		PZone.InitZone();		
	}	
	// End:0x79
	foreach DynamicActors(Class'R6Engine.R6Terrorist', pTerrorist)
	{
		m_listAllTerrorists[m_listAllTerrorists.Length] = pTerrorist;		
	}	
	return;
}

//------------------------------------------------------------------
// SetGameTypeInLocal
//	set m_szGameTypeFlag in the GameRepInfo of the local player
//------------------------------------------------------------------
function SetGameTypeInLocal()
{
	local R6PlayerController PController;
	local Controller P;
	local Actor anActor;

	// End:0x1B
	if((int(Level.NetMode) == int(NM_DedicatedServer)))
	{
		return;
	}
	P = Level.ControllerList;
	J0x2F:

	// End:0xAB [Loop If]
	if((P != none))
	{
		PController = R6PlayerController(P);
		// End:0x8D
		if((PController != none))
		{
			// End:0x71
			if((int(Level.NetMode) == int(NM_Standalone)))
			{
				// [Explicit Break]
				goto J0xAB;
			}
			// End:0x8D
			if((Viewport(PController.Player) != none))
			{
				// [Explicit Break]
				goto J0xAB;
			}
		}
		PController = none;
		P = P.nextController;
		// [Loop Continue]
		goto J0x2F;
	}
	J0xAB:

	// End:0xED
	if((PController != none))
	{
		PController.GameReplicationInfo.m_szGameTypeFlagRep = m_szGameTypeFlag;
		PController.GameReplicationInfo.m_bReceivedGameType = 1;
	}
	return;
}

//------------------------------------------------------------------
// SpawnAIandInitGoInGame
//	
//------------------------------------------------------------------
function SpawnAIandInitGoInGame()
{
	local R6MissionObjectiveMgr aMgr;
	local R6IORotatingDoor Door;

	// End:0x23
	if(bShowLog)
	{
		Log("SpawnAIandInitGoInGame");
	}
	SpawnAI();
	aMgr = m_missionMgr;
	m_missionMgr = none;
	// End:0x52
	if((aMgr != none))
	{
		aMgr.Destroy();
	}
	// End:0x6C
	if((GameReplicationInfo != none))
	{
		GameReplicationInfo.ResetRepMObjInfo();
	}
	CreateMissionObjectiveMgr();
	m_missionMgr.m_bEnableCheckForErrors = true;
	InitObjectives();
	// End:0xB3
	if(m_bUnlockAllDoors)
	{
		// End:0xB2
		foreach AllActors(Class'R6Engine.R6IORotatingDoor', Door)
		{
			Door.UnlockDoor();			
		}		
	}
	// End:0xE6
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		m_fRoundStartTime = Level.TimeSeconds;
		SetGameTypeInLocal();
	}
	return;
}

// this function will decide if KillerPawn should be a spectator in the next round
function SetTeamKillerPenalty(Pawn DeadPawn, Pawn KillerPawn)
{
	local R6PlayerController pControllerDead, pControllerKiller;

	// End:0x19
	if(Level.IsGameTypeCooperative(m_szGameTypeFlag))
	{
		return;
	}
	pControllerKiller = R6PlayerController(R6Pawn(KillerPawn).Controller);
	// End:0x5F
	if(((pControllerKiller == none) || (!Level.IsGameTypeMultiplayer(m_szGameTypeFlag))))
	{
		return;
	}
	pControllerDead = R6PlayerController(R6Pawn(DeadPawn).Controller);
	// End:0xD8
	if(((int(DeadPawn.m_ePawnType) == int(3)) && (KillerPawn != DeadPawn)))
	{
		pControllerKiller.m_ePenaltyForKillingAPawn = DeadPawn.m_ePawnType;
		pControllerKiller.m_bHasAPenalty = true;		
	}
	else
	{
		// End:0x189
		if((((m_bTKPenalty && KillerPawn.IsFriend(DeadPawn)) && (KillerPawn != DeadPawn)) && (!pControllerDead.m_bAlreadyPoppedTKPopUpBox)))
		{
			pControllerDead.m_TeamKiller = pControllerKiller;
			pControllerDead.TKPopUpBox(pControllerKiller.PlayerReplicationInfo.PlayerName);
			pControllerDead.m_bAlreadyPoppedTKPopUpBox = true;
			pControllerKiller.m_ePenaltyForKillingAPawn = DeadPawn.m_ePawnType;
		}
	}
	return;
}

function bool ProcessPlayerReadyStatus()
{
	local R6PlayerController _playerController;
	local Controller P;
	local int _iCount;

	P = Level.ControllerList;
	J0x14:

	// End:0x8E [Loop If]
	if((P != none))
	{
		_playerController = R6PlayerController(P);
		// End:0x77
		if(((_playerController != none) && (!_playerController.IsPlayerPassiveSpectator())))
		{
			(_iCount++);
			// End:0x77
			if((_playerController.PlayerReplicationInfo.m_bPlayerReady == false))
			{
				return false;
			}
		}
		P = P.nextController;
		// [Loop Continue]
		goto J0x14;
	}
	return (_iCount > 0);
	return;
}

//------------------------------------------------------------------
// BroadcastGameTypeDescription
//	
//------------------------------------------------------------------
function BroadcastGameTypeDescription()
{
	local Controller P;
	local R6PlayerController PlayerController;

	P = Level.ControllerList;
	J0x14:

	// End:0x98 [Loop If]
	if((P != none))
	{
		// End:0x81
		if(P.IsA('PlayerController'))
		{
			PlayerController = R6PlayerController(P);
			// End:0x81
			if(((!PlayerController.bOnlySpectator) && (!PlayerController.IsPlayerPassiveSpectator())))
			{
				PlayerController.ClientGameTypeDescription(m_szGameTypeFlag);
			}
		}
		P = P.nextController;
		// [Loop Continue]
		goto J0x14;
	}
	return;
}

//------------------------------------------------------------------
// BroadcastGameMsg
//	
//------------------------------------------------------------------
function BroadcastGameMsg(string szLocFile, string szPreMsg, string szMsgID, optional Sound sndGameStatus, optional int iLifeTime)
{
	local Controller P;
	local R6PlayerController PlayerController;

	P = Level.ControllerList;
	J0x14:

	// End:0x82 [Loop If]
	if((P != none))
	{
		// End:0x6B
		if(P.IsA('PlayerController'))
		{
			PlayerController = R6PlayerController(P);
			PlayerController.ClientGameMsg(szLocFile, szPreMsg, szMsgID, sndGameStatus, iLifeTime);
		}
		P = P.nextController;
		// [Loop Continue]
		goto J0x14;
	}
	return;
}

//------------------------------------------------------------------
// BroadcastMissionObjMsg
//	
//------------------------------------------------------------------
function BroadcastMissionObjMsg(string szLocFile, string szPreMsg, string szMsgID, optional Sound sndGameStatus, optional int iLifeTime)
{
	local Controller P;
	local R6PlayerController PlayerController;

	P = Level.ControllerList;
	J0x14:

	// End:0x82 [Loop If]
	if((P != none))
	{
		// End:0x6B
		if(P.IsA('PlayerController'))
		{
			PlayerController = R6PlayerController(P);
			PlayerController.ClientMissionObjMsg(szLocFile, szPreMsg, szMsgID, sndGameStatus, iLifeTime);
		}
		P = P.nextController;
		// [Loop Continue]
		goto J0x14;
	}
	return;
}

function ResetBroadcastGameMsg()
{
	local Controller P;
	local R6PlayerController PlayerController;

	P = Level.ControllerList;
	J0x14:

	// End:0x69 [Loop If]
	if((P != none))
	{
		// End:0x52
		if(P.IsA('PlayerController'))
		{
			PlayerController = R6PlayerController(P);
			PlayerController.ClientResetGameMsg();
		}
		P = P.nextController;
		// [Loop Continue]
		goto J0x14;
	}
	return;
}

//============================================================================
// PawnKilled - 
//============================================================================
function PawnKilled(Pawn killed)
{
	local R6Hostage hostage;

	RemoveTerroFromList(killed);
	// End:0x124
	if(m_bFeedbackHostageKilled)
	{
		hostage = R6Hostage(killed);
		// End:0x124
		if((hostage != none))
		{
			// End:0x60
			if(hostage.m_bPoliceManMp1)
			{
				BroadcastMissionObjMsg("", "", "PolicemanHasDied");				
			}
			else
			{
				// End:0x90
				if(hostage.m_bCivilian)
				{
					BroadcastMissionObjMsg("", "", "CivilianHasDied");					
				}
				else
				{
					// End:0xDA
					if(hostage.m_bClassicMissionCivilian)
					{
						BroadcastMissionObjMsg("IronWrathMissionObjectives", "", "CivilianHasDied");						
					}
					else
					{
						// End:0x124
						if(((!(hostage.m_iPrisonierTeam == 5)) && (!(hostage.m_iPrisonierTeam == 6))))
						{
							BroadcastMissionObjMsg("", "", "HostageHasDied");
						}
					}
				}
			}
		}
	}
	super.PawnKilled(killed);
	return;
}

//============================================================================
// RemoveTerroFromList - 
//============================================================================
function RemoveTerroFromList(Pawn toRemove)
{
	local int i;
	local R6Terrorist aTerrorist;

	aTerrorist = R6Terrorist(toRemove);
	// End:0x7D
	if((aTerrorist != none))
	{
		i = 0;
		J0x22:

		// End:0x60 [Loop If]
		if((i < m_listAllTerrorists.Length))
		{
			// End:0x56
			if((m_listAllTerrorists[i] == aTerrorist))
			{
				m_listAllTerrorists.Remove(i, 1);
				// [Explicit Break]
				goto J0x60;
			}
			(i++);
			// [Loop Continue]
			goto J0x22;
		}
		J0x60:

		// End:0x7D
		if((m_listAllTerrorists.Length == 1))
		{
			m_listAllTerrorists[0].StartHunting();
		}
	}
	return;
}

function bool IsUnlimitedPractice()
{
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	return pGameOptions.UnlimitedPractice;
	return;
}

exec function SetUnlimitedPractice(bool bUnlimitedPractice, bool bInGameProcess)
{
	local R6GameOptions pGameOptions;

	// End:0x1B
	if((int(Level.NetMode) != int(NM_Standalone)))
	{
		return;
	}
	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	pGameOptions.UnlimitedPractice = bUnlimitedPractice;
	// End:0xCD
	if(bInGameProcess)
	{
		// End:0x75
		if((!pGameOptions.UnlimitedPractice))
		{
			// End:0x75
			if(CheckEndGame(none, ""))
			{
				EndGame(none, "");
			}
		}
		// End:0xAB
		if(pGameOptions.UnlimitedPractice)
		{
			BroadcastGameMsg("", "", "UnlimitedPracticeTRUE");			
		}
		else
		{
			BroadcastGameMsg("", "", "UnlimitedPracticeFALSE");
		}
	}
	return;
}

function DestroyBeacon()
{
	local UdpBeacon aBeacon;

	// End:0x1D
	foreach AllActors(Class'IpDrv.UdpBeacon', aBeacon)
	{
		aBeacon.Destroy();		
	}	
	return;
}

//------------------------------------------------------------------
// EnteredExtractionZone
//	
//------------------------------------------------------------------
function EnteredExtractionZone(Actor Other)
{
	local R6Hostage hostage;

	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	// End:0xCB
	if(m_bFeedbackHostageExtracted)
	{
		hostage = R6Hostage(Other);
		// End:0xCB
		if(((((((hostage != none) && hostage.IsAlive()) && hostage.m_bExtracted) && (!hostage.m_bFeedbackExtracted)) && (!hostage.m_bPoliceManMp1)) && (!hostage.m_bCivilian)))
		{
			BroadcastMissionObjMsg("", "", "HostageHasBeenRescued");
			hostage.m_bFeedbackExtracted = true;
		}
	}
	super.EnteredExtractionZone(Other);
	return;
}

//------------------------------------------------------------------
// CanPlayIntroVideo
//	
//------------------------------------------------------------------
event bool CanPlayIntroVideo()
{
	// End:0x13
	if(m_bPlayIntroVideo)
	{
		m_bPlayIntroVideo = false;
		return true;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// CanPlayOutroVideo
//	
//------------------------------------------------------------------
event bool CanPlayOutroVideo()
{
	// End:0x1A
	if(((!m_bPlayOutroVideo) || (m_missionMgr == none)))
	{
		return false;
	}
	// End:0x3D
	if((int(m_missionMgr.m_eMissionObjectiveStatus) == int(1)))
	{
		m_bPlayOutroVideo = false;
		return true;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// GetNbTerroNeutralized
//	
//------------------------------------------------------------------
function int GetNbTerroNeutralized()
{
	local R6Terrorist aTerrorist;
	local int iTerroNeutralized;

	// End:0x55
	foreach DynamicActors(Class'R6Engine.R6Terrorist', aTerrorist)
	{
		// End:0x54
		if((((!aTerrorist.IsAlive()) || aTerrorist.m_bIsKneeling) || aTerrorist.m_bIsUnderArrest))
		{
			(iTerroNeutralized += 1);
		}		
	}	
	return iTerroNeutralized;
	return;
}

function ChangeName(Controller Other, coerce string S, bool bNameChange, optional bool bDontBroadcastNameChange)
{
	local R6Rainbow aRainbow;
	local R6Pawn pOther;
	local string szPreviousName;
	local R6PlayerController P;

	szPreviousName = Other.PlayerReplicationInfo.PlayerName;
	super(GameInfo).ChangeName(Other, S, bNameChange, bDontBroadcastNameChange);
	// End:0x5C
	if((Other.PlayerReplicationInfo.PlayerName == szPreviousName))
	{
		return;
	}
	// End:0xB3
	if((bDontBroadcastNameChange == false))
	{
		// End:0xB2
		foreach DynamicActors(Class'R6Engine.R6PlayerController', P)
		{
			P.ClientMPMiscMessage("IsNowKnownAs", szPreviousName, Other.PlayerReplicationInfo.PlayerName);			
		}		
	}
	return;
}

event UpdateServer()
{
	m_GameService.NativeUpdateServer();
	return;
}

defaultproperties
{
	m_eEndGameWidgetID=2
	m_bRainbowFaces[7]=1
	m_bRainbowFaces[11]=1
	m_bRainbowFaces[23]=1
	m_bRainbowFaces[24]=1
	m_bRainbowFaces[27]=1
	m_bRainbowFaces[28]=1
	m_iCurrentID=1
	m_iMaxOperatives=8
	m_bIsRadarAllowed=true
	m_bIsWritableMapAllowed=true
	m_bFeedbackHostageKilled=true
	m_bFeedbackHostageExtracted=true
	DefaultFaceTexture=Texture'R6MenuOperative.RS6_Memeber_01'
	DefaultFaceCoords=(W=42.0000000,X=472.0000000,Y=308.0000000,Z=38.0000000)
	m_fTimeBetRounds=5.0000000
	CurrentID=100
	GameReplicationInfoClass=Class'R6Engine.R6GameReplicationInfo'
	DefaultPlayerClassName="R6Game.R6PlanningPawn"
	HUDType="R6Game.R6PlanningHud"
	GameName="Rainbow6"
	PlayerControllerClassName="R6Game.R6PlanningCtrl"
	m_szGameTypeFlag="RGM_NoRulesMode"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function ToggleRestart
// REMOVED IN 1.60: function SaveTrainingPlanning
// REMOVED IN 1.60: function AbortScoreSubmission
