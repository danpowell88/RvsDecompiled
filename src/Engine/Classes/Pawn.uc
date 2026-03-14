//=============================================================================
// Pawn, the base class of all actors that can be controlled by players or AI.
//
// Pawns are the physical representations of players and creatures in a level.  
// Pawns have a mesh, collision, and physics.  Pawns can take damage, make sounds, 
// and hold weapons and other inventory.  In short, they are responsible for all 
// physical interaction between the player or AI and the world.
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Pawn extends Actor
    native
    abstract
    nativereplication;

#exec Texture Import File=Textures\Pawn.pcx Name=S_Pawn Mips=Off MASKED=1

// --- Enums ---
enum eGrenadeThrow
{
    GRENADE_None,
    GRENADE_Throw,
    GRENADE_Roll,
    GRENADE_RemovePin,
    GRENADE_PeekLeft,
    GRENADE_PeekRight,
	GRENADE_PeekLeftThrow,
	GRENADE_PeekRightThrow
};
enum EGrenadeType
{
    GTYPE_None,
    GTYPE_Smoke,
    GTYPE_TearGas,
    GTYPE_FlashBang,
	GTYPE_BreachingCharge
};
enum eHealth
{
    // enum values not recoverable from binary — see 1.56 source
};
enum ERainbowTeamVoices
{
    RTV_PlacingBug,
    RTV_BugActivated,
    RTV_AccessingComputer,
    RTV_ComputerHacked,
    RTV_EscortingHostage,
    RTV_HostageSecured,
    RTV_PlacingExplosives,
    RTV_ExplosivesReady,
    RTV_DesactivatingSecurity,
    RTV_SecurityDeactivated,
    RTV_GasThreat,
    RTV_GrenadeThreat

};
enum ePeekingMode
{
    PEEK_none,
    PEEK_full,
    PEEK_fluid
} m_ePeekingMode;


var					BYTE			m_bIsFiringWeapon;
// #endif

//R6HEARTBEAT
//var                 R6BasicHBLocation m_BasicHBLocation;
var                 EPawnType       m_ePawnType;            // Type of pawn.  Possibility are PAWN_Rainbow, PAWN_Terrorist
                                                            //           and PAWN_Hostage (hostage include civilian)
var BOOL		m_bHBJammerOn;			    // Only for the Heart Beat Jammer. Because it a gun and not a object spwan i use that in the basic location
//var             R6BasicRadarLocation m_BasicRadarLocation;
var float       m_fHeartBeatTime[2];        // Heart Beat time in ms, one for each cicle
var float       m_fHeartBeatFrequency;      // Number of heart beat by minutes.
var int         m_iNoCircleBeat;            // Current circle to be start display

var texture m_pHeartBeatTexture;    // Texture use for the heart beat sensor
var                 INT m_iTeam;	 // In which team the R6Pawn is

// these bitflags is for the isfriendly mechanism, all other teams are neutral
var                 INT m_iFriendlyTeams;   // all teams we are friendly towards
var                 INT m_iEnemyTeams;      // all teams we are hostile towards

//#ifdef R6CODE
var INT m_iExtentX0;    // Extend of last Add to the hash, for debug
var INT m_iExtentY0;
var INT m_iExtentZ0;
var INT m_iExtentX1;
var INT m_iExtentY1;
var INT m_iExtentZ1;
//#endif // #ifdef R6CODE

//R6CODE
var string m_CharacterName;        //Name of the character
var BOOL m_bIsDeadBody;
var BOOL m_bAnimStopedForRG;       // Stop animation on a ragdoll, but after the first frame
var BOOL m_bIsPlayer;              // this will accurately indicate whether this pawn is a player or not

var class<StaticMeshActor>			m_HelmetClass;

var FLOAT m_fBlurValue;
var FLOAT m_fDecrementalBlurValue;
var FLOAT m_fRepDecrementalBlurValue;

//R6CODE
enum EGrenadeType
{
    GTYPE_None,
    GTYPE_Smoke,
    GTYPE_TearGas,
    GTYPE_FlashBang,
	GTYPE_BreachingCharge
};
enum EAnimStateType
{
    SA_Generic,
    SA_Walk,
    SA_Run,
    SA_Turn,
    SA_CrouchToProne,
    SA_ProneToCrouch,
    SA_ProneWalk,
    SA_ProneSideWalk,
    SA_StairUp,
    SA_StairDown,
    SA_LadderHands,
    SA_LadderFoot,
    SA_LameWalkSlide,
    SA_Land,
    SA_DeadFall,
    SA_LameWalkLegOK
};
enum EGunSoundType
{
    GS_ExteriorStereo,
    GS_InteriorStereo,
    GS_ExteriorMono,
    GS_InteriorMono
};
enum ETerroristVoices
{
    TV_Wounded,
    TV_Taunt,
    TV_Surrender,
    TV_SeesTearGas,
    TV_RunAway,
    TV_Grenade,
    TV_CoughsSmoke,
    TV_CoughsGas,
    TV_Backup,
    TV_SeesSurrenderedHostage,
    TV_SeesRainbow_LowAlert,
    TV_SeesRainbow_HighAlert,
    TV_SeesFreeHostage,
    TV_HearsNoize
};
enum EHostageVoices
{
    HV_Run,
    HV_Frozen,
    HV_Foetal,
    HV_Hears_Shooting,
    HV_RnbFollow,
    HV_RndStayPut,
    HV_RnbHurt,
    HV_EntersSmoke,
    HV_EntersGas,
    HV_ClarkReprimand
};
enum ECommonRainbowVoices
{
    CRV_TerroristDown,
    CRV_TakeWound,
    CRV_GoesDown,
    CRV_EntersSmoke,
    CRV_EntersGas
};
enum ERainbowPlayerVoices
{
    RPV_TeamRegroup,
    RPV_TeamMove,
    RPV_TeamHold,
    RPV_AllTeamsHold,
    RPV_AllTeamsMove,
    RPV_TeamMoveAndFrag,
    RPV_TeamMoveAndGas,
    RPV_TeamMoveAndSmoke,
    RPV_TeamMoveAndFlash,
    RPV_TeamOpenDoor,
    RPV_TeamCloseDoor,
	RPV_TeamOpenShudder,
	RPV_TeamCloseShudder,
    RPV_TeamOpenAndClear,
    RPV_TeamOpenAndFrag,
    RPV_TeamOpenAndGas,
    RPV_TeamOpenAndSmoke,
    RPV_TeamOpenAndFlash,
    RPV_TeamOpenFragAndClear,
    RPV_TeamOpenGasAndClear,
    RPV_TeamOpenSmokeAndClear,
    RPV_TeamOpenFlashAndClear,
    RPV_TeamFragAndClear,
    RPV_TeamGasAndClear,
    RPV_TeamSmokeAndClear,
    RPV_TeamFlashAndClear,
    RPV_TeamUseLadder,
    RPV_TeamSecureTerrorist,
    RPV_TeamGoGetHostage,
    RPV_TeamHostageStayPut,
    RPV_TeamStatusReport,
    RPV_TeamUseElectronic,
    RPV_TeamUseDemolition,
    RPV_AlphaGoCode,
    RPV_BravoGoCode,
    RPV_CharlieGoCode,
    RPV_ZuluGoCode,
    RPV_OrderTeamWithGoCode,
    RPV_HostageFollow,
    RPV_HostageStay,
    RPV_HostageSafe,
    RPV_HostageSecured,
    RPV_MemberDown,
    RPV_SniperFree,
    RPV_SniperHold
};
enum ERainbowMembersVoices
{
    RMV_Contact,
    RMV_ContactRear,
    RMV_ContactAndEngages,
    RMV_ContactRearAndEngages,
    RMV_TeamRegroupOnLead,
    RMV_TeamReformOnLead,
    RMV_TeamReceiveOrder,
    RMV_TeamOrderFromLeadNil,
    RMV_NoMoreFrag,
    RMV_NoMoreSmoke,
    RMV_NoMoreGas,
    RMV_NoMoreFlash,
    RMV_OnLadder,
    RMV_MemberDown,
    RMV_AmmoOut,
    RMV_FragNear,
    RMV_EntersGasCloud,
    RMV_TakingFire,
    RMV_TeamHoldUp,
    RMV_TeamMoveOut,
    RMV_HostageFollow,
    RMV_HostageStay,
    RMV_HostageSafe,
    RMV_HostageSecured,
    RMV_RainbowHitRainbow,
    RMV_RainbowHitHostage,
    RMV_DoorReform
};
enum ERainbowOtherTeamVoices
{
    ROTV_SniperHasTarget,
    ROTV_SniperLooseTarget,
    ROTV_SniperTangoDown,
    ROTV_MemberDown,
    ROTV_RainbowHitRainbow,
    ROTV_Objective1,
    ROTV_Objective2,
    ROTV_Objective3,
    ROTV_Objective4,
    ROTV_Objective5,
    ROTV_Objective6,
    ROTV_Objective7,
    ROTV_Objective8,
    ROTV_Objective9,
    ROTV_Objective10,
    ROTV_WaitAlpha,
    ROTV_WaitBravo,
    ROTV_WaitCharlie,
    ROTV_WaitZulu,
    ROTV_EntersSmoke,
    ROTV_EntersGas,
    ROTV_StatusEngaging,
    ROTV_StatusMoving,
    ROTV_StatusWaiting,
    ROTV_StatusWaitAlpha,
    ROTV_StatusWaitBravo,
    ROTV_StatusWaitCharlie,
    ROTV_StatusWaitZulu,
    ROTV_StatusSniperWaitAlpha,
    ROTV_StatusSniperWaitBravo,
    ROTV_StatusSniperWaitCharlie,
    ROTV_StatusSniperUntilAlpha,
    ROTV_StatusSniperUntilBravo,
    ROTV_StatusSniperUntilCharlie
};
enum EPreRecordedMsgVoices
{
    PRMV_NeedBackup,
    PRMV_FollowMe,
    PRMV_CoverArea,
    PRMV_MoveOut,
    PRMV_CoverMe,
    PRMV_Retreat,
    PRMV_ReformOnMe,
    PRMV_Charge,
    PRMV_HoldPosition,
    PRMV_SecureArea,
    PRMV_WaitingOrders,
    PRMV_Assauting,
    PRMV_Defending,
    PRMV_EscortingCargo,
    PRMV_ObjectiveComplete,
    PRMV_ObjectiveReached,
    PRMV_Covering,
    PRMV_WeaponDry,
    PRMV_Move,
    PRMV_Roger,
    PRMV_Negative,
    PRMV_TakingFire,
    PRMV_PinnedDown,
    PRMV_TangoSpotted,
    PRMV_TangoDown,
    PRMV_StatusReport,
    PRMV_Clear
};
enum EMultiCommonVoices
{
    MCV_FragThrow,
    MCV_FlashThrow,
    MCV_GasThrow,
    MCV_SmokeThrow,
    MCV_ActivatingBomb,
    MCV_BombActivated,
    MCV_DeactivatingBomb,
    MCV_BombDeactivated
};

// --- Variables ---
// var ? HitDamageType; // REMOVED IN 1.60
// var ? LastPainTime; // REMOVED IN 1.60
// var ? ReducedDamageType; // REMOVED IN 1.60
// var ? SelectedItem; // REMOVED IN 1.60
// var ? Weapon; // REMOVED IN 1.60
// var ? bCanPickupInventory; // REMOVED IN 1.60
var /* replicated */ Controller Controller;
// vertical acceleration w/ jump
var /* replicated */ float JumpZ;
//var Weapon				PendingWeapon;	// Will become weapon once current weapon is put down
//#ifdef R6CHANGEWEAPONSYSTEM
//Current weapon the character is using
var /* replicated */ R6EngineWeapon EngineWeapon;
// Health: 100 = normal maximum
var travel /* replicated */ int Health;
var /* replicated */ PlayerReplicationInfo PlayerReplicationInfo;
var Vector WalkBob;
// ladder currently being climbed
var /* replicated */ LadderVolume OnLadder;
//R6CODE var float      	BaseEyeHeight; 	// Base eye height above collision center.
//R6CODE var float        	EyeHeight;     	// Current eye height, adjusted for bobbing and stairs.
// Normal of floor pawn is standing on (only used by PHYS_Spider and PHYS_Walking)
var const Vector Floor;
// PlayerControllerState to use when moving on land or air
var name LandMovementState;
// used for getting BreathTimer() messages (for no air, etc.)
var float BreathTime;
var bool bPhysicsAnimUpdate;
var float bobtime;
var float LandBob;
// ^ NEW IN 1.60
// Set when travelling through warpzone (so shouldn't telefrag)
var bool bWarping;
// PlayerControllerState to use when moving in water
var name WaterMovementState;
// default class to use when pawn is controlled by AI (can be modified by an AIScript)
var class<AIController> ControllerClass;
//#endif // #ifndef R6CODE
var float AppliedBob;
// view bob
//#ifndef R6CODE
//var				globalconfig float Bob;
//#else
var float Bob;
//R6CODE var float			OldZ;			// Old Z Location - used for eyeheight smoothing
// physics volume of head
var PhysicsVolume HeadVolume;
// Will become weapon once current weapon is put down
var /* replicated */ R6EngineWeapon PendingWeapon;
// Name used for this pawn type in menus (e.g. player selection)
var localized string MenuName;
// Animation status
var /* replicated */ name AnimStatus;
var name AIScriptTag;
// ^ NEW IN 1.60
// used by dead pawns (for bodies landing and changing collision box)
var bool bThumped;
// crawling - pitch and roll based on surface pawn is on
var bool bCrawler;
// if true crouched (physics will automatically reduce collision height to CrouchHeight)
var bool bWantsToCrouch;
// currently walking (can't jump, affects animations)
var /* replicated */ bool bIsWalking;
// used by swimming
var bool bUpAndOut;
// Physics related flags.
// used by eyeheight adjustment
var bool bJustLanded;
// time of last splash
var float SplashTime;
var /* replicated */ bool m_bRepFinishShotgun;
// set by physics to specify that pawn is currently crouched
var const /* replicated */ bool bIsCrouched;
var class<StaticMeshActor> m_HelmetClass;
// set to tell controller not to modify velocity of a jump/fall
var bool bNoJumpAdjust;
// rotation offset (with respect to pawn.rotation)
var /* replicated */ Rotator m_rRotationOffset;
// how much time pawn can go without air (in seconds)
var float UnderWaterTime;
// Player info.
// Name of owning player (for save games, coop)
var string OwnerName;
// max speed pawn can land without taking damage (also limits what paths AI can use)
var float MaxFallSpeed;
// amount of AirControl available to the pawn
var /* replicated */ float AirControl;
// collision height of dead body lying on the ground
var float CarcassCollisionHeight;
// used to vary destination over NavigationPoints
var float DestinationOffset;
// current nearest path;
var NavigationPoint Anchor;
var Vector m_vEyeLocation;
// to avoid infinite recursion through inventory setdisplay
var bool bUpdatingDisplay;
// AI related flags
var bool bIsFemale;
var bool bInvulnerableBody;
//R6ARMPATCHES
var /* replicated */ Guid m_ArmPatchGUID;
// this will accurately indicate whether this pawn is a player or not
var /* replicated */ bool m_bIsPlayer;
//R6CODE
//Name of the character
var string m_CharacterName;
// used for determining if pawn is turning
var float OldRotYaw;
var bool bPlayedDeath;
var bool bInitializeAnimation;
// momentum to apply when torn off (bTearOff == true)
var /* replicated */ Vector TearOffMomentum;
// use for replicating anims
var /* replicated */ name AnimAction;
// max acceleration rate
var /* replicated */ float AccelRate;
// The maximum swimming speed.
var /* replicated */ float WaterSpeed;
// Movement.
// The maximum ground speed.
var /* replicated */ float GroundSpeed;
// when auto-crouch during movement, continually try to uncrouch once this decrements to zero
var const float UncrouchTime;
// how long to stay straight before strafing again
var float SerpentineTime;
var float SerpentineDist;
var float SkillModifier;
// ^ NEW IN 1.60
var float DesiredSpeed;
//R6ARMPATCHES
// if false, ArmPatch is the default one
var bool m_bArmPatchSet;
var bool bDontPossess;
// ^ NEW IN 1.60
// AIs will ignore me
var bool bAmbientCreature;
// all your 'base', are belong to us
var bool bCanBeBaseForPawns;
// used for third person weapon anims/effects
var /* replicated */ bool bSteadyFiring;
//R6CODE var	bool		bUpdateEyeheight;	// if true, UpdateEyeheight will get called every tick
// if true, not affected by external forces
var bool bIgnoreForces;
var bool bCanClimbLadders;
var bool bCanCrouch;
// ^ NEW IN 1.60
// when auto-crouch during movement, continually try to uncrouch
var const bool bTryToUncrouch;
var /* replicated */ float m_fFallingHeight;
// ^ NEW IN 1.60
// #ifdef R6CODE  - 24 jan 2002 rbrek - moved here for pathfinding
var bool m_bWantsToProne;
var const /* replicated */ bool m_bIsProne;
var const bool m_bTryToUnProne;
var bool m_bCanProne;
// ^ NEW IN 1.60
// used by movement natives
var const bool bReducedSpeed;
// movement capabilities - used by AI
var bool bCanJump;
var bool bCanWalk;
var bool bCanSwim;
var bool bCanFly;
var bool bCanStrafe;
// don't get too close to ledges
var bool bAvoidLedges;
// if bAvoidLedges and bStopAtLedges, Pawn doesn't try to walk along the edge at all
var bool bStopAtLedges;
// if true, inventory wants message whenever this pawn jumps
var bool bCountJumps;
// simulate gravity for this pawn on network clients when predicting position (true if pawn is walking or falling)
var const /* replicated */ bool bSimulateGravity;
// used by C++ physics
var const bool bNoVelocityUpdate;
// Can still fall off ledges, even when walking (for Player Controlled pawns)
var bool bCanWalkOffLedges;
// if true, automatically activate Powerups which have their bAutoActivate==true
var bool bAutoActivate;
var bool bLOSHearing;
// ^ NEW IN 1.60
var bool bSameZoneHearing;
// ^ NEW IN 1.60
var bool bAdjacentZoneHearing;
// ^ NEW IN 1.60
var bool bMuffledHearing;
// ^ NEW IN 1.60
var bool bAroundCornerHearing;
// ^ NEW IN 1.60
										// bLOSHearing=true is like UT/Unreal hearing
// used for third person weapon anims/effects
var bool bAutoFire;
// Update roll when turning to desired rotation (normally false)
var bool bRollToDesired;
// if true, ignore the next PlayFiring() call (used by AnimNotify_FireWeapon)
var bool bIgnorePlayFiring;
//UT2K3
// cache net relevancy test
// network relevancy caching flag
var bool bCachedRelevant;
var float NetRelevancyTime;
var PlayerController LastRealViewer;
var Actor LastViewer;
// use compressed position in networking - true unless want to replicate roll, or very high velocities
var bool bUseCompressedPosition;
// used for third person weapon anims/effects
var byte FlashCount;
// AI basics.
//How visible is the pawn? 0=invisible, 128=normal, 255=highly visible
var byte Visibility;
var float MaxDesiredSpeed;
var float Alertness;
// ^ NEW IN 1.60
var float SightRadius;
// ^ NEW IN 1.60
var float PeripheralVision;
// ^ NEW IN 1.60
//#ifndef R6NOISE
//var(AI) float	HearingThreshold;	// max distance at which a makenoise(1.0) loudness sound can be heard
//#endif // #ifndef R6NOISE
// Physics updating time monitoring (for AI monitoring reaching destinations)
var const float AvgPhysicsTime;
// Max range for melee attack (not including collision radii)
var float MeleeRange;
// radius of next path in route
var float NextPathRadius;
// serpentine direction
var Vector SerpentineDir;
// The maximum flying speed.
var /* replicated */ float AirSpeed;
// Ladder climbing speed
var float LadderSpeed;
// pct. of running speed that walking speed is
var float WalkingPct;
// pct. of running speed that crouched walking speed is
var float CrouchedPct;
// acceleration added to pawn when falling
var Vector ConstantAcceleration;
// Weapons carried by the character, max 4 (primary, handgun, 2 types of grenades)
var /* replicated */ R6EngineWeapon m_WeaponsCarried[4];
var bool m_bDroppedWeapon;
var /* replicated */ bool m_bHaveGasMask;
// Character is using high stance when holding his weapon.
var bool m_bUseHighStance;
// Character want to use HighStance
var /* replicated */ bool m_bWantsHighStance;
// CollisionHeight when crouching
var float CrouchHeight;
// CollisionRadius when crouching
var float CrouchRadius;
// #ifdef R6CODE  - 24 jan 2002 rbrek - moved here for pathfinding
// height of collision cylinder when prone
var float m_fProneHeight;
// radius of collision cylinder when prone
var float m_fProneRadius;
// When the player turn left
var /* replicated */ bool m_bTurnRight;
// When the player turn right
var /* replicated */ bool m_bTurnLeft;
//#ifdef R6CODE
// Last location received by the network.  Used to set the correct location of a pawn when he stop (Velocity=0)
var const Vector m_vLastNetLocation;
// Sound and noise management
// remember location and position of last noises propagated
//#ifndef R6NOISE
//var const 	vector 		noise1spot;
//var const 	float 		noise1time;
//var const	pawn		noise1other;
//var const	float		noise1loudness;
//var const 	vector 		noise2spot;
//var const 	float 		noise2time;
//var const	pawn		noise2other;
//var const	float		noise2loudness;
//#else  // #ifdef R6NOISE
var const Vector noiseSpot;
var const float noiseTime;
var const float noiseLoudness;
var const ENoiseType noiseType;
var float m_NextBulletImpact;
var float m_NextFireSound;
//#endif // #ifdef R6NOISE
var float LastPainSound;
var float SoundDampening;
var float DamageScaling;
// blood effect
var class<Effects> BloodEffect;
var class<Effects> LowDetailBlood;
var class<Effects> LowGoreBlood;
// Animation updating by physics FIXME - this should be handled as an animation object
// Note that animation channels 2 through 11 are used for animation updating
// location of last hit (for playing hit/death anims)
var /* replicated */ Vector TakeHitLocation;
// r6code - rbrek 9 jan 2002
var bool bWasProne;
var bool bWasCrouched;
var bool bWasWalking;
var bool bWasOnGround;
// r6code - rbrek 23 jan 2002
var bool m_bIsLanding;
//R6CODE+
var bool m_bMakesTrailsWhenProning;
//R6CODE-
var EPhysics OldPhysics;
var Vector OldAcceleration;
// FIXME - temp - used for scaling movement
var float BaseMovementRate;
// Forward, Back, Left, Right
var name MovementAnims[4];
//#ifdef R6CODE	// rbrek 18 april 2002 - this is to replace the old MovementAnimRate[]; need something to indicate that anim must be played backward
var byte AnimPlayBackward[4];
//#endif
var name TurnLeftAnim;
// turning anims when standing in place (scaled by turn speed)
var name TurnRightAnim;
var float BlendChangeTime;
// ^ NEW IN 1.60
// used for delaying the start of run blending
var float MovementBlendStartTime;
// bias of strafe blending in forward direction
var float ForwardStrafeBias;
// bias of strafe blending in backward direction
var float BackwardStrafeBias;
// #ifdef R6CODE
// Use when we do a line check for the footstep. Use also for the sound.
var Material m_HitMaterial;
var int m_iIsInStairVolume;
// peeking
var /* replicated */ float m_fCrouchBlendRate;
var /* replicated */ bool m_bPeekingLeft;
var /* replicated */ ePeekingMode m_ePeekingMode;
// ^ NEW IN 1.60
var /* replicated */ byte m_bIsFiringWeapon;
//R6HEARTBEAT
//var                 R6BasicHBLocation m_BasicHBLocation;
// Type of pawn.  Possibility are PAWN_Rainbow, PAWN_Terrorist
var EPawnType m_ePawnType;
                                                            //           and PAWN_Hostage (hostage include civilian)
// Only for the Heart Beat Jammer. Because it a gun and not a object spwan i use that in the basic location
var /* replicated */ bool m_bHBJammerOn;
//var             R6BasicRadarLocation m_BasicRadarLocation;
// Heart Beat time in ms, one for each cicle
var float m_fHeartBeatTime[2];
// Number of heart beat by minutes.
var float m_fHeartBeatFrequency;
// Current circle to be start display
var int m_iNoCircleBeat;
// Texture use for the heart beat sensor
var Texture m_pHeartBeatTexture;
// In which team the R6Pawn is
var /* replicated */ int m_iTeam;
var int m_iDefaultTeam;
// ^ NEW IN 1.60
var bool m_bUseSpecialSkin;
// ^ NEW IN 1.60
// these bitflags is for the isfriendly mechanism, all other teams are neutral
// all teams we are friendly towards
var /* replicated */ int m_iFriendlyTeams;
// all teams we are hostile towards
var /* replicated */ int m_iEnemyTeams;
//#ifdef R6CODE
// Extend of last Add to the hash, for debug
var int m_iExtentX0;
var int m_iExtentY0;
var int m_iExtentZ0;
var int m_iExtentX1;
var int m_iExtentY1;
var int m_iExtentZ1;
var bool m_bIsDeadBody;
// Stop animation on a ragdoll, but after the first frame
var bool m_bAnimStopedForRG;
var float m_fBlurValue;
var float m_fDecrementalBlurValue;
var /* replicated */ float m_fRepDecrementalBlurValue;
//UT2K3
var transient /* replicated */ CompressedPosition PawnPosition;
// Grenade effect
var EGrenadeType m_eEffectiveGrenade;
var float m_fRemainingGrenadeTime;
var Vector m_vGrenadeLocation;
// Flashbang visual effect
var bool m_bFlashBangVisualEffectRequested;
var float m_fFlashBangVisualEffectTime;
var float m_fXFlashBang;
var float m_fYFlashBang;
var float m_fDistanceFlashBang;
var Sound m_sndHBSSound;
var Sound m_sndHearToneSound;
var Sound m_sndHearToneSoundStop;
// Throw or roll the grenade (anims)
var eGrenadeThrow m_eGrenadeThrow;
// SPECIAL replication purposes see Aristo or Serge for info
var /* replicated */ eGrenadeThrow m_eRepGrenadeThrow;
// Prone trail
var int m_iProneTrailPtr;
var /* replicated */ eHealth m_eHealth;
// ^ NEW IN 1.60
var Texture m_ArmPatchTexture;
//R6CODE
var int m_iCurrentFloor;
// last time player sent a voice message for in-game map
var float m_fLastCommunicationTime;
//#ifdef R6CODE
var float m_fPrePivotPawnInitialOffset;

// --- Functions ---
// function ? ChangedWeapon(...); // REMOVED IN 1.60
// function ? DeleteInventory(...); // REMOVED IN 1.60
// function ? GiveWeapon(...); // REMOVED IN 1.60
// function ? HandlePickup(...); // REMOVED IN 1.60
// function ? NextItem(...); // REMOVED IN 1.60
// function ? PlayDyingSound(...); // REMOVED IN 1.60
// function ? PlayHit(...); // REMOVED IN 1.60
// function ? PlayTakeHit(...); // REMOVED IN 1.60
// function ? PlayWeaponSwitch(...); // REMOVED IN 1.60
// function ? TakeDamage(...); // REMOVED IN 1.60
// function ? TossWeapon(...); // REMOVED IN 1.60
// function ? gibbedBy(...); // REMOVED IN 1.60
function Died(Vector HitLocation, Controller Killer) {}
event Landed(Vector HitNormal) {}
event BreathTimer() {}
//=============================================================================
//
// Called immediately before gameplay begins.
//
event PreBeginPlay() {}
singular event BaseChange() {}
simulated function SetAnimStatus(name NewStatus) {}
function bool TouchingWaterVolume() {}
// ^ NEW IN 1.60
event HeadVolumeChange(PhysicsVolume newHeadVolume) {}
//==============
// Encroachment
event bool EncroachingOn(Actor Other) {}
// ^ NEW IN 1.60
simulated function FaceRotation(Rotator NewRotation, float DeltaTime) {}
function KilledBy(Pawn EventInstigator) {}
function JumpOutOfWater(Vector jumpDir) {}
event SetWalking(bool bNewIsWalking) {}
event PostBeginPlay() {}
function Vector WeaponBob(float BobDamping) {}
// ^ NEW IN 1.60
function AddVelocity(Vector NewVelocity) {}
function PlayLanded(float impactVel) {}
function TakeFallingDamage() {}
simulated event AnimEnd(int Channel) {}
function ClientDying(Vector HitLocation) {}
function ClientSetRotation(Rotator NewRotation) {}
function ClientSetLocation(Rotator NewRotation, Vector NewLocation) {}
function ShouldCrouch(bool Crouch) {}
function SetDisplayProperties(bool bLighting, Material NewTexture, ERenderStyle NewStyle) {}
function Trigger(Pawn EventInstigator, Actor Other) {}
event ClientMessage(optional name type, coerce string S) {}
function ReceiveLocalizedMessage(optional Object OptionalObject, optional PlayerReplicationInfo RelatedPRI_2, optional PlayerReplicationInfo RelatedPRI_1, optional int Switch, class<LocalMessage> Message) {}
function bool LineOfSightTo(Actor Other) {}
// ^ NEW IN 1.60
function SetMoveTarget(Actor NewTarget) {}
simulated function SetViewRotation(Rotator NewRotation) {}
function ClimbLadder(LadderVolume L) {}
native function bool IsNeutral(Pawn aPawn) {}
// ^ NEW IN 1.60
native function bool IsEnemy(Pawn aPawn) {}
// ^ NEW IN 1.60
//R6IsFriend
native function bool IsFriend(Pawn aPawn) {}
// ^ NEW IN 1.60
native function bool ReachedDestination(Actor Goal) {}
// ^ NEW IN 1.60
function PossessedBy(Controller C) {}
function bool CheckWaterJump(out Vector WallNormal) {}
// ^ NEW IN 1.60
function CheckBob(float DeltaTime, Vector Y) {}
simulated function DisplayDebug(Canvas Canvas, out float YPos, out float YL) {}
//R6BLOOD
simulated event R6DeadEndedMoving() {}
simulated event StopAnimForRG() {}
native function bool IsAlive() {}
// ^ NEW IN 1.60
//#ifdef R6CHANGEWEAPONSYSTEM
simulated event ReceivedWeapons() {}
simulated event ReceivedEngineWeapon() {}
//#ifdef R6CODE
function float GetPeekingRate() {}
// ^ NEW IN 1.60
simulated event PlayWeaponAnimation() {}
//For shotguns anims in MP
delegate ServerFinishShotgunAnimation() {}
function Reset() {}
function string GetHumanReadableName() {}
// ^ NEW IN 1.60
function PlayTeleportEffect(bool bOut, bool bSound) {}
function UnPossessed() {}
simulated function bool PointOfView() {}
// ^ NEW IN 1.60
function BecomeViewTarget() {}
function DropToGround() {}
function bool CanGrabLadder() {}
// ^ NEW IN 1.60
function bool CanSplash() {}
// ^ NEW IN 1.60
//#ifdef R6CODE
event EndClimbLadder(LadderVolume OldLadder) {}
// return true if controlled by a Player (AI or human)
simulated function bool IsPlayerPawn() {}
// ^ NEW IN 1.60
// return true if controlled by a real live human
simulated function bool IsHumanControlled() {}
// ^ NEW IN 1.60
// return true if controlled by local (not network) player
simulated function bool IsLocallyControlled() {}
// ^ NEW IN 1.60
// rbrek 26 oct 2001
// #ifdef R6CODE - this function was converted to an event so that it can be called from the native
//					code for SeePawn(), LineOfSightTo()...
// simulated function rotator GetViewRotation()
simulated event Rotator GetViewRotation() {}
// ^ NEW IN 1.60
final function bool InGodMode() {}
// ^ NEW IN 1.60
function bool NearMoveTarget() {}
// ^ NEW IN 1.60
final simulated function bool PressingFire() {}
// ^ NEW IN 1.60
final simulated function bool PressingAltFire() {}
// ^ NEW IN 1.60
function Actor GetMoveTarget() {}
// ^ NEW IN 1.60
function bool CanTrigger(Trigger t) {}
// ^ NEW IN 1.60
function SetDefaultDisplayProperties() {}
function FinishedInterpolation() {}
event FellOutOfWorld() {}
// Stub events called when physics actually allows crouch to begin or end
// use these for changing the animation (if script controlled)
event EndCrouch(float HeightAdjust) {}
event StartCrouch(float HeightAdjust) {}
function RestartPlayer() {}
function ClientReStart() {}
delegate ServerChangedWeapon(R6EngineWeapon OldWeapon, R6EngineWeapon W) {}
event EncroachedBy(Actor Other) {}
//Base change - if new base is pawn or decoration, damage based on relative mass and old velocity
// Also, non-players will jump off pawns immediately
function JumpOffPawn() {}
// rbrek 26 oct 2001
// #ifdef R6CODE - this function was converted to an event so that it can be called from the native
//					code for SeePawn(), LineOfSightTo()...
// function vector EyePosition()
event Vector EyePosition() {}
// ^ NEW IN 1.60
simulated event Destroyed() {}
// called after PostBeginPlay on net client
simulated event PostNetBeginPlay() {}
simulated function SetMesh() {}
function Gasp() {}
function SetMovementPhysics() {}
event Falling() {}
event HitWall(Vector HitNormal, Actor Wall) {}
function TakeDrowningDamage() {}
//Player Jumped
function DoJump(bool bUpdating) {}
function PlayMoverHitSound() {}
// blow up into little pieces (implemented in subclass)
simulated function ChunkUp() {}
simulated event SetAnimAction(name NewAction) {}
simulated event PlayDying(Vector HitLoc) {}
simulated function PlayFiring(float Rate, name FiringMode) {}
simulated event StopPlayFiring() {}
simulated event ChangeAnimation() {}
function bool CannotJumpNow() {}
// ^ NEW IN 1.60
simulated event PlayJump() {}
simulated event PlayFalling() {}
simulated function PlayMoving() {}
simulated function PlayWaiting() {}
simulated event PlayLandingAnimation(float impactVel) {}

state Dying
{
    event AnimEnd(int Channel) {}
    function Landed(Vector HitNormal) {}
	// prone body should have low height, wider radius
    function ReduceCylinder() {}
    function BreathTimer() {}
    event ChangeAnimation() {}
    event StopPlayFiring() {}
    function PlayFiring(float Rate, name FiringMode) {}
    simulated function PlayNextAnimation() {}
    function Died(Controller Killer, Vector HitLocation) {}
    function Timer() {}
    function LandThump() {}
    function LieStill() {}
    singular function BaseChange() {}
    function int R6TakeDamage(int iKillValue, int iStunValue, Pawn instigatedBy, Vector vHitLocation, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGoup) {}
// ^ NEW IN 1.60
    function BeginState() {}
}

defaultproperties
{
}
