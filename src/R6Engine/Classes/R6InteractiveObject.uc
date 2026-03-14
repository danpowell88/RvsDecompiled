//=============================================================================
//  R6InteractiveObject.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/15 * Creation - Jean-Francois Dube
//=============================================================================
class R6InteractiveObject extends Actor
    native;

// --- Constants ---
const c_iIObjectSkinMax =  4;

// --- Enums ---
enum EInteractiveAction
{
    IA_PlayAnim,
    IA_LookAt
};

// --- Structs ---
struct stDamageState
{
    var () FLOAT fDamagePercentage;
    var () array<stRandomMesh> RandomMeshes;
    var () array<stRandomSkin> RandomSkins;
    var () array<stSpawnedActor> ActorList;
    var () array<Sound> SoundList;
    var () Sound NewAmbientSound;
    var () Sound NewAmbientSoundStop;
};

struct stRandomSkin
{
    var () FLOAT fPercentage;
    var () array<Material> Skin;
};

struct stRandomMesh
{
    var () FLOAT fPercentage;
    var () StaticMesh Mesh;
};

struct stSpawnedActor
{
    var () class<Actor> ActorToSpawn;
    var () string HelperName;
};

// --- Variables ---
// var ? ActorList; // REMOVED IN 1.60
// var ? ActorToSpawn; // REMOVED IN 1.60
// var ? HelperName; // REMOVED IN 1.60
// var ? Mesh; // REMOVED IN 1.60
// var ? NewAmbientSound; // REMOVED IN 1.60
// var ? NewAmbientSoundStop; // REMOVED IN 1.60
// var ? RandomMeshes; // REMOVED IN 1.60
// var ? RandomSkins; // REMOVED IN 1.60
// var ? Skin; // REMOVED IN 1.60
// var ? SoundList; // REMOVED IN 1.60
// var ? fDamagePercentage; // REMOVED IN 1.60
// var ? fPercentage; // REMOVED IN 1.60
var R6AIController m_InteractionOwner;
var R6InteractiveObjectAction m_CurrentInteractiveObject;
// Current Hit Points
var int m_iCurrentHitPoints;
var bool m_bBroken;
var array<array> m_StateList;
var float m_fPlayerCAStartTime;
var Actor m_HearNoiseNoiseMaker;
// SeePlayer buffering
var Pawn m_SeePlayerPawn;
var Actor m_RemoveCollisionFromActor;  // Actor whose collision is disabled during the interaction sequence
// ^ NEW IN 1.60
var bool bShowLog;
var int m_iActionIndex;
//===========================================================================================================
//	 ####              #                                       #      ##
//	  ##              ##                                      ##
//	  ##    #####    #####   ####   ## ###   ####    ####    #####   ###     ####   #####    #####
//	  ##    ##  ##    ##    ##  ##   ### ##     ##  ##  ##    ##      ##    ##  ##  ##  ##  ##
//	  ##    ##  ##    ##    ######   ##  ##  #####  ##        ##      ##    ##  ##  ##  ##   ####
//	  ##    ##  ##    ## #  ##       ##     ##  ##  ##  ##    ## #    ##    ##  ##  ##  ##      ##
//	 ####   ##  ##     ##    ####   ####     ### ##  ####      ##    ####    ####   ##  ##  #####
//===========================================================================================================
var float m_fTimeSinceAction;
var int m_iCurrentState;
var bool m_bCollisionRemovedFromActor;
// true when AI and player can interact with the object
var bool m_bRainbowCanInteract;
var float m_fTimeForNextSound;
var bool m_bPawnDied;
var int m_iActionNumber;
var bool m_bEndAction;
// Replication specific
var /* replicated */ float m_fNetDamagePercentage;
// Original Hit Points
var int m_iHitPoints;
var array<array> m_AttachedActors;  // Actors that move/animate in sync with this interactive object
// ^ NEW IN 1.60
var bool m_bOriginalCollideActors;
var bool m_bOriginalBlockActors;
var bool m_bOriginalBlockPlayers;
// replicated skin
var /* replicated */ Material m_aRepSkins[4];
// save original skin
var array<array> sm_aSkins;
var StaticMesh sm_staticMesh;
var float m_fProbability;         // Probability (0.0-1.0) that AI will choose to interact with this object
// ^ NEW IN 1.60
var float m_fTimerInterval;
var NavigationPoint m_Anchor;    // Nav point where AI must stand to interact with this object
// ^ NEW IN 1.60
var name m_vEndActionAnimName;   // Animation played on the pawn when the interaction ends
// ^ NEW IN 1.60
var Actor m_vEndActionGoto;      // Actor the pawn moves toward after completing the interaction
// ^ NEW IN 1.60
var array<array> m_ActionList;   // Ordered list of sub-actions that make up this interaction sequence
// ^ NEW IN 1.60
// HearNoise buffering
var float m_HearNoiseLoudness;
var ENoiseType m_HearNoiseType;
// save/reset
// compared with the rep one
var Material m_aOldSkins[4];
var float m_fAIBreakNoiseRadius;
var Sound sm_AmbientSound;
var Sound sm_AmbientSoundStop;
var float m_fRadius;              // Detection radius; pawn must be within this range to interact
// ^ NEW IN 1.60
var float m_fActionInterval;     // Delay in seconds between repeating action cycles
// ^ NEW IN 1.60
var R6Pawn m_User;
var bool m_bBlockCoronas;         // Hide lens flare/corona effects while this object is active
// ^ NEW IN 1.60
var bool m_bBreakableByFlashBang;

// --- Functions ---
//------------------------------------------------------------------
// ResetOriginalData
//
//------------------------------------------------------------------
simulated function ResetOriginalData() {}
//------------------------------------------------------------------
// SaveOriginalData
//
//------------------------------------------------------------------
simulated function SaveOriginalData() {}
function PostBeginPlay() {}
//===========================================================================================================
//	#####
//	 ## ##
//	 ##  ##  ####   ##  ##   ####    ### ##  ####
//	 ##  ##     ##  #######     ##  ##  ##  ##  ##
//	 ##  ##  #####  #######  #####  ##  ##  ######
//	 ## ##  ##  ##  ## # ## ##  ##   #####  ##
//	#####    ### ## ##   ##  ### ##     ##   ####
//	                                #####
//===========================================================================================================
function int R6TakeDamage(int iKillValue, Pawn instigatedBy, int iStunValue, Vector vHitLocation, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGroup) {}
// ^ NEW IN 1.60
simulated function Timer() {}
//============================================================================
// function FirstPassReset -
//============================================================================
simulated function FirstPassReset() {}
//------------------------------------------------------------------
// SetBroken
//  object is broken, so stop the timer.
//------------------------------------------------------------------
simulated function SetBroken() {}
//===========================================================================================================
//	 ####              #                                       #      ##
//	  ##              ##                                      ##
//	  ##    #####    #####   ####   ## ###   ####    ####    #####   ###     ####   #####    #####
//	  ##    ##  ##    ##    ##  ##   ### ##     ##  ##  ##    ##      ##    ##  ##  ##  ##  ##
//	  ##    ##  ##    ##    ######   ##  ##  #####  ##        ##      ##    ##  ##  ##  ##   ####
//	  ##    ##  ##    ## #  ##       ##     ##  ##  ##  ##    ## #    ##    ##  ##  ##  ##      ##
//	 ####   ##  ##     ##    ####   ####     ### ##  ####      ##    ####    ####   ##  ##  #####
//===========================================================================================================
function FinishAction() {}
//------------------------------------------------------------------
// SetSkin: set the skin for local player and for replication
//
//------------------------------------------------------------------
simulated function SetSkin(int iIndex, Material aSkin) {}
//------------------------------------------------------------------
// ChangeStaticMesh: set the StaticMesh
//
//------------------------------------------------------------------
simulated function ChangeStaticMesh(StaticMesh sm) {}
function PlayInteractiveObjectSound(stDamageState stState) {}
function PerformAction(R6Pawn P) {}
simulated event SetNewDamageState(float fPercentage) {}
function StopInteraction() {}
function StopInteractionWithEndingActions() {}
function SwitchToNextAction() {}

state PA_Execute
{
//===========================================================================================================
//	 ####              #                                       #      ##
//	  ##              ##                                      ##
//	  ##    #####    #####   ####   ## ###   ####    ####    #####   ###     ####   #####    #####
//	  ##    ##  ##    ##    ##  ##   ### ##     ##  ##  ##    ##      ##    ##  ##  ##  ##  ##
//	  ##    ##  ##    ##    ######   ##  ##  #####  ##        ##      ##    ##  ##  ##  ##   ####
//	  ##    ##  ##    ## #  ##       ##     ##  ##  ##  ##    ## #    ##    ##  ##  ##  ##      ##
//	 ####   ##  ##     ##    ####   ####     ### ##  ####      ##    ####    ####   ##  ##  #####
//===========================================================================================================
    function FinishAction() {}
}

state PA_ExecuteToggleDevice
{
    function ActionDetonateAllBombs() {}
    function ActionToggleDevice() {}
}

state PA_ExecuteStartInteraction
{
}

state PA_ExecuteLookAt
{
}

state PA_ExecuteGoto
{
}

state PA_ExecutePlayAnim
{
}

state PA_ExecuteLoopAnim
{
}

state PA_ExecuteLoopRandomAnim
{
//===========================================================================================================
//	 ####              #                                       #      ##
//	  ##              ##                                      ##
//	  ##    #####    #####   ####   ## ###   ####    ####    #####   ###     ####   #####    #####
//	  ##    ##  ##    ##    ##  ##   ### ##     ##  ##  ##    ##      ##    ##  ##  ##  ##  ##
//	  ##    ##  ##    ##    ######   ##  ##  #####  ##        ##      ##    ##  ##  ##  ##   ####
//	  ##    ##  ##    ## #  ##       ##     ##  ##  ##  ##    ## #    ##    ##  ##  ##  ##      ##
//	 ####   ##  ##     ##    ####   ####     ### ##  ####      ##    ####    ####   ##  ##  #####
//===========================================================================================================
    function FinishAction() {}
}

state PA_ExecutePlayEnding
{
//===========================================================================================================
//	 ####              #                                       #      ##
//	  ##              ##                                      ##
//	  ##    #####    #####   ####   ## ###   ####    ####    #####   ###     ####   #####    #####
//	  ##    ##  ##    ##    ##  ##   ### ##     ##  ##  ##    ##      ##    ##  ##  ##  ##  ##
//	  ##    ##  ##    ##    ######   ##  ##  #####  ##        ##      ##    ##  ##  ##  ##   ####
//	  ##    ##  ##    ## #  ##       ##     ##  ##  ##  ##    ## #    ##    ##  ##  ##  ##      ##
//	 ####   ##  ##     ##    ####   ####     ### ##  ####      ##    ####    ####   ##  ##  #####
//===========================================================================================================
    function FinishAction() {}
}

state PA_ExecuteGotoEnding
{
//===========================================================================================================
//	 ####              #                                       #      ##
//	  ##              ##                                      ##
//	  ##    #####    #####   ####   ## ###   ####    ####    #####   ###     ####   #####    #####
//	  ##    ##  ##    ##    ##  ##   ### ##     ##  ##  ##    ##      ##    ##  ##  ##  ##  ##
//	  ##    ##  ##    ##    ######   ##  ##  #####  ##        ##      ##    ##  ##  ##  ##   ####
//	  ##    ##  ##    ## #  ##       ##     ##  ##  ##  ##    ## #    ##    ##  ##  ##  ##      ##
//	 ####   ##  ##     ##    ####   ####     ### ##  ####      ##    ####    ####   ##  ##  #####
//===========================================================================================================
    function FinishAction() {}
}

defaultproperties
{
}
