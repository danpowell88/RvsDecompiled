//=============================================================================
//  R6Rainbow.uc : This is the base pawn class for all members of Rainbow
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/04 * Created by Rima Brek
//    Eric - May 7th, 2001 - Add More Basic Animations
//
//============================================================================//
class R6Rainbow extends R6Pawn
    native
    notplaceable
    abstract;

// --- Enums ---
enum eComAnimation
{
	COM_None,
	COM_FollowMe,
	COM_Cover,
	COM_Go,
	COM_Regroup,
	COM_Hold,	
};
enum eEquipWeapon
{
	EQUIP_SecureWeapon,
	EQUIP_EquipWeapon,
	EQUIP_NoWeapon,
	EQUIP_Armed
} m_eEquipWeapon;

// MPF1
//---------- MissionPack1
enum eRainbowCircumstantialAction
{
    CAR_None,
    CAR_Secure,
	CAR_Free,
};
enum eLadderSlide
{
	SLIDE_Start,
	SLIDE_Sliding,
	SLIDE_End,
	SLIDE_None
} m_eLadderSlide;

enum eComAnimation
{
	COM_None,
	COM_FollowMe,
	COM_Cover,
	COM_Go,
	COM_Regroup,
	COM_Hold,	
};
enum eRainbowCircumstantialAction
{
    CAR_None,
    CAR_Secure,
	CAR_Free,
};

// --- Variables ---
// escort
var R6Hostage m_aEscortedHostage[4];
var eEquipWeapon m_eEquipWeapon;
// ^ NEW IN 1.60
var /* replicated */ bool m_bIsSurrended;
var int m_iCurrentWeapon;
var R6AbstractHelmet m_Helmet;
var /* replicated */ R6NightVision m_NightVision;
// MPF_Milan_7_1_2003 deprecated var bool	m_bSurrenderWait;
// MPF_Milan_7_12003 deprecated var bool	m_bArrestWait;
//true when transitioning from surrender to arrest or from arrest to free
var bool m_bIsBeingArrestedOrFreed;
var bool m_bThrowGrenadeWithLeftHand;
var /* replicated */ bool m_bIsLockPicking;
// desired yaw for rainbow NPCs
var /* replicated */ byte m_u8DesiredYaw;
// true when arrested
var /* replicated */ bool m_bIsUnderArrest;
// specialty of the rainbow
var string m_szSpecialityID;
var R6GasMask m_GasMask;
var bool m_bWeaponIsSecured;
// this var is being used in the switch weapon animation system (particularly in 1st person view or in MP)
var R6EngineWeapon m_preSwitchWeapon;
// workaround the problem of tweening
var bool m_bTweenFirstTimeOnly;
var eLadderSlide m_eLadderSlide;
// ^ NEW IN 1.60
// set to false when getting off a ladder
var bool m_bGettingOnLadder;
var string m_szPrimaryWeapon;
var string m_szSecondaryWeapon;
var /* replicated */ bool m_bHasLockPickKit;
var /* replicated */ bool m_bHasDiffuseKit;
var /* replicated */ bool m_bHasElectronicsKit;
var bool m_bReloadToFullAmmo;
// Id operative for the campaign file
var int m_iOperativeID;
var string m_szSecondaryItem;
var string m_szPrimaryItem;
var /* replicated */ int m_iExtraSecondaryClips;
var /* replicated */ int m_iExtraPrimaryClips;
// desired pitch for rainbow NPCs
var /* replicated */ byte m_u8DesiredPitch;
var Rotator m_rFiringRotation;
var string m_szSecondaryGadget;
var string m_szPrimaryGadget;
var bool m_bInitRainbow;
var Plane m_FaceCoords;
var Material m_FaceTexture;
var string m_szSecondaryBulletType;
var string m_szPrimaryBulletType;
var /* replicated */ int m_iRainbowFaceID;
// for multiplayer NPCs only
var /* replicated */ bool m_bRainbowIsFemale;
var byte m_u8CurrentYaw;
var class<R6NightVision> m_NightVisionClass;
var bool m_bScaleGasMaskForFemale;
var class<R6GasMask> m_GasMaskClass;
var int m_iBulletsHit;
var int m_iBulletsFired;
var int m_iKills;
var Vector m_vStartLocation;
var /* replicated */ bool m_bIsTheIntruder;
// ^ NEW IN 1.60
var byte m_u8CurrentPitch;
var /* replicated */ bool m_bHasDataObject;
// ^ NEW IN 1.60

// --- Functions ---
// function ? PlayStartArrest(...); // REMOVED IN 1.60
simulated event PostBeginPlay() {}
function SetMovementPhysics() {}
function ServerToggleNightVision(bool bActivateNightVision) {}
event EndOfGrenadeEffect(EGrenadeType eType) {}
//============================================================================
// PlaySpecialPendingAction - Called from UpdateMovementAnimation to
//                            play special animation on all clients
//============================================================================
simulated event PlaySpecialPendingAction(EPendingAction eAction, int iActionInt) {}
simulated event SetAnimAction(name NewAction) {}
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
//									GRENADE FUNCTIONS
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
function GrenadeThrow() {}
//------------------------------------------------------------------
// ProcessBuildDeathMessage
//	return true if the build death msg can be build by "static BuildDeathMessage"
//------------------------------------------------------------------
function bool ProcessBuildDeathMessage(Pawn Killer, out string szPlayerName) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// Escort_UpdateTeamSpeed
//
//------------------------------------------------------------------
function Escort_UpdateTeamSpeed() {}
//------------------------------------------------------------------
// Escort_GetPawnToFollow
//
//------------------------------------------------------------------
function R6Rainbow Escort_GetPawnToFollow(optional bool bRunningTowardMe) {}
// ^ NEW IN 1.60
//===========================================================================//
// R6GetCircumstantialActionProgress() -
//===========================================================================//
function int R6GetCircumstantialActionProgress(Pawn actingPawn, R6AbstractCircumstantialActionQuery Query) {}
// ^ NEW IN 1.60
simulated function GetWeapon(R6AbstractWeapon NewWeapon) {}
// MPF_Milan_7_1_2003 - changed to specific channel, not loop
simulated function PlayArrestWaiting() {}
//------------------------------------------------------------------
// GetReticuleInfo
//
//------------------------------------------------------------------
simulated event bool GetReticuleInfo(out string szName, Pawn ownerReticule) {}
// ^ NEW IN 1.60
function Rotator GetFiringRotation() {}
// ^ NEW IN 1.60
//--------------- End MissionPack1
function bool HasBumpPriority(R6Pawn bumpedBy) {}
// ^ NEW IN 1.60
simulated event AnimEnd(int iChannel) {}
function PossessedBy(Controller C) {}
//===================================================================================================
// ClimbStairs()
//===================================================================================================
simulated function ClimbStairs(Vector vStairDirection) {}
simulated function SetCommunicationAnimation(eComAnimation eComAnim) {}
function ServerSetComAnim(eComAnimation eComAnim) {}
simulated function PlayCommunicationAnimation(eComAnimation eComAnim) {}
event EndCrouch(float fHeight) {}
//-----------------------------------------------------------------//
// --                 Rainbow Skill Advancement                 -- //
// --   called at the end of a mission to update skill levels   -- //
// -- TODO : (x.5) add special clause for members that did not  -- //
// --        participate in this mission and were in training   -- //
// --        MOVE THIS TO NATIVE CODE LATER                     -- //
//-----------------------------------------------------------------//
function UpdateRainbowSkills() {}
event StartCrouch(float HeightAdjust) {}
//============================================================================
// string R6GetCircumstantialActionString -
//============================================================================
simulated function string R6GetCircumstantialActionString(int iAction) {}
// ^ NEW IN 1.60
function ServerSetCrouch(bool bCrouch) {}
//------------------------------------------------------------------
// Escort_FindRainbow
//	find a rainbow who is visible and close to me
//------------------------------------------------------------------
function R6Rainbow Escort_FindRainbow(R6Hostage hostage) {}
// ^ NEW IN 1.60
function ClientSetCrouch(bool bCrouch) {}
simulated function Tick(float DeltaTime) {}
//============================================================================
// function GetFireWeaponAnimation -
//============================================================================
simulated function bool GetFireWeaponAnimation(out STWeaponAnim stAnim) {}
// ^ NEW IN 1.60
simulated function bool CheckForPassiveGadget(string aClassName) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// Escort_AddHostage
//
//------------------------------------------------------------------
function bool Escort_AddHostage(R6Hostage hostage, optional bool bOrderedByRainbow, optional bool bNoFeedbackByHostage) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// RemoveEscortedHostage: remove an hostage from the escort list,
//  update the escort list and call UpdateEscortList
//  return true is succesfull
//------------------------------------------------------------------
function bool Escort_RemoveHostage(R6Hostage hostage, optional bool bOrderedByRainbow, optional bool bNoFeedbackByHostage) {}
// ^ NEW IN 1.60
simulated function GiveDefaultWeapon() {}
//============================================================================
// function GetPawnSpecificAnimation -
//============================================================================
simulated function bool GetPawnSpecificAnimation(out STWeaponAnim stAnim) {}
// ^ NEW IN 1.60
//============================================================================
// function GetReloadAnimation -
//============================================================================
simulated function bool GetReloadWeaponAnimation(out STWeaponAnim stAnim) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// Escort_IsPawnCloseToMe: return true if there's a pawn in my radius
//
//------------------------------------------------------------------
function bool Escort_IsPawnCloseToMe(R6Hostage me, float fMyRadius) {}
// ^ NEW IN 1.60
simulated function bool GetNormalWeaponAnimation(out STWeaponAnim stAnim) {}
// ^ NEW IN 1.60
simulated event ReceivedWeapons() {}
//------------------------------------------------------------------
// Escort_UpdateCloserToLead
//
//------------------------------------------------------------------
function Escort_UpdateCloserToLead() {}
//============================================================================
// function GetThrowGrenadeAnimation -
//  . for grenade animations that play on clavicle (except for PullPin) we
//    don't want to play the animation on both arms because this will result
//    in the animation notifications being called twice
//============================================================================
simulated function bool GetThrowGrenadeAnimation(out STWeaponAnim stAnim) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// Escort_UpdateList
//	- if leader is dead, it finds someone else to escort the hostage
//  -
//------------------------------------------------------------------
function Escort_UpdateList() {}
event R6QueryCircumstantialAction(out R6AbstractCircumstantialActionQuery Query, float fDistance, PlayerController PlayerController) {}
//============================================================================
// function GetChangeWeaponAnimation -
//============================================================================
simulated function bool GetChangeWeaponAnimation(out STWeaponAnim stAnim) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// CanInteractWithObjects
//	MPF_Milan_7_1_2003 - ovverridden from R6Pawn for Mission pack - capture the enemy
//------------------------------------------------------------------
function bool CanInteractWithObjects() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetTeamMgr
//
//------------------------------------------------------------------
function R6RainbowTeam GetTeamMgr() {}
// ^ NEW IN 1.60
function GrenadeAnimEnd() {}
//============================================================================
// IsFighting: return true when the pawn is fighting
// - inherited
//============================================================================
function bool IsFighting() {}
// ^ NEW IN 1.60
//============================================================================
// ResetArrest -
//============================================================================
function ResetArrest() {}
//===========================================================================//
// R6CircumstantialActionProgressStart()                                     //
//===========================================================================//
function R6CircumstantialActionProgressStart(R6AbstractCircumstantialActionQuery Query) {}
function ChangeProneAttach() {}
// this function must be move in R6Pawn.
function ChangingWeaponEnd() {}
simulated function SubToHand_Step2() {}
// The same animation is use for both "SubGun to HandGun" and "HandGun to Subgun" transition
// We have to check the current weapon state to know which transition we are doing
simulated function SubToHand_Step1() {}
function FinishedReloadingWeapon() {}
// this notification is only called for all weapons except handguns, and gadgets
simulated function EquipHands() {}
simulated function EquipWeapon() {}
simulated function SecureWeapon() {}
simulated function BoltActionSwitchToRight() {}
simulated function BoltActionSwitchToLeftProne() {}
/////////////////////////////////////////////////////////////////////////////
//							NOTIFICATIONS
/////////////////////////////////////////////////////////////////////////////
simulated function BoltActionSwitchToLeft() {}
simulated function bool HasPawnSpecificWeaponAnimation() {}
// ^ NEW IN 1.60
simulated function PlayProneWaiting() {}
simulated function PlayCrouchWaiting() {}
simulated function EndKneeDown() {}
simulated function BlendKneeOnGround() {}
simulated function PlayDuck() {}
delegate ClientQuickResetPeeking() {}
simulated function StopPeeking() {}
// choose a random wait animation to play; this overrides the function in R6Pawn.uc
simulated function PlayWaiting() {}
simulated event PlayWeaponAnimation() {}
simulated event ReceivedEngineWeapon() {}
simulated function AttachGasMask() {}
simulated function RainbowEquipWeapon() {}
simulated function RainbowSecureWeapon() {}
simulated function PlayBlinded() {}
simulated function PlayCoughing() {}
simulated function ResetPawnSpecificAnimation() {}
simulated function PlayLockPickDoorAnim() {}
simulated function PlayPostEndSurrender() {}
simulated function PlaySetFree() {}
// NEW
simulated function PlayEndArrest() {}
simulated function PlayArrestKneel() {}
simulated function PlayArrest() {}
simulated function PlayEndSurrender() {}
simulated function PlaySurrender() {}
// MPF_Milan2 - changed all channels to specific
simulated function PlayStartSurrender() {}
simulated function PlaySecureTerrorist() {}
//===================================================================================================
// EndClimbStairs()
//===================================================================================================
simulated function EndClimbStairs() {}
simulated function PlayEndClimbing() {}
simulated function PlayStartClimbing() {}
function TurnAwayFromNearbyWalls() {}
function Vector GetHandLocation() {}
// ^ NEW IN 1.60
simulated function float ArmorSkillEffect() {}
// ^ NEW IN 1.60
delegate ClientFinishAnimation() {}
function MandatoryToggleNightVision() {}
// ^ NEW IN 1.60
exec function ToggleNightVision() {}
simulated function DeactivateNightVision() {}
simulated function RemoveNightVision() {}
simulated function RaiseHelmetVisor() {}
simulated function GetNightVision() {}
simulated function PlayDeactivateNightVisionAnimation() {}
simulated function PlayActivateNightVisionAnimation() {}
// this is used as a backup - to make sure if the activation or deactivation of the night vision was
// interrupted, the final state of the goggles is correct.
simulated function SecureNightVisionGoggles() {}
function UnPossessed() {}
simulated function InitializeRainbowAnimations() {}
simulated event PostNetBeginPlay() {}
simulated function AttachNightVision() {}
simulated function SetRainbowFaceTexture() {}
simulated event Destroyed() {}
simulated function EndSliding() {}
simulated function StartSliding() {}
function IncrementRoundsHit() {}
function IncrementBulletsFired() {}
// the following three functions are to keep stats for Rainbow in Single Player Games
function IncrementKillCount() {}
// ----MissionPack1
simulated function ResetOriginalData() {}
simulated function ActivateNightVision() {}

defaultproperties
{
}
