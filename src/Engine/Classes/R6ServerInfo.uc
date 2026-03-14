// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6ServerInfo extends Object
    native
    config(server);

// --- Variables ---
var GameInfo m_GameInfo;
var config array<array> RestrictedSubMachineGuns;
var config array<array> RestrictedMiscGadgets;
var config array<array> RestrictedSecondary;
var config array<array> RestrictedPrimary;
var config array<array> RestrictedMachinePistols;
var config array<array> RestrictedPistols;
var config array<array> RestrictedSniperRifles;
var config array<array> RestrictedMachineGuns;
var config array<array> RestrictedAssultRifles;
var config array<array> RestrictedShotGuns;
var R6MapList m_ServerMapList;
var config string GamePassword;
var config bool UsePassword;
var config string ServerName;
var config bool CamFirstPerson;
var config bool CamThirdPerson;
var config bool CamFreeThirdP;
var config bool CamGhost;
var config bool CamFadeToBlack;
var config bool CamTeamOnly;
var config int MaxPlayers;
var config int NbTerro;
//3 or more "say" inside that period (seconds) trigger ChatLock
var config float SpamThreshold;
//Duration of ChatLock (seconds)
var config float ChatLockDuration;
//Delay (seconds) before sending a new vote broadcast
var config float VoteBroadcastMaxFrequency;
var config string MOTD;
var config int RoundTime;
var config int RoundsPerMatch;
var config int BetweenRoundTime;
var config bool UseAdminPassword;
var config string AdminPassword;
var config int BombTime;
var config int DiffLevel;
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

// --- Functions ---
// on reset we want to avoid reloading the original values
// we want to keep proper config values
function PostBeginPlay() {}
function ClearSettings() {}
event RestartServer() {}

defaultproperties
{
}
