//=============================================================================
// R6Pawn - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
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
class R6Pawn extends R6
    AbstractPawn
    abstract
    native;

const C_iHeartRateMaxTerrorist = 184;
const C_iHeartRateMaxOther = 182;
const C_iHeartRateMinTerrorist = 65;
const C_iHeartRateMinOther = 90;
// Animation channel assignments; each channel blends a separate animation layer onto the skeleton.
// Channels 2-11 are reserved for physics-driven animation updates.
const C_iBaseAnimChannel = 0;
const C_iBaseBlendAnimChannel = 1;
const C_iPostureAnimChannel = 12;
const C_iPeekingAnimChannel = 13;
const C_iWeaponRightAnimChannel = 14;
const C_iWeaponLeftAnimChannel = 15;
const C_iPawnSpecificChannel = 16;
const C_fPrePivotStairOffset = 5.0;
const C_fHeadRadius = 28.f;
const C_fHeadHeight = 26.f;
const C_MaxPendingAction = 5;
// Peek blend ratios: 0=full left, 1000=center, 2000=full right (separate crouch range 400-1600).
const C_fPeekLeftMax = 0.0;
const C_fPeekMiddleMax = 1000.0;
const C_fPeekRightMax = 2000.0;
const C_fPeekCrouchLeftMax = 400.0;
const C_fPeekCrouchRightMax = 1600.0;
const C_fPeekSpeedInMs = 3000.0;
const C_fPeekProneTime = 120.0;
const C_iRotationOffsetNormal = 5461;
const C_iRotationOffsetProne = 3000;
const C_iRotationOffsetBipod = 5600;
const C_NoiseTimerFrequency = 0.33f;

enum eBodyPart
{
	BP_Head,                        // 0
	BP_Chest,                       // 1
	BP_Abdomen,                     // 2
	BP_Legs,                        // 3
	BP_Arms                         // 4
};

enum eArmor
{
	ARMOR_None,                     // 0
	ARMOR_Light,                    // 1
	ARMOR_Medium,                   // 2
	ARMOR_Heavy                     // 3
};

enum EHeadAttachmentType
{
	ATTACH_Glasses,                 // 0
	ATTACH_Sunglasses,              // 1
	ATTACH_GasMask,                 // 2
	ATTACH_None                     // 3
};

enum ETerroristType
{
	TTYPE_B1T1,                     // 0
	TTYPE_B1T3,                     // 1
	TTYPE_B2T2,                     // 2
	TTYPE_B2T4,                     // 3
	TTYPE_M1T1,                     // 4
	TTYPE_M1T3,                     // 5
	TTYPE_M2T2,                     // 6
	TTYPE_M2T4,                     // 7
	TTYPE_P1T1,                     // 8
	TTYPE_P2T2,                     // 9
	TTYPE_P3T3,                     // 10
	TTYPE_P1T4,                     // 11
	TTYPE_P2T5,                     // 12
	TTYPE_P3T6,                     // 13
	TTYPE_P1T7,                     // 14
	TTYPE_P2T8,                     // 15
	TTYPE_P3T9,                     // 16
	TTYPE_P1T10,                    // 17
	TTYPE_P2T11,                    // 18
	TTYPE_P3T12,                    // 19
	TTYPE_P4T13,                    // 20
	TTYPE_D1T1,                     // 21
	TTYPE_D1T2,                     // 22
	TTYPE_GOSP,                     // 23
	TTYPE_GUTI,                     // 24
	TTYPE_S1T1,                     // 25
	TTYPE_S1T2,                     // 26
	TTYPE_TXIC,                     // 27
	TTYPE_T1T1,                     // 28
	TTYPE_T2T2,                     // 29
	TTYPE_T1T3,                     // 30
	TTYPE_T2T4                      // 31
};

enum eMovementDirection
{
	MOVEDIR_Forward,                // 0
	MOVEDIR_Backward,               // 1
	MOVEDIR_Strafe                  // 2
};

enum eMovementPace
{
	PACE_None,                      // 0
	PACE_Prone,                     // 1
	PACE_CrouchWalk,                // 2
	PACE_CrouchRun,                 // 3
	PACE_Walk,                      // 4
	PACE_Run                        // 5
};

enum EPendingAction
{
	PENDING_None,                   // 0
	PENDING_Coughing,               // 1
	PENDING_StopCoughing,           // 2
	PENDING_Blinded,                // 3
	PENDING_OpenDoor,               // 4
	PENDING_StartClimbingLadder,    // 5
	PENDING_PostStartClimbingLadder,// 6
	PENDING_EndClimbingLadder,      // 7
	PENDING_PostEndClimbingLadder,  // 8
	PENDING_DropWeapon,             // 9
	PENDING_ProneToCrouch,          // 10
	PENDING_CrouchToProne,          // 11
	PENDING_MoveHitBone,            // 12
	PENDING_StartClimbingObject,    // 13
	PENDING_PostStartClimbingObject,// 14
	PENDING_SetRemoteCharge,        // 15
	PENDING_SetBreachingCharge,     // 16
	PENDING_SetClaymore,            // 17
	PENDING_InteractWithDevice,     // 18
	PENDING_LockPickDoor,           // 19
	PENDING_ComFollowMe,            // 20
	PENDING_ComCover,               // 21
	PENDING_ComGo,                  // 22
	PENDING_ComRegroup,             // 23
	PENDING_ComHold,                // 24
	PENDING_ActivateNightVision,    // 25
	PENDING_DeactivateNightVision,  // 26
	PENDING_SecureWeapon,           // 27
	PENDING_EquipWeapon,            // 28
	PENDING_SecureTerrorist,        // 29
	PENDING_ThrowGrenade,           // 30
	PENDING_Surrender,              // 31
	PENDING_Kneeling,               // 32
	PENDING_Arrest,                 // 33
	PENDING_CallBackup,             // 34
	PENDING_SpecialAnim,            // 35
	PENDING_LoopSpecialAnim,        // 36
	PENDING_StopSpecialAnim,        // 37
	PENDING_HostageAnim,            // 38
	PENDING_EndSurrender,           // 39
	PENDING_StartSurrender,         // 40
	PENDING_PostEndSurrender,       // 41
	PENDING_SetFree,                // 42
	PENDING_ArrestKneel,            // 43
	PENDING_ArrestWaiting,          // 44
	PENDING_EndArrest,              // 45
	PENDING_Custom                  // 46
};

enum eHands
{
	HANDS_None,                     // 0
	HANDS_Right,                    // 1
	HANDS_Left,                     // 2
	HANDS_Both                      // 3
};

enum eDeviceAnimToPlay
{
	BA_ArmBomb,                     // 0
	BA_DisarmBomb,                  // 1
	BA_Keypad,                      // 2
	BA_PlantDevice,                 // 3
	BA_Keyboard,                    // 4
	BA_Custom                       // 5
};

enum EHostagePersonality
{
	HPERSO_Coward,                  // 0
	HPERSO_Normal,                  // 1
	HPERSO_Brave,                   // 2
	HPERSO_Bait,                    // 3
	HPERSO_None                     // 4
};

enum eStrafeDirection
{
	STRAFE_None,                    // 0
	STRAFE_ForwardRight,            // 1
	STRAFE_ForwardLeft,             // 2
	STRAFE_BackwardRight,           // 3
	STRAFE_BackwardLeft             // 4
};

struct STWeaponAnim
{
	var name nAnimToPlay;
	var name nBlendName;
	var float fTweenTime;
	var float fRate;
	var bool bPlayOnce;
	var bool bBackward;
};

var R6Pawn.eMovementPace m_eMovementPace;
// NEW IN 1.60
var R6Pawn.EPendingAction m_ePendingAction[5];
var byte m_iNetCurrentActionIndex;
var byte m_iLocalCurrentActionIndex;
// NEW IN 1.60
var R6Pawn.eHands m_ePlayerIsUsingHands;
// NEW IN 1.60
var R6Pawn.eDeviceAnimToPlay m_eDeviceAnim;
// -- animation -- //
var R6Pawn.eHands m_eLastUsingHands;
var R6Pawn.eHands m_ePawnIsUsingHand;  // Used in Native function
var(Equip) R6Pawn.eArmor m_eArmorType;
var Pawn.ePeekingMode m_eOldPeekingMode;  // used in updatedmovementAnimation
//AK: m_bSuicided should be set to true, this will be used to punish those who suicide in deathmatch and perhaps other game modes
////
var byte m_bSuicideType;  // how did the player quit the round/match
//R6BLOOD
var R6Pawn.eBodyPart m_eLastHitPart;
// NEW IN 1.60
var R6Pawn.eStrafeDirection m_eStrafeDirection;
// For wait animation Synch
var byte m_bRepPlayWaitAnim;
var byte m_bSavedPlayWaitAnim;
var byte m_byRemainingWaitZero;
// NEW IN 1.60
var int m_iPendingActionInt[5];
// -- identification -- //
var() int m_iID;  // this identifies the character rank within the team (for formation purposes)
var() int m_iPermanentID;  // this id stays with the character, does not change
var int m_iVisibilityTest;  // used for visibility checks; ensure that location of checks vary to improve chances of partial detection...
var int m_iForceKill;  // force kill result for testing
var int m_iForceStun;
var int m_iMaxRotationOffset;  // if prone: C_iRotationOffsetProne, otherwise C_iRotationOffsetNormal
var int m_iRepBipodRotationRatio;  // for replication m_fBipodRotation/C_iRotationOffsetBipod
var int m_iLastBipodRotation;  // last bipod rotation
//
var int m_iUniqueID;  // Each pawnthis identifies the character rank within the team (for formation purposes)
// Lipsynch data
var int m_hLipSynchData;
var int m_iDesignRandomTweak;
var int m_iDesignLightTweak;
var int m_iDesignMediumTweak;
var int m_iDesignHeavyTweak;
var bool m_bIsClimbingStairs;
var bool m_bIsMovingUpStairs;  // when m_bIsClimbingStairs is true, this var indicates whether pawn is facing up or down
var bool m_bIsClimbingLadder;
var bool m_bSlideEnd;
var bool m_bCanClimbObject;  // used by NPC: allowed to climb a ClimbableObject
var bool m_bOldCanWalkOffLedges;
// -- gadgets -- //
var bool m_bActivateHeatVision;  // Boolean to activate the heat vision and the black flag.
var bool m_bActivateNightVision;  // Boolean to determine if the night vision is on
var bool m_bActivateScopeVision;  // Boolean to determine if the scope vision is on
var bool m_bWeaponGadgetActivated;  // Boolean to activate the current gadget
var bool m_bIsKneeling;
var bool m_bIsSniping;
var bool m_bPlayingComAnimation;
var bool m_bDontKill;
var bool m_bPreviousAnimPlayOnce;
var bool m_bToggleServerCancelPlacingCharge;
var bool m_bOldServerCancelPlacingCharge;
var bool m_bReAttachToRightHand;  // When using blot action rifle and the notify that re attach to righ hand was not called.
// -- weapons -- //
var bool m_bReloadingWeapon;
var bool m_bReloadAnimLoop;  // Replicated bool to loop shotguns reload anims.
var bool m_bChangingWeapon;
var bool m_bIsFiringState;  // Wait until it false to change weapon
var bool m_bPawnIsReloading;  // Used in Native function
var bool m_bPawnIsChangingWeapon;  // Used in Native function
var bool m_bPawnReloadShotgunLoop;
var bool m_bPeekingReturnToCenter;  // when peeking is over, return to center
var bool m_bWasPeeking;
var bool m_bWasPeekingLeft;
var bool m_bAutoClimbLadders;
var bool m_bAim;
var bool m_bPostureTransition;
var bool m_bWeaponTransition;
var bool m_bPawnSpecificAnimInProgress;
var bool m_bSoundChangePosture;
var bool m_bNightVisionAnimation;
////
var bool m_bSuicided;
var bool m_bAvoidFacingWalls;
var bool m_bWallAdjustmentDone;
// Used for debug.  This pawn will not treat hearnoise and seeplayer from a human player (m_bIsPlayer == true)
// NB: ** Currently only implemented for terrorist and hostage.
var(Debug) bool m_bDontSeePlayer;
var(Debug) bool m_bDontHearPlayer;
var(Debug) bool m_bUseKarmaRagdoll;
// Death variables
var bool m_bTerroSawMeDead;  // Set to true as soon as one terrorist saw this dead body
var bool m_bInteractingWithDevice;  // For the bomb & other devices (computer, keypad, placebug)
var bool m_bCanDisarmBomb;  // For the bomb
var bool m_bCanArmBomb;  // For the bomb
var bool m_bUsingBipod;  // true when prone and the gun have a bipod
var bool m_bLeftFootDown;  // To know which foot is on the floor (use to check the surface)
//#ifdefDEBUG
var(DEBUG_Bones) bool m_bModifyBones;
var bool m_bHelmetWasHit;
// rbrek 25 oct 2001
// this flag is used to ensure that the bone rotation that is needed for diagonal movement is only
// done once when the diagonal movement begins, and once when the player returns to normal movement.
var bool m_bMovingDiagonally;
var bool m_bEngaged;
//R6ArmPatches
var bool m_bHasArmPatches;
// Friendly Fire
var bool m_bCanFireFriends;  // when a bullet touch someone, check if the friendly fire can be used
var bool m_bCanFireNeutrals;
var bool m_bDesignToggleLog;
// -- personality/skills -- //
var(Personality) float m_fSkillAssault;  // affects how fast the reticule adjusts from max inaccuracy to most accurate,
                                                            //   when using weapons without a scope.
var(Personality) float m_fSkillDemolitions;  // affects how fast this pawn can plant and disarm explosives (0->10s,50->6s,100->2s)
var(Personality) float m_fSkillElectronics;  // affects how fast this pawn can plant and disable electronic devices (same as above)
var(Personality) float m_fSkillSniper;  // affects how fast the reticule adjusts from maximum inaccuracy to most accurate
                                                            //   when using weapons with a scope activated.
var(Personality) float m_fSkillStealth;  // this influences the amount of noise this pawn makes when moving (sound radius).
                                                            //   (0->7m, 50->4m, 100->1m)
var(Personality) float m_fSkillSelfControl;  // this influences how willing this pawn is to shoot when there is a good chance of
                                                            //   missing the target. (0->60% chance of hit,50->75%,100->90%)
var(Personality) float m_fSkillLeadership;  // this affects the delay between the time when the orders are issued, and the time
                                                            //   when this member responds to the orders. (0->5s,50->3s,100->1s)
var(Personality) float m_fSkillObservation;  // affect how likely then pawn is to spot other pawn
// Speeds (Rainbow values set in R6Rainbow)
var float m_fReloadSpeedMultiplier;
var float m_fGunswitchSpeedMultiplier;
// NEW IN 1.60
var float m_fGadgetSpeedMultiplier;
// -- movement speeds -- // 
var float m_fWalkingSpeed;
var float m_fWalkingBackwardStrafeSpeed;
var float m_fRunningSpeed;
var float m_fRunningBackwardStrafeSpeed;
var float m_fCrouchedWalkingSpeed;
var float m_fCrouchedWalkingBackwardStrafeSpeed;
var float m_fCrouchedRunningSpeed;
var float m_fCrouchedRunningBackwardStrafeSpeed;
var float m_fProneSpeed;
var float m_fProneStrafeSpeed;
// peeking data
var float m_fLastValidPeeking;
var float m_fOldCrouchBlendRate;  // used in updatedmovementAnimation
var float m_fOldPeekBlendRate;  // used in updatedmovementAnimation
var float m_fPeekingGoalModifier;  // modifier of the goal (used by ai). Tween value, 1 == 100% of the goal setted
var float m_fPeekingGoal;  // value that peekingatio reaches (replication)
var float m_fPeeking;  // current ratio
var float m_fWallCheckDistance;  // distance to use when checking if wall is too close
var float m_fStunShakeTime;
//These variables are put here for network.
var float m_fWeaponJump;  // How much the weapon jumps when firing, set when changing weapon
var float m_fZoomJumpReturn;  // jump return factor when zoom
// Movement noise timer
var float m_fNoiseTimer;
// Firing start point caching
var float m_fLastFSPUpdate;
var float m_fLastVRPUpdate;
var float m_fBipodRotation;  // current bipod rotation
var float m_fTimeStartBodyFallSound;
var float m_fFiringTimer;
//R6HEARTBEAT
var float m_fHBTime;
var float m_fHBMove;
var float m_fHBWound;
var float m_fHBDefcon;
var float m_fPrePivotLastUpdate;  // when prone, we do small translation of the prepivot instead of a radical change
var float m_fLeftDirtyFootStepRemainingTime;
var float m_fRightDirtyFootStepRemainingTime;
var float m_fTimeGrenadeEffectBeforeSound;  // Use for the sound when a pawn enter a smoke grenade or tear gas
var R6AbstractBulletManager m_pBulletManager;
var R6Ladder m_Ladder;
// -- object and actor interaction -- //
var Actor m_potentialActionActor;
var R6Door m_Door;
var R6Door m_Door2;
// Action Mode
var R6ClimbableObject m_climbObject;
// Sound variable
var Sound m_sndNightVisionActivation;
var Sound m_sndNightVisionDeactivation;
var Sound m_sndCrouchToStand;
var Sound m_sndStandToCrouch;
var Sound m_sndThermalScopeActivation;
var Sound m_sndThermalScopeDeactivation;
var Sound m_sndDeathClothes;
var Sound m_sndDeathClothesStop;
var R6AbstractCorpse m_ragdoll;  // Ragdoll controling the bone when dead
var R6Pawn m_KilledBy;  // pawn who killed me
var Actor m_TrackActor;
var Actor m_FOV;
//R6Breathing
var Emitter m_BreathingEmitter;
var R6ArmPatchGlow m_ArmPatches[2];
// R6CODE
var R6TeamMemberReplicationInfo m_TeamMemberRepInfo;  // used for radar replication
var R6SoundReplicationInfo m_SoundRepInfo;  // only used for Audio replication
var name m_WeaponAnimPlaying;
// upright movement animation names
var name m_standRunForwardName;
var name m_standRunLeftName;
var name m_standRunBackName;
var name m_standRunRightName;
var name m_standWalkForwardName;
var name m_standWalkBackName;
var name m_standWalkLeftName;
var name m_standWalkRightName;
// hurt anim
var name m_hurtStandWalkLeftName;
var name m_hurtStandWalkRightName;
// turning animation names
var name m_standTurnLeftName;
var name m_standTurnRightName;
// falling animation names
var name m_standFallName;
var name m_standLandName;
var name m_crouchFallName;
var name m_crouchLandName;
// crouch movement animation names
var name m_crouchWalkForwardName;
// stair walk animation names
var name m_standStairWalkUpName;
var name m_standStairWalkUpBackName;
var name m_standStairWalkUpRightName;
var name m_standStairWalkDownName;
var name m_standStairWalkDownBackName;
var name m_standStairWalkDownRightName;
// stair run animation names
var name m_standStairRunUpName;
var name m_standStairRunUpBackName;
var name m_standStairRunUpRightName;
var name m_standStairRunDownName;
var name m_standStairRunDownBackName;
var name m_standStairRunDownRightName;
// stair crouch animation names
var name m_crouchStairWalkDownName;
var name m_crouchStairWalkDownBackName;
var name m_crouchStairWalkDownRightName;
var name m_crouchStairWalkUpName;
var name m_crouchStairWalkUpBackName;
var name m_crouchStairWalkUpRightName;
var name m_crouchStairRunUpName;
var name m_crouchStairRunDownName;
var name m_crouchDefaultAnimName;  // default name for the anim
var name m_standDefaultAnimName;
var name m_standClimb64DefaultAnimName;
var name m_standClimb96DefaultAnimName;
var Class<Actor> m_FOVClass;
// Dirty footsteps
var Class<R6FootStep> m_LeftDirtyFootStep;
var Class<R6FootStep> m_RightDirtyFootStep;
// -- movement -- //
var Vector m_vStairDirection;  // vector indicates direction towards top of stairs
// Hit variable
var Rotator m_rHitDirection;
var Rotator m_rPrevRotationOffset;  // previous rotation offset
var Vector m_vFiringStartPoint;
var Rotator m_rViewRotation;
var(DEBUG_Bones) Rotator m_rRoot;
var(DEBUG_Bones) Rotator m_rPelvis;
var(DEBUG_Bones) Rotator m_rSpine;
var(DEBUG_Bones) Rotator m_rSpine1;
var(DEBUG_Bones) Rotator m_rSpine2;
var(DEBUG_Bones) Rotator m_rNeck;
var(DEBUG_Bones) Rotator m_rHead;
var(DEBUG_Bones) Rotator m_rPonyTail1;
var(DEBUG_Bones) Rotator m_rPonyTail2;
var(DEBUG_Bones) Rotator m_rJaw;
var(DEBUG_Bones) Rotator m_rLClavicle;
var(DEBUG_Bones) Rotator m_rLUpperArm;
var(DEBUG_Bones) Rotator m_rLForeArm;
var(DEBUG_Bones) Rotator m_rLHand;
var(DEBUG_Bones) Rotator m_rLFinger0;
var(DEBUG_Bones) Rotator m_rRClavicle;
var(DEBUG_Bones) Rotator m_rRUpperArm;
var(DEBUG_Bones) Rotator m_rRForeArm;
var(DEBUG_Bones) Rotator m_rRHand;
var(DEBUG_Bones) Rotator m_rRFinger0;
var(DEBUG_Bones) Rotator m_rLThigh;
var(DEBUG_Bones) Rotator m_rLCalf;
var(DEBUG_Bones) Rotator m_rLFoot;
var(DEBUG_Bones) Rotator m_rLToe;
var(DEBUG_Bones) Rotator m_rRThigh;
var(DEBUG_Bones) Rotator m_rRCalf;
var(DEBUG_Bones) Rotator m_rRFoot;
var(DEBUG_Bones) Rotator m_rRToe;
// R6CollisionBox
var Vector m_vPrePivotProneBackup;  // when going prone, backup the value

replication
{
	// Pos:0x000
	unreliable if((int(Role) < int(ROLE_Authority)))
		ServerPerformDoorAction, ServerPlayReloadAnimAgain, 
		ServerSuicidePawn, ServerSwitchReloadingWeapon;

	// Pos:0x04E
	unreliable if((int(Role) == int(ROLE_Authority)))
		ClientSetJumpValues, R6ClientAffectedByFlashbang;

	// Pos:0x00D
	reliable if((int(Role) < int(ROLE_Authority)))
		ServerActionRequest, ServerClimbLadder, 
		ServerGivesWeaponToClient;

	// Pos:0x01A
	reliable if((int(Role) == int(ROLE_Authority)))
		m_KilledBy, m_Ladder, 
		m_SoundRepInfo, m_TeamMemberRepInfo, 
		m_bCanArmBomb, m_bCanDisarmBomb, 
		m_bCanFireFriends, m_bCanFireNeutrals, 
		m_bChangingWeapon, m_bEngaged, 
		m_bHasArmPatches, m_bInteractingWithDevice, 
		m_bIsClimbingLadder, m_bIsKneeling, 
		m_bPawnSpecificAnimInProgress, m_bReloadAnimLoop, 
		m_bReloadingWeapon, m_bRepPlayWaitAnim, 
		m_bSuicideType, m_climbObject, 
		m_eDeviceAnim, m_ePlayerIsUsingHands, 
		m_fBipodRotation, m_iForceKill, 
		m_iForceStun, m_iRepBipodRotationRatio, 
		m_potentialActionActor, m_rHitDirection;

	// Pos:0x027
	reliable if((int(Role) == int(ROLE_Authority)))
		Arrested, ClientSetFree, 
		ClientSurrender, m_ePendingAction, 
		m_iNetCurrentActionIndex, m_iPendingActionInt;

	// Pos:0x034
	reliable if(((!bNetOwner) && (int(Role) == int(ROLE_Authority))))
		m_bToggleServerCancelPlacingCharge, m_fPeekingGoal;
}

// Export UR6Pawn::execGetKillResult(FFrame&, void* const)
native(2002) final function Actor.eKillResult GetKillResult(int iKillDamage, int ePartHit, int eArmorType, int iBulletToArmorModifier, bool bHitBySilencedWeapon);

// Export UR6Pawn::execGetStunResult(FFrame&, void* const)
native(2003) final function Actor.eStunResult GetStunResult(int iStunDamage, int ePartHit, int eArmorType, int iBulletToArmorModifier, bool bHitBySilencedWeapon);

// Export UR6Pawn::execGetThroughResult(FFrame&, void* const)
native(2006) final function int GetThroughResult(int iKillDamage, int ePartHit, Vector vBulletDirection);

// Export UR6Pawn::execToggleHeatProperties(FFrame&, void* const)
native(2004) final function ToggleHeatProperties(bool bTurnItOn, Texture pMaskTexture, Texture pAddTexture);

// Export UR6Pawn::execToggleNightProperties(FFrame&, void* const)
native(2600) final function ToggleNightProperties(bool bTurnItOn, Texture pMaskTexture, Texture pAddTexture);

// Export UR6Pawn::execToggleScopeProperties(FFrame&, void* const)
native(2605) final function ToggleScopeProperties(bool bTurnItOn, Texture pMaskTexture, Texture pAddTexture);

// Export UR6Pawn::execAdjustFluidCollisionCylinder(FFrame&, void* const)
// this function is used to set the collision cylinder
native(2200) final function bool AdjustFluidCollisionCylinder(float fBlendRate, optional bool bTest);

// Export UR6Pawn::execSetPawnScale(FFrame&, void* const)
native(2212) final function SetPawnScale(float fNewScale);

// Export UR6Pawn::execCheckCylinderTranslation(FFrame&, void* const)
native(1507) final function bool CheckCylinderTranslation(Vector vStart, Vector vDest, optional Actor ignoreActor1, optional bool bIgnoreAllActor1Class);

// Export UR6Pawn::execGetPeekingRatioNorm(FFrame&, void* const)
native(1508) final function float GetPeekingRatioNorm(float fPeeking);

// Export UR6Pawn::execGetMaxRotationOffset(FFrame&, void* const)
native(1512) final function int GetMaxRotationOffset();

// Export UR6Pawn::execGetMovementDirection(FFrame&, void* const)
native(1517) final function R6Pawn.eMovementDirection GetMovementDirection();

// Export UR6Pawn::execStartLipSynch(FFrame&, void* const)
native(2611) final function StartLipSynch(Sound _hSound, Sound _hStopSound);

// Export UR6Pawn::execStopLipSynch(FFrame&, void* const)
native(1603) final function StopLipSynch();

// Export UR6Pawn::execMoveHitBone(FFrame&, void* const)
native(1846) final function MoveHitBone(Rotator rHitDirection, int iHitBone);

// Export UR6Pawn::execFootStep(FFrame&, void* const)
native(1844) final function FootStep(name nBoneName, bool bLeftFoot);

// Export UR6Pawn::execPawnLook(FFrame&, void* const)
native(2214) final function PawnLook(Rotator rLookDir, optional bool bAim, optional bool bNoBlend);

// Export UR6Pawn::execPawnLookAbsolute(FFrame&, void* const)
native(2215) final function PawnLookAbsolute(Rotator rLookDir, optional bool bAim, optional bool bNoBlend);

// Export UR6Pawn::execPawnLookAt(FFrame&, void* const)
native(2216) final function PawnLookAt(Vector vTarget, optional bool bAim, optional bool bNoBlend);

// Export UR6Pawn::execPawnTrackActor(FFrame&, void* const)
native(2217) final function PawnTrackActor(Actor Target, optional bool bAim);

// Export UR6Pawn::execUpdatePawnTrackActor(FFrame&, void* const)
native(2218) final function UpdatePawnTrackActor(optional bool bNoBlend);

// Export UR6Pawn::execR6GetViewRotation(FFrame&, void* const)
native(1841) final function Rotator R6GetViewRotation();

// Export UR6Pawn::execGetRotationOffset(FFrame&, void* const)
native(1842) final function Rotator GetRotationOffset();

// Export UR6Pawn::execPawnCanBeHurtFrom(FFrame&, void* const)
native(1845) final function bool PawnCanBeHurtFrom(Vector vLocation);

// Export UR6Pawn::execSendPlaySound(FFrame&, void* const)
native(2729) final function SendPlaySound(Sound S, Actor.ESoundSlot ID, optional bool bDoNotPlayLocallySound);

// Export UR6Pawn::execPlayVoices(FFrame&, void* const)
native(2730) final function PlayVoices(Sound sndPlayVoice, Actor.ESoundSlot eSlotUse, int iPriority, optional Actor.ESendSoundStatus eSend, optional bool bWaitToFinishSound, optional float fTime);

// Export UR6Pawn::execSetAudioInfo(FFrame&, void* const)
native(2731) final function SetAudioInfo();

simulated event ZoneChange(ZoneInfo NewZone)
{
	local int i;
	local PlayerController PC;
	local ZoneInfo WZ;

	// End:0x36
	if(((Level.m_WeatherEmitter == none) || (Level.m_WeatherEmitter.Emitters.Length == 0)))
	{
		return;
	}
	PC = PlayerController(Controller);
	// End:0x6E
	if(((PC == none) || (Viewport(PC.Player) == none)))
	{
		return;
	}
	WZ = Region.Zone;
	// End:0x160
	if(WZ.m_bAlternateEmittersActive)
	{
		i = 0;
		J0x97:

		// End:0x14F [Loop If]
		if((i < WZ.m_AlternateWeatherEmitters.Length))
		{
			// End:0x145
			if(((WZ.m_AlternateWeatherEmitters[i] != none) && (WZ.m_AlternateWeatherEmitters[i].Emitters.Length > 0)))
			{
				WZ.m_AlternateWeatherEmitters[i].Emitters[0].m_iPaused = 1;
				WZ.m_AlternateWeatherEmitters[i].Emitters[0].AllParticlesDead = false;
			}
			(i++);
			// [Loop Continue]
			goto J0x97;
		}
		WZ.m_bAlternateEmittersActive = false;
	}
	// End:0x244
	if((!NewZone.m_bAlternateEmittersActive))
	{
		i = 0;
		J0x17B:

		// End:0x233 [Loop If]
		if((i < NewZone.m_AlternateWeatherEmitters.Length))
		{
			// End:0x229
			if(((NewZone.m_AlternateWeatherEmitters[i] != none) && (NewZone.m_AlternateWeatherEmitters[i].Emitters.Length > 0)))
			{
				NewZone.m_AlternateWeatherEmitters[i].Emitters[0].m_iPaused = 0;
				NewZone.m_AlternateWeatherEmitters[i].Emitters[0].AllParticlesDead = false;
			}
			(i++);
			// [Loop Continue]
			goto J0x17B;
		}
		NewZone.m_bAlternateEmittersActive = true;
	}
	return;
}

//------------------------------------------------------------------
// ProcessBuildDeathMessage
//  return true if the build death msg can be build by "static BuildDeathMessage"
//------------------------------------------------------------------
function bool ProcessBuildDeathMessage(Pawn Killer, out string szPlayerName)
{
	szPlayerName = "";
	// End:0x29
	if((PlayerReplicationInfo != none))
	{
		szPlayerName = PlayerReplicationInfo.PlayerName;
		return true;
	}
	return false;
	return;
}

static function string BuildDeathMessage(string Killer, string killed, byte bDeathMsgType)
{
	local string DeathMessage;

	// End:0x52
	if((int(bDeathMsgType) == 1))
	{
		DeathMessage = ((killed $ " ") $ Localize("MPDeathMessages", "LeftTheGame", "R6GameInfo"));		
	}
	else
	{
		// End:0xA7
		if((int(bDeathMsgType) == 2))
		{
			DeathMessage = ((("" $ Localize("MPDeathMessages", "PenaltyTo", "R6GameInfo")) $ " ") $ Killer);			
		}
		else
		{
			// End:0xF1
			if((int(bDeathMsgType) == 5))
			{
				DeathMessage = Localize("MPDeathMessages", "HostageHasDied", "R6GameInfo");				
			}
			else
			{
				// End:0x14B
				if((int(bDeathMsgType) == 9))
				{
					DeathMessage = ((Killer $ " ") $ Localize("MPDeathMessages", "PlayerKilledByBomb", "R6GameInfo"));					
				}
				else
				{
					// End:0x1A5
					if((int(bDeathMsgType) == 7))
					{
						DeathMessage = ((Killer $ " ") $ Localize("MPDeathMessages", "TerroKilledHostage", "R6GameInfo"));						
					}
					else
					{
						// End:0x20C
						if(((int(bDeathMsgType) == 3) || (Killer == killed)))
						{
							DeathMessage = ((Killer $ " ") $ Localize("MPDeathMessages", "PlayerSuicided", "R6GameInfo"));							
						}
						else
						{
							// End:0x262
							if((int(bDeathMsgType) == 6))
							{
								DeathMessage = ((Killer $ " ") $ Localize("MPDeathMessages", "KilledAHostage", "R6GameInfo"));								
							}
							else
							{
								// End:0x2BB
								if((int(bDeathMsgType) == 8))
								{
									DeathMessage = ((Localize("MPDeathMessages", "TerroKilledPlayer", "R6GameInfo") $ " ") $ killed);									
								}
								else
								{
									// End:0x31B
									if((int(bDeathMsgType) == 12))
									{
										DeathMessage = ((Killer $ " ") $ Localize("MPDeathMessages", "KilledTheIntruder", "IronWrathGameInfo"));										
									}
									else
									{
										DeathMessage = ((((Killer $ " ") $ Localize("MPDeathMessages", "PlayerKilledPlayer", "R6GameInfo")) $ " ") $ killed);
									}
								}
							}
						}
					}
				}
			}
		}
	}
	return DeathMessage;
	return;
}

//------------------------------------------------------------------
// logX - Log with more information for debugging.  Display:
//          controller, source, controller state, pawn state and a string
//------------------------------------------------------------------
simulated function logX(string szText)
{
	local string szSource, Time;

	// End:0x23
	if((Controller != none))
	{
		Controller.logX(szText, 1);		
	}
	else
	{
		Time = string(Level.TimeSeconds);
		Time = Left(Time, (InStr(Time, ".") + 3));
		szSource = (("(", Time) $ ":P) " $ ???);
		Log((((((szSource $ string(Name)) $ " [ None |") $ string(GetStateName())) $ "] ") $ szText));
	}
	return;
}

//------------------------------------------------------------------
// logWarning: important log to catch (ie: they should not happen,
//  and the don't have bShowLog in front of them)
//------------------------------------------------------------------
simulated function logWarning(string Text)
{
	Log(" *********************************************************************************** ");
	logX((" WARNING!!! " $ Text));
	Log(" *********************************************************************************** ");
	return;
}

//============================================================================
//                  ##                            
//  #####   ##  #        ####   ####   #####   
//  ##      ## #    ##    ##     ##    ##      
//  ####    ###     ##    ##     ##    ####    
//     ##   ## #    ##    ##     ##       ##   
//  ####    ##  #   ##   ####   ####   ####    
//============================================================================
event float GetSkill(R6AbstractPawn.ESkills eSkillName)
{
	local float fSkill, fLevelMul;

	switch(eSkillName)
	{
		// End:0x1A
		case 0:
			fSkill = m_fSkillAssault;
			// End:0xA2
			break;
		// End:0x2D
		case 1:
			fSkill = m_fSkillDemolitions;
			// End:0xA2
			break;
		// End:0x40
		case 2:
			fSkill = m_fSkillElectronics;
			// End:0xA2
			break;
		// End:0x53
		case 3:
			fSkill = m_fSkillSniper;
			// End:0xA2
			break;
		// End:0x66
		case 4:
			fSkill = m_fSkillStealth;
			// End:0xA2
			break;
		// End:0x79
		case 5:
			fSkill = m_fSkillSelfControl;
			// End:0xA2
			break;
		// End:0x8C
		case 6:
			fSkill = m_fSkillLeadership;
			// End:0xA2
			break;
		// End:0x9F
		case 7:
			fSkill = m_fSkillObservation;
			// End:0xA2
			break;
		// End:0xFFFF
		default:
			break;
	}
	fLevelMul = 1.0000000;
	// End:0x103
	if((!m_bIsPlayer))
	{
		// End:0xDF
		if((int(m_ePawnType) == int(2)))
		{
			fLevelMul = Level.m_fTerroSkillMultiplier;			
		}
		else
		{
			// End:0x103
			if((int(m_ePawnType) == int(1)))
			{
				fLevelMul = Level.m_fRainbowSkillMultiplier;
			}
		}
	}
	return ((SkillModifier() * fSkill) * fLevelMul);
	return;
}

function float SkillModifier()
{
	local float fFactor;

	fFactor = 1.0000000;
	// End:0x27
	if((int(m_eHealth) == int(1)))
	{
		(fFactor *= 0.7500000);
	}
	// End:0x43
	if((int(m_eEffectiveGrenade) == int(2)))
	{
		(fFactor *= 0.7500000);
	}
	return fFactor;
	return;
}

function float ArmorSkillEffect()
{
	return 1.0000000;
	return;
}

function IncrementBulletsFired()
{
	return;
}

function ClientSetJumpValues(float fNewValue)
{
	m_fWeaponJump = fNewValue;
	m_fZoomJumpReturn = 1.0000000;
	return;
}

//------------------------------------------------------------------
// HasBumpPriority: return true if this pawn has bump priority
//  over bumpedBy. This is used when the pawn is NOT stationary so he 
//  should get out of the way
//------------------------------------------------------------------
function bool HasBumpPriority(R6Pawn bumpedBy)
{
	return true;
	return;
}

//============================================================================
// R6MakeMovementNoise - Make a noise every X second
//============================================================================
event R6MakeMovementNoise()
{
	// End:0x41
	if((R6AbstractGameInfo(Level.Game) != none))
	{
		R6AbstractGameInfo(Level.Game).GetNoiseMgr().R6MakePawnMovementNoise(self);
	}
	return;
}

//R6BLOOD
simulated event R6DeadEndedMoving()
{
	local bool bSpawnBloodBath;
	local Vector vBloodBathLocation;
	local Rotator rBloodBathRotation;
	local Vector vFloorLocation, vFloorNormal, vTraceEnd;

	bProjTarget = false;
	// End:0x181
	if((int(Level.NetMode) != int(NM_DedicatedServer)))
	{
		SendPlaySound(m_sndDeathClothesStop, 3);
		switch(m_eLastHitPart)
		{
			// End:0x59
			case 0:
				bSpawnBloodBath = true;
				vBloodBathLocation = GetBoneCoords('R6 Head', true).Origin;
				// End:0xCA
				break;
			// End:0x80
			case 1:
				bSpawnBloodBath = true;
				vBloodBathLocation = GetBoneCoords('R6 Spine2', true).Origin;
				// End:0xCA
				break;
			// End:0xA7
			case 2:
				bSpawnBloodBath = true;
				vBloodBathLocation = GetBoneCoords('R6 Spine', true).Origin;
				// End:0xCA
				break;
			// End:0xB7
			case 3:
				bSpawnBloodBath = false;
				// End:0xCA
				break;
			// End:0xC7
			case 4:
				bSpawnBloodBath = false;
				// End:0xCA
				break;
			// End:0xFFFF
			default:
				break;
		}
		// End:0x181
		if((bSpawnBloodBath == true))
		{
			rBloodBathRotation.Pitch = -16384;
			rBloodBathRotation.Yaw = 0;
			rBloodBathRotation.Roll = Rand(65535);
			vTraceEnd = (vBloodBathLocation + (Vector(rBloodBathRotation) * float(250)));
			// End:0x181
			if((Trace(vFloorLocation, vFloorNormal, vTraceEnd, vBloodBathLocation) != none))
			{
				(vFloorLocation.Z += float(4));
				Level.m_DecalManager.AddDecal(vFloorLocation, rBloodBathRotation, Texture'Inventory_t.BloodSplats.BloodBath', 3, 1, 0.0000000, 0.0000000, 50.0000000);
			}
		}
	}
	return;
}

// NEW IN 1.60
simulated function DestroyShadow()
{
	local ShadowProjector aShadowProjector;

	// End:0x76
	if((Shadow != none))
	{
		aShadowProjector = ShadowProjector(Shadow);
		// End:0x63
		if((aShadowProjector != none))
		{
			aShadowProjector.ShadowActor = none;
			// End:0x63
			if((aShadowProjector.ShadowTexture != none))
			{
				aShadowProjector.ShadowTexture.ShadowActor = none;
			}
		}
		Shadow.Destroy();
		Shadow = none;
	}
	return;
}

simulated function FirstPassReset()
{
	m_KilledBy = none;
	return;
}

simulated event Destroyed()
{
	local int iCounter;
	local Actor A;
	local R6PlayerController aPC;

	// End:0x30
	if((m_collisionBox != none))
	{
		A = m_collisionBox;
		m_collisionBox = none;
		A.Destroy();
		A = none;
	}
	// End:0x60
	if((m_collisionBox2 != none))
	{
		A = m_collisionBox2;
		m_collisionBox2 = none;
		A.Destroy();
		A = none;
	}
	aPC = R6PlayerController(Controller);
	// End:0xA9
	if(((aPC != none) && (aPC.m_TeamManager != none)))
	{
		aPC.m_TeamManager.ResetTeam();
	}
	super(Pawn).Destroyed();
	iCounter = 0;
	J0xB6:

	// End:0xFC [Loop If]
	if((iCounter < 4))
	{
		// End:0xF2
		if((m_WeaponsCarried[iCounter] != none))
		{
			m_WeaponsCarried[iCounter].Destroy();
			m_WeaponsCarried[iCounter] = none;
		}
		(iCounter++);
		// [Loop Continue]
		goto J0xB6;
	}
	iCounter = 0;
	J0x103:

	// End:0x149 [Loop If]
	if((iCounter < 2))
	{
		// End:0x13F
		if((m_ArmPatches[iCounter] != none))
		{
			m_ArmPatches[iCounter].Destroy();
			m_ArmPatches[iCounter] = none;
		}
		(iCounter++);
		// [Loop Continue]
		goto J0x103;
	}
	// End:0x167
	if((m_SoundRepInfo != none))
	{
		m_SoundRepInfo.Destroy();
		m_SoundRepInfo = none;
	}
	// End:0x185
	if((EngineWeapon != none))
	{
		EngineWeapon.Destroy();
		EngineWeapon = none;
	}
	// End:0x1A3
	if((m_pBulletManager != none))
	{
		m_pBulletManager.Destroy();
		m_pBulletManager = none;
	}
	// End:0x1C1
	if((m_TeamMemberRepInfo != none))
	{
		m_TeamMemberRepInfo.Destroy();
		m_TeamMemberRepInfo = none;
	}
	// End:0x236
	if((m_BreathingEmitter != none))
	{
		// End:0x218
		if((m_BreathingEmitter.Emitters.Length != 0))
		{
			m_BreathingEmitter.Emitters[0].AllParticlesDead = false;
			m_BreathingEmitter.Emitters[0].m_iPaused = 1;
		}
		DetachFromBone(m_BreathingEmitter);
		m_BreathingEmitter.Destroy();
		m_BreathingEmitter = none;
	}
	// End:0x26B
	foreach AllActors(Class'Engine.Actor', A)
	{
		// End:0x26A
		if((A.Instigator == self))
		{
			A.Instigator = none;
		}		
	}	
	return;
}

function Rotator GetFiringRotation()
{
	return GetViewRotation();
	return;
}

function Vector GetHandLocation()
{
	return GetBoneCoords('R6 R Hand').Origin;
	return;
}

event Vector GetFiringStartPoint()
{
	// End:0x3F
	if((m_fLastFSPUpdate != Level.TimeSeconds))
	{
		m_fLastFSPUpdate = Level.TimeSeconds;
		m_vFiringStartPoint = (Location + EyePosition());
	}
	return m_vFiringStartPoint;
	return;
}

function Vector GetGrenadeStartLocation(Pawn.eGrenadeThrow eThrow)
{
	local Vector vStart;

	vStart = (Location + EyePosition());
	// End:0x9B
	if((((int(eThrow) == int(4)) || (int(eThrow) == int(5))) || (int(eThrow) == int(2))))
	{
		// End:0x67
		if(m_bIsProne)
		{
			(vStart -= vect(0.0000000, 0.0000000, 10.0000000));			
		}
		else
		{
			// End:0x87
			if(bIsCrouched)
			{
				(vStart -= vect(0.0000000, 0.0000000, 30.0000000));				
			}
			else
			{
				(vStart -= vect(0.0000000, 0.0000000, 40.0000000));
			}
		}
	}
	return vStart;
	return;
}

function RenderGunDirection(Canvas C)
{
	C.Draw3DLine(GetFiringStartPoint(), (GetFiringStartPoint() + (Vector(GetFiringRotation()) * float(10000))), Class'Engine.Canvas'.static.MakeColor(byte(255), 0, 0));
	return;
}

function DrawViewRotation(Canvas C)
{
	C.Draw3DLine((Location + EyePosition()), ((Location + EyePosition()) + (float(70) * Vector(GetViewRotation()))), Class'Engine.Canvas'.static.MakeColor(byte(255), 0, 0));
	return;
}

simulated function FaceRotation(Rotator NewRotation, float DeltaTime)
{
	// End:0x68
	if((int(Physics) == int(11)))
	{
		// End:0x38
		if((OnLadder != none))
		{
			SetRotation(OnLadder.LadderList.Rotation);			
		}
		else
		{
			// End:0x65
			if((int(Level.NetMode) != int(NM_Standalone)))
			{
				m_bPostureTransition = false;
				R6ResetAnimBlendParams(1);
				SetPhysics(1);
			}
		}		
	}
	else
	{
		// End:0xA8
		if((((int(Physics) == int(1)) || (int(Physics) == int(2))) || (int(Physics) == int(12))))
		{
			NewRotation.Pitch = 0;
		}
		SetRotation(NewRotation);
	}
	return;
}

//===================================================================================================
// function PossessedBy()                                               
//===================================================================================================
function PossessedBy(Controller C)
{
	super(Pawn).PossessedBy(C);
	// End:0x31
	if(Controller.IsA('PlayerController'))
	{
		m_bIsPlayer = true;
		AvoidLedges(false);		
	}
	else
	{
		AvoidLedges(true);
	}
	// End:0x60
	if((m_SoundRepInfo != none))
	{
		m_SoundRepInfo.m_PawnRepInfo = Controller.m_PawnRepInfo;
	}
	Controller.FocalPoint = (Location + Vector(Rotation));
	return;
}

//------------------------------------------------------------------
// SetDefaultWalkAnim();
//  
//------------------------------------------------------------------
function SetDefaultWalkAnim()
{
	m_standWalkForwardName = default.m_standWalkForwardName;
	m_standWalkBackName = default.m_standWalkBackName;
	m_standWalkLeftName = default.m_standWalkLeftName;
	m_standWalkRightName = default.m_standWalkRightName;
	m_standTurnLeftName = default.m_standTurnLeftName;
	m_standTurnRightName = default.m_standTurnRightName;
	m_standRunForwardName = default.m_standRunForwardName;
	m_standRunLeftName = default.m_standRunLeftName;
	m_standRunBackName = default.m_standRunBackName;
	m_standRunRightName = default.m_standRunRightName;
	m_standDefaultAnimName = default.m_standDefaultAnimName;
	m_standClimb64DefaultAnimName = default.m_standClimb64DefaultAnimName;
	m_standClimb96DefaultAnimName = default.m_standClimb96DefaultAnimName;
	m_standStairWalkUpName = default.m_standStairWalkUpName;
	m_standStairWalkDownName = default.m_standStairWalkDownName;
	return;
}

//===================================================================================================
// function PostNetBeginPlay()
//===================================================================================================
simulated event PostNetBeginPlay()
{
	super(Pawn).PostNetBeginPlay();
	// End:0x2F
	if((int(Level.NetMode) != int(NM_Client)))
	{
		m_iLocalCurrentActionIndex = 0;
		m_iNetCurrentActionIndex = 0;
	}
	// End:0x3C
	if((Controller == none))
	{
		return;
	}
	// End:0x97
	if(((Controller.IsA('PlayerController') && (PlayerController(Controller).Player != none)) && PlayerController(Controller).Player.IsA('Viewport')))
	{
		m_bIsPlayer = true;
	}
	return;
}

simulated event PostBeginPlay()
{
	local int iCounter;
	local R6GameOptions GameOptions;

	GameOptions = GetGameOptions();
	super(Pawn).PostBeginPlay();
	// End:0xA8
	if((int(Role) == int(ROLE_Authority)))
	{
		R6AbstractGameInfo(Level.Game).SetPawnTeamFriendlies(self);
		// End:0x56
		if((m_SoundRepInfo == none))
		{
			m_SoundRepInfo = Spawn(Class'R6Engine.R6SoundReplicationInfo');
		}
		m_SoundRepInfo.m_pawnOwner = self;
		m_SoundRepInfo.m_NewWeaponSound = 1;
		m_fHeartBeatTime[0] = float(Rand(int((float(1000) / (m_fHeartBeatFrequency / float(60))))));
		m_fHeartBeatTime[1] = m_fHeartBeatTime[0];
	}
	// End:0x374
	if((int(Level.NetMode) != int(NM_DedicatedServer)))
	{
		// End:0x180
		if(m_bHasArmPatches)
		{
			// End:0xE7
			if((m_ArmPatches[0] == none))
			{
				m_ArmPatches[0] = Spawn(Class'R6Engine.R6ArmPatchGlow');
			}
			m_ArmPatches[0].m_pOwnerNightVision = self;
			m_ArmPatches[0].m_AttachedBoneName = 'R6 L UpperArm';
			m_ArmPatches[0].m_fMatrixMul = 1.0000000;
			// End:0x142
			if((m_ArmPatches[1] == none))
			{
				m_ArmPatches[1] = Spawn(Class'R6Engine.R6ArmPatchGlow');
			}
			m_ArmPatches[1].m_pOwnerNightVision = self;
			m_ArmPatches[1].m_AttachedBoneName = 'R6 R UpperArm';
			m_ArmPatches[1].m_fMatrixMul = -1.0000000;
		}
		// End:0x1EF
		if(((Level.m_BreathingEmitterClass != none) && (m_BreathingEmitter == none)))
		{
			m_BreathingEmitter = Spawn(Level.m_BreathingEmitterClass);
			// End:0x1EF
			if((m_BreathingEmitter != none))
			{
				AttachToBone(m_BreathingEmitter, 'R6 Head');
				m_BreathingEmitter.SetRelativeLocation(vect(0.0000000, -20.0000000, 0.0000000));
			}
		}
		// End:0x2D5
		if((Class'Engine.Actor'.static.IsVideoHardwareAtLeast64M() && ((((int(m_ePawnType) == int(1)) && (int(GameOptions.RainbowsShadowLevel) == int(3))) || ((int(m_ePawnType) == int(3)) && (int(GameOptions.HostagesShadowLevel) == int(3)))) || ((int(m_ePawnType) == int(2)) && (int(GameOptions.TerrosShadowLevel) == int(3))))))
		{
			// End:0x2D2
			if((Shadow == none))
			{
				Shadow = Spawn(Class'Engine.ShadowProjector', self, 'None', Location);
				ShadowProjector(Shadow).ShadowActor = self;
				ShadowProjector(Shadow).UpdateShadow();
			}			
		}
		else
		{
			// End:0x374
			if(((((int(m_ePawnType) == int(1)) && (int(GameOptions.RainbowsShadowLevel) != int(0))) || ((int(m_ePawnType) == int(3)) && (int(GameOptions.HostagesShadowLevel) != int(0)))) || ((int(m_ePawnType) == int(2)) && (int(GameOptions.TerrosShadowLevel) != int(0)))))
			{
				// End:0x374
				if((Shadow == none))
				{
					Shadow = Spawn(Class'R6Engine.R6ShadowProjector', self);
				}
			}
		}
	}
	m_iMaxRotationOffset = GetMaxRotationOffset();
	R6BlendAnim(m_standDefaultAnimName, 13, 0.0000000, 'R6 Spine', 0.0000000, 0.0000000, true);
	m_vEyeLocation = Location;
	(m_vEyeLocation.Z += float(70));
	return;
}

event TornOff()
{
	local int i;

	DropWeaponToGround();
	i = 0;
	J0x0D:

	// End:0x4A [Loop If]
	if((i < 4))
	{
		// End:0x40
		if((m_WeaponsCarried[i] != none))
		{
			m_WeaponsCarried[i].SetTearOff(true);
		}
		(i++);
		// [Loop Continue]
		goto J0x0D;
	}
	return;
}

simulated function UpdateVisualEffects(float fDeltaTime)
{
	// End:0x57
	if((m_BreathingEmitter != none))
	{
		m_BreathingEmitter.Emitters[0].AllParticlesDead = false;
		m_BreathingEmitter.Emitters[0].m_iPaused = int(Region.Zone.m_bInDoor);
	}
	// End:0x8F
	if((m_LeftDirtyFootStep != none))
	{
		(m_fLeftDirtyFootStepRemainingTime -= fDeltaTime);
		// End:0x8F
		if((m_fLeftDirtyFootStepRemainingTime <= 0.0000000))
		{
			m_LeftDirtyFootStep = none;
			m_fLeftDirtyFootStepRemainingTime = 0.0000000;
		}
	}
	// End:0xC7
	if((m_RightDirtyFootStep != none))
	{
		(m_fRightDirtyFootStepRemainingTime -= fDeltaTime);
		// End:0xC7
		if((m_fRightDirtyFootStepRemainingTime <= 0.0000000))
		{
			m_RightDirtyFootStep = none;
			m_fRightDirtyFootStepRemainingTime = 0.0000000;
		}
	}
	return;
}

simulated function Tick(float DeltaTime)
{
	local float tempDelta, sign, fHeartBeatRateMAX, fHeartBeatRateMIN, fHeartBeatFrequency;

	super(Actor).Tick(DeltaTime);
	// End:0x3D
	if((m_fDecrementalBlurValue > float(0)))
	{
		(m_fDecrementalBlurValue -= (DeltaTime * 8.0000000));
		m_fDecrementalBlurValue = float(Max(int(m_fDecrementalBlurValue), 0));
	}
	// End:0x71
	if((int(Role) < int(ROLE_Authority)))
	{
		// End:0x71
		if((int(m_bRepPlayWaitAnim) != int(m_bSavedPlayWaitAnim)))
		{
			m_bSavedPlayWaitAnim = m_bRepPlayWaitAnim;
			PlayWaiting();
		}
	}
	// End:0x97
	if(((int(Role) == int(ROLE_Authority)) && (m_bHelmetWasHit == true)))
	{
		m_bHelmetWasHit = false;
	}
	(m_fHBTime += DeltaTime);
	// End:0x188
	if((m_fHBTime > 1.0000000))
	{
		m_fHBTime = (m_fHBTime - 1.0000000);
		// End:0xED
		if((int(m_ePawnType) == int(2)))
		{
			fHeartBeatRateMAX = 184.0000000;
			fHeartBeatRateMIN = 65.0000000;			
		}
		else
		{
			fHeartBeatRateMAX = 182.0000000;
			fHeartBeatRateMIN = 90.0000000;
		}
		fHeartBeatFrequency = (((fHeartBeatRateMIN * m_fHBMove) * m_fHBWound) * m_fHBDefcon);
		// End:0x138
		if(m_bEngaged)
		{
			(fHeartBeatFrequency *= 1.2000000);
		}
		// End:0x16F
		if((fHeartBeatFrequency > m_fHeartBeatFrequency))
		{
			(m_fHeartBeatFrequency += float(5));
			// End:0x16C
			if((m_fHeartBeatFrequency > fHeartBeatRateMAX))
			{
				m_fHeartBeatFrequency = fHeartBeatRateMAX;
			}			
		}
		else
		{
			// End:0x188
			if((fHeartBeatFrequency < m_fHeartBeatFrequency))
			{
				(m_fHeartBeatFrequency -= float(1));
			}
		}
	}
	UpdateVisualEffects(DeltaTime);
	return;
}

//============================================================================
// event rotator GetViewRotation - 
//============================================================================
simulated event Rotator GetViewRotation()
{
	return R6GetViewRotation();
	return;
}

//===================================================================================================
// rbrek - 12 nov 2001
// for NPCS (non-player pawns)
// set the m_rRotationOffset using this function; uses m_rPrevRotationOffset in order to keep track of 
// previous rotationOffset
//===================================================================================================
simulated event SetRotationOffset(int iPitch, int iYaw, int iRoll)
{
	m_fBoneRotationTransition = 0.0000000;
	m_rPrevRotationOffset = m_rRotationOffset;
	m_rRotationOffset.Pitch = iPitch;
	m_rRotationOffset.Yaw = iYaw;
	m_rRotationOffset.Roll = iRoll;
	return;
}

//===================================================================================================
// EyePosition() 
//  Returns the offset for the eye from the Pawn's location at which to place the camera or to start
//  the line of sight 
// rbrek - 19 July 2001 - Originally defined in Pawn.uc.  Overridden here in order to 
//   include the proper offset due to peeking and/or fluid crouching...
//===================================================================================================
simulated event Vector EyePosition()
{
	local Vector vEyeHeight;
	local PlayerController PC;

	// End:0x5D
	if(m_bIsPlayer)
	{
		PC = PlayerController(Controller);
		// End:0x5D
		if((((PC != none) && (!PC.bBehindView)) && (PC.ViewTarget == self)))
		{
			return (m_vEyeLocation - Location);
		}
	}
	// End:0x79
	if(bIsCrouched)
	{
		vEyeHeight.Z = 30.0000000;		
	}
	else
	{
		// End:0x95
		if(m_bIsProne)
		{
			vEyeHeight.Z = 0.0000000;			
		}
		else
		{
			// End:0xB1
			if(m_bIsKneeling)
			{
				vEyeHeight.Z = 20.0000000;				
			}
			else
			{
				vEyeHeight.Z = 70.0000000;
			}
		}
	}
	return vEyeHeight;
	return;
}

//===================================================================================================
// R6CalcDrawLocation() 
// rbrek 23 nov 2001
// obtains the true location of the eyes based on the location of the 'R6 PonyTail1' bone.  
// uses the same information that the 1st person camera uses.
//===================================================================================================
simulated function Vector R6CalcDrawLocation(R6EngineWeapon Wep, out Rotator MoveRotation, Vector offset)
{
	local Vector drawLocation, bobOffset, vAxisX, vAxisY, vAxisZ;

	drawLocation = Location;
	// End:0x61
	if(((int(Level.NetMode) == int(NM_DedicatedServer)) || ((int(Level.NetMode) == int(NM_ListenServer)) && (int(RemoteRole) == int(ROLE_AutonomousProxy)))))
	{
		(drawLocation += EyePosition());		
	}
	else
	{
		// End:0x86
		if(R6PlayerController(Controller).m_bAttachCameraToEyes)
		{
			drawLocation = m_vEyeLocation;			
		}
		else
		{
			drawLocation = (Location + EyePosition());
		}
		GetAxes(GetViewRotation(), vAxisX, vAxisY, vAxisZ);
		(drawLocation.X += (((vAxisX.X * offset.X) + (vAxisY.X * offset.Y)) + (vAxisZ.X * offset.Z)));
		(drawLocation.Y += (((vAxisX.Y * offset.X) + (vAxisY.Y * offset.Y)) + (vAxisZ.Y * offset.Z)));
		(drawLocation.Z += (((vAxisX.Z * offset.X) + (vAxisY.Z * offset.Y)) + (vAxisZ.Z * offset.Z)));
	}
	return drawLocation;
	return;
}

simulated function RotateBone(name BoneName, int Pitch, int Yaw, int Roll, optional float InTime)
{
	local Rotator rOffset;

	rOffset.Pitch = Pitch;
	rOffset.Yaw = Yaw;
	rOffset.Roll = Roll;
	SetBoneRotation(BoneName, rOffset,, 1.0000000, InTime);
	return;
}

simulated function ResetBoneRotation()
{
	SetBoneRotation('R6 PonyTail1', rot(0, 0, 0),, 1.0000000, 0.4000000);
	SetBoneRotation('R6 Head', rot(0, 0, 0),, 1.0000000, 0.4000000);
	SetBoneRotation('R6 Spine', rot(0, 0, 0),, 1.0000000, 0.4000000);
	SetBoneRotation('R6 Spine1', rot(0, 0, 0),, 1.0000000, 0.4000000);
	SetBoneRotation('R6 Neck', rot(0, 0, 0),, 1.0000000, 0.4000000);
	SetBoneRotation('R6 R Clavicle', rot(0, 0, 0),, 1.0000000, 0.4000000);
	SetBoneRotation('R6 L Clavicle', rot(0, 0, 0),, 1.0000000, 0.4000000);
	return;
}

function AimUp()
{
	ResetBoneRotation();
	SetBoneRotation('R6 Spine', rot(0, -3000, 0),, 1.0000000);
	SetBoneRotation('R6 Neck', rot(0, -4000, 0),, 1.0000000);
	return;
}

function AimDown()
{
	ResetBoneRotation();
	SetBoneRotation('R6 Spine', rot(0, 3000, 0),, 1.0000000);
	SetBoneRotation('R6 Neck', rot(0, 3000, 0),, 1.0000000);
	return;
}

function bool IsWalking()
{
	return (bIsWalking && ((((Velocity.X * Velocity.X) + (Velocity.Y * Velocity.Y)) + (Velocity.Z * Velocity.Z)) > float(1000)));
	return;
}

function bool IsRunning()
{
	return ((!bIsWalking) && ((((Velocity.X * Velocity.X) + (Velocity.Y * Velocity.Y)) + (Velocity.Z * Velocity.Z)) > float(1000)));
	return;
}

function bool IsMovingForward()
{
	// End:0x19
	if((Velocity == vect(0.0000000, 0.0000000, 0.0000000)))
	{
		return true;
	}
	// End:0x38
	if((Dot(Normal(Velocity), Vector(Rotation)) > 0.5000000))
	{
		return true;		
	}
	else
	{
		return false;
	}
	return;
}

function bool IsMovingUpLadder()
{
	// End:0x17
	if((Velocity.Z > float(0)))
	{
		return true;		
	}
	else
	{
		return false;
	}
	return;
}

simulated event AnimEnd(int iChannel)
{
	// End:0x24
	if((iChannel == 0))
	{
		// End:0x21
		if((int(Physics) != int(12)))
		{
			PlayWaiting();
		}		
	}
	else
	{
		// End:0x55
		if(((iChannel == 1) && m_bPostureTransition))
		{
			m_bSoundChangePosture = false;
			m_bIsLanding = false;
			m_bPostureTransition = false;			
		}
		else
		{
			// End:0x8A
			if(((iChannel == 14) && m_bWeaponTransition))
			{
				m_bWeaponTransition = false;
				// End:0x8A
				if((int(m_eGrenadeThrow) != int(3)))
				{
					PlayWeaponAnimation();
				}
			}
		}
	}
	return;
}

//===================================================================================================
// R6LoopAnim()
//   can be used instead of calling LoopAnim directly, so that tweening is done automatically
//   if the requested animation differs from the current one
//===================================================================================================
simulated function R6LoopAnim(name animName, optional float fRate, optional float fTween)
{
	// End:0x18
	if((fRate == float(0)))
	{
		fRate = 1.0000000;
	}
	// End:0x30
	if((fTween == float(0)))
	{
		fTween = 0.2500000;
	}
	LoopAnim(animName, fRate, fTween);
	return;
}

//===================================================================================================
// R6PlayAnim()
//   can be used instead of calling LoopAnim directly, so that tweening is done automatically
//   if the requested animation differs from the current one
//===================================================================================================
simulated function R6PlayAnim(name animName, optional float fRate, optional float fTween)
{
	// End:0x18
	if((fRate == float(0)))
	{
		fRate = 1.0000000;
	}
	// End:0x30
	if((fTween == float(0)))
	{
		fTween = 0.2500000;
	}
	PlayAnim(animName, fRate, fTween);
	return;
}

//===================================================================================================
// R6BlendAnim()
//===================================================================================================
simulated function R6BlendAnim(name animName, int iBlendChannel, float fBlendAlpha, optional name BoneName, optional float fRate, optional float fTween, optional bool bPlayOnce)
{
	// End:0x1A
	if((fRate == 0.0000000))
	{
		fRate = 1.0000000;
	}
	// End:0x34
	if((fTween == 0.0000000))
	{
		fTween = 0.2000000;
	}
	AnimBlendParams(iBlendChannel, fBlendAlpha, 0.0000000, 0.0000000, BoneName);
	// End:0x78
	if((!bPlayOnce))
	{
		LoopAnim(animName, fRate, fTween, iBlendChannel);		
	}
	else
	{
		PlayAnim(animName, fRate, fTween, iBlendChannel);
	}
	return;
}

//===================================================================================================
// R6ResetAnimBlendParams()
//   reset the blend parameters for a specific channel
//===================================================================================================
simulated function R6ResetAnimBlendParams(int iBlendChannel)
{
	AnimBlendParams(iBlendChannel, 0.0000000, 0.0000000, 0.0000000);
	ClearChannel(iBlendChannel);
	return;
}

//===================================================================================================
// rbrek 12 nov 2001
// PlayRootMotionAnimation()
//   used to play an uncompressed animation using Root Motion
//===================================================================================================
simulated function PlayRootMotionAnimation(name animName, optional float fRate)
{
	// End:0x1A
	if((fRate == 0.0000000))
	{
		fRate = 1.0000000;
	}
	m_bPostureTransition = false;
	R6ResetAnimBlendParams(1);
	PlayAnim(animName, fRate);
	SetPhysics(12);
	bCollideWorld = false;
	return;
}

//===================================================================================================
// rbrek 12 nov 2001
// PlayPostRootMotionAnimation()
//   used to reset the mode after using root motion, and to play a regular compressed animation 
//===================================================================================================
simulated function PlayPostRootMotionAnimation(name animName)
{
	m_ePlayerIsUsingHands = 0;
	bCollideWorld = true;
	SetPhysics(1);
	m_bPostureTransition = true;
	AnimBlendParams(1, 1.0000000, 0.0000000, 0.0000000);
	PlayAnim(animName, 1.4000000, 0.0000000, 1);
	return;
}

function StartClimbObject(R6ClimbableObject climbObj)
{
	return;
}

simulated function PlayPostStartLadder()
{
	m_ePlayerIsUsingHands = 3;
	bCollideWorld = true;
	SetPhysics(11);
	m_bPostureTransition = true;
	AnimBlendParams(1, 1.0000000, 0.0000000, 0.0000000);
	PlayAnim('StandLadder_nt', 1.0000000, 0.0000000, 1);
	// End:0x93
	if(m_Ladder.m_bIsTopOfLadder)
	{
		SetLocation(((m_Ladder.Location - (float(38) * Vector(m_Ladder.Rotation))) - vect(0.0000000, 0.0000000, 126.0000000)));		
	}
	else
	{
		SetLocation(((m_Ladder.Location + (float(4) * Vector(m_Ladder.Rotation))) + vect(0.0000000, 0.0000000, 100.0000000)));
	}
	return;
}

simulated function PlayPostEndLadder()
{
	m_ePlayerIsUsingHands = 3;
	// End:0x3D
	if((int(m_ePawnType) == int(3)))
	{
		SetLocation((Location + vect(0.0000000, 0.0000000, 15.0000000)));
		PlayPostRootMotionAnimation(default.m_standDefaultAnimName);		
	}
	else
	{
		PlayPostRootMotionAnimation(m_standDefaultAnimName);
	}
	return;
}

function bool IsValidClimber()
{
	// End:0x1F
	if(((!m_bIsClimbingLadder) && (int(Physics) == int(1))))
	{
		return false;
	}
	return true;
	return;
}

//------------------------------------------------------------------
// SetPeekingInfo: set peeking info 
//  
//------------------------------------------------------------------
simulated event SetPeekingInfo(Pawn.ePeekingMode eMode, float fPeeking, optional bool bPeekLeft)
{
	m_fPeekingGoal = fPeeking;
	m_ePeekingMode = eMode;
	// End:0x3C
	if((int(m_ePeekingMode) == int(2)))
	{
		m_bPeekingLeft = (fPeeking < 1000.0000000);		
	}
	else
	{
		// End:0x59
		if((int(m_ePeekingMode) != int(0)))
		{
			m_bPeekingLeft = bPeekLeft;
		}
	}
	// End:0x95
	if(((!m_bIsPlayer) && (m_fPeekingGoal != 1000.0000000)))
	{
		m_fPeekingGoal = (((1000.0000000 - m_fPeekingGoal) * m_fPeekingGoalModifier) + 1000.0000000);
	}
	return;
}

//------------------------------------------------------------------
// SetCrouchBlend
//  
//------------------------------------------------------------------
simulated event SetCrouchBlend(float fCrouchBlend)
{
	m_fCrouchBlendRate = fCrouchBlend;
	return;
}

simulated event bool IsPeekingLeft()
{
	return m_bPeekingLeft;
	return;
}

//===================================================================================================
// GetPeekingRate()
//  this function returns the exact rate of peeking between -1 and 1
//===================================================================================================
simulated function float GetPeekingRate()
{
	return GetPeekingRatioNorm(m_fPeeking);
	return;
}

//------------------------------------------------------------------
// IsPeeking: true if peeking in mode. False when returning to center
//  
//------------------------------------------------------------------
simulated function bool IsPeeking()
{
	return (int(m_ePeekingMode) != int(0));
	return;
}

//------------------------------------------------------------------
// StartFluidPeeking: 
//  
//------------------------------------------------------------------
simulated event StartFluidPeeking()
{
	m_bPeekingReturnToCenter = false;
	return;
}

//------------------------------------------------------------------
// GetPeekAnimName
//	
//------------------------------------------------------------------
simulated function name GetPeekAnimName(float fPeeking, bool bPeekingLeft)
{
	// End:0x6B
	if(m_bIsPlayer)
	{
		// End:0x52
		if(bIsCrouched)
		{
			// End:0x38
			if(bPeekingLeft)
			{
				// End:0x35
				if((fPeeking < 400.0000000))
				{
					fPeeking = 400.0000000;
				}				
			}
			else
			{
				// End:0x52
				if((fPeeking > 1600.0000000))
				{
					fPeeking = 1600.0000000;
				}
			}
		}
		fPeeking = (Abs(GetPeekingRatioNorm(fPeeking)) * float(100));		
	}
	else
	{
		fPeeking = 100.0000000;
	}
	// End:0x10C
	if(m_bPeekingLeft)
	{
		// End:0xA7
		if(((fPeeking <= float(15)) && (m_fCrouchBlendRate < 0.5000000)))
		{
			return 'None';			
		}
		else
		{
			// End:0xBE
			if((fPeeking <= float(25)))
			{
				return 'PeekLeft_nt_20';				
			}
			else
			{
				// End:0xD5
				if((fPeeking <= float(45)))
				{
					return 'PeekLeft_nt_40';					
				}
				else
				{
					// End:0xEC
					if((fPeeking <= float(65)))
					{
						return 'PeekLeft_nt_60';						
					}
					else
					{
						// End:0x103
						if((fPeeking <= float(85)))
						{
							return 'PeekLeft_nt_80';							
						}
						else
						{
							return 'PeekLeft_nt';
						}
					}
				}
			}
		}		
	}
	else
	{
		// End:0x134
		if(((fPeeking <= float(15)) && (m_fCrouchBlendRate < 0.5000000)))
		{
			return 'None';			
		}
		else
		{
			// End:0x14B
			if((fPeeking <= float(25)))
			{
				return 'PeekRight_nt_20';				
			}
			else
			{
				// End:0x162
				if((fPeeking <= float(45)))
				{
					return 'PeekRight_nt_40';					
				}
				else
				{
					// End:0x179
					if((fPeeking <= float(65)))
					{
						return 'PeekRight_nt_60';						
					}
					else
					{
						// End:0x190
						if((fPeeking <= float(85)))
						{
							return 'PeekRight_nt_80';							
						}
						else
						{
							return 'PeekRight_nt';
						}
					}
				}
			}
		}
	}
	return;
}

//------------------------------------------------------------------
// StartFullPeeking: init var for peeking
//  
//------------------------------------------------------------------
simulated event StartFullPeeking()
{
	local name animName;

	m_bPeekingReturnToCenter = false;
	// End:0x53
	if(m_bIsProne)
	{
		// End:0x38
		if(m_bPeekingLeft)
		{
			RotateBone('R6 Spine1', 0, 2000, 10000, 0.6000000);			
		}
		else
		{
			RotateBone('R6 Spine1', 0, -2000, -6000, 0.6000000);
		}
	}
	// End:0xAE
	if(((!m_bIsPlayer) && (!m_bIsProne)))
	{
		// End:0x82
		if(m_bPeekingLeft)
		{
			animName = 'PeekLeft_nt';			
		}
		else
		{
			animName = 'PeekRight_nt';
		}
		R6BlendAnim(animName, 13, 0.3500000, 'R6 Spine', 1.0000000, 0.2000000);
	}
	return;
}

//------------------------------------------------------------------
// EndPeekingMode: end the peeking mode but have to return to the center
//  
//------------------------------------------------------------------
simulated event EndPeekingMode(Pawn.ePeekingMode eMode)
{
	// End:0x13
	if((int(eMode) == int(2)))
	{		
	}
	else
	{
		// End:0x36
		if((int(eMode) == int(1)))
		{
			RotateBone('R6 Spine1', 0, 0, 0, 0.6000000);
		}
	}
	m_bPeekingReturnToCenter = true;
	m_fPeekingGoal = 1000.0000000;
	return;
}

//------------------------------------------------------------------
// IsFullPeekingOver: return true if full peeking is over
//  
//------------------------------------------------------------------
simulated event bool IsFullPeekingOver()
{
	local float fGoal;

	// End:0x51
	if(bIsCrouched)
	{
		// End:0x26
		if((m_fPeekingGoal <= 400.0000000))
		{
			fGoal = 400.0000000;			
		}
		else
		{
			// End:0x43
			if((m_fPeekingGoal >= 1600.0000000))
			{
				fGoal = 1600.0000000;				
			}
			else
			{
				fGoal = m_fPeekingGoal;
			}
		}		
	}
	else
	{
		fGoal = m_fPeekingGoal;
	}
	return (fGoal == m_fPeeking);
	return;
}

//------------------------------------------------------------------
// PlayPeekingAnim
//  
//------------------------------------------------------------------
simulated event PlayPeekingAnim(optional bool bUseSpecialPeekAnim)
{
	local float fRatio;
	local name animName;
	local float fPeekingAdjust;

	// End:0x0D
	if((!m_bIsPlayer))
	{
		return;
	}
	// End:0xE1
	if(((!m_bPostureTransition) && (!m_bIsProne)))
	{
		// End:0x6D
		if(bUseSpecialPeekAnim)
		{
			animName = GetPeekAnimName(m_fPeeking, (m_fPeeking < 1000.0000000));
			fRatio = 1.0000000;
			// End:0x6D
			if((animName == 'None'))
			{
				bUseSpecialPeekAnim = false;
			}
		}
		// End:0xB1
		if((bUseSpecialPeekAnim == false))
		{
			// End:0x96
			if((m_fPeeking < 1000.0000000))
			{
				animName = 'PeekLeft_nt';				
			}
			else
			{
				animName = 'PeekRight_nt';
			}
			fRatio = Abs(GetPeekingRatioNorm(m_fPeeking));
		}
		AnimBlendParams(13, fRatio, 0.0000000, 0.0000000, 'R6 Spine');
		LoopAnim(animName, 1.0000000, 0.0000000, 13);
	}
	return;
}

//===================================================================================================
// UpdateFluidPeeking()
//  -- for player pawn only --
//  blending between upright movement and crouched running animations
//===================================================================================================
simulated event PlayFluidPeekingAnim(float fForwardPct, float fLeftPct, float fDeltaTime)
{
	local name crouchAnim;
	local float fCrouchAnimRate, fAnimRateAdjustment;
	local name animName;
	local float fOldCrouchBlendRate, fMaxPeek;

	// End:0x0B
	if(m_bIsProne)
	{
		return;
	}
	fCrouchAnimRate = 1.0000000;
	fAnimRateAdjustment = 0.0000000;
	AnimBlendParams(2, m_fCrouchBlendRate, 0.0000000, 0.0000000);
	LoopAnim('CrouchRun_nt', 1.0000000, 0.0000000, 2);
	// End:0x17B
	if(((fForwardPct != 0.0000000) || (fLeftPct != float(0))))
	{
		// End:0x11C
		if((Abs(fForwardPct) > Abs(fLeftPct)))
		{
			// End:0xEC
			if((fForwardPct > float(0)))
			{
				// End:0xBA
				if(bIsWalking)
				{
					crouchAnim = m_crouchWalkForwardName;
					fAnimRateAdjustment = ((m_fWalkingSpeed - m_fCrouchedWalkingSpeed) / m_fCrouchedWalkingSpeed);					
				}
				else
				{
					crouchAnim = 'CrouchRunForward';
					fCrouchAnimRate = 1.5000000;
					fAnimRateAdjustment = ((m_fRunningSpeed - m_fCrouchedRunningSpeed) / m_fCrouchedRunningSpeed);
				}				
			}
			else
			{
				// End:0x103
				if(bIsWalking)
				{
					crouchAnim = 'CrouchWalkBack';					
				}
				else
				{
					crouchAnim = 'CrouchRunBack';
					fCrouchAnimRate = 1.3330000;
				}
			}			
		}
		else
		{
			// End:0x14E
			if((fLeftPct > float(0)))
			{
				// End:0x140
				if(bIsWalking)
				{
					crouchAnim = 'CrouchWalkLeft';					
				}
				else
				{
					crouchAnim = 'CrouchRunLeft';
				}				
			}
			else
			{
				// End:0x165
				if(bIsWalking)
				{
					crouchAnim = 'CrouchWalkRight';					
				}
				else
				{
					crouchAnim = 'CrouchRunRight';
				}
			}
			fCrouchAnimRate = 1.0700000;
		}
	}
	// End:0x195
	if((crouchAnim == 'None'))
	{
		crouchAnim = m_crouchWalkForwardName;
	}
	// End:0x1C1
	if((Acceleration == vect(0.0000000, 0.0000000, 0.0000000)))
	{
		AnimBlendToAlpha(12, 0.0000000, 0.3000000);		
	}
	else
	{
		AnimBlendToAlpha(12, m_fCrouchBlendRate, 0.1000000);
		LoopAnim(crouchAnim, fCrouchAnimRate, 0.0000000, 12,, true);
	}
	return;
}

//===================================================================================================
// AvoidLedges()
//   rbrek 09 feb 2002
//   use to set or reset the desireability to avoid ledges... (now that it is possible to walk off a 
//   ledges, it is easy for NPCs to fall off inadvertantly.
//===================================================================================================
function AvoidLedges(bool bAvoid)
{
	bCanWalkOffLedges = (!bAvoid);
	bAvoidLedges = bAvoid;
	return;
}

//===================================================================================================
// SetAvoidFacingWalls()
//===================================================================================================
function SetAvoidFacingWalls(bool bAvoidFacingWalls)
{
	m_bAvoidFacingWalls = bAvoidFacingWalls;
	return;
}

//===================================================================================================
// TurnAwayFromNearbyWalls()
//   rbrek 18 jan 2002
//   pick a focalpoint so that we are not facing a wall... (traces do not check for actors)
//   currently using a distance of 3m for the trace tests
//===================================================================================================
function TurnAwayFromNearbyWalls()
{
	local Rotator rViewDir;
	local Vector vViewDir, vTraceStart, vTraceEnd, vHitLocation, vHitNormal, vDir,
		vDirFarthest;

	local float fDist, fDistFarthest;

	rViewDir = GetViewRotation();
	vViewDir = Vector(rViewDir);
	vTraceStart = (Location + EyePosition());
	vTraceEnd = (vTraceStart + ((CollisionRadius + m_fWallCheckDistance) * vViewDir));
	// End:0x6C
	if((Trace(vHitLocation, vHitNormal, vTraceEnd, vTraceStart, false) == none))
	{
		return;
	}
	fDistFarthest = VSize((vHitLocation - vTraceStart));
	vDirFarthest = vViewDir;
	vViewDir = Vector((rViewDir + rot(0, 32768, 0)));
	vTraceEnd = (vTraceStart + ((CollisionRadius + m_fWallCheckDistance) * vViewDir));
	// End:0xF4
	if((Trace(vHitLocation, vHitNormal, vTraceEnd, vTraceStart, false) == none))
	{
		vDir = vViewDir;		
	}
	else
	{
		fDist = VSize((vHitLocation - vTraceStart));
		// End:0x136
		if((fDistFarthest > fDist))
		{
			fDistFarthest = VSize((vHitLocation - vTraceStart));
			vDirFarthest = vViewDir;
		}
		vViewDir = Vector((rViewDir + rot(0, 16384, 0)));
		vTraceEnd = (vTraceStart + ((CollisionRadius + m_fWallCheckDistance) * vViewDir));
		// End:0x19F
		if((Trace(vHitLocation, vHitNormal, vTraceEnd, vTraceStart, false) == none))
		{
			vDir = vViewDir;			
		}
		else
		{
			fDist = VSize((vHitLocation - vTraceStart));
			// End:0x1D8
			if((fDistFarthest > fDist))
			{
				fDistFarthest = fDist;
				vDirFarthest = vViewDir;
			}
			vViewDir = Vector((rViewDir - rot(0, 16384, 0)));
			vTraceEnd = (vTraceStart + ((CollisionRadius + m_fWallCheckDistance) * vViewDir));
			// End:0x241
			if((Trace(vHitLocation, vHitNormal, vTraceEnd, vTraceStart, false) == none))
			{
				vDir = vViewDir;				
			}
			else
			{
				fDist = VSize((vHitLocation - vTraceStart));
				// End:0x26F
				if((fDistFarthest > fDist))
				{
					vDirFarthest = vViewDir;
				}
				vDir = vDirFarthest;
			}
		}
	}
	// End:0x2B6
	if((Controller != none))
	{
		Controller.Focus = none;
		Controller.FocalPoint = (Location + (float(100) * vDir));
	}
	return;
}

//===================================================================================================
// ChangeAnimation()
//===================================================================================================
simulated event ChangeAnimation()
{
	// End:0x21
	if(((Controller != none) && Controller.bControlAnimations))
	{
		return;
	}
	PlayWeaponAnimation();
	// End:0x3D
	if((int(Physics) != int(12)))
	{
		PlayWaiting();
	}
	PlayMoving();
	// End:0xAC
	if(((((((!m_bWallAdjustmentDone) && (Acceleration == vect(0.0000000, 0.0000000, 0.0000000))) && (int(Physics) == int(1))) && (!m_bIsPlayer)) && m_bAvoidFacingWalls) && (!m_bPostureTransition)))
	{
		TurnAwayFromNearbyWalls();
		m_bWallAdjustmentDone = true;
	}
	return;
}

//===================================================================================================
// PlayMoving()
//===================================================================================================
simulated function PlayMoving()
{
	// End:0x39
	if(((int(Physics) == int(0)) || ((Controller != none) && Controller.bPreparingMove)))
	{
		PlayWaiting();
		return;
	}
	m_bWallAdjustmentDone = false;
	// End:0x90
	if((m_bIsClimbingStairs && (Velocity != vect(0.0000000, 0.0000000, 0.0000000))))
	{
		// End:0x88
		if((Dot(Normal(Velocity), Normal(m_vStairDirection)) <= 0.0000000))
		{
			m_bIsMovingUpStairs = false;			
		}
		else
		{
			m_bIsMovingUpStairs = true;
		}
	}
	// End:0xA9
	if((int(Physics) == int(11)))
	{
		AnimateClimbing();		
	}
	else
	{
		// End:0xC1
		if(m_bIsProne)
		{
			AnimateProneTurning();
			AnimateProneWalking();			
		}
		else
		{
			// End:0xE9
			if(m_bIsKneeling)
			{
				TurnLeftAnim = 'KneelTurnLeft';
				TurnRightAnim = 'KneelTurnRight';
				AnimateCrouchWalking();				
			}
			else
			{
				// End:0x15B
				if(bIsCrouched)
				{
					AnimateCrouchTurning();
					// End:0x140
					if(m_bIsClimbingStairs)
					{
						// End:0x125
						if(bIsWalking)
						{
							// End:0x11C
							if(m_bIsMovingUpStairs)
							{
								AnimateCrouchWalkingUpStairs();								
							}
							else
							{
								AnimateCrouchWalkingDownStairs();
							}							
						}
						else
						{
							// End:0x137
							if(m_bIsMovingUpStairs)
							{
								AnimateCrouchRunningUpStairs();								
							}
							else
							{
								AnimateCrouchRunningDownStairs();
							}
						}						
					}
					else
					{
						// End:0x152
						if(bIsWalking)
						{
							AnimateCrouchWalking();							
						}
						else
						{
							AnimateCrouchRunning();
						}
					}					
				}
				else
				{
					AnimateStandTurning();
					// End:0x1A9
					if(m_bIsClimbingStairs)
					{
						// End:0x18E
						if(bIsWalking)
						{
							// End:0x185
							if(m_bIsMovingUpStairs)
							{
								AnimateWalkingUpStairs();								
							}
							else
							{
								AnimateWalkingDownStairs();
							}							
						}
						else
						{
							// End:0x1A0
							if(m_bIsMovingUpStairs)
							{
								AnimateRunningUpStairs();								
							}
							else
							{
								AnimateRunningDownStairs();
							}
						}						
					}
					else
					{
						// End:0x1BB
						if(bIsWalking)
						{
							AnimateWalking();							
						}
						else
						{
							AnimateRunning();
						}
					}
				}
			}
		}
	}
	return;
}

//===================================================================================================
simulated function AnimateStandTurning()
{
	TurnLeftAnim = m_standTurnLeftName;
	TurnRightAnim = m_standTurnRightName;
	return;
}

//===================================================================================================
simulated function AnimateCrouchTurning()
{
	TurnLeftAnim = 'CrouchTurnLeft';
	TurnRightAnim = 'CrouchTurnRight';
	return;
}

//===================================================================================================
simulated function AnimateProneTurning()
{
	TurnLeftAnim = 'ProneTurnLeft';
	TurnRightAnim = 'ProneTurnRight';
	return;
}

simulated function InitBackwardAnims()
{
	local int i;

	i = 0;
	J0x07:

	// End:0x2B [Loop If]
	if((i < 4))
	{
		AnimPlayBackward[i] = 0;
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

//===================================================================================================
simulated function AnimateWalking()
{
	// End:0x49
	if((int(m_eHealth) == int(1)))
	{
		MovementAnims[0] = 'HurtStandWalkForward';
		MovementAnims[1] = m_hurtStandWalkLeftName;
		MovementAnims[2] = 'HurtStandWalkBack';
		MovementAnims[3] = m_hurtStandWalkRightName;		
	}
	else
	{
		MovementAnims[0] = m_standWalkForwardName;
		MovementAnims[1] = m_standWalkLeftName;
		MovementAnims[2] = m_standWalkBackName;
		MovementAnims[3] = m_standWalkRightName;
	}
	InitBackwardAnims();
	return;
}

//===================================================================================================
simulated function AnimateRunning()
{
	MovementAnims[0] = m_standRunForwardName;
	MovementAnims[1] = m_standRunLeftName;
	MovementAnims[2] = m_standRunBackName;
	MovementAnims[3] = m_standRunRightName;
	InitBackwardAnims();
	return;
}

//===================================================================================================
simulated function AnimateCrouchWalking()
{
	MovementAnims[0] = m_crouchWalkForwardName;
	MovementAnims[1] = 'CrouchWalkLeft';
	MovementAnims[2] = 'CrouchWalkBack';
	MovementAnims[3] = 'CrouchWalkRight';
	InitBackwardAnims();
	return;
}

//===================================================================================================
simulated function AnimateCrouchRunning()
{
	MovementAnims[0] = 'CrouchRunForward';
	MovementAnims[1] = 'CrouchRunLeft';
	MovementAnims[2] = 'CrouchRunBack';
	MovementAnims[3] = 'CrouchRunRight';
	InitBackwardAnims();
	return;
}

//===================================================================================================
simulated function AnimateProneWalking()
{
	MovementAnims[0] = 'ProneWalkForward';
	MovementAnims[1] = 'ProneWalkLeft';
	MovementAnims[2] = 'ProneWalkBack';
	MovementAnims[3] = 'ProneWalkRight';
	InitBackwardAnims();
	return;
}

//===================================================================================================
// there still remains a problem when strafing across stairs (should use regular non-stair strafing animation)
simulated function AnimateWalkingUpStairs()
{
	MovementAnims[0] = m_standStairWalkUpName;
	MovementAnims[1] = m_standStairWalkDownRightName;
	MovementAnims[2] = m_standStairWalkUpBackName;
	MovementAnims[3] = m_standStairWalkUpRightName;
	InitBackwardAnims();
	AnimPlayBackward[1] = 1;
	return;
}

//===================================================================================================
simulated function AnimateWalkingDownStairs()
{
	MovementAnims[0] = m_standStairWalkDownName;
	MovementAnims[1] = m_standStairWalkUpRightName;
	MovementAnims[2] = m_standStairWalkDownBackName;
	MovementAnims[3] = m_standStairWalkDownRightName;
	InitBackwardAnims();
	AnimPlayBackward[1] = 1;
	return;
}

//===================================================================================================
simulated function AnimateRunningUpStairs()
{
	MovementAnims[0] = m_standStairRunUpName;
	MovementAnims[1] = m_standStairRunDownRightName;
	MovementAnims[2] = m_standStairRunUpBackName;
	MovementAnims[3] = m_standStairRunUpRightName;
	InitBackwardAnims();
	AnimPlayBackward[1] = 1;
	return;
}

//===================================================================================================
simulated function AnimateRunningDownStairs()
{
	MovementAnims[0] = m_standStairRunDownName;
	MovementAnims[1] = m_standStairRunUpRightName;
	MovementAnims[2] = m_standStairRunDownBackName;
	MovementAnims[3] = m_standStairRunDownRightName;
	InitBackwardAnims();
	AnimPlayBackward[1] = 1;
	return;
}

//===================================================================================================
simulated function AnimateCrouchWalkingUpStairs()
{
	MovementAnims[0] = m_crouchStairWalkUpName;
	MovementAnims[1] = m_crouchStairWalkDownRightName;
	MovementAnims[2] = m_crouchStairWalkUpBackName;
	MovementAnims[3] = m_crouchStairWalkDownRightName;
	InitBackwardAnims();
	AnimPlayBackward[1] = 1;
	return;
}

//===================================================================================================
simulated function AnimateCrouchRunningUpStairs()
{
	AnimateCrouchWalkingUpStairs();
	MovementAnims[0] = m_crouchStairRunUpName;
	return;
}

//===================================================================================================
simulated function AnimateCrouchWalkingDownStairs()
{
	MovementAnims[0] = m_crouchStairWalkDownName;
	MovementAnims[1] = m_crouchStairWalkUpRightName;
	MovementAnims[2] = m_crouchStairWalkDownBackName;
	MovementAnims[3] = m_crouchStairWalkDownRightName;
	InitBackwardAnims();
	AnimPlayBackward[1] = 1;
	return;
}

//===================================================================================================
simulated function AnimateCrouchRunningDownStairs()
{
	AnimateCrouchWalkingDownStairs();
	MovementAnims[0] = m_crouchStairRunDownName;
	return;
}

//===================================================================================================
simulated function AnimateClimbing()
{
	local name ladderAnim;
	local int i;

	ladderAnim = 'StandLadderUp_c';
	// End:0x5E
	if(bIsWalking)
	{
		i = 0;
		J0x1B:

		// End:0x50 [Loop If]
		if((i < 4))
		{
			MovementAnims[i] = ladderAnim;
			AnimPlayBackward[i] = 0;
			(i++);
			// [Loop Continue]
			goto J0x1B;
		}
		AnimPlayBackward[2] = 1;		
	}
	else
	{
		i = 0;
		J0x65:

		// End:0x9A [Loop If]
		if((i < 4))
		{
			MovementAnims[i] = ladderAnim;
			AnimPlayBackward[i] = 0;
			(i++);
			// [Loop Continue]
			goto J0x65;
		}
		// End:0xC6
		if((int(m_ePawnType) == int(1)))
		{
			MovementAnims[2] = 'StandLadderSlide_nt';
			AnimPlayBackward[2] = 0;			
		}
		else
		{
			AnimPlayBackward[2] = 1;
		}
	}
	TurnLeftAnim = ladderAnim;
	TurnRightAnim = ladderAnim;
	return;
}

simulated function AnimateStoppedOnLadder()
{
	m_ePlayerIsUsingHands = 3;
	TweenAnim('StandLadder_nt', 0.2000000);
	return;
}

//===================================================================================================
// PlayFalling() 
//  rbrek 3 dec 2001
//  this function is called when a pawn first starts to fall
// 3 jan 2002 - rbrek, removed PlayInAir() (obsolete), can replace with calls to PlayFalling()
//===================================================================================================
simulated event PlayFalling()
{
	m_ePlayerIsUsingHands = 3;
	// End:0x1F
	if(bWantsToCrouch)
	{
		R6LoopAnim(m_crouchFallName);		
	}
	else
	{
		R6LoopAnim(m_standFallName);
	}
	return;
}

//------------------------------------------------------------------
// Falling: fired when the pawn physic switch to falling or when he
//  has to jump (not the case in ravenshield)
//------------------------------------------------------------------
event Falling()
{
	m_fFallingHeight = Location.Z;
	return;
}

//------------------------------------------------------------------
// Landed: when the pawn land on the floor
//  
//------------------------------------------------------------------
event Landed(Vector HitNormal)
{
	local float fDistanceFallen;
	local Pawn.eHealth ePreviousHealth;
	local bool bGameOver;

	// End:0x77
	if((int(Level.NetMode) == int(NM_Client)))
	{
		// End:0x74
		if((m_bIsPlayer && R6PlayerController(Controller).GameReplicationInfo.m_bGameOverRep))
		{
			m_bIsLanding = true;
			Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
			Velocity = vect(0.0000000, 0.0000000, 0.0000000);
			return;
		}		
	}
	else
	{
		// End:0xE6
		if((Level.Game.m_bGameOver && (!R6AbstractGameInfo(Level.Game).m_bGameOverButAllowDeath)))
		{
			m_bIsLanding = true;
			Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
			Velocity = vect(0.0000000, 0.0000000, 0.0000000);
			return;
		}
	}
	// End:0x1B6
	if(Class'Engine.Actor'.static.GetModMgr().IsMissionPack())
	{
		// End:0x1B6
		if(((((PlayerController(Controller).GameReplicationInfo.m_szGameTypeFlagRep == "RGM_CaptureTheEnemyAdvMode") && (int(m_bSuicideType) != 3)) && (int(m_bSuicideType) != 1)) && (int(m_bSuicideType) != 2)))
		{
			// End:0x1B4
			if(((m_fFallingHeight - Location.Z) >= 128.0000000))
			{
				m_bIsLanding = true;
				Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
				Velocity = vect(0.0000000, 0.0000000, 0.0000000);
			}
			return;
		}
	}
	// End:0x1C5
	if((m_fFallingHeight == float(0)))
	{
		return;
	}
	ePreviousHealth = m_eHealth;
	fDistanceFallen = (m_fFallingHeight - Location.Z);
	// End:0x2B6
	if(((!InGodMode()) && ((fDistanceFallen >= float(600)) || ((fDistanceFallen >= float(300)) && ((int(m_eHealth) == int(1)) || (int(m_eHealth) == int(2)))))))
	{
		m_eHealth = 3;
		// End:0x271
		if(((int(Role) == int(ROLE_Authority)) && (Controller != none)))
		{
			Controller.PlaySoundDamage(self);
		}
		// End:0x2B3
		if((int(Level.NetMode) != int(NM_Client)))
		{
			TakeHitLocation = vect(0.0000000, 0.0000000, 0.0000000);
			R6Died(self, 3, vect(0.0000000, 0.0000000, 0.0000000));
		}		
	}
	else
	{
		// End:0x361
		if(((fDistanceFallen >= 128.0000000) && (int(m_eHealth) != int(3))))
		{
			// End:0x333
			if(((!InGodMode()) && (fDistanceFallen >= 300.0000000)))
			{
				m_eHealth = 1;
				m_fHBWound = 1.2000000;
				// End:0x333
				if(((int(Role) == int(ROLE_Authority)) && (Controller != none)))
				{
					Controller.PlaySoundDamage(self);
				}
			}
			m_bIsLanding = true;
			Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
			Velocity = vect(0.0000000, 0.0000000, 0.0000000);
		}
	}
	// End:0x382
	if((PlayerReplicationInfo != none))
	{
		PlayerReplicationInfo.m_iHealth = int(m_eHealth);
	}
	// End:0x41F
	if((int(ePreviousHealth) != int(m_eHealth)))
	{
		// End:0x41F
		if((int(m_ePawnType) == int(1)))
		{
			// End:0x3E8
			if(m_bIsPlayer)
			{
				// End:0x3E5
				if((R6PlayerController(Controller).m_TeamManager != none))
				{
					R6PlayerController(Controller).m_TeamManager.UpdateTeamStatus(self);
				}				
			}
			else
			{
				// End:0x41F
				if((R6RainbowAI(Controller).m_TeamManager != none))
				{
					R6RainbowAI(Controller).m_TeamManager.UpdateTeamStatus(self);
				}
			}
		}
	}
	return;
}

//===================================================================================================
// PlayLandingAnimation() 
//  rbrek 3 dec 2001
//  this function is called when pawn's physics changes from PHYS_Falling to PHYS_Walking
//  called by PlayLanded() which also handles playing the appropriate sound.
//===================================================================================================
simulated event PlayLandingAnimation(float impactVel)
{
	// End:0x12
	if((int(m_eHealth) == int(3)))
	{
		return;
	}
	// End:0x36
	if(((m_fFallingHeight - Location.Z) < float(128)))
	{
		m_bIsLanding = false;
		return;
	}
	m_bIsLanding = true;
	m_fFallingHeight = 0.0000000;
	m_ePlayerIsUsingHands = 3;
	// End:0x67
	if((int(m_eHealth) == int(1)))
	{
		ChangeAnimation();
	}
	m_bPostureTransition = true;
	AnimBlendParams(1, 1.0000000, 0.0000000, 0.0000000);
	// End:0xA4
	if(bWantsToCrouch)
	{
		PlayAnim(m_crouchLandName, 1.5000000, 0.1000000, 1);		
	}
	else
	{
		PlayAnim(m_standLandName, 1.5000000, 0.1000000, 1);
	}
	return;
}

//------------------------------------------------------------------
// BaseChange: when the base was a pawn, the base was taking damage
// and self was jumping like a monkey on acid.
// - overriden from pawn.uc 
//------------------------------------------------------------------
singular event BaseChange()
{
	// End:0x0B
	if(bInterpolating)
	{
		return;
	}
	// End:0x30
	if(((Base == none) && (int(Physics) == int(0))))
	{
		SetPhysics(2);		
	}
	else
	{
		// End:0x7D
		if(((Pawn(Base) != none) || (R6ColBox(Base) != none)))
		{
			// End:0x7D
			if((int(Level.NetMode) != int(NM_Client)))
			{
				R6JumpOffPawn();
				Falling();
				PlayFalling();
			}
		}
	}
	return;
}

//------------------------------------------------------------------
// R6JumpOffPawn
//	jump off something: good velocity + not to high 
//------------------------------------------------------------------
function R6JumpOffPawn()
{
	local int i;

	i = 200;
	(Velocity += (float(i) * VRand()));
	// End:0x53
	if((Velocity.X < float(0)))
	{
		Velocity.X = (float((Rand(i) + i)) * float(-1));		
	}
	else
	{
		Velocity.X = float((Rand(i) + i));
	}
	// End:0xA7
	if((Velocity.Y < float(0)))
	{
		Velocity.Y = (float((Rand(i) + i)) * float(-1));		
	}
	else
	{
		Velocity.Y = float((Rand(i) + i));
	}
	Velocity.Z = 25.0000000;
	SetPhysics(2);
	bNoJumpAdjust = true;
	Controller.SetFall();
	return;
}

//============================================================================
// AttachToClimbableObject - 
//============================================================================
function AttachToClimbableObject(R6ClimbableObject pObject)
{
	m_bOldCanWalkOffLedges = bCanWalkOffLedges;
	bCanWalkOffLedges = true;
	return;
}

//============================================================================
// DetachFromClimbableObject - 
//============================================================================
function DetachFromClimbableObject(R6ClimbableObject pObject)
{
	bCanWalkOffLedges = m_bOldCanWalkOffLedges;
	return;
}

//===================================================================================================
// rbrek
// EncroachedBy()
//   this function was overriden from Pawn.uc; actors were being gibbed (killed) when they were encroached 
//   on by another actor who started crouching. it is left empty to prevent pawn from being 'gibbed'
//===================================================================================================
event EncroachedBy(Actor Other)
{
	return;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
//                          ANIMATION FUNCTIONS COMMON TO ALL STATES
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
simulated function PlayWaiting()
{
	m_ePlayerIsUsingHands = 0;
	R6LoopAnim(m_standDefaultAnimName);
	return;
}

simulated function PlayDuck()
{
	R6LoopAnim(m_crouchDefaultAnimName);
	return;
}

simulated function PlayCrouchWaiting()
{
	m_ePlayerIsUsingHands = 0;
	R6LoopAnim(m_crouchDefaultAnimName);
	return;
}

simulated event PlayCrouchToProne(optional bool bForcedByClient)
{
	local Vector vHitLocation, vHitNormal, vPositionEnd;

	// End:0x3A
	if((((int(Level.NetMode) == int(NM_Client)) && (!bForcedByClient)) && (int(Role) == int(ROLE_AutonomousProxy))))
	{
		return;
	}
	m_ePlayerIsUsingHands = 3;
	PlayWeaponAnimation();
	m_bPostureTransition = true;
	m_bSoundChangePosture = true;
	vPositionEnd = Location;
	(vPositionEnd.Z -= CollisionHeight);
	(vPositionEnd.Z -= float(50));
	R6Trace(vHitLocation, vHitNormal, vPositionEnd, Location, 8,, m_HitMaterial);
	PlaySurfaceSwitch();
	AnimBlendParams(1, 1.0000000, 0.0000000, 0.0000000);
	// End:0x11E
	if((((EngineWeapon != none) && (int(m_ePawnType) == int(1))) && EngineWeapon.GotBipod()))
	{
		EngineWeapon.GotoState('DeployBipod');
		PlayAnim('CrouchToProneBipod', (1.4000000 * ArmorSkillEffect()), 0.1000000, 1);		
	}
	else
	{
		PlayAnim('CrouchToProne', (1.4000000 * ArmorSkillEffect()), 0.1000000, 1);
	}
	return;
}

simulated event PlayProneToCrouch(optional bool bForcedByClient)
{
	local Vector vHitLocation, vHitNormal, vPositionEnd;

	// End:0x3A
	if((((int(Level.NetMode) == int(NM_Client)) && (!bForcedByClient)) && (int(Role) == int(ROLE_AutonomousProxy))))
	{
		return;
	}
	SetBoneRotation('R6 Spine', rot(0, 0, 0),, 1.0000000, 0.4000000);
	SetBoneRotation('R6 Pelvis', rot(0, 0, 0),, 1.0000000, 0.0000000);
	m_ePlayerIsUsingHands = 3;
	PlayWeaponAnimation();
	m_bPostureTransition = true;
	m_bSoundChangePosture = true;
	vPositionEnd = Location;
	(vPositionEnd.Z -= CollisionHeight);
	(vPositionEnd.Z -= float(50));
	R6Trace(vHitLocation, vHitNormal, vPositionEnd, Location, 8,, m_HitMaterial);
	PlaySurfaceSwitch();
	AnimBlendParams(1, 1.0000000, 0.0000000, 0.0000000);
	// End:0x165
	if((((EngineWeapon != none) && (int(m_ePawnType) == int(1))) && EngineWeapon.GotBipod()))
	{
		EngineWeapon.GotoState('CloseBipod');
		PlayAnim('CrouchToProneBipod', (1.4000000 * ArmorSkillEffect()), 0.0000000, 1, true);		
	}
	else
	{
		PlayAnim('CrouchToProne', (1.4000000 * ArmorSkillEffect()), 0.0000000, 1, true);
	}
	return;
}

event StartCrouch(float HeightAdjust)
{
	Visibility = 64;
	PlayDuck();
	return;
}

event EndCrouch(float fHeight)
{
	Visibility = 128;
	return;
}

event StartCrawl()
{
	Visibility = 38;
	// End:0x2C
	if((int(Level.NetMode) != int(NM_Client)))
	{
		SetNextPendingAction();		
	}
	else
	{
		PlayCrouchToProne(true);
	}
	return;
}

event EndCrawl()
{
	Visibility = 64;
	// End:0x2C
	if((int(Level.NetMode) != int(NM_Client)))
	{
		SetNextPendingAction();		
	}
	else
	{
		PlayProneToCrouch(true);
	}
	return;
}

function ServerGod(bool bIsGod, bool bUpdateTeam, bool bForHostage, string szPlayerName, bool bForTerro)
{
	local R6Pawn P;
	local string szMsg;

	// End:0xA1
	if((((!bUpdateTeam) && (!bForHostage)) && (!bForTerro)))
	{
		Controller.bGodMode = bIsGod;
		// End:0x7A
		if(Controller.bGodMode)
		{
			szMsg = (szPlayerName $ " activated GOD mode");
			m_eHealth = 0;			
		}
		else
		{
			szMsg = (szPlayerName $ " deactivated GOD mode");
		}		
	}
	else
	{
		// End:0x21D
		foreach AllActors(Class'R6Engine.R6Pawn', P)
		{
			// End:0xC9
			if((!P.IsAlive()))
			{
				continue;				
			}
			// End:0x113
			if(bForTerro)
			{
				// End:0xEF
				if((int(P.m_ePawnType) != int(2)))
				{
					continue;					
				}
				bIsGod = (!P.Controller.bGodMode);				
			}
			else
			{
				// End:0x15D
				if(bForHostage)
				{
					// End:0x139
					if((int(P.m_ePawnType) != int(3)))
					{
						continue;						
					}
					bIsGod = (!P.Controller.bGodMode);					
				}
				else
				{
					// End:0x17D
					if((int(P.m_ePawnType) != int(1)))
					{
						continue;												
					}
					else
					{
						// End:0x1BD
						if(((int(Level.NetMode) != int(NM_Standalone)) && (P.m_iTeam != P.m_iTeam)))
						{
							continue;							
						}
					}
				}
			}
			// End:0x21C
			if((P.Controller != none))
			{
				P.Controller.bGodMode = bIsGod;
				// End:0x21C
				if(P.Controller.bGodMode)
				{
					P.m_eHealth = 0;
				}
			}			
		}		
		// End:0x290
		if(bForTerro)
		{
			// End:0x25F
			if(bIsGod)
			{
				szMsg = (szPlayerName $ " activated TERRORIST GOD mode");				
			}
			else
			{
				szMsg = (szPlayerName $ " deactivated TERRORIST GOD mode");
			}			
		}
		else
		{
			// End:0x2FE
			if(bForHostage)
			{
				// End:0x2CF
				if(bIsGod)
				{
					szMsg = (szPlayerName $ " activated HOSTAGE GOD mode");					
				}
				else
				{
					szMsg = (szPlayerName $ " deactivated HOSTAGE GOD mode");
				}				
			}
			else
			{
				// End:0x331
				if(bIsGod)
				{
					szMsg = (szPlayerName $ " activated TEAM GOD mode");					
				}
				else
				{
					szMsg = (szPlayerName $ " deactivated TEAM GOD mode");
				}
			}
		}
	}
	Level.Game.Broadcast(none, szMsg, 'ServerMessage');
	return;
}

//------------------------------------------------------------------
// ServerSuicidePawn: for debugging
//  
//------------------------------------------------------------------
function ServerSuicidePawn(byte bSuicidedType)
{
	// End:0x0B
	if(InGodMode())
	{
		return;
	}
	m_bSuicideType = bSuicidedType;
	Velocity = vect(0.0000000, 0.0000000, 0.0000000);
	Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
	m_fFallingHeight = (Location.Z + float(1000));
	Landed(vect(0.0000000, 0.0000000, 0.0000000));
	return;
}

function ServerSetRoundTime(int iTime)
{
	Level.Game.Broadcast(none, (("ServerSetRoundTime: " $ string(iTime)) $ " seconds"), 'ServerMessage');
	// End:0x96
	if((R6AbstractGameInfo(Level.Game) != none))
	{
		R6AbstractGameInfo(Level.Game).m_fEndingTime = (Level.TimeSeconds + float(iTime));
	}
	return;
}

function ServerSetBetTime(int iTime)
{
	Level.Game.Broadcast(none, (("ServerSetBetTime: " $ string(iTime)) $ " seconds"), 'ServerMessage');
	// End:0x84
	if((R6AbstractGameInfo(Level.Game) != none))
	{
		R6AbstractGameInfo(Level.Game).m_fTimeBetRounds = float(iTime);
	}
	return;
}

//------------------------------------------------------------------
// ServerToggleCollision: for debugging and not safe
//  
//------------------------------------------------------------------
function ServerToggleCollision()
{
	local bool bValue;

	bValue = (!bCollideActors);
	SetCollision(bValue, bValue, bValue);
	return;
}

function ServerSwitchReloadingWeapon(bool NewValue)
{
	m_bReloadingWeapon = NewValue;
	// End:0x24
	if((m_bReloadingWeapon == false))
	{
		m_WeaponAnimPlaying = 'None';
	}
	return;
}

function ServerPerformDoorAction(R6IORotatingDoor whichDoor, int iActionID)
{
	whichDoor.Instigator = self;
	whichDoor.performDoorAction(iActionID);
	return;
}

simulated function PlaySecureTerrorist()
{
	return;
}

function bool PawnHaveFinishedRotation()
{
	local bool bSuccess;

	bSuccess = (Abs(float((DesiredRotation.Yaw - (Rotation.Yaw & 65535)))) < float(2000));
	// End:0x6D
	if((!bSuccess))
	{
		bSuccess = (Abs(float((DesiredRotation.Yaw - (Rotation.Yaw & 65535)))) > float(63535));
	}
	return bSuccess;
	return;
}

//------------------------------------------------------------------
// CanInteractWithObjects()
//------------------------------------------------------------------
function bool CanInteractWithObjects()
{
	// End:0x40
	if(((((m_bIsProne || m_bChangingWeapon) || m_bReloadingWeapon) || m_bIsFiringState) || Level.m_bInGamePlanningActive))
	{
		return false;
	}
	return true;
	return;
}

// PLAYERPAWN - request to perform an action has been recieved from PlayerController...
simulated function ServerActionRequest(R6CircumstantialActionQuery actionRequested)
{
	// End:0x23
	if(((!m_bIsPlayer) || (actionRequested.aQueryTarget == none)))
	{
		return;
	}
	// End:0x89
	if(actionRequested.aQueryTarget.IsA('R6IORotatingDoor'))
	{
		actionRequested.aQueryTarget.Instigator = self;
		R6IORotatingDoor(actionRequested.aQueryTarget).performDoorAction(int(actionRequested.iPlayerActionID));		
	}
	else
	{
		// End:0xC7
		if(actionRequested.aQueryTarget.IsA('R6IOObject'))
		{
			R6IOObject(actionRequested.aQueryTarget).ToggleDevice(self);			
		}
		else
		{
			// End:0x11E
			if(actionRequested.aQueryTarget.IsA('R6Hostage'))
			{
				R6Hostage(actionRequested.aQueryTarget).m_controller.DispatchOrder(int(actionRequested.iPlayerActionID), self);				
			}
			else
			{
				// End:0x178
				if(actionRequested.aQueryTarget.IsA('R6LadderVolume'))
				{
					// End:0x178
					if((!m_bIsClimbingLadder))
					{
						PotentialClimbLadder(LadderVolume(actionRequested.aQueryTarget));
						ClimbLadder(LadderVolume(actionRequested.aQueryTarget));
					}
				}
			}
		}
	}
	return;
}

simulated function ActionRequest(R6CircumstantialActionQuery actionRequested)
{
	// End:0x30
	if((((!m_bIsPlayer) || (actionRequested == none)) || (actionRequested.aQueryTarget == none)))
	{
		return;
	}
	ServerActionRequest(actionRequested);
	// End:0x74
	if(actionRequested.aQueryTarget.IsA('R6IORotatingDoor'))
	{
		PlayDoorAnim(R6IORotatingDoor(actionRequested.aQueryTarget));		
	}
	else
	{
		// End:0xB3
		if((actionRequested.aQueryTarget.IsA('R6IOObject') || actionRequested.aQueryTarget.IsA('R6Hostage')))
		{			
		}
		else
		{
			// End:0x128
			if(actionRequested.aQueryTarget.IsA('R6LadderVolume'))
			{
				// End:0x128
				if(((int(Level.NetMode) == int(NM_Client)) && (!m_bIsClimbingLadder)))
				{
					PotentialClimbLadder(LadderVolume(actionRequested.aQueryTarget));
					ClimbLadder(LadderVolume(actionRequested.aQueryTarget));
				}
			}
		}
	}
	return;
}

function PlayInteraction()
{
	return;
}

// climbladder has been requested...
function PotentialClimbLadder(LadderVolume L)
{
	m_potentialActionActor = L;
	return;
}

function RemovePotentialClimbLadder(LadderVolume L)
{
	m_potentialActionActor = none;
	return;
}

function PotentialClimbableObject(R6ClimbableObject obj)
{
	m_potentialActionActor = obj;
	return;
}

simulated function RemovePotentialClimbableObject(R6ClimbableObject obj)
{
	m_potentialActionActor = none;
	return;
}

function bool IsTouching(R6Door Door)
{
	local R6Door aDoor;

	// End:0x23
	foreach TouchingActors(Class'R6Engine.R6Door', aDoor)
	{
		// End:0x22
		if((Door == aDoor))
		{			
			return true;
		}		
	}	
	return false;
	return;
}

//===================================================================================================
// PotentialOpenDoor()                                        
//===================================================================================================
event PotentialOpenDoor(R6Door Door)
{
	// End:0x16
	if((Door.m_RotatingDoor == none))
	{
		return;
	}
	// End:0x50
	if((m_Door != none))
	{
		// End:0x4D
		if((m_Door.m_RotatingDoor != Door.m_RotatingDoor))
		{
			m_Door2 = Door;
		}		
	}
	else
	{
		m_Door = Door;
		m_potentialActionActor = Door.m_RotatingDoor;
	}
	// End:0x112
	if((((int(m_ePawnType) == int(1)) && Door.m_RotatingDoor.m_bIsDoorClosed) && (!Door.m_RotatingDoor.m_bTreatDoorAsWindow)))
	{
		// End:0x112
		if(m_bIsPlayer)
		{
			// End:0x112
			if(((R6PlayerController(Controller) != none) && (R6PlayerController(Controller).m_TeamManager != none)))
			{
				R6PlayerController(Controller).m_TeamManager.RainbowIsInFrontOfAClosedDoor(self, m_Door);
			}
		}
	}
	return;
}

//===================================================================================================
// RemovePotentialOpenDoor()                                  
//===================================================================================================
event RemovePotentialOpenDoor(R6Door Door)
{
	// End:0xC8
	if((m_Door == Door))
	{
		// End:0x51
		if(IsTouching(Door.m_CorrespondingDoor))
		{
			m_Door = Door.m_CorrespondingDoor;
			m_potentialActionActor = m_Door.m_RotatingDoor;			
		}
		else
		{
			// End:0x86
			if((((int(m_ePawnType) == int(2)) && (Controller != none)) && Controller.IsInState('OpenDoor')))
			{
				return;
			}
			m_potentialActionActor = none;
			m_Door = none;
			// End:0xC5
			if((m_Door2 != none))
			{
				m_Door = m_Door2;
				m_Door2 = none;
				m_potentialActionActor = m_Door.m_RotatingDoor;
			}
		}		
	}
	else
	{
		// End:0xE1
		if((m_Door2 == Door))
		{
			m_Door2 = none;			
		}
		else
		{
			return;
		}
	}
	// End:0x132
	if(((m_bIsPlayer && (Controller != none)) && (R6PlayerController(Controller).m_TeamManager != none)))
	{
		R6PlayerController(Controller).m_TeamManager.RainbowHasLeftDoor(self);
	}
	return;
}

//===================================================================================================
// PlayDoorAnim()
//===================================================================================================
simulated function PlayDoorAnim(R6IORotatingDoor Door)
{
	local bool bOpensTowardsPawn;

	// End:0x16
	if(bIsCrouched)
	{
		PlayCrouchedDoorAnim(Door);
		return;
	}
	bOpensTowardsPawn = Door.DoorOpenTowardsActor(self);
	m_ePlayerIsUsingHands = 2;
	// End:0x7A
	if(Door.m_bIsDoorClosed)
	{
		// End:0x65
		if(bOpensTowardsPawn)
		{
			PlayAnim('StandDoorPull', 1.0000000, 0.2000000);			
		}
		else
		{
			PlayAnim('StandDoorPush', 1.0000000, 0.2000000);
		}		
	}
	else
	{
		// End:0x98
		if(bOpensTowardsPawn)
		{
			PlayAnim('StandDoorPush', 1.0000000, 0.2000000);			
		}
		else
		{
			PlayAnim('StandDoorPull', 1.0000000, 0.2000000);
		}
	}
	return;
}

//===================================================================================================    
// PlayCrouchedDoorAnim()
//===================================================================================================
simulated function PlayCrouchedDoorAnim(R6IORotatingDoor Door)
{
	local bool bOpensTowardsPawn;

	bOpensTowardsPawn = Door.DoorOpenTowardsActor(self);
	m_ePlayerIsUsingHands = 2;
	// End:0x64
	if(Door.m_bIsDoorClosed)
	{
		// End:0x4F
		if(bOpensTowardsPawn)
		{
			PlayAnim('CrouchDoorPull', 1.0000000, 0.2000000);			
		}
		else
		{
			PlayAnim('CrouchDoorPush', 1.0000000, 0.2000000);
		}		
	}
	else
	{
		// End:0x82
		if(bOpensTowardsPawn)
		{
			PlayAnim('CrouchDoorPush', 1.0000000, 0.2000000);			
		}
		else
		{
			PlayAnim('CrouchDoorPull', 1.0000000, 0.2000000);
		}
	}
	return;
}

//===================================================================================================
// LocateLadderActor()                                        
//    determine which ladder actor this pawn is closest to              
//    (top or bottom)
//===================================================================================================
function Ladder LocateLadderActor(LadderVolume L)
{
	// End:0x0D
	if((L == none))
	{
		return none;
	}
	// End:0x73
	if((VSize((R6LadderVolume(L).m_TopLadder.Location - Location)) < VSize((R6LadderVolume(L).m_BottomLadder.Location - Location))))
	{
		return R6LadderVolume(L).m_TopLadder;		
	}
	else
	{
		return R6LadderVolume(L).m_BottomLadder;
	}
	return;
}

function ServerClimbLadder(LadderVolume L, R6Ladder Ladder)
{
	// End:0x11
	if((OnLadder == L))
	{
		return;
	}
	m_Ladder = Ladder;
	ClimbLadder(L);
	return;
}

//===================================================================================================
// ClimbLadder()                                              
//===================================================================================================
function ClimbLadder(LadderVolume L)
{
	local Vector vStartPosition;

	// End:0x0B
	if(m_bIsClimbingLadder)
	{
		return;
	}
	// End:0x1D
	if((int(Physics) == int(2)))
	{
		return;
	}
	OnLadder = L;
	// End:0x49
	if((m_Ladder == none))
	{
		m_Ladder = R6Ladder(LocateLadderActor(L));
	}
	// End:0x72
	if((int(Level.NetMode) == int(NM_Client)))
	{
		ServerClimbLadder(L, m_Ladder);
	}
	// End:0xF2
	if(m_Ladder.m_bIsTopOfLadder)
	{
		vStartPosition = (m_Ladder.Location + (float(50) * Vector(OnLadder.LadderList.Rotation)));
		vStartPosition.Z = Location.Z;
		SetRotation((m_Ladder.Rotation + rot(0, 32768, 0)));		
	}
	else
	{
		vStartPosition = m_Ladder.Location;
		vStartPosition.Z = Location.Z;
		SetRotation(m_Ladder.Rotation);
	}
	SetLocation(vStartPosition);
	SetPhysics(11);
	R6LadderVolume(L).AddClimber(self);
	// End:0x16F
	if(m_bIsPlayer)
	{
		R6PlayerController(Controller).GotoState('PreBeginClimbingLadder');		
	}
	else
	{
		R6AIController(Controller).GotoState('BeginClimbingLadder');
	}
	return;
}

simulated function PlayStartClimbing()
{
	local name animName;

	AnimBlendToAlpha(16, 0.0000000, 0.5000000);
	m_bSlideEnd = false;
	// End:0x74
	if((m_Ladder == none))
	{
		logWarning(((((("PlayStartClimbing() " $ string(self)) $ " m_Ladder=") $ string(m_Ladder)) $ " onLadder=") $ string(OnLadder)));
	}
	// End:0xA1
	if(((m_Ladder != none) && m_Ladder.m_bIsTopOfLadder))
	{
		animName = 'StandLadderDown_b';		
	}
	else
	{
		animName = 'StandLadderUp_b';
	}
	m_ePlayerIsUsingHands = 3;
	PlayRootMotionAnimation(animName, (ArmorSkillEffect() * 1.5000000));
	return;
}

simulated function bool EndOfLadderSlide()
{
	// End:0x0D
	if((m_Ladder == none))
	{
		return false;
	}
	// End:0x3B
	if(((Location.Z - CollisionHeight) > m_Ladder.Location.Z))
	{
		return false;		
	}
	else
	{
		return true;
	}
	return;
}

simulated function PlayEndClimbing()
{
	local name animName;

	// End:0x12
	if((int(Physics) == int(1)))
	{
		return;
	}
	// End:0x47
	if(m_Ladder.m_bIsTopOfLadder)
	{
		m_ePlayerIsUsingHands = 3;
		PlayRootMotionAnimation('StandLadderUp_e', (ArmorSkillEffect() * 1.5000000));		
	}
	else
	{
		// End:0x87
		if(((int(m_ePawnType) == int(1)) && EndOfLadderSlide()))
		{
			m_bSlideEnd = true;
			PlayAnim('StandLadderSlide_e', (1.5000000 * ArmorSkillEffect()), 0.0000000);			
		}
		else
		{
			m_ePlayerIsUsingHands = 3;
			PlayRootMotionAnimation('StandLadderDown_e', (ArmorSkillEffect() * 1.5000000));
		}
	}
	return;
}

event EndClimbLadder(LadderVolume OldLadder)
{
	local int iFacing;

	// End:0x0D
	if((OnLadder == none))
	{
		return;
	}
	R6LadderVolume(OldLadder).RemoveClimber(self);
	// End:0x3B
	if(m_bIsPlayer)
	{
		// End:0x38
		if((!m_bIsClimbingLadder))
		{
			return;
		}		
	}
	else
	{
		// End:0x56
		if(Controller.IsInState('EndClimbingLadder'))
		{
			SetPhysics(1);
			return;
		}
	}
	// End:0xA6
	if(m_bIsPlayer)
	{
		// End:0xA3
		if((int(Level.NetMode) != int(NM_Client)))
		{
			R6PlayerController(Controller).m_bSkipBeginState = false;
			R6PlayerController(Controller).GotoState('PlayerEndClimbingLadder');
		}		
	}
	else
	{
		R6AIController(Controller).GotoState('EndClimbingLadder');
	}
	return;
}

//===================================================================================================
// ClimbStairs()
//  vStairDirection indicates the direction towards the top of the stairs
//===================================================================================================
simulated function ClimbStairs(Vector vStairDirection)
{
	(PrePivot.Z -= 5.0000000);
	(m_vPrePivotProneBackup.Z -= 5.0000000);
	m_vStairDirection = vStairDirection;
	ChangeAnimation();
	return;
}

//===================================================================================================
// EndClimbStairs()
//===================================================================================================
simulated function EndClimbStairs()
{
	(PrePivot.Z += 5.0000000);
	(m_vPrePivotProneBackup.Z += 5.0000000);
	ChangeAnimation();
	return;
}

simulated function bool IsUsingHeartBeatSensor()
{
	// End:0x0D
	if((!m_bIsPlayer))
	{
		return false;
	}
	// End:0x2E
	if(((EngineWeapon != none) && EngineWeapon.IsGoggles()))
	{
		return true;
	}
	return false;
	return;
}

///////////////////////////////////////////////////////////////////////////////////////
// GunShouldFollowHead()
// rbrek - 11 april 2002
///////////////////////////////////////////////////////////////////////////////////////
simulated function bool GunShouldFollowHead()
{
	// End:0x1D
	if(((int(Physics) == int(12)) || m_bIsClimbingLadder))
	{
		return false;
	}
	// End:0x28
	if(IsUsingHeartBeatSensor())
	{
		return true;
	}
	// End:0x37
	if((m_fFiringTimer > float(0)))
	{
		return true;
	}
	// End:0x42
	if(m_bWeaponGadgetActivated)
	{
		return true;
	}
	return false;
	return;
}

//===================================================================================================
// rbrek - 13 feb 2002                                              
// AdjustPawnForDiagonalStrafing()                                      
//===================================================================================================
simulated event AdjustPawnForDiagonalStrafing()
{
	local Rotator rDirection, rBoneRotation;
	local int iOffset;

	// End:0x18
	if(((!m_bMovingDiagonally) || m_bIsProne))
	{
		return;
	}
	rDirection.Pitch = m_rRotationOffset.Pitch;
	iOffset = 5825;
	rBoneRotation.Yaw = iOffset;
	// End:0xA8
	if(((int(m_eStrafeDirection) == int(1)) || (int(m_eStrafeDirection) == int(4))))
	{
		SetBoneRotation('R6', rBoneRotation,, 1.0000000, 0.4000000);
		rDirection.Yaw = (-rBoneRotation.Yaw);
		PawnLook(rDirection, true);		
	}
	else
	{
		(rBoneRotation.Yaw *= float(-1));
		SetBoneRotation('R6', rBoneRotation,, 1.0000000, 0.4000000);
		rDirection.Yaw = (-rBoneRotation.Yaw);
		PawnLook(rDirection, true);
	}
	return;
}

simulated event ResetDiagonalStrafing()
{
	m_eStrafeDirection = 0;
	m_bMovingDiagonally = false;
	SetBoneRotation('R6', rot(0, 0, 0),, 1.0000000, 0.4000000);
	R6ResetLookDirection();
	return;
}

//===================================================================================================
// rbrek - 15 oct 2001                                              
// TurnToFaceActor()                                      
//===================================================================================================
event TurnToFaceActor(Actor Target)
{
	local Rotator rDesiredRotation;
	local int iYawDiff;

	rDesiredRotation = Rotator((Target.Location - Location));
	// End:0x41
	if((rDesiredRotation.Yaw < 0))
	{
		(rDesiredRotation.Yaw += 65536);		
	}
	else
	{
		// End:0x62
		if((rDesiredRotation.Yaw < 0))
		{
			(rDesiredRotation.Yaw -= 65536);
		}
	}
	iYawDiff = (rDesiredRotation.Yaw - Rotation.Yaw);
	// End:0xC8
	if(((iYawDiff > 32768) || ((iYawDiff > -32768) && (iYawDiff < 0))))
	{
		Controller.SetLocation(Target.Location);		
	}
	else
	{
		Controller.SetLocation(Target.Location);
	}
	SetRotationOffset(0, 0, 0);
	Controller.Focus = Controller;
	return;
}

//===================================================================================================
// rbrek - 3 oct 2001                                               
// function R6ResetLookDirection()                                  
//   Reset the bone rotations that have be imposed.                 
//===================================================================================================
simulated event R6ResetLookDirection()
{
	m_TrackActor = none;
	ResetBoneRotation();
	return;
}

function R6Pawn.eBodyPart WhichBodyPartWasHit(Vector vHitLocation, Vector vBulletDirection)
{
	local int iHitDistanceFromGround;

	// End:0x1E
	if((int(m_iTracedBone) != 0))
	{
		return GetBodyPartFromBoneID(m_iTracedBone, vBulletDirection);
	}
	iHitDistanceFromGround = int(((vHitLocation.Z - Location.Z) + CollisionHeight));
	// End:0x72
	if((float(iHitDistanceFromGround) > ((0.8000000 * float(2)) * CollisionHeight)))
	{
		CheckForHelmet(vBulletDirection);
		return 0;		
	}
	else
	{
		// End:0x96
		if((float(iHitDistanceFromGround) > ((0.6000000 * float(2)) * CollisionHeight)))
		{
			return 1;			
		}
		else
		{
			// End:0xBA
			if((float(iHitDistanceFromGround) > ((0.4500000 * float(2)) * CollisionHeight)))
			{
				return 2;				
			}
			else
			{
				return 3;
			}
		}
	}
	return;
}

function R6Pawn.eBodyPart GetBodyPartFromBoneID(byte iBone, Vector vBulletDirection)
{
	// End:0x34
	if((((int(iBone) <= 5) || (int(iBone) == 15)) || (int(iBone) == 10)))
	{
		return 1;		
	}
	else
	{
		// End:0x63
		if(((int(iBone) >= 6) && (int(iBone) <= 9)))
		{
			CheckForHelmet(vBulletDirection);
			return 0;			
		}
		else
		{
			// End:0x97
			if((((int(iBone) >= 11) && (int(iBone) <= 19)) && (int(iBone) != 15)))
			{
				return 4;				
			}
			else
			{
				return 3;
			}
		}
	}
	return;
}

function CheckForHelmet(Vector vBulletDirection)
{
	local Rotator rBulletRotator, rHeadRotator;
	local int iYawDiff;

	rHeadRotator = GetBoneRotation('R6 Head');
	rBulletRotator = Rotator(vBulletDirection);
	iYawDiff = ShortestAngle2D(rBulletRotator.Yaw, rHeadRotator.Yaw);
	// End:0x55
	if((iYawDiff > 24576))
	{
		m_bHelmetWasHit = false;		
	}
	else
	{
		m_bHelmetWasHit = true;
	}
	return;
}

function PlayerController GetHumanLeaderForAIPawn()
{
	local R6RainbowTeam _TeamManager;

	// End:0x12
	if((R6RainbowAI(Controller) == none))
	{
		return none;
	}
	_TeamManager = R6RainbowAI(Controller).m_TeamManager;
	// End:0x6D
	if((((_TeamManager == none) || (_TeamManager.m_TeamLeader == none)) || (_TeamManager.m_TeamLeader.Owner == none)))
	{
		return none;
	}
	return PlayerController(_TeamManager.m_TeamLeader.Owner);
	return;
}

function int R6TakeDamage(int iKillValue, int iStunValue, Pawn instigatedBy, Vector vHitLocation, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGoup)
{
	local Actor.eKillResult eKillFromTable;
	local Actor.eStunResult eStunFromTable;
	local R6Pawn.eBodyPart eHitPart;
	local int iKillFromHit;
	local Vector vBulletDirection;
	local int iSndIndex;
	local bool bIsSilenced;
	local R6BloodSplat BloodSplat;
	local Rotator BloodRotation;
	local R6WallHit aBloodEffect;
	local bool _bAffectedActor;
	local PlayerController _playerController;

	// End:0x94
	if((((PlayerController(Controller) != none) && (PlayerController(Controller).GameReplicationInfo != none)) && (PlayerController(Controller).GameReplicationInfo.m_szGameTypeFlagRep == "RGM_CaptureTheEnemyAdvMode")))
	{
		return R6TakeDamageCTE(iKillValue, iStunValue, instigatedBy, vHitLocation, vMomentum, iBulletToArmorModifier, iBulletGoup);
	}
	// End:0xDD
	if(((instigatedBy != none) && (instigatedBy.EngineWeapon != none)))
	{
		_bAffectedActor = instigatedBy.EngineWeapon.AffectActor(iBulletGoup, self);		
	}
	else
	{
		_bAffectedActor = false;
	}
	// End:0x1ED
	if((IsEnemy(instigatedBy) && _bAffectedActor))
	{
		// End:0x154
		if((int(Level.NetMode) == int(NM_Standalone)))
		{
			// End:0x151
			if(((instigatedBy != none) && (int(instigatedBy.m_ePawnType) == int(1))))
			{
				R6Rainbow(instigatedBy).IncrementRoundsHit();
			}			
		}
		else
		{
			// End:0x1ED
			if(((instigatedBy != none) && (Level.Game.m_bCompilingStats == true)))
			{
				// End:0x1AF
				if((instigatedBy.PlayerReplicationInfo != none))
				{
					(instigatedBy.PlayerReplicationInfo.m_iRoundsHit++);					
				}
				else
				{
					_playerController = R6Pawn(instigatedBy).GetHumanLeaderForAIPawn();
					// End:0x1ED
					if((_playerController != none))
					{
						(_playerController.PlayerReplicationInfo.m_iRoundsHit++);
					}
				}
			}
		}
	}
	TakeHitLocation = vHitLocation;
	// End:0x239
	if((!IsAlive()))
	{
		// End:0x237
		if((int(Level.NetMode) != int(NM_DedicatedServer)))
		{
			KAddImpulse((Normal(vMomentum) * float(50000)), vHitLocation);
		}
		return 0;
	}
	// End:0x282
	if((int(Level.NetMode) == int(NM_Client)))
	{
		// End:0x27F
		if((m_bIsPlayer && R6PlayerController(Controller).GameReplicationInfo.m_bGameOverRep))
		{
			return 0;
		}		
	}
	else
	{
		// End:0x2C3
		if((Level.Game.m_bGameOver && (!R6AbstractGameInfo(Level.Game).m_bGameOverButAllowDeath)))
		{
			return 0;
		}
	}
	// End:0x2F9
	if(((int(m_ePawnType) == int(1)) && (!m_bIsPlayer)))
	{
		R6RainbowAI(Controller).IsBeingAttacked(instigatedBy);
	}
	// End:0x304
	if(InGodMode())
	{
		return 0;
	}
	eHitPart = WhichBodyPartWasHit(vHitLocation, vMomentum);
	m_eLastHitPart = eHitPart;
	// End:0x368
	if(((instigatedBy != none) && (instigatedBy.EngineWeapon != none)))
	{
		bIsSilenced = instigatedBy.EngineWeapon.m_bIsSilenced;		
	}
	else
	{
		bIsSilenced = false;
	}
	// End:0x8CE
	if((int(m_eHealth) != int(3)))
	{
		// End:0x3D7
		if((m_iForceKill != 0))
		{
			switch(m_iForceKill)
			{
				// End:0x3A1
				case 1:
					eKillFromTable = 0;
					// End:0x3D4
					break;
				// End:0x3B1
				case 2:
					eKillFromTable = 1;
					// End:0x3D4
					break;
				// End:0x3C1
				case 3:
					eKillFromTable = 2;
					// End:0x3D4
					break;
				// End:0x3D1
				case 4:
					eKillFromTable = 3;
					// End:0x3D4
					break;
				// End:0xFFFF
				default:
					break;
			}			
		}
		else
		{
			eKillFromTable = GetKillResult(iKillValue, int(eHitPart), int(m_eArmorType), iBulletToArmorModifier, bIsSilenced);
		}
		// End:0x463
		if(((m_iForceStun != 0) && (m_iForceStun < 5)))
		{
			switch(m_iForceStun)
			{
				// End:0x42D
				case 1:
					eStunFromTable = 0;
					// End:0x460
					break;
				// End:0x43D
				case 2:
					eStunFromTable = 1;
					// End:0x460
					break;
				// End:0x44D
				case 3:
					eStunFromTable = 2;
					// End:0x460
					break;
				// End:0x45D
				case 4:
					eStunFromTable = 3;
					// End:0x460
					break;
				// End:0xFFFF
				default:
					break;
			}			
		}
		else
		{
			eStunFromTable = GetStunResult(iStunValue, int(eHitPart), int(m_eArmorType), iBulletToArmorModifier, bIsSilenced);
		}
		vBulletDirection = Normal(vMomentum);
		BloodRotation = Rotator(vBulletDirection);
		BloodRotation.Roll = 0;
		// End:0x50B
		if(((!InGodMode()) && (int(eKillFromTable) != int(0))))
		{
			aBloodEffect = Spawn(Class'R6SFX.R6BloodEffect',,, vHitLocation);
			// End:0x50B
			if(((aBloodEffect != none) && (!_bAffectedActor)))
			{
				aBloodEffect.m_bPlayEffectSound = false;
			}
		}
		// End:0x538
		if((int(eKillFromTable) == int(3)))
		{
			BloodSplat = Spawn(Class'R6Engine.R6BloodSplat',,, vHitLocation, BloodRotation);			
		}
		else
		{
			// End:0x562
			if((int(eKillFromTable) != int(0)))
			{
				BloodSplat = Spawn(Class'R6Engine.R6BloodSplatSmall',,, vHitLocation, BloodRotation);
			}
		}
		// End:0x5A4
		if((int(m_iTracedBone) != 0))
		{
			m_rHitDirection = Rotator(vBulletDirection);
			// End:0x5A4
			if((int(Level.NetMode) != int(NM_Client)))
			{
				SetNextPendingAction(, int(m_iTracedBone));
			}
		}
		// End:0x619
		if((((int(eKillFromTable) == int(3)) || (((int(eKillFromTable) == int(2)) || (int(eKillFromTable) == int(1))) && (int(m_eHealth) == int(2)))) || ((int(eKillFromTable) == int(2)) && (int(m_eHealth) == int(1)))))
		{
			m_eHealth = 3;			
		}
		else
		{
			// End:0x658
			if(((int(eKillFromTable) == int(2)) || ((int(eKillFromTable) == int(1)) && (int(m_eHealth) == int(1)))))
			{
				m_eHealth = 2;				
			}
			else
			{
				// End:0x692
				if((int(eKillFromTable) == int(1)))
				{
					m_eHealth = 1;
					m_fHBWound = 1.2000000;
					// End:0x68C
					if(m_bIsClimbingLadder)
					{
						bIsWalking = true;
					}
					ChangeAnimation();
				}
			}
		}
		// End:0x75C
		if(((instigatedBy != none) && (R6PlayerController(instigatedBy.Controller) != none)))
		{
			// End:0x75C
			if(R6PlayerController(instigatedBy.Controller).m_bShowHitLogs)
			{
				Log(((((((((("Player HIT : " $ string(self)) $ " Bullet Energy : ") $ string(iKillValue)) $ " body part : ") $ string(eHitPart)) $ " KillResult : ") $ string(eKillFromTable)) $ " Armor type : ") $ string(m_eArmorType)));
			}
		}
		// End:0x81D
		if(((int(m_ePawnType) == int(1)) && (int(eKillFromTable) != int(0))))
		{
			// End:0x7C7
			if(m_bIsPlayer)
			{
				R6PlayerController(Controller).m_TeamManager.m_eMovementMode = 0;
				R6PlayerController(Controller).m_TeamManager.UpdateTeamStatus(self);				
			}
			else
			{
				// End:0x81D
				if((R6RainbowAI(Controller).m_TeamManager != none))
				{
					R6RainbowAI(Controller).m_TeamManager.m_eMovementMode = 0;
					R6RainbowAI(Controller).m_TeamManager.UpdateTeamStatus(self);
				}
			}
		}
		// End:0x872
		if((Controller != none))
		{
			Controller.R6DamageAttitudeTo(instigatedBy, eKillFromTable, eStunFromTable, vMomentum);
			// End:0x86F
			if((int(eKillFromTable) != int(0)))
			{
				Controller.PlaySoundDamage(instigatedBy);
			}			
		}
		// End:0x8CE
		if((int(eKillFromTable) != int(0)))
		{
			iStunValue = Min(iStunValue, 5000);
			vMomentum = (Normal(vMomentum) * float((iStunValue * 100)));
			// End:0x8CE
			if((!IsAlive()))
			{
				R6Died(instigatedBy, eHitPart, vMomentum);
			}
		}
	}
	iKillFromHit = GetThroughResult(iKillValue, int(eHitPart), vMomentum);
	// End:0x94B
	if((PlayerReplicationInfo != none))
	{
		switch(m_eHealth)
		{
			// End:0x912
			case 0:
				PlayerReplicationInfo.m_iHealth = 0;
				// End:0x94B
				break;
			// End:0x92A
			case 1:
				PlayerReplicationInfo.m_iHealth = 1;
				// End:0x94B
				break;
			// End:0x92F
			case 2:
			// End:0x948
			case 3:
				PlayerReplicationInfo.m_iHealth = 2;
				// End:0x94B
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		return iKillFromHit;
		return;
	}
}

//============================================================================
// R6Died
//      Called only on the server
//============================================================================
function R6Died(Pawn Killer, R6Pawn.eBodyPart eHitPart, Vector vMomentum)
{
	local R6AbstractGameInfo pGameInfo;
	local int i;
	local R6PlayerController P;
	local R6AbstractWeapon AWeapon;
	local string KillerName, szPlayerName;

	// End:0x30
	if((Killer == none))
	{
		Log(" R6Died() : WARNING : Killer=none");
	}
	// End:0x64
	if((Killer.PlayerReplicationInfo != none))
	{
		KillerName = Killer.PlayerReplicationInfo.PlayerName;		
	}
	else
	{
		KillerName = Killer.m_CharacterName;
	}
	// End:0x15F
	if((m_bIsClimbingLadder || (int(Physics) == int(11))))
	{
		// End:0x109
		if(((m_Ladder == none) || (m_Ladder.MyLadder == none)))
		{
			Log((((" R6Died() : WARNING : m_Ladder=" $ string(m_Ladder)) $ " m_Ladder.myLadder=") $ string(m_Ladder.MyLadder)));
		}
		R6LadderVolume(m_Ladder.MyLadder).RemoveClimber(self);
		// End:0x15F
		if((m_bIsPlayer && (m_Ladder != none)))
		{
			R6LadderVolume(m_Ladder.MyLadder).DisableCollisions(m_Ladder);
		}
	}
	// End:0x1AC
	if((int(Physics) == int(12)))
	{
		// End:0x18A
		if((Controller != none))
		{
			Controller.GotoState('None');
		}
		// End:0x1A1
		if(bIsCrouched)
		{
			PlayPostRootMotionAnimation(m_crouchDefaultAnimName);			
		}
		else
		{
			PlayPostRootMotionAnimation(m_standDefaultAnimName);
		}
	}
	AWeapon = R6AbstractWeapon(EngineWeapon);
	// End:0x1F6
	if(((AWeapon != none) && (AWeapon.m_SelectedWeaponGadget != none)))
	{
		AWeapon.m_SelectedWeaponGadget.ActivateGadget(false);
	}
	// End:0x220
	if((vMomentum == vect(0.0000000, 0.0000000, 0.0000000)))
	{
		vMomentum = vect(1.0000000, 1.0000000, 1.0000000);
	}
	TearOffMomentum = vMomentum;
	bAlwaysRelevant = true;
	i = 0;
	J0x23A:

	// End:0x277 [Loop If]
	if((i <= 3))
	{
		// End:0x26D
		if((m_WeaponsCarried[i] != none))
		{
			m_WeaponsCarried[i].SetRelevant(true);
		}
		(i++);
		// [Loop Continue]
		goto J0x23A;
	}
	m_bUseRagdoll = true;
	bProjTarget = false;
	SpawnRagDoll();
	m_KilledBy = R6Pawn(Killer);
	// End:0x2E0
	if(ProcessBuildDeathMessage(Killer, szPlayerName))
	{
		// End:0x2DF
		foreach DynamicActors(Class'R6Engine.R6PlayerController', P)
		{
			P.ClientDeathMessage(KillerName, szPlayerName, m_bSuicideType);			
		}		
	}
	// End:0x31B
	if((m_KilledBy == none))
	{
		Log(("  R6Died() : Warning!!  m_KilledBy=" $ string(m_KilledBy)));
	}
	// End:0x331
	if((m_KilledBy == self))
	{
		m_bSuicided = true;		
	}
	else
	{
		// End:0x34E
		if(IsEnemy(m_KilledBy))
		{
			m_KilledBy.IncrementFragCount();
		}
	}
	// End:0x394
	if((R6PlayerController(Controller) != none))
	{
		R6PlayerController(Controller).ClientDisableFirstPersonViewEffects();
		R6PlayerController(Controller).PlayerReplicationInfo.m_szKillersName = KillerName;
	}
	pGameInfo = R6AbstractGameInfo(Level.Game);
	// End:0x4FD
	if((pGameInfo != none))
	{
		// End:0x4D8
		if(((pGameInfo.m_bCompilingStats == true) || (pGameInfo.m_bGameOver && pGameInfo.m_bGameOverButAllowDeath)))
		{
			// End:0x49E
			if((Controller.PlayerReplicationInfo != none))
			{
				(Controller.PlayerReplicationInfo.Deaths += 1.0000000);
				// End:0x49B
				if(((((!m_bSuicided) && (m_KilledBy != none)) && (m_KilledBy.Controller != none)) && (m_KilledBy.Controller.PlayerReplicationInfo != none)))
				{
					(m_KilledBy.Controller.PlayerReplicationInfo.Score += 1.0000000);
				}				
			}
			else
			{
				P = R6PlayerController(GetHumanLeaderForAIPawn());
				// End:0x4D8
				if((P != none))
				{
					(P.PlayerReplicationInfo.Deaths += 1.0000000);
				}
			}
		}
		pGameInfo.PawnKilled(self);
		pGameInfo.SetTeamKillerPenalty(self, Killer);
	}
	return;
}

// this function should only be entered server side
function IncrementFragCount()
{
	local PlayerController _playerController;

	// End:0x44
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		// End:0x41
		if(Instigator.IsA('R6Rainbow'))
		{
			R6Rainbow(Instigator).IncrementKillCount();
		}		
	}
	else
	{
		// End:0xF1
		if(((Level.Game != none) && (Level.Game.m_bCompilingStats == true)))
		{
			// End:0xA8
			if((PlayerReplicationInfo != none))
			{
				(PlayerReplicationInfo.m_iKillCount += 1);
				(PlayerReplicationInfo.m_iRoundKillCount += 1);				
			}
			else
			{
				_playerController = GetHumanLeaderForAIPawn();
				// End:0xF1
				if((_playerController != none))
				{
					(_playerController.PlayerReplicationInfo.m_iKillCount++);
					(_playerController.PlayerReplicationInfo.m_iRoundKillCount++);
				}
			}
		}
	}
	return;
}

function ServerForceKillResult(int iKillResult)
{
	m_iForceKill = iKillResult;
	return;
}

function ServerForceStunResult(int iStunResult)
{
	m_iForceStun = iStunResult;
	return;
}

function ToggleHeatVision()
{
	// End:0x17
	if((Level.m_bHeartBeatOn == true))
	{
		return;
	}
	// End:0x14C
	if((m_bActivateScopeVision == true))
	{
		m_bActivateHeatVision = (!m_bActivateHeatVision);
		R6PlayerController(Controller).m_bHeatVisionActive = m_bActivateHeatVision;
		R6PlayerController(Controller).ServerToggleHeatVision(m_bActivateHeatVision);
		// End:0x9C
		if((m_bActivateNightVision == true))
		{
			m_bActivateNightVision = false;
			ToggleNightProperties(false, none, none);
			R6PlayerController(Controller).ClientPlaySound(m_sndNightVisionDeactivation, 3);
		}
		// End:0xF1
		if((m_bActivateHeatVision == true))
		{
			ToggleScopeProperties(false, none, none);
			ToggleHeatProperties(m_bActivateHeatVision, EngineWeapon.m_ScopeTexture, EngineWeapon.m_ScopeAdd);
			R6PlayerController(Controller).ClientPlaySound(m_sndThermalScopeActivation, 3);			
		}
		else
		{
			// End:0x14C
			if(((m_bActivateScopeVision == true) && (m_bActivateHeatVision == false)))
			{
				R6PlayerController(Controller).ClientPlaySound(m_sndThermalScopeDeactivation, 3);
				ToggleHeatProperties(false, none, none);
				ToggleScopeProperties(true, EngineWeapon.m_ScopeTexture, EngineWeapon.m_ScopeAdd);
			}
		}
	}
	return;
}

exec function ToggleNightVision()
{
	// End:0x17
	if((Level.m_bHeartBeatOn == true))
	{
		return;
	}
	m_bActivateNightVision = (!m_bActivateNightVision);
	// End:0x48
	if((R6Rainbow(self) != none))
	{
		R6Rainbow(self).ServerToggleNightVision(m_bActivateNightVision);
	}
	// End:0xB2
	if((m_bActivateHeatVision == true))
	{
		m_bActivateHeatVision = false;
		R6PlayerController(Controller).m_bHeatVisionActive = m_bActivateHeatVision;
		R6PlayerController(Controller).ServerToggleHeatVision(m_bActivateHeatVision);
		ToggleHeatProperties(false, none, none);
		R6PlayerController(Controller).ClientPlaySound(m_sndThermalScopeDeactivation, 3);
	}
	// End:0x12B
	if((((m_bActivateScopeVision == true) && (m_bActivateNightVision == true)) && (EngineWeapon.m_ScopeTexture != none)))
	{
		R6PlayerController(Controller).ClientPlaySound(m_sndNightVisionActivation, 3);
		ToggleScopeProperties(false, none, none);
		ToggleNightProperties(m_bActivateNightVision, EngineWeapon.m_ScopeTexture, EngineWeapon.m_ScopeAdd);		
	}
	else
	{
		// End:0x189
		if(((m_bActivateScopeVision == true) && (m_bActivateNightVision == false)))
		{
			R6PlayerController(Controller).ClientPlaySound(m_sndNightVisionDeactivation, 3);
			ToggleNightProperties(false, none, none);
			ToggleScopeProperties(true, EngineWeapon.m_ScopeTexture, EngineWeapon.m_ScopeAdd);			
		}
		else
		{
			// End:0x1B0
			if(m_bActivateNightVision)
			{
				R6PlayerController(Controller).ClientPlaySound(m_sndNightVisionActivation, 3);				
			}
			else
			{
				R6PlayerController(Controller).ClientPlaySound(m_sndNightVisionDeactivation, 3);
			}
			ToggleNightProperties(m_bActivateNightVision, Texture'Inventory_t.NightVision.NightVisionTex', none);
		}
	}
	return;
}

function ToggleScopeVision()
{
	// End:0x17
	if((Level.m_bHeartBeatOn == true))
	{
		return;
	}
	// End:0x32
	if((int(Level.NetMode) == int(NM_DedicatedServer)))
	{
		return;
	}
	m_bActivateScopeVision = (!m_bActivateScopeVision);
	// End:0x83
	if(((m_bActivateNightVision == false) && (m_bActivateHeatVision == false)))
	{
		ToggleScopeProperties(m_bActivateScopeVision, EngineWeapon.m_ScopeTexture, EngineWeapon.m_ScopeAdd);		
	}
	else
	{
		// End:0xE1
		if((m_bActivateNightVision == true))
		{
			// End:0xD4
			if(((m_bActivateScopeVision == true) && (EngineWeapon.m_ScopeTexture != none)))
			{
				ToggleNightProperties(true, EngineWeapon.m_ScopeTexture, EngineWeapon.m_ScopeAdd);				
			}
			else
			{
				ToggleNightProperties(true, Texture'Inventory_t.NightVision.NightVisionTex', none);
			}			
		}
		else
		{
			// End:0x15F
			if((m_bActivateHeatVision == true))
			{
				// End:0x11C
				if((m_bActivateScopeVision == true))
				{
					ToggleHeatProperties(true, EngineWeapon.m_ScopeTexture, EngineWeapon.m_ScopeAdd);					
				}
				else
				{
					m_bActivateHeatVision = false;
					R6PlayerController(Controller).m_bHeatVisionActive = m_bActivateHeatVision;
					R6PlayerController(Controller).ServerToggleHeatVision(m_bActivateHeatVision);
					ToggleHeatProperties(false, none, none);
				}
			}
		}
	}
	return;
}

exec function ToggleGadget()
{
	local R6AbstractWeapon AWeapon;

	AWeapon = R6AbstractWeapon(EngineWeapon);
	// End:0x72
	if(((AWeapon != none) && (AWeapon.m_SelectedWeaponGadget != none)))
	{
		m_bWeaponGadgetActivated = (!m_bWeaponGadgetActivated);
		AWeapon.m_SelectedWeaponGadget.ActivateGadget(m_bWeaponGadgetActivated, R6PlayerController(Controller).bBehindView);
	}
	return;
}

///////////////////
// RELOAD WEAPON //
///////////////////
function ReloadWeapon()
{
	EngineWeapon.PlayReloading();
	return;
}

//Notify function
simulated function ReloadingWeaponEnd()
{
	// End:0x55
	if(((!m_bIsPlayer) || (!((Controller != none) && (R6PlayerController(Controller).bBehindView == false)))))
	{
		EngineWeapon.ChangeClip();
		EngineWeapon.GotoState('None');
	}
	return;
}

//For rainbow when using Bolt Action rifles.
simulated function BoltActionSwitchToRight()
{
	return;
}

//Notify Function
// will always close the bipod at the beginning of an animation
simulated function WeaponBipod()
{
	local bool bSetBipod;
	local R6AbstractWeapon pWeaponWithTheBipod;

	pWeaponWithTheBipod = R6AbstractWeapon(EngineWeapon);
	// End:0x34
	if(((EngineWeapon == PendingWeapon) || (PendingWeapon == none)))
	{
		bSetBipod = false;
	}
	// End:0x7E
	if(((int(Level.NetMode) == int(NM_DedicatedServer)) || (int(Level.NetMode) == int(NM_ListenServer))))
	{
		pWeaponWithTheBipod.m_bDeployBipod = bSetBipod;
	}
	// End:0xC7
	if(((int(Level.NetMode) == int(NM_Standalone)) || (int(Level.NetMode) == int(NM_ListenServer))))
	{
		pWeaponWithTheBipod.DeployWeaponBipod(bSetBipod);
	}
	return;
}

// Will always open the bipod at the end of an animation
simulated function WeaponBipodLast()
{
	local bool bSetBipod;
	local R6AbstractWeapon pWeaponWithTheBipod;

	pWeaponWithTheBipod = R6AbstractWeapon(EngineWeapon);
	// End:0x3C
	if(((EngineWeapon == PendingWeapon) || (PendingWeapon == none)))
	{
		bSetBipod = m_bWantsToProne;		
	}
	else
	{
		// End:0x66
		if(PendingWeapon.GotBipod())
		{
			pWeaponWithTheBipod = R6AbstractWeapon(PendingWeapon);
			bSetBipod = true;
		}
	}
	// End:0xB0
	if(((int(Level.NetMode) == int(NM_DedicatedServer)) || (int(Level.NetMode) == int(NM_ListenServer))))
	{
		pWeaponWithTheBipod.m_bDeployBipod = bSetBipod;
	}
	// End:0xF9
	if(((int(Level.NetMode) == int(NM_Standalone)) || (int(Level.NetMode) == int(NM_ListenServer))))
	{
		pWeaponWithTheBipod.DeployWeaponBipod(bSetBipod);
	}
	return;
}

function ServerPlayReloadAnimAgain()
{
	m_bReloadAnimLoop = (!m_bReloadAnimLoop);
	return;
}

simulated function PutShellInWeapon()
{
	// End:0x45
	if(((!m_bIsPlayer) || (!((Controller != none) && (R6PlayerController(Controller).bBehindView == false)))))
	{
		EngineWeapon.ServerPutBulletInShotgun();
	}
	return;
}

simulated function float PrepareDemolitionsAnimation()
{
	local float fSkillDemolitions;

	fSkillDemolitions = GetSkill(1);
	R6ResetAnimBlendParams(13);
	m_ePlayerIsUsingHands = 3;
	PlayWeaponAnimation();
	m_bPostureTransition = true;
	AnimBlendParams(1, 1.0000000, 0.0000000, 0.0000000);
	// End:0x5E
	if((Controller != none))
	{
		Controller.PlaySoundCurrentAction(6);
	}
	// End:0x76
	if((fSkillDemolitions < 0.6000000))
	{
		return 0.8000000;		
	}
	else
	{
		return (0.8000000 + (((fSkillDemolitions - 0.6000000) / 0.4000000) * 0.4500000));
	}
	return;
}

simulated function PlayClaymoreAnimation()
{
	local float fAnimRate, fTween;

	// End:0x4E
	if(((Controller != none) && (!Controller.IsInState('PlayerSetExplosive'))))
	{
		// End:0x4C
		if((int(Controller.bFire) == 1))
		{
			Controller.GotoState('PlayerSetExplosive');			
		}
		else
		{
			return;
		}
	}
	fAnimRate = PrepareDemolitionsAnimation();
	// End:0x92
	if(m_bIsProne)
	{
		fTween = (0.2000000 / m_fGadgetSpeedMultiplier);
		PlayAnim('ProneClaymore', (fAnimRate * m_fGadgetSpeedMultiplier), fTween, 1);		
	}
	else
	{
		// End:0xAF
		if((!bIsCrouched))
		{
			fTween = (1.0000000 / m_fGadgetSpeedMultiplier);
		}
		PlayAnim('CrouchClaymore', (fAnimRate * m_fGadgetSpeedMultiplier), fTween, 1);
	}
	return;
}

simulated function PlayRemoteChargeAnimation()
{
	local float fAnimRate, fTween;

	// End:0x4E
	if(((Controller != none) && (!Controller.IsInState('PlayerSetExplosive'))))
	{
		// End:0x4C
		if((int(Controller.bFire) == 1))
		{
			Controller.GotoState('PlayerSetExplosive');			
		}
		else
		{
			return;
		}
	}
	fAnimRate = PrepareDemolitionsAnimation();
	// End:0x92
	if(m_bIsProne)
	{
		fTween = (0.2000000 / m_fGadgetSpeedMultiplier);
		PlayAnim('ProneC4', (fAnimRate * m_fGadgetSpeedMultiplier), fTween, 1);		
	}
	else
	{
		// End:0xAF
		if((!bIsCrouched))
		{
			fTween = (1.0000000 / m_fGadgetSpeedMultiplier);
		}
		PlayAnim('CrouchC4', (fAnimRate * m_fGadgetSpeedMultiplier), fTween, 1);
	}
	return;
}

simulated function PlayBreachDoorAnimation()
{
	local float fAnimRate;

	// End:0x59
	if(((m_bIsPlayer && (Controller != none)) && (!Controller.IsInState('PlayerSetExplosive'))))
	{
		// End:0x57
		if((int(Controller.bFire) == 1))
		{
			Controller.GotoState('PlayerSetExplosive');			
		}
		else
		{
			return;
		}
	}
	fAnimRate = PrepareDemolitionsAnimation();
	// End:0x8B
	if(bIsCrouched)
	{
		PlayAnim('CrouchPlaceBreach', (fAnimRate * m_fGadgetSpeedMultiplier), 0.0000000, 1);		
	}
	else
	{
		PlayAnim('StandPlaceBreach', (fAnimRate * m_fGadgetSpeedMultiplier), 0.0000000, 1);
	}
	return;
}

simulated function PlayInteractWithDeviceAnimation()
{
	local float fAnimRate, fSkillDevice;

	// End:0x33
	if(((int(m_eDeviceAnim) == int(1)) || (int(m_eDeviceAnim) == int(0))))
	{
		fSkillDevice = GetSkill(1);		
	}
	else
	{
		fSkillDevice = GetSkill(2);
	}
	// End:0x7A
	if((fSkillDevice < 0.8000000))
	{
		fAnimRate = (1.0000000 + (((0.8000000 - fSkillDevice) / 0.8000000) * 0.2500000));		
	}
	else
	{
		fAnimRate = (0.8000000 + (((float(1) - fSkillDevice) / 0.2000000) * 0.2000000));
	}
	R6ResetAnimBlendParams(13);
	m_ePlayerIsUsingHands = 3;
	PlayWeaponAnimation();
	m_bPostureTransition = true;
	AnimBlendParams(1, 1.0000000, 0.0000000, 0.0000000);
	switch(m_eDeviceAnim)
	{
		// End:0x130
		case 2:
			// End:0xFB
			if((Controller != none))
			{
				Controller.PlaySoundCurrentAction(8);
			}
			// End:0x11A
			if(bIsCrouched)
			{
				LoopAnim('CrouchKeyPad_c', fAnimRate, 0.5000000, 1);				
			}
			else
			{
				LoopAnim('StandKeyPad_c', fAnimRate, 0.5000000, 1);
			}
			// End:0x1FF
			break;
		// End:0x135
		case 0:
		// End:0x150
		case 1:
			LoopAnim('CrouchDisarmBomb_c', fAnimRate, 0.5000000, 1);
			// End:0x1FF
			break;
		// End:0x1A6
		case 3:
			// End:0x171
			if((Controller != none))
			{
				Controller.PlaySoundCurrentAction(0);
			}
			// End:0x190
			if(bIsCrouched)
			{
				LoopAnim('CrouchPlaceBug_c', fAnimRate, 0.5000000, 1);				
			}
			else
			{
				LoopAnim('StandPlaceBug_c', fAnimRate, 0.5000000, 1);
			}
			// End:0x1FF
			break;
		// End:0x1FC
		case 4:
			// End:0x1C7
			if((Controller != none))
			{
				Controller.PlaySoundCurrentAction(2);
			}
			// End:0x1E6
			if(bIsCrouched)
			{
				LoopAnim('CrouchKeyboard_c', fAnimRate, 0.5000000, 1);				
			}
			else
			{
				LoopAnim('StandKeyboard_c', fAnimRate, 0.5000000, 1);
			}
			// End:0x1FF
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

//============================================================================
// function PlayProneFireAnimation - 
//============================================================================
simulated function PlayProneFireAnimation()
{
	local name animName;
	local float fRatio;

	// End:0x12
	if((int(m_ePawnType) == int(2)))
	{
		return;
	}
	fRatio = 100.0000000;
	// End:0x80
	if((m_iRepBipodRotationRatio > 0))
	{
		// End:0x4B
		if((EngineWeapon.IsLMG() == true))
		{
			animName = 'ProneBipodRightFireLMG';			
		}
		else
		{
			// End:0x72
			if((EngineWeapon.GetProneFiringAnimName() == 'ProneBipodFireAndBoltRifle'))
			{
				animName = 'ProneBipodRightFireAndBoltRifle';				
			}
			else
			{
				animName = 'ProneBipodRightFireSniper';
			}
		}		
	}
	else
	{
		// End:0xA3
		if((EngineWeapon.IsLMG() == true))
		{
			animName = 'ProneBipodLeftFireLMG';			
		}
		else
		{
			// End:0xCA
			if((EngineWeapon.GetProneFiringAnimName() == 'ProneBipodFireAndBoltRifle'))
			{
				animName = 'ProneBipodLeftFireAndBoltRifle';				
			}
			else
			{
				animName = 'ProneBipodLeftFireSniper';
			}
		}
	}
	// End:0x112
	if((IsLocallyControlled() && (int(Level.NetMode) != int(NM_Standalone))))
	{
		fRatio = Abs((m_fBipodRotation / float(5600)));		
	}
	else
	{
		fRatio = Abs((float(m_iRepBipodRotationRatio) / fRatio));
	}
	AnimBlendParams(12, fRatio, 0.0000000, 0.0000000, 'R6');
	PlayAnim(animName, 1.5000000, 0.0000000, 12);
	return;
}

//============================================================================
simulated function bool GetReloadWeaponAnimation(out STWeaponAnim stAnim)
{
	return false;
	return;
}

simulated function bool GetChangeWeaponAnimation(out STWeaponAnim stAnim)
{
	return false;
	return;
}

simulated function bool GetFireWeaponAnimation(out STWeaponAnim stAnim)
{
	return false;
	return;
}

simulated function bool GetThrowGrenadeAnimation(out STWeaponAnim stAnim)
{
	return false;
	return;
}

simulated function bool GetNormalWeaponAnimation(out STWeaponAnim stAnim)
{
	return false;
	return;
}

simulated function bool GetPawnSpecificAnimation(out STWeaponAnim stAnim)
{
	return false;
	return;
}

simulated function bool HasPawnSpecificWeaponAnimation()
{
	return false;
	return;
}

//============================================================================
// event PlayWeaponAnimation - 
//============================================================================
simulated event PlayWeaponAnimation()
{
	local STWeaponAnim stAnim;
	local bool bContinue;

	// End:0x16
	if((m_bWeaponTransition || m_bPostureTransition))
	{
		return;
	}
	// End:0x56
	if((int(m_ePlayerIsUsingHands) == int(3)))
	{
		// End:0x54
		if((int(m_eLastUsingHands) != int(m_ePlayerIsUsingHands)))
		{
			m_eLastUsingHands = m_ePlayerIsUsingHands;
			R6ResetAnimBlendParams(14);
			R6ResetAnimBlendParams(15);
		}
		return;
	}
	// End:0x76
	if((EngineWeapon == none))
	{
		bContinue = GetNormalWeaponAnimation(stAnim);		
	}
	else
	{
		// End:0x94
		if(HasPawnSpecificWeaponAnimation())
		{
			bContinue = GetPawnSpecificAnimation(stAnim);			
		}
		else
		{
			// End:0xB2
			if(m_bReloadingWeapon)
			{
				bContinue = GetReloadWeaponAnimation(stAnim);				
			}
			else
			{
				// End:0xD0
				if(m_bChangingWeapon)
				{
					bContinue = GetChangeWeaponAnimation(stAnim);					
				}
				else
				{
					// End:0x10B
					if((EngineWeapon.bFiredABullet == true))
					{
						bContinue = GetFireWeaponAnimation(stAnim);
						EngineWeapon.bFiredABullet = false;						
					}
					else
					{
						// End:0x130
						if((int(m_eGrenadeThrow) != int(0)))
						{
							bContinue = GetThrowGrenadeAnimation(stAnim);							
						}
						else
						{
							bContinue = GetNormalWeaponAnimation(stAnim);
						}
					}
				}
			}
		}
	}
	// End:0x154
	if((m_bReAttachToRightHand == true))
	{
		BoltActionSwitchToRight();
	}
	// End:0x345
	if(bContinue)
	{
		// End:0x345
		if(((m_bPreviousAnimPlayOnce || (m_WeaponAnimPlaying != stAnim.nAnimToPlay)) || (int(m_eLastUsingHands) != int(m_ePlayerIsUsingHands))))
		{
			m_bPreviousAnimPlayOnce = stAnim.bPlayOnce;
			m_eLastUsingHands = m_ePlayerIsUsingHands;
			// End:0x25E
			if(((int(m_ePlayerIsUsingHands) == int(0)) || (int(m_ePlayerIsUsingHands) == int(2))))
			{
				AnimBlendParams(14, 1.0000000,,, stAnim.nBlendName);
				// End:0x228
				if(stAnim.bPlayOnce)
				{
					PlayAnim(stAnim.nAnimToPlay, stAnim.fRate, stAnim.fTweenTime, 14, stAnim.bBackward);					
				}
				else
				{
					LoopAnim(stAnim.nAnimToPlay, stAnim.fRate, stAnim.fTweenTime, 14);
				}
				m_WeaponAnimPlaying = stAnim.nAnimToPlay;				
			}
			else
			{
				// End:0x271
				if((!m_bNightVisionAnimation))
				{
					R6ResetAnimBlendParams(14);
				}
			}
			// End:0x332
			if((((int(m_ePlayerIsUsingHands) == int(0)) || (int(m_ePlayerIsUsingHands) == int(1))) && (stAnim.nBlendName == 'R6 R Clavicle')))
			{
				AnimBlendParams(15, 1.0000000,,, 'R6 L Clavicle');
				// End:0x2FC
				if(stAnim.bPlayOnce)
				{
					PlayAnim(stAnim.nAnimToPlay, stAnim.fRate, stAnim.fTweenTime, 15, stAnim.bBackward);					
				}
				else
				{
					LoopAnim(stAnim.nAnimToPlay, stAnim.fRate, stAnim.fTweenTime, 15);
					m_WeaponAnimPlaying = stAnim.nAnimToPlay;
				}				
			}
			else
			{
				// End:0x345
				if((!m_bNightVisionAnimation))
				{
					R6ResetAnimBlendParams(15);
				}
			}
		}
	}
	return;
}

//============================================================================
// ServerChangedWeapon - 
//============================================================================
function ServerChangedWeapon(R6EngineWeapon OldWeapon, R6EngineWeapon W)
{
	local Vector vTagLocation;
	local Rotator rTagRotator;

	// End:0x0D
	if((W == none))
	{
		return;
	}
	// End:0x32
	if((OldWeapon != none))
	{
		OldWeapon.SetDefaultDisplayProperties();
		DetachFromBone(OldWeapon);
	}
	EngineWeapon = W;
	m_pBulletManager.SetBulletParameter(EngineWeapon);
	AttachWeapon(EngineWeapon, EngineWeapon.m_AttachPoint);
	EngineWeapon.SetRelativeLocation(vect(0.0000000, 0.0000000, 0.0000000));
	// End:0xA5
	if((int(Level.NetMode) == int(NM_ListenServer)))
	{
		PlayWeaponAnimation();
	}
	return;
}

//Notify called by the animations ro attach the weapon to the left hand for reloading.
simulated function GetClipInHand()
{
	// End:0xB8
	if(((R6AbstractWeapon(EngineWeapon) != none) && (R6AbstractWeapon(EngineWeapon).m_MagazineGadget != none)))
	{
		R6AbstractWeapon(EngineWeapon).m_MagazineGadget.SetBase(none);
		AttachToBone(R6AbstractWeapon(EngineWeapon).m_MagazineGadget, 'TagMagazineHand');
		R6AbstractWeapon(EngineWeapon).m_MagazineGadget.SetRelativeLocation(vect(0.0000000, 0.0000000, 0.0000000));
		R6AbstractWeapon(EngineWeapon).m_MagazineGadget.SetRelativeRotation(rot(0, 0, 0));
	}
	return;
}

// Notify called to attach the magazine to the weapon once reload is over
simulated function AttachClipToWeapon()
{
	// End:0x54
	if((R6AbstractWeapon(EngineWeapon).m_MagazineGadget != none))
	{
		DetachFromBone(R6AbstractWeapon(EngineWeapon).m_MagazineGadget);
		R6AbstractWeapon(EngineWeapon).m_MagazineGadget.UpdateAttachment(EngineWeapon);
	}
	return;
}

// Notify function for foot on ladder
simulated function FootStepLadder()
{
	// End:0x2C
	if((m_Ladder != none))
	{
		SendPlaySound(R6LadderVolume(m_Ladder.MyLadder).m_FootSound, 3);
	}
	return;
}

// Notify function for Hands on ladder
simulated function HandGripLadder()
{
	// End:0x2C
	if((m_Ladder != none))
	{
		SendPlaySound(R6LadderVolume(m_Ladder.MyLadder).m_HandSound, 3);
	}
	return;
}

// Notify function for footsteps
simulated function FootStepRight()
{
	m_bLeftFootDown = false;
	FootStep('R6 R Foot', false);
	return;
}

// Notify function for footsteps
simulated function FootStepLeft()
{
	m_bLeftFootDown = true;
	FootStep('R6 L Foot', true);
	return;
}

// Notify function for Surface. Can be call for other notify also.
simulated event PlaySurfaceSwitch()
{
	// End:0x26
	if((int(m_ePawnType) == int(1)))
	{
		SendPlaySound(Level.m_SurfaceSwitchSnd, 3);		
	}
	else
	{
		SendPlaySound(Level.m_SurfaceSwitchForOtherPawnSnd, 3);
	}
	return;
}

//============================================================================
// IsFighting: return true when the pawn is in active combat (ie: a threat)
//============================================================================
function bool IsFighting()
{
	return false;
	return;
}

//===================================================================================================
// IsStationary
//   21 jan 2002 rbrek - check only acceleration.  velocity is only set to (0,0,0) a few ticks later...
//===================================================================================================
function bool IsStationary()
{
	// End:0x35
	if(((Velocity == vect(0.0000000, 0.0000000, 0.0000000)) && (Acceleration == vect(0.0000000, 0.0000000, 0.0000000))))
	{
		return true;		
	}
	else
	{
		return false;
	}
	return;
}

simulated function bool CheckForPassiveGadget(string aClassName)
{
	return false;
	return;
}

function CreateBulletManager()
{
	local Class<R6AbstractBulletManager> aBulletMgrClass;

	aBulletMgrClass = Class<R6AbstractBulletManager>(DynamicLoadObject("R6Weapons.R6BulletManager", Class'Core.Class'));
	m_pBulletManager = Spawn(aBulletMgrClass);
	// End:0x5A
	if((m_pBulletManager != none))
	{
		m_pBulletManager.InitBulletMgr(self);
	}
	return;
}

simulated function ServerGivesWeaponToClient(string aClassName, int iWeaponOrItemSlot, optional string bulletType, optional string weaponGadget)
{
	local Class<R6AbstractWeapon> WeaponClass;
	local R6AbstractWeapon NewWeapon;

	// End:0x11
	if((m_pBulletManager == none))
	{
		CreateBulletManager();
	}
	// End:0x40
	if((iWeaponOrItemSlot == 4))
	{
		// End:0x3D
		if(((m_WeaponsCarried[2] != none) && (m_WeaponsCarried[3] != none)))
		{
			return;
		}		
	}
	else
	{
		// End:0x56
		if((m_WeaponsCarried[(iWeaponOrItemSlot - 1)] != none))
		{
			return;
		}
	}
	// End:0xAC
	if((m_SoundRepInfo != none))
	{
		// End:0x90
		if(((iWeaponOrItemSlot == 2) && (m_WeaponsCarried[0] == none)))
		{
			m_SoundRepInfo.m_CurrentWeapon = 1;			
		}
		else
		{
			// End:0xAC
			if((iWeaponOrItemSlot == 1))
			{
				m_SoundRepInfo.m_CurrentWeapon = 0;
			}
		}
	}
	// End:0xBC
	if(CheckForPassiveGadget(aClassName))
	{
		return;
	}
	WeaponClass = Class<R6AbstractWeapon>(DynamicLoadObject(aClassName, Class'Core.Class'));
	NewWeapon = Spawn(WeaponClass, self);
	// End:0x25C
	if((NewWeapon != none))
	{
		NewWeapon.m_InventoryGroup = iWeaponOrItemSlot;
		// End:0x132
		if(((iWeaponOrItemSlot == 4) && (m_WeaponsCarried[2] == none)))
		{
			NewWeapon.m_InventoryGroup = 3;
		}
		NewWeapon.SetHoldAttachPoint();
		// End:0x16B
		if((int(Level.NetMode) != int(NM_Standalone)))
		{
			NewWeapon.RemoteRole = ROLE_AutonomousProxy;
		}
		NewWeapon.Instigator = self;
		// End:0x1C7
		if((int(m_ePawnType) == int(1)))
		{
			AttachWeapon(NewWeapon, NewWeapon.m_HoldAttachPoint);
			// End:0x1C7
			if(NewWeapon.m_bHiddenWhenNotInUse)
			{
				NewWeapon.bHidden = true;
			}
		}
		// End:0x1F7
		if((weaponGadget != ""))
		{
			NewWeapon.m_WeaponGadgetClass = Class<R6AbstractGadget>(DynamicLoadObject(weaponGadget, Class'Core.Class'));
		}
		// End:0x21F
		if((int(Level.NetMode) != int(NM_DedicatedServer)))
		{
			NewWeapon.SetGadgets();
		}
		// End:0x23F
		if((bulletType != ""))
		{
			NewWeapon.GiveBulletToWeapon(bulletType);
		}
		m_WeaponsCarried[(NewWeapon.m_InventoryGroup - 1)] = NewWeapon;
	}
	return;
}

//Defined in R6Rainbow.uc
simulated function GetWeapon(R6AbstractWeapon NewWeapon)
{
	return;
}

simulated function R6EngineWeapon GetWeaponInGroup(int iGroup)
{
	// End:0x5F
	if((iGroup == 0))
	{
		Log((string(self) $ "  Error : GetWeaponInGroup() : iGroup==0));
		return none;
	}
	return m_WeaponsCarried[(iGroup - 1)];
	return;
}

simulated function AttachWeapon(R6EngineWeapon WeaponToAttach, name Attachment)
{
	// End:0x0D
	if((WeaponToAttach == none))
	{
		return;
	}
	// End:0x4A
	if((WeaponToAttach.bNetOwner || (int(WeaponToAttach.Role) == int(ROLE_Authority))))
	{
		AttachToBone(WeaponToAttach, Attachment);
	}
	return;
}

//------------------------------------------------------------------
// AttachCollisionBox
//  iNbOfColBox
//------------------------------------------------------------------
simulated function AttachCollisionBox(int iNbOfColBox)
{
	// End:0x27
	if(((m_collisionBox == none) && (1 <= iNbOfColBox)))
	{
		m_collisionBox = Spawn(Class'Engine.R6ColBox', self);
	}
	// End:0xB6
	if((((m_collisionBox2 == none) && (m_collisionBox != none)) && (2 <= iNbOfColBox)))
	{
		m_collisionBox2 = Spawn(Class'Engine.R6ColBox', m_collisionBox);
		m_collisionBox2.SetCollision(false, false, false);
		m_collisionBox2.bCollideWorld = false;
		m_collisionBox2.bBlockActors = false;
		m_collisionBox2.bBlockPlayers = false;
		m_collisionBox2.m_fFeetColBoxRadius = 28.0000000;
	}
	return;
}

event float GetStanceReticuleModifier()
{
	// End:0x2D
	if(m_bIsProne)
	{
		// End:0x24
		if(EngineWeapon.GotBipod())
		{
			return 1.3000000;			
		}
		else
		{
			return 1.2000000;
		}		
	}
	else
	{
		// End:0x3C
		if(bIsCrouched)
		{
			return 1.1000000;
		}
	}
	return 1.0000000;
	return;
}

function float GetStanceJumpModifier()
{
	// End:0x2D
	if(m_bIsProne)
	{
		// End:0x24
		if(EngineWeapon.GotBipod())
		{
			return 0.5500000;			
		}
		else
		{
			return 0.7500000;
		}		
	}
	else
	{
		// End:0x3C
		if(bIsCrouched)
		{
			return 0.8500000;
		}
	}
	return 1.0000000;
	return;
}

//------------------------------------------------------------------
// CanBeAffectedByGrenade: return true if can be affected by the grenade 
//   at this moment
//------------------------------------------------------------------
simulated function bool CanBeAffectedByGrenade(Actor aGrenade, Pawn.EGrenadeType eType)
{
	// End:0x18
	if((m_bIsClimbingLadder || (m_climbObject != none)))
	{
		return false;
	}
	return true;
	return;
}

//============================================================================
// function R6ClientAffectedByFlashbang - 
//============================================================================
simulated function R6ClientAffectedByFlashbang(Vector vGrenadeLocation)
{
	m_vGrenadeLocation = vGrenadeLocation;
	m_eEffectiveGrenade = 3;
	m_bFlashBangVisualEffectRequested = true;
	m_fRemainingGrenadeTime = 5.0000000;
	return;
}

//============================================================================
// AffectedByGrenade - 
//============================================================================
function AffectedByGrenade(Actor aGrenade, Pawn.EGrenadeType eType)
{
	local R6AIController AIController;

	m_fRemainingGrenadeTime = 5.0000000;
	// End:0x58
	if((int(m_eEffectiveGrenade) != int(eType)))
	{
		// End:0x39
		if((int(m_eEffectiveGrenade) != int(0)))
		{
			EndOfGrenadeEffect(m_eEffectiveGrenade);
		}
		m_eEffectiveGrenade = eType;
		m_fTimeGrenadeEffectBeforeSound = Level.TimeSeconds;
	}
	// End:0xBE
	if((((int(eType) != int(2)) || (!m_bHaveGasMask)) && CanBeAffectedByGrenade(aGrenade, eType)))
	{
		AIController = R6AIController(Controller);
		// End:0xBE
		if((AIController != none))
		{
			AIController.AIAffectedByGrenade(aGrenade, eType);
		}
	}
	// End:0xF8
	if(((int(eType) == int(3)) && m_bIsPlayer))
	{
		m_vGrenadeLocation = aGrenade.Location;
		R6ClientAffectedByFlashbang(m_vGrenadeLocation);
	}
	// End:0x169
	if(((!m_bHaveGasMask) && (Level.TimeSeconds > m_fTimeGrenadeEffectBeforeSound)))
	{
		m_fTimeGrenadeEffectBeforeSound = ((Level.TimeSeconds + 7.0000000) + RandRange(0.0000000, 6.0000000));
		// End:0x169
		if((Controller != none))
		{
			Controller.PlaySoundAffectedByGrenade(eType);
		}
	}
	return;
}

event EndOfGrenadeEffect(Pawn.EGrenadeType eType)
{
	return;
}

//============================================================================
// SetRandomWaiting - 
//============================================================================
function SetRandomWaiting(int iMax, optional bool bDontUseWaitZero)
{
	// End:0x6C
	if((int(Role) == int(ROLE_Authority)))
	{
		// End:0x24
		if(m_bEngaged)
		{
			m_bRepPlayWaitAnim = 0;			
		}
		else
		{
			// End:0x5D
			if((bDontUseWaitZero || (int(m_byRemainingWaitZero) <= 0)))
			{
				m_byRemainingWaitZero = byte((Rand(5) + 1));
				m_bRepPlayWaitAnim = byte(Rand(iMax));				
			}
			else
			{
				(m_byRemainingWaitZero--);
				m_bRepPlayWaitAnim = 0;
			}
		}
	}
	return;
}

//============================================================================
// SetNextPendingAction - 
//============================================================================
function SetNextPendingAction(R6Pawn.EPendingAction eAction, optional int i)
{
	// End:0x58
	if((int(Level.NetMode) == int(NM_Client)))
	{
		logWarning((" client shouldn't call SetNextPendingAction " $ string(eAction)));
		return;
	}
	(m_iNetCurrentActionIndex++);
	// End:0x75
	if((int(m_iNetCurrentActionIndex) >= 5))
	{
		m_iNetCurrentActionIndex = 0;
	}
	m_ePendingAction[int(m_iNetCurrentActionIndex)] = eAction;
	m_iPendingActionInt[int(m_iNetCurrentActionIndex)] = i;
	// End:0xFA
	if((int(Level.NetMode) != int(NM_Client)))
	{
		(m_iLocalCurrentActionIndex++);
		// End:0xD1
		if((int(m_iLocalCurrentActionIndex) >= 5))
		{
			m_iLocalCurrentActionIndex = 0;
		}
		// End:0xFA
		if(IsAlive())
		{
			PlaySpecialPendingAction(m_ePendingAction[int(m_iLocalCurrentActionIndex)], m_iPendingActionInt[int(m_iLocalCurrentActionIndex)]);
		}
	}
	return;
}

//============================================================================
// PlaySpecialPendingAction - Called from UpdateMovementAnimation to
//                            play special animation on all clients
//============================================================================
simulated event PlaySpecialPendingAction(R6Pawn.EPendingAction eAction, int iActionInt)
{
	switch(eAction)
	{
		// End:0x0F
		case 0:
			// End:0x12E
			break;
		// End:0x1D
		case 1:
			PlayCoughing();
			// End:0x12E
			break;
		// End:0x2B
		case 3:
			PlayBlinded();
			// End:0x12E
			break;
		// End:0x52
		case 4:
			// End:0x4F
			if((m_Door != none))
			{
				PlayDoorAnim(m_Door.m_RotatingDoor);
			}
			// End:0x12E
			break;
		// End:0x60
		case 18:
			PlayInteractWithDeviceAnimation();
			// End:0x12E
			break;
		// End:0x6E
		case 5:
			PlayStartClimbing();
			// End:0x12E
			break;
		// End:0x7C
		case 6:
			PlayPostStartLadder();
			// End:0x12E
			break;
		// End:0x8A
		case 7:
			PlayEndClimbing();
			// End:0x12E
			break;
		// End:0x98
		case 8:
			PlayPostEndLadder();
			// End:0x12E
			break;
		// End:0xA6
		case 9:
			DropWeaponToGround();
			// End:0x12E
			break;
		// End:0xB4
		case 11:
			PlayCrouchToProne();
			// End:0x12E
			break;
		// End:0xC2
		case 10:
			PlayProneToCrouch();
			// End:0x12E
			break;
		// End:0xDF
		case 12:
			MoveHitBone(m_rHitDirection, m_iPendingActionInt[int(m_iLocalCurrentActionIndex)]);
			// End:0x12E
			break;
		// End:0xFFFF
		default:
			logWarning((("Received PlaySpecialPendingAction not defined for " $ string(eAction)) @ string(iActionInt)));
			break;
	}
	return;
}

simulated function PlayCoughing()
{
	return;
}

simulated function PlayBlinded()
{
	return;
}

//============================================================================
// KImpact - 
//============================================================================
event KImpact(Actor Other, Vector pos, Vector impactVel, Vector impactNorm)
{
	local Vector vHitLocation, vHitNormal;

	// End:0xC8
	if((Level.TimeSeconds > m_fTimeStartBodyFallSound))
	{
		// End:0x39
		if((int(Level.NetMode) != int(NM_Client)))
		{
			R6MakeNoise();
		}
		R6Trace(vHitLocation, vHitNormal, (pos - vect(0.0000000, 0.0000000, 50.0000000)), (pos + vect(0.0000000, 0.0000000, 10.0000000)), 8,, m_HitMaterial);
		m_fTimeStartBodyFallSound = (Level.TimeSeconds + float(1));
		// End:0xB5
		if((int(m_ePawnType) == int(1)))
		{
			SendPlaySound(Level.m_BodyFallSwitchSnd, 3);			
		}
		else
		{
			SendPlaySound(Level.m_BodyFallSwitchForOtherPawnSnd, 3);
		}
	}
	return;
}

//============================================================================
// DropWeaponToGround - 
//============================================================================
simulated function DropWeaponToGround()
{
	// End:0x22
	if((EngineWeapon != none))
	{
		EngineWeapon.StartFalling();
		m_bDroppedWeapon = true;
	}
	return;
}

//============================================================================
// SpawnRagDoll - 
//============================================================================
simulated event SpawnRagDoll()
{
	local Class<R6AbstractCorpse> corpseClass;
	local KarmaParamsSkel skelParams;
	local Vector shotDir, shotDir2D, hitLocRel;
	local float maxDim;
	local int i;

	StopWeaponSound();
	DropWeaponToGround();
	bPlayedDeath = true;
	m_fTimeStartBodyFallSound = (Level.TimeSeconds + 0.5000000);
	SendPlaySound(m_sndDeathClothes, 3);
	// End:0x73
	if((!m_bUseKarmaRagdoll))
	{
		SetPhysics(0);
		m_ragdoll = Spawn(Class'R6Engine.R6RagDoll', self,, Location, Rotation);
		m_ragdoll.FirstInit(self);		
	}
	else
	{
		// End:0x252
		if((int(Level.NetMode) != int(NM_DedicatedServer)))
		{
			KMakeRagdollAvailable();
			// End:0x252
			if(KIsRagdollAvailable())
			{
				skelParams = KarmaParamsSkel(KParams);
				shotDir = Normal(TearOffMomentum);
				// End:0x13B
				if((TakeHitLocation != vect(0.0000000, 0.0000000, 0.0000000)))
				{
					hitLocRel = ((TakeHitLocation - GetBoneCoords('R6 Spine').Origin) * 1000.0000000);
					hitLocRel.Z = 0.0000000;
					shotDir2D = shotDir;
					shotDir2D.Z = 0.0000000;
					skelParams.KStartAngVel = Cross(hitLocRel, Normal(shotDir2D));
				}
				skelParams.KStartLinVel.X = (0.6000000 * Velocity.X);
				skelParams.KStartLinVel.Y = (0.6000000 * Velocity.Y);
				skelParams.KStartLinVel.Z = (1.0000000 * Velocity.Z);
				(skelParams.KStartLinVel += (shotDir * float(200)));
				maxDim = float(Max(int(CollisionRadius), int(CollisionHeight)));
				skelParams.KShotStart = (TakeHitLocation - (float(1) * shotDir));
				skelParams.KShotEnd = (TakeHitLocation + ((float(2) * maxDim) * shotDir));
				skelParams.KShotStrength = VSize(TearOffMomentum);
				KParams = skelParams;
				KSetBlockKarma(true);
				SetPhysics(14);
			}
		}
	}
	// End:0x2B2
	if((m_BreathingEmitter != none))
	{
		m_BreathingEmitter.Emitters[0].AllParticlesDead = false;
		m_BreathingEmitter.Emitters[0].m_iPaused = 1;
		DetachFromBone(m_BreathingEmitter);
		m_BreathingEmitter.Destroy();
		m_BreathingEmitter = none;
	}
	GotoState('Dead');
	return;
}

//============================================================================
// event StopAnimForRG - 
//============================================================================
simulated event StopAnimForRG()
{
	local Rotator Rot;

	StopAnimating(true);
	m_bAnimStopedForRG = true;
	Rot.Yaw = 1500;
	SetBoneRotation('R6 PonyTail1', Rot,, 1.0000000, 1.0000000);
	return;
}

//------------------------------------------------------------------
// InitBiPodPosture: called when going prone/unprone, selecting/unselecting 
//  a weapon
//------------------------------------------------------------------
simulated event InitBiPodPosture(bool bEnable)
{
	ResetBipodPosture();
	m_bUsingBipod = bEnable;
	// End:0x3B
	if((m_bUsingBipod && (int(m_ePeekingMode) != int(0))))
	{
		SetPeekingInfo(0, 1000.0000000);
	}
	m_iMaxRotationOffset = GetMaxRotationOffset();
	return;
}

//------------------------------------------------------------------
// ResetBipodPosture: reset basic bipod posture info
//  
//------------------------------------------------------------------
simulated event ResetBipodPosture()
{
	m_fBipodRotation = 0.0000000;
	m_iLastBipodRotation = 0;
	m_iRepBipodRotationRatio = 0;
	return;
}

//------------------------------------------------------------------
// Update bipod posture only if using one and not moving
//  
//------------------------------------------------------------------
simulated event UpdateBipodPosture()
{
	local name animName;
	local float fRatio;

	// End:0x2E
	if((EngineWeapon.bFiredABullet == true))
	{
		PlayProneFireAnimation();
		EngineWeapon.bFiredABullet = false;
		return;
	}
	// End:0x3F
	if((m_iLastBipodRotation == m_iRepBipodRotationRatio))
	{
		return;
	}
	// End:0x7B
	if((m_iRepBipodRotationRatio > 0))
	{
		// End:0x6D
		if((EngineWeapon.IsLMG() == true))
		{
			animName = 'ProneBipodRightLMGBreathe';			
		}
		else
		{
			animName = 'ProneBipodRightSniperBreathe';
		}		
	}
	else
	{
		// End:0x9E
		if((EngineWeapon.IsLMG() == true))
		{
			animName = 'ProneBipodLeftLMGBreathe';			
		}
		else
		{
			animName = 'ProneBipodLeftSniperBreathe';
		}
	}
	fRatio = 100.0000000;
	// End:0xF1
	if((IsLocallyControlled() && (int(Level.NetMode) != int(NM_Standalone))))
	{
		fRatio = Abs((m_fBipodRotation / float(5600)));		
	}
	else
	{
		fRatio = Abs((float(m_iRepBipodRotationRatio) / fRatio));
	}
	AnimBlendParams(12, fRatio, 0.0000000, 0.0000000, 'R6');
	PlayAnim(animName, 1.0000000, 0.0000000, 12);
	m_iLastBipodRotation = m_iRepBipodRotationRatio;
	return;
}

//------------------------------------------------------------------
// CanPeek(): return true if the pawn can peek
//  
//------------------------------------------------------------------
function bool CanPeek()
{
	return (!m_bUsingBipod);
	return;
}

//------------------------------------------------------------------
// EnteredExtractionZone
//------------------------------------------------------------------
function EnteredExtractionZone(R6AbstractExtractionZone Zone)
{
	return;
}

//------------------------------------------------------------------
// LeftExtractionZone
//------------------------------------------------------------------
function LeftExtractionZone(R6AbstractExtractionZone Zone)
{
	return;
}

//------------------------------------------------------------------
// SetFriendlyFire
//  - called by controller posses fn
//------------------------------------------------------------------
function SetFriendlyFire()
{
	local bool bFriendlyFire;

	// End:0x31
	if(Controller.IsA('AIController'))
	{
		m_bCanFireFriends = default.m_bCanFireFriends;
		m_bCanFireNeutrals = default.m_bCanFireNeutrals;		
	}
	else
	{
		// End:0x7A
		if((int(m_ePawnType) != int(1)))
		{
			Log(("WARNING: SetFriendlyFire unknow m_ePawnType for " $ string(self)));
		}
		// End:0xCF
		if(Level.IsGameTypeMultiplayer(R6AbstractGameInfo(Level.Game).m_szGameTypeFlag))
		{
			bFriendlyFire = R6AbstractGameInfo(Level.Game).m_bFriendlyFire;			
		}
		else
		{
			bFriendlyFire = true;
		}
		m_bCanFireFriends = bFriendlyFire;
		m_bCanFireNeutrals = bFriendlyFire;
	}
	return;
}

// Play sound because no animation here just interpolation
simulated function CrouchToStand()
{
	SendPlaySound(m_sndCrouchToStand, 3);
	return;
}

// Play sound because no animation here just interpolation
simulated function StandToCrouch()
{
	SendPlaySound(m_sndStandToCrouch, 3);
	return;
}

function PlayLocalWeaponSound(R6EngineWeapon.EWeaponSound EWeaponSound)
{
	// End:0x1C
	if((m_SoundRepInfo != none))
	{
		m_SoundRepInfo.PlayLocalWeaponSound(EWeaponSound);
	}
	return;
}

// Server call this function
function PlayWeaponSound(R6EngineWeapon.EWeaponSound EWeaponSound)
{
	// End:0x1F
	if((m_SoundRepInfo != none))
	{
		SetAudioInfo();
		m_SoundRepInfo.PlayWeaponSound(EWeaponSound);
	}
	return;
}

// Stop sound when the ragdoll is spawn. Done on the client side.
simulated function StopWeaponSound()
{
	// End:0x17
	if((m_SoundRepInfo != none))
	{
		m_SoundRepInfo.StopWeaponSound();
	}
	return;
}

//============================================================================
// FellOutOfWorld - 
//============================================================================
event FellOutOfWorld()
{
	// End:0x12
	if((int(Role) < int(ROLE_Authority)))
	{
		return;
	}
	// End:0x25
	if((!m_bIsPlayer))
	{
		ServerSuicidePawn(3);
	}
	return;
}

// -----------  MissionPack1
// MPF1 
function int R6TakeDamageCTE(int iKillValue, int iStunValue, Pawn instigatedBy, Vector vHitLocation, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGoup)
{
	local Actor.eKillResult eKillFromTable;
	local Actor.eStunResult eStunFromTable;
	local R6Pawn.eBodyPart eHitPart;
	local int iKillFromHit;
	local Vector vBulletDirection;
	local int iSndIndex;
	local bool bIsSilenced, bIsSurrended;
	local R6BloodSplat BloodSplat;
	local Rotator BloodRotation;
	local R6WallHit aBloodEffect;
	local bool _bAffectedActor;

	// End:0x2D
	if((bInvulnerableBody || (IsA('R6Rainbow') && R6Rainbow(self).m_bIsSurrended)))
	{
		return 0;
	}
	// End:0x76
	if(((instigatedBy != none) && (instigatedBy.EngineWeapon != none)))
	{
		_bAffectedActor = instigatedBy.EngineWeapon.AffectActor(iBulletGoup, self);		
	}
	else
	{
		_bAffectedActor = false;
	}
	// End:0x14A
	if((IsEnemy(instigatedBy) && _bAffectedActor))
	{
		// End:0xED
		if((int(Level.NetMode) == int(NM_Standalone)))
		{
			// End:0xEA
			if(((instigatedBy != none) && (int(instigatedBy.m_ePawnType) == int(1))))
			{
				R6Rainbow(instigatedBy).IncrementRoundsHit();
			}			
		}
		else
		{
			// End:0x147
			if((((instigatedBy != none) && (instigatedBy.PlayerReplicationInfo != none)) && (Level.Game.m_bCompilingStats == true)))
			{
				(instigatedBy.PlayerReplicationInfo.m_iRoundsHit++);
			}
		}		
	}
	else
	{
		return 0;
	}
	TakeHitLocation = vHitLocation;
	// End:0x1A0
	if((int(Level.NetMode) == int(NM_Client)))
	{
		// End:0x19D
		if((m_bIsPlayer && R6PlayerController(Controller).GameReplicationInfo.m_bGameOverRep))
		{
			return 0;
		}		
	}
	else
	{
		// End:0x1E1
		if((Level.Game.m_bGameOver && (!R6AbstractGameInfo(Level.Game).m_bGameOverButAllowDeath)))
		{
			return 0;
		}
	}
	// End:0x237
	if(((!InGodMode()) && (iKillValue != 0)))
	{
		aBloodEffect = Spawn(Class'R6SFX.R6BloodEffect',,, vHitLocation);
		// End:0x237
		if(((aBloodEffect != none) && (!_bAffectedActor)))
		{
			aBloodEffect.m_bPlayEffectSound = false;
		}
	}
	// End:0x26D
	if(((int(m_ePawnType) == int(1)) && (!m_bIsPlayer)))
	{
		R6RainbowAI(Controller).IsBeingAttacked(instigatedBy);
	}
	// End:0x278
	if(InGodMode())
	{
		return 0;
	}
	eHitPart = WhichBodyPartWasHit(vHitLocation, vMomentum);
	m_eLastHitPart = eHitPart;
	// End:0x2DC
	if(((instigatedBy != none) && (instigatedBy.EngineWeapon != none)))
	{
		bIsSilenced = instigatedBy.EngineWeapon.m_bIsSilenced;		
	}
	else
	{
		bIsSilenced = false;
	}
	// End:0x33B
	if((m_iForceKill != 0))
	{
		switch(m_iForceKill)
		{
			// End:0x305
			case 1:
				eKillFromTable = 0;
				// End:0x338
				break;
			// End:0x315
			case 2:
				eKillFromTable = 1;
				// End:0x338
				break;
			// End:0x325
			case 3:
				eKillFromTable = 2;
				// End:0x338
				break;
			// End:0x335
			case 4:
				eKillFromTable = 3;
				// End:0x338
				break;
			// End:0xFFFF
			default:
				break;
		}		
	}
	else
	{
		eKillFromTable = GetKillResult(iKillValue, int(eHitPart), int(m_eArmorType), iBulletToArmorModifier, bIsSilenced);
	}
	// End:0x394
	if(((int(eKillFromTable) == int(3)) || (int(eKillFromTable) == int(2))))
	{
		eKillFromTable = 1;
		bIsSurrended = true;
	}
	// End:0x3F9
	if(((m_iForceStun != 0) && (m_iForceStun < 5)))
	{
		switch(m_iForceStun)
		{
			// End:0x3C3
			case 1:
				eStunFromTable = 0;
				// End:0x3F6
				break;
			// End:0x3D3
			case 2:
				eStunFromTable = 1;
				// End:0x3F6
				break;
			// End:0x3E3
			case 3:
				eStunFromTable = 2;
				// End:0x3F6
				break;
			// End:0x3F3
			case 4:
				eStunFromTable = 3;
				// End:0x3F6
				break;
			// End:0xFFFF
			default:
				break;
		}		
	}
	else
	{
		eStunFromTable = GetStunResult(iStunValue, int(eHitPart), int(m_eArmorType), iBulletToArmorModifier, bIsSilenced);
	}
	vBulletDirection = Normal(vMomentum);
	BloodRotation = Rotator(vBulletDirection);
	BloodRotation.Roll = 0;
	// End:0x470
	if((int(eKillFromTable) != int(0)))
	{
		BloodSplat = Spawn(Class'R6Engine.R6BloodSplatSmall',,, vHitLocation, BloodRotation);
	}
	// End:0x48A
	if((int(m_iTracedBone) != 0))
	{
		m_rHitDirection = Rotator(vBulletDirection);
	}
	// End:0x4A9
	if(bIsSurrended)
	{
		m_eHealth = 0;
		m_fHBWound = 1.0000000;		
	}
	else
	{
		// End:0x4DD
		if((int(eKillFromTable) == int(1)))
		{
			m_eHealth = 1;
			m_fHBWound = 1.2000000;
			// End:0x4DD
			if(m_bIsClimbingLadder)
			{
				bIsWalking = true;
			}
		}
	}
	// End:0x5A7
	if(((instigatedBy != none) && (R6PlayerController(instigatedBy.Controller) != none)))
	{
		// End:0x5A7
		if(R6PlayerController(instigatedBy.Controller).m_bShowHitLogs)
		{
			Log(((((((((("Player HIT : " $ string(self)) $ " Bullet Energy : ") $ string(iKillValue)) $ " body part : ") $ string(eHitPart)) $ " KillResult : ") $ string(eKillFromTable)) $ " Armor type : ") $ string(m_eArmorType)));
		}
	}
	// End:0x60F
	if(((int(m_ePawnType) == int(1)) && (int(eKillFromTable) != int(0))))
	{
		// End:0x60F
		if(m_bIsPlayer)
		{
			R6PlayerController(Controller).m_TeamManager.m_eMovementMode = 0;
			R6PlayerController(Controller).m_TeamManager.UpdateTeamStatus(self);
		}
	}
	// End:0x664
	if((Controller != none))
	{
		Controller.R6DamageAttitudeTo(instigatedBy, eKillFromTable, eStunFromTable, vMomentum);
		// End:0x661
		if((int(eKillFromTable) != int(0)))
		{
			Controller.PlaySoundDamage(instigatedBy);
		}		
	}
	// End:0x6D9
	if((int(eKillFromTable) != int(0)))
	{
		iStunValue = Min(iStunValue, 5000);
		vMomentum = (Normal(vMomentum) * float((iStunValue * 100)));
		// End:0x6D9
		if(bIsSurrended)
		{
			// End:0x6D9
			if(((int(m_ePawnType) == int(1)) && m_bIsPlayer))
			{
				R6Surrender(instigatedBy, eHitPart, vMomentum);
			}
		}
	}
	iKillFromHit = GetThroughResult(iKillValue, int(eHitPart), vMomentum);
	// End:0x751
	if((PlayerReplicationInfo != none))
	{
		switch(m_eHealth)
		{
			// End:0x71D
			case 0:
				PlayerReplicationInfo.m_iHealth = 0;
				// End:0x751
				break;
			// End:0x735
			case 1:
				PlayerReplicationInfo.m_iHealth = 1;
				// End:0x751
				break;
			// End:0x74E
			case 3:
				PlayerReplicationInfo.m_iHealth = 2;
				// End:0x751
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		return iKillFromHit;
		return;
	}
}

// MPF_Milan_9_23_2003 - uncommented 
function ServerSurrender()
{
	// End:0x28
	if((IsA('R6Rainbow') && R6PlayerController(Controller).IsInState('PlayerStartSurrenderSequence')))
	{
		return;
	}
	Surrender();
	return;
}

function ClientSurrender()
{
	// End:0x28
	if((IsA('R6Rainbow') && R6PlayerController(Controller).IsInState('PlayerStartSurrenderSequence')))
	{
		return;
	}
	Surrender();
	return;
}

function Surrender()
{
	// End:0x22
	if((IsA('R6Rainbow') && R6Rainbow(self).m_bIsSurrended))
	{
		return;
	}
	// End:0x4A
	if((IsA('R6Rainbow') && R6PlayerController(Controller).IsInState('PlayerStartSurrenderSequence')))
	{
		return;
	}
	R6PlayerController(Controller).GotoState('PlayerStartSurrenderSequence');
	// End:0x7C
	if(IsA('R6Rainbow'))
	{
		R6Rainbow(self).m_bIsSurrended = true;
	}
	// End:0x92
	if((int(Role) == int(ROLE_Authority)))
	{
		ClientSurrender();
	}
	return;
}

//===================================================================================================
// Arrested()                                              
//===================================================================================================
simulated function Arrested()
{
	R6Rainbow(self).m_bIsBeingArrestedOrFreed = true;
	R6PlayerController(Controller).GotoState('PlayerStartArrest');
	return;
}

function ClientSetFree()
{
	// End:0x15
	if(R6Rainbow(self).m_bIsBeingArrestedOrFreed)
	{
		return;
	}
	SetFree();
	return;
}

//===================================================================================================
// SetFree()                                              
//===================================================================================================
function SetFree()
{
	// End:0x15
	if(R6Rainbow(self).m_bIsBeingArrestedOrFreed)
	{
		return;
	}
	R6Rainbow(self).m_bIsBeingArrestedOrFreed = true;
	// End:0x46
	if((int(Level.NetMode) != int(NM_Client)))
	{
		ClientSetFree();
	}
	R6PlayerController(Controller).GotoState('PlayerSetFree');
	return;
}

//============================================================================
// R6Surrender
//      Called only on the server
//============================================================================
function R6Surrender(Pawn Killer, R6Pawn.eBodyPart eHitPart, Vector vMomentum)
{
	local R6AbstractGameInfo pGameInfo;
	local int i;
	local R6PlayerController P;
	local R6AbstractWeapon AWeapon;
	local string KillerName, szPlayerName;

	// End:0x35
	if((Killer == none))
	{
		Log(" R6Surrender() : WARNING : Killer=none");
	}
	// End:0x69
	if((Killer.PlayerReplicationInfo != none))
	{
		KillerName = Killer.PlayerReplicationInfo.PlayerName;		
	}
	else
	{
		KillerName = Killer.m_CharacterName;
	}
	// End:0x169
	if((m_bIsClimbingLadder || (int(Physics) == int(11))))
	{
		// End:0x113
		if(((m_Ladder == none) || (m_Ladder.MyLadder == none)))
		{
			Log((((" R6Surrender() : WARNING : m_Ladder=" $ string(m_Ladder)) $ " m_Ladder.myLadder=") $ string(m_Ladder.MyLadder)));
		}
		R6LadderVolume(m_Ladder.MyLadder).RemoveClimber(self);
		// End:0x169
		if((m_bIsPlayer && (m_Ladder != none)))
		{
			R6LadderVolume(m_Ladder.MyLadder).DisableCollisions(m_Ladder);
		}
	}
	// End:0x1B6
	if((int(Physics) == int(12)))
	{
		// End:0x194
		if((Controller != none))
		{
			Controller.GotoState('None');
		}
		// End:0x1AB
		if(bIsCrouched)
		{
			PlayPostRootMotionAnimation(m_crouchDefaultAnimName);			
		}
		else
		{
			PlayPostRootMotionAnimation(m_standDefaultAnimName);
		}
	}
	AWeapon = R6AbstractWeapon(EngineWeapon);
	// End:0x200
	if(((AWeapon != none) && (AWeapon.m_SelectedWeaponGadget != none)))
	{
		AWeapon.m_SelectedWeaponGadget.ActivateGadget(false);
	}
	// End:0x22A
	if((vMomentum == vect(0.0000000, 0.0000000, 0.0000000)))
	{
		vMomentum = vect(1.0000000, 1.0000000, 1.0000000);
	}
	TearOffMomentum = vMomentum;
	bAlwaysRelevant = true;
	i = 0;
	J0x244:

	// End:0x281 [Loop If]
	if((i <= 3))
	{
		// End:0x277
		if((m_WeaponsCarried[i] != none))
		{
			m_WeaponsCarried[i].SetRelevant(true);
		}
		(i++);
		// [Loop Continue]
		goto J0x244;
	}
	bProjTarget = false;
	m_KilledBy = R6Pawn(Killer);
	// End:0x2DC
	if(ProcessBuildDeathMessage(Killer, szPlayerName))
	{
		// End:0x2DB
		foreach DynamicActors(Class'R6Engine.R6PlayerController', P)
		{
			P.ClientDeathMessage(KillerName, szPlayerName, m_bSuicideType);			
		}		
	}
	// End:0x31C
	if((m_KilledBy == none))
	{
		Log(("  R6Surrender() : Warning!!  m_KilledBy=" $ string(m_KilledBy)));
	}
	// End:0x339
	if(IsEnemy(m_KilledBy))
	{
		m_KilledBy.IncrementFragCount();
	}
	// End:0x36B
	if((R6PlayerController(Controller) != none))
	{
		R6PlayerController(Controller).PlayerReplicationInfo.m_szKillersName = KillerName;
	}
	Surrender();
	return;
}

simulated state Dead
{
	simulated function BeginState()
	{
		return;
	}

//===================================================================================================
// EyePosition() 
//  Returns the offset for the eye from the Pawn's location at which to place the camera or to start
//  the line of sight 
// rbrek - 19 July 2001 - Originally defined in Pawn.uc.  Overridden here in order to 
//   include the proper offset due to peeking and/or fluid crouching...
//===================================================================================================
	event Vector EyePosition()
	{
		return (GetBoneCoords('R6 Head').Origin - Location);
		return;
	}

	event Timer()
	{
		bProjTarget = false;
		return;
	}
Begin:

	// End:0x16
	if(IsPeeking())
	{
		SetPeekingInfo(0, 1000.0000000);
	}
	bProjTarget = true;
	SetCollision(true, false, false);
	SetCollisionSize((1.5000000 * default.CollisionRadius), (1.0000000 * default.CollisionHeight));
	SetTimer(0.5000000, false);
	// End:0x60
	if((m_collisionBox != none))
	{
		m_collisionBox.EnableCollision(false);
	}
	// End:0x78
	if((m_collisionBox2 != none))
	{
		m_collisionBox2.EnableCollision(false);
	}
	// End:0xCF
	if((Controller != none))
	{
		Controller.FocalPoint = vect(0.0000000, 0.0000000, 0.0000000);
		Controller.Focus = none;
		Controller.bRotateToDesired = false;
		Controller.PawnDied();
	}
	bRotateToDesired = false;
	// End:0xF8
	if((int(Level.NetMode) != int(NM_Client)))
	{
		R6MakeNoise();
	}
	stop;			
}

defaultproperties
{
	m_iNetCurrentActionIndex=255
	m_iLocalCurrentActionIndex=255
	m_eLastUsingHands=3
	m_iUniqueID=1
	m_iDesignRandomTweak=50
	m_iDesignLightTweak=10
	m_iDesignMediumTweak=30
	m_iDesignHeavyTweak=50
	m_bAvoidFacingWalls=true
	m_bUseKarmaRagdoll=true
	m_fSkillAssault=0.8000000
	m_fSkillDemolitions=0.8000000
	m_fSkillElectronics=0.8000000
	m_fSkillSniper=0.8000000
	m_fSkillStealth=0.8000000
	m_fSkillSelfControl=0.8000000
	m_fSkillLeadership=0.8000000
	m_fSkillObservation=0.8000000
	m_fReloadSpeedMultiplier=1.0000000
	m_fGunswitchSpeedMultiplier=1.0000000
	m_fGadgetSpeedMultiplier=1.0000000
	m_fWalkingSpeed=170.0000000
	m_fWalkingBackwardStrafeSpeed=170.0000000
	m_fRunningSpeed=290.0000000
	m_fRunningBackwardStrafeSpeed=290.0000000
	m_fCrouchedWalkingSpeed=80.0000000
	m_fCrouchedWalkingBackwardStrafeSpeed=80.0000000
	m_fCrouchedRunningSpeed=150.0000000
	m_fCrouchedRunningBackwardStrafeSpeed=150.0000000
	m_fProneSpeed=45.0000000
	m_fProneStrafeSpeed=17.0000000
	m_fPeekingGoalModifier=1.0000000
	m_fPeekingGoal=1000.0000000
	m_fPeeking=1000.0000000
	m_fWallCheckDistance=300.0000000
	m_fZoomJumpReturn=1.0000000
	m_fHBMove=1.0000000
	m_fHBWound=1.0000000
	m_fHBDefcon=1.0000000
	m_sndNightVisionActivation=Sound'Gadgets_NightVision.Play_NightActivation'
	m_sndNightVisionDeactivation=Sound'Gadgets_NightVision.Stop_NightActivation_Go'
	m_sndCrouchToStand=Sound'Foley_RainbowGear.Play_Crouch_Stand_Gear'
	m_sndStandToCrouch=Sound'Foley_RainbowGear.Play_Stand_Crouch_Gear'
	m_sndThermalScopeActivation=Sound'CommonSniper.Play_ThermScopeActivation'
	m_sndThermalScopeDeactivation=Sound'CommonSniper.Stop_ThermScopeActivation_Go'
	m_sndDeathClothes=Sound'Foley_RainbowClothesLight.Play_DeathClothes'
	m_sndDeathClothesStop=Sound'Foley_RainbowClothesLight.Stop_DeathClothes'
	m_standRunForwardName="StandRunForward"
	m_standRunLeftName="StandRunLeft"
	m_standRunBackName="StandRunBack"
	m_standRunRightName="StandRunRight"
	m_standWalkForwardName="StandWalkForward"
	m_standWalkBackName="StandWalkBack"
	m_standWalkLeftName="StandWalkLeft"
	m_standWalkRightName="StandWalkRight"
	m_hurtStandWalkLeftName="HurtStandWalkLeft"
	m_hurtStandWalkRightName="HurtStandWalkRight"
	m_standTurnLeftName="StandTurnLeft"
	m_standTurnRightName="StandTurnRight"
	m_standFallName="StandFall_nt"
	m_standLandName="StandLand"
	m_crouchFallName="CrouchFall_nt"
	m_crouchLandName="CrouchLand"
	m_crouchWalkForwardName="CrouchWalkForward"
	m_standStairWalkUpName="StandStairWalkUpForward"
	m_standStairWalkUpBackName="StandStairWalkUpBack"
	m_standStairWalkUpRightName="StandStairWalkUpRight"
	m_standStairWalkDownName="StandStairWalkDownForward"
	m_standStairWalkDownBackName="StandStairWalkDownBack"
	m_standStairWalkDownRightName="StandStairWalkDownRight"
	m_standStairRunUpName="StandStairRunUpForward"
	m_standStairRunUpBackName="StandStairRunUpBack"
	m_standStairRunUpRightName="StandStairRunUpRight"
	m_standStairRunDownName="StandStairRunDownForward"
	m_standStairRunDownBackName="StandStairRunDownBack"
	m_standStairRunDownRightName="StandStairRunDownRight"
	m_crouchStairWalkDownName="CrouchStairWalkDownForward"
	m_crouchStairWalkDownBackName="CrouchStairWalkDownBack"
	m_crouchStairWalkDownRightName="CrouchStairWalkDownRight"
	m_crouchStairWalkUpName="CrouchStairWalkUpForward"
	m_crouchStairWalkUpBackName="CrouchStairWalkUpBack"
	m_crouchStairWalkUpRightName="CrouchStairWalkUpRight"
	m_crouchStairRunUpName="CrouchStairRunUpForward"
	m_crouchStairRunDownName="CrouchStairRunDownForward"
	m_crouchDefaultAnimName="CrouchSubGunHigh_nt"
	m_standDefaultAnimName="StandSubGunHigh_nt"
	m_standClimb64DefaultAnimName="StandClimb64Up"
	m_standClimb96DefaultAnimName="StandClimb96Up"
	bCanCrouch=true
	m_bCanProne=true
	bCanClimbLadders=true
	bCanWalkOffLedges=true
	bSameZoneHearing=true
	bMuffledHearing=true
	bAroundCornerHearing=true
	bDontPossess=true
	m_bWantsHighStance=true
	bPhysicsAnimUpdate=true
	PeripheralVision=0.5000000
	GroundSpeed=340.0000000
	LadderSpeed=50.0000000
	WalkingPct=1.0000000
	CrouchHeight=60.0000000
	CrouchRadius=35.0000000
	m_fProneHeight=28.0000000
	m_fProneRadius=40.0000000
	m_fHeartBeatFrequency=90.0000000
	m_pHeartBeatTexture=Texture'Inventory_t.HeartBeat.SphereBeat'
	m_sndHBSSound=Sound'Foley_HBSensor.Play_HBSensorAction2'
	m_sndHearToneSound=Sound'Grenade_FlashBang.Play_HearTone'
	m_sndHearToneSoundStop=Sound'Grenade_FlashBang.Stop_HearTone'
	MovementAnims[0]="StandWalkForward"
	MovementAnims[1]="StandWalkLeft"
	MovementAnims[2]="StandWalkBack"
	MovementAnims[3]="StandWalkRight"
	TurnLeftAnim="StandTurnLeft"
	TurnRightAnim="StandTurnRight"
	m_HeatIntensity=255
	m_bReticuleInfo=true
	m_bShowInHeatVision=true
	m_bDeleteOnReset=true
	m_bPlanningAlwaysDisplay=true
	CollisionRadius=35.0000000
	CollisionHeight=75.0000000
	m_fBoneRotationTransition=1.0000000
	KParams=KarmaParamsSkel'R6Engine.R6AllRagDoll'
	RotationRate=(Pitch=4096,Yaw=30000,Roll=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_ePendingActionC_MaxPendingAction
// REMOVED IN 1.60: var m_iPendingActionIntC_MaxPendingAction
// REMOVED IN 1.60: var eHands
// REMOVED IN 1.60: var eDeviceAnimToPlay
// REMOVED IN 1.60: var m_fFallingHeight
// REMOVED IN 1.60: var eStrafeDirection
// REMOVED IN 1.60: function GetKillResult
// REMOVED IN 1.60: function GetStunResult
// REMOVED IN 1.60: function GetMovementDirection
// REMOVED IN 1.60: function UpdateBones
// REMOVED IN 1.60: function PlayClimbObject
// REMOVED IN 1.60: function PlayPostClimb
// REMOVED IN 1.60: function WhichBodyPartWasHit
// REMOVED IN 1.60: function GetBodyPartFromBoneID
// REMOVED IN 1.60: function TakeDamage
// REMOVED IN 1.60: function ServerArrested
