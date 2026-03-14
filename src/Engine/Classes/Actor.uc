//=============================================================================
// Actor - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// Actor: The base class of all actors.
// Actor is the base class of all gameplay objects.  
// A large number of properties, behaviors and interfaces are implemented in Actor, including:
//
// -	Display 
// -	Animation
// -	Physics and world interaction
// -	Making sounds
// -	Networking properties
// -	Actor creation and destruction
// -	Triggering and timers
// -	Actor iterator functions
// -	Message broadcasting
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Actor extends Object
	abstract
	native
 nativereplication;

const MAXSTEPHEIGHT = 33.0;
const MINFLOORZ = 0.7;
const TEAM_None = 0x00000;
const TEAM_Orders = 0x00001;
const TEAM_OpenDoor = 0x00010;
const TEAM_CloseDoor = 0x00020;
const TEAM_Grenade = 0x00040;
const TEAM_ClearRoom = 0x00080;
const TEAM_Move = 0x00100;
const TEAM_ClimbLadder = 0x00200;
const TEAM_SecureTerrorist = 0x00400;
const TEAM_EscortHostage = 0x00800;
const TEAM_DisarmBomb = 0x01000;
const TEAM_InteractDevice = 0x02000;
const TEAM_OpenAndClear = 0x00090;
const TEAM_OpenAndGrenade = 0x00050;
const TEAM_OpenGrenadeAndClear = 0x000d0;
const TEAM_GrenadeAndClear = 0x000c0;
const TEAM_MoveAndGrenade = 0x00140;
const c_iTeamNumHostage = 0;
const c_iTeamNumTerrorist = 1;
const c_iTeamNumAlpha = 2;
const c_iTeamNumBravo = 3;
const c_iTeamNumUnknow = 4;
const c_iTeamNumPrisonerAlpha = 5;
const c_iTeamNumPrisonerBravo = 6;
const c_iTeamNumFreeBackup = 7;
const DEATHMSG_CONNECTIONLOST = 1;
const DEATHMSG_PENALTY = 2;
const DEATHMSG_KAMAKAZE = 3;
const DEATHMSG_SWITCHTEAM = 4;
const DEATHMSG_HOSTAGE_DIED = 5;
const DEATHMSG_HOSTAGE_KILLEDBY = 6;
const DEATHMSG_HOSTAGE_KILLEDBYTERRO = 7;
const DEATHMSG_RAINBOW_KILLEDBYTERRO = 8;
const DEATHMSG_KILLED_BY_BOMB = 9;
const DEATHMSG_PRISONER_KILLEDBY = 10;
const DEATHMSG_RAINBOW_SUFFOCATE = 11;
const DEATHMSG_INTRUDER_KILLEDBY = 12;
const TF_TraceActors = 0x0001;
const TF_Visibility = 0x0002;
const TF_LineOfFire = 0x0004;
const TF_SkipVolume = 0x0008;
const TF_ShadowCast = 0x0010;
const TF_SkipPawn = 0x0020;

enum eKillResult
{
	KR_None,                        // 0
	KR_Wound,                       // 1
	KR_Incapacitate,                // 2
	KR_Killed                       // 3
};

enum eStunResult
{
	SR_None,                        // 0
	SR_Stunned,                     // 1
	SR_Dazed,                       // 2
	SR_KnockedOut                   // 3
};

enum EStance
{
	STAN_None,                      // 0
	STAN_Standing,                  // 1
	STAN_Crouching,                 // 2
	STAN_Prone                      // 3
};

enum EPhysics
{
	PHYS_None,                      // 0
	PHYS_Walking,                   // 1
	PHYS_Falling,                   // 2
	PHYS_Swimming,                  // 3
	PHYS_Flying,                    // 4
	PHYS_Rotating,                  // 5
	PHYS_Projectile,                // 6
	PHYS_Interpolating,             // 7
	PHYS_MovingBrush,               // 8
	PHYS_Spider,                    // 9
	PHYS_Trailer,                   // 10
	PHYS_Ladder,                    // 11
	PHYS_RootMotion,                // 12
	PHYS_Karma,                     // 13
	PHYS_KarmaRagDoll               // 14
};

enum ENetRole
{
	ROLE_None,                      // 0
	ROLE_DumbProxy,                 // 1
	ROLE_SimulatedProxy,            // 2
	ROLE_AutonomousProxy,           // 3
	ROLE_Authority                  // 4
};

enum EDrawType
{
	DT_None,                        // 0
	DT_Sprite,                      // 1
	DT_Mesh,                        // 2
	DT_Brush,                       // 3
	DT_RopeSprite,                  // 4
	DT_VerticalSprite,              // 5
	DT_Terraform,                   // 6
	DT_SpriteAnimOnce,              // 7
	DT_StaticMesh,                  // 8
	DT_DrawType,                    // 9
	DT_Particle,                    // 10
	DT_AntiPortal,                  // 11
	DT_FluidSurface                 // 12
};

enum ERenderStyle
{
	STY_None,                       // 0
	STY_Normal,                     // 1
	STY_Masked,                     // 2
	STY_Translucent,                // 3
	STY_Modulated,                  // 4
	STY_Alpha,                      // 5
	STY_Particle,                   // 6
	STY_Highlight                   // 7
};

enum ESoundOcclusion
{
	OCCLUSION_Default,              // 0
	OCCLUSION_None,                 // 1
	OCCLUSION_BSP,                  // 2
	OCCLUSION_StaticMeshes          // 3
};

enum ESoundSlot
{
	SLOT_None,                      // 0
	SLOT_Ambient,                   // 1
	SLOT_Guns,                      // 2
	SLOT_SFX,                       // 3
	SLOT_GrenadeEffect,             // 4
	SLOT_Music,                     // 5
	SLOT_Talk,                      // 6
	SLOT_Speak,                     // 7
	SLOT_HeadSet,                   // 8
	SLOT_Menu,                      // 9
	SLOT_Instruction,               // 10
	SLOT_StartingSound              // 11
};

enum ESoundVolume
{
	VOLUME_Music,                   // 0
	VOLUME_Voices,                  // 1
	VOLUME_FX,                      // 2
	VOLUME_Grenade                  // 3
};

enum ESendSoundStatus
{
	SSTATUS_SendToPlayer,           // 0
	SSTATUS_SendToMPTeam,           // 1
	SSTATUS_SendToAll               // 2
};

enum ELoadBankSound
{
	LBS_Fix,                        // 0
	LBS_UC,                         // 1
	LBS_Map,                        // 2
	LBS_Gun                         // 3
};

enum EMusicTransition
{
	MTRAN_None,                     // 0
	MTRAN_Instant,                  // 1
	MTRAN_Segue,                    // 2
	MTRAN_Fade,                     // 3
	MTRAN_FastFade,                 // 4
	MTRAN_SlowFade                  // 5
};

enum ELightType
{
	LT_None,                        // 0
	LT_Steady,                      // 1
	LT_Pulse,                       // 2
	LT_Blink,                       // 3
	LT_Flicker,                     // 4
	LT_Strobe,                      // 5
	LT_BackdropLight,               // 6
	LT_SubtlePulse,                 // 7
	LT_TexturePaletteOnce,          // 8
	LT_TexturePaletteLoop           // 9
};

enum ELightEffect
{
	LE_None,                        // 0
	LE_TorchWaver,                  // 1
	LE_FireWaver,                   // 2
	LE_WateryShimmer,               // 3
	LE_Searchlight,                 // 4
	LE_SlowWave,                    // 5
	LE_FastWave,                    // 6
	LE_CloudCast,                   // 7
	LE_StaticSpot,                  // 8
	LE_Shock,                       // 9
	LE_Disco,                       // 10
	LE_Warp,                        // 11
	LE_Spotlight,                   // 12
	LE_NonIncidence,                // 13
	LE_Shell,                       // 14
	LE_OmniBumpMap,                 // 15
	LE_Interference,                // 16
	LE_Cylinder,                    // 17
	LE_Rotor,                       // 18
	LE_Unused,                      // 19
	LE_Sunlight                     // 20
};

enum EForceType
{
	FT_None,                        // 0
	FT_DragAlong                    // 1
};

enum ETravelType
{
	TRAVEL_Absolute,                // 0
	TRAVEL_Partial,                 // 1
	TRAVEL_Relative                 // 2
};

enum EDoubleClickDir
{
	DCLICK_None,                    // 0
	DCLICK_Left,                    // 1
	DCLICK_Right,                   // 2
	DCLICK_Forward,                 // 3
	DCLICK_Back,                    // 4
	DCLICK_Active,                  // 5
	DCLICK_Done                     // 6
};

enum EDisplayFlag
{
	DF_ShowOnlyInPlanning,          // 0
	DF_ShowOnlyIn3DView,            // 1
	DF_ShowInBoth                   // 2
};

enum ENoiseType
{
	NOISE_None,                     // 0
	NOISE_Investigate,              // 1
	NOISE_Threat,                   // 2
	NOISE_Grenade,                  // 3
	NOISE_Dead                      // 4
};

enum EPawnType
{
	PAWN_NotDefined,                // 0
	PAWN_Rainbow,                   // 1
	PAWN_Terrorist,                 // 2
	PAWN_Hostage,                   // 3
	PAWN_All                        // 4
};

enum ESoundType
{
	SNDTYPE_None,                   // 0
	SNDTYPE_Gunshot,                // 1
	SNDTYPE_BulletImpact,           // 2
	SNDTYPE_GrenadeImpact,          // 3
	SNDTYPE_GrenadeLike,            // 4
	SNDTYPE_Explosion,              // 5
	SNDTYPE_PawnMovement,           // 6
	SNDTYPE_Choking,                // 7
	SNDTYPE_Talking,                // 8
	SNDTYPE_Screaming,              // 9
	SNDTYPE_Reload,                 // 10
	SNDTYPE_Equipping,              // 11
	SNDTYPE_Dead,                   // 12
	SNDTYPE_Door                    // 13
};

enum EGameModeInfo
{
	GMI_None,                       // 0
	GMI_SinglePlayer,               // 1
	GMI_Cooperative,                // 2
	GMI_Adversarial,                // 3
	GMI_Squad                       // 4
};

enum EModeFlagOption
{
	MFO_Available,                  // 0
	MFO_NotAvailable                // 1
};

enum EHUDDisplayType
{
	HDT_Normal,                     // 0
	HDT_Hidden,                     // 1
	HDT_FadeIn,                     // 2
	HDT_Blink                       // 3
};

enum EHUDElement
{
	HE_HealthAndName,               // 0
	HE_Posture,                     // 1
	HE_ActionIcon,                  // 2
	HE_WeaponIconAndName,           // 3
	HE_WeaponAttachment,            // 4
	HE_Ammo,                        // 5
	HE_Magazine,                    // 6
	HE_ROF,                         // 7
	HE_TeamHealth,                  // 8
	HE_MovementMode,                // 9
	HE_ROE,                         // 10
	HE_WPAction,                    // 11
	HE_Reticule,                    // 12
	HE_WPIcon,                      // 13
	HE_OtherTeam,                   // 14
	HE_PressGoCodeKey               // 15
};

enum ETerroristNationality
{
	TN_Spanish1,                    // 0
	TN_Spanish2,                    // 1
	TN_German1,                     // 2
	TN_German2,                     // 3
	TN_Portuguese                   // 4
};

enum EHostageNationality
{
	HN_French,                      // 0
	HN_British,                     // 1
	HN_Spanish,                     // 2
	HN_Portuguese,                  // 3
	HN_Norwegian                    // 4
};

enum EVoicesPriority
{
	VP_Low,                         // 0
	VP_Medium,                      // 1
	VP_High                         // 2
};

struct RandomTweenNum
{
	var() float m_fMin;
	var() float m_fMax;
	var float m_fResult;  // result of the last GetRandomTweenNum
};

struct PointRegion
{
	var ZoneInfo Zone;  // Zone.
	var int iLeaf;  // Bsp leaf.
	var byte ZoneNumber;  // Zone number.
};

struct ProjectorRenderInfoPtr
{
// NEW IN 1.60
	var int Ptr;
};

struct ProjectorRelativeRenderInfo
{
	var ProjectorRenderInfoPtr m_RenderInfoPtr;
	var Vector m_RelativeLocation;
	var Rotator m_RelativeRotation;
};

struct DbgVectorInfo
{
	var bool m_bDisplay;
	var Vector m_vLocation;
	var Vector m_vCylinder;
	var Color m_color;
	var string m_szDef;
};

struct KRBVec
{
	var float X;
	var float Y;
	var float Z;
};

struct AnimRep
{
	var name AnimSequence;
	var bool bAnimLoop;
	var byte AnimRate;  // note that with compression, max replicated animrate is 4.0
	var byte AnimFrame;
	var byte TweenRate;  // note that with compression, max replicated tweentime is 4 seconds
};

struct AnimStruct
{
	var() name AnimSequence;
	var() name BoneName;
	var() float AnimRate;  // note that with compression, max replicated animrate is 4.0
	var() byte Alpha;
	var() byte LeadIn;
	var() byte LeadOut;
	var() bool bLoopAnim;
};

struct R6HUDState
{
	var float fTimeStamp;
	var Actor.EHUDDisplayType eDisplay;
	var Color Color;
};

struct stCustomAvailability
{
// NEW IN 1.60
	var() string szGameType;
// NEW IN 1.60
	var() Actor.EModeFlagOption eAvailabilityFlag;
};

struct IndexBufferPtr
{
// NEW IN 1.60
	var int Ptr;
};

struct ResolutionInfo
{
	var int iWidth;
	var int iHeigh;
	var int iRefreshRate;
};

struct StaticMeshBatchRenderInfo
{
	var int m_iBatchIndex;
	var int m_iFirstIndex;
	var int m_iMinVertexIndex;
	var int m_iMaxVertexIndex;
};

struct PlayerMenuInfo
{
	var string szPlayerName;
	var string szKilledBy;  // name of the player who killed me
	var int iKills;  // Number of kills
	var int iEfficiency;  // Efficiency (hits/shot)
	var int iRoundsFired;  // Rounds fired (Bullets shot by the player)
	var int iRoundsHit;  // Bullets shot by the player and that hit somebody
	var int iPingTime;  // ping (The delay between player and server communication)
	var int iHealth;  // health of this player
	var int iTeamSelection;
	var int iRoundsPlayed;  // game rounds played
	var int iRoundsWon;  // game rounds won
	var int iDeathCount;  // number of rounds we died in this match
	var bool bOwnPlayer;  // This player is the player on this computer
	var bool bSpectator;  // treat as spectator?
	var bool bPlayerReady;  // player ready icon
	var bool bJoinedTeamLate;  // joined a team after game started
};

// NEW IN 1.60
var(Movement) const Actor.EPhysics Physics;
var Actor.ENetRole Role;
var Actor.ENetRole RemoteRole;
// NEW IN 1.60
var(Display) const Actor.EDrawType DrawType;
var(Display) byte AmbientGlow;  // Ambient brightness, or 255=pulsing.
var(Display) byte MaxLights;  // Limit to hardware lights active on this primitive.
// NEW IN 1.60
var(Display) Actor.ERenderStyle Style;
var(Sound) byte SoundPitch;  // Sound pitch shift, 64.0=none.
var(Sound) Actor.ESoundOcclusion SoundOcclusion;  // Sound occlusion approach.
var byte m_iTracedBone;
// NEW IN 1.60
var(Lighting) Actor.ELightType LightType;
// NEW IN 1.60
var(Lighting) Actor.ELightEffect LightEffect;
// NEW IN 1.60
var(LightColor) byte LightHue;
// NEW IN 1.60
var(LightColor) byte LightSaturation;
// NEW IN 1.60
var(Lighting) byte LightPeriod;
// NEW IN 1.60
var(Lighting) byte LightPhase;
// NEW IN 1.60
var(Lighting) byte LightCone;
var(Force) Actor.EForceType ForceType;
var(R6Planning) Actor.EDisplayFlag m_eDisplayFlag;
var(R6Planning) byte m_u8SpritePlanningAngle;
var(R6Availability) const Actor.EModeFlagOption m_eStoryMode;
var(R6Availability) const Actor.EModeFlagOption m_eMissionMode;
var(R6Availability) const Actor.EModeFlagOption m_eTerroristHunt;
var(R6Availability) const Actor.EModeFlagOption m_eTerroristHuntCoop;
var(R6Availability) const Actor.EModeFlagOption m_eHostageRescue;
var(R6Availability) const Actor.EModeFlagOption m_eHostageRescueCoop;
var(R6Availability) const Actor.EModeFlagOption m_eHostageRescueAdv;
var(R6Availability) const Actor.EModeFlagOption m_eDefend;
var(R6Availability) const Actor.EModeFlagOption m_eDefendCoop;
var(R6Availability) const Actor.EModeFlagOption m_eRecon;
var(R6Availability) const Actor.EModeFlagOption m_eReconCoop;
var(R6Availability) const Actor.EModeFlagOption m_eDeathmatch;
var(R6Availability) const Actor.EModeFlagOption m_eTeamDeathmatch;
var(R6Availability) const Actor.EModeFlagOption m_eBomb;
var(R6Availability) const Actor.EModeFlagOption m_eEscort;
var(R6Availability) const Actor.EModeFlagOption m_eLoneWolf;
var(R6Availability) const Actor.EModeFlagOption m_eSquadDeathmatch;
var(R6Availability) const Actor.EModeFlagOption m_eSquadTeamDeathmatch;
// MPF
var(R6Availability) const Actor.EModeFlagOption m_eTerroristHuntAdv;  // MissionPack1
var(R6Availability) const Actor.EModeFlagOption m_eScatteredHuntAdv;  // MissionPack1
var(R6Availability) const Actor.EModeFlagOption m_eCaptureTheEnemyAdv;  // MissionPack1
var(R6Availability) const Actor.EModeFlagOption m_eCountDown;  // MissionPack1 2
var(R6Availability) const Actor.EModeFlagOption m_eKamikaze;  // MissionPack1 for MissionPack2
// NEW IN 1.60
var(R6Availability) const Actor.EModeFlagOption m_eFreeBackupAdv;
// NEW IN 1.60
var(R6Availability) const Actor.EModeFlagOption m_eGazAlertAdv;
// NEW IN 1.60
var(R6Availability) const Actor.EModeFlagOption m_eIntruderAdv;
// NEW IN 1.60
var(R6Availability) const Actor.EModeFlagOption m_eLimitSeatsAdv;
// NEW IN 1.60
var(R6Availability) const Actor.EModeFlagOption m_eVirusUploadAdv;
var byte m_u8RenderDataLastUpdate;
var(Display) byte m_HeatIntensity;
var byte m_wTickFrequency;
var byte m_wNbTickSkipped;
// Internal tags.
var native const int CollisionTag;
// NEW IN 1.60
var native const int LightingTag;
// NEW IN 1.60
var native const int ActorTag;
var native const int KStepTag;
var(R6Planning) int m_iPlanningFloor_0;
var(R6Planning) int m_iPlanningFloor_1;
var int m_bInWeatherVolume;
var int m_iLastRenderCycles;
var int m_iLastRenderTick;
var int m_iTotalRenderCycles;
var int m_iNbRenders;
var int m_iTickCycles;
var int m_iTraceCycles;
var int m_iTraceLastTick;
var int m_iTracedCycles;
var int m_iTracedLastTick;
// Flags.
var const bool bStatic;  // Does not move or change over time. Don't let L.D.s change this - screws up net play
var(Advanced) bool bHidden;  // Is hidden during gameplay.
var(Advanced) const bool bNoDelete;  // Cannot be deleted during play.
//#ifdef R6CODE
// Overrides bNoDelete, we need bNoDelete set to true for Interactive objects, but we want to be able to override 
// this if it should not be available based on game mode.
var const bool m_bR6Deletable;
var(R6Availability) bool m_bUseR6Availability;
var bool m_bSkipHitDetection;
//#endif R6CODE
var bool bAnimByOwner;  // Animation dictated by owner.
var const bool bDeleteMe;  // About to be deleted.
var(Lighting) bool bDynamicLight;  // This light is dynamic.
var bool m_bDynamicLightOnlyAffectPawns;  // R6CODE
var bool bTimerLoop;  // Timer loops (else is one-shot).
var(Advanced) bool bCanTeleport;  // This actor can be teleported.
var bool bOwnerNoSee;  // Everything but the owner can see this actor.
var bool bOnlyOwnerSee;  // Only owner can see this actor.
var const bool bAlwaysTick;  // Update even when players-only.
var(Advanced) bool bHighDetail;  // Only show up on high-detail.
var(Advanced) bool bStasis;  // In StandAlone games, turn off if not in a recently rendered zone turned off if  bStasis  and physics = PHYS_None or PHYS_Rotating.
var bool bTrailerSameRotation;  // If PHYS_Trailer and true, have same rotation as owner.
var bool bTrailerPrePivot;  // If PHYS_Trailer and true, offset from owner by PrePivot.
var bool bClientAnim;  // Don't replicate any animations - animation done client-side
var bool bWorldGeometry;  // Collision and Physics treats this actor as world geometry
//R6CODE
//var					bool    bAcceptsProjectors;	// Projectors can project onto this actor
var(Display) bool bAcceptsProjectors;  // Projectors can project onto this actor
var bool m_bHandleRelativeProjectors;  // Projectors can project onto this actor but are relative to it -jfd
var bool bOrientOnSlope;  // when landing, orient base on slope of floor
var bool bDisturbFluidSurface;  // Cause ripples when in contact with FluidSurface.
var const bool bOnlyAffectPawns;  // Optimisation - only test ovelap against pawns. Used for influences etc.
var bool bShowOctreeNodes;
var bool bWasSNFiltered;  // Mainly for debugging - the way this actor was inserted into Octree.
// Networking flags
var const bool bNetTemporary;  // Tear-off simulation in network play.
var const bool bNetOptional;  // Actor should only be replicated if bandwidth available.
var const bool bNetDirty;  // set when any attribute is assigned a value in unrealscript, reset when the actor is replicated
var bool bAlwaysRelevant;  // Always relevant for network.
var bool bReplicateInstigator;  // Replicate instigator to client (used by bNetTemporary projectiles).
var bool bReplicateMovement;  // if true, replicate movement/location related properties
var bool bSkipActorPropertyReplication;  // if true, don't replicate actor class variables for this actor
var bool bUpdateSimulatedPosition;  // if true, update velocity/location after initialization for simulated proxies
var bool bTearOff;  // if true, this actor is no longer replicated to new clients, and
														// is "torn off" (becomes a ROLE_Authority) on clients to which it was being replicated.
//#ifdef R6CODE
var bool m_bUseRagdoll;  // Wheter or not the ragdoll have control over the bone (used only for pawn)
var bool m_bForceBaseReplication;  // Force to replicate Base and AttachmentBone, mostly for weapon
//#endif // #ifdef R6CODE
var bool bOnlyDirtyReplication;  // if true, only replicate actor if bNetDirty is true - useful if no C++ changed attributes (such as physics)
														// bOnlyDirtyReplication only used with bAlwaysRelevant actors
var bool bReplicateAnimations;  // Should replicate SimAnim
//UT2K3
var const bool bNetInitialRotation;  // Should replicate initial rotation
var bool bCompressedPosition;  // used by networking code to flag compressed position replication
//R6CODE
var const bool m_bReticuleInfo;  // if the true, eventGetReticuleInfo will get call
var bool m_bShowInHeatVision;
var bool m_bFirstTimeInZone;
var(Lighting) bool m_bBypassAmbiant;
var bool m_bRenderOutOfWorld;
var bool m_bSpawnedInGame;  // when spawned in game, after the game is started, this is set to true
var bool m_bResetSystemLog;  // used to debug the reset system
var bool m_bDeleteOnReset;  // Actor who must be deleted when resetting the level
var bool m_bInAmbientRange;
// Play Conditions
var(R6Sound) bool m_bPlayIfSameZone;  // Play the ambient sound only if the object is in the same zone
var(R6Sound) bool m_bPlayOnlyOnce;  // Play a sound one time only.
var(R6Sound) bool m_bListOfZoneHearable;  // Play the sound only in the zone of the array m_ListOfZoneInfo
var(R6Sound) bool m_bIfDirectLineOfSight;  // Play the ambient sound only if we have a direct line of sight
var bool m_bUseExitSounds;  // Some objects, like ZoneInfo, contains Entry and Exit Sound.  This lag is to know which of the m_CurrentAmbianceSounds object to use
var bool m_bSoundWasPlayed;  // When the we want play the sound only once. A check is made to know if the sound was already played.
var bool m_bDrawFromBase;  // R6CODE This actor is drawn by its parent
//R6CODE from UT2003
var(Movement) const bool bHardAttach;  // Uses 'hard' attachment code. bBlockActor and bBlockPlayer must also be false.
var bool m_bAllowLOD;
// Display.
var(Display) bool bUnlit;  // Lights don't affect actor.
var(Display) bool bShadowCast;  // Casts static shadows.
var(Display) bool bStaticLighting;  // Uses raytraced lighting.
var(Display) bool bUseLightingFromBase;  // Use Unlit/AmbientGlow from Base
// Advanced.
var bool bHurtEntry;  // keep HurtRadius from being reentrant
var(Advanced) bool bGameRelevant;  // Always relevant for game
var(Advanced) bool bCollideWhenPlacing;  // This actor collides with the world when placing.
var bool bTravel;  // Actor is capable of travelling among servers.
var(Advanced) bool bMovable;  // Actor can be moved.
var bool bDestroyInPainVolume;  // destroy this actor if it enters a pain volume
var(Advanced) bool bShouldBaseAtStartup;  // if true, find base for this actor at level startup, if collides with world and PHYS_None or PHYS_Rotating
var bool bPendingDelete;  // set when actor is about to be deleted (since endstate and other functions called
//R6CODE    For collisions
var(Advanced) bool m_bUseDifferentVisibleCollide;  // to use a different point to collide with this actor (in foreach VisibleCollidingActors)
var bool m_b3DSound;  // Does this actor emits sounds in 3D
// Collision flags.
var(Collision) const bool bCollideActors;  // Collides with other actors.
var(Collision) bool bCollideWorld;  // Collides with the world.
var(Collision) bool bBlockActors;  // Blocks other nonplayer actors.
var(Collision) bool bBlockPlayers;  // Blocks other player actors.
var(Collision) bool bProjTarget;  // Projectiles should potentially target this actor.
//#ifndef R6CODE
var(Collision) bool m_bSeeThrough;  // Object that we don't want to see when checking for visibility (mainly for AI)
var(Collision) bool m_bPawnGoThrough;  // Object from geometry that don't block the player
var(Collision) bool m_bBulletGoThrough;  // Object from geometry that don't block the bullet
// NEW IN 1.60
var(Collision) bool m_bShotThrough;
//#endif // #ifndef R6CODE
// #ifdef R6PERBONECOLLISION
var bool m_bDoPerBoneTrace;  // Use per-bone collision
//#ifndef R6CODE
//var(Collision) bool		  bBlockZeroExtentTraces; // block zero extent actors/traces
//var(Collision) bool		  bBlockNonZeroExtentTraces;	// block non-zero extent actors/traces
//#endif // #ifndef R6CODE
var(Collision) bool bAutoAlignToTerrain;  // Auto-align to terrain in the editor
var(Collision) bool bUseCylinderCollision;  // Force axis aligned cylinder collision (useful for static mesh pickups, etc.)
var(Collision) const bool bBlockKarma;  // Block actors being simulated with Karma.
//R6CODE
var(Debug) bool m_bLogNetTraffic;  // should we log net traffic for this actor?
// Lighting.
var(Lighting) bool bSpecialLit;  // Only affects special-lit surfaces.
var(Lighting) bool bActorShadows;  // Light casts actor shadows.
var(Lighting) bool bCorona;  // Light uses Skin as a corona.
var bool bLightChanged;  // Recalculate this light's lighting now.
var bool m_bLightingVisibility;  // R6CODE
// Options.
var bool bIgnoreOutOfWorld;  // Don't destroy if enters zone zero
var(Movement) bool bBounce;  // Bounces when hits ground fast.
var(Movement) bool bFixedRotationDir;  // Fixed direction of rotation.
var(Movement) bool bRotateToDesired;  // Rotate to DesiredRotation.
var bool bInterpolating;  // Performing interpolating.
var const bool bJustTeleported;  // Used by engine physics - not valid for scripts.
// R6CODE
var bool m_bUseOriginalRotationInPlanning;
// Symmetric network flags, valid during replication only.
var const bool bNetInitial;  // Initial network update.
var const bool bNetOwner;  // Player owns this actor.
var const bool bNetRelevant;  // Actor is currently relevant. Only valid server side, only when replicating variables.
var const bool bDemoRecording;  // True we are currently demo recording
var const bool bClientDemoRecording;  // True we are currently recording a client-side demo
var const bool bClientDemoNetFunc;  // True if we're client-side demo recording and this call originated from the remote.
//Editing flags
var(Advanced) bool bHiddenEd;  // Is hidden during editing.
var(Advanced) bool bHiddenEdGroup;  // Is hidden by the group brower.
var(Advanced) bool bDirectional;  // Actor shows direction arrow during editing.
var const bool bSelected;  // Selected in UnrealEd.
var(Advanced) bool bEdShouldSnap;  // Snap to grid in editor.
var bool bObsolete;  // actor is obsolete - warn level designers to remove it
var bool bPathColliding;  // this actor should collide (if bWorldGeometry && bBlockActors is true) during path building (ignored if bStatic is true, as actor will always collide during path building)
var bool bScriptInitialized;  // set to prevent re-initializing of actors spawned during level startup
var(Advanced) bool bLockLocation;  // Prevent the actor from being moved in the editor.
//#ifdef R6EDITORLOCKACTOR
var(Advanced) bool bEdLocked;  // Locked in editor (no movement or rotation).
var(R6Planning) bool m_bPlanningAlwaysDisplay;
var(R6Planning) bool m_bIsWalkable;
var(R6Planning) bool m_bSpriteShowFlatInPlanning;
var(R6Planning) bool m_bSpriteShownIn3DInPlanning;
var bool m_bSpriteShowOver;
// the following specify if this actor is (not) available for each mode
// don't put this in an enum
var(R6Availability) const bool m_bHideInLowGoreLevel;
var(Lighting) bool m_bIsRealtime;
var(Advanced) bool m_bShouldHidePortal;
var bool m_bHidePortal;
var(Display) bool m_bOutlinedInPlanning;
var bool m_bNeedOutlineUpdate;  // Actor was modified in the editor
var bool m_bBatchesStaticLightingUpdated;
// R6CODE
var(Lighting) bool m_bForceStaticLighting;
// Variable for skipping certain tick for unimportant actor
var bool m_bSkipTick;
var bool m_bTickOnlyWhenVisible;
var float LastRenderTime;  // last time this actor was rendered.
// Execution and timer variables.
var float TimerRate;  // Timer event, 0=no timer.
var const float TimerCounter;  // Counts up until it reaches TimerRate.
var(Advanced) float LifeSpan;  // How old the object lives before dying, 0=forever.
var(Display) float LODBias;
// ifdef R6Sound
var(R6Sound) float m_fAmbientSoundRadius;  // Ambient Sound Radius
var(R6Sound) float m_fSoundRadiusSaturation;  // The distance where the sound will be at the maximum
var(R6Sound) float m_fSoundRadiusActivation;  // The distance where the sound is activated
var(R6Sound) float m_fSoundRadiusLinearFadeDist;  // Distance at which the sound starts to fade linearly
var(R6Sound) float m_fSoundRadiusLinearFadeEnd;  // Distance from which the sound will be inaudible
// Internal.
var const float LatentFloat;  // Internal latent function use.
//var(Display) const float	DrawScale;			// Scaling factor, 1.0=normal size.
//R6
var(Display) float DrawScale;  // Scaling factor, 1.0=normal size.
var(Display) float m_fLightingScaleFactor;
// NEW IN 1.60
var(Display) float CullDistance;
// Ambient sound.
var(Sound) float SoundRadius;  // Radius of ambient sound.
// Regular sounds.
var(Sound) float TransientSoundVolume;  // default sound volume for regular sounds (can be overridden in playsound)
var(Sound) float TransientSoundRadius;  // default sound radius for regular sounds (can be overridden in playsound)
// Collision size.
var(Collision) const float CollisionRadius;  // Radius of collision cyllinder.
var(Collision) const float CollisionHeight;  // Half-height cyllinder.
// R6CIRCUMSTANTIALACTION
var float m_fCircumstantialActionRange;
// NEW IN 1.60
var(LightColor) float LightBrightness;
// NEW IN 1.60
var(Lighting) float LightRadius;
// Physics properties.
var(Movement) float Mass;  // Mass of this actor.
var(Movement) float Buoyancy;  // Water buoyancy.
//#ifdef R6CHARLIGHTVALUE
var float fLightValue;  // Light value of the actor in the range 0..1
// #ifdef R6CODE
// rbrek - 12 nov 2001
//  used for bone rotation, represents the transition of a bone rotation
//  if == 1, either no bone rotation has been done or a bone rotation has been applied but the transition is complete.
//  if == 0, a bone rotation was requested and we are at the very start of the transition to the desired rotation.
var float m_fBoneRotationTransition;
var(Force) float ForceRadius;
var(Force) float ForceScale;
// Network control.
var float NetPriority;  // Higher priorities means update it more frequently.
var float NetUpdateFrequency;  // How many seconds between net updates.
//R6NEWRENDERERFEATURES
var(Lighting) float bCoronaMUL2XFactor;
var(Lighting) float m_fCoronaMinSize;
var(Lighting) float m_fCoronaMaxSize;
var float m_fAttachFactor;  // Factor used by R6Tags.  if the scale changes (1.1 for rainbow character, 1 for Terrorists)
var float m_fCummulativeTick;
// Owner.
var const Actor Owner;  // Owner actor.
// Scriptable.
var const LevelInfo Level;  // Level this actor is on.
var Pawn Instigator;  // Pawn responsible for damage caused by this actor.
var(R6Sound) Sound AmbientSound;  // Ambient sound effect.
var(R6Sound) Sound AmbientSoundStop;  // Stop the ambient sound effect.
var Actor m_CurrentAmbianceObject;  // Object responsible if the current ambience that should be hear by this actor.  Use when we switch from player to player
var Actor m_CurrentVolumeSound;  // Object responsible if the current ambience that should be hear by this actor.  Use when we switch from player to player
//#ifndef R6CHANGEWEAPONSYSTEM
//var Inventory             Inventory;     // Inventory chain.
//#endif
var const Actor Base;  // Actor we're standing on.
var const Actor Deleted;  // Next actor in just-deleted chain.
// The actor's position and rotation.
var const PhysicsVolume PhysicsVolume;  // physics volume this actor is currently in
var(Display) Material Texture;  // Sprite texture.if DrawType=DT_Sprite
var(Display) const Mesh Mesh;  // Mesh if DrawType=DT_Mesh.
var(Display) const StaticMesh StaticMesh;  // StaticMesh if DrawType=DT_StaticMesh
var StaticMeshInstance StaticMeshInstance;  // Contains per-instance static mesh data, like static lighting data.
var const export Model Brush;  // Brush if DrawType=DT_Brush.
var(Display) ConvexVolume AntiPortal;  // Convex volume used for DT_AntiPortal
//R6COLLISIONBOX
var R6ColBox m_collisionBox;  // Second CollisionBox of the pawn
var R6ColBox m_collisionBox2;  // Second CollisionBox of the pawn
var Actor PendingTouch;  // Actor touched during move which wants to add an effect after the movement completes
var(Karma) export editinline KarmaParamsCollision KParams;  // Parameters for Karma Collision/Dynamics.
var Actor m_AttachedTo;
//R6SHADOW
var Projector Shadow;
var StaticMesh m_OutlineStaticMesh;
var(Events) name Tag;  // Actor's tag name.
var(Object) name InitialState;
var(Object) name Group;
var(Events) name Event;  // The event this actor causes.
// Attachment related variables
var(Movement) name AttachTag;
var const name AttachmentBone;  // name of bone to which actor is attached (if attached to center of base, =='')
var(R6Sound) name m_szSoundBoneName;  // Bone use by the sound.
var Class<LocalMessage> MessageClass;
var(R6Sound) array<ZoneInfo> m_ListOfZoneInfo;  // Play the ambient sound only if the object is NOT in one of those zone
var const array<Actor> Touching;  // List of touching actors.
var const array<Actor> Attached;  // array of actors attached to this actor.
var(Display) array<Material> Skins;  // Multiple skin support - not replicated.
//R6Code
var(Display) array<Material> NightVisionSkins;
var array<DbgVectorInfo> m_dbgVectorInfo;
// NEW IN 1.60
var(R6Availability) array<stCustomAvailability> m_aCustomAvailability;
var array<int> m_OutlineIndices;  // 2 16-bits indices each
var array<StaticMeshBatchRenderInfo> m_Batches;
var const PointRegion Region;  // Region this actor is in.
var(Movement) const Vector Location;  // Actor's location; use Move to set.
var(Movement) const Rotator Rotation;  // Rotation.
var(Movement) Vector Velocity;  // Velocity.
var Vector Acceleration;  // Acceleration.
var const Vector RelativeLocation;  // location relative to base/bone (valid if base exists)
var const Rotator RelativeRotation;  // rotation relative to base/bone (valid if base exists)
											// This actor cannot then move relative to base (setlocation etc.).
											// Dont set while currently based on something!
											// 
var const Matrix HardRelMatrix;  // Transform of actor in base's ref frame. Doesn't change after SetBase.
var(Display) const Vector DrawScale3D;  // Scaling vector, (1.0,1.0,1.0)=normal size.
var Vector PrePivot;  // Offset from box center for drawing.
var(Display) Color m_fLightingAdditiveAmbiant;
var(Advanced) Vector m_vVisibleCenter;  // use this vector instead of location when m_bUseDifferentVisibleCollide is true
var Rotator sm_Rotation;
var(Movement) Rotator RotationRate;  // Change in rotation per second.
var(Movement) Rotator DesiredRotation;  // Physics will smoothly rotate actor to this rotation if bRotateToDesired.
var const Vector ColLocation;  // Actor's old location one move ago. Only for debugging
var(R6Planning) Color m_PlanningColor;
var const transient int NetTag;
var const transient int JoinedTag;
var const transient bool bTicked;  // Actor has been updated.
var transient bool bEdSnap;  // Should snap to grid in UnrealEd.
var const transient bool bTempEditor;  // Internal UnrealEd.
var transient bool bPathTemp;  // Internal/path building
var transient MeshInstance MeshInstance;  // Mesh instance.
var const transient Level XLevel;  // Level object.
var transient array<int> Leaves;  // BSP leaves this actor is in.
var const transient array<int> OctreeNodes;  // Array of nodes of the octree Actor is currently in. Internal use only.
var const transient array<ProjectorRelativeRenderInfo> Projectors;  // Projected textures on this actor
var const transient Box OctreeBox;  // Actor bounding box cached when added to Octree. Internal use only.
var const transient Vector OctreeBoxCenter;
var const transient Vector OctreeBoxRadii;
var transient AnimRep SimAnim;  // only replicated if bReplicateAnimations is true
var const transient IndexBufferPtr m_OutlineIndexBuffer;

replication
{
	// Pos:0x6E6
	unreliable if(bDemoRecording)
		DemoPlaySound;

	// Pos:0x000
	reliable if(__NFUN_130__(__NFUN_130__(__NFUN_132__(__NFUN_130__(__NFUN_129__(m_bUseRagdoll), __NFUN_129__(bSkipActorPropertyReplication)), bNetInitial), bReplicateMovement), __NFUN_132__(__NFUN_132__(__NFUN_130__(__NFUN_154__(int(RemoteRole), int(ROLE_AutonomousProxy)), bNetInitial), __NFUN_130__(__NFUN_130__(__NFUN_154__(int(RemoteRole), int(ROLE_SimulatedProxy)), __NFUN_132__(bNetInitial, bUpdateSimulatedPosition)), __NFUN_132__(__NFUN_114__(Base, none), Base.bWorldGeometry))), __NFUN_130__(__NFUN_154__(int(RemoteRole), int(ROLE_DumbProxy)), __NFUN_132__(__NFUN_114__(Base, none), Base.bWorldGeometry)))))
		Location;

	// Pos:0x0C4
	reliable if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_132__(__NFUN_130__(__NFUN_129__(m_bUseRagdoll), __NFUN_129__(bSkipActorPropertyReplication)), bNetInitial), bReplicateMovement), __NFUN_132__(__NFUN_154__(int(DrawType), int(2)), __NFUN_154__(int(DrawType), int(8)))), __NFUN_132__(__NFUN_132__(__NFUN_130__(__NFUN_154__(int(RemoteRole), int(ROLE_AutonomousProxy)), bNetInitial), __NFUN_130__(__NFUN_130__(__NFUN_154__(int(RemoteRole), int(ROLE_SimulatedProxy)), __NFUN_132__(bNetInitial, bUpdateSimulatedPosition)), __NFUN_132__(__NFUN_114__(Base, none), Base.bWorldGeometry))), __NFUN_130__(__NFUN_154__(int(RemoteRole), int(ROLE_DumbProxy)), __NFUN_132__(__NFUN_114__(Base, none), Base.bWorldGeometry)))))
		Rotation;

	// Pos:0x1AC
	reliable if(__NFUN_132__(__NFUN_130__(__NFUN_130__(__NFUN_132__(__NFUN_130__(__NFUN_129__(m_bUseRagdoll), __NFUN_129__(bSkipActorPropertyReplication)), bNetInitial), bReplicateMovement), __NFUN_152__(int(RemoteRole), int(ROLE_SimulatedProxy))), __NFUN_130__(__NFUN_130__(m_bForceBaseReplication, __NFUN_129__(bNetOwner)), __NFUN_154__(int(Role), int(ROLE_Authority)))))
		Base;

	// Pos:0x213
	reliable if(__NFUN_132__(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_132__(__NFUN_130__(__NFUN_129__(m_bUseRagdoll), __NFUN_129__(bSkipActorPropertyReplication)), bNetInitial), bReplicateMovement), __NFUN_152__(int(RemoteRole), int(ROLE_SimulatedProxy))), __NFUN_119__(Base, none)), __NFUN_129__(Base.bWorldGeometry)), __NFUN_130__(__NFUN_130__(m_bForceBaseReplication, __NFUN_129__(bNetOwner)), __NFUN_154__(int(Role), int(ROLE_Authority)))))
		AttachmentBone, RelativeLocation, 
		RelativeRotation;

	// Pos:0x29D
	reliable if(__NFUN_130__(__NFUN_130__(__NFUN_132__(__NFUN_130__(__NFUN_129__(m_bUseRagdoll), __NFUN_129__(bSkipActorPropertyReplication)), bNetInitial), bReplicateMovement), __NFUN_132__(__NFUN_130__(__NFUN_154__(int(RemoteRole), int(ROLE_SimulatedProxy)), __NFUN_132__(bNetInitial, bUpdateSimulatedPosition)), __NFUN_130__(__NFUN_154__(int(RemoteRole), int(ROLE_DumbProxy)), __NFUN_154__(int(Physics), int(2))))))
		Velocity;

	// Pos:0x314
	reliable if(__NFUN_130__(__NFUN_154__(int(Role), int(ROLE_Authority)), __NFUN_129__(bNetOwner)))
		Physics;

	// Pos:0x32E
	reliable if(__NFUN_130__(__NFUN_154__(int(Role), int(ROLE_Authority)), bNetInitial))
		bActorShadows;

	// Pos:0x346
	reliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		m_bUseRagdoll, m_fAttachFactor;

	// Pos:0x353
	reliable if(__NFUN_150__(int(Role), int(ROLE_Authority)))
		ServerForceKillResult, ServerForceStunResult, 
		ServerSendBankToLoad;

	// Pos:0x360
	reliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		ClientAddSoundBank;

	// Pos:0x36D
	reliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		m_collisionBox, m_collisionBox2;

	// Pos:0x37A
	reliable if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_132__(__NFUN_130__(__NFUN_129__(m_bUseRagdoll), __NFUN_129__(bSkipActorPropertyReplication)), bNetInitial), bReplicateMovement), __NFUN_152__(int(RemoteRole), int(ROLE_SimulatedProxy))), __NFUN_154__(int(Physics), int(5))))
		DesiredRotation, RotationRate, 
		bFixedRotationDir, bRotateToDesired;

	// Pos:0x3C9
	reliable if(__NFUN_130__(__NFUN_130__(__NFUN_132__(__NFUN_130__(__NFUN_129__(m_bUseRagdoll), __NFUN_129__(bSkipActorPropertyReplication)), bNetInitial), __NFUN_154__(int(Role), int(ROLE_Authority))), __NFUN_132__(__NFUN_129__(bNetOwner), __NFUN_129__(bClientAnim))))
		AmbientSound;

	// Pos:0x415
	reliable if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_132__(__NFUN_130__(__NFUN_129__(m_bUseRagdoll), __NFUN_129__(bSkipActorPropertyReplication)), bNetInitial), __NFUN_154__(int(Role), int(ROLE_Authority))), __NFUN_132__(__NFUN_129__(bNetOwner), __NFUN_129__(bClientAnim))), __NFUN_119__(AmbientSound, none)))
		SoundPitch, SoundRadius, 
		m_szSoundBoneName;

	// Pos:0x46E
	reliable if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_132__(__NFUN_130__(__NFUN_129__(m_bUseRagdoll), __NFUN_129__(bSkipActorPropertyReplication)), bNetInitial), __NFUN_154__(int(Role), int(ROLE_Authority))), __NFUN_154__(int(DrawType), int(2))), bReplicateAnimations))
		SimAnim;

	// Pos:0x4BD
	reliable if(__NFUN_130__(__NFUN_132__(__NFUN_130__(__NFUN_129__(m_bUseRagdoll), __NFUN_129__(bSkipActorPropertyReplication)), bNetInitial), __NFUN_154__(int(Role), int(ROLE_Authority))))
		bHidden;

	// Pos:0x4EF
	reliable if(__NFUN_130__(__NFUN_130__(__NFUN_132__(__NFUN_130__(__NFUN_129__(m_bUseRagdoll), __NFUN_129__(bSkipActorPropertyReplication)), bNetInitial), __NFUN_154__(int(Role), int(ROLE_Authority))), bNetDirty))
		DrawScale, DrawScale3D, 
		DrawType, Owner, 
		Style, Texture, 
		bCollideActors, bCollideWorld, 
		bOnlyOwnerSee, m_fLightingAdditiveAmbiant, 
		m_fLightingScaleFactor;

	// Pos:0x52C
	reliable if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_132__(__NFUN_130__(__NFUN_129__(m_bUseRagdoll), __NFUN_129__(bSkipActorPropertyReplication)), bNetInitial), __NFUN_154__(int(Role), int(ROLE_Authority))), bNetDirty), __NFUN_132__(bCollideActors, bCollideWorld)))
		CollisionHeight, CollisionRadius, 
		bBlockActors, bBlockPlayers, 
		bProjTarget;

	// Pos:0x57F
	reliable if(__NFUN_130__(__NFUN_132__(__NFUN_130__(__NFUN_129__(m_bUseRagdoll), __NFUN_129__(bSkipActorPropertyReplication)), bNetInitial), __NFUN_154__(int(Role), int(ROLE_Authority))))
		LightType, RemoteRole, 
		Role, bNetOwner, 
		bTearOff;

	// Pos:0x5B1
	reliable if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_132__(__NFUN_130__(__NFUN_129__(m_bUseRagdoll), __NFUN_129__(bSkipActorPropertyReplication)), bNetInitial), __NFUN_154__(int(Role), int(ROLE_Authority))), bNetDirty), bReplicateInstigator))
		Instigator;

	// Pos:0x5F9
	reliable if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_132__(__NFUN_130__(__NFUN_129__(m_bUseRagdoll), __NFUN_129__(bSkipActorPropertyReplication)), bNetInitial), __NFUN_154__(int(Role), int(ROLE_Authority))), bNetDirty), __NFUN_154__(int(DrawType), int(2))))
		AmbientGlow, Mesh, 
		PrePivot, bUnlit;

	// Pos:0x648
	reliable if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_132__(__NFUN_130__(__NFUN_129__(m_bUseRagdoll), __NFUN_129__(bSkipActorPropertyReplication)), bNetInitial), __NFUN_154__(int(Role), int(ROLE_Authority))), bNetDirty), __NFUN_154__(int(DrawType), int(8))))
		StaticMesh;

	// Pos:0x697
	reliable if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_132__(__NFUN_130__(__NFUN_129__(m_bUseRagdoll), __NFUN_129__(bSkipActorPropertyReplication)), bNetInitial), __NFUN_154__(int(Role), int(ROLE_Authority))), bNetDirty), __NFUN_155__(int(LightType), int(0))))
		LightBrightness, LightEffect, 
		LightHue, LightPeriod, 
		LightPhase, LightRadius, 
		LightSaturation, bSpecialLit;
}

// Export UActor::execConsoleCommand(FFrame&, void* const)
// Execute a console command in the context of the current level and game engine.
 native function string ConsoleCommand(string Command);

// Export UActor::execGetTagInformations(FFrame&, void* const)
//#ifdef R6TAGS
//=========================================================================
// Tags.
 native(2008) final function GetTagInformations(string TagName, out Vector outVector, out Rotator OutRotator, optional float vOwnerScale);

// Export UActor::execDbgVectorReset(FFrame&, void* const)
// #ifdef R6DBGVECTORINFO
 native(1505) final function DbgVectorReset(int vectorIndex);

// Export UActor::execDbgVectorAdd(FFrame&, void* const)
 native(1506) final function DbgVectorAdd(Vector vPoint, Vector vCylinder, int vectorIndex, optional string szDef);

// Export UActor::execDbgAddLine(FFrame&, void* const)
 native(1801) final function DbgAddLine(Vector vStart, Vector vEnd, Color cColor);

// Export UActor::execIsAvailableInGameType(FFrame&, void* const)
 native(1513) final function bool IsAvailableInGameType(string szGameType);

// Export UActor::execGetFPlayerMenuInfo(FFrame&, void* const)
//#ifdef R6CODE
 native(1230) final function GetFPlayerMenuInfo(int Index, out PlayerMenuInfo _iPlayerMenuInfo);

// Export UActor::execSetFPlayerMenuInfo(FFrame&, void* const)
 native(1231) final function SetFPlayerMenuInfo(int Index, PlayerMenuInfo _iPlayerMenuInfo);

// Export UActor::execGetPlayerSetupInfo(FFrame&, void* const)
//#ifdef R6CODE
 native(1232) final function GetPlayerSetupInfo(out string m_CharacterName, out string m_ArmorName, out string m_WeaponNameOne, out string m_WeaponGadgetNameOne, out string m_BulletTypeOne, out string m_WeaponNameTwo, out string m_WeaponGadgetNameTwo, out string m_BulletTypeTwo, out string m_GadgetNameOne, out string m_GadgetNameTwo);

// Export UActor::execSetPlayerSetupInfo(FFrame&, void* const)
 native(1233) final function SetPlayerSetupInfo(string m_CharacterName, string m_ArmorName, string m_WeaponNameOne, string m_WeaponGadgetNameOne, string m_BulletTypeOne, string m_WeaponNameTwo, string m_WeaponGadgetNameTwo, string m_BulletTypeTwo, string m_GadgetNameOne, string m_GadgetNameTwo);

// Export UActor::execSortFPlayerMenuInfo(FFrame&, void* const)
 native(1279) final function SortFPlayerMenuInfo(int LastIndex, string szGameType);

// Export UActor::execGetGameManager(FFrame&, void* const)
//#ifdef R6CODE
 native(1551) static final function R6AbstractGameManager GetGameManager();

// Export UActor::execGetModMgr(FFrame&, void* const)
 native(1524) static final function R6ModMgr GetModMgr();

// Export UActor::execGetGameOptions(FFrame&, void* const)
 native(1009) static final function R6GameOptions GetGameOptions();

// Export UActor::execGetTime(FFrame&, void* const)
 native(1012) static final function float GetTime();

// Export UActor::execGetNbAvailableResolutions(FFrame&, void* const)
 native(2614) static final function int GetNbAvailableResolutions();

// Export UActor::execGetAvailableResolution(FFrame&, void* const)
 native(2615) static final function GetAvailableResolution(int Index, out int Width, out int Height, out int RefreshRate);

// Export UActor::execNativeStartedByGSClient(FFrame&, void* const)
//#ifdef R6CODE
 native(1200) static final function bool NativeStartedByGSClient();

// Export UActor::execNativeNonUbiMatchMakingHost(FFrame&, void* const)
 native(1316) static final function bool NativeNonUbiMatchMakingHost();

// Export UActor::execNativeNonUbiMatchMaking(FFrame&, void* const)
 native(1303) static final function bool NativeNonUbiMatchMaking();

// Export UActor::execNativeNonUbiMatchMakingAddress(FFrame&, void* const)
 native(1304) static final function NativeNonUbiMatchMakingAddress(out string RemoteIpAddress);

// Export UActor::execNativeNonUbiMatchMakingPassword(FFrame&, void* const)
 native(1305) static final function NativeNonUbiMatchMakingPassword(out string NonUbiPassword);

// Export UActor::execGetServerOptions(FFrame&, void* const)
 native(1273) static final function R6ServerInfo GetServerOptions();

// Export UActor::execGetServerOptionsRefreshed(FFrame&, void* const)
// NEW IN 1.60
 native(1274) static final function R6ServerInfo GetServerOptionsRefreshed();

// Export UActor::execSaveServerOptions(FFrame&, void* const)
 native(1283) static final function R6ServerInfo SaveServerOptions(optional string FileName);

// Export UActor::execGetMissionDescription(FFrame&, void* const)
 native(1302) static final function R6MissionDescription GetMissionDescription();

// Export UActor::execSetServerBeacon(FFrame&, void* const)
 native(1311) static final function SetServerBeacon(InternetInfo ServerBeacon);

// Export UActor::execGetServerBeacon(FFrame&, void* const)
 native(1312) static final function InternetInfo GetServerBeacon();

// Export UActor::execIsPBClientEnabled(FFrame&, void* const)
//#ifdefR6PUNBUSTER
 native(1400) static final function bool IsPBClientEnabled();

// Export UActor::execIsPBServerEnabled(FFrame&, void* const)
 native(1402) static final function bool IsPBServerEnabled();

// Export UActor::execSetPBStatus(FFrame&, void* const)
 native(1401) static final function SetPBStatus(bool _bDisable, bool _bServerStatus);

// Export UActor::execLoadLoadingScreen(FFrame&, void* const)
//#endif R6CODE
 native(2613) static final function LoadLoadingScreen(string MapName, Texture pTex0, Texture pTex1);

// Export UActor::execReplaceTexture(FFrame&, void* const)
 native(2616) static final function bool ReplaceTexture(string FileName, Texture pTex);

// Export UActor::execConvertGameTypeIntToString(FFrame&, void* const)
 native(1256) final function string ConvertGameTypeIntToString(int iGameType);

// Export UActor::execConvertGameTypeToInt(FFrame&, void* const)
 native(2015) final function int ConvertGameTypeToInt(string szGameType);

// Export UActor::execGetGameVersion(FFrame&, void* const)
 native(1419) static final function string GetGameVersion(optional bool _bShortVersion, optional bool _bModVersion);

// Export UActor::execIsVideoHardwareAtLeast64M(FFrame&, void* const)
 native(2617) static final function bool IsVideoHardwareAtLeast64M();

// Export UActor::execGetCanvas(FFrame&, void* const)
 native(2618) static final function Canvas GetCanvas();

// Export UActor::execEnableLoadingScreen(FFrame&, void* const)
 native(2619) static final function EnableLoadingScreen(bool _enable);

// Export UActor::execAddMessageToConsole(FFrame&, void* const)
 native(2620) static final function AddMessageToConsole(string Msg, Color MsgColor, optional byte bMessageUseBigFont);

// Export UActor::execUpdateGraphicOptions(FFrame&, void* const)
 native(2621) static final function UpdateGraphicOptions();

// Export UActor::execGarbageCollect(FFrame&, void* const)
 native(2622) static final function GarbageCollect();

// Export UActor::execGetMapNameExt(FFrame&, void* const)
 native(1519) static final function string GetMapNameExt();

// Export UActor::execConvertIntTimeToString(FFrame&, void* const)
 native(1520) static final function string ConvertIntTimeToString(int iTimeToConvert, optional bool bAlignMinOnTwoDigits);

// Export UActor::execGlobalIDToString(FFrame&, void* const)
 native(1522) static final function string GlobalIDToString(byte aBytes[16]);

// Export UActor::execGlobalIDToBytes(FFrame&, void* const)
 native(1523) static final function GlobalIDToBytes(string szIn, out byte aBytes[255]);

// Export UActor::execLoadRandomBackgroundImage(FFrame&, void* const)
 native(2607) static final function Object LoadRandomBackgroundImage(optional string _szBackGroundSubFolder);

// Export UActor::execKMP2IOKarmaAllNativeFct(FFrame&, void* const)
// NEW IN 1.60
 native(4042) static final function KMP2IOKarmaAllNativeFct(int WhatIdo, Actor _owner, optional float _var_int, optional float _var_float, optional Vector _var_vect);

//------------------------------------------------------------------
// GetReticuleInfo: info displayed under the reticule. 
//  optimized to work with the flag m_bReticuleInfo.
//	out: szName is the name identifying this Actor
//       return true if it's a friend or a neutral actor, False if enemy
//------------------------------------------------------------------
simulated event bool GetReticuleInfo(Pawn ownerReticule, out string szName)
{
	return false;
	return;
}

// #ifdef R6HEARTBEAT
simulated event bool ProcessHeart(float DeltaSeconds, out float fMul1, out float fMul2)
{
	return;
}

// Export UActor::execError(FFrame&, void* const)
// Handle an error and kill this one actor.
 native(233) final function Error(coerce string S);

// Export UActor::execSleep(FFrame&, void* const)
// Latent functions.
 native(256) final latent function Sleep(float Seconds);

// Export UActor::execSetCollision(FFrame&, void* const)
// Collision.
 native(262) final function SetCollision(optional bool NewColActors, optional bool NewBlockActors, optional bool NewBlockPlayers);

// Export UActor::execSetCollisionSize(FFrame&, void* const)
 native(283) final function bool SetCollisionSize(float NewRadius, float NewHeight);

// Export UActor::execSetDrawScale(FFrame&, void* const)
 native final function SetDrawScale(float NewScale);

// Export UActor::execSetDrawScale3D(FFrame&, void* const)
 native final function SetDrawScale3D(Vector NewScale3D);

// Export UActor::execSetStaticMesh(FFrame&, void* const)
 native final function SetStaticMesh(StaticMesh NewStaticMesh);

// Export UActor::execSetDrawType(FFrame&, void* const)
 native final function SetDrawType(Actor.EDrawType NewDrawType);

// Export UActor::execMove(FFrame&, void* const)
// Movement.
 native(266) final function bool Move(Vector Delta);

// Export UActor::execSetLocation(FFrame&, void* const)
//R6CODE native(267) final function bool SetLocation( vector NewLocation );
 native(267) final function bool SetLocation(Vector NewLocation, optional bool bNoCheck);

// Export UActor::execSetRotation(FFrame&, void* const)
 native(299) final function bool SetRotation(Rotator NewRotation);

// Export UActor::execSetRelativeRotation(FFrame&, void* const)
// SetRelativeRotation() sets the rotation relative to the actor's base
 native final function bool SetRelativeRotation(Rotator NewRotation);

// Export UActor::execSetRelativeLocation(FFrame&, void* const)
 native final function bool SetRelativeLocation(Vector NewLocation);

// Export UActor::execMoveSmooth(FFrame&, void* const)
 native(3969) final function bool MoveSmooth(Vector Delta);

// Export UActor::execAutonomousPhysics(FFrame&, void* const)
 native(3971) final function AutonomousPhysics(float DeltaSeconds);

// Export UActor::execSetBase(FFrame&, void* const)
// Relations.
 native(298) final function SetBase(Actor NewBase, optional Vector NewFloor);

// Export UActor::execSetOwner(FFrame&, void* const)
 native(272) final function SetOwner(Actor NewOwner);

// Export UActor::execPlayAnim(FFrame&, void* const)
// Animation functions.
//#ifdef R6CODE -  
// 14 jan 2002 rbrek - for playing animations backwards
// 16 jan 2002 rbrek - added bForceAnimRate to force PlayAnim to use exactly the specified animation rate
 native(259) final function PlayAnim(name Sequence, optional float Rate, optional float TweenTime, optional int Channel, optional bool bBackward, optional bool bForceAnimRate);

// Export UActor::execLoopAnim(FFrame&, void* const)
 native(260) final function LoopAnim(name Sequence, optional float Rate, optional float TweenTime, optional int Channel, optional bool bBackward, optional bool bForceAnimRate);

// Export UActor::execTweenAnim(FFrame&, void* const)
 native(294) final function TweenAnim(name Sequence, float Time, optional int Channel);

// Export UActor::execIsAnimating(FFrame&, void* const)
 native(282) final function bool IsAnimating(optional int Channel);

// Export UActor::execFinishAnim(FFrame&, void* const)
 native(261) final latent function FinishAnim(optional int Channel);

// Export UActor::execHasAnim(FFrame&, void* const)
 native(263) final function bool HasAnim(name Sequence);

// Export UActor::execStopAnimating(FFrame&, void* const)
 native final function StopAnimating(optional bool ClearAllButBase);

// Export UActor::execFreezeAnimAt(FFrame&, void* const)
 native final function FreezeAnimAt(float Time, optional int Channel);

// Export UActor::execIsTweening(FFrame&, void* const)
 native final function bool IsTweening(int Channel);

// Export UActor::execClearChannel(FFrame&, void* const)
//#ifdef R6CODE 
 native(1805) final function ClearChannel(int iChannel);

// Export UActor::execGetAnimGroup(FFrame&, void* const)
 native(1500) final function name GetAnimGroup(name Sequence);

// Animation notifications.
event AnimEnd(int Channel)
{
	return;
}

// Export UActor::execEnableChannelNotify(FFrame&, void* const)
 native final function EnableChannelNotify(int Channel, int Switch);

// Export UActor::execGetNotifyChannel(FFrame&, void* const)
 native final function int GetNotifyChannel();

// Export UActor::execLinkSkelAnim(FFrame&, void* const)
// Skeletal animation.
 native final simulated function LinkSkelAnim(MeshAnimation Anim, optional Mesh NewMesh);

// Export UActor::execLinkMesh(FFrame&, void* const)
 native final simulated function LinkMesh(Mesh NewMesh, optional bool bKeepAnim);

// Export UActor::execUnLinkSkelAnim(FFrame&, void* const)
//#ifdef R6CODE - rbrek 4 april 2002
 native(2210) final function UnLinkSkelAnim();

// Export UActor::execAnimBlendParams(FFrame&, void* const)
 native final simulated function AnimBlendParams(int Stage, optional float BlendAlpha, optional float InTime, optional float OutTime, optional name BoneName);

// Export UActor::execAnimBlendToAlpha(FFrame&, void* const)
 native final function AnimBlendToAlpha(int Stage, float TargetAlpha, float TimeInterval);

// Export UActor::execGetAnimBlendAlpha(FFrame&, void* const)
//#ifdef R6CODE - rbrek 05 jan 2002
 native(2208) final function float GetAnimBlendAlpha(int Stage);

// Export UActor::execWasSkeletonUpdated(FFrame&, void* const)
//#ifdef R6CODE - pgaron 15 jan 2002
 native(1501) final function bool WasSkeletonUpdated();

// Export UActor::execGetBoneCoords(FFrame&, void* const)
//#endif
 native final simulated function Coords GetBoneCoords(name BoneName, optional bool bDontCallGetFrame);

// Export UActor::execGetBoneRotation(FFrame&, void* const)
 native final function Rotator GetBoneRotation(name BoneName, optional int Space);

// Export UActor::execGetRootLocation(FFrame&, void* const)
 native final function Vector GetRootLocation();

// Export UActor::execGetRootRotation(FFrame&, void* const)
 native final function Rotator GetRootRotation();

// Export UActor::execGetRootLocationDelta(FFrame&, void* const)
 native final function Vector GetRootLocationDelta();

// Export UActor::execGetRootRotationDelta(FFrame&, void* const)
 native final function Rotator GetRootRotationDelta();

// Export UActor::execAttachToBone(FFrame&, void* const)
 native final function bool AttachToBone(Actor Attachment, name BoneName);

// Export UActor::execDetachFromBone(FFrame&, void* const)
 native final function bool DetachFromBone(Actor Attachment);

// Export UActor::execLockRootMotion(FFrame&, void* const)
// rbrek - 22 nov 2001
// added an argument to LockRootMotion() to allow using root motion with or without locking rotation of the root bone...
//#ifdef R6CODE
 native final function LockRootMotion(int Lock, optional bool bUseRootRotation);

// Export UActor::execSetBoneScale(FFrame&, void* const)
 native final function SetBoneScale(int Slot, optional float BoneScale, optional name BoneName);

// Export UActor::execSetBoneDirection(FFrame&, void* const)
 native final function SetBoneDirection(name BoneName, Rotator BoneTurn, optional Vector BoneTrans, optional float Alpha);

// Export UActor::execSetBoneLocation(FFrame&, void* const)
 native final function SetBoneLocation(name BoneName, optional Vector BoneTrans, optional float Alpha);

// Export UActor::execGetAnimParams(FFrame&, void* const)
 native final function GetAnimParams(int Channel, out name OutSeqName, out float OutAnimFrame, out float OutAnimRate);

// Export UActor::execAnimIsInGroup(FFrame&, void* const)
 native final function bool AnimIsInGroup(int Channel, name GroupName);

// Export UActor::execSetBoneRotation(FFrame&, void* const)
// #ifdif R6CODE - rbrek - 10 oct 2001  
 native final function SetBoneRotation(name BoneName, optional Rotator BoneTurn, optional int Space, optional float Alpha, optional float InTime);

// Export UActor::execGetRenderBoundingSphere(FFrame&, void* const)
 native final function Plane GetRenderBoundingSphere();

// Export UActor::execFinishInterpolation(FFrame&, void* const)
// Physics control.
 native(301) final latent function FinishInterpolation();

// Export UActor::execSetPhysics(FFrame&, void* const)
 native(3970) final function SetPhysics(Actor.EPhysics newPhysics);

// Export UActor::execOnlyAffectPawns(FFrame&, void* const)
 native final function OnlyAffectPawns(bool B);

// Export UActor::execKSetMass(FFrame&, void* const)
// ifdef WITH_KARMA
 native final function KSetMass(float Mass);

// Export UActor::execKGetMass(FFrame&, void* const)
 native final function float KGetMass();

// Export UActor::execKSetInertiaTensor(FFrame&, void* const)
// Set inertia tensor assuming a mass of 1. Scaled by mass internally to calculate actual inertia tensor.
 native final function KSetInertiaTensor(Vector it1, Vector it2);

// Export UActor::execKGetInertiaTensor(FFrame&, void* const)
 native final function KGetInertiaTensor(out Vector it1, out Vector it2);

// Export UActor::execKSetDampingProps(FFrame&, void* const)
 native final function KSetDampingProps(float lindamp, float angdamp);

// Export UActor::execKGetDampingProps(FFrame&, void* const)
 native final function KGetDampingProps(out float lindamp, out float angdamp);

// Export UActor::execKSetFriction(FFrame&, void* const)
 native final function KSetFriction(float friction);

// Export UActor::execKGetFriction(FFrame&, void* const)
 native final function float KGetFriction();

// Export UActor::execKSetRestitution(FFrame&, void* const)
 native final function KSetRestitution(float rest);

// Export UActor::execKGetRestitution(FFrame&, void* const)
 native final function float KGetRestitution();

// Export UActor::execKSetCOMOffset(FFrame&, void* const)
 native final function KSetCOMOffset(Vector offset);

// Export UActor::execKGetCOMOffset(FFrame&, void* const)
 native final function KGetCOMOffset(out Vector offset);

// Export UActor::execKGetCOMPosition(FFrame&, void* const)
 native final function KGetCOMPosition(out Vector pos);

// Export UActor::execKSetImpactThreshold(FFrame&, void* const)
 native final function KSetImpactThreshold(float thresh);

// Export UActor::execKGetImpactThreshold(FFrame&, void* const)
 native final function float KGetImpactThreshold();

// Export UActor::execKWake(FFrame&, void* const)
 native final function KWake();

// Export UActor::execKIsAwake(FFrame&, void* const)
 native final function bool KIsAwake();

// Export UActor::execKAddImpulse(FFrame&, void* const)
 native final function KAddImpulse(Vector Impulse, Vector Position, optional name BoneName);

// Export UActor::execKSetStayUpright(FFrame&, void* const)
 native final function KSetStayUpright(bool stayUpright, bool allowRotate);

// Export UActor::execKSetBlockKarma(FFrame&, void* const)
 native final function KSetBlockKarma(bool newBlock);

// Export UActor::execKSetActorGravScale(FFrame&, void* const)
 native final function KSetActorGravScale(float ActorGravScale);

// Export UActor::execKGetActorGravScale(FFrame&, void* const)
 native final function float KGetActorGravScale();

// Export UActor::execKDisableCollision(FFrame&, void* const)
// Disable/Enable Karma contact generation between this actor, and another actor.
// Collision is on by default.
 native final function KDisableCollision(Actor Other);

// Export UActor::execKEnableCollision(FFrame&, void* const)
 native final function KEnableCollision(Actor Other);

// Export UActor::execKSetSkelVel(FFrame&, void* const)
// Ragdoll-specific functions
 native final function KSetSkelVel(Vector Velocity, optional Vector AngVelocity, optional bool AddToCurrent);

// Export UActor::execKGetSkelMass(FFrame&, void* const)
 native final function float KGetSkelMass();

// Export UActor::execKFreezeRagdoll(FFrame&, void* const)
 native final function KFreezeRagdoll();

// Export UActor::execKAddBoneLifter(FFrame&, void* const)
// You MUST turn collision off (KSetBlockKarma) before using bone lifters!
 native final function KAddBoneLifter(name BoneName, InterpCurve LiftVel, float LateralFriction, InterpCurve Softness);

// Export UActor::execKRemoveLifterFromBone(FFrame&, void* const)
 native final function KRemoveLifterFromBone(name BoneName);

// Export UActor::execKRemoveAllBoneLifters(FFrame&, void* const)
 native final function KRemoveAllBoneLifters();

// Export UActor::execKMakeRagdollAvailable(FFrame&, void* const)
// Used for only allowing a fixed maximum number of ragdolls in action.
 native final function KMakeRagdollAvailable();

// Export UActor::execKIsRagdollAvailable(FFrame&, void* const)
 native final function bool KIsRagdollAvailable();

// event called when Karmic actor hits with impact velocity over KImpactThreshold
event KImpact(Actor Other, Vector pos, Vector impactVel, Vector impactNorm)
{
	return;
}

// event called when karma actor's velocity drops below KVelDropBelowThreshold;
event KVelDropBelow()
{
	return;
}

// event called when a ragdoll convulses (see KarmaParamsSkel)
event KSkelConvulse()
{
	return;
}

// event called just before sim to allow user to 
// NOTE: you should ONLY put numbers into Force and Torque during this event!!!!
event KApplyForce(out Vector Force, out Vector Torque)
{
	return;
}

// Export UActor::execPlayMusic(FFrame&, void* const)
//R6SOUND
 native final function bool PlayMusic(Sound Music, optional bool bForcePlayMusic);

// Export UActor::execStopMusic(FFrame&, void* const)
 native final function bool StopMusic(Sound StopMusic);

// Export UActor::execStopAllMusic(FFrame&, void* const)
 native final function StopAllMusic();

//
// Major notifications.
//
//event Destroyed();
//R6SHADOW
event Destroyed()
{
	// End:0x17
	if(__NFUN_119__(Shadow, none))
	{
		Shadow.__NFUN_279__();
	}
	return;
}

event GainedChild(Actor Other)
{
	return;
}

event LostChild(Actor Other)
{
	return;
}

event Tick(float DeltaTime)
{
	return;
}

//
// Triggers.
//
event Trigger(Actor Other, Pawn EventInstigator)
{
	return;
}

event UnTrigger(Actor Other, Pawn EventInstigator)
{
	return;
}

event BeginEvent()
{
	return;
}

event EndEvent()
{
	return;
}

//
// Physics & world interaction.
//
event Timer()
{
	return;
}

event HitWall(Vector HitNormal, Actor HitWall)
{
	return;
}

event Falling()
{
	return;
}

event Landed(Vector HitNormal)
{
	return;
}

event ZoneChange(ZoneInfo NewZone)
{
	return;
}

event PhysicsVolumeChange(PhysicsVolume NewVolume)
{
	return;
}

event Touch(Actor Other)
{
	return;
}

event PostTouch(Actor Other)
{
	return;
}

event UnTouch(Actor Other)
{
	return;
}

event Bump(Actor Other)
{
	return;
}

event BaseChange()
{
	return;
}

event Attach(Actor Other)
{
	return;
}

event Detach(Actor Other)
{
	return;
}

event Actor SpecialHandling(Pawn Other)
{
	return;
}

event bool EncroachingOn(Actor Other)
{
	return;
}

event EncroachedBy(Actor Other)
{
	return;
}

event FinishedInterpolation()
{
	bInterpolating = false;
	return;
}

event EndedRotation()
{
	return;
}

event UsedBy(Pawn User)
{
	return;
}

//#ifdef R6CODE
function SetAttachVar(Actor AttachActor, string StaticMeshTag, name PawnTag)
{
	return;
}

function MatineeAttach()
{
	return;
}

function MatineeDetach()
{
	return;
}

event FellOutOfWorld()
{
	__NFUN_3970__(0);
	__NFUN_279__();
	return;
}

//
// Damage and kills.
//
event KilledBy(Pawn EventInstigator)
{
	return;
}

// Export UActor::execTrace(FFrame&, void* const)
// NEW IN 1.60
 native(277) final function Actor Trace(out Vector HitLocation, out Vector HitNormal, Vector TraceEnd, optional Vector TraceStart, optional bool bTraceActors, optional Vector Extent, optional out Material Material);

// Export UActor::execR6Trace(FFrame&, void* const)
// NEW IN 1.60
 native(1806) final function Actor R6Trace(out Vector HitLocation, out Vector HitNormal, Vector TraceEnd, optional Vector TraceStart, optional int iTraceFlags, optional Vector Extent, optional out Material Material);

// Export UActor::execFindSpot(FFrame&, void* const)
 native(1800) final function bool FindSpot(out Vector vLocation, optional Vector vExtent);

// Export UActor::execFastTrace(FFrame&, void* const)
// NEW IN 1.60
 native(548) final function bool FastTrace(Vector TraceEnd, optional Vector TraceStart);

// Export UActor::execSpawn(FFrame&, void* const)
// NEW IN 1.60
 native(278) final function Actor Spawn(Class<Actor> SpawnClass, optional Actor SpawnOwner, optional name SpawnTag, optional Vector SpawnLocation, optional Rotator SpawnRotation, optional bool bNoCollisionFail);

// Export UActor::execDestroy(FFrame&, void* const)
//
// Destroy this actor. Returns true if destroyed, false if indestructable.
// Destruction is latent. It occurs at the end of the tick.
//
 native(279) final function bool Destroy();

// Networking - called on client when actor is torn off (bTearOff==true)
event TornOff()
{
	return;
}

// Export UActor::execSetTimer(FFrame&, void* const)
// Causes Timer() events every NewTimerRate seconds.
 native(280) final function SetTimer(float NewTimerRate, bool bLoop);

// Export UActor::execPlaySound(FFrame&, void* const)
// R6CODE
 native(264) final function PlaySound(Sound Sound, optional Actor.ESoundSlot Slot);

// Export UActor::execStopSound(FFrame&, void* const)
 native(2725) final function StopSound(Sound Sound);

// Export UActor::execIsPlayingSound(FFrame&, void* const)
 native(2703) final function bool IsPlayingSound(Actor aActor, Sound Sound);

// Export UActor::execResetVolume_AllTypeSound(FFrame&, void* const)
 native(2704) final function bool ResetVolume_AllTypeSound();

// Export UActor::execResetVolume_TypeSound(FFrame&, void* const)
 native(2720) final function bool ResetVolume_TypeSound(Actor.ESoundSlot eSlot);

// Export UActor::execChangeVolumeType(FFrame&, void* const)
 native(2705) final function ChangeVolumeType(Actor.ESoundSlot eSlot, float fVolume);

// Export UActor::execStopAllSounds(FFrame&, void* const)
 native(2712) final function StopAllSounds();

// Export UActor::execAddSoundBank(FFrame&, void* const)
 native(2716) final function AddSoundBank(string szBank, Actor.ELoadBankSound eLBS);

// Export UActor::execAddAndFindBankInSound(FFrame&, void* const)
 native(2717) final function AddAndFindBankInSound(Sound Sound, Actor.ELoadBankSound eLBS);

// Export UActor::execStopAllSoundsActor(FFrame&, void* const)
 native(2719) final function StopAllSoundsActor(Actor aActor);

// Export UActor::execFadeSound(FFrame&, void* const)
 native(2721) final function FadeSound(float fTime, int iFade, Actor.ESoundSlot eSlot);

// Export UActor::execSaveCurrentFadeValue(FFrame&, void* const)
 native(2722) final function SaveCurrentFadeValue();

// Export UActor::execReturnSavedFadeValue(FFrame&, void* const)
 native(2723) final function ReturnSavedFadeValue(float fTime);

// Export UActor::execPlayOwnedSound(FFrame&, void* const)
// NEW IN 1.60
 native final simulated function PlayOwnedSound(Sound Sound, optional Actor.ESoundSlot Slot, optional float Volume, optional bool bNoOverride, optional float Radius, optional float Pitch, optional bool Attenuate);

// Export UActor::execDemoPlaySound(FFrame&, void* const)
// NEW IN 1.60
 native simulated event DemoPlaySound(Sound Sound, optional Actor.ESoundSlot Slot, optional float Volume, optional bool bNoOverride, optional float Radius, optional float Pitch, optional bool Attenuate);

// Export UActor::execGetSoundDuration(FFrame&, void* const)
 native final function float GetSoundDuration(Sound Sound);

// Export UActor::execMakeNoise(FFrame&, void* const)
// #ifdef R6NOISE
 native(512) final function MakeNoise(float Loudness, optional Actor.ENoiseType eNoise, optional Actor.EPawnType ePawn, optional Actor.ESoundType ESoundType);

event R6MakeNoise(Actor.ESoundType eType)
{
	// End:0x12
	if(__NFUN_154__(int(eType), int(0)))
	{
		return;
	}
	// End:0x47
	if(__NFUN_119__(Level.Game, none))
	{
		Level.Game.R6GameInfoMakeNoise(eType, self);		
	}
	else
	{
		__NFUN_231__("Warning: Call to R6MakeNoise when game is not the server");
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("         From ", string(Name)), " in the state "), string(__NFUN_284__())));
	}
	return;
}

function R6MakeNoise2(float fLoudness, Actor.ENoiseType eNoise, Actor.EPawnType ePawn)
{
	__NFUN_512__(fLoudness, eNoise, ePawn);
	return;
}

// Export UActor::execPlayerCanSeeMe(FFrame&, void* const)
 native(532) final function bool PlayerCanSeeMe();

// Teleportation.
event bool PreTeleport(Teleporter InTeleporter)
{
	return;
}

event PostTeleport(Teleporter OutTeleporter)
{
	return;
}

// Level state.
event BeginPlay()
{
	return;
}

// Export UActor::execGetMapName(FFrame&, void* const)
// Find files.
 native(539) final function string GetMapName(string NameEnding, string MapName, int Dir);

// Export UActor::execGetNextSkin(FFrame&, void* const)
 native(545) final function GetNextSkin(string Prefix, string CurrentSkin, int Dir, out string SkinName, out string SkinDesc);

// Export UActor::execGetURLMap(FFrame&, void* const)
 native(547) final function string GetURLMap();

// Export UActor::execGetNextInt(FFrame&, void* const)
 native final function string GetNextInt(string ClassName, int Num);

// Export UActor::execGetNextIntDesc(FFrame&, void* const)
 native final function GetNextIntDesc(string ClassName, int Num, out string Entry, out string Description);

// Export UActor::execGetCacheEntry(FFrame&, void* const)
 native final function bool GetCacheEntry(int Num, out string Guid, out string FileName);

// Export UActor::execMoveCacheEntry(FFrame&, void* const)
 native final function bool MoveCacheEntry(string Guid, optional string NewFilename);

// Export UActor::execAllActors(FFrame&, void* const)
 native(304) final iterator function AllActors(Class<Actor> BaseClass, out Actor Actor, optional name MatchTag);

// Export UActor::execDynamicActors(FFrame&, void* const)
 native(313) final iterator function DynamicActors(Class<Actor> BaseClass, out Actor Actor, optional name MatchTag);

// Export UActor::execChildActors(FFrame&, void* const)
 native(305) final iterator function ChildActors(Class<Actor> BaseClass, out Actor Actor);

// Export UActor::execBasedActors(FFrame&, void* const)
 native(306) final iterator function BasedActors(Class<Actor> BaseClass, out Actor Actor);

// Export UActor::execTouchingActors(FFrame&, void* const)
 native(307) final iterator function TouchingActors(Class<Actor> BaseClass, out Actor Actor);

// Export UActor::execTraceActors(FFrame&, void* const)
 native(309) final iterator function TraceActors(Class<Actor> BaseClass, out Actor Actor, out Vector HitLoc, out Vector HitNorm, Vector End, optional Vector Start, optional Vector Extent);

// Export UActor::execRadiusActors(FFrame&, void* const)
 native(310) final iterator function RadiusActors(Class<Actor> BaseClass, out Actor Actor, float Radius, optional Vector Loc);

// Export UActor::execVisibleActors(FFrame&, void* const)
 native(311) final iterator function VisibleActors(Class<Actor> BaseClass, out Actor Actor, optional float Radius, optional Vector Loc);

// Export UActor::execVisibleCollidingActors(FFrame&, void* const)
 native(312) final iterator function VisibleCollidingActors(Class<Actor> BaseClass, out Actor Actor, float Radius, optional Vector Loc, optional bool bIgnoreHidden);

// Export UActor::execCollidingActors(FFrame&, void* const)
 native(321) final iterator function CollidingActors(Class<Actor> BaseClass, out Actor Actor, float Radius, optional Vector Loc);

// Export UActor::execSubtract_ColorColor(FFrame&, void* const)
 native(549) static final operator(20) Color -(Color A, Color B);

// Export UActor::execMultiply_FloatColor(FFrame&, void* const)
 native(550) static final operator(16) Color *(float A, Color B);

// Export UActor::execAdd_ColorColor(FFrame&, void* const)
 native(551) static final operator(20) Color +(Color A, Color B);

// Export UActor::execMultiply_ColorFloat(FFrame&, void* const)
 native(552) static final operator(16) Color *(Color A, float B);

// Export UActor::execSetPlanningMode(FFrame&, void* const)
//R6PLANNING
 native(2011) final function SetPlanningMode(bool bDraw);

// Export UActor::execInPlanningMode(FFrame&, void* const)
 native(2014) final function bool InPlanningMode();

// Export UActor::execSetFloorToDraw(FFrame&, void* const)
 native(2012) final function SetFloorToDraw(int iFloor);

// Export UActor::execRenderLevelFromMe(FFrame&, void* const)
 native(2610) final function RenderLevelFromMe(int iXMin, int iYMin, int iXSize, int iYSize);

// Export UActor::execDrawDashedLine(FFrame&, void* const)
//R6CODE
 native(2608) final function DrawDashedLine(Vector vStart, Vector vEnd, Color Col, float fDashSize);

// Export UActor::execDrawText3D(FFrame&, void* const)
 native(2609) final function DrawText3D(Vector vPos, coerce string pString);

function RenderOverlays(Canvas Canvas)
{
	return;
}

//
// Called immediately before gameplay begins.
//
event PreBeginPlay()
{
	// End:0x39
	if(__NFUN_130__(__NFUN_119__(Level.Game, none), Level.Game.m_bGameStarted))
	{
		m_bSpawnedInGame = true;
	}
	return;
}

//
// Broadcast a localized message to all players.
// Most message deal with 0 to 2 related PRIs.
// The LocalMessage class defines how the PRI's and optional actor are used.
//
event BroadcastLocalizedMessage(Class<LocalMessage> MessageClass, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	Level.Game.BroadcastLocalized(self, MessageClass, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	return;
}

// Called immediately after gameplay begins.
//
event PostBeginPlay()
{
	return;
}

// Called after PostBeginPlay.
//
simulated event SetInitialState()
{
	bScriptInitialized = true;
	// End:0x21
	if(__NFUN_255__(InitialState, 'None'))
	{
		__NFUN_113__(InitialState);		
	}
	else
	{
		__NFUN_113__('Auto');
	}
	return;
}

//#ifdef R6CODE
simulated function FirstPassReset()
{
	return;
}

// called after PostBeginPlay.  On a net client, PostNetBeginPlay() is spawned after replicated variables have been initialized to
// their replicated values
event PostNetBeginPlay()
{
	return;
}

// R6CODE +
simulated event SaveAndResetData()
{
	SaveOriginalData();
	ResetOriginalData();
	return;
}

// Called when carried onto a new level, before AcceptInventory.
//
event TravelPreAccept()
{
	return;
}

// Called when carried into a new level, after AcceptInventory.
//
event TravelPostAccept()
{
	return;
}

// Called by PlayerController when this actor becomes its ViewTarget.
//
function BecomeViewTarget()
{
	return;
}

// Returns the string representation of the name of an object without the package
// prefixes.
//
function string GetItemName(string FullName)
{
	local int pos;

	pos = __NFUN_126__(FullName, ".");
	J0x10:

	// End:0x50 [Loop If]
	if(__NFUN_155__(pos, -1))
	{
		FullName = __NFUN_234__(FullName, __NFUN_147__(__NFUN_147__(__NFUN_125__(FullName), pos), 1));
		pos = __NFUN_126__(FullName, ".");
		// [Loop Continue]
		goto J0x10;
	}
	return FullName;
	return;
}

// Returns the human readable string representation of an object.
//
function string GetHumanReadableName()
{
	return GetItemName(string(Class));
	return;
}

final function ReplaceText(out string Text, string Replace, string With)
{
	local int i;
	local string Input;

	Input = Text;
	Text = "";
	i = __NFUN_126__(Input, Replace);
	J0x25:

	// End:0x84 [Loop If]
	if(__NFUN_155__(i, -1))
	{
		Text = __NFUN_112__(__NFUN_112__(Text, __NFUN_128__(Input, i)), With);
		Input = __NFUN_127__(Input, __NFUN_146__(i, __NFUN_125__(Replace)));
		i = __NFUN_126__(Input, Replace);
		// [Loop Continue]
		goto J0x25;
	}
	Text = __NFUN_112__(Text, Input);
	return;
}

// Set the display properties of an actor.  By setting them through this function, it allows
// the actor to modify other components (such as a Pawn's weapon) or to adjust the result
// based on other factors (such as a Pawn's other inventory wanting to affect the result)
function SetDisplayProperties(Actor.ERenderStyle NewStyle, Material NewTexture, bool bLighting)
{
	Style = NewStyle;
	Texture = NewTexture;
	bUnlit = bLighting;
	return;
}

function SetDefaultDisplayProperties()
{
	Style = default.Style;
	Texture = default.Texture;
	bUnlit = default.bUnlit;
	return;
}

// Get localized message string associated with this actor
static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	return "";
	return;
}

function MatchStarting()
{
	return;
}

function string GetDebugName()
{
	return GetItemName(string(self));
	return;
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string t;
	local float XL;
	local int i;
	local Actor A;
	local name Anim;
	local float frame, Rate;

	Canvas.Style = 1;
	Canvas.__NFUN_464__("TEST", XL, YL);
	YPos = __NFUN_174__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, YPos);
	Canvas.__NFUN_2626__(byte(255), 0, 0);
	t = GetDebugName();
	// End:0xA9
	if(bDeleteMe)
	{
		t = __NFUN_112__(t, " DELETED (bDeleteMe == true)");
	}
	Canvas.__NFUN_465__(t, false);
	__NFUN_184__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, YPos);
	Canvas.__NFUN_2626__(byte(255), byte(255), byte(255));
	// End:0x2EC
	if(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)))
	{
		t = "ROLE ";
		switch(Role)
		{
			// End:0x13D
			case ROLE_None:
				t = __NFUN_112__(t, "None");
				// End:0x1CB
				break;
			// End:0x15D
			case 1:
				t = __NFUN_112__(t, "DumbProxy");
				// End:0x1CB
				break;
			// End:0x182
			case 2:
				t = __NFUN_112__(t, "SimulatedProxy");
				// End:0x1CB
				break;
			// End:0x1A8
			case 3:
				t = __NFUN_112__(t, "AutonomousProxy");
				// End:0x1CB
				break;
			// End:0x1C8
			case 4:
				t = __NFUN_112__(t, "Authority");
				// End:0x1CB
				break;
			// End:0xFFFF
			default:
				break;
		}
		t = __NFUN_112__(t, " REMOTE ROLE ");
		switch(RemoteRole)
		{
			// End:0x209
			case ROLE_None:
				t = __NFUN_112__(t, "None");
				// End:0x297
				break;
			// End:0x229
			case 1:
				t = __NFUN_112__(t, "DumbProxy");
				// End:0x297
				break;
			// End:0x24E
			case 2:
				t = __NFUN_112__(t, "SimulatedProxy");
				// End:0x297
				break;
			// End:0x274
			case 3:
				t = __NFUN_112__(t, "AutonomousProxy");
				// End:0x297
				break;
			// End:0x294
			case 4:
				t = __NFUN_112__(t, "Authority");
				// End:0x297
				break;
			// End:0xFFFF
			default:
				break;
		}
		// End:0x2B8
		if(bTearOff)
		{
			t = __NFUN_112__(t, " Tear Off");
		}
		Canvas.__NFUN_465__(t, false);
		__NFUN_184__(YPos, YL);
		Canvas.__NFUN_2623__(4.0000000, YPos);
	}
	t = "Physics ";
	switch(Physics)
	{
		// End:0x31E
		case 0:
			t = __NFUN_112__(t, "None");
			// End:0x477
			break;
		// End:0x33C
		case 1:
			t = __NFUN_112__(t, "Walking");
			// End:0x477
			break;
		// End:0x35A
		case 2:
			t = __NFUN_112__(t, "Falling");
			// End:0x477
			break;
		// End:0x379
		case 3:
			t = __NFUN_112__(t, "Swimming");
			// End:0x477
			break;
		// End:0x396
		case 4:
			t = __NFUN_112__(t, "Flying");
			// End:0x477
			break;
		// End:0x3B5
		case 5:
			t = __NFUN_112__(t, "Rotating");
			// End:0x477
			break;
		// End:0x3D6
		case 6:
			t = __NFUN_112__(t, "Projectile");
			// End:0x477
			break;
		// End:0x3FA
		case 7:
			t = __NFUN_112__(t, "Interpolating");
			// End:0x477
			break;
		// End:0x41C
		case 8:
			t = __NFUN_112__(t, "MovingBrush");
			// End:0x477
			break;
		// End:0x439
		case 9:
			t = __NFUN_112__(t, "Spider");
			// End:0x477
			break;
		// End:0x457
		case 10:
			t = __NFUN_112__(t, "Trailer");
			// End:0x477
			break;
		// End:0x474
		case 11:
			t = __NFUN_112__(t, "Ladder");
			// End:0x477
			break;
		// End:0xFFFF
		default:
			break;
	}
	t = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(t, " in physicsvolume "), GetItemName(string(PhysicsVolume))), " on base "), GetItemName(string(Base)));
	// End:0x4E9
	if(bBounce)
	{
		t = __NFUN_112__(t, " - will bounce");
	}
	Canvas.__NFUN_465__(t, false);
	__NFUN_184__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, YPos);
	Canvas.__NFUN_465__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Location: ", string(Location)), " Rotation "), string(Rotation)), false);
	__NFUN_184__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, YPos);
	Canvas.__NFUN_465__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Velocity: ", string(Velocity)), " Speed "), string(__NFUN_225__(Velocity))), false);
	__NFUN_184__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, YPos);
	Canvas.__NFUN_465__(__NFUN_112__("Acceleration: ", string(Acceleration)), false);
	__NFUN_184__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, YPos);
	Canvas.DrawColor.B = 0;
	Canvas.__NFUN_465__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Collision Radius ", string(CollisionRadius)), " Height "), string(CollisionHeight)));
	__NFUN_184__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, YPos);
	Canvas.__NFUN_465__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Collides with Actors ", string(bCollideActors)), ", world "), string(bCollideWorld)), ", proj. target "), string(bProjTarget)));
	__NFUN_184__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, YPos);
	Canvas.__NFUN_465__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Blocks Actors ", string(bBlockActors)), ", players "), string(bBlockPlayers)));
	__NFUN_184__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, YPos);
	t = "Touching ";
	// End:0x7B2
	foreach __NFUN_307__(Class'Engine.Actor', A)
	{
		t = __NFUN_112__(__NFUN_112__(t, GetItemName(string(A))), " ");		
	}	
	// End:0x7E0
	if(__NFUN_122__(t, "Touching "))
	{
		t = "Touching nothing";
	}
	Canvas.__NFUN_465__(t, false);
	__NFUN_184__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, YPos);
	Canvas.DrawColor.R = 0;
	t = "Rendered: ";
	switch(Style)
	{
		// End:0x856
		case 0:
			t = t;
			// End:0x8F1
			break;
		// End:0x873
		case 1:
			t = __NFUN_112__(t, "Normal");
			// End:0x8F1
			break;
		// End:0x890
		case 2:
			t = __NFUN_112__(t, "Masked");
			// End:0x8F1
			break;
		// End:0x8B2
		case 3:
			t = __NFUN_112__(t, "Translucent");
			// End:0x8F1
			break;
		// End:0x8D2
		case 4:
			t = __NFUN_112__(t, "Modulated");
			// End:0x8F1
			break;
		// End:0x8EE
		case 5:
			t = __NFUN_112__(t, "Alpha");
			// End:0x8F1
			break;
		// End:0xFFFF
		default:
			break;
	}
	switch(DrawType)
	{
		// End:0x914
		case 0:
			t = __NFUN_112__(t, " None");
			// End:0xA27
			break;
		// End:0x933
		case 1:
			t = __NFUN_112__(t, " Sprite ");
			// End:0xA27
			break;
		// End:0x950
		case 2:
			t = __NFUN_112__(t, " Mesh ");
			// End:0xA27
			break;
		// End:0x96E
		case 3:
			t = __NFUN_112__(t, " Brush ");
			// End:0xA27
			break;
		// End:0x991
		case 4:
			t = __NFUN_112__(t, " RopeSprite ");
			// End:0xA27
			break;
		// End:0x9B8
		case 5:
			t = __NFUN_112__(t, " VerticalSprite ");
			// End:0xA27
			break;
		// End:0x9DA
		case 6:
			t = __NFUN_112__(t, " Terraform ");
			// End:0xA27
			break;
		// End:0xA01
		case 7:
			t = __NFUN_112__(t, " SpriteAnimOnce ");
			// End:0xA27
			break;
		// End:0xA24
		case 8:
			t = __NFUN_112__(t, " StaticMesh ");
			// End:0xA27
			break;
		// End:0xFFFF
		default:
			break;
	}
	// End:0xB7E
	if(__NFUN_154__(int(DrawType), int(2)))
	{
		t = __NFUN_112__(t, string(Mesh));
		// End:0xAC6
		if(__NFUN_151__(Skins.Length, 0))
		{
			t = __NFUN_112__(t, " skins: ");
			i = 0;
			J0xA75:

			// End:0xAC6 [Loop If]
			if(__NFUN_150__(i, Skins.Length))
			{
				// End:0xA9C
				if(__NFUN_114__(Skins[i], none))
				{
					// [Explicit Break]
					goto J0xAC6;
					// [Explicit Continue]
					goto J0xABC;
				}
				t = __NFUN_112__(__NFUN_112__(t, string(Skins[i])), ", ");
				J0xABC:

				__NFUN_165__(i);
				// [Loop Continue]
				goto J0xA75;
			}
		}
		J0xAC6:

		Canvas.__NFUN_465__(t, false);
		__NFUN_184__(YPos, YL);
		Canvas.__NFUN_2623__(4.0000000, YPos);
		GetAnimParams(0, Anim, frame, Rate);
		t = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("AnimSequence ", string(Anim)), " Frame "), string(frame)), " Rate "), string(Rate));
		// End:0xB7B
		if(bAnimByOwner)
		{
			t = __NFUN_112__(t, " Anim by Owner");
		}		
	}
	else
	{
		// End:0xBB7
		if(__NFUN_132__(__NFUN_154__(int(DrawType), int(1)), __NFUN_154__(int(DrawType), int(7))))
		{
			t = __NFUN_112__(t, string(Texture));			
		}
		else
		{
			// End:0xBDB
			if(__NFUN_154__(int(DrawType), int(3)))
			{
				t = __NFUN_112__(t, string(Brush));
			}
		}
	}
	Canvas.__NFUN_465__(t, false);
	__NFUN_184__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, YPos);
	Canvas.DrawColor.B = byte(255);
	Canvas.__NFUN_465__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Tag: ", string(Tag)), " Event: "), string(Event)), " STATE: "), string(__NFUN_284__())), false);
	__NFUN_184__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, YPos);
	Canvas.__NFUN_465__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Instigator ", GetItemName(string(Instigator))), " Owner "), GetItemName(string(Owner))));
	__NFUN_184__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, YPos);
	Canvas.__NFUN_465__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Timer: ", string(TimerCounter)), " LifeSpan "), string(LifeSpan)), " AmbientSound "), string(AmbientSound)));
	__NFUN_184__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, YPos);
	return;
}

// NearSpot() returns true is spot is within collision cylinder
final simulated function bool NearSpot(Vector Spot)
{
	local Vector Dir;

	Dir = __NFUN_216__(Location, Spot);
	// End:0x2A
	if(__NFUN_177__(__NFUN_186__(Dir.Z), CollisionHeight))
	{
		return false;
	}
	Dir.Z = 0.0000000;
	return __NFUN_178__(__NFUN_225__(Dir), CollisionRadius);
	return;
}

final simulated function bool TouchingActor(Actor A)
{
	local Vector Dir;

	Dir = __NFUN_216__(Location, A.Location);
	// End:0x43
	if(__NFUN_177__(__NFUN_186__(Dir.Z), __NFUN_174__(CollisionHeight, A.CollisionHeight)))
	{
		return false;
	}
	Dir.Z = 0.0000000;
	return __NFUN_178__(__NFUN_225__(Dir), __NFUN_174__(CollisionRadius, A.CollisionRadius));
	return;
}

simulated function StartInterpolation()
{
	__NFUN_113__('None');
	__NFUN_262__(true, false, false);
	bCollideWorld = false;
	bInterpolating = true;
	__NFUN_3970__(0);
	return;
}

function Reset()
{
	return;
}

event TriggerEvent(name EventName, Actor Other, Pawn EventInstigator)
{
	local Actor A;

	// End:0x22
	if(__NFUN_132__(__NFUN_254__(EventName, 'None'), __NFUN_254__(EventName, 'None')))
	{
		return;
	}
	// End:0x51
	foreach __NFUN_313__(Class'Engine.Actor', A, EventName)
	{
		A.Trigger(Other, EventInstigator);		
	}	
	return;
}

function UntriggerEvent(name EventName, Actor Other, Pawn EventInstigator)
{
	local Actor A;

	// End:0x22
	if(__NFUN_132__(__NFUN_254__(EventName, 'None'), __NFUN_254__(EventName, 'None')))
	{
		return;
	}
	// End:0x51
	foreach __NFUN_313__(Class'Engine.Actor', A, EventName)
	{
		A.UnTrigger(Other, EventInstigator);		
	}	
	return;
}

function bool IsInVolume(Volume aVolume)
{
	local Volume V;

	// End:0x23
	foreach __NFUN_307__(Class'Engine.Volume', V)
	{
		// End:0x22
		if(__NFUN_114__(V, aVolume))
		{			
			return true;
		}		
	}	
	return false;
	return;
}

function PlayTeleportEffect(bool bOut, bool bSound)
{
	return;
}

function bool CanSplash()
{
	return false;
	return;
}

function Vector GetCollisionExtent()
{
	local Vector Extent;

	Extent = __NFUN_213__(CollisionRadius, vect(1.0000000, 1.0000000, 0.0000000));
	Extent.Z = CollisionHeight;
	return Extent;
	return;
}

//===========================================================================//
// R6QueryCircumstantialAction()                                             //
//  Get circumstantial action informations from an actor.                    //
//===========================================================================//
event R6QueryCircumstantialAction(float fDistance, out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController)
{
	Query.iHasAction = 0;
	return;
}

//===========================================================================//
// R6GetCircumstantialActionString()                                         //
//  Translate an action ID to a string.                                      //
//===========================================================================//
simulated function string R6GetCircumstantialActionString(int iAction)
{
	return "";
	return;
}

//===========================================================================//
// R6CircumstantialActionProgressStart()                                     //
//  Notify the actor that the player is starting to interact with it.        //
//===========================================================================//
function R6CircumstantialActionProgressStart(R6AbstractCircumstantialActionQuery Query)
{
	return;
}

//===========================================================================//
// R6GetCircumstantialActionProgress()                                       //
//  Once the progress bar is started, use this function to update it.        //
//  Progress should be updated using Level.TimeSeconds and the skill of the  //
//  player acting on it. Should return a number between 0 and 100            //
//===========================================================================//
function int R6GetCircumstantialActionProgress(R6AbstractCircumstantialActionQuery Query, Pawn actingPawn)
{
	return 0;
	return;
}

//===========================================================================//
// R6CircumstantialActionCancel()                                            //
//  If the action it stop when the player is doing the action				 //
//===========================================================================//
function R6CircumstantialActionCancel()
{
	return;
}

//===========================================================================//
// R6ActionCanBeExecuted()                                                   //
//  Can the action be executed at this time ?                                //
//  If not, the action will be grayed out in the rose des vents.             //
//===========================================================================//
simulated function bool R6ActionCanBeExecuted(int iAction, PlayerController PlayerController)
{
	return true;
	return;
}

//===========================================================================//
// R6FillSubAction()                                                         //
//  Small function used to fill a circumstantial action team submenu using   //
//  an action ID.                                                            //
//===========================================================================//
function R6FillSubAction(out R6AbstractCircumstantialActionQuery Query, int iSubMenu, int iAction)
{
	Query.iTeamSubActionsIDList[__NFUN_146__(__NFUN_144__(iSubMenu, 4), 0)] = byte(iAction);
	Query.iTeamSubActionsIDList[__NFUN_146__(__NFUN_144__(iSubMenu, 4), 1)] = byte(iAction);
	Query.iTeamSubActionsIDList[__NFUN_146__(__NFUN_144__(iSubMenu, 4), 2)] = byte(iAction);
	Query.iTeamSubActionsIDList[__NFUN_146__(__NFUN_144__(iSubMenu, 4), 3)] = byte(iAction);
	return;
}

//R6CODE
function int R6TakeDamage(int iKillValue, int iStunValue, Pawn instigatedBy, Vector vHitLocation, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGoup)
{
	// End:0x15
	if(__NFUN_242__(m_bBulletGoThrough, true))
	{
		return iKillValue;		
	}
	else
	{
		return 0;
	}
	return;
}

// NEW IN 1.60
function ServerForceKillResult(int iKillResult)
{
	return;
}

// NEW IN 1.60
function ServerForceStunResult(int iStunResult)
{
	return;
}

//=============================================================================
// get random number betweem a min and a max
//=============================================================================
static function float GetRandomTweenNum(out RandomTweenNum R)
{
	R.m_fResult = __NFUN_171__(__NFUN_195__(), __NFUN_175__(R.m_fMax, R.m_fMin));
	__NFUN_184__(R.m_fResult, R.m_fMin);
	return R.m_fResult;
	return;
}

function Actor R6GetRootActor()
{
	// End:0x1B
	if(__NFUN_119__(m_AttachedTo, none))
	{
		return m_AttachedTo.R6GetRootActor();
	}
	return self;
	return;
}

function AddSoundBankName(string szBank)
{
	local bool bFind;
	local int i;

	i = 0;
	J0x07:

	// End:0x65 [Loop If]
	if(__NFUN_150__(i, Level.Game.m_BankListToLoad.Length))
	{
		// End:0x5B
		if(__NFUN_122__(Level.Game.m_BankListToLoad[i], szBank))
		{
			bFind = true;
			// [Explicit Break]
			goto J0x65;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	J0x65:

	// End:0xA6
	if(__NFUN_129__(bFind))
	{
		Level.Game.m_BankListToLoad[Level.Game.m_BankListToLoad.Length] = szBank;
	}
	return;
}

function ServerSendBankToLoad()
{
	local Controller lpController;
	local int i;

	i = 0;
	J0x07:

	// End:0xA9 [Loop If]
	if(__NFUN_150__(i, Level.Game.m_BankListToLoad.Length))
	{
		lpController = Level.ControllerList;
		J0x3D:

		// End:0x9F [Loop If]
		if(__NFUN_119__(lpController, none))
		{
			// End:0x88
			if(lpController.__NFUN_303__('PlayerController'))
			{
				lpController.ClientAddSoundBank(Level.Game.m_BankListToLoad[i]);
			}
			lpController = lpController.nextController;
			// [Loop Continue]
			goto J0x3D;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

function ClientAddSoundBank(string szBank)
{
	__NFUN_2716__(szBank, 1);
	return;
}

//------------------------------------------------------------------
// Save / Reset Original Data
//	
//------------------------------------------------------------------
simulated function SaveOriginalData()
{
	return;
}

simulated function ResetOriginalData()
{
	return;
}

function LogResetSystem(bool bSaving)
{
	// End:0x3B
	if(bSaving)
	{
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("SAVING: ", string(Name)), " in "), string(Class.Name)));		
	}
	else
	{
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("RESETTING: ", string(Name)), " in "), string(Class.Name)));
	}
	return;
}

//------------------------------------------------------------------
// dbgLogActor
//	
//------------------------------------------------------------------
simulated function dbgLogActor(bool bVerbose)
{
	__NFUN_231__(__NFUN_112__("Name= ", string(Name)));
	return;
}

defaultproperties
{
	Role=4
	RemoteRole=1
	DrawType=1
	MaxLights=4
	Style=1
	SoundPitch=64
	m_eDisplayFlag=2
	m_HeatIntensity=64
	m_wNbTickSkipped=255
	m_iPlanningFloor_0=-1
	m_iPlanningFloor_1=-1
	bReplicateMovement=true
	m_bAllowLOD=true
	bMovable=true
	m_b3DSound=true
	bJustTeleported=true
	m_bIsRealtime=true
	m_bOutlinedInPlanning=true
	LODBias=1.0000000
	m_fSoundRadiusSaturation=300.0000000
	m_fSoundRadiusActivation=2000.0000000
	m_fSoundRadiusLinearFadeDist=1000.0000000
	m_fSoundRadiusLinearFadeEnd=2900.0000000
	DrawScale=1.0000000
	m_fLightingScaleFactor=1.0000000
	SoundRadius=64.0000000
	TransientSoundVolume=1.0000000
	m_fCircumstantialActionRange=175.0000000
	Mass=100.0000000
	NetPriority=1.0000000
	NetUpdateFrequency=100.0000000
	bCoronaMUL2XFactor=0.5000000
	m_fCoronaMaxSize=100000.0000000
	m_fAttachFactor=1.0000000
	Texture=Texture'Engine.S_Actor'
	MessageClass=Class'Engine.LocalMessage'
	DrawScale3D=(X=1.0000000,Y=1.0000000,Z=1.0000000)
	m_PlanningColor=(R=244,G=250,B=255,A=255)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_vID
// REMOVED IN 1.60: var EPhysics
// REMOVED IN 1.60: var EDrawType
// REMOVED IN 1.60: var g
// REMOVED IN 1.60: var ERenderStyle
// REMOVED IN 1.60: var ELightType
// REMOVED IN 1.60: var ELightEffect
// REMOVED IN 1.60: var float
// REMOVED IN 1.60: var byte
// REMOVED IN 1.60: function TakeDamage
// REMOVED IN 1.60: function HurtRadius
// REMOVED IN 1.60: function IsInPain
