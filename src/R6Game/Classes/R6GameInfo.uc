//=============================================================================
//  R6GameInfo.uc : This is class where all the Rainbow game rules will be defined.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/20 * Created by Rima Brek
//    2001/05/25 * Joel Tremblay added the heat textures initialisation
//    2001/07/31 * Chaouky Garram added the game mode and the TeamInfo
//============================================================================//
class R6GameInfo extends R6AbstractGameInfo
    native;

#exec OBJ LOAD FILE=..\Textures\Inventory_t.utx

// --- Constants ---
const CMaxRainbowAI =   6;
const CMaxPlayers =   16;
const CMaxCoOpPlayers =  8;
const K_InGamePauseTime =  5;

// --- Variables ---
var bool bShowLog;
// ^ NEW IN 1.60
var array<array> m_RainbowAIBackup;
//var FLOAT  m_fMapTimeLimit;     // Time limit per map (seconds)
// Camera Mode used when plyer dead
var int m_iDeathCameraMode;
// this is the time that the round will start at
var float m_fRoundStartTime;
var array<array> m_HostageVoicesFemaleMgr;
var array<array> m_HostageVoicesMaleMgr;
var array<array> m_TerroristVoicesMgr;
var array<array> m_listAllTerrorists;
var array<array> m_MultiCoopPlayerVoicesMgr;
var array<array> m_RainbowOtherTeamVoicesMgr;
// Manages servers from game service
var R6GSServers m_GameService;
var byte m_bCurrentMaleId;
var byte m_bCurrentFemaleId;
var bool m_bTKPenalty;
var int m_iJumpMapIndex;
// used in conjunction with the admin Map command
var bool m_bJumpingMaps;
// list of game modes used in multi player mode
var array<array> m_gameModeList;
// AI backup
var bool m_bAIBkp;
// in coop, rotate map automatically if it's true
var bool m_bRotateMap;
// List of maps in multi player mode
var array<array> m_mapList;
var R6MultiCommonVoices m_MultiCommonVoicesMgr;
var float m_fBombTime;
var R6PreRecordedMsgVoices m_PreRecordedMsgVoicesMgr;
var R6MultiCoopVoices m_MultiCoopMemberVoicesMgr;
// Server name passed as comand line argument
var string m_szSvrName;
var class<HUD> m_HudClass;
// ^ NEW IN 1.60
var R6CommonRainbowVoices m_CommonRainbowPlayerVoicesMgr;
var R6CommonRainbowVoices m_CommonRainbowMemberVoicesMgr;
var R6RainbowPlayerVoices m_RainbowPlayerVoicesMgr;
// replicated bool
var bool m_bServerAllowRadarRep;
var R6RainbowMemberVoices m_RainbowMemberVoicesMgr;
var bool m_bRepAllowRadarOption;
// These variables can be set in the menus, but the results are not yet
// integrated in the game.
// *** and there's some in r6AbstractGameInfo
var bool m_bAutoBalance;
var float m_fInGameStartTime;
// ^ NEW IN 1.60
var int m_iIDVoicesMgr;
// in single player before the DebriefingWidget stat the fade
var bool m_bFadeStarted;
var bool m_bStopPostBetweenRoundCountdown;
// ^ NEW IN 1.60
var R6GSServers m_PersistantGameService;
// last place any player started from
var NavigationPoint LastStartSpot;
var int m_iCurrentID;
// show the name of players (enemies or not)
var bool m_bShowNames;
// Force first person weapons
var bool m_bFFPWeapon;
// Administration password required
var bool m_bAdminPasswordReq;
var byte m_bRainbowFaces[30];
// in some game type, the radar can't be used (ie: deathmatch)
var bool m_bIsRadarAllowed;
// number of rounds in each match/map
var int m_iRoundsPerMatch;
var int m_iNbOfRestart;
// Variables used to hold information passed via the command line options string
// Message of the day passed as comand line argument
var string m_szMessageOfDay;
// in some game type, the writablemap can't be used (ie: deathmatch)
var bool m_bIsWritableMapAllowed;
// count down paused at time
var float m_fPausedAtTime;
var bool m_bFeedbackHostageKilled;
var bool m_bFeedbackHostageExtracted;
var Material DefaultFaceTexture;
var Plane DefaultFaceCoords;
var int m_iUbiComGameMode;
// ^ NEW IN 1.60
var float m_fRoundEndTime;
// a game mode can forces to unlock all doors
var bool m_bUnlockAllDoors;
//A game mode with this set to true allows saving through a player campaign
var bool m_bUsingPlayerCampaign;
var eGameWidgetID m_eEndGameWidgetID;
//#ifdef R6Cheat
//AK: this is a cheat
var bool bNoRestart;
var byte R6DefaultWeaponInput;
// max of operatives available for a mission in single player
var int m_iMaxOperatives;
//A game mode with this set to true allows having sweeney and clark briefing
var bool m_bUsingCampaignBriefing;
var int m_iSubMachineGunsResMask;
// Primary weapon: Shotguns restricted
var int m_iShotGunResMask;
// Primary weapon: Assault rifles restricted
var int m_iAssRifleResMask;
// Primary weapon: Machine Guns restricted
var int m_iMachGunResMask;
// Primary weapon: Sniper rifles restricted
var int m_iSnipRifleResMask;
// Secondary weapon: Pistols restricted
var int m_iPistolResMask;
// Secondary weapon: Machine pistols restricted
var int m_iMachPistolResMask;
// Gadget: primary weapon restricted
var int m_iGadgPrimaryResMask;
// Gadget: secondary restricted
var int m_iGadgSecondaryResMask;
// Gadget: misceleaneous restricted
var int m_iGadgMiscResMask;
// Primary weapon: Sub machine guns restricted
var bool m_bPWSubMachGunRes;
// Primary weapon: Shotguns restricted
var bool m_bPWShotGunRes;
// Primary weapon: Assault rifles restricted
var bool m_bPWAssRifleRes;
// Primary weapon: Machine Guns restricted
var bool m_bPWMachGunRes;
// Primary weapon: Sniper rifles restricted
var bool m_bPWSnipRifleRes;
// Secondary weapon: Pistols restricted
var bool m_bSWPistolRes;
// Secondary weapon: Machine pistols restricted
var bool m_bSWMachPistolRes;
// Gadget: primary weapon restricted
var bool m_bGadgPrimaryRes;
// Gadget: secondary restricted
var bool m_bGadgSecondayRes;
// Gadget: misceleaneous restricted
var bool m_bGadgMiscRes;

// --- Functions ---
// function ? AbortScoreSubmission(...); // REMOVED IN 1.60
// function ? SaveTrainingPlanning(...); // REMOVED IN 1.60
// function ? ToggleRestart(...); // REMOVED IN 1.60
//============================================================================
// PawnKilled -
//============================================================================
function PawnKilled(Pawn killed) {}
///////////////////////////////////////////////////////////////////////////////
// InitObjectives()
///////////////////////////////////////////////////////////////////////////////
function InitObjectives() {}
///////////////////////////////////////////////////////////////////////////////
// EndGame()
///////////////////////////////////////////////////////////////////////////////
function EndGame(string Reason, PlayerReplicationInfo Winner) {}
//------------------------------------------------------------------
// tick
//
//------------------------------------------------------------------
function Tick(float DeltaTime) {}
//============================================================================
// RestartPlayer -
//============================================================================
function RestartPlayer(Controller aPlayer) {}
function PlayerReadySelected(PlayerController _Controller) {}
//============================================================================
// InitGame -  Initialize the game.
// The GameInfo's InitGame() function is called before any other scripts (including
// PreBeginPlay() ), and is used by the GameInfo to initialize parameters and spawn
// its helper classes.
// Warning: this is called before actors' PreBeginPlay.
//  restriction kit is taken care of in PostBeginPlay
//============================================================================
event InitGame(string Options, out string Error) {}
//------------------------------------------------------------------
// ResetOriginalData
//
//------------------------------------------------------------------
simulated function ResetOriginalData() {}
event PlayerController Login(out string Error, string Options, string Portal) {}
// ^ NEW IN 1.60
//============================================================================
// DeployCharacters -
//============================================================================
function DeployCharacters(PlayerController ControlledByPlayer) {}
//------------------------------------------------------------------
// SetPawnTeamFriendlies
//
//------------------------------------------------------------------
function SetPawnTeamFriendlies(Pawn aPawn) {}
//============================================================================
// PostLogin -
//============================================================================
event PostLogin(PlayerController NewPlayer) {}
//------------------------------------------------------------------
// BroadcastGameTypeDescription
//
//------------------------------------------------------------------
function BroadcastGameTypeDescription() {}
//============================================================================
// PostBeginPlay -
//============================================================================
function PostBeginPlay() {}
function Logout(Controller Exiting) {}
//------------------------------------------------------------------
// ResetMatchStat
//	- used in adversarial
//------------------------------------------------------------------
function ResetMatchStat() {}
//------------------------------------------------------------------
// EnteredExtractionZone
//
//------------------------------------------------------------------
function EnteredExtractionZone(Actor Other) {}
//------------------------------------------------------------------
// R6SetPawnClassInMultiPlayer
//
//------------------------------------------------------------------
function R6SetPawnClassInMultiPlayer(Controller _playerController) {}
function GetNbHumanPlayerInTeam(out int iAlphaNb, out int iBravoNb) {}
//------------------------------------------------------------------
// IsPrimaryWeaponRestrictedToPawn
//
//------------------------------------------------------------------
function bool IsPrimaryWeaponRestrictedToPawn(Pawn aPawn) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// IsSecondaryWeaponRestrictedToPawn
//
//------------------------------------------------------------------
function bool IsSecondaryWeaponRestrictedToPawn(Pawn aPawn) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// IsTertiaryWeaponRestrictedToPawn
//
//------------------------------------------------------------------
function bool IsTertiaryWeaponRestrictedToPawn(Pawn aPawn) {}
// ^ NEW IN 1.60
//============================================================================
// Object GetTrainingMgr -
//============================================================================
function R6TrainingMgr GetTrainingMgr(R6Pawn P) {}
// ^ NEW IN 1.60
function LoadPlanningInTraining() {}
function SetGamePassword(string szPasswd) {}
//------------------------------------------------------------------
// SetJumpingMaps
//
//------------------------------------------------------------------
function SetJumpingMaps(int iNextMapIndex, bool _flagSetting) {}
function SetUdpBeacon(InternetInfo _udpBeacon) {}
//------------------------------------------------------------------
// GetTeamNumBit
//
//------------------------------------------------------------------
function int GetTeamNumBit(int Num) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// CheckEndGame
//
//------------------------------------------------------------------
function bool CheckEndGame(string Reason, PlayerReplicationInfo Winner) {}
// ^ NEW IN 1.60
function UpdateRepResArrays() {}
// AK: yes we are using this function. 01/Feb/2002
//function AcceptInventory(pawn PlayerPawn)
simulated event AcceptInventory(Pawn PlayerPawn) {}
final native function LogoutUpdatePlayersCtrlInfo(Controller Exiting) {}
// ^ NEW IN 1.60
//============================================================================
// DeployRainbowTeam
//  spawn a Rainbow Team in multiplayer
//============================================================================
function DeployRainbowTeam(PlayerController NewPlayer) {}
//============================================================================
// ChangeTeams -
//============================================================================
function ChangeTeams(optional Actor newRainbowTeam, PlayerController inPlayerController, optional bool bNextTeam) {}
//------------------------------------------------------------------
// CheckForHostage
//
//------------------------------------------------------------------
function CheckForHostage(int iMinNum, R6MissionObjectiveBase mo) {}
//============================================================================
// Object GetHostageVoicesMgr -
//============================================================================
function Object GetHostageVoicesMgr(EHostageNationality eNationality, bool IsFemale) {}
// ^ NEW IN 1.60
//============================================================================
// Actor GetNewTeam -
//============================================================================
function Actor GetNewTeam(Actor aCurrentTeam, optional bool bNextTeam) {}
// ^ NEW IN 1.60
//============================================================================
// R6GameInfoMakeNoise -
//============================================================================
function R6GameInfoMakeNoise(ESoundType eType, Actor soundsource) {}
//------------------------------------------------------------------
// CheckForTerrorist
//
//------------------------------------------------------------------
function CheckForTerrorist(int iMinNum, R6MissionObjectiveBase mo) {}
//------------------------------------------------------------------
// SetDefaultTeamFriendlies: set the default value based on single
//	player mode.
//------------------------------------------------------------------
function SetDefaultTeamFriendlies(Pawn aPawn) {}
//============================================================================
// float RatePlayerStart -
//============================================================================
function float RatePlayerStart(NavigationPoint NavPoint, byte Team, Controller Player) {}
// ^ NEW IN 1.60
//============================================================================
// InstructAllTeamsToHoldPosition -
//============================================================================
function InstructAllTeamsToHoldPosition() {}
//============================================================================
// InstructAllTeamsToFollowPlanning -
//============================================================================
function InstructAllTeamsToFollowPlanning() {}
//============================================================================
// RestartGame - At the end of a round or if we switch maps
//============================================================================
function RestartGame() {}
function Find2DTexture(out Region TextureRegion, out Material MenuTexture, string TeamClass) {}
//------------------------------------------------------------------
// RestartGameMgr
//	when we want to restart a game, we check if it's a restart game
//  or a reset level that is required
//------------------------------------------------------------------
function RestartGameMgr() {}
// Object GetCommonRainbowPlayerVoicesMgr -
//============================================================================
function Object GetMultiCoopPlayerVoicesMgr(int iTeam) {}
// ^ NEW IN 1.60
//============================================================================
// NavigationPoint R6FindPlayerStart -
//============================================================================
function NavigationPoint R6FindPlayerStart(optional int SpawnPointNumber, Controller Player, optional string incomingName) {}
// ^ NEW IN 1.60
//============================================================================
// CreateRainbowTeam -
//============================================================================
function CreateRainbowTeam(R6TeamStartInfo TeamInfo, int NewTeamNumber, int iTeamStart, bool bIsPlaying, PlayerController aRainbowPC) {}
function InitObjectivesOfStoryMode() {}
//============================================================================
// Object GetTerroristVoicesMgr -
//============================================================================
function Object GetTerroristVoicesMgr(ETerroristNationality eNationality) {}
// ^ NEW IN 1.60
//============================================================================
// BOOL SpawnNumberToNavPoint -
//============================================================================
function bool SpawnNumberToNavPoint(int _iSpawnNumber, out NavigationPoint _StartNavPoint) {}
// ^ NEW IN 1.60
// for multiplayer only, an arbitrary face is selected based on sex
function int MPSelectOperativeFace(bool bIsFemale) {}
// ^ NEW IN 1.60
//special rset for stats if an admin wants to reset the round
// thus reseting stats to what they were at the beginnning of last round.
function AdminResetRound() {}
function Object GetRainbowTeam(int eTeamName) {}
// ^ NEW IN 1.60
//============================================================================
// ChangeOperatives -
//============================================================================
function ChangeOperatives(int iOperativeID, PlayerController inPlayerController, int iTeamId) {}
function SetRainbowTeam(R6RainbowTeam newTeam, int eTeamName) {}
//------------------------------------------------------------------
// ResetPlayerBlur
//
//------------------------------------------------------------------
function ResetPlayerBlur() {}
final native function InitScoreSubmission(bool _bStatsSetting) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// SetPlayerInPenaltyBox
//
//------------------------------------------------------------------
function SetPlayerInPenaltyBox() {}
//============================================================================
// Object GetRainbowOtherTeamVoicesMgr -
//============================================================================
function Object GetRainbowOtherTeamVoicesMgr(int iIDVoicesMgr) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// SpawnAI
//
//------------------------------------------------------------------
function SpawnAI() {}
final native function GetSystemUserName(out string szUserName) {}
// ^ NEW IN 1.60
//============================================================================
// R6InsertionZone FindTeamInsertionZone -
//============================================================================
function R6InsertionZone FindTeamInsertionZone(int iSpawningPointNumber) {}
// ^ NEW IN 1.60
final native function NativeLogout(PlayerController Exiting) {}
// ^ NEW IN 1.60
//============================================================================
// NavigationPoint FindPlayerStart -
//============================================================================
function NavigationPoint FindPlayerStart(optional byte InTeam, Controller Player, optional string incomingName) {}
// ^ NEW IN 1.60
//============================================================================
// bool RainbowOperativesStillAlive -
//============================================================================
function bool RainbowOperativesStillAlive() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// UpdateRepMissionObjectives
//
//------------------------------------------------------------------
function UpdateRepMissionObjectives() {}
function int SearchOperativesArray(int iStartIndex, bool bIsFemale) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// SetGameTypeInLocal
//	set m_szGameTypeFlag in the GameRepInfo of the local player
//------------------------------------------------------------------
function SetGameTypeInLocal() {}
// this function will decide if KillerPawn should be a spectator in the next round
function SetTeamKillerPenalty(Pawn DeadPawn, Pawn KillerPawn) {}
function ResetBroadcastGameMsg() {}
//------------------------------------------------------------------
// BroadcastMissionObjMsg
//
//------------------------------------------------------------------
function BroadcastMissionObjMsg(optional int iLifeTime, optional Sound sndGameStatus, string szMsgID, string szPreMsg, string szLocFile) {}
final native function bool SetController(PlayerController PController, Player pPlayer) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// IsARainbowAlive (slower version!)
// - different from RainbowOperativesStillAlive
// - can't look the iMemberCount because of an order of execution problem
//------------------------------------------------------------------
function bool IsARainbowAlive() {}
// ^ NEW IN 1.60
function bool IsPrimaryWeaponRestricted(string szWeaponName) {}
// ^ NEW IN 1.60
// remove this player's AI Backup if there are any
function RemoveAIBackup(R6PlayerController _playerController) {}
//------------------------------------------------------------------
// BroadcastGameMsg
//
//------------------------------------------------------------------
function BroadcastGameMsg(optional int iLifeTime, optional Sound sndGameStatus, string szMsgID, string szPreMsg, string szLocFile) {}
// granades, frags, flashbangs, HB sensors etc
function bool IsTertiaryWeaponRestricted(string szWeaponName) {}
// ^ NEW IN 1.60
function bool IsInResArray(string RestrictionArray, string szWeaponNameId) {}
// ^ NEW IN 1.60
function bool IsUnlimitedPractice() {}
// ^ NEW IN 1.60
//============================================================================
// RemoveTerroFromList -
//============================================================================
function RemoveTerroFromList(Pawn toRemove) {}
function bool ProcessPlayerReadyStatus() {}
// ^ NEW IN 1.60
//============================================================================
// bool Stats_getPlayerInfo -
//============================================================================
function bool Stats_getPlayerInfo(PlayerReplicationInfo pInfo, R6Pawn pPawn, out string sz) {}
// ^ NEW IN 1.60
function DestroyBeacon() {}
function ChangeName(Controller Other, optional bool bDontBroadcastNameChange, bool bNameChange, coerce string S) {}
//------------------------------------------------------------------
// GetNbTerroNeutralized
//
//------------------------------------------------------------------
function int GetNbTerroNeutralized() {}
// ^ NEW IN 1.60
exec function SetUnlimitedPractice(bool bInGameProcess, bool bUnlimitedPractice) {}
simulated function FirstPassReset() {}
event PreLogOut(PlayerController ExitingPlayer) {}
function IncrementRoundsFired(Pawn Instigator, bool ForceIncrement) {}
function CreateBackupRainbowAI() {}
//------------------------------------------------------------------
// CheckForExtractionZone
//
//------------------------------------------------------------------
function CheckForExtractionZone(R6MissionObjectiveBase mo) {}
//============================================================================
// GetRainbowAIFromTable
//============================================================================
function Actor GetRainbowAIFromTable() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// ApplyTeamKillerPenalty
//	kill all pawn who's in the penalty box and check end game when
//  they are all dead
//------------------------------------------------------------------
function ApplyTeamKillerPenalty(Pawn aPawn) {}
//------------------------------------------------------------------
// ResetPenalty
//
//------------------------------------------------------------------
function ResetPenalty() {}
function bool IsPrimaryGadgetRestricted(string szWeaponGadgetName) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// SpawnAIandInitGoInGame
//
//------------------------------------------------------------------
function SpawnAIandInitGoInGame() {}
function R6AbstractInsertionZone GetAStartSpot() {}
// ^ NEW IN 1.60
function bool IsSecondaryWeaponRestricted(string szWeaponName) {}
// ^ NEW IN 1.60
function bool IsSecondaryGadgetRestricted(string szWeaponGadgetName) {}
// ^ NEW IN 1.60
event UpdateServer() {}
//------------------------------------------------------------------
// CanPlayOutroVideo
//
//------------------------------------------------------------------
event bool CanPlayOutroVideo() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// CanPlayIntroVideo
//
//------------------------------------------------------------------
event bool CanPlayIntroVideo() {}
// ^ NEW IN 1.60
function ResetRound() {}
final native function SubmissionSrvRoundStart() {}
// ^ NEW IN 1.60
final native function bool SubmissionNotifySendStartMatch() {}
// ^ NEW IN 1.60
final native function SubmissionSrvRoundFinish() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// ProcessChangeLevelSystem
//  Determine if we have exceeded the time for this map
//------------------------------------------------------------------
function ProcessChangeLevelSystem() {}
//------------------------------------------------------------------
// IsLastRoundOfTheMatch
//
//------------------------------------------------------------------
function bool IsLastRoundOfTheMatch() {}
// ^ NEW IN 1.60
final native function bool SubmissionUpdateLadderStat() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// BaseEndGame
//
//------------------------------------------------------------------
function BaseEndGame() {}
//------------------------------------------------------------------
// UpdateRepMissionObjectivesStatus
//
//------------------------------------------------------------------
function UpdateRepMissionObjectivesStatus() {}
//------------------------------------------------------------------
// ResetRepMissionObjectives
//
//------------------------------------------------------------------
function ResetRepMissionObjectives() {}
//============================================================================
// InitGameReplicationInfo -
//============================================================================
function InitGameReplicationInfo() {}
//============================================================================
// PlayTeleportEffect - Overided to remove MakeNoise of base class
//============================================================================
function PlayTeleportEffect(bool bSound, bool bOut) {}
//============================================================================
// R6AbstractNoiseMgr GetNoiseMgr -
//============================================================================
function R6AbstractNoiseMgr GetNoiseMgr() {}
// ^ NEW IN 1.60
//============================================================================
// Object GetRainbowMemberVoicesMgr -
//============================================================================
function Object GetRainbowMemberVoicesMgr() {}
// ^ NEW IN 1.60
//============================================================================
// Object GetRainbowPlayerVoicesMgr -
//============================================================================
function Object GetRainbowPlayerVoicesMgr() {}
// ^ NEW IN 1.60
//============================================================================
// Object GetCommonRainbowMemberVoicesMgr -
//============================================================================
function Object GetCommonRainbowMemberVoicesMgr() {}
// ^ NEW IN 1.60
//============================================================================
// Object GetCommonRainbowPlayerVoicesMgr -
//============================================================================
function Object GetCommonRainbowPlayerVoicesMgr() {}
// ^ NEW IN 1.60
// Object GetCommonRainbowPlayerVoicesMgr -
//============================================================================
function Object GetMultiCommonVoicesMgr() {}
// ^ NEW IN 1.60
// Object GetCommonRainbowPlayerVoicesMgr -
//============================================================================
function Object GetPreRecordedMsgVoicesMgr() {}
// ^ NEW IN 1.60
// Object GetCommonRainbowPlayerVoicesMgr -
//============================================================================
function Object GetMultiCoopMemberVoicesMgr() {}
// ^ NEW IN 1.60
// MPF1
///////////////Begin MissionPack1
///////////////////////////
function bool IsTertiaryWeaponRestrictedForGamePlay(Pawn aPawn, string szWeaponName) {}
// ^ NEW IN 1.60

defaultproperties
{
}
