//=============================================================================
//  R6Pawn.uc : This is the base pawn class for all Rainbow 6 characters
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/03 * Created by Rima Brek
//    2001/05/07   Joel Tremblay        Add Kill and Stun results
//                                      Add R6TakeDamage and R6Died
//    2001/05/29   Joel Tremblay        Add Activate Night Vision.
//    2001/05/29   Aristo Kolokathis    Added player's base accuracy
//    2001/07/24   Joel Tremblay        Change player response to hit
//=============================================================================
class R6Pawn extends R6AbstractPawn
    native
    abstract;

#exec OBJ LOAD FILE=..\Textures\R6ActionIcons.utx PACKAGE=R6ActionIcons
#exec OBJ LOAD FILE=..\Textures\Inventory_t.utx PACKAGE=Inventory_t
#exec OBJ LOAD FILE=..\Sounds\Voices_1rstPersonRainbow.uax PACKAGE=Voices_1rstPersonRainbow
#exec OBJ LOAD FILE=..\Sounds\Voices_3rdPersonRainbow.uax PACKAGE=Voices_3rdPersonRainbow

// --- Constants ---
const C_NoiseTimerFrequency =  0.33f;
const C_iRotationOffsetBipod =  5600;
const C_iRotationOffsetProne =  3000;
const C_iRotationOffsetNormal =  5461;
const C_fPeekProneTime =   120.0;
const C_fPeekSpeedInMs =  3000.0;
const C_fPeekCrouchRightMax =  1600.0;
const C_fPeekCrouchLeftMax =   400.0;
const C_fPeekRightMax =  2000.0;
const C_fPeekMiddleMax =  1000.0;
const C_fPeekLeftMax =     0.0;
const C_MaxPendingAction =  5;
const C_fHeadHeight =  26.f;
const C_fHeadRadius =  28.f;
const C_fPrePivotStairOffset =  5.0;
const C_iPawnSpecificChannel =  16;
const C_iWeaponLeftAnimChannel =  15;
const C_iWeaponRightAnimChannel =  14;
const C_iPeekingAnimChannel =  13;
const C_iPostureAnimChannel =  12;
const C_iBaseBlendAnimChannel =  1;
const C_iBaseAnimChannel =  0;
const C_iHeartRateMinOther =  90;
const C_iHeartRateMinTerrorist =  65;
const C_iHeartRateMaxOther =  182;
const C_iHeartRateMaxTerrorist =  184;

// --- Enums ---
enum eMovementPace
{
    PACE_None,
    PACE_Prone,
    PACE_CrouchWalk,
    PACE_CrouchRun,
    PACE_Walk,
    PACE_Run
};
enum eBodyPart
{
    BP_Head,
    BP_Chest,
    BP_Abdomen,
    BP_Legs,
    BP_Arms,
};
enum EPendingAction
{
    PENDING_None,
    // Common animation
    PENDING_Coughing,
    PENDING_StopCoughing,
    PENDING_Blinded,
    PENDING_OpenDoor,
    PENDING_StartClimbingLadder,
    PENDING_PostStartClimbingLadder,
    PENDING_EndClimbingLadder,
    PENDING_PostEndClimbingLadder,
    PENDING_DropWeapon,
    PENDING_ProneToCrouch,
    PENDING_CrouchToProne,
    PENDING_MoveHitBone,
    PENDING_StartClimbingObject,
    PENDING_PostStartClimbingObject,
    // Specific Rainbow animation
    PENDING_SetRemoteCharge,
    PENDING_SetBreachingCharge,
    PENDING_SetClaymore,
    PENDING_InteractWithDevice,
    PENDING_LockPickDoor,
    PENDING_ComFollowMe,
    PENDING_ComCover,
    PENDING_ComGo,
    PENDING_ComRegroup,
    PENDING_ComHold,
    PENDING_ActivateNightVision,
    PENDING_DeactivateNightVision,
    PENDING_SecureWeapon,
    PENDING_EquipWeapon,
    PENDING_SecureTerrorist,
    // Specific Terrorist animation
    PENDING_ThrowGrenade,
    PENDING_Surrender,
    PENDING_Kneeling,
    PENDING_Arrest,
    PENDING_CallBackup,
    PENDING_SpecialAnim,
    PENDING_LoopSpecialAnim,
    PENDING_StopSpecialAnim,
    // Specific Hostage animation
    PENDING_HostageAnim,
            // MPF1
	    // Specific Capture The Enemy animations
	PENDING_EndSurrender, //MissionPack1
	PENDING_StartSurrender, //MissionPack1
	PENDING_PostEndSurrender, //MissionPack1
	PENDING_SetFree,		  //MissionPack1
	PENDING_ArrestKneel,		  //MPF_Milan
	PENDING_ArrestWaiting,	//MPF_Milan_7_1_2003
	PENDING_EndArrest		//MPF_Milan_7_1_2003
};
enum EHostagePersonality
{
    HPERSO_Coward,
    HPERSO_Normal,
    HPERSO_Brave,
    HPERSO_Bait,
    HPERSO_None
};
enum eDeviceAnimToPlay
{
    BA_ArmBomb,
    BA_DisarmBomb,
    BA_Keypad,
    BA_PlantDevice,
    BA_Keyboard
}m_eDeviceAnim;

enum EHostagePersonality
{
    HPERSO_Coward,
    HPERSO_Normal,
    HPERSO_Brave,
    HPERSO_Bait,
    HPERSO_None
};
enum eHands
{
    HANDS_None,
    HANDS_Right,
    HANDS_Left,
    HANDS_Both
}m_ePlayerIsUsingHands;

var enum eDeviceAnimToPlay
{
    BA_ArmBomb,
    BA_DisarmBomb,
    BA_Keypad,
    BA_PlantDevice,
    BA_Keyboard
}m_eDeviceAnim;

enum EHostagePersonality
{
    HPERSO_Coward,
    HPERSO_Normal,
    HPERSO_Brave,
    HPERSO_Bait,
    HPERSO_None
};
enum eStrafeDirection
{
    // enum values not recoverable from binary — see 1.56 source
};
enum ETerroristType
{
    TTYPE_B1T1,
    TTYPE_B1T3,
    TTYPE_B2T2,
    TTYPE_B2T4,
    TTYPE_M1T1,
    TTYPE_M1T3,
    TTYPE_M2T2,
    TTYPE_M2T4,
    TTYPE_P1T1,
    TTYPE_P2T2,
    TTYPE_P3T3,
    TTYPE_P1T4,
    TTYPE_P2T5,
    TTYPE_P3T6,
    TTYPE_P1T7,
    TTYPE_P2T8,
    TTYPE_P3T9,
    TTYPE_P1T10,
    TTYPE_P2T11,
    TTYPE_P3T12,
    TTYPE_P4T13,
    TTYPE_D1T1,
    TTYPE_D1T2,
    TTYPE_GOSP,
    TTYPE_GUTI,
    TTYPE_S1T1,
    TTYPE_S1T2,
    TTYPE_TXIC,
    TTYPE_T1T1,
    TTYPE_T2T2,
    TTYPE_T1T3,
    TTYPE_T2T4,
};
enum EHeadAttachmentType
{
    ATTACH_Glasses,
    ATTACH_Sunglasses,
    ATTACH_GasMask,
    ATTACH_None
};
enum eArmor
{
    ARMOR_None,
    ARMOR_Light,
    ARMOR_Medium,
    ARMOR_Heavy,
};
enum eMovementDirection
{
    MOVEDIR_Forward,
    MOVEDIR_Backward,
    MOVEDIR_Strafe
};

// --- Structs ---
struct STWeaponAnim
{
    var name    nAnimToPlay;
    var name    nBlendName;
    var FLOAT   fTweenTime;
    var FLOAT   fRate;
    var BOOL    bPlayOnce;
    var BOOL    bBackward;
};

// --- Variables ---
// var ? bBackward; // REMOVED IN 1.60
// var ? bPlayOnce; // REMOVED IN 1.60
// var ? fRate; // REMOVED IN 1.60
// var ? fTweenTime; // REMOVED IN 1.60
// var ? m_fFallingHeight; // REMOVED IN 1.60
// var ? nAnimToPlay; // REMOVED IN 1.60
// var ? nBlendName; // REMOVED IN 1.60
var /* replicated */ R6Ladder m_Ladder;
var R6Door m_Door;
var eMovementPace m_eMovementPace;
var /* replicated */ eHands m_ePlayerIsUsingHands; // Which hand(s) the pawn is currently using (replicated)
// ^ NEW IN 1.60
var bool m_bPostureTransition;
var int m_iID;                    // Formation rank identifier for this pawn within its team
// ^ NEW IN 1.60
var /* replicated */ bool m_bIsClimbingLadder;
var bool m_bAvoidFacingWalls;
var /* replicated */ bool m_bPawnSpecificAnimInProgress;
// only used for Audio replication
var /* replicated */ R6SoundReplicationInfo m_SoundRepInfo;
var bool m_bWeaponTransition;
// Boolean to determine if the night vision is on
var bool m_bActivateNightVision;
var /* replicated */ bool m_bChangingWeapon;
var /* replicated */ bool m_bIsKneeling;
// -- weapons -- //
var /* replicated */ bool m_bReloadingWeapon;
//R6Breathing
var Emitter m_BreathingEmitter;
// pawn who killed me
var /* replicated */ R6Pawn m_KilledBy;
// current bipod rotation
var /* replicated */ float m_fBipodRotation;
var eArmor m_eArmorType;          // Equipped armor tier (None/Light/Medium/Heavy)
// ^ NEW IN 1.60
// -- gadgets -- //
// Boolean to activate the heat vision and the black flag.
var bool m_bActivateHeatVision;
// current ratio
var float m_fPeeking;
var bool m_bIsSniping;
//AK: m_bSuicided should be set to true, this will be used to punish those who suicide in deathmatch and perhaps other game modes
////
// how did the player quit the round/match
var /* replicated */ byte m_bSuicideType;
// -- object and actor interaction -- //
var /* replicated */ Actor m_potentialActionActor;
// For wait animation Synch
var /* replicated */ byte m_bRepPlayWaitAnim;
var R6ArmPatchGlow m_ArmPatches[2];
var bool m_bNightVisionAnimation;
// value that peekingatio reaches (replication)
var /* replicated */ float m_fPeekingGoal;
var R6Door m_Door2;
var R6AbstractBulletManager m_pBulletManager;
var byte m_iLocalCurrentActionIndex;
var bool m_bIsClimbingStairs;
var bool m_bSlideEnd;
// rbrek 25 oct 2001
// this flag is used to ensure that the bone rotation that is needed for diagonal movement is only
// done once when the diagonal movement begins, and once when the player returns to normal movement.
var bool m_bMovingDiagonally;
var /* replicated */ bool m_bEngaged;
// R6CODE
// used for radar replication
var /* replicated */ R6TeamMemberReplicationInfo m_TeamMemberRepInfo;
var float m_fGadgetSpeedMultiplier; // Speed multiplier applied to gadget deployment actions
// ^ NEW IN 1.60
// -- movement speeds -- //
var float m_fWalkingSpeed;
var name m_WeaponAnimPlaying;
// Boolean to determine if the scope vision is on
var bool m_bActivateScopeVision;
// For the bomb & other devices (computer, keypad, placebug)
var /* replicated */ bool m_bInteractingWithDevice;
var name m_standDefaultAnimName;
// Boolean to activate the current gadget
var bool m_bWeaponGadgetActivated;
var name m_standWalkRightName;
var name m_standWalkLeftName;
var float m_fSkillStealth;        // Stealth skill level: reduces movement noise radius (0=7m, 100=1m)
// ^ NEW IN 1.60
var float m_fSkillSniper;         // Sniper skill level: affects scoped reticule convergence speed
// ^ NEW IN 1.60
var float m_fSkillElectronics;    // Electronics skill: reduces time to plant/disable electronic devices
// ^ NEW IN 1.60
var float m_fSkillDemolitions;    // Demolitions skill: reduces time to plant and disarm explosives
// ^ NEW IN 1.60
var float m_fSkillAssault;        // Assault skill: affects hip-fire reticule convergence speed
// ^ NEW IN 1.60
// for replication m_fBipodRotation/C_iRotationOffsetBipod
var /* replicated */ int m_iRepBipodRotationRatio;
var /* replicated */ int m_iForceStun;
var Actor m_TrackActor;
// true when prone and the gun have a bipod
var bool m_bUsingBipod;
var eStrafeDirection m_eStrafeDirection; // Current diagonal strafe direction for bone rotation
// ^ NEW IN 1.60
var int m_iPermanentID;           // Permanent ID that persists across team reshuffles
// ^ NEW IN 1.60
// when m_bIsClimbingStairs is true, this var indicates whether pawn is facing up or down
var bool m_bIsMovingUpStairs;
var /* replicated */ int m_iPendingActionInt[5];
var Actor m_FOV;
var /* replicated */ byte m_iNetCurrentActionIndex;
var /* replicated */ eDeviceAnimToPlay m_eDeviceAnim; // Which device interaction animation to play (replicated)
// ^ NEW IN 1.60
var float m_fSkillObservation;    // Observation skill: increases chance to spot enemies
// ^ NEW IN 1.60
var float m_fSkillLeadership;     // Leadership skill: reduces delay before team members respond to orders
// ^ NEW IN 1.60
// if prone: C_iRotationOffsetProne, otherwise C_iRotationOffsetNormal
var int m_iMaxRotationOffset;
var bool m_bDontHearPlayer;       // Debug: pawn cannot hear player-generated sounds
// ^ NEW IN 1.60
var float m_fSkillSelfControl;    // Self-control skill: increases minimum hit-chance threshold before firing
// ^ NEW IN 1.60
//These variables are put here for network.
// How much the weapon jumps when firing, set when changing weapon
var float m_fWeaponJump;
// jump return factor when zoom
var float m_fZoomJumpReturn;
// when peeking is over, return to center
var bool m_bPeekingReturnToCenter;
var bool m_bAutoClimbLadders;
// force kill result for testing
var /* replicated */ int m_iForceKill;
// -- animation -- //
var eHands m_eLastUsingHands;
var name m_standWalkForwardName;
var name m_standWalkBackName;
// turning animation names
var name m_standTurnLeftName;
var name m_standTurnRightName;
var float m_fHBWound;
var /* replicated */ bool m_bCanFireNeutrals;
// Friendly Fire
// when a bullet touch someone, check if the friendly fire can be used
var /* replicated */ bool m_bCanFireFriends;
//R6HEARTBEAT
var float m_fHBTime;
var bool m_bHelmetWasHit;
// default name for the anim
var name m_crouchDefaultAnimName;
var bool m_bDontSeePlayer;        // Debug: pawn cannot visually detect the player
// ^ NEW IN 1.60
var float m_fWallCheckDistance;
var bool m_bSoundChangePosture;
// Used in Native function
var bool m_bPawnIsReloading;
// When using blot action rifle and the notify that re attach to righ hand was not called.
var bool m_bReAttachToRightHand;
var bool m_bPlayingComAnimation;
// Use for the sound when a pawn enter a smoke grenade or tear gas
var float m_fTimeGrenadeEffectBeforeSound;
var float m_fRightDirtyFootStepRemainingTime;
var float m_fLeftDirtyFootStepRemainingTime;
var byte m_byRemainingWaitZero;
// R6CollisionBox
// when going prone, backup the value
var Vector m_vPrePivotProneBackup;
//R6BLOOD
var eBodyPart m_eLastHitPart;
var float m_fTimeStartBodyFallSound;
// last bipod rotation
var int m_iLastBipodRotation;
// For the bomb
var /* replicated */ bool m_bCanArmBomb;
// For the bomb
var /* replicated */ bool m_bCanDisarmBomb;
var name m_standClimb96DefaultAnimName;
var name m_standClimb64DefaultAnimName;
var name m_crouchStairWalkDownRightName;
var name m_standStairWalkDownName;
// stair walk animation names
var name m_standStairWalkUpName;
// crouch movement animation names
var name m_crouchWalkForwardName;
var name m_standRunRightName;
var name m_standRunBackName;
var name m_standRunLeftName;
// upright movement animation names
var name m_standRunForwardName;
// Hit variable
var /* replicated */ Rotator m_rHitDirection;
// Ragdoll controling the bone when dead
var R6AbstractCorpse m_ragdoll;
var bool m_bUseKarmaRagdoll;      // Debug: enable Karma physics ragdoll on death
// ^ NEW IN 1.60
var bool m_bWallAdjustmentDone;
////
var bool m_bSuicided;
var Sound m_sndNightVisionDeactivation;
var float m_fCrouchedRunningSpeed;
var float m_fCrouchedWalkingSpeed;
var bool m_bPreviousAnimPlayOnce;
var bool m_bDesignToggleLog;
var class<R6FootStep> m_RightDirtyFootStep;
// Dirty footsteps
var class<R6FootStep> m_LeftDirtyFootStep;
var byte m_bSavedPlayWaitAnim;
var float m_fFiringTimer;
// To know which foot is on the floor (use to check the surface)
var bool m_bLeftFootDown;
var Vector m_vFiringStartPoint;
// Firing start point caching
var float m_fLastFSPUpdate;
var name m_standStairRunDownRightName;
var name m_standStairRunUpRightName;
var name m_standStairWalkDownRightName;
var name m_standStairWalkUpRightName;
var name m_hurtStandWalkRightName;
// hurt anim
var name m_hurtStandWalkLeftName;
// Death variables
// Set to true as soon as one terrorist saw this dead body
var bool m_bTerroSawMeDead;
var Sound m_sndThermalScopeDeactivation;
// Sound variable
var Sound m_sndNightVisionActivation;
// peeking data
var float m_fLastValidPeeking;
// Action Mode
var /* replicated */ R6ClimbableObject m_climbObject;
var float m_fRunningSpeed;
// Wait until it false to change weapon
var bool m_bIsFiringState;
//Replicated bool to loop shotguns reload anims.
var /* replicated */ bool m_bReloadAnimLoop;
var bool m_bOldCanWalkOffLedges;
// used by NPC: allowed to climb a ClimbableObject
var bool m_bCanClimbObject;
// -- movement -- //
// vector indicates direction towards top of stairs
var Vector m_vStairDirection;
var /* replicated */ EPendingAction m_ePendingAction[5];
var bool m_bDontKill;
// Speeds (Rainbow values set in R6Rainbow)
var float m_fReloadSpeedMultiplier;
var float m_fGunswitchSpeedMultiplier;
var float m_fWalkingBackwardStrafeSpeed;
var float m_fRunningBackwardStrafeSpeed;
var float m_fCrouchedWalkingBackwardStrafeSpeed;
var float m_fCrouchedRunningBackwardStrafeSpeed;
var float m_fProneSpeed;
// modifier of the goal (used by ai). Tween value, 1 == 100% of the goal setted
var float m_fPeekingGoalModifier;
var Sound m_sndCrouchToStand;
var Sound m_sndStandToCrouch;
var Sound m_sndThermalScopeActivation;
var Sound m_sndDeathClothes;
var Sound m_sndDeathClothesStop;
var float m_fStunShakeTime;
// previous rotation offset
var Rotator m_rPrevRotationOffset;
// falling animation names
var name m_standFallName;
var name m_standLandName;
var name m_crouchFallName;
var name m_crouchLandName;
var name m_standStairWalkUpBackName;
var name m_standStairWalkDownBackName;
// stair run animation names
var name m_standStairRunUpName;
var name m_standStairRunUpBackName;
var name m_standStairRunDownName;
var name m_standStairRunDownBackName;
// stair crouch animation names
var name m_crouchStairWalkDownName;
var name m_crouchStairWalkDownBackName;
var name m_crouchStairWalkUpName;
var name m_crouchStairWalkUpBackName;
var name m_crouchStairWalkUpRightName;
var name m_crouchStairRunUpName;
var name m_crouchStairRunDownName;
var class<Actor> m_FOVClass;
var float m_fHBMove;
var float m_fHBDefcon;
//R6ArmPatches
var /* replicated */ bool m_bHasArmPatches;
var int m_iDesignRandomTweak;
var int m_iDesignLightTweak;
var int m_iDesignMediumTweak;
var int m_iDesignHeavyTweak;
// Lipsynch data
var int m_hLipSynchData;
// when prone, we do small translation of the prepivot instead of a radical change
var float m_fPrePivotLastUpdate;
//
// Each pawnthis identifies the character rank within the team (for formation purposes)
var int m_iUniqueID;
var Rotator m_rRToe;
var Rotator m_rRFoot;
var Rotator m_rRCalf;
var Rotator m_rRThigh;
var Rotator m_rLToe;
var Rotator m_rLFoot;
var Rotator m_rLCalf;
var Rotator m_rLThigh;
var Rotator m_rRFinger0;
var Rotator m_rRHand;
var Rotator m_rRForeArm;
var Rotator m_rRUpperArm;
var Rotator m_rRClavicle;
var Rotator m_rLFinger0;
var Rotator m_rLHand;
var Rotator m_rLForeArm;
var Rotator m_rLUpperArm;
var Rotator m_rLClavicle;
var Rotator m_rJaw;
var Rotator m_rPonyTail2;
var Rotator m_rPonyTail1;
var Rotator m_rHead;
var Rotator m_rNeck;
var Rotator m_rSpine2;
var Rotator m_rSpine1;
var Rotator m_rSpine;
var Rotator m_rPelvis;
var Rotator m_rRoot;
//#ifdefDEBUG
var bool m_bModifyBones;
var Rotator m_rViewRotation;
var float m_fLastVRPUpdate;
// Movement noise timer
var float m_fNoiseTimer;
var bool m_bAim;
var bool m_bWasPeekingLeft;
var bool m_bWasPeeking;
// used in updatedmovementAnimation
var float m_fOldPeekBlendRate;
// used in updatedmovementAnimation
var float m_fOldCrouchBlendRate;
// used in updatedmovementAnimation
var ePeekingMode m_eOldPeekingMode;
var float m_fProneStrafeSpeed;
var bool m_bPawnReloadShotgunLoop;
// Used in Native function
var bool m_bPawnIsChangingWeapon;
var bool m_bOldServerCancelPlacingCharge;
var /* replicated */ bool m_bToggleServerCancelPlacingCharge;
// Used in Native function
var eHands m_ePawnIsUsingHand;
// -- identification -- //
// used for visibility checks; ensure that location of checks vary to improve chances of partial detection...
var int m_iVisibilityTest;

// --- Functions ---
// function ? PlayClimbObject(...); // REMOVED IN 1.60
// function ? PlayPostClimb(...); // REMOVED IN 1.60
// function ? ServerArrested(...); // REMOVED IN 1.60
// function ? TakeDamage(...); // REMOVED IN 1.60
// function ? UpdateBones(...); // REMOVED IN 1.60
simulated event PostBeginPlay() {}
//============================================================================
// PlaySpecialPendingAction - Called from UpdateMovementAnimation to
//                            play special animation on all clients
//============================================================================
simulated event PlaySpecialPendingAction(EPendingAction eAction, int iActionInt) {}
simulated event AnimEnd(int iChannel) {}
//============================================================================
// event PlayWeaponAnimation -
//============================================================================
simulated event PlayWeaponAnimation() {}
event EndCrouch(float fHeight) {}
event StartCrouch(float HeightAdjust) {}
simulated function Tick(float DeltaTime) {}
//===================================================================================================
// function PostNetBeginPlay()
//===================================================================================================
simulated event PostNetBeginPlay() {}
simulated event Destroyed() {}
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
//                          ANIMATION FUNCTIONS COMMON TO ALL STATES
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
simulated function PlayWaiting() {}
function int R6TakeDamage(Pawn instigatedBy, Vector vMomentum, Vector vHitLocation, int iStunValue, int iKillValue, int iBulletToArmorModifier, optional int iBulletGoup) {}
// ^ NEW IN 1.60
exec function ToggleNightVision() {}
simulated function PlayDuck() {}
//===================================================================================================
// EyePosition()
//  Returns the offset for the eye from the Pawn's location at which to place the camera or to start
//  the line of sight
// rbrek - 19 July 2001 - Originally defined in Pawn.uc.  Overridden here in order to
//   include the proper offset due to peeking and/or fluid crouching...
//===================================================================================================
simulated event Vector EyePosition() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// ProcessBuildDeathMessage
//  return true if the build death msg can be build by "static BuildDeathMessage"
//------------------------------------------------------------------
function bool ProcessBuildDeathMessage(out string szPlayerName, Pawn Killer) {}
// ^ NEW IN 1.60
simulated function PlayBlinded() {}
simulated function PlayCoughing() {}
simulated function bool GetNormalWeaponAnimation(out STWeaponAnim stAnim) {}
// ^ NEW IN 1.60
simulated function bool GetFireWeaponAnimation(out STWeaponAnim stAnim) {}
// ^ NEW IN 1.60
//===================================================================================================
// TurnAwayFromNearbyWalls()
//   rbrek 18 jan 2002
//   pick a focalpoint so that we are not facing a wall... (traces do not check for actors)
//   currently using a distance of 3m for the trace tests
//===================================================================================================
function TurnAwayFromNearbyWalls() {}
//============================================================================
simulated function bool GetReloadWeaponAnimation(out STWeaponAnim stAnim) {}
// ^ NEW IN 1.60
//===================================================================================================
// function PossessedBy()
//===================================================================================================
function PossessedBy(Controller C) {}
//============================================================================
// AffectedByGrenade -
//============================================================================
function AffectedByGrenade(EGrenadeType eType, Actor aGrenade) {}
function Rotator GetFiringRotation() {}
// ^ NEW IN 1.60
simulated function PlayCrouchWaiting() {}
//------------------------------------------------------------------
// HasBumpPriority: return true if this pawn has bump priority
//  over bumpedBy. This is used when the pawn is NOT stationary so he
//  should get out of the way
//------------------------------------------------------------------
function bool HasBumpPriority(R6Pawn bumpedBy) {}
// ^ NEW IN 1.60
event EndOfGrenadeEffect(EGrenadeType eType) {}
//------------------------------------------------------------------
// CanBeAffectedByGrenade: return true if can be affected by the grenade
//   at this moment
//------------------------------------------------------------------
simulated function bool CanBeAffectedByGrenade(EGrenadeType eType, Actor aGrenade) {}
// ^ NEW IN 1.60
//===================================================================================================
// PlayMoving()
//===================================================================================================
simulated function PlayMoving() {}
//===================================================================================================
// there still remains a problem when strafing across stairs (should use regular non-stair strafing animation)
simulated function AnimateWalkingUpStairs() {}
//===================================================================================================
simulated function AnimateWalkingDownStairs() {}
//===================================================================================================
// PlayDoorAnim()
//===================================================================================================
simulated function PlayDoorAnim(R6IORotatingDoor Door) {}
simulated function PlayStartClimbing() {}
//============================================================================
// IsFighting: return true when the pawn is in active combat (ie: a threat)
//============================================================================
function bool IsFighting() {}
// ^ NEW IN 1.60
//===================================================================================================
// EndClimbStairs()
//===================================================================================================
simulated function EndClimbStairs() {}
//===================================================================================================
// ClimbStairs()
//  vStairDirection indicates the direction towards the top of the stairs
//===================================================================================================
simulated function ClimbStairs(Vector vStairDirection) {}
simulated function PlayEndClimbing() {}
simulated function bool HasPawnSpecificWeaponAnimation() {}
// ^ NEW IN 1.60
//For rainbow when using Bolt Action rifles.
simulated function BoltActionSwitchToRight() {}
//------------------------------------------------------------------
// EnteredExtractionZone
//------------------------------------------------------------------
function EnteredExtractionZone(R6AbstractExtractionZone Zone) {}
//Defined in R6Rainbow.uc
simulated function GetWeapon(R6AbstractWeapon NewWeapon) {}
//------------------------------------------------------------------
// CanInteractWithObjects()
//------------------------------------------------------------------
function bool CanInteractWithObjects() {}
// ^ NEW IN 1.60
simulated function bool GetChangeWeaponAnimation(out STWeaponAnim stAnim) {}
// ^ NEW IN 1.60
simulated function PlaySecureTerrorist() {}
simulated function bool GetThrowGrenadeAnimation(out STWeaponAnim stAnim) {}
// ^ NEW IN 1.60
simulated function bool GetPawnSpecificAnimation(out STWeaponAnim stAnim) {}
// ^ NEW IN 1.60
//===================================================================================================
simulated function AnimateCrouchRunningDownStairs() {}
//===================================================================================================
simulated function AnimateCrouchRunningUpStairs() {}
//===================================================================================================
simulated function AnimateCrouchRunning() {}
//===================================================================================================
simulated function AnimateWalking() {}
simulated function bool CheckForPassiveGadget(string aClassName) {}
// ^ NEW IN 1.60
//===================================================================================================
simulated function AnimateStandTurning() {}
simulated event PlayCrouchToProne(optional bool bForcedByClient) {}
simulated event PlayProneToCrouch(optional bool bForcedByClient) {}
function Vector GetHandLocation() {}
// ^ NEW IN 1.60
function IncrementBulletsFired() {}
function float ArmorSkillEffect() {}
// ^ NEW IN 1.60
//===================================================================================================
simulated function AnimateRunning() {}
final native function int GetThroughResult(Vector vBulletDirection, int ePartHit, int iKillDamage) {}
// ^ NEW IN 1.60
final native function eStunResult GetStunResult(int iStunDamage, bool bHitBySilencedWeapon, int ePartHit, int eArmorType, int iBulletToArmorModifier) {}
// ^ NEW IN 1.60
final native function eKillResult GetKillResult(int iKillDamage, int ePartHit, int eArmorType, int iBulletToArmorModifier, bool bHitBySilencedWeapon) {}
// ^ NEW IN 1.60
final native function ToggleHeatProperties(Texture pAddTexture, Texture pMaskTexture, bool bTurnItOn) {}
// ^ NEW IN 1.60
final native function ToggleNightProperties(Texture pAddTexture, Texture pMaskTexture, bool bTurnItOn) {}
// ^ NEW IN 1.60
final native function ToggleScopeProperties(Texture pAddTexture, Texture pMaskTexture, bool bTurnItOn) {}
// ^ NEW IN 1.60
final native function bool AdjustFluidCollisionCylinder(optional bool bTest, float fBlendRate) {}
// ^ NEW IN 1.60
final native function SetPawnScale(float fNewScale) {}
// ^ NEW IN 1.60
final native function bool CheckCylinderTranslation(optional bool bIgnoreAllActor1Class, optional Actor ignoreActor1, Vector vDest, Vector vStart) {}
// ^ NEW IN 1.60
final native function float GetPeekingRatioNorm(float fPeeking) {}
// ^ NEW IN 1.60
final native function StartLipSynch(Sound _hStopSound, Sound _hSound) {}
// ^ NEW IN 1.60
final native function MoveHitBone(int iHitBone, Rotator rHitDirection) {}
// ^ NEW IN 1.60
final native function FootStep(bool bLeftFoot, name nBoneName) {}
// ^ NEW IN 1.60
final native function PawnLook(optional bool bNoBlend, optional bool bAim, Rotator rLookDir) {}
// ^ NEW IN 1.60
final native function PawnLookAbsolute(optional bool bNoBlend, optional bool bAim, Rotator rLookDir) {}
// ^ NEW IN 1.60
final native function PawnLookAt(optional bool bNoBlend, optional bool bAim, Vector vTarget) {}
// ^ NEW IN 1.60
final native function PawnTrackActor(optional bool bAim, Actor Target) {}
// ^ NEW IN 1.60
final native function UpdatePawnTrackActor(optional bool bNoBlend) {}
// ^ NEW IN 1.60
final native function bool PawnCanBeHurtFrom(Vector vLocation) {}
// ^ NEW IN 1.60
final native function SendPlaySound(optional bool bDoNotPlayLocallySound, ESoundSlot ID, Sound S) {}
// ^ NEW IN 1.60
final native function PlayVoices(optional float fTime, optional bool bWaitToFinishSound, optional ESendSoundStatus eSend, int iPriority, ESoundSlot eSlotUse, Sound sndPlayVoice) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// logWarning: important log to catch (ie: they should not happen,
//  and the don't have bShowLog in front of them)
//------------------------------------------------------------------
simulated function logWarning(string Text) {}
function ClientSetJumpValues(float fNewValue) {}
function RenderGunDirection(Canvas C) {}
function DrawViewRotation(Canvas C) {}
//===================================================================================================
// rbrek - 12 nov 2001
// for NPCS (non-player pawns)
// set the m_rRotationOffset using this function; uses m_rPrevRotationOffset in order to keep track of
// previous rotationOffset
//===================================================================================================
simulated event SetRotationOffset(int iRoll, int iYaw, int iPitch) {}
//===================================================================================================
// rbrek 12 nov 2001
// PlayPostRootMotionAnimation()
//   used to reset the mode after using root motion, and to play a regular compressed animation
//===================================================================================================
simulated function PlayPostRootMotionAnimation(name animName) {}
//------------------------------------------------------------------
// SetCrouchBlend
//
//------------------------------------------------------------------
simulated event SetCrouchBlend(float fCrouchBlend) {}
//===================================================================================================
// SetAvoidFacingWalls()
//===================================================================================================
function SetAvoidFacingWalls(bool bAvoidFacingWalls) {}
//------------------------------------------------------------------
// ServerSuicidePawn: for debugging
//
//------------------------------------------------------------------
function ServerSuicidePawn(byte bSuicidedType) {}
function ServerSwitchReloadingWeapon(bool NewValue) {}
// climbladder has been requested...
function PotentialClimbLadder(LadderVolume L) {}
function PotentialClimbableObject(R6ClimbableObject obj) {}
simulated function FaceRotation(Rotator NewRotation, float DeltaTime) {}
simulated function UpdateVisualEffects(float fDeltaTime) {}
event EndClimbLadder(LadderVolume OldLadder) {}
//============================================================================
// event StopAnimForRG -
//============================================================================
simulated event StopAnimForRG() {}
//============================================================================
// KImpact -
//============================================================================
event KImpact(Vector pos, Vector impactNorm, Vector impactVel, Actor Other) {}
//===================================================================================================
// R6ResetAnimBlendParams()
//   reset the blend parameters for a specific channel
//===================================================================================================
simulated function R6ResetAnimBlendParams(int iBlendChannel) {}
//============================================================================
// SetNextPendingAction -
//============================================================================
function SetNextPendingAction(EPendingAction eAction, optional int i) {}
delegate ServerForceKillResult(int iKillResult) {}
//------------------------------------------------------------------
// SetPeekingInfo: set peeking info
//
//------------------------------------------------------------------
simulated event SetPeekingInfo(float fPeeking, optional bool bPeekLeft, ePeekingMode eMode) {}
delegate ServerForceStunResult(int iStunResult) {}
//------------------------------------------------------------------
// EndPeekingMode: end the peeking mode but have to return to the center
//
//------------------------------------------------------------------
simulated event EndPeekingMode(ePeekingMode eMode) {}
//===================================================================================================
// AvoidLedges()
//   rbrek 09 feb 2002
//   use to set or reset the desireability to avoid ledges... (now that it is possible to walk off a
//   ledges, it is easy for NPCs to fall off inadvertantly.
//===================================================================================================
function AvoidLedges(bool bAvoid) {}
//------------------------------------------------------------------
// AttachCollisionBox
//  iNbOfColBox
//------------------------------------------------------------------
simulated function AttachCollisionBox(int iNbOfColBox) {}
simulated function R6EngineWeapon GetWeaponInGroup(int iGroup) {}
// ^ NEW IN 1.60
function ServerSetRoundTime(int iTime) {}
function ServerSetBetTime(int iTime) {}
function ServerPerformDoorAction(R6IORotatingDoor whichDoor, int iActionID) {}
function bool IsTouching(R6Door Door) {}
// ^ NEW IN 1.60
function CreateBulletManager() {}
function ServerClimbLadder(LadderVolume L, R6Ladder Ladder) {}
function CheckForHelmet(Vector vBulletDirection) {}
simulated function float PrepareDemolitionsAnimation() {}
// ^ NEW IN 1.60
//============================================================================
// function R6ClientAffectedByFlashbang -
//============================================================================
function R6ClientAffectedByFlashbang(Vector vGrenadeLocation) {}
//Notify Function
// will always close the bipod at the beginning of an animation
simulated function WeaponBipod() {}
simulated function PlayBreachDoorAnimation() {}
//============================================================================
// ServerChangedWeapon -
//============================================================================
delegate ServerChangedWeapon(R6EngineWeapon OldWeapon, R6EngineWeapon W) {}
//============================================================================
// SetRandomWaiting -
//============================================================================
function SetRandomWaiting(int iMax, optional bool bDontUseWaitZero) {}
//===================================================================================================
// PlayCrouchedDoorAnim()
//===================================================================================================
simulated function PlayCrouchedDoorAnim(R6IORotatingDoor Door) {}
//------------------------------------------------------------------
// StartFullPeeking: init var for peeking
//
//------------------------------------------------------------------
simulated event StartFullPeeking() {}
//===================================================================================================
// rbrek 12 nov 2001
// PlayRootMotionAnimation()
//   used to play an uncompressed animation using Root Motion
//===================================================================================================
simulated function PlayRootMotionAnimation(optional float fRate, name animName) {}
//===================================================================================================
// R6PlayAnim()
//   can be used instead of calling LoopAnim directly, so that tweening is done automatically
//   if the requested animation differs from the current one
//===================================================================================================
simulated function R6PlayAnim(optional float fTween, optional float fRate, name animName) {}
//===================================================================================================
// R6LoopAnim()
//   can be used instead of calling LoopAnim directly, so that tweening is done automatically
//   if the requested animation differs from the current one
//===================================================================================================
simulated function R6LoopAnim(optional float fTween, optional float fRate, name animName) {}
//------------------------------------------------------------------
// InitBiPodPosture: called when going prone/unprone, selecting/unselecting
//  a weapon
//------------------------------------------------------------------
simulated event InitBiPodPosture(bool bEnable) {}
function PlayLocalWeaponSound(EWeaponSound EWeaponSound) {}
// Server call this function
function PlayWeaponSound(EWeaponSound EWeaponSound) {}
function float SkillModifier() {}
// ^ NEW IN 1.60
simulated function RotateBone(optional float InTime, int Roll, int Yaw, int Pitch, name BoneName) {}
//===================================================================================================
// R6BlendAnim()
//===================================================================================================
simulated function R6BlendAnim(optional float fTween, optional float fRate, int iBlendChannel, name animName, optional bool bPlayOnce, optional name BoneName, float fBlendAlpha) {}
simulated function InitBackwardAnims() {}
//------------------------------------------------------------------
// ServerToggleCollision: for debugging and not safe
//
//------------------------------------------------------------------
function ServerToggleCollision() {}
function bool PawnHaveFinishedRotation() {}
// ^ NEW IN 1.60
//===================================================================================================
// RemovePotentialOpenDoor()
//===================================================================================================
event RemovePotentialOpenDoor(R6Door Door) {}
function eBodyPart WhichBodyPartWasHit(Vector vBulletDirection, Vector vHitLocation) {}
// ^ NEW IN 1.60
// this function should only be entered server side
function IncrementFragCount() {}
exec function ToggleGadget() {}
// Will always open the bipod at the end of an animation
simulated function WeaponBipodLast() {}
simulated function PlayClaymoreAnimation() {}
simulated function PlayRemoteChargeAnimation() {}
simulated function AttachWeapon(R6EngineWeapon WeaponToAttach, name Attachment) {}
//------------------------------------------------------------------
// SetFriendlyFire
//  - called by controller posses fn
//------------------------------------------------------------------
function SetFriendlyFire() {}
//------------------------------------------------------------------
// Update bipod posture only if using one and not moving
//
//------------------------------------------------------------------
simulated event UpdateBipodPosture() {}
//------------------------------------------------------------------
// logX - Log with more information for debugging.  Display:
//          controller, source, controller state, pawn state and a string
//------------------------------------------------------------------
simulated function logX(string szText) {}
simulated function DestroyShadow() {}
// ^ NEW IN 1.60
function Vector GetGrenadeStartLocation(eGrenadeThrow eThrow) {}
// ^ NEW IN 1.60
event TornOff() {}
function PlayerController GetHumanLeaderForAIPawn() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// IsFullPeekingOver: return true if full peeking is over
//
//------------------------------------------------------------------
simulated event bool IsFullPeekingOver() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// PlayPeekingAnim
//
//------------------------------------------------------------------
simulated event PlayPeekingAnim(optional bool bUseSpecialPeekAnim) {}
//===================================================================================================
// ClimbLadder()
//===================================================================================================
function ClimbLadder(LadderVolume L) {}
//===================================================================================================
// LocateLadderActor()
//    determine which ladder actor this pawn is closest to
//    (top or bottom)
//===================================================================================================
function Ladder LocateLadderActor(LadderVolume L) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// Landed: when the pawn land on the floor
//
//------------------------------------------------------------------
event Landed(Vector HitNormal) {}
//============================================================================
// R6Surrender
//      Called only on the server
//============================================================================
function R6Surrender(Pawn Killer, Vector vMomentum, eBodyPart eHitPart) {}
//===================================================================================================
// rbrek - 13 feb 2002
// AdjustPawnForDiagonalStrafing()
//===================================================================================================
simulated event AdjustPawnForDiagonalStrafing() {}
//===================================================================================================
// rbrek - 15 oct 2001
// TurnToFaceActor()
//===================================================================================================
event TurnToFaceActor(Actor Target) {}
//R6BLOOD
simulated event R6DeadEndedMoving() {}
//============================================================================
// function PlayProneFireAnimation -
//============================================================================
simulated function PlayProneFireAnimation() {}
//============================================================================
// R6Died
//      Called only on the server
//============================================================================
function R6Died(Pawn Killer, Vector vMomentum, eBodyPart eHitPart) {}
//===================================================================================================
// PotentialOpenDoor()
//===================================================================================================
event PotentialOpenDoor(R6Door Door) {}
function eBodyPart GetBodyPartFromBoneID(byte iBone, Vector vBulletDirection) {}
// ^ NEW IN 1.60
simulated function PlayInteractWithDeviceAnimation() {}
//============================================================================
//                  ##
//  #####   ##  #        ####   ####   #####
//  ##      ## #    ##    ##     ##    ##
//  ####    ###     ##    ##     ##    ####
//     ##   ## #    ##    ##     ##       ##
//  ####    ##  #   ##   ####   ####   ####
//============================================================================
event float GetSkill(ESkills eSkillName) {}
// ^ NEW IN 1.60
//===================================================================================================
// R6CalcDrawLocation()
// rbrek 23 nov 2001
// obtains the true location of the eyes based on the location of the 'R6 PonyTail1' bone.
// uses the same information that the 1st person camera uses.
//===================================================================================================
simulated function Vector R6CalcDrawLocation(Vector offset, out Rotator MoveRotation, R6EngineWeapon Wep) {}
// ^ NEW IN 1.60
//============================================================================
// SpawnRagDoll -
//============================================================================
simulated event SpawnRagDoll() {}
//===================================================================================================
simulated function AnimateClimbing() {}
//------------------------------------------------------------------
// R6JumpOffPawn
//	jump off something: good velocity + not to high
//------------------------------------------------------------------
function R6JumpOffPawn() {}
simulated function ActionRequest(R6CircumstantialActionQuery actionRequested) {}
//===================================================================================================
// UpdateFluidPeeking()
//  -- for player pawn only --
//  blending between upright movement and crouched running animations
//===================================================================================================
simulated event PlayFluidPeekingAnim(float fLeftPct, float fForwardPct, float fDeltaTime) {}
static function string BuildDeathMessage(byte bDeathMsgType, string Killer, string killed) {}
// ^ NEW IN 1.60
// PLAYERPAWN - request to perform an action has been recieved from PlayerController...
function ServerActionRequest(R6CircumstantialActionQuery actionRequested) {}
function ServerGod(string szPlayerName, bool bIsGod, bool bForTerro, bool bForHostage, bool bUpdateTeam) {}
simulated event ZoneChange(ZoneInfo NewZone) {}
function ServerGivesWeaponToClient(int iWeaponOrItemSlot, string aClassName, optional string bulletType, optional string weaponGadget) {}
//------------------------------------------------------------------
// GetPeekAnimName
//
//------------------------------------------------------------------
simulated function name GetPeekAnimName(float fPeeking, bool bPeekingLeft) {}
// ^ NEW IN 1.60
// -----------  MissionPack1
// MPF1
function int R6TakeDamageCTE(Pawn instigatedBy, Vector vMomentum, int iKillValue, int iStunValue, Vector vHitLocation, int iBulletToArmorModifier, optional int iBulletGoup) {}
// ^ NEW IN 1.60
//===================================================================================================
// SetFree()
//===================================================================================================
function SetFree() {}
function ClientSetFree() {}
//===================================================================================================
// Arrested()
//===================================================================================================
function Arrested() {}
function Surrender() {}
function ClientSurrender() {}
// MPF_Milan_9_23_2003 - uncommented
function ServerSurrender() {}
//============================================================================
// FellOutOfWorld -
//============================================================================
event FellOutOfWorld() {}
// Stop sound when the ragdoll is spawn. Done on the client side.
simulated function StopWeaponSound() {}
// Play sound because no animation here just interpolation
simulated function StandToCrouch() {}
// Play sound because no animation here just interpolation
simulated function CrouchToStand() {}
//------------------------------------------------------------------
// LeftExtractionZone
//------------------------------------------------------------------
function LeftExtractionZone(R6AbstractExtractionZone Zone) {}
//------------------------------------------------------------------
// CanPeek(): return true if the pawn can peek
//
//------------------------------------------------------------------
function bool CanPeek() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// ResetBipodPosture: reset basic bipod posture info
//
//------------------------------------------------------------------
simulated event ResetBipodPosture() {}
//============================================================================
// DropWeaponToGround -
//============================================================================
simulated function DropWeaponToGround() {}
function float GetStanceJumpModifier() {}
// ^ NEW IN 1.60
event float GetStanceReticuleModifier() {}
// ^ NEW IN 1.60
//===================================================================================================
// IsStationary
//   21 jan 2002 rbrek - check only acceleration.  velocity is only set to (0,0,0) a few ticks later...
//===================================================================================================
function bool IsStationary() {}
// ^ NEW IN 1.60
// Notify function for Surface. Can be call for other notify also.
simulated event PlaySurfaceSwitch() {}
// Notify function for footsteps
simulated function FootStepLeft() {}
// Notify function for footsteps
simulated function FootStepRight() {}
// Notify function for Hands on ladder
simulated function HandGripLadder() {}
// Notify function for foot on ladder
simulated function FootStepLadder() {}
// Notify called to attach the magazine to the weapon once reload is over
simulated function AttachClipToWeapon() {}
//Notify called by the animations ro attach the weapon to the left hand for reloading.
simulated function GetClipInHand() {}
simulated function PutShellInWeapon() {}
function ServerPlayReloadAnimAgain() {}
//Notify function
simulated function ReloadingWeaponEnd() {}
///////////////////
// RELOAD WEAPON //
///////////////////
function ReloadWeapon() {}
function ToggleScopeVision() {}
function ToggleHeatVision() {}
//===================================================================================================
// rbrek - 3 oct 2001
// function R6ResetLookDirection()
//   Reset the bone rotations that have be imposed.
//===================================================================================================
simulated event R6ResetLookDirection() {}
simulated event ResetDiagonalStrafing() {}
///////////////////////////////////////////////////////////////////////////////////////
// GunShouldFollowHead()
// rbrek - 11 april 2002
///////////////////////////////////////////////////////////////////////////////////////
simulated function bool GunShouldFollowHead() {}
// ^ NEW IN 1.60
simulated function bool IsUsingHeartBeatSensor() {}
// ^ NEW IN 1.60
simulated function bool EndOfLadderSlide() {}
// ^ NEW IN 1.60
simulated function RemovePotentialClimbableObject(R6ClimbableObject obj) {}
function RemovePotentialClimbLadder(LadderVolume L) {}
function PlayInteraction() {}
event EndCrawl() {}
event StartCrawl() {}
//===================================================================================================
// rbrek
// EncroachedBy()
//   this function was overriden from Pawn.uc; actors were being gibbed (killed) when they were encroached
//   on by another actor who started crouching. it is left empty to prevent pawn from being 'gibbed'
//===================================================================================================
event EncroachedBy(Actor Other) {}
//============================================================================
// DetachFromClimbableObject -
//============================================================================
function DetachFromClimbableObject(R6ClimbableObject pObject) {}
//============================================================================
// AttachToClimbableObject -
//============================================================================
function AttachToClimbableObject(R6ClimbableObject pObject) {}
singular event BaseChange() {}
//===================================================================================================
// PlayLandingAnimation()
//  rbrek 3 dec 2001
//  this function is called when pawn's physics changes from PHYS_Falling to PHYS_Walking
//  called by PlayLanded() which also handles playing the appropriate sound.
//===================================================================================================
simulated event PlayLandingAnimation(float impactVel) {}
//------------------------------------------------------------------
// Falling: fired when the pawn physic switch to falling or when he
//  has to jump (not the case in ravenshield)
//------------------------------------------------------------------
event Falling() {}
//===================================================================================================
// PlayFalling()
//  rbrek 3 dec 2001
//  this function is called when a pawn first starts to fall
// 3 jan 2002 - rbrek, removed PlayInAir() (obsolete), can replace with calls to PlayFalling()
//===================================================================================================
simulated event PlayFalling() {}
simulated function AnimateStoppedOnLadder() {}
//===================================================================================================
simulated function AnimateCrouchWalkingDownStairs() {}
//===================================================================================================
simulated function AnimateCrouchWalkingUpStairs() {}
//===================================================================================================
simulated function AnimateRunningDownStairs() {}
//===================================================================================================
simulated function AnimateRunningUpStairs() {}
//===================================================================================================
simulated function AnimateProneWalking() {}
//===================================================================================================
simulated function AnimateCrouchWalking() {}
//===================================================================================================
simulated function AnimateProneTurning() {}
//===================================================================================================
simulated function AnimateCrouchTurning() {}
//===================================================================================================
// ChangeAnimation()
//===================================================================================================
simulated event ChangeAnimation() {}
//------------------------------------------------------------------
// StartFluidPeeking:
//
//------------------------------------------------------------------
simulated event StartFluidPeeking() {}
//------------------------------------------------------------------
// IsPeeking: true if peeking in mode. False when returning to center
//
//------------------------------------------------------------------
simulated function bool IsPeeking() {}
// ^ NEW IN 1.60
//===================================================================================================
// GetPeekingRate()
//  this function returns the exact rate of peeking between -1 and 1
//===================================================================================================
simulated function float GetPeekingRate() {}
// ^ NEW IN 1.60
simulated event bool IsPeekingLeft() {}
// ^ NEW IN 1.60
function bool IsValidClimber() {}
// ^ NEW IN 1.60
simulated function PlayPostEndLadder() {}
simulated function PlayPostStartLadder() {}
function StartClimbObject(R6ClimbableObject climbObj) {}
function bool IsMovingUpLadder() {}
// ^ NEW IN 1.60
function bool IsMovingForward() {}
// ^ NEW IN 1.60
function bool IsRunning() {}
// ^ NEW IN 1.60
function bool IsWalking() {}
// ^ NEW IN 1.60
function AimDown() {}
function AimUp() {}
simulated function ResetBoneRotation() {}
//============================================================================
// event rotator GetViewRotation -
//============================================================================
simulated event Rotator GetViewRotation() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// SetDefaultWalkAnim();
//
//------------------------------------------------------------------
function SetDefaultWalkAnim() {}
event Vector GetFiringStartPoint() {}
// ^ NEW IN 1.60
simulated function FirstPassReset() {}
//============================================================================
// R6MakeMovementNoise - Make a noise every X second
//============================================================================
event R6MakeMovementNoise() {}
final native function SetAudioInfo() {}
// ^ NEW IN 1.60
final native function Rotator GetRotationOffset() {}
// ^ NEW IN 1.60
final native function Rotator R6GetViewRotation() {}
// ^ NEW IN 1.60
final native function StopLipSynch() {}
// ^ NEW IN 1.60
final native function eMovementDirection GetMovementDirection() {}
// ^ NEW IN 1.60
final native function int GetMaxRotationOffset() {}
// ^ NEW IN 1.60

state Dead
{
    event Timer() {}
//===================================================================================================
// EyePosition()
//  Returns the offset for the eye from the Pawn's location at which to place the camera or to start
//  the line of sight
// rbrek - 19 July 2001 - Originally defined in Pawn.uc.  Overridden here in order to
//   include the proper offset due to peeking and/or fluid crouching...
//===================================================================================================
    event Vector EyePosition() {}
// ^ NEW IN 1.60
    simulated function BeginState() {}
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
//                          ANIMATION FUNCTIONS COMMON TO ALL STATES
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
    function PlayWaiting() {}
//============================================================================
// event PlayWeaponAnimation -
//============================================================================
    function PlayWeaponAnimation() {}
}

defaultproperties
{
}
