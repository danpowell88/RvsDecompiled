//=============================================================================
//  R6Terrorist.uc : This is the pawn class for all terrorists
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/03 * Created by Rima Brek
//    Eric - May 7th, 2001 - Add Basic Animations 
//    Eric - June 12th, 2001    - Add PatrolNode Interaction
//=============================================================================
class R6Terrorist extends R6Pawn
    native
    notplaceable
    abstract;

// --- Enums ---
enum EDefCon
{
    DEFCON_0,   // Don't exist, place holder for value of 0    
    DEFCON_1,   // Psycho
    DEFCON_2,   // Aggressive
    DEFCON_3,   // Agitated
    DEFCON_4,   // Nervous
    DEFCON_5    // Normal
};
enum ENetworkSpecialAnim
{
    NWA_NonValid,
    NWA_Playing,
    NWA_Looping
};
enum ETerroPersonality
{
    PERSO_Coward,
    PERSO_DeskJockey,
    PERSO_Normal,
    PERSO_Hardened,
    PERSO_SuicideBomber,
    PERSO_Sniper
};
enum EStrategy
{
    STRATEGY_PatrolPath,
    STRATEGY_PatrolArea,
    STRATEGY_GuardPoint,
    STRATEGY_Hunt,
    STRATEGY_Test
};
enum ETerroristCircumstantialAction
{
    CAT_None,
    CAT_Secure,
};

// --- Variables ---
var /* replicated */ byte m_wWantedHeadYaw;  // Target head yaw for AI aiming, packed as a byte for replication
// ^ NEW IN 1.60
var R6DeploymentZone m_DZone;
var /* replicated */ EDefCon m_eDefCon;    // Current DEFCON alert level of this terrorist (replicated)
// ^ NEW IN 1.60
var R6TerroristAI m_controller;
var ETerroPersonality m_ePersonality;    // Personality archetype controlling this terrorist's behavior
// ^ NEW IN 1.60
var R6THeadAttachment m_HeadAttachment;
var /* replicated */ bool m_bIsUnderArrest; // True when this terrorist has surrendered and been secured
// ^ NEW IN 1.60
var int m_iDiffLevel;             // Difficulty level index affecting this terrorist's skill stats
// ^ NEW IN 1.60
var /* replicated */ bool m_bSprayFire;  // True when terrorist is spraying automatic fire blindly
// ^ NEW IN 1.60
// Whether the therrorist can or not crouch
var bool m_bPreventCrouching;
var /* replicated */ byte m_wWantedAimingPitch; // Target vertical aim pitch, packed as a byte for replication
// ^ NEW IN 1.60
var EStrategy m_eStrategy;        // Tactical strategy this terrorist uses (aggressive/defensive/etc.)
// ^ NEW IN 1.60
var bool m_bHaveAGrenade;         // True when this terrorist has a grenade available to throw
// ^ NEW IN 1.60
var bool m_bAllowLeave;           // Allow this terrorist to leave their deployment zone when reacting
// ^ NEW IN 1.60
var /* replicated */ name m_szSpecialAnimName;
// For network. When true, a newly relevant must play the special anim.
var /* replicated */ ENetworkSpecialAnim m_eSpecialAnimValid;
var string m_szPrimaryWeapon;     // Class name of the primary weapon to equip
// ^ NEW IN 1.60
var Rotator m_rFiringRotation;   // Desired rotator for aiming, used for spray-fire direction
// ^ NEW IN 1.60
var bool m_bEnteringView;
// Patrol Movements
var bool m_bPatrolForward;
var EHeadAttachmentType m_eHeadAttachmentType;
var string m_szGrenadeWeapon;     // Class name of the grenade weapon to equip
// ^ NEW IN 1.60
var bool m_bBoltActionRifle;
var string m_szGadget;            // Class name of the gadget to equip
// ^ NEW IN 1.60
var int m_iGroupID;               // Group ID linking this terrorist to a deployment zone group
// ^ NEW IN 1.60
var bool m_bHearNothing;          // True when this terrorist is completely deaf to all sounds
// ^ NEW IN 1.60
// State variable
var /* replicated */ bool m_bPreventWeaponAnimation;
var float m_fPlayerCAStartTime;
var int m_iCurrentAimingPitch;   // Current interpolated vertical aim pitch (integer)
// ^ NEW IN 1.60
var ETerroristType m_eTerroType;
var EStance m_eStartingStance;   // Posture (stand/crouch/prone) at mission start
// ^ NEW IN 1.60
var string m_szUsedTemplate;      // Name of the template that was used to spawn this terrorist
// ^ NEW IN 1.60
var int m_iCurrentHeadYaw;        // Current interpolated horizontal head yaw (integer)
// ^ NEW IN 1.60
var Actor m_Radio;

// --- Functions ---
//============================================================================
// PostBeginPlay -
//============================================================================
simulated function PostBeginPlay() {}
simulated event AnimEnd(int iChannel) {}
//============================================================================
// BOOL R6TakeDamage -
//============================================================================
function int R6TakeDamage(optional int iBulletGoup, int iBulletToArmorModifier, Vector vMomentum, Vector vHitLocation, Pawn instigatedBy, int iStunValue, int iKillValue) {}
// ^ NEW IN 1.60
//============================================================================
// PlaySpecialPendingAction - Called from UpdateMovementAnimation to
//                            play special animation on all clients
//============================================================================
simulated event PlaySpecialPendingAction(EPendingAction eAction, int iActionInt) {}
simulated function PlayDoorAnim(R6IORotatingDoor Door) {}
function AffectedByGrenade(EGrenadeType eType, Actor aGrenade) {}
//===========================================================================//
// R6GetCircumstantialActionProgress() -
//===========================================================================//
function int R6GetCircumstantialActionProgress(Pawn actingPawn, R6AbstractCircumstantialActionQuery Query) {}
// ^ NEW IN 1.60
//============================================================================
// PlayArrestWaiting() -
//============================================================================
simulated function PlayArrestWaiting() {}
simulated function PlayCallBackup() {}
//============================================================================
// PlayDuck -
//============================================================================
simulated function PlayDuck() {}
//============================================================================
// AnimateRunning()
//============================================================================
simulated function AnimateRunning() {}
//============================================================================
// vector EyePosition -
//============================================================================
event Vector EyePosition() {}
// ^ NEW IN 1.60
//============================================================================
// PlayCrouchWaiting() -
//============================================================================
simulated function PlayCrouchWaiting() {}
//============================================================================
// string R6GetCircumstantialActionString -
//============================================================================
simulated function string R6GetCircumstantialActionString(int iAction) {}
// ^ NEW IN 1.60
event EndOfGrenadeEffect(EGrenadeType eType) {}
//============================================================================
// CommonInit -  Common initialization between R6Terrorist and R6MatineeTerrorist
//============================================================================
function CommonInit() {}
//============================================================================
// StartCrouch -
//============================================================================
event StartCrouch(float HeightAdjust) {}
//============================================================================
// EndCrouch -
//============================================================================
event EndCrouch(float fHeight) {}
//============================================================================
// function GetReloadAnimation -
//============================================================================
simulated function bool GetReloadWeaponAnimation(out STWeaponAnim stAnim) {}
// ^ NEW IN 1.60
//============================================================================
// R6QueryCircumstantialAction -
//============================================================================
event R6QueryCircumstantialAction(out R6AbstractCircumstantialActionQuery Query, float fDistance, PlayerController PlayerController) {}
//============================================================================
// PlayWaiting -
//============================================================================
simulated function PlayWaiting() {}
//============================================================================
// function GetFireWeaponAnimation -
//============================================================================
simulated function bool GetFireWeaponAnimation(out STWeaponAnim stAnim) {}
// ^ NEW IN 1.60
//============================================================================
// function GetNormalWeaponAnimation -
//============================================================================
simulated function bool GetNormalWeaponAnimation(out STWeaponAnim stAnim) {}
// ^ NEW IN 1.60
simulated event StopSpecialAnim() {}
simulated event LoopSpecialAnim() {}
simulated event PlaySpecialAnim() {}
simulated function PlayThrowGrenade() {}
simulated function PlayArrest() {}
simulated function PlayKneeling() {}
simulated function PlaySurrender() {}
simulated function PlayBlinded() {}
simulated function StopCoughing() {}
simulated function PlayCoughing() {}
//============================================================================
// event ReceivedWeapons -
//============================================================================
simulated event ReceivedWeapons() {}
//============================================================================
// function PlayMoving -
//============================================================================
simulated function PlayMoving() {}
function StartHunting() {}
simulated function AnimateCrouchRunningDownStairs() {}
simulated function AnimateCrouchRunningUpStairs() {}
// Movement function not supposed to be called for a terrorist
simulated function AnimateCrouchRunning() {}
//============================================================================
// R6TerroristMgr GetManager -
//============================================================================
function R6TerroristMgr GetManager() {}
// ^ NEW IN 1.60
//============================================================================
// IsFighting: return true when the pawn is fighting
// - inherited
//============================================================================
function bool IsFighting() {}
// ^ NEW IN 1.60
function EndGrenade() {}
function ReleaseGrenade() {}
//===========================================================================//
// R6CircumstantialActionProgressStart()                                     //
//===========================================================================//
function R6CircumstantialActionProgressStart(R6AbstractCircumstantialActionQuery Query) {}
//============================================================================
// ResetArrest -
//============================================================================
function ResetArrest() {}
//============================================================================
// PlayKneelWaiting() -
//============================================================================
simulated function PlayKneelWaiting() {}
//============================================================================
// PlayProneWaiting -
//============================================================================
simulated function PlayProneWaiting() {}
//============================================================================
// function AnimateWalkingDownStairs -
//============================================================================
simulated function AnimateWalkingDownStairs() {}
//============================================================================
// function AnimateWalkingUpStairs -
//============================================================================
simulated function AnimateWalkingUpStairs() {}
//============================================================================
// AnimateWalking()
//============================================================================
simulated function AnimateWalking() {}
//============================================================================
// AnimateStandTurning
//============================================================================
simulated function AnimateStandTurning() {}
//============================================================================
// SetMovementPhysics -
//============================================================================
simulated function SetMovementPhysics() {}
//============================================================================
// FinishInitialization -
//============================================================================
event FinishInitialization() {}
//============================================================================
// SetToGrenade -
//============================================================================
function SetToGrenade() {}
//============================================================================
// SetToNormalWeapon -
//============================================================================
function SetToNormalWeapon() {}
//============================================================================
// Rotator GetFiringRotation -
//============================================================================
function Rotator GetFiringRotation() {}
// ^ NEW IN 1.60
//============================================================================
// event Destroyed -
//============================================================================
simulated event Destroyed() {}

defaultproperties
{
}
