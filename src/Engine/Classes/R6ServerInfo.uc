//=============================================================================
// R6ServerInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6ServerInfo extends Object
    native
    config(server);

var config int MaxPlayers;
var config int NbTerro;
var config int RoundTime;
var config int RoundsPerMatch;
var config int BetweenRoundTime;
var config int BombTime;
var config int DiffLevel;
var config bool CamFirstPerson;
var config bool CamThirdPerson;
var config bool CamFreeThirdP;
var config bool CamGhost;
var config bool CamFadeToBlack;
var config bool CamTeamOnly;
var config bool UsePassword;
var config bool UseAdminPassword;
var config bool ShowNames;
var config bool InternetServer;
var config bool DedicatedServer;
var config bool FriendlyFire;
var config bool Autobalance;
var config bool TeamKillerPenalty;
var config bool AllowRadar;
var config bool ForceFPersonWeapon;
var config bool AIBkp;
var config bool RotateMap;
var config float SpamThreshold;  // 3 or more "say" inside that period (seconds) trigger ChatLock
var config float ChatLockDuration;  // Duration of ChatLock (seconds)
var config float VoteBroadcastMaxFrequency;  // Delay (seconds) before sending a new vote broadcast
var R6MapList m_ServerMapList;
var GameInfo m_GameInfo;
var config array< Class > RestrictedSubMachineGuns;
var config array< Class > RestrictedShotGuns;
var config array< Class > RestrictedAssultRifles;
var config array< Class > RestrictedMachineGuns;
var config array< Class > RestrictedSniperRifles;
var config array< Class > RestrictedPistols;
var config array< Class > RestrictedMachinePistols;
var config array<string> RestrictedPrimary;
var config array<string> RestrictedSecondary;
var config array<string> RestrictedMiscGadgets;
var config string ServerName;
var config string GamePassword;
var config string MOTD;
var config string AdminPassword;

// on reset we want to avoid reloading the original values
// we want to keep proper config values
function PostBeginPlay()
{
	return;
}

function ClearSettings()
{
	RestrictedSubMachineGuns.Remove(0, RestrictedSubMachineGuns.Length);
	RestrictedSubMachineGuns.Remove(0, RestrictedSubMachineGuns.Length);
	RestrictedShotGuns.Remove(0, RestrictedShotGuns.Length);
	RestrictedAssultRifles.Remove(0, RestrictedAssultRifles.Length);
	RestrictedMachineGuns.Remove(0, RestrictedMachineGuns.Length);
	RestrictedSniperRifles.Remove(0, RestrictedSniperRifles.Length);
	RestrictedPistols.Remove(0, RestrictedPistols.Length);
	RestrictedMachinePistols.Remove(0, RestrictedMachinePistols.Length);
	RestrictedPrimary.Remove(0, RestrictedPrimary.Length);
	RestrictedSecondary.Remove(0, RestrictedSecondary.Length);
	RestrictedMiscGadgets.Remove(0, RestrictedMiscGadgets.Length);
	return;
}

event RestartServer()
{
	// End:0x59
	if(__NFUN_119__(m_GameInfo, none))
	{
		m_GameInfo.__NFUN_1210__();
		m_GameInfo.bChangeLevels = true;
		m_GameInfo.m_bChangedServerConfig = true;
		m_GameInfo.SetJumpingMaps(true, 0);
		m_GameInfo.RestartGameMgr();
	}
	return;
}

defaultproperties
{
	MaxPlayers=16
	RoundTime=240
	RoundsPerMatch=10
	BetweenRoundTime=45
	BombTime=45
	DiffLevel=2
	CamFirstPerson=true
	CamThirdPerson=true
	CamFreeThirdP=true
	CamGhost=true
	CamTeamOnly=true
	ShowNames=true
	InternetServer=true
	DedicatedServer=true
	FriendlyFire=true
	Autobalance=true
	TeamKillerPenalty=true
	AllowRadar=true
	ForceFPersonWeapon=true
	SpamThreshold=5.0000000
	ChatLockDuration=15.0000000
	VoteBroadcastMaxFrequency=15.0000000
	ServerName="Raven Shield ADVER"
}
