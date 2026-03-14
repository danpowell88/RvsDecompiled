//=============================================================================
//  R6MultiPlayerGameInfo.uc : Native base class for all Rainbow Six multiplayer game modes; handles
//                             player login, team balancing, round timing, and voting systems.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/21 * Created by Aristomenis Kolokathis 
//                      Base GameInfo class for MP Games
//=============================================================================
class R6MultiPlayerGameInfo extends R6GameInfo
    native;

// --- Constants ---
const K_RefreshCheckPlayerReadyFreq =  1;
const K_VoteTime =  90;

// --- Variables ---
// var ? m_bDoLadderInit; // REMOVED IN 1.60
// var ? m_bMSCLientActive; // REMOVED IN 1.60
// var ? m_fInGameStartTime; // REMOVED IN 1.60
// var ? m_iUbiComGameMode; // REMOVED IN 1.60
// mission objective timer
var R6MObjTimer m_missionObjTimer;
// place holder for time of next CheckPlayerReady
var float m_fNextCheckPlayerReadyTime;
var bool m_TeamSelectionLocked;
var Sound m_sndSoundTimeFailure;
// Time of lat update sent to ubi.com
var float m_fLastUpdateTime;

// --- Functions ---
// function ? HandleKickVotesTick(...); // REMOVED IN 1.60
// function ? InitGame(...); // REMOVED IN 1.60
// function ? MasterServerManager(...); // REMOVED IN 1.60
// function ? PostBeginPlay(...); // REMOVED IN 1.60
//------------------------------------------------------------------
// InitObjectives
//
//------------------------------------------------------------------
function InitObjectives() {}
function EndGame(PlayerReplicationInfo Winner, string Reason) {}
function ResetPlayerTeam(Controller aPlayer) {}
//============================================================================
// PlayerController Login
//============================================================================
function int GetSpawnPointNum(string Options) {}
// ^ NEW IN 1.60
function int GetRainbowTeamColourIndex(int eTeamName) {}
// ^ NEW IN 1.60
event PlayerController Login(string Options, out string Error, string Portal) {}
// ^ NEW IN 1.60
function Tick(float Delta) {}
function bool CanAutoBalancePlayer(R6PlayerController pCtrl) {}
// ^ NEW IN 1.60
function HandleVotesTick() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// ProcessAutoBalanceTeam
//
//------------------------------------------------------------------
function ProcessAutoBalanceTeam() {}
event PostLogin(PlayerController NewPlayer) {}
function IncrementRoundsPlayed() {}
//------------------------------------------------------------------
// GetNbHumanPlayerInTeam
//
//------------------------------------------------------------------
function GetNbHumanPlayerInTeam(out int iAlphaNb, out int iBravoNb) {}
function ResetPlayerReady() {}
function bool ProcessChangeMapVote(string InstigatorName) {}
// ^ NEW IN 1.60
function bool ProcessKickVote(string InstigatorName, PlayerController _KickPlayer) {}
// ^ NEW IN 1.60
function Logout(Controller Exiting) {}
function SetCompilingStats(bool bStatsSetting) {}
function SetLockOnTeamSelection(bool _bLocked) {}
function LogVoteInfo() {}
function bool IsTeamSelectionLocked() {}
// ^ NEW IN 1.60
function bool IsBetweenRoundTimeOver() {}
// ^ NEW IN 1.60
function bool AtCapacity(bool bSpectator) {}
// ^ NEW IN 1.60

state InBetweenRoundMenu
{
    function EndState() {}
    function Tick(float DeltaTime) {}
    function UnPauseCountDown() {}
    function BeginState() {}
    function PauseCountDown() {}
    // Precondition: We are in the time between rounds stage
    // Postcondition: Returns true if we are no longer waiting because of unlimited time between round
    //                Returns true if we do not have time between round
    // Modifies: nothing
    // depends on begin state of InBetweenRoundMenu
    function bool UnlimitedTBRPassed() {}
// ^ NEW IN 1.60
}

state PostBetweenRoundTime
{
    function PostBetweenRoundTimeDone() {}
    function BeginState() {}
    function EndState() {}
    function Tick(float DeltaTime) {}
}

defaultproperties
{
}
