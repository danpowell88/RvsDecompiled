//=============================================================================
// R6AbstractGameInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6AbstractGameInfo.uc : This is the abstract class for the R6GameInfo class.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    august 8th, 2001 * Created by Chaouky Garram
//=============================================================================
// R6AbstractGameInfo: abstract base for all Ravenshield game modes (singleplayer, co-op, multiplayer).
// Provides the shared interface consumed by the mission objective manager and game-event hooks.
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

// Lazy-spawn the singleton mission objective manager if it hasn't been created yet.
function CreateMissionObjectiveMgr()
{
	// End:0x19
	if((m_missionMgr == none))
	{
		m_missionMgr = Spawn(Class'R6Abstract.R6MissionObjectiveMgr');
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

// Delegates kill notification to the objective manager, then checks whether the game should end.
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

// Delegates sight event to the objective manager (e.g., for "don't be detected" objectives).
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

// Delegates sound-detection event to the objective manager (e.g., stealth/noise objectives).
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

// Delegates hostage-secured event to the objective manager (rescue missions use this to track extractions).
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
	// Standalone uses the level-configured value; co-op and last MP round both show 6s; normal MP rounds show 4s.
	if((int(Level.NetMode) == int(NM_Standalone)))
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
	// Last round of a match gets 10s so clients can finish reading the end-match scoreboard message.
	if((IsLastRoundOfTheMatch() && (int(Level.NetMode) != int(NM_Standalone))))
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
// Jumps to a specific map by ID without recording game stats — used by admin map-change commands.
function EndGameAndJumpToMapID(int iGotoMapId)
{
	local R6ServerInfo pServerOptions;

	pServerOptions = Class'Engine.Actor'.static.GetServerOptions();
	// End:0x51
	if(((pServerOptions != none) && (pServerOptions.m_ServerMapList != none)))
	{
		pServerOptions.m_ServerMapList.GetNextMap(iGotoMapId);
	}
	AbortScoreSubmission();
	SetJumpingMaps(true, iGotoMapId);
	// End:0x81
	// If already between rounds, restart the round manager directly; otherwise end the current game.
	if((IsInState('InBetweenRoundMenu') || IsInState('PostBetweenRoundTime')))
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

// Forces a mission failure: marks all objectives failed, ends the game, and skips the normal pause delay.
function AbortMission()
{
	m_missionMgr.AbortMission();
	CheckEndGame(none, "");
	EndGame(none, "");
	m_bTimerStarted = true;
	// Wind the clock back so the end-game timer expires nearly immediately (skips the pause wait).
	m_fTimerStartTime = int(((Level.TimeSeconds - GetEndGamePauseTime()) - float(1)));
	m_fTimerStartTime = Clamp(m_fTimerStartTime, 0, int(Level.TimeSeconds));
	return;
}

// Forces mission success: marks all objectives complete and ends the game immediately.
function CompleteMission()
	CheckEndGame(none, "");
	EndGame(none, "");
	return;
}

// Notifies the objective manager that a pawn entered an extraction zone (may satisfy extraction objectives).
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

// Notifies the objective manager that a pawn left an extraction zone (may revert partial extraction progress).
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

// Notifies the objective manager that a pawn interacted with an object (e.g., defusing a bomb).
function IObjectInteract(Pawn aPawn, Actor anInteractiveObject)
{
	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	// End:0x18
	if((m_missionMgr == none))
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

// Notifies the objective manager that a destructible object was destroyed (may fail a "protect" objective).
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

// Called each timer tick while a round countdown is active; ends the game if the time limit is reached.
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

// Base implementation always returns false; subclasses must override to implement actual win/lose conditions.
 // if this function has not been defined then always return false
function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	return false;
	return;
}

function PostBeginPlay()
{
	// Unreal's GameInfo enables its tick-timer by default; Ravenshield uses its own timer management.
	SetTimer(0.0000000, false);
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
