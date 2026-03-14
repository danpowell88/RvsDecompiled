//=============================================================================
//  R6AbstractGameInfo.uc : This is the abstract class for the R6GameInfo class.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    august 8th, 2001 * Created by Chaouky Garram
//=============================================================================
class R6AbstractGameInfo extends GameInfo
    native
    abstract;

// --- Variables ---
// var ? m_KickersName; // REMOVED IN 1.60
// var ? m_fEndKickVoteTime; // REMOVED IN 1.60
// the following flag can be used for to determine game mode
var R6MissionObjectiveMgr m_missionMgr;
// Time at which we began counting down
var int m_fTimerStartTime;
var int m_iNbOfRainbowAIToSpawn;
var bool m_bEndGameIgnoreGamePlayCheck;
// Boolean to inticate that we have started the countdown
var bool m_bTimerStarted;
var UdpBeacon m_UdpBeacon;
// The server is a internet server
var bool m_bInternetSvr;
// To have the right part of the name of the action planning. The left part is the name of the map.
var string m_szDefaultActionPlan;
// the player controller who's modifying the server settings
var PlayerController m_pCurPlayerCtrlMdfSrvInfo;
// this is the player who may be kicked
var PlayerController m_PlayerKick;
var string m_VoteInstigatorName;
// ^ NEW IN 1.60
var float m_fEndVoteTime;
// ^ NEW IN 1.60
// Time between round (seconds)
var float m_fTimeBetRounds;
// Time the round will end at in seconds.
var float m_fEndingTime;
// The difficulty level of the terro -- in coop
var int m_iDiffLevel;
var bool m_bGameOverButAllowDeath;
var bool m_bFriendlyFire;
// this is now set in the game info init
var int m_iNbOfTerroristToSpawn;
// Manager for the loudness of MakeNoise sound
var R6AbstractNoiseMgr m_noiseMgr;
// AK: local player controller VALID *ONLY* FOR SINGLE PLAYER MODE!!!!!!!
var PlayerController m_Player;

// --- Functions ---
//------------------------------------------------------------------
// EndGameAndJumpToMapID
//	set info to jump to a map, end game by aborting the mission without
//  game stats effect
//------------------------------------------------------------------
function EndGameAndJumpToMapID(int iGotoMapId) {}
function SetPawnTeamFriendlies(Pawn aPawn) {}
function IObjectDestroyed(Actor anInteractiveObject, Pawn aPawn) {}
function IObjectInteract(Actor anInteractiveObject, Pawn aPawn) {}
function LeftExtractionZone(Actor Other) {}
function EnteredExtractionZone(Actor Other) {}
function PawnSecure(Pawn secured) {}
function PawnHeard(Pawn witness, Pawn heard) {}
function PawnSeen(Pawn witness, Pawn seen) {}
function PawnKilled(Pawn killed) {}
function ChangeTeams(optional bool bPrevTeam, optional Actor newRainbowTeam, PlayerController inPlayerController) {}
function ChangeOperatives(PlayerController inPlayerController, int iTeamId, int iOperativeID) {}
function InstructAllTeamsToHoldPosition() {}
function InstructAllTeamsToFollowPlanning() {}
function BroadcastGameMsg(string szLocFile, string szPreMsg, string szMsgID, optional Sound sndGameStatus, optional int iLifeTime) {}
function R6AbstractNoiseMgr GetNoiseMgr() {}
// ^ NEW IN 1.60
function Object GetMultiCoopPlayerVoicesMgr(int iTeam) {}
// ^ NEW IN 1.60
function Object GetMultiCoopMemberVoicesMgr() {}
// ^ NEW IN 1.60
function Object GetPreRecordedMsgVoicesMgr() {}
// ^ NEW IN 1.60
function Object GetMultiCommonVoicesMgr() {}
// ^ NEW IN 1.60
function Object GetRainbowPlayerVoicesMgr() {}
// ^ NEW IN 1.60
function Object GetRainbowMemberVoicesMgr() {}
// ^ NEW IN 1.60
function Object GetCommonRainbowPlayerVoicesMgr() {}
// ^ NEW IN 1.60
function Object GetCommonRainbowMemberVoicesMgr() {}
// ^ NEW IN 1.60
function Object GetRainbowOtherTeamVoicesMgr(int iIDVoicesMgr) {}
// ^ NEW IN 1.60
function Object GetTerroristVoicesMgr(ETerroristNationality eNationality) {}
// ^ NEW IN 1.60
function Object GetHostageVoicesMgr(EHostageNationality eNationality, bool bIsFemale) {}
// ^ NEW IN 1.60
function bool ProcessKickVote(PlayerController _KickPlayer, string KickersName) {}
// ^ NEW IN 1.60
function bool ProcessChangeMapVote(string InstigatorName) {}
// ^ NEW IN 1.60
function ResetRound() {}
function AdminResetRound() {}
function ResetPenalty() {}
function SetJumpingMaps(bool _flagSetting, int iNextMapIndex) {}
function UpdateRepResArrays() {}
function PauseCountDown() {}
function UnPauseCountDown() {}
function StartTimer() {}
function bool IsTeamSelectionLocked() {}
// ^ NEW IN 1.60
function bool CanSwitchTeamMember() {}
// ^ NEW IN 1.60
function Actor GetRainbowAIFromTable() {}
// ^ NEW IN 1.60
function bool RainbowOperativesStillAlive() {}
// ^ NEW IN 1.60
function int GetNbOfRainbowAIToSpawn(PlayerController aController) {}
// ^ NEW IN 1.60
function CreateMissionObjectiveMgr() {}
function BroadcastMissionObjMsg(string szLocMsg, string szPreMsg, string szMsgID, optional Sound sndGameStatus, optional int iLifeTime) {}
function UpdateRepMissionObjectivesStatus() {}
function UpdateRepMissionObjectives() {}
function ResetRepMissionObjectives() {}
function Find2DTexture(string TeamClass, out Material MenuTexture, out Region TextureRegion) {}
function SpawnAIandInitGoInGame() {}
function InitObjectives() {}
function RemoveObjectives() {}
function RemoveTerroFromList(Pawn toRemove) {}
function Actor GetNewTeam(optional bool bNextTeam, Actor aCurrentTeam) {}
// ^ NEW IN 1.60
function Object GetRainbowTeam(int eTeamName) {}
// ^ NEW IN 1.60
function bool IsLastRoundOfTheMatch() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetEndGamePauseTime
//	return the time needed when the game is over and we still
//  stay in game to see and heard the end of round result
//------------------------------------------------------------------
function float GetEndGamePauseTime() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetGameMsgLifeTime
//	return the life time of game msg
//------------------------------------------------------------------
function float GetGameMsgLifeTime() {}
// ^ NEW IN 1.60
function BaseEndGame() {}
function AbortMission() {}
function CompleteMission() {}
function TimerCountdown() {}
function ResetPlayerTeam(Controller aPlayer) {}
function RemoveController(Controller aPlayer) {}
//------------------------------------------------------------------
// SetDefaultTeamFriendlies: set the default value based on single
//	player mode.
//------------------------------------------------------------------
function SetDefaultTeamFriendlies(Pawn aPawn) {}
// this function will decide if KillerPawn should be a spectator in the next round
function SetTeamKillerPenalty(Pawn DeadPawn, Pawn KillerPawn) {}
function ApplyTeamKillerPenalty(Pawn aPawn) {}
 // if this function has not been defined then always return false
function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason) {}
// ^ NEW IN 1.60
function PostBeginPlay() {}
function PlayerReadySelected(PlayerController _Controller) {}
function IncrementRoundsFired(Pawn Instigator, bool ForceIncrement) {}
//------------------------------------------------------------------
// NotifyMatchStart: fired when the round start
//
//------------------------------------------------------------------
function NotifyMatchStart() {}
function bool ProcessPlayerReadyStatus() {}
// ^ NEW IN 1.60
function bool IsUnlimitedPractice() {}
// ^ NEW IN 1.60
exec function SetUnlimitedPractice(bool bUnlimitedPractice, optional bool bSendMsg) {}
function LogVoteInfo() {}
function string GetIntelVideoName(R6MissionDescription Desc) {}
// ^ NEW IN 1.60

defaultproperties
{
}
