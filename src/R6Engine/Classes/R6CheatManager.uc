//=============================================================================
//  R6CheatManager.uc : Cheat manager for R6
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/24 * Created by Guillaume Borgia
//=============================================================================
class R6CheatManager extends CheatManager;

// --- Constants ---
const c_iNavPointIndex =  10;

// --- Structs ---
struct CommandInfo
{
    var name    m_functionName; // name used for quick string comparison
    var string  m_szDescription;
};

// --- Variables ---
// var ? m_functionName; // REMOVED IN 1.60
// var ? m_hostage; // REMOVED IN 1.60
// var ? m_szDescription; // REMOVED IN 1.60
var R6Hostage m_Hostage;         // Target hostage for cheat commands
// ^ NEW IN 1.60
var R6Pawn m_curPawn;
var CommandInfo m_aCommandInfo[128];
var bool m_bTeamGodMode;
var int m_iHostageTestAnimIndex;
var bool m_bHideAll;
var int m_iCounterLog;
var bool m_bRendFocus;
var bool m_bRendPawnState;
// navigation debug system
var bool m_bEnableNavDebug;
var int m_iCommandInfoIndex;
var bool m_bToggleHostageLog;
var bool m_bRenderViewDirection;
var bool m_bRenderGunDirection;
var bool m_bRenderBoneCorpse;
var bool m_bRenderFOV;
var bool m_bRenderRoute;
var bool m_bRenderNavPoint;
var bool m_bToggleTerroLog;
var bool m_bRendSpot;
var bool m_bToggleRainbowLog;
var bool m_bTogglePeek;
var bool m_bToggleMissionLog;
var bool m_bSkipTick;
var int m_iCurNavPoint;
var bool m_bToggleHostageThreat;
var bool m_bPlayerInvisble;
var bool m_bToggleThreatInfo;
var bool m_bToggleGameInfo;
var bool m_bFirstPersonPlayerView;
var int m_iGameInfoLevel;
var array<array> m_aNavPointLocation;
var bool m_bHostageTestAnim;
var int m_iCounterLogMax;
var float m_fNavPointDistance;
var bool m_bTogglePGDebug;
var bool m_bNumberLog;

// --- Functions ---
// function ? Arsenic(...); // REMOVED IN 1.60
// function ? CloseBP(...); // REMOVED IN 1.60
// function ? DeployBP(...); // REMOVED IN 1.60
// function ? DoAJump(...); // REMOVED IN 1.60
// function ? GetBombInfo(...); // REMOVED IN 1.60
// function ? GetPrePivot(...); // REMOVED IN 1.60
// function ? Gwigre(...); // REMOVED IN 1.60
// function ? HandDown(...); // REMOVED IN 1.60
// function ? HandUp(...); // REMOVED IN 1.60
// function ? HideWeapon(...); // REMOVED IN 1.60
// function ? SNDChangeVolume(...); // REMOVED IN 1.60
// function ? SNDMute(...); // REMOVED IN 1.60
// function ? SNDRecall(...); // REMOVED IN 1.60
// function ? SetBombInfo(...); // REMOVED IN 1.60
// function ? SetBombTimer(...); // REMOVED IN 1.60
// function ? SetPrePivot(...); // REMOVED IN 1.60
// function ? ShakeTime(...); // REMOVED IN 1.60
// function ? ShowWO(...); // REMOVED IN 1.60
// function ? ShowWeapon(...); // REMOVED IN 1.60
// function ? ToggleSoundLog(...); // REMOVED IN 1.60
// function ? WOX(...); // REMOVED IN 1.60
// function ? WOY(...); // REMOVED IN 1.60
// function ? WOZ(...); // REMOVED IN 1.60
// function ? dbgHisWeapon(...); // REMOVED IN 1.60
// function ? dbgHostage(...); // REMOVED IN 1.60
// function ? dbgWeapon(...); // REMOVED IN 1.60
// function ? deks(...); // REMOVED IN 1.60
// function ? pago(...); // REMOVED IN 1.60
// function ? r6ladder(...); // REMOVED IN 1.60
// function ? testBomb(...); // REMOVED IN 1.60
//------------------------------------------------------------------
// AddCommandInfo
//
//------------------------------------------------------------------
function AddCommandInfo(string szDescription, name functionName) {}
//============================================================================
// function AutoSelect - select a team by default in the gameoptions
//============================================================================
exec function AutoSelect(string _szSelection) {}
//------------------------------------------------------------------
// hostage Set Anim ( index )
//
//------------------------------------------------------------------
exec function HSA(int Index) {}
//------------------------------------------------------------------
// SetPState: set the pawn's state
//
//------------------------------------------------------------------
exec function SetPState(name stateToGo) {}
//------------------------------------------------------------------
// SetCState: set the controller's state
//------------------------------------------------------------------
exec function SetCState(name stateToGo) {}
//------------------------------------------------------------------
// Shake Parameters Cheats
//------------------------------------------------------------------
exec function DesignSF(float NewSpeedFactor) {}
exec function DesignJF(float NewJumpFactor) {}
exec function SetShake(bool bSet) {}
exec function DesignHBS(float fRange) {}
function hDebugLog(string sz) {}
//------------------------------------------------------------------
//
//------------------------------------------------------------------
exec function hHostage(int iPos) {}
exec function hGre(int iGrenade) {}
//------------------------------------------------------------------
// hWalkAnim
//------------------------------------------------------------------
exec function hWalkAnim(int i) {}
exec function sgi(int iLevel) {}
exec function ShowGameInfo(int iLevel) {}
exec function SetRoundTime(int iSec) {}
exec function SetBetTime(int iSec) {}
exec function shaketime(float fTime) {}
// ^ NEW IN 1.60
exec function MaxShake(float f) {}
exec function MaxShakeTime(float f) {}
exec function PlayDare(string SoundName) {}
///////////////////////////////////////////////////////////////////////////////////////
//  R6 Speed Debug functions - used to set the different movement speeds for the
//								player controller
///////////////////////////////////////////////////////////////////////////////////////
exec function r6walk(float speed) {}
exec function r6walkbackstrafe(float speed) {}
exec function r6run(float speed) {}
exec function r6runbackstrafe(float speed) {}
exec function r6cwalk(float speed) {}
exec function r6cwalkbackstrafe(float speed) {}
exec function r6crun(float speed) {}
exec function r6crunbackstrafe(float speed) {}
exec function r6prone(float speed) {}
exec function R6Ladder(float speed) {}
// ^ NEW IN 1.60
exec function LogBandWidth(bool bLogBandWidth) {}
exec function Armor(int armorType) {}
exec function ForceStunResult(int iStunResult) {}
exec function ForceKillResult(int iKillResult) {}
exec function logAct(int iNb, optional bool bNumber) {}
exec function listzone() {}
exec function DesignMaxRand(int NewMax) {}
//============================================================================
// function dbgTerro -
//============================================================================
exec function dbgTerro() {}
//============================================================================
// function dbgRainbow -
//============================================================================
exec function dbgRainbow() {}
function HostageSetAnimIndex(int increment) {}
function InitTestHostageAnim() {}
exec function DbgHostage() {}
// ^ NEW IN 1.60
exec function dbgEdit(optional bool bTraceWorld) {}
function name GetNameOfActor(Actor aActor) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// ToggleHostageThreat
//
//------------------------------------------------------------------
exec function ToggleHostageThreat() {}
//============================================================================
// function tAimedFire -
//============================================================================
exec function tAimedFire() {}
//============================================================================
// function tSprayFire -
//============================================================================
exec function tSprayFire() {}
//============================================================================
// function tSpeed
//============================================================================
exec function tSpeed(float fSpeed) {}
//============================================================================
// function tRunAway -
//============================================================================
exec function tRunAway() {}
//============================================================================
// function tSurrender -
//============================================================================
exec function tSurrender() {}
//============================================================================
// function tNoThreat -
//============================================================================
exec function tNoThreat() {}
// plant a bug
exec function DeactivateIODevice() {}
// disarms all the bombs on the level
exec function DisarmBombs() {}
exec function RouteAll(optional float fDistance) {}
//------------------------------------------------------------------
// ToggleUnlimitedPractice
//
//------------------------------------------------------------------
exec function ToggleUnlimitedPractice() {}
function DoPlayerInvisible(bool bInvisible) {}
//============================================================================
// function tTick -
//============================================================================
exec function tTick(int iTickFrequency) {}
//============================================================================
// function UseKarma -
//============================================================================
exec function UseKarma() {}
//------------------------------------------------------------------
// ToggleTerroLog
//
//------------------------------------------------------------------
exec function ToggleTerroLog() {}
//------------------------------------------------------------------
// logThis
//	do a dbgLogActor on the client and on the server side
//------------------------------------------------------------------
exec event LogThis(optional Actor anActor, optional bool bDontTraceActor) {}
//------------------------------------------------------------------
// SetPawn : set the current pawn
//------------------------------------------------------------------
exec function SetPawn() {}
//------------------------------------------------------------------
// MoveEscort
//------------------------------------------------------------------
exec function MoveEscort() {}
exec function DesignToggleLog() {}
exec function resetThreat() {}
function int GetActorsNb(optional bool bNoLog, class<Actor> ClassName) {}
// ^ NEW IN 1.60
exec function NetLogServer() {}
function DoGhost(Pawn aPawn) {}
exec function RainbowSkill(float fMul) {}
exec function TerroSkill(float fMul) {}
exec function FullAmmo() {}
exec function regroupHostages() {}
function ListActors(optional int iMax, optional int iFrom, optional bool bNumber, class<Actor> ClassName) {}
exec function TestGetFrame() {}
function processDebugPG(Canvas Canvas) {}
function processThreatInfo(Canvas Canvas) {}
//------------------------------------------------------------------
// processNavDebug: when enabled, it check if there's a nav point
//  accessible from the player location.
//------------------------------------------------------------------
function processNavDebug(Canvas C) {}
// RotateMe "R6 Spine" pitch yaw roll
exec function RotateMe(name BoneName, float InTime, int Roll, int Yaw, int Pitch) {}
exec function DesignArmor(int Heavy, int Medium, int Light) {}
//------------------------------------------------------------------
// ToggleRainbowLog
//
//------------------------------------------------------------------
exec function ToggleRainbowLog() {}
//------------------------------------------------------------------
// ToggleHostageLog
//
//------------------------------------------------------------------
exec function ToggleHostageLog() {}
//============================================================================
// function CallTerro -
//============================================================================
exec function CallTerro(optional int iGroup) {}
exec function GiveMag(int iNbOfExtraClips) {}
exec function DisableMorality() {}
exec function RescueHostage() {}
//------------------------------------------------------------------
// Hostage list anim
//
//------------------------------------------------------------------
exec function HLA() {}
//------------------------------------------------------------------
// UsePath
//------------------------------------------------------------------
exec function UsePath(int i) {}
exec function KillRagdoll() {}
exec function SetHRoll(int iRoll) {}
exec function ToggleObjectiveMgr() {}
//------------------------------------------------------------------
//
//------------------------------------------------------------------
exec function bool hInit() {}
// ^ NEW IN 1.60
// kills only all the terrorists and none of your team members
exec function NeutralizeTerro() {}
//============================================================================
// function KillThemAll -
//============================================================================
exec function KillThemAll() {}
function DoWalk(Pawn aPawn) {}
exec function LogFriendlyFire() {}
exec function KOValue(float fValue, int iWhich) {}
exec function DazedValue(float fValue, int iWhich) {}
exec function StunValue(float fValue, int iWhich) {}
exec function HitValue(float fValue, int iWhich) {}
//============================================================================
// LogRainbow -
//============================================================================
function LogRainbow(R6Rainbow rb) {}
//------------------------------------------------------------------
//
//------------------------------------------------------------------
exec function hReact(int iReact) {}
//============================================================================
// function ActorTick -
//============================================================================
exec function ActorTick(int iTickFrequency) {}
function LogIOBomb(R6IOBomb bomb) {}
exec function string SetPawnPace(optional bool bHelp, int i) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// SetHPos: set hostage position
//------------------------------------------------------------------
exec function SetHPos(int iPos) {}
//------------------------------------------------------------------
//
//------------------------------------------------------------------
exec function hPos(int iPos) {}
function KillRainbowTeam() {}
//------------------------------------------------------------------
// hostage Play Anim
//
//------------------------------------------------------------------
exec function HP(optional bool bLoop) {}
//------------------------------------------------------------------
// dbg the pointed actor
//
//------------------------------------------------------------------
exec function dbgThis(optional bool bTraceWorld) {}
exec function ListEscort() {}
//============================================================================
// function dbgActor -
//============================================================================
exec function dbgActor() {}
//============================================================================
// function DrawRoute -
//============================================================================
simulated function DrawRoute(R6AIController r6con, Canvas Canvas) {}
function Actor GetPointedActor(out optional Vector vReturnHit, bool bTraceActor, bool bVerboseLog, optional bool bForceTrace) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// CheckFrienship: check all problems related to friendship rules
//
//------------------------------------------------------------------
exec function CheckFrienship() {}
//------------------------------------------------------------------
// help: list all registered function
//------------------------------------------------------------------
exec function help() {}
exec function ShowFOV() {}
//------------------------------------------------------------------
// displayMissionObjective
//
//------------------------------------------------------------------
function displayMissionObjective(R6MissionObjectiveBase mo, Canvas C, out int iLine, out int YPos, out int iSubGroup, int iVerbose, int YL, int XPos) {}
//------------------------------------------------------------------
// LogFriendship: list all frienship relation with all pawns
//
//------------------------------------------------------------------
exec function LogFriendship(optional bool bCheckIfAlive) {}
function displayGameInfo(Canvas C) {}
//============================================================================
// PostRender -
//============================================================================
event PostRender(Canvas Canvas) {}
//============================================================================
// LogTerro -
//============================================================================
function LogTerro(R6Terrorist t) {}
function LogHostage(R6Hostage H) {}
function processDebugPeek(Canvas Canvas) {}
function LogR6Pawn(R6Pawn P) {}
//============================================================================
// On off function begin --
exec function PhyStat() {}
exec function ToggleRadius() {}
exec function BoneCorpse() {}
exec function GunDirection() {}
exec function ViewDirection() {}
exec function Route() {}
exec function NavPoint() {}
exec function God() {}
exec function GodTeam() {}
exec function GodTerro() {}
exec function GodHostage() {}
exec function GodAll() {}
exec function PerfectAim() {}
function DoCompleteMission() {}
function DoAbortMission() {}
exec function KillTerro() {}
exec function KillHostage() {}
exec function KillRainbow() {}
exec function KillPawns() {}
exec function PlayerInvisible() {}
exec function HideAll() {}
exec function ToggleReticule() {}
//============================================================================
// function ToggleHitLog -
//============================================================================
exec function ToggleHitLog() {}
exec function ToggleWalk() {}
//============================================================================
// function RendSpot -
//============================================================================
exec function RendSpot() {}
exec function TerroInfo() {}
//------------------------------------------------------------------
// hostage Next Anim
//
//------------------------------------------------------------------
exec function HNA() {}
//------------------------------------------------------------------
// hostage Previous Anim
//
//------------------------------------------------------------------
exec function HPA() {}
exec function SeeCurPawn() {}
//------------------------------------------------------------------
// CanWalk
//------------------------------------------------------------------
exec function CanWalk() {}
//------------------------------------------------------------------
// TestFindPathToMe
//------------------------------------------------------------------
exec function TestFindPathToMe() {}
//------------------------------------------------------------------
// Hostage / Civilian debugger
//
//------------------------------------------------------------------
exec function hHelp() {}
//------------------------------------------------------------------
//
//------------------------------------------------------------------
exec function hReset() {}
//------------------------------------------------------------------
//
//------------------------------------------------------------------
exec function hLog() {}
//------------------------------------------------------------------
//
//------------------------------------------------------------------
exec function hCiv() {}
//------------------------------------------------------------------
// hFreeze:
//------------------------------------------------------------------
exec function hFreeze() {}
//------------------------------------------------------------------
// hHurt
//------------------------------------------------------------------
exec function hHurt() {}
exec function ResetMeAll() {}
//------------------------------------------------------------------
// toggleNav
//
//------------------------------------------------------------------
exec function toggleNav() {}
exec function dbgPeek() {}
exec function toggleThreatInfo() {}
exec function RendPawnState() {}
exec function RendFocus() {}
exec function ToggleCollision() {}
exec function ToggleMissionLog() {}
exec function GetNbTerro() {}
exec function GetNbHostage() {}
exec function GetNbRainbow() {}
exec function logActReset() {}
exec function DbgPlayerStates() {}
exec function CallDebug() {}
exec function ResetRainbow() {}
exec function GetNetMode() {}
//------------------------------------------------------
// Begin R6Debug functions
//------------------------------------------------------
exec function UpdateBones() {}
///////////////////////////////////////////////////////////////////////////////////////
//  R6FixCamera()
//    rbrek - 5 oct 2001
//    Debug function, only has an effect when behindView = true, camera will not move...
///////////////////////////////////////////////////////////////////////////////////////
exec function R6FixCamera() {}
///////////////////////////////////////////////////////////////////////////////////////
//  R6FreeCamera()
//    rbrek - 5 oct 2001
//    Debug function, only has an effect when behindView = true, camera will not move...
///////////////////////////////////////////////////////////////////////////////////////
exec function R6FreeCamera() {}
exec function LogActors() {}
exec function Azimut() {}
exec function Ghost() {}
exec function CompleteMission() {}
exec function AbortMission() {}
exec function Walk() {}
exec function Alkoliq() {}
exec function ShowSkill(float fMul) {}
exec function Thor() {}

defaultproperties
{
}
