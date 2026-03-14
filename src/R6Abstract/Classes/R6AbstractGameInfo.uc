//=============================================================================
// R6AbstractGameInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6AbstractGameInfo.uc : This is the abstract class for the R6GameInfo class.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    august 8th, 2001 * Created by Chaouky Garram
//=============================================================================
class R6AbstractGameInfo extends GameInfo
    abstract
    native
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var int m_iNbOfRainbowAIToSpawn;
var int m_iNbOfTerroristToSpawn;  // this is now set in the game info init
var int m_iDiffLevel;  // The difficulty level of the terro -- in coop
var int m_fTimerStartTime;  // Time at which we began counting down
var bool m_bFriendlyFire;
var bool m_bEndGameIgnoreGamePlayCheck;
var bool m_bGameOverButAllowDeath;
var bool m_bTimerStarted;  // Boolean to inticate that we have started the countdown
var bool m_bInternetSvr;  // The server is a internet server
var float m_fEndingTime;  // Time the round will end at in seconds.
var float m_fTimeBetRounds;  // Time between round (seconds)
// NEW IN 1.60
var float m_fEndVoteTime;
var PlayerController m_Player;  // AK: local player controller VALID *ONLY* FOR SINGLE PLAYER MODE!!!!!!!
var R6AbstractNoiseMgr m_noiseMgr;  // Manager for the loudness of MakeNoise sound
// the following flag can be used for to determine game mode
var R6MissionObjectiveMgr m_missionMgr;
var PlayerController m_PlayerKick;  // this is the player who may be kicked
var PlayerController m_pCurPlayerCtrlMdfSrvInfo;  // the player controller who's modifying the server settings
var UdpBeacon m_UdpBeacon;
// NEW IN 1.60
var string m_VoteInstigatorName;
var string m_szDefaultActionPlan;  // To have the right part of the name of the action planning. The left part is the name of the map.

function Object GetRainbowTeam(int eTeamName)
{
	return;
}

function Actor GetNewTeam(Actor aCurrentTeam, optional bool bNextTeam)
{
	return;
}

function ChangeTeams(PlayerController inPlayerController, optional bool bPrevTeam, optional Actor newRainbowTeam)
{
	return;
}

function ChangeOperatives(PlayerController inPlayerController, int iTeamId, int iOperativeID)
{
	return;
}

function InstructAllTeamsToHoldPosition()
{
	return;
}

function InstructAllTeamsToFollowPlanning()
{
	return;
}

function BroadcastGameMsg(string szLocFile, string szPreMsg, string szMsgID, optional Sound sndGameStatus, optional int iLifeTime)
{
	return;
}

function R6AbstractNoiseMgr GetNoiseMgr()
{
	return;
}

function Object GetMultiCoopPlayerVoicesMgr(int iTeam)
{
	return;
}

function Object GetMultiCoopMemberVoicesMgr()
{
	return;
}

function Object GetPreRecordedMsgVoicesMgr()
{
	return;
}

function Object GetMultiCommonVoicesMgr()
{
	return;
}

function Object GetRainbowPlayerVoicesMgr()
{
	return;
}

function Object GetRainbowMemberVoicesMgr()
{
	return;
}

function Object GetCommonRainbowPlayerVoicesMgr()
{
	return;
}

function Object GetCommonRainbowMemberVoicesMgr()
{
	return;
}

function Object GetRainbowOtherTeamVoicesMgr(int iIDVoicesMgr)
{
	return;
}

function Object GetTerroristVoicesMgr(Actor.ETerroristNationality eNationality)
{
	return;
}

function Object GetHostageVoicesMgr(Actor.EHostageNationality eNationality, bool bIsFemale)
{
	return;
}

function bool ProcessKickVote(PlayerController _KickPlayer, string KickersName)
{
	return;
}

// NEW IN 1.60
function bool ProcessChangeMapVote(string InstigatorName)
{
	return;
}

function ResetRound()
{
	return;
}

function AdminResetRound()
{
	return;
}

function ResetPenalty()
{
	return;
}

function SetJumpingMaps(bool _flagSetting, int iNextMapIndex)
{
	return;
}

function UpdateRepResArrays()
{
	return;
}

function PauseCountDown()
{
	return;
}

function UnPauseCountDown()
{
	return;
}

function StartTimer()
{
	return;
}

function bool IsTeamSelectionLocked()
{
	return;
}

function bool CanSwitchTeamMember()
{
	return true;
	return;
}

function Actor GetRainbowAIFromTable()
{
	return none;
	return;
}

function bool RainbowOperativesStillAlive()
{
	return false;
	return;
}

function int GetNbOfRainbowAIToSpawn(PlayerController aController)
{
	return m_iNbOfRainbowAIToSpawn;
	return;
}

function CreateMissionObjectiveMgr()
{
	// End:0x19
	if(__NFUN_114__(m_missionMgr, none))
	{
		m_missionMgr = __NFUN_278__(Class'R6Abstract.R6MissionObjectiveMgr');
	}
	return;
}

function BroadcastMissionObjMsg(string szLocMsg, string szPreMsg, string szMsgID, optional Sound sndGameStatus, optional int iLifeTime)
{
	return;
}

function UpdateRepMissionObjectivesStatus()
{
	return;
}

function UpdateRepMissionObjectives()
{
	return;
}

function ResetRepMissionObjectives()
{
	return;
}

function Find2DTexture(string TeamClass, out Material MenuTexture, out Region TextureRegion)
{
	return;
}

function SpawnAIandInitGoInGame()
{
	return;
}

function InitObjectives()
{
	return;
}

function RemoveObjectives()
{
	m_missionMgr.RemoveObjectives();
	return;
}

function PawnKilled(Pawn killed)
{
	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	m_missionMgr.PawnKilled(killed);
	// End:0x34
	if(CheckEndGame(none, ""))
	{
		EndGame(none, "");
	}
	return;
}

function RemoveTerroFromList(Pawn toRemove)
{
	return;
}

function PawnSeen(Pawn seen, Pawn witness)
{
	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	m_missionMgr.PawnSeen(seen, witness);
	// End:0x39
	if(CheckEndGame(none, ""))
	{
		EndGame(none, "");
	}
	return;
}

function PawnHeard(Pawn heard, Pawn witness)
{
	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	m_missionMgr.PawnHeard(heard, witness);
	// End:0x39
	if(CheckEndGame(none, ""))
	{
		EndGame(none, "");
	}
	return;
}

function PawnSecure(Pawn secured)
{
	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	m_missionMgr.PawnSecure(secured);
	// End:0x34
	if(CheckEndGame(none, ""))
	{
		EndGame(none, "");
	}
	return;
}

function bool IsLastRoundOfTheMatch()
{
	return;
}

//------------------------------------------------------------------
// GetEndGamePauseTime
//	return the time needed when the game is over and we still
//  stay in game to see and heard the end of round result
//------------------------------------------------------------------
function float GetEndGamePauseTime()
{
	// End:0x2B
	if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
	{
		return Level.m_fEndGamePauseTime;		
	}
	else
	{
		// End:0x5D
		if(Level.IsGameTypeCooperative(Level.Game.m_szGameTypeFlag))
		{
			return 6.0000000;			
		}
		else
		{
			// End:0x6F
			if(IsLastRoundOfTheMatch())
			{
				return 6.0000000;				
			}
			else
			{
				return 4.0000000;
			}
		}
	}
	return;
}

//------------------------------------------------------------------
// GetGameMsgLifeTime
//	return the life time of game msg
//------------------------------------------------------------------
function float GetGameMsgLifeTime()
{
	// End:0x2D
	if(__NFUN_130__(IsLastRoundOfTheMatch(), __NFUN_155__(int(Level.NetMode), int(NM_Standalone))))
	{
		return 10.0000000;		
	}
	else
	{
		return 5.0000000;
	}
	return;
}

function BaseEndGame()
{
	return;
}

//------------------------------------------------------------------
// EndGameAndJumpToMapID
//	set info to jump to a map, end game by aborting the mission without 
//  game stats effect
//------------------------------------------------------------------
function EndGameAndJumpToMapID(int iGotoMapId)
{
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.__NFUN_1273__();
	// End:0x51
	if(__NFUN_130__(__NFUN_119__(pServerOptions, none), __NFUN_119__(pServerOptions.m_ServerMapList, none)))
	{
		pServerOptions.m_ServerMapList.GetNextMap(iGotoMapId);
	}
	__NFUN_1210__();
	SetJumpingMaps(true, iGotoMapId);
	// End:0x81
	if(__NFUN_132__(__NFUN_281__('InBetweenRoundMenu'), __NFUN_281__('PostBetweenRoundTime')))
	{
		RestartGameMgr();		
	}
	else
	{
		BaseEndGame();
		m_bEndGameIgnoreGamePlayCheck = true;
	}
	return;
}

function AbortMission()
{
	m_missionMgr.AbortMission();
	CheckEndGame(none, "");
	EndGame(none, "");
	m_bTimerStarted = true;
	m_fTimerStartTime = int(__NFUN_175__(__NFUN_175__(Level.TimeSeconds, GetEndGamePauseTime()), float(1)));
	m_fTimerStartTime = __NFUN_251__(m_fTimerStartTime, 0, int(Level.TimeSeconds));
	return;
}

function CompleteMission()
{
	m_missionMgr.CompleteMission();
	CheckEndGame(none, "");
	EndGame(none, "");
	return;
}

function EnteredExtractionZone(Actor Other)
{
	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	m_missionMgr.EnteredExtractionZone(Pawn(Other));
	// End:0x39
	if(CheckEndGame(none, ""))
	{
		EndGame(none, "");
	}
	return;
}

function LeftExtractionZone(Actor Other)
{
	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	m_missionMgr.ExitExtractionZone(Pawn(Other));
	// End:0x39
	if(CheckEndGame(none, ""))
	{
		EndGame(none, "");
	}
	return;
}

function IObjectInteract(Pawn aPawn, Actor anInteractiveObject)
{
	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	// End:0x18
	if(__NFUN_114__(m_missionMgr, none))
	{
		return;
	}
	m_missionMgr.IObjectInteract(aPawn, anInteractiveObject);
	// End:0x46
	if(CheckEndGame(none, ""))
	{
		EndGame(none, "");
	}
	return;
}

function IObjectDestroyed(Pawn aPawn, Actor anInteractiveObject)
{
	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	m_missionMgr.IObjectDestroyed(aPawn, anInteractiveObject);
	// End:0x39
	if(CheckEndGame(none, ""))
	{
		EndGame(none, "");
	}
	return;
}

function TimerCountdown()
{
	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	// End:0x20
	if(CheckEndGame(none, ""))
	{
		EndGame(none, "");
	}
	return;
}

function ResetPlayerTeam(Controller aPlayer)
{
	return;
}

function RemoveController(Controller aPlayer)
{
	return;
}

function SetPawnTeamFriendlies(Pawn aPawn)
{
	SetDefaultTeamFriendlies(aPawn);
	return;
}

//------------------------------------------------------------------
// SetDefaultTeamFriendlies: set the default value based on single
//	player mode. 
//------------------------------------------------------------------
function SetDefaultTeamFriendlies(Pawn aPawn)
{
	return;
}

// this function will decide if KillerPawn should be a spectator in the next round
function SetTeamKillerPenalty(Pawn DeadPawn, Pawn KillerPawn)
{
	return;
}

function ApplyTeamKillerPenalty(Pawn aPawn)
{
	return;
}

 // if this function has not been defined then always return false
function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	return false;
	return;
}

function PostBeginPlay()
{
	__NFUN_280__(0.0000000, false);
	return;
}

function PlayerReadySelected(PlayerController _Controller)
{
	return;
}

function IncrementRoundsFired(Pawn Instigator, bool ForceIncrement)
{
	return;
}

//------------------------------------------------------------------
// NotifyMatchStart: fired when the round start
//	
//------------------------------------------------------------------
function NotifyMatchStart()
{
	return;
}

function bool ProcessPlayerReadyStatus()
{
	return;
}

function bool IsUnlimitedPractice()
{
	return;
}

exec function SetUnlimitedPractice(bool bUnlimitedPractice, optional bool bSendMsg)
{
	return;
}

function LogVoteInfo()
{
	return;
}

function string GetIntelVideoName(R6MissionDescription Desc)
{
	return "generic_intel";
	return;
}

defaultproperties
{
	m_iNbOfTerroristToSpawn=1
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_fEndKickVoteTime
// REMOVED IN 1.60: var m_KickersName
