//=============================================================================
// Pawn - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
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
    abstract
    native
    nativereplication
    placeable;

enum ePeekingMode
{
	PEEK_none,                      // 0
	PEEK_full,                      // 1
	PEEK_fluid                      // 2
};

enum EGrenadeType
{
	GTYPE_None,                     // 0
	GTYPE_Smoke,                    // 1
	GTYPE_TearGas,                  // 2
	GTYPE_FlashBang,                // 3
	GTYPE_BreachingCharge           // 4
};

enum eGrenadeThrow
{
	GRENADE_None,                   // 0
	GRENADE_Throw,                  // 1
	GRENADE_Roll,                   // 2
	GRENADE_RemovePin,              // 3
	GRENADE_PeekLeft,               // 4
	GRENADE_PeekRight,              // 5
	GRENADE_PeekLeftThrow,          // 6
	GRENADE_PeekRightThrow          // 7
};

enum EAnimStateType
{
	SA_Generic,                     // 0
	SA_Walk,                        // 1
	SA_Run,                         // 2
	SA_Turn,                        // 3
	SA_CrouchToProne,               // 4
	SA_ProneToCrouch,               // 5
	SA_ProneWalk,                   // 6
	SA_ProneSideWalk,               // 7
	SA_StairUp,                     // 8
	SA_StairDown,                   // 9
	SA_LadderHands,                 // 10
	SA_LadderFoot,                  // 11
	SA_LameWalkSlide,               // 12
	SA_Land,                        // 13
	SA_DeadFall,                    // 14
	SA_LameWalkLegOK                // 15
};

enum EGunSoundType
{
	GS_ExteriorStereo,              // 0
	GS_InteriorStereo,              // 1
	GS_ExteriorMono,                // 2
	GS_InteriorMono                 // 3
};

// Voice-line enums used by the AI/audio system to select situational clips for each faction.
enum ETerroristVoices
{
	TV_Wounded,                     // 0
	TV_Taunt,                       // 1
	TV_Surrender,                   // 2
	TV_SeesTearGas,                 // 3
	TV_RunAway,                     // 4
	TV_Grenade,                     // 5
	TV_CoughsSmoke,                 // 6
	TV_CoughsGas,                   // 7
	TV_Backup,                      // 8
	TV_SeesSurrenderedHostage,      // 9
	TV_SeesRainbow_LowAlert,        // 10
	TV_SeesRainbow_HighAlert,       // 11
	TV_SeesFreeHostage,             // 12
	TV_HearsNoize                   // 13
};

enum EHostageVoices
{
	HV_Run,                         // 0
	HV_Frozen,                      // 1
	HV_Foetal,                      // 2
	HV_Hears_Shooting,              // 3
	HV_RnbFollow,                   // 4
	HV_RndStayPut,                  // 5
	HV_RnbHurt,                     // 6
	HV_EntersSmoke,                 // 7
	HV_EntersGas,                   // 8
	HV_ClarkReprimand               // 9
};

enum ECommonRainbowVoices
{
	CRV_TerroristDown,              // 0
	CRV_TakeWound,                  // 1
	CRV_GoesDown,                   // 2
	CRV_EntersSmoke,                // 3
	CRV_EntersGas,                  // 4
	CRV_Cough,                      // 5
	CRV_Suffocation                 // 6
};

enum ERainbowPlayerVoices
{
	RPV_TeamRegroup,                // 0
	RPV_TeamMove,                   // 1
	RPV_TeamHold,                   // 2
	RPV_AllTeamsHold,               // 3
	RPV_AllTeamsMove,               // 4
	RPV_TeamMoveAndFrag,            // 5
	RPV_TeamMoveAndGas,             // 6
	RPV_TeamMoveAndSmoke,           // 7
	RPV_TeamMoveAndFlash,           // 8
	RPV_TeamOpenDoor,               // 9
	RPV_TeamCloseDoor,              // 10
	RPV_TeamOpenShudder,            // 11
	RPV_TeamCloseShudder,           // 12
	RPV_TeamOpenAndClear,           // 13
	RPV_TeamOpenAndFrag,            // 14
	RPV_TeamOpenAndGas,             // 15
	RPV_TeamOpenAndSmoke,           // 16
	RPV_TeamOpenAndFlash,           // 17
	RPV_TeamOpenFragAndClear,       // 18
	RPV_TeamOpenGasAndClear,        // 19
	RPV_TeamOpenSmokeAndClear,      // 20
	RPV_TeamOpenFlashAndClear,      // 21
	RPV_TeamFragAndClear,           // 22
	RPV_TeamGasAndClear,            // 23
	RPV_TeamSmokeAndClear,          // 24
	RPV_TeamFlashAndClear,          // 25
	RPV_TeamUseLadder,              // 26
	RPV_TeamSecureTerrorist,        // 27
	RPV_TeamGoGetHostage,           // 28
	RPV_TeamHostageStayPut,         // 29
	RPV_TeamStatusReport,           // 30
	RPV_TeamUseElectronic,          // 31
	RPV_TeamUseDemolition,          // 32
	RPV_AlphaGoCode,                // 33
	RPV_BravoGoCode,                // 34
	RPV_CharlieGoCode,              // 35
	RPV_ZuluGoCode,                 // 36
	RPV_OrderTeamWithGoCode,        // 37
	RPV_HostageFollow,              // 38
	RPV_HostageStay,                // 39
	RPV_HostageSafe,                // 40
	RPV_HostageSecured,             // 41
	RPV_MemberDown,                 // 42
	RPV_SniperFree,                 // 43
	RPV_SniperHold                  // 44
};

enum ERainbowMembersVoices
{
	RMV_Contact,                    // 0
	RMV_ContactRear,                // 1
	RMV_ContactAndEngages,          // 2
	RMV_ContactRearAndEngages,      // 3
	RMV_TeamRegroupOnLead,          // 4
	RMV_TeamReformOnLead,           // 5
	RMV_TeamReceiveOrder,           // 6
	RMV_TeamOrderFromLeadNil,       // 7
	RMV_NoMoreFrag,                 // 8
	RMV_NoMoreSmoke,                // 9
	RMV_NoMoreGas,                  // 10
	RMV_NoMoreFlash,                // 11
	RMV_OnLadder,                   // 12
	RMV_MemberDown,                 // 13
	RMV_AmmoOut,                    // 14
	RMV_FragNear,                   // 15
	RMV_EntersGasCloud,             // 16
	RMV_TakingFire,                 // 17
	RMV_TeamHoldUp,                 // 18
	RMV_TeamMoveOut,                // 19
	RMV_HostageFollow,              // 20
	RMV_HostageStay,                // 21
	RMV_HostageSafe,                // 22
	RMV_HostageSecured,             // 23
	RMV_RainbowHitRainbow,          // 24
	RMV_RainbowHitHostage,          // 25
	RMV_DoorReform                  // 26
};

enum ERainbowOtherTeamVoices
{
	ROTV_SniperHasTarget,           // 0
	ROTV_SniperLooseTarget,         // 1
	ROTV_SniperTangoDown,           // 2
	ROTV_MemberDown,                // 3
	ROTV_RainbowHitRainbow,         // 4
	ROTV_Objective1,                // 5
	ROTV_Objective2,                // 6
	ROTV_Objective3,                // 7
	ROTV_Objective4,                // 8
	ROTV_Objective5,                // 9
	ROTV_Objective6,                // 10
	ROTV_Objective7,                // 11
	ROTV_Objective8,                // 12
	ROTV_Objective9,                // 13
	ROTV_Objective10,               // 14
	ROTV_WaitAlpha,                 // 15
	ROTV_WaitBravo,                 // 16
	ROTV_WaitCharlie,               // 17
	ROTV_WaitZulu,                  // 18
	ROTV_EntersSmoke,               // 19
	ROTV_EntersGas,                 // 20
	ROTV_StatusEngaging,            // 21
	ROTV_StatusMoving,              // 22
	ROTV_StatusWaiting,             // 23
	ROTV_StatusWaitAlpha,           // 24
	ROTV_StatusWaitBravo,           // 25
	ROTV_StatusWaitCharlie,         // 26
	ROTV_StatusWaitZulu,            // 27
	ROTV_StatusSniperWaitAlpha,     // 28
	ROTV_StatusSniperWaitBravo,     // 29
	ROTV_StatusSniperWaitCharlie,   // 30
	ROTV_StatusSniperUntilAlpha,    // 31
	ROTV_StatusSniperUntilBravo,    // 32
	ROTV_StatusSniperUntilCharlie   // 33
};

enum EPreRecordedMsgVoices
{
	PRMV_NeedBackup,                // 0
	PRMV_FollowMe,                  // 1
	PRMV_CoverArea,                 // 2
	PRMV_MoveOut,                   // 3
	PRMV_CoverMe,                   // 4
	PRMV_Retreat,                   // 5
	PRMV_ReformOnMe,                // 6
	PRMV_Charge,                    // 7
	PRMV_HoldPosition,              // 8
	PRMV_SecureArea,                // 9
	PRMV_WaitingOrders,             // 10
	PRMV_Assauting,                 // 11
	PRMV_Defending,                 // 12
	PRMV_EscortingCargo,            // 13
	PRMV_ObjectiveComplete,         // 14
	PRMV_ObjectiveReached,          // 15
	PRMV_Covering,                  // 16
	PRMV_WeaponDry,                 // 17
	PRMV_Move,                      // 18
	PRMV_Roger,                     // 19
	PRMV_Negative,                  // 20
	PRMV_TakingFire,                // 21
	PRMV_PinnedDown,                // 22
	PRMV_TangoSpotted,              // 23
	PRMV_TangoDown,                 // 24
	PRMV_StatusReport,              // 25
	PRMV_Clear                      // 26
};

enum EMultiCommonVoices
{
	MCV_FragThrow,                  // 0
	MCV_FlashThrow,                 // 1
	MCV_GasThrow,                   // 2
	MCV_SmokeThrow,                 // 3
	MCV_ActivatingBomb,             // 4
	MCV_BombActivated,              // 5
	MCV_DeactivatingBomb,           // 6
	MCV_BombDeactivated             // 7
};

enum ERainbowTeamVoices
{
	RTV_PlacingBug,                 // 0
	RTV_BugActivated,               // 1
	RTV_AccessingComputer,          // 2
	RTV_ComputerHacked,             // 3
	RTV_EscortingHostage,           // 4
	RTV_HostageSecured,             // 5
	RTV_PlacingExplosives,          // 6
	RTV_ExplosivesReady,            // 7
	RTV_DesactivatingSecurity,      // 8
	RTV_SecurityDeactivated,        // 9
	RTV_GasThreat,                  // 10
	RTV_GrenadeThreat               // 11
};

enum eHealth
{
	HEALTH_Healthy,                 // 0
	HEALTH_Wounded,                 // 1
	HEALTH_Incapacitated,           // 2
	HEALTH_Dead                     // 3
};

var byte FlashCount;  // used for third person weapon anims/effects
// AI basics.
var byte Visibility;  // How visible is the pawn? 0=invisible, 128=normal, 255=highly visible
var const Actor.ENoiseType noiseType;
//R6CODE-
var Actor.EPhysics OldPhysics;
//#ifdef R6CODE	// rbrek 18 april 2002 - this is to replace the old MovementAnimRate[]; need something to indicate that anim must be played backward
var byte AnimPlayBackward[4];
// NEW IN 1.60
var Pawn.ePeekingMode m_ePeekingMode;
var byte m_bIsFiringWeapon;
//R6HEARTBEAT
//var                 R6BasicHBLocation m_BasicHBLocation;
var Actor.EPawnType m_ePawnType;  // Type of pawn.  Possibility are PAWN_Rainbow, PAWN_Terrorist
// Grenade effect
var Pawn.EGrenadeType m_eEffectiveGrenade;
var Pawn.eGrenadeThrow m_eGrenadeThrow;  // Throw or roll the grenade (anims)
var Pawn.eGrenadeThrow m_eRepGrenadeThrow;  // SPECIAL replication purposes see Aristo or Serge for info
// NEW IN 1.60
var Pawn.eHealth m_eHealth;
var travel int Health;  // Health: 100 = normal maximum
var int m_iIsInStairVolume;
var int m_iNoCircleBeat;  // Current circle to be start display
var int m_iTeam;  // In which team the R6Pawn is
// NEW IN 1.60
var int m_iDefaultTeam;
// these bitflags is for the isfriendly mechanism, all other teams are neutral
var int m_iFriendlyTeams;  // all teams we are friendly towards
var int m_iEnemyTeams;  // all teams we are hostile towards
//#ifdef R6CODE
var int m_iExtentX0;  // Extend of last Add to the hash, for debug
var int m_iExtentY0;
var int m_iExtentZ0;
var int m_iExtentX1;
var int m_iExtentY1;
var int m_iExtentZ1;
// Prone trail
var int m_iProneTrailPtr;
//R6CODE
var int m_iCurrentFloor;
// Physics related flags.
var bool bJustLanded;  // used by eyeheight adjustment
var bool bUpAndOut;  // used by swimming
var bool bIsWalking;  // currently walking (can't jump, affects animations)
var bool bWarping;  // Set when travelling through warpzone (so shouldn't telefrag)
var bool bWantsToCrouch;  // if true crouched (physics will automatically reduce collision height to CrouchHeight)
var const bool bIsCrouched;  // set by physics to specify that pawn is currently crouched
var const bool bTryToUncrouch;  // when auto-crouch during movement, continually try to uncrouch
var() bool bCanCrouch;  // if true, this pawn is capable of crouching
// #ifdef R6CODE  - 24 jan 2002 rbrek - moved here for pathfinding
var bool m_bWantsToProne;
var const bool m_bIsProne;
var const bool m_bTryToUnProne;
var() bool m_bCanProne;
var bool bCrawler;  // crawling - pitch and roll based on surface pawn is on
var const bool bReducedSpeed;  // used by movement natives
// Movement capability flags queried by AI pathfinding to determine which path types are usable.
var bool bCanJump;
var bool bCanWalk;
var bool bCanSwim;
var bool bCanFly;
var bool bCanClimbLadders;
var bool bCanStrafe;
var bool bAvoidLedges;  // don't get too close to ledges
var bool bStopAtLedges;  // if bAvoidLedges and bStopAtLedges, Pawn doesn't try to walk along the edge at all
var bool bNoJumpAdjust;  // set to tell controller not to modify velocity of a jump/fall
var bool bCountJumps;  // if true, inventory wants message whenever this pawn jumps
var const bool bSimulateGravity;  // simulate gravity for this pawn on network clients when predicting position (true if pawn is walking or falling)
//R6CODE var	bool		bUpdateEyeheight;	// if true, UpdateEyeheight will get called every tick
var bool bIgnoreForces;  // if true, not affected by external forces
var const bool bNoVelocityUpdate;  // used by C++ physics
var bool bCanWalkOffLedges;  // Can still fall off ledges, even when walking (for Player Controlled pawns)
var bool bSteadyFiring;  // used for third person weapon anims/effects
var bool bCanBeBaseForPawns;  // all your 'base', are belong to us
// used by dead pawns (for bodies landing and changing collision box)
var bool bThumped;
var bool bInvulnerableBody;
// AI related flags
var bool bIsFemale;
var bool bAutoActivate;  // if true, automatically activate Powerups which have their bAutoActivate==true
var bool bUpdatingDisplay;  // to avoid infinite recursion through inventory setdisplay
var bool bAmbientCreature;  // AIs will ignore me
var(AI) bool bLOSHearing;  // can hear sounds from line-of-sight sources (which are close enough to hear)
										// bLOSHearing=true is like UT/Unreal hearing
var(AI) bool bSameZoneHearing;  // can hear any sound in same zone (if close enough to hear)
var(AI) bool bAdjacentZoneHearing;  // can hear any sound in adjacent zone (if close enough to hear)
var(AI) bool bMuffledHearing;  // can hear sounds through walls (but muffled - sound distance increased to double plus 4x the distance through walls
var(AI) bool bAroundCornerHearing;  // Hear sounds around one corner (slightly more expensive, and bLOSHearing must also be true)
var(AI) bool bDontPossess;  // if true, Pawn won't be possessed at game start
var bool bAutoFire;  // used for third person weapon anims/effects
var bool bRollToDesired;  // Update roll when turning to desired rotation (normally false)
var bool bIgnorePlayFiring;  // if true, ignore the next PlayFiring() call (used by AnimNotify_FireWeapon)
//R6ARMPATCHES
var bool m_bArmPatchSet;  // if false, ArmPatch is the default one
//UT2K3
// cache net relevancy test
var bool bCachedRelevant;  // network relevancy caching flag
var bool bUseCompressedPosition;  // use compressed position in networking - true unless want to replicate roll, or very high velocities
var bool m_bDroppedWeapon;
var bool m_bHaveGasMask;
var bool m_bUseHighStance;  // Character is using high stance when holding his weapon.
var bool m_bWantsHighStance;  // Character want to use HighStance
var bool m_bTurnRight;  // When the player turn left
var bool m_bTurnLeft;  // When the player turn right
var bool bPhysicsAnimUpdate;
var bool bWasProne;  // r6code - rbrek 9 jan 2002
var bool bWasCrouched;
var bool bWasWalking;
var bool bWasOnGround;
var bool bInitializeAnimation;
var bool bPlayedDeath;
var bool m_bIsLanding;  // r6code - rbrek 23 jan 2002
//R6CODE+
var bool m_bMakesTrailsWhenProning;
var bool m_bPeekingLeft;
                                                            //           and PAWN_Hostage (hostage include civilian)
var bool m_bHBJammerOn;  // Only for the Heart Beat Jammer. Because it a gun and not a object spwan i use that in the basic location
// NEW IN 1.60
var bool m_bUseSpecialSkin;
var bool m_bIsDeadBody;
var bool m_bAnimStopedForRG;  // Stop animation on a ragdoll, but after the first frame
var bool m_bIsPlayer;  // this will accurately indicate whether this pawn is a player or not
// Flashbang visual effect
var bool m_bFlashBangVisualEffectRequested;
var bool m_bRepFinishShotgun;
// NEW IN 1.60
var float m_fFallingHeight;
var float NetRelevancyTime;
var float DesiredSpeed;
var float MaxDesiredSpeed;
//#ifndef R6NOISE
//var(AI) float	HearingThreshold;	// max distance at which a makenoise(1.0) loudness sound can be heard
//#endif // #ifndef R6NOISE
var(AI) float Alertness;  // -1 to 1 ->Used within specific states for varying reaction to stimuli
var(AI) float SightRadius;  // Maximum seeing distance.
var(AI) float PeripheralVision;  // Cosine of limits of peripheral vision.
var() float SkillModifier;  // skill modifier (same scale as game difficulty)
var const float AvgPhysicsTime;  // Physics updating time monitoring (for AI monitoring reaching destinations)
var float MeleeRange;  // Max range for melee attack (not including collision radii)
var float DestinationOffset;  // used to vary destination over NavigationPoints
var float NextPathRadius;  // radius of next path in route
var float SerpentineDist;
var float SerpentineTime;  // how long to stay straight before strafing again
var const float UncrouchTime;  // when auto-crouch during movement, continually try to uncrouch once this decrements to zero
// Movement.
var float GroundSpeed;  // The maximum ground speed.
var float WaterSpeed;  // The maximum swimming speed.
var float AirSpeed;  // The maximum flying speed.
var float LadderSpeed;  // Ladder climbing speed
var float AccelRate;  // max acceleration rate
var float JumpZ;  // vertical acceleration w/ jump
var float AirControl;  // amount of AirControl available to the pawn
var float WalkingPct;  // pct. of running speed that walking speed is
var float CrouchedPct;  // pct. of running speed that crouched walking speed is
var float MaxFallSpeed;  // max speed pawn can land without taking damage (also limits what paths AI can use)
var float SplashTime;  // time of last splash
var float CrouchHeight;  // CollisionHeight when crouching
var float CrouchRadius;  // CollisionRadius when crouching
var float BreathTime;  // used for getting BreathTimer() messages (for no air, etc.)
var float UnderWaterTime;  // how much time pawn can go without air (in seconds)
// #ifdef R6CODE  - 24 jan 2002 rbrek - moved here for pathfinding
var float m_fProneHeight;  // height of collision cylinder when prone
var float m_fProneRadius;  // radius of collision cylinder when prone
var const float noiseTime;
var const float noiseLoudness;
var float m_NextBulletImpact;
var float m_NextFireSound;
//#endif // #ifdef R6NOISE
var float LastPainSound;
// view bob
//#ifndef R6CODE
//var				globalconfig float Bob;
//#else
var float Bob;
//#endif // #ifndef R6CODE
var float LandBob;
// NEW IN 1.60
var float AppliedBob;
var float bobtime;
var float SoundDampening;
var float DamageScaling;
var float CarcassCollisionHeight;  // collision height of dead body lying on the ground
var float OldRotYaw;  // used for determining if pawn is turning
var float BaseMovementRate;  // FIXME - temp - used for scaling movement
var(AnimTweaks) float BlendChangeTime;  // time to blend between movement animations
var float MovementBlendStartTime;  // used for delaying the start of run blending
var float ForwardStrafeBias;  // bias of strafe blending in forward direction
var float BackwardStrafeBias;  // bias of strafe blending in backward direction
// peeking
var float m_fCrouchBlendRate;
//var             R6BasicRadarLocation m_BasicRadarLocation;
var float m_fHeartBeatTime[2];  // Heart Beat time in ms, one for each cicle
var float m_fHeartBeatFrequency;  // Number of heart beat by minutes.
var float m_fBlurValue;
var float m_fDecrementalBlurValue;
var float m_fRepDecrementalBlurValue;
var float m_fRemainingGrenadeTime;
var float m_fFlashBangVisualEffectTime;
var float m_fXFlashBang;
var float m_fYFlashBang;
var float m_fDistanceFlashBang;
var float m_fLastCommunicationTime;  // last time player sent a voice message for in-game map
//#ifdef R6CODE
var float m_fPrePivotPawnInitialOffset;
var Controller Controller;
var PlayerController LastRealViewer;
var Actor LastViewer;
var NavigationPoint Anchor;  // current nearest path;
//#ifdef R6CHANGEWEAPONSYSTEM
var R6EngineWeapon EngineWeapon;  // Current weapon the character is using
var R6EngineWeapon PendingWeapon;  // Will become weapon once current weapon is put down
var R6EngineWeapon m_WeaponsCarried[4];  // Weapons carried by the character, max 4 (primary, handgun, 2 types of grenades)
//R6CODE var float			OldZ;			// Old Z Location - used for eyeheight smoothing
var PhysicsVolume HeadVolume;  // physics volume of head
var PlayerReplicationInfo PlayerReplicationInfo;
var LadderVolume OnLadder;  // ladder currently being climbed
// #ifdef R6CODE
var Material m_HitMaterial;  // Use when we do a line check for the footstep. Use also for the sound.
var Texture m_pHeartBeatTexture;  // Texture use for the heart beat sensor
var Sound m_sndHBSSound;
var Sound m_sndHearToneSound;
var Sound m_sndHearToneSoundStop;
var Texture m_ArmPatchTexture;
var(AI) name AIScriptTag;  // tag of AIScript which should be associated with this pawn
var name LandMovementState;  // PlayerControllerState to use when moving on land or air
var name WaterMovementState;  // PlayerControllerState to use when moving in water
// Animation status
var name AnimStatus;
var name AnimAction;  // use for replicating anims
var name MovementAnims[4];  // Forward, Back, Left, Right
//#endif
var name TurnLeftAnim;
var name TurnRightAnim;  // turning anims when standing in place (scaled by turn speed)
// blood effect
var Class<Effects> BloodEffect;
var Class<Effects> LowDetailBlood;
var Class<Effects> LowGoreBlood;
var Class<AIController> ControllerClass;  // default class to use when pawn is controlled by AI (can be modified by an AIScript)
var Class<StaticMeshActor> m_HelmetClass;
var Vector SerpentineDir;  // serpentine direction
var Vector ConstantAcceleration;  // acceleration added to pawn when falling
//R6CODE var float      	BaseEyeHeight; 	// Base eye height above collision center.
//R6CODE var float        	EyeHeight;     	// Current eye height, adjusted for bobbing and stairs.
var const Vector Floor;  // Normal of floor pawn is standing on (only used by PHYS_Spider and PHYS_Walking)
//#ifdef R6CODE
var const Vector m_vLastNetLocation;  // Last location received by the network.  Used to set the correct location of a pawn when he stop (Velocity=0)
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
var Vector WalkBob;
// Animation updating by physics FIXME - this should be handled as an animation object
// Note that animation channels 2 through 11 are used for animation updating
var Vector TakeHitLocation;  // location of last hit (for playing hit/death anims)
var Vector TearOffMomentum;  // momentum to apply when torn off (bTearOff == true)
var Vector OldAcceleration;
var Vector m_vEyeLocation;
var Rotator m_rRotationOffset;  // rotation offset (with respect to pawn.rotation)
var Vector m_vGrenadeLocation;
//R6ARMPATCHES
var Guid m_ArmPatchGUID;
// Player info.
var string OwnerName;  // Name of owning player (for save games, coop)
var localized string MenuName;  // Name used for this pawn type in menus (e.g. player selection)
//R6CODE
var string m_CharacterName;  // Name of the character
//UT2K3
var transient CompressedPosition PawnPosition;

replication
{
	// Pos:0x000
	reliable if((bNetDirty && (int(Role) == int(ROLE_Authority))))
		AnimAction, AnimStatus, 
		Controller, OnLadder, 
		PlayerReplicationInfo, TakeHitLocation, 
		bIsCrouched, bIsWalking, 
		bSimulateGravity, m_ArmPatchGUID, 
		m_WeaponsCarried, m_bHBJammerOn, 
		m_bHaveGasMask, m_bIsProne, 
		m_bWantsHighStance, m_eHealth, 
		m_eRepGrenadeThrow, m_iEnemyTeams, 
		m_iFriendlyTeams, m_iTeam;

	// Pos:0x018
	reliable if(((bNetDirty && bNetOwner) && (int(Role) == int(ROLE_Authority))))
		AccelRate, AirControl, 
		AirSpeed, GroundSpeed, 
		Health, JumpZ, 
		WaterSpeed;

	// Pos:0x03B
	reliable if((bNetDirty && ((!bNetOwner) && (int(Role) == int(ROLE_Authority)))))
		EngineWeapon, PendingWeapon, 
		bSteadyFiring;

	// Pos:0x060
	reliable if((int(Role) == int(ROLE_Authority)))
		m_bIsPlayer, m_fFallingHeight;

	// Pos:0x06D
	reliable if(((!bNetOwner) && (int(Role) == int(ROLE_Authority))))
		m_bPeekingLeft, m_ePeekingMode, 
		m_fCrouchBlendRate;

	// Pos:0x087
	reliable if((((!bNetOwner) && (int(Role) == int(ROLE_Authority))) && m_bIsPlayer))
		m_bRepFinishShotgun, m_rRotationOffset;

	// Pos:0x0AC
	reliable if(((bNetOwner && (int(Role) < int(ROLE_Authority))) || ((!bNetOwner) && (int(Role) == int(ROLE_Authority)))))
		m_bIsFiringWeapon, m_bTurnLeft, 
		m_bTurnRight;

	// Pos:0x0E3
	reliable if((((bTearOff || m_bUseRagdoll) && bNetDirty) && (int(Role) == int(ROLE_Authority))))
		TearOffMomentum;

	// Pos:0x111
	reliable if((int(Role) < int(ROLE_Authority)))
		ServerChangedWeapon, ServerFinishShotgunAnimation;

	// Pos:0x11E
	reliable if((int(Role) == int(ROLE_Authority)))
		m_fRepDecrementalBlurValue;

	// Pos:0x12B
	reliable if(((!bNetOwner) && (int(Role) == int(ROLE_Authority))))
		PawnPosition;
}

//R6BLOOD
simulated event R6DeadEndedMoving()
{
	return;
}

simulated event StopAnimForRG()
{
	return;
}

// Export UPawn::execReachedDestination(FFrame&, void* const)
native function bool ReachedDestination(Actor Goal);

// Export UPawn::execIsFriend(FFrame&, void* const)
//R6IsFriend
native function bool IsFriend(Pawn aPawn);

// Export UPawn::execIsEnemy(FFrame&, void* const)
native function bool IsEnemy(Pawn aPawn);

// Export UPawn::execIsNeutral(FFrame&, void* const)
native function bool IsNeutral(Pawn aPawn);

// Export UPawn::execIsAlive(FFrame&, void* const)
native function bool IsAlive();

//#ifdef R6CHANGEWEAPONSYSTEM
simulated event ReceivedWeapons()
{
	return;
}

simulated event ReceivedEngineWeapon()
{
	return;
}

//#ifdef R6CODE
function float GetPeekingRate()
{
	return;
}

simulated event PlayWeaponAnimation()
{
	return;
}

//For shotguns anims in MP
function ServerFinishShotgunAnimation()
{
	m_bRepFinishShotgun = (!m_bRepFinishShotgun);
	return;
}

function Reset()
{
	// End:0x25
	if(((Controller == none) || Controller.bIsPlayer))
	{
		Destroy();		
	}
	else
	{
		super.Reset();
	}
	return;
}

function string GetHumanReadableName()
{
	// End:0x1A
	if((PlayerReplicationInfo != none))
	{
		return PlayerReplicationInfo.PlayerName;
	}
	return MenuName;
	return;
}

function PlayTeleportEffect(bool bOut, bool bSound)
{
	MakeNoise(1.0000000);
	return;
}

function PossessedBy(Controller C)
{
	Controller = C;
	NetPriority = 3.0000000;
	// End:0x52
	if((C.PlayerReplicationInfo != none))
	{
		PlayerReplicationInfo = C.PlayerReplicationInfo;
		OwnerName = PlayerReplicationInfo.PlayerName;
	}
	// End:0xD3
	if(C.IsA('PlayerController'))
	{
		// End:0x87
		if((int(Level.NetMode) != int(NM_Standalone)))
		{
			RemoteRole = ROLE_AutonomousProxy;
		}
		BecomeViewTarget();
		// End:0xD0
		if((PlayerController(C).Player != none))
		{
			m_ArmPatchGUID = PlayerController(C).Player.m_ArmPatchGUID;
			m_bArmPatchSet = false;
		}		
	}
	else
	{
		RemoteRole = default.RemoteRole;
	}
	SetOwner(Controller);
	ChangeAnimation();
	return;
}

function UnPossessed()
{
	// End:0x3A
	if(((int(Level.NetMode) != int(NM_Standalone)) && (PlayerReplicationInfo != none)))
	{
		m_CharacterName = PlayerReplicationInfo.PlayerName;
	}
	SetOwner(none);
	Controller = none;
	return;
}

simulated function bool PointOfView()
{
	return false;
	return;
}

function BecomeViewTarget()
{
	return;
}

function DropToGround()
{
	bCollideWorld = true;
	bInterpolating = false;
	// End:0x46
	if((Health > 0))
	{
		SetCollision(true, true, true);
		SetPhysics(2);
		AmbientSound = none;
		// End:0x46
		if(IsHumanControlled())
		{
			Controller.GotoState(LandMovementState);
		}
	}
	return;
}

function bool CanGrabLadder()
{
	return (((bCanClimbLadders && (Controller != none)) && (int(Physics) != int(11))) && ((int(Physics) != int(2)) || (Abs(Velocity.Z) <= JumpZ)));
	return;
}

event SetWalking(bool bNewIsWalking)
{
	// End:0x24
	if((bNewIsWalking != bIsWalking))
	{
		bIsWalking = bNewIsWalking;
		ChangeAnimation();
	}
	return;
}

function bool CanSplash()
{
	// End:0x70
	if(((((Level.TimeSeconds - SplashTime) > 0.2500000) && ((int(Physics) == int(2)) || (int(Physics) == int(4)))) && (Abs(Velocity.Z) > float(100))))
	{
		SplashTime = Level.TimeSeconds;
		return true;
	}
	return false;
	return;
}

//#ifdef R6CODE
event EndClimbLadder(LadderVolume OldLadder)
{
	// End:0x1A
	if((Controller != none))
	{
		Controller.EndClimbLadder();
	}
	// End:0x2F
	if((int(Physics) == int(11)))
	{
		SetPhysics(2);
	}
	return;
}

function ClimbLadder(LadderVolume L)
{
	OnLadder = L;
	SetRotation(OnLadder.WallDir);
	SetPhysics(11);
	// End:0x3A
	if(IsHumanControlled())
	{
		Controller.GotoState('PlayerClimbing');
	}
	return;
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string t;

	super.DisplayDebug(Canvas, YL, YPos);
	Canvas.SetDrawColor(byte(255), byte(255), byte(255));
	Canvas.DrawText(((("Animation Action " $ string(AnimAction)) $ " Status ") $ string(AnimStatus)));
	(YPos += YL);
	Canvas.SetPos(4.0000000, YPos);
	Canvas.DrawText(((((("Anchor " $ string(Anchor)) $ " Serpentine Dist ") $ string(SerpentineDist)) $ " Time ") $ string(SerpentineTime)));
	(YPos += YL);
	Canvas.SetPos(4.0000000, YPos);
	t = ((((((("Floor " $ string(Floor)) $ " DesiredSpeed ") $ string(DesiredSpeed)) $ " Crouched ") $ string(bIsCrouched)) $ " Try to uncrouch ") $ string(UncrouchTime));
	// End:0x1A5
	if(((OnLadder != none) || (int(Physics) == int(11))))
	{
		t = ((t $ " on ladder ") $ string(OnLadder));
	}
	Canvas.DrawText(t);
	(YPos += YL);
	Canvas.SetPos(4.0000000, YPos);
	// End:0x237
	if((Controller == none))
	{
		Canvas.SetDrawColor(byte(255), 0, 0);
		Canvas.DrawText("NO CONTROLLER");
		(YPos += YL);
		Canvas.SetPos(4.0000000, YPos);		
	}
	else
	{
		Controller.DisplayDebug(Canvas, YL, YPos);
	}
	return;
}

function Vector WeaponBob(float BobDamping)
{
	local Vector WBob;

	WBob = (BobDamping * WalkBob);
	WBob.Z = ((0.4500000 + (0.5500000 * BobDamping)) * WalkBob.Z);
	// End:0x6D
	if((PlayerController(Controller) != none))
	{
		(WBob += (0.9000000 * PlayerController(Controller).ShakeOffset));
	}
	return WBob;
	return;
}

function CheckBob(float DeltaTime, Vector Y)
{
	local float Speed2D;

	// End:0x159
	if((int(Physics) == int(1)))
	{
		Speed2D = VSize(Velocity);
		// End:0x41
		if((Speed2D < float(10)))
		{
			(bobtime += (0.2000000 * DeltaTime));			
		}
		else
		{
			(bobtime += (DeltaTime * (0.3000000 + ((0.7000000 * Speed2D) / GroundSpeed))));
		}
		WalkBob = (((Y * Bob) * Speed2D) * Sin((8.0000000 * bobtime)));
		AppliedBob = (AppliedBob * (float(1) - FMin(1.0000000, (16.0000000 * DeltaTime))));
		WalkBob.Z = AppliedBob;
		// End:0x10F
		if((Speed2D > float(10)))
		{
			WalkBob.Z = (WalkBob.Z + (((0.7500000 * Bob) * Speed2D) * Sin((16.0000000 * bobtime))));
		}
		// End:0x156
		if((LandBob > 0.0100000))
		{
			(AppliedBob += (FMin(1.0000000, (16.0000000 * DeltaTime)) * LandBob));
			(LandBob *= (float(1) - (float(8) * DeltaTime)));
		}		
	}
	else
	{
		// End:0x212
		if((int(Physics) == int(3)))
		{
			Speed2D = Sqrt(((Velocity.X * Velocity.X) + (Velocity.Y * Velocity.Y)));
			WalkBob = ((((Y * Bob) * 0.5000000) * Speed2D) * Sin((4.0000000 * Level.TimeSeconds)));
			WalkBob.Z = (((Bob * 1.5000000) * Speed2D) * Sin((8.0000000 * Level.TimeSeconds)));			
		}
		else
		{
			bobtime = 0.0000000;
			WalkBob = (WalkBob * (float(1) - FMin(1.0000000, (8.0000000 * DeltaTime))));
		}
	}
	return;
}

// return true if controlled by a Player (AI or human)
simulated function bool IsPlayerPawn()
{
	return ((Controller != none) && Controller.bIsPlayer);
	return;
}

// return true if controlled by a real live human
simulated function bool IsHumanControlled()
{
	return (PlayerController(Controller) != none);
	return;
}

// return true if controlled by local (not network) player
simulated function bool IsLocallyControlled()
{
	// End:0x1B
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		return true;
	}
	// End:0x28
	if((Controller == none))
	{
		return false;
	}
	// End:0x3A
	if((PlayerController(Controller) == none))
	{
		return true;
	}
	return (Viewport(PlayerController(Controller).Player) != none);
	return;
}

// rbrek 26 oct 2001
// #ifdef R6CODE - this function was converted to an event so that it can be called from the native 
//					code for SeePawn(), LineOfSightTo()...
// simulated function rotator GetViewRotation()
simulated event Rotator GetViewRotation()
{
	// End:0x14
	if((Controller == none))
	{
		return Rotation;		
	}
	else
	{
		return Controller.GetViewRotation();
	}
	return;
}

simulated function SetViewRotation(Rotator NewRotation)
{
	// End:0x1C
	if((Controller != none))
	{
		Controller.SetRotation(NewRotation);
	}
	return;
}

final function bool InGodMode()
{
	return ((Controller != none) && Controller.bGodMode);
	return;
}

function bool NearMoveTarget()
{
	// End:0x23
	if(((Controller == none) || (Controller.MoveTarget == none)))
	{
		return false;
	}
	return ReachedDestination(Controller.MoveTarget);
	return;
}

final simulated function bool PressingFire()
{
	return ((Controller != none) && (int(Controller.bFire) != 0));
	return;
}

final simulated function bool PressingAltFire()
{
	return ((Controller != none) && (int(Controller.bAltFire) != 0));
	return;
}

function Actor GetMoveTarget()
{
	// End:0x0D
	if((Controller == none))
	{
		return none;
	}
	return Controller.MoveTarget;
	return;
}

function SetMoveTarget(Actor NewTarget)
{
	// End:0x1F
	if((Controller != none))
	{
		Controller.MoveTarget = NewTarget;
	}
	return;
}

function bool LineOfSightTo(Actor Other)
{
	return ((Controller != none) && Controller.LineOfSightTo(Other));
	return;
}

function ReceiveLocalizedMessage(Class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	// End:0x3D
	if((PlayerController(Controller) != none))
	{
		PlayerController(Controller).ReceiveLocalizedMessage(Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	}
	return;
}

event ClientMessage(coerce string S, optional name type)
{
	// End:0x2E
	if((PlayerController(Controller) != none))
	{
		PlayerController(Controller).ClientMessage(S, type);
	}
	return;
}

function Trigger(Actor Other, Pawn EventInstigator)
{
	// End:0x24
	if((Controller != none))
	{
		Controller.Trigger(Other, EventInstigator);
	}
	return;
}

function bool CanTrigger(Trigger t)
{
	return true;
	return;
}

function SetDisplayProperties(Actor.ERenderStyle NewStyle, Material NewTexture, bool bLighting)
{
	Style = NewStyle;
	Texture = NewTexture;
	bUnlit = bLighting;
	bUpdatingDisplay = false;
	return;
}

function SetDefaultDisplayProperties()
{
	Style = default.Style;
	Texture = default.Texture;
	bUnlit = default.bUnlit;
	bUpdatingDisplay = false;
	return;
}

function FinishedInterpolation()
{
	DropToGround();
	return;
}

function JumpOutOfWater(Vector jumpDir)
{
	Falling();
	Velocity = (jumpDir * WaterSpeed);
	Acceleration = (jumpDir * AccelRate);
	Velocity.Z = FMax(380.0000000, JumpZ);
	bUpAndOut = true;
	return;
}

event FellOutOfWorld()
{
	// End:0x12
	if((int(Role) < int(ROLE_Authority)))
	{
		return;
	}
	Health = -1;
	SetPhysics(0);
	return;
}

function ShouldCrouch(bool Crouch)
{
	bWantsToCrouch = Crouch;
	return;
}

// Stub events called when physics actually allows crouch to begin or end
// use these for changing the animation (if script controlled)
event EndCrouch(float HeightAdjust)
{
	return;
}

event StartCrouch(float HeightAdjust)
{
	return;
}

function RestartPlayer()
{
	return;
}

function AddVelocity(Vector NewVelocity)
{
	// End:0x0B
	if(bIgnoreForces)
	{
		return;
	}
	// End:0x5A
	if(((int(Physics) == int(1)) || (((int(Physics) == int(11)) || (int(Physics) == int(9))) && (NewVelocity.Z > default.JumpZ))))
	{
		SetPhysics(2);
	}
	// End:0x95
	if(((Velocity.Z > float(380)) && (NewVelocity.Z > float(0))))
	{
		(NewVelocity.Z *= 0.5000000);
	}
	(Velocity += NewVelocity);
	return;
}

function KilledBy(Pawn EventInstigator)
{
	local Controller Killer;

	Health = 0;
	// End:0x26
	if((EventInstigator != none))
	{
		Killer = EventInstigator.Controller;
	}
	return;
}

function TakeFallingDamage()
{
	local float Shake;

	// End:0xCD
	if((Velocity.Z < (-0.5000000 * MaxFallSpeed)))
	{
		MakeNoise(FMin(2.0000000, ((-0.5000000 * Velocity.Z) / FMax(JumpZ, 150.0000000))));
		// End:0xCD
		if((Controller != none))
		{
			Shake = FMin(1.0000000, ((-1.0000000 * Velocity.Z) / MaxFallSpeed));
			Controller.ShakeView((0.1750000 + (0.1000000 * Shake)), (850.0000000 * Shake), (Shake * vect(0.0000000, 0.0000000, 1.5000000)), 120000.0000000, vect(0.0000000, 0.0000000, 10.0000000), 1.0000000);
		}
	}
	return;
}

function ClientReStart()
{
	Velocity = vect(0.0000000, 0.0000000, 0.0000000);
	Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
	PlayWaiting();
	return;
}

function ClientSetLocation(Vector NewLocation, Rotator NewRotation)
{
	// End:0x24
	if((Controller != none))
	{
		Controller.ClientSetLocation(NewLocation, NewRotation);
	}
	return;
}

function ClientSetRotation(Rotator NewRotation)
{
	// End:0x1F
	if((Controller != none))
	{
		Controller.ClientSetRotation(NewRotation);
	}
	return;
}

simulated function FaceRotation(Rotator NewRotation, float DeltaTime)
{
	// End:0x24
	if((int(Physics) == int(11)))
	{
		SetRotation(OnLadder.WallDir);		
	}
	else
	{
		// End:0x52
		if(((int(Physics) == int(1)) || (int(Physics) == int(2))))
		{
			NewRotation.Pitch = 0;
		}
		SetRotation(NewRotation);
	}
	return;
}

function ClientDying(Vector HitLocation)
{
	// End:0x1F
	if((Controller != none))
	{
		Controller.ClientDying(HitLocation);
	}
	return;
}

function ServerChangedWeapon(R6EngineWeapon OldWeapon, R6EngineWeapon W)
{
	return;
}

//==============
// Encroachment
event bool EncroachingOn(Actor Other)
{
	// End:0x14
	if(Other.bWorldGeometry)
	{
		return true;
	}
	// End:0x54
	if(((((Controller == none) || (!Controller.bIsPlayer)) || bWarping) && (Pawn(Other) != none)))
	{
		return true;
	}
	return false;
	return;
}

event EncroachedBy(Actor Other)
{
	return;
}

//Base change - if new base is pawn or decoration, damage based on relative mass and old velocity
// Also, non-players will jump off pawns immediately
function JumpOffPawn()
{
	(Velocity += ((float(100) + CollisionRadius) * VRand()));
	Velocity.Z = (200.0000000 + CollisionHeight);
	SetPhysics(2);
	bNoJumpAdjust = true;
	Controller.SetFall();
	return;
}

singular event BaseChange()
{
	local float decorMass;

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
		// End:0x5F
		if((Pawn(Base) != none))
		{
			// End:0x5F
			if((!Pawn(Base).bCanBeBaseForPawns))
			{
				JumpOffPawn();
			}
		}
	}
	return;
}

// rbrek 26 oct 2001
// #ifdef R6CODE - this function was converted to an event so that it can be called from the native 
//					code for SeePawn(), LineOfSightTo()...
// function vector EyePosition()
event Vector EyePosition()
{
	return WalkBob;
	return;
}

simulated event Destroyed()
{
	// End:0x1E
	if((Shadow != none))
	{
		Shadow.Destroy();
		Shadow = none;
	}
	// End:0x38
	if((Controller != none))
	{
		Controller.PawnDied();
	}
	// End:0x4A
	if((int(Role) < int(ROLE_Authority)))
	{
		return;
	}
	// End:0x61
	if((EngineWeapon != none))
	{
		EngineWeapon.Destroy();
	}
	// End:0x78
	if((PendingWeapon != none))
	{
		PendingWeapon.Destroy();
	}
	EngineWeapon = none;
	PendingWeapon = none;
	super.Destroyed();
	return;
}

//=============================================================================
//
// Called immediately before gameplay begins.
//
event PreBeginPlay()
{
	super.PreBeginPlay();
	Instigator = self;
	DesiredRotation = Rotation;
	// End:0x23
	if(bDeleteMe)
	{
		return;
	}
	// End:0x42
	if((MenuName == ""))
	{
		MenuName = GetItemName(string(Class));
	}
	return;
}

event PostBeginPlay()
{
	local AIScript A;

	super.PostBeginPlay();
	SplashTime = 0.0000000;
	OldRotYaw = float(Rotation.Yaw);
	// End:0x10C
	if(((Level.bStartup && (Health > 0)) && (!bDontPossess)))
	{
		// End:0xB1
		if(((AIScriptTag != 'None') && (AIScriptTag != 'None')))
		{
			// End:0x88
			foreach AllActors(Class'Engine.AIScript', A, AIScriptTag)
			{
				// End:0x88
				break;				
			}			
			// End:0xB1
			if((A != none))
			{
				A.SpawnControllerFor(self);
				// End:0xB1
				if((Controller != none))
				{
					return;
				}
			}
		}
		// End:0xD7
		if(((ControllerClass != none) && (Controller == none)))
		{
			Controller = Spawn(ControllerClass);
		}
		// End:0x10C
		if((Controller != none))
		{
			Controller.Possess(self);
			(AIController(Controller).Skill += SkillModifier);
		}
	}
	return;
}

// called after PostBeginPlay on net client
simulated event PostNetBeginPlay()
{
	// End:0x12
	if((int(Role) == int(ROLE_Authority)))
	{
		return;
	}
	// End:0x2D
	if((Controller != none))
	{
		Controller.Pawn = self;
	}
	// End:0x5F
	if(((PlayerReplicationInfo != none) && (PlayerReplicationInfo.Owner == none)))
	{
		PlayerReplicationInfo.SetOwner(Controller);
	}
	PlayWaiting();
	return;
}

simulated function SetMesh()
{
	LinkMesh(default.Mesh);
	return;
}

function Gasp()
{
	return;
}

function SetMovementPhysics()
{
	return;
}

function Died(Controller Killer, Vector HitLocation)
{
	// End:0x0B
	if(bDeleteMe)
	{
		return;
	}
	// End:0x33
	if((Killer != none))
	{
		TriggerEvent(Event, self, Killer.Pawn);		
	}
	else
	{
		TriggerEvent(Event, self, none);
	}
	(Velocity.Z *= 1.3000000);
	// End:0x6E
	if(IsHumanControlled())
	{
		PlayerController(Controller).ForceDeathUpdate();
	}
	PlayDying(HitLocation);
	// End:0x96
	if(Level.Game.bGameEnded)
	{
		return;
	}
	// End:0xB9
	if(((!bPhysicsAnimUpdate) && (!IsLocallyControlled())))
	{
		ClientDying(HitLocation);
	}
	return;
}

event Falling()
{
	// End:0x1A
	if((Controller != none))
	{
		Controller.SetFall();
	}
	return;
}

event HitWall(Vector HitNormal, Actor Wall)
{
	return;
}

event Landed(Vector HitNormal)
{
	LandBob = FMin(50.0000000, (0.0550000 * Velocity.Z));
	TakeFallingDamage();
	// End:0x3F
	if((Health > 0))
	{
		PlayLanded(Velocity.Z);
	}
	// End:0x7C
	if((Velocity.Z < (-1.4000000 * JumpZ)))
	{
		MakeNoise(((-0.5000000 * Velocity.Z) / FMax(JumpZ, 150.0000000)));
	}
	bJustLanded = true;
	return;
}

event HeadVolumeChange(PhysicsVolume newHeadVolume)
{
	// End:0x28
	if(((int(Level.NetMode) == int(NM_Client)) || (Controller == none)))
	{
		return;
	}
	// End:0x93
	if(HeadVolume.bWaterVolume)
	{
		// End:0x90
		if((!newHeadVolume.bWaterVolume))
		{
			// End:0x85
			if(((Controller.bIsPlayer && (BreathTime > float(0))) && (BreathTime < float(8))))
			{
				Gasp();
			}
			BreathTime = -1.0000000;
		}		
	}
	else
	{
		// End:0xB0
		if(newHeadVolume.bWaterVolume)
		{
			BreathTime = UnderWaterTime;
		}
	}
	return;
}

function bool TouchingWaterVolume()
{
	local PhysicsVolume V;

	// End:0x26
	foreach TouchingActors(Class'Engine.PhysicsVolume', V)
	{
		// End:0x25
		if(V.bWaterVolume)
		{			
			return true;
		}		
	}	
	return false;
	return;
}

event BreathTimer()
{
	// End:0x28
	if(((Health < 0) || (int(Level.NetMode) == int(NM_Client))))
	{
		return;
	}
	TakeDrowningDamage();
	// End:0x44
	if((Health > 0))
	{
		BreathTime = 2.0000000;
	}
	return;
}

function TakeDrowningDamage()
{
	return;
}

function bool CheckWaterJump(out Vector WallNormal)
{
	local Actor HitActor;
	local Vector HitLocation, HitNormal, checkpoint, Start, checkNorm, Extent;

	checkpoint = Vector(Rotation);
	checkpoint.Z = 0.0000000;
	checkNorm = Normal(checkpoint);
	checkpoint = (Location + (CollisionRadius * checkNorm));
	Extent = (CollisionRadius * vect(1.0000000, 1.0000000, 0.0000000));
	Extent.Z = CollisionHeight;
	HitActor = Trace(HitLocation, HitNormal, checkpoint, Location, true, Extent);
	// End:0x12E
	if(((HitActor != none) && (Pawn(HitActor) == none)))
	{
		WallNormal = (float(-1) * HitNormal);
		Start = Location;
		(Start.Z += (1.1000000 * 33.0000000));
		checkpoint = (Start + ((float(2) * CollisionRadius) * checkNorm));
		HitActor = Trace(HitLocation, HitNormal, checkpoint, Start, true);
		// End:0x12E
		if((HitActor == none))
		{
			return true;
		}
	}
	return false;
	return;
}

//Player Jumped
function DoJump(bool bUpdating)
{
	// End:0x16F
	if((((!bIsCrouched) && (!bWantsToCrouch)) && (((int(Physics) == int(1)) || (int(Physics) == int(11))) || (int(Physics) == int(9)))))
	{
		// End:0xB6
		if((int(Role) == int(ROLE_Authority)))
		{
			// End:0xB6
			if(((Level.Game != none) && (int(Level.Game.Difficulty) > 0)))
			{
				MakeNoise((0.1000000 * float(Level.Game.Difficulty)));
			}
		}
		// End:0xDB
		if((int(Physics) == int(9)))
		{
			Velocity = (JumpZ * Floor);			
		}
		else
		{
			// End:0xFE
			if((int(Physics) == int(11)))
			{
				Velocity.Z = 0.0000000;				
			}
			else
			{
				// End:0x11A
				if(bIsWalking)
				{
					Velocity.Z = default.JumpZ;					
				}
				else
				{
					Velocity.Z = JumpZ;
				}
			}
		}
		// End:0x16A
		if(((Base != none) && (!Base.bWorldGeometry)))
		{
			(Velocity.Z += Base.Velocity.Z);
		}
		SetPhysics(2);
	}
	return;
}

function PlayMoverHitSound()
{
	return;
}

// blow up into little pieces (implemented in subclass)		
simulated function ChunkUp()
{
	// End:0x56
	if(((int(Level.NetMode) != int(NM_Client)) && (Controller != none)))
	{
		// End:0x4A
		if(Controller.bIsPlayer)
		{
			Controller.PawnDied();			
		}
		else
		{
			Controller.Destroy();
		}
	}
	Destroy();
	return;
}

simulated event SetAnimAction(name NewAction)
{
	return;
}

simulated function SetAnimStatus(name NewStatus)
{
	// End:0x20
	if((NewStatus != AnimStatus))
	{
		AnimStatus = NewStatus;
		ChangeAnimation();
	}
	return;
}

simulated event PlayDying(Vector HitLoc)
{
	GotoState('Dying');
	// End:0x31
	if(bPhysicsAnimUpdate)
	{
		bReplicateMovement = false;
		bTearOff = true;
		(Velocity += TearOffMomentum);
		SetPhysics(2);
	}
	bPlayedDeath = true;
	return;
}

simulated function PlayFiring(float Rate, name FiringMode)
{
	return;
}

simulated event StopPlayFiring()
{
	bSteadyFiring = false;
	return;
}

simulated event ChangeAnimation()
{
	// End:0x21
	if(((Controller != none) && Controller.bControlAnimations))
	{
		return;
	}
	PlayWaiting();
	PlayMoving();
	return;
}

simulated event AnimEnd(int Channel)
{
	// End:0x11
	if((Channel == 0))
	{
		PlayWaiting();
	}
	return;
}

function bool CannotJumpNow()
{
	return false;
	return;
}

simulated event PlayJump()
{
	return;
}

simulated event PlayFalling()
{
	return;
}

simulated function PlayMoving()
{
	return;
}

simulated function PlayWaiting()
{
	return;
}

function PlayLanded(float impactVel)
{
	// End:0x16
	if((!bPhysicsAnimUpdate))
	{
		PlayLandingAnimation(impactVel);
	}
	return;
}

simulated event PlayLandingAnimation(float impactVel)
{
	return;
}

state Dying
{
	ignores BreathTimer;

	event ChangeAnimation()
	{
		return;
	}

	event StopPlayFiring()
	{
		return;
	}

	function PlayFiring(float Rate, name FiringMode)
	{
		return;
	}

	simulated function PlayNextAnimation()
	{
		return;
	}

	function Died(Controller Killer, Vector HitLocation)
	{
		return;
	}

	function Timer()
	{
		// End:0x0E
		if((!PlayerCanSeeMe()))
		{
			Destroy();			
		}
		else
		{
			SetTimer(2.0000000, false);
		}
		return;
	}

	function Landed(Vector HitNormal)
	{
		local Rotator finalRot;

		LandBob = FMin(50.0000000, (0.0550000 * Velocity.Z));
		finalRot = Rotation;
		finalRot.Roll = 0;
		finalRot.Pitch = 0;
		SetRotation(finalRot);
		SetPhysics(0);
		SetCollision(true, false, false);
		// End:0x63
		if((!IsAnimating(0)))
		{
			LieStill();
		}
		return;
	}

	// prone body should have low height, wider radius
	function ReduceCylinder()
	{
		local float OldHeight, OldRadius;
		local Vector OldLocation;

		SetCollision(true, false, false);
		OldHeight = CollisionHeight;
		OldRadius = CollisionRadius;
		SetCollisionSize((1.5000000 * default.CollisionRadius), CarcassCollisionHeight);
		PrePivot = (vect(0.0000000, 0.0000000, 1.0000000) * (OldHeight - CollisionHeight));
		OldLocation = Location;
		// End:0xCA
		if((!SetLocation((OldLocation - PrePivot))))
		{
			SetCollisionSize(OldRadius, CollisionHeight);
			// End:0xCA
			if((!SetLocation((OldLocation - PrePivot))))
			{
				SetCollisionSize(CollisionRadius, OldHeight);
				SetCollision(false, false, false);
				PrePivot = vect(0.0000000, 0.0000000, 0.0000000);
				// End:0xCA
				if((!SetLocation(OldLocation)))
				{
					ChunkUp();
				}
			}
		}
		PrePivot = (PrePivot + vect(0.0000000, 0.0000000, 3.0000000));
		return;
	}

	function LandThump()
	{
		// End:0x18
		if((int(Physics) == int(0)))
		{
			bThumped = true;
		}
		return;
	}

	event AnimEnd(int Channel)
	{
		// End:0x0D
		if((Channel != 0))
		{
			return;
		}
		// End:0x26
		if((int(Physics) == int(0)))
		{
			LieStill();			
		}
		else
		{
			// End:0x46
			if(PhysicsVolume.bWaterVolume)
			{
				bThumped = true;
				LieStill();
			}
		}
		return;
	}

	function LieStill()
	{
		// End:0x11
		if((!bThumped))
		{
			LandThump();
		}
		// End:0x26
		if((CollisionHeight != CarcassCollisionHeight))
		{
			ReduceCylinder();
		}
		return;
	}

	singular function BaseChange()
	{
		// End:0x13
		if((Base == none))
		{
			SetPhysics(2);			
		}
		else
		{
			// End:0x29
			if((Pawn(Base) != none))
			{
				ChunkUp();
			}
		}
		return;
	}

// NEW IN 1.60
	function int R6TakeDamage(int iKillValue, int iStunValue, Pawn instigatedBy, Vector vHitLocation, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGoup)
	{
		return 0;
		return;
	}

	function BeginState()
	{
		// End:0x32
		if((bTearOff && (int(Level.NetMode) == int(NM_DedicatedServer))))
		{
			LifeSpan = 1.0000000;			
		}
		else
		{
			SetTimer(12.0000000, false);
		}
		SetPhysics(2);
		bInvulnerableBody = true;
		// End:0x83
		if((Controller != none))
		{
			// End:0x77
			if(Controller.bIsPlayer)
			{
				Controller.PawnDied();				
			}
			else
			{
				Controller.Destroy();
			}
		}
		return;
	}
Begin:

	Sleep(0.2000000);
	bInvulnerableBody = false;
	stop;			
}

defaultproperties
{
	Visibility=128
	Health=100
	bCanJump=true
	bCanWalk=true
	bLOSHearing=true
	bUseCompressedPosition=true
	m_bUseHighStance=true
	DesiredSpeed=1.0000000
	MaxDesiredSpeed=1.0000000
	SightRadius=5000.0000000
	AvgPhysicsTime=0.1000000
	GroundSpeed=600.0000000
	WaterSpeed=300.0000000
	AirSpeed=600.0000000
	LadderSpeed=200.0000000
	AccelRate=2048.0000000
	JumpZ=420.0000000
	AirControl=0.0500000
	WalkingPct=0.5000000
	CrouchedPct=0.5000000
	MaxFallSpeed=1200.0000000
	CrouchHeight=40.0000000
	CrouchRadius=34.0000000
	Bob=0.0160000
	SoundDampening=1.0000000
	DamageScaling=1.0000000
	CarcassCollisionHeight=23.0000000
	BaseMovementRate=525.0000000
	BlendChangeTime=0.2500000
	LandMovementState="PlayerWalking"
	WaterMovementState="PlayerSwimming"
	ControllerClass=Class'Engine.AIController'
	RemoteRole=2
	DrawType=2
	bCanTeleport=true
	bOwnerNoSee=true
	bStasis=true
	bAcceptsProjectors=true
	bDisturbFluidSurface=true
	bUpdateSimulatedPosition=true
	bTravel=true
	bShouldBaseAtStartup=true
	bCollideActors=true
	bCollideWorld=true
	bBlockActors=true
	bBlockPlayers=true
	bProjTarget=true
	bRotateToDesired=true
	bDirectional=true
	SoundRadius=9.0000000
    TransientSoundVolume=2.0000000
	CollisionRadius=34.0000000
	CollisionHeight=78.0000000
	NetPriority=2.0000000
	Texture=Texture'Engine.S_Pawn'
	RotationRate=(Pitch=4096,Yaw=20000,Roll=3072)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var bCanPickupInventory
// REMOVED IN 1.60: var Weapon
// REMOVED IN 1.60: var SelectedItem
// REMOVED IN 1.60: var LastPainTime
// REMOVED IN 1.60: var ReducedDamageType
// REMOVED IN 1.60: var b
// REMOVED IN 1.60: var HitDamageType
// REMOVED IN 1.60: var ePeekingMode
// REMOVED IN 1.60: var eHealth
// REMOVED IN 1.60: function AdjustAim
// REMOVED IN 1.60: function ShootSpecial
// REMOVED IN 1.60: function HandlePickup
// REMOVED IN 1.60: function GiveWeapon
// REMOVED IN 1.60: function TossWeapon
// REMOVED IN 1.60: function NextItem
// REMOVED IN 1.60: function FindInventoryType
// REMOVED IN 1.60: function AddInventory
// REMOVED IN 1.60: function DeleteInventory
// REMOVED IN 1.60: function ChangedWeapon
// REMOVED IN 1.60: function GetWeaponBoneFor
// REMOVED IN 1.60: function gibbedBy
// REMOVED IN 1.60: function TakeDamage
// REMOVED IN 1.60: function Gibbed
// REMOVED IN 1.60: function IsInPain
// REMOVED IN 1.60: function PlayDyingSound
// REMOVED IN 1.60: function PlayHit
// REMOVED IN 1.60: function PlayTakeHit
// REMOVED IN 1.60: function PlayWeaponSwitch
