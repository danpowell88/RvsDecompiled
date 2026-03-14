//=============================================================================
// PlayerReplicationInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// PlayerReplicationInfo.
//=============================================================================
class PlayerReplicationInfo extends ReplicationInfo
	native
	nativereplication
	notplaceable
 hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

const m_cKillStat = 0;
const m_cDeathStat = 1;
const m_cRatioStat = 2;
const m_cMission = 3;
const m_cPlayTime = 4;

var int Ping;
var int NumLives;
var int PlayerID;  // Unique id number.
var int TeamID;  // Player position in team.
//#ifdef R6CODE
var int iOperativeID;  // used to select which operative's face will be used
// Time elapsed.
var int StartTime;
var int TimeAcc;
// values that are kept between rounds
var int m_iKillCount;
var int m_iKillCountForEvent;  // used to signal when kill count has changed
var int m_iRoundFired;
var int m_iRoundsHit;
var int m_iRoundsPlayed;
var int m_iRoundsWon;
var int m_iDeathCountForEvent;  // used to signal when kill count has changed
// backup of stats in case of Admin Restart Round
var int m_iBackUpKillCount;
var int m_iBackUpRoundFired;
var int m_iBackUpRoundsHit;
var int m_iBackUpRoundsPlayed;
var int m_iBackUpRoundsWon;
// values that are reset
var int m_iHealth;
var int m_iRoundKillCount;  // frag count
var travel int m_iUniqueID;
//#endif
var bool bIsFemale;
var bool bFeigningDeath;
var bool bIsSpectator;
var bool bWaitingPlayer;
var bool bReadyToPlay;
var bool bOutOfLives;
var bool bBot;
//#ifdef R6Code
// -- statistics -- //
var bool m_bPlayerReady;  // the player ready status
var bool m_bJoinedTeamLate;
// For General Escort Mode only
// this is a temporary hack to tell the server that I should be the General
// If m_bIsGeneral is false for all players then the server should pick
// a general randomly
var travel bool m_bIsEscortedPilot;
// MPF1 // For Kamikaze Mode only (for MissionPack2)
var travel bool m_bIsBombMan;
// Variables used for ubi.com game service
var travel bool m_bAlreadyLoggedIn;
var bool m_bClientWillSubmitResult;  // server side info on player
// NEW IN 1.60
var bool m_bIsTheIntruder;
// NEW IN 1.60
var bool m_bHasTheFloppy;
var float Score;  // Player's current score.
var float Deaths;  // Number of player's deaths.
var float m_iBackUpDeaths;  // Number of player's deaths.
var Volume PlayerLocation;
var Texture TalkTexture;
var Class<VoicePack> VoiceType;
var string PlayerName;  // Player name, or blank if none.
var string OldName;  // Temporary value.
// NEW IN 1.60
var string PreviousName;
var string m_szUbiUserID;
var string m_szKillersName;  // name of the player that killed me

replication
{
	// Pos:0x000
	reliable if(__NFUN_130__(bNetDirty, __NFUN_154__(int(Role), int(ROLE_Authority))))
		PlayerID, PlayerName, 
		TalkTexture, TeamID, 
		VoiceType, bFeigningDeath, 
		bIsFemale, bIsSpectator, 
		bOutOfLives, bReadyToPlay, 
		bWaitingPlayer, iOperativeID, 
		m_bIsBombMan, m_bIsEscortedPilot, 
		m_bPlayerReady, m_szKillersName, 
		m_szUbiUserID;

	// Pos:0x018
	reliable if(__NFUN_130__(bNetDirty, __NFUN_154__(int(Role), int(ROLE_Authority))))
		Ping, PlayerLocation, 
		Score, m_bJoinedTeamLate;

	// Pos:0x030
	reliable if(__NFUN_130__(bNetInitial, __NFUN_154__(int(Role), int(ROLE_Authority))))
		StartTime, bBot;

	// Pos:0x048
	reliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		m_bClientWillSubmitResult, m_bIsTheIntruder;

	// Pos:0x055
	reliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		Deaths, m_iBackUpDeaths, 
		m_iBackUpKillCount, m_iBackUpRoundFired, 
		m_iBackUpRoundsHit, m_iBackUpRoundsPlayed, 
		m_iBackUpRoundsWon, m_iHealth, 
		m_iKillCount, m_iRoundFired, 
		m_iRoundKillCount, m_iRoundsHit, 
		m_iRoundsPlayed, m_iRoundsWon;
}

function PostBeginPlay()
{
	StartTime = int(Level.TimeSeconds);
	Timer();
	__NFUN_280__(2.0000000, true);
	return;
}

//#ifdef R6CODE
function PostNetBeginPlay()
{
	super(Actor).PostNetBeginPlay();
	// End:0x35
	if(__NFUN_154__(int(Role), int(ROLE_Authority)))
	{
		PlayerID = __NFUN_165__(Level.Game.CurrentID);
	}
	return;
}

simulated function SaveOriginalData()
{
	// End:0x10
	if(m_bResetSystemLog)
	{
		LogResetSystem(true);
	}
	super(Actor).SaveOriginalData();
	return;
}

//special rset for stats if an admin wants to reset the round 
// thus reseting stats to what they were at the beginnning of last round.
function AdminResetRound()
{
	m_iKillCount = m_iBackUpKillCount;
	m_iRoundFired = m_iBackUpRoundFired;
	m_iRoundsHit = m_iBackUpRoundsHit;
	m_iRoundsPlayed = m_iBackUpRoundsPlayed;
	m_iRoundsWon = m_iBackUpRoundsWon;
	Deaths = m_iBackUpDeaths;
	return;
}

simulated function ResetOriginalData()
{
	// End:0x10
	if(m_bResetSystemLog)
	{
		LogResetSystem(false);
	}
	super(Actor).ResetOriginalData();
	m_iHealth = 0;
	m_iRoundKillCount = 0;
	m_iBackUpKillCount = m_iKillCount;
	m_iBackUpRoundFired = m_iRoundFired;
	m_iBackUpRoundsHit = m_iRoundsHit;
	m_iBackUpRoundsPlayed = m_iRoundsPlayed;
	m_iBackUpRoundsWon = m_iRoundsWon;
	m_iBackUpDeaths = Deaths;
	m_bPlayerReady = false;
	return;
}

function Reset()
{
	super(Actor).Reset();
	Score = 0.0000000;
	bReadyToPlay = false;
	NumLives = 0;
	bOutOfLives = false;
	m_bPlayerReady = false;
	return;
}

simulated function string GetLocationName()
{
	// End:0x1D
	if(__NFUN_119__(PlayerLocation, none))
	{
		return PlayerLocation.LocationName;		
	}
	else
	{
		return "";
	}
	return;
}

simulated function string GetHumanReadableName()
{
	return PlayerName;
	return;
}

function UpdatePlayerLocation()
{
	local Volume V;

	PlayerLocation = none;
	// End:0x7D
	foreach __NFUN_307__(Class'Engine.Volume', V)
	{
		// End:0x7C
		if(__NFUN_130__(__NFUN_130__(__NFUN_123__(V.LocationName, ""), __NFUN_132__(__NFUN_114__(PlayerLocation, none), __NFUN_151__(V.LocationPriority, PlayerLocation.LocationPriority))), V.Encompasses(self)))
		{
			PlayerLocation = V;
		}		
	}	
	return;
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	Canvas.__NFUN_465__(__NFUN_112__("     PlayerName ", PlayerName));
	return;
}

function Timer()
{
	UpdatePlayerLocation();
	// End:0x14
	if(__NFUN_176__(__NFUN_195__(), 0.6500000))
	{
		return;
	}
	return;
}

function SetPlayerName(string S)
{
	OldName = PlayerName;
	ReplaceText(S, " ", "_");
	ReplaceText(S, "~", "_");
	ReplaceText(S, "?", "_");
	ReplaceText(S, ",", "_");
	ReplaceText(S, "#", "_");
	ReplaceText(S, "/", "_");
	PlayerName = __NFUN_238__(S);
	return;
}

function SetWaitingPlayer(bool B)
{
	bIsSpectator = B;
	bWaitingPlayer = B;
	return;
}

defaultproperties
{
	iOperativeID=-1
	bIsSpectator=true
	RemoteRole=2
	bTravel=true
	NetUpdateFrequency=2.0000000
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var HasFlag
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var Team
