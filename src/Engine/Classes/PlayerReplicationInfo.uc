//=============================================================================
// PlayerReplicationInfo.
//=============================================================================
class PlayerReplicationInfo extends ReplicationInfo
    native
    nativereplication;

// --- Constants ---
const m_cPlayTime; // value unavailable in binary
const m_cMission; // value unavailable in binary
const m_cRatioStat; // value unavailable in binary
const m_cDeathStat; // value unavailable in binary
const m_cKillStat =  0;

// --- Variables ---
// var ? HasFlag; // REMOVED IN 1.60
// var ? Team; // REMOVED IN 1.60
// Player name, or blank if none.
var /* replicated */ string PlayerName;
// Unique id number.
var /* replicated */ int PlayerID;
var /* replicated */ Volume PlayerLocation;
//#ifdef R6Code
// -- statistics -- //
// the player ready status
var /* replicated */ bool m_bPlayerReady;
var /* replicated */ bool bIsSpectator;
// Player position in team.
var /* replicated */ int TeamID;
var /* replicated */ int Ping;
var string OldName;
// ^ NEW IN 1.60
var /* replicated */ class<VoicePack> VoiceType;
//#endif
var /* replicated */ bool bIsFemale;
var /* replicated */ bool bWaitingPlayer;
var /* replicated */ bool bReadyToPlay;
// values that are kept between rounds
var /* replicated */ int m_iKillCount;
var /* replicated */ int m_iRoundFired;
var /* replicated */ int m_iRoundsHit;
var /* replicated */ int m_iRoundsPlayed;
var /* replicated */ int m_iRoundsWon;
// Number of player's deaths.
var /* replicated */ float Deaths;
// backup of stats in case of Admin Restart Round
var /* replicated */ int m_iBackUpKillCount;
var /* replicated */ int m_iBackUpRoundFired;
var /* replicated */ int m_iBackUpRoundsHit;
var /* replicated */ int m_iBackUpRoundsPlayed;
var /* replicated */ int m_iBackUpRoundsWon;
// Number of player's deaths.
var /* replicated */ float m_iBackUpDeaths;
// Player's current score.
var /* replicated */ float Score;
var int NumLives;
var /* replicated */ bool bOutOfLives;
// Time elapsed.
var /* replicated */ int StartTime;
// values that are reset
var /* replicated */ int m_iHealth;
// frag count
var /* replicated */ int m_iRoundKillCount;
var bool m_bHasTheFloppy;
// ^ NEW IN 1.60
var /* replicated */ bool m_bIsTheIntruder;
// ^ NEW IN 1.60
// server side info on player
var /* replicated */ bool m_bClientWillSubmitResult;
var travel int m_iUniqueID;
// Variables used for ubi.com game service
var travel bool m_bAlreadyLoggedIn;
// MPF1 // For Kamikaze Mode only (for MissionPack2)
var travel /* replicated */ bool m_bIsBombMan;
// For General Escort Mode only
// this is a temporary hack to tell the server that I should be the General
// If m_bIsGeneral is false for all players then the server should pick
// a general randomly
var travel /* replicated */ bool m_bIsEscortedPilot;
// name of the player that killed me
var /* replicated */ string m_szKillersName;
// used to signal when kill count has changed
var int m_iDeathCountForEvent;
var /* replicated */ bool m_bJoinedTeamLate;
// used to signal when kill count has changed
var int m_iKillCountForEvent;
var int TimeAcc;
var /* replicated */ Texture TalkTexture;
var /* replicated */ bool bBot;
var /* replicated */ bool bFeigningDeath;
//#ifdef R6CODE
// used to select which operative's face will be used
var /* replicated */ int iOperativeID;
var /* replicated */ string m_szUbiUserID;
// Temporary value.
var string PreviousName;

// --- Functions ---
simulated function DisplayDebug(Canvas Canvas, out float YPos, out float YL) {}
function SetWaitingPlayer(bool B) {}
function UpdatePlayerLocation() {}
function SetPlayerName(string S) {}
function Timer() {}
simulated function string GetHumanReadableName() {}
// ^ NEW IN 1.60
simulated function string GetLocationName() {}
// ^ NEW IN 1.60
function Reset() {}
simulated function ResetOriginalData() {}
//special rset for stats if an admin wants to reset the round
// thus reseting stats to what they were at the beginnning of last round.
function AdminResetRound() {}
simulated function SaveOriginalData() {}
//#ifdef R6CODE
function PostNetBeginPlay() {}
function PostBeginPlay() {}

defaultproperties
{
}
