//=============================================================================
//  R6Hostage.uc : This is the pawn class for all hostages
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/11 * Created by Rima Brek
//=============================================================================
class R6Hostage extends R6Pawn
    native
    notplaceable
    abstract;

// --- Enums ---
enum EStartingPosition
{
    POS_Stand,
    POS_Kneel,
    POS_Prone,
    POS_Foetus,
    POS_Crouch,
    POS_Random
};
enum EStandWalkingAnim
{
    eStandWalkingAnim_default,
    eStandWalkingAnim_scared,
};
enum eHostageOrder
{
    // enum values not recoverable from binary — see 1.56 source
};
enum EHandsUpType
{
    HANDSUP_none,
    HANDSUP_kneeling,
    HANDSUP_standing
};
enum ECivPatrolType
{
    CIVPATROL_None,
    CIVPATROL_Path,
    CIVPATROL_Area,
    CIVPATROL_Point
};

// --- Structs ---
struct STRepHostageAnim
{
    var EStandWalkingAnim m_eRepStandWalkingAnim;
    var bool m_bRepPlayMoving;
};

// --- Variables ---
// var ? m_bRepPlayMoving; // REMOVED IN 1.60
// var ? m_eRepStandWalkingAnim; // REMOVED IN 1.60
// quick reference
var R6HostageMgr m_mgr;
var /* replicated */ R6Rainbow m_escortedByRainbow;
// quick reference
var R6HostageAI m_controller;
// when in CivPatrolPath
var R6DZonePathNode m_currentNode;
// true when civilian (faster than isInState('Civilian')
var bool m_bCivilian;
// used to know if we have to play anim transition when hands are up/down
var /* replicated */ EHandsUpType m_eHandsUpType;
// MPF1
// policeMan for MissionPack1 (ignores SeePlayer, HearNoise and QueryAction=0)
var bool m_bPoliceManMp1;
// kneel or standing
var /* replicated */ EStartingPosition m_ePosition;
// true when not guarded
var /* replicated */ bool m_bFreed;
// true when enter an extration zone
var /* replicated */ bool m_bExtracted;
var bool m_bClassicMissionCivilian;  // Treat this hostage as a background civilian in classic mission mode
// ^ NEW IN 1.60
var EHostagePersonality m_ePersonality;
// deployment zone
var R6DeploymentZone m_DZone;
var /* replicated */ STRepHostageAnim m_eCurrentRepHostageAnim;
// frozen for kneeling/standing anim
var /* replicated */ bool m_bFrozen;
// in escorte mode
var /* replicated */ bool m_bEscorted;
var RandomTweenNum m_changeOrientationTween;  // Random timer controlling how often the hostage changes facing direction
// ^ NEW IN 1.60
// true when playing a reaction anim
var bool m_bReactionAnim;
// when in CivPatrolPath
var bool m_bPatrolForward;
var /* replicated */ bool m_bIsKneeling;
var /* replicated */ bool m_bIsFoetus;
var /* replicated */ byte m_bRepWaitAnimIndex;
var RandomTweenNum m_sightRadiusTween;  // Random variation applied to the hostage's sight detection radius
// ^ NEW IN 1.60
var RandomTweenNum m_updatePaceTween;   // Random timer for how often the hostage re-evaluates movement pace
// ^ NEW IN 1.60
// Used in the TerroristMgr to rapidely find an hostage already in the array
var int m_iIndex;
// true when play this anim
var bool m_bCrouchToScaredStandBegin;
var STRepHostageAnim m_eSavedRepHostageAnim;
var RandomTweenNum m_stayCautiousGuardedStateTime;  // How long hostage stays in the cautious/guarded state
// ^ NEW IN 1.60
var RandomTweenNum m_patrolAreaWaitTween;  // Random wait time between patrol area traversals
// ^ NEW IN 1.60
var RandomTweenNum m_waitingGoCrouchTween;  // Random delay before hostage crouches while waiting
// ^ NEW IN 1.60
// start has a civilian
var bool m_bStartAsCivilian;
//MissionPack1
var name m_NocsWaitingName;
// used to check if we are in the GotoState('')
var name m_globalState;
var byte m_bSavedRepWaitAnimIndex;
var RandomTweenNum m_stayInFoetusTime;  // How long hostage stays curled up in the foetal/cowering position
// ^ NEW IN 1.60
var RandomTweenNum m_stayFrozenTime;    // How long hostage stays frozen with fear after being startled
// ^ NEW IN 1.60
// initialized by the template
var string m_szUsedTemplate;
// true when the initializing process of dzone is over
var bool m_bInitFinished;
// type of patrol in the depZone
var ECivPatrolType m_eCivPatrol;
var bool m_bPoliceManHasWeapon;
var bool m_bPoliceManCanSeeRainbows;
//MissionPack1
var name m_NocsSeeRainbowsName;
var int m_iPrisonierTeam;          // Team ID for this hostage when used as a CTE prisoner
// ^ NEW IN 1.60
// true when we process the feedback
var bool m_bFeedbackExtracted;
var RandomTweenNum m_stayProneTime;     // How long the hostage remains prone after being told to get down
// ^ NEW IN 1.60

// --- Functions ---
    //////////////////////////////////////////////
simulated event GotoStand() {}
///////////////////////////////////////////////
simulated event GotoCrouch() {}
    //////////////////////////////////////////////
simulated event GotoKneel() {}
    //////////////////////////////////////////////
simulated event GotoFoetus() {}
    //////////////////////////////////////////////
simulated event GotoProne() {}
//------------------------------------------------------------------
// Initialize the default value
//------------------------------------------------------------------
simulated event PostBeginPlay() {}
    /////////////////////////////////////////////////////////////////////////
function PlayReaction() {}
/////////////////////////////////////////////
function GotoFrozen() {}
//------------------------------------------------------------------
// CanBeAffectedByGrenade: return true if can be affected by the grenade
//   at this moment
//------------------------------------------------------------------
simulated function bool CanBeAffectedByGrenade(EGrenadeType eType, Actor aGrenade) {}
// ^ NEW IN 1.60
simulated function PlayDoorAnim(R6IORotatingDoor Door) {}
//------------------------------------------------------------------
// ProcessBuildDeathMessage
//
//------------------------------------------------------------------
function bool ProcessBuildDeathMessage(Pawn Killer, out string szPlayerName) {}
// ^ NEW IN 1.60
simulated function SetStandWalkingAnim(EStandWalkingAnim eAnim, bool bUpdatePlayMoving) {}
//------------------------------------------------------------------
// R6TakeDamage: when wounded, will sets the HurtAnim
//	- inherited
//------------------------------------------------------------------
function int R6TakeDamage(int iKillValue, int iStunValue, Pawn instigatedBy, Vector vHitLocation, optional int iBulletGoup, int iBulletToArmorModifier, Vector vMomentum) {}
// ^ NEW IN 1.60
simulated event PlaySpecialPendingAction(EPendingAction eAction, int iActionInt) {}
//------------------------------------------------------------------
// GetReticuleInfo
//
//------------------------------------------------------------------
simulated event bool GetReticuleInfo(Pawn ownerReticule, out string szName) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// AnimEnd
//	inherited to detect a modification m_bPostureTransition
//------------------------------------------------------------------
simulated event AnimEnd(int iChannel) {}
simulated function PlayBlinded() {}
simulated function PlayCoughing() {}
//------------------------------------------------------------------
// HasBumpPriority
//
//------------------------------------------------------------------
function bool HasBumpPriority(R6Pawn bumpedBy) {}
// ^ NEW IN 1.60
simulated function Tick(float fDeltaTime) {}
//------------------------------------------------------------------
// SetAnimTransition: set the transition anim to play and to the next pawn
// 	state to go when the transition is over.
// - First it looks if the transition exist in the Manager. This
//   can be used we want to customize the anim transition.
// - If not in the mgr, it check if it's anim of type transition.
//   If so, it will blend the current anim with the transition one.
// - If option 1 and 2 failed, it will set the anim and set the new pawn state
//------------------------------------------------------------------
simulated function SetAnimTransition(int iAnimToPlay, name pawnStateToGo) {}
//------------------------------------------------------------------
// may freeze when the hostage see a new terrorist or rainbow
//------------------------------------------------------------------
function setFrozen(bool bFreeze) {}
//------------------------------------------------------------------
// setCrouch
//------------------------------------------------------------------
function setCrouch(bool bIsCrouch) {}
//------------------------------------------------------------------
// setProne
//------------------------------------------------------------------
function setProne(bool bIsProne) {}
simulated function string R6GetCircumstantialActionString(int iAction) {}
// ^ NEW IN 1.60
//============================================================================
// vector EyePosition -
//============================================================================
event Vector EyePosition() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// PlayWaiting: play waiting animation randomly
//  - inherited
//------------------------------------------------------------------
simulated function PlayWaiting() {}
//------------------------------------------------------------------
// SetAnimInfo: set the current anim to play based on his
//	properties.
//------------------------------------------------------------------
simulated event SetAnimInfo(int ID) {}
event R6QueryCircumstantialAction(out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController, float fDistance) {}
 // MPF1
///////////////////////////////
/////MissionPack1
//============================================================================
// SetToNormalWeapon -
//============================================================================
function SetToNormalWeapon() {}
//------------------------------------------------------------------
// EnteredExtractionZone
//
//------------------------------------------------------------------
function EnteredExtractionZone(R6AbstractExtractionZone Zone) {}
//------------------------------------------------------------------
// PlayProneToCrouch
//	- inherited
//------------------------------------------------------------------
simulated function PlayProneToCrouch(optional bool bForcedByClient) {}
//------------------------------------------------------------------
// PlayCrouchToProne
//	- inherited
//------------------------------------------------------------------
simulated function PlayCrouchToProne(optional bool bForcedByClient) {}
//------------------------------------------------------------------
// PlayDuck
//	- inherited
//------------------------------------------------------------------
function PlayDuck() {}
//------------------------------------------------------------------
// AnimNotify_CrouchToScaredStandBegin
//
//------------------------------------------------------------------
function AnimNotify_CrouchToScaredStandBegin() {}
//------------------------------------------------------------------
// AnimNotify_CrouchToScaredStandEnd
//
//------------------------------------------------------------------
function AnimNotify_CrouchToScaredStandEnd() {}
function ResetWeaponAnimation() {}
//------------------------------------------------------------------
// PlayWeaponAnimation
//	- inherited to avoid Access None and Wrong
//------------------------------------------------------------------
function PlayWeaponAnimation() {}
//=============================================================================
// isKneeling: return true if hostage is kneeling
//=============================================================================
function bool isKneeling() {}
// ^ NEW IN 1.60
//=============================================================================
// isFoetus: return true if hostage is in foetus position
//=============================================================================
function bool isFoetus() {}
// ^ NEW IN 1.60
//=============================================================================
// isStandingHandUp: return true if hostage is standing with hands up
//=============================================================================
function bool isStandingHandUp() {}
// ^ NEW IN 1.60
//=============================================================================
// isStanding: return true if hostage is standing
//=============================================================================
function bool isStanding() {}
// ^ NEW IN 1.60
simulated event PostNetBeginPlay() {}
//------------------------------------------------------------------
// logAnim: special log for anim
//------------------------------------------------------------------
function logAnim(string sz) {}
//============================================================================
// FinishInitialization -
//============================================================================
event FinishInitialization() {}

state Kneeling
{
    /////////////////////////////////////////////////////////////////////////
    simulated function PlayReaction() {}
///////////////////////////////////////////////
    simulated event GotoCrouch() {}
    //////////////////////////////////////////////
    simulated event GotoProne() {}
    //////////////////////////////////////////////
    simulated event GotoFoetus() {}
    //////////////////////////////////////////////
    simulated event GotoKneel() {}
    //////////////////////////////////////////////
    simulated event GotoStand() {}
/////////////////////////////////////////////
    simulated function GotoFrozen() {}
    simulated function EndState() {}
    /////////////////////////////////////////////////////////////////////////
    simulated function BeginState() {}
}

state Foetus
{
    simulated function EndState() {}
    /////////////////////////////////////////////////////////////////////////
    simulated function BeginState() {}
    //////////////////////////////////////////////
    simulated event GotoProne() {}
///////////////////////////////////////////////
    simulated event GotoCrouch() {}
    //////////////////////////////////////////////
    simulated event GotoFoetus() {}
    //////////////////////////////////////////////
    simulated event GotoKneel() {}
    //////////////////////////////////////////////
    simulated event GotoStand() {}
}

state Prone
{
///////////////////////////////////////////////
    simulated event GotoCrouch() {}
    //////////////////////////////////////////////
    simulated event GotoProne() {}
    //////////////////////////////////////////////
    simulated event GotoFoetus() {}
    //////////////////////////////////////////////
    simulated event GotoKneel() {}
    //////////////////////////////////////////////
    simulated event GotoStand() {}
    /////////////////////////////////////////////////////////////////////////
    simulated function BeginState() {}
}

state Crouching
{
    //////////////////////////////////////////////
    simulated event GotoKneel() {}
    //////////////////////////////////////////////
    simulated event GotoProne() {}
    //////////////////////////////////////////////
    simulated event GotoStand() {}
    //////////////////////////////////////////////
    simulated event GotoFoetus() {}
///////////////////////////////////////////////
    simulated event GotoCrouch() {}
    /////////////////////////////////////////////////////////////////////////
    simulated function BeginState() {}
}

defaultproperties
{
}
