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
    native
    abstract
    nativereplication;

#exec Texture Import File=Textures\S_Actor.pcx Name=S_Actor Mips=Off MASKED=1
#exec Texture Import File=Textures\S_LockLocation.pcx Name=S_LockLocation Mips=Off

// --- Constants ---
const TF_TraceActors =  0x0001;
const TF_Visibility =  0x0002;
const TF_LineOfFire =  0x0004;
const TF_SkipVolume =  0x0008;
const TF_ShadowCast =  0x0010;
const TF_SkipPawn =  0x0020;
const DEATHMSG_INTRUDER_KILLEDBY = 12;
const DEATHMSG_RAINBOW_SUFFOCATE = 11;
const DEATHMSG_PRISONER_KILLEDBY = 10;
const DEATHMSG_KILLED_BY_BOMB; // value unavailable in binary
const DEATHMSG_RAINBOW_KILLEDBYTERRO; // value unavailable in binary
const DEATHMSG_HOSTAGE_KILLEDBYTERRO; // value unavailable in binary
const DEATHMSG_HOSTAGE_KILLEDBY; // value unavailable in binary
const DEATHMSG_HOSTAGE_DIED; // value unavailable in binary
const DEATHMSG_SWITCHTEAM; // value unavailable in binary
const DEATHMSG_KAMAKAZE; // value unavailable in binary
const DEATHMSG_PENALTY; // value unavailable in binary
const DEATHMSG_CONNECTIONLOST; // value unavailable in binary
const c_iTeamNumFreeBackup =  7;
const c_iTeamNumPrisonerBravo =  6;
const c_iTeamNumPrisonerAlpha =  5;
const c_iTeamNumUnknow =  4;
const c_iTeamNumBravo =  3;
const c_iTeamNumAlpha =  2;
const c_iTeamNumTerrorist =  1;
const c_iTeamNumHostage =  0;
const TEAM_MoveAndGrenade =  0x00140;
const TEAM_GrenadeAndClear =  0x000c0;
const TEAM_OpenGrenadeAndClear =  0x000d0;
const TEAM_OpenAndGrenade =  0x00050;
const TEAM_OpenAndClear =  0x00090;
const TEAM_InteractDevice =  0x02000;
const TEAM_DisarmBomb =  0x01000;
const TEAM_EscortHostage =  0x00800;
const TEAM_SecureTerrorist =  0x00400;
const TEAM_ClimbLadder =  0x00200;
const TEAM_Move =  0x00100;
const TEAM_ClearRoom =  0x00080;
const TEAM_Grenade =  0x00040;
const TEAM_CloseDoor =  0x00020;
const TEAM_OpenDoor =  0x00010;
const TEAM_Orders =  0x00001;
const TEAM_None =  0x00000;
const MINFLOORZ =  0.7;
const MAXSTEPHEIGHT =  33.0;

// --- Enums ---
enum EModeFlagOption
{
    MFO_Available,
    MFO_NotAvailable
};
enum EDoubleClickDir
{
	DCLICK_None,
	DCLICK_Left,
	DCLICK_Right,
	DCLICK_Forward,
	DCLICK_Back,
	DCLICK_Active,
	DCLICK_Done
};
enum ESoundSlot
{
	SLOT_None,
	SLOT_Ambient,           
    SLOT_Guns,
    SLOT_SFX,               // All the special effect (Door, Explosion, Vitre, etc.)
	SLOT_GrenadeEffect,     // Use for special effect on the flash bang grenade )
	SLOT_Music,             // In game music
	SLOT_Talk,              // Use for the terrorist
    SLOT_Speak,             // Use in the menu briefing
    SLOT_HeadSet,           // Use for the Rainbow, talk with the Head Phone the player talk 
    SLOT_Menu,              // Use for all other sound in the menu
    SLOT_Instruction,
    SLOT_StartingSound
};
enum EPhysics
{
	PHYS_None,
	PHYS_Walking,
	PHYS_Falling,
	PHYS_Swimming,
	PHYS_Flying,
	PHYS_Rotating,
	PHYS_Projectile,
	PHYS_Interpolating,
	PHYS_MovingBrush,
	PHYS_Spider,
	PHYS_Trailer,
	PHYS_Ladder,
	PHYS_RootMotion,
    PHYS_Karma,
    PHYS_KarmaRagDoll
} Physics;

// Net variables.
enum ENetRole
{
	ROLE_None,              // No role at all.
	ROLE_DumbProxy,			// Dumb proxy of this actor.
	ROLE_SimulatedProxy,	// Locally simulated proxy of this actor.
	ROLE_AutonomousProxy,	// Locally autonomous proxy of this actor.
	ROLE_Authority,			// Authoritative control over the actor.
};
enum ESoundType
{
    SNDTYPE_None,           // No sound
    SNDTYPE_Gunshot,        // Check the gun for silenced or not
    SNDTYPE_BulletImpact,   // Impact, ricochet
    SNDTYPE_GrenadeImpact,  // Grenade bouncing
    SNDTYPE_GrenadeLike,    // Grenade-like weapon bouncing (FalseHB, HeartBeatJammer,...)
    SNDTYPE_Explosion,      // Various explosion (grenade, breach door)
    SNDTYPE_PawnMovement,   // Check the pawn to know the stance and the speed
    SNDTYPE_Choking,        // Choking from gas
    SNDTYPE_Talking,        // Talking
    SNDTYPE_Screaming,      // Talking louder :)
    SNDTYPE_Reload,         // Reloading weapon
    SNDTYPE_Equipping,      // Change in equipment (Weapon, gadget, ...)
    SNDTYPE_Dead,           // When a pawn died
    SNDTYPE_Door            // Opening and closing door
//    SNDTYPE_Object        // Let the objects do their own noise
};
enum ENoiseType
{
    NOISE_None,             // no sound
    NOISE_Investigate,      // Pawn go investigate
    NOISE_Threat,           // Pawn feel threatened 
    NOISE_Grenade,          // It's a grenade!!  Run!!
	NOISE_Dead				// team mate has been killed
};
enum ERenderStyle
{
	STY_None,
	STY_Normal,
	STY_Masked,
	STY_Translucent,
	STY_Modulated,
	STY_Alpha,
	STY_Particle,
    STY_Highlight
} Style;

// Display.
var(Display)  bool      bUnlit;					// Lights don't affect actor.
var(Display)  bool      bShadowCast;			// Casts static shadows.
var(Display)  bool		bStaticLighting;		// Uses raytraced lighting.
var(Display)  bool		bUseLightingFromBase;	// Use Unlit/AmbientGlow from Base

// Advanced.
var			  bool		bHurtEntry;				// keep HurtRadius from being reentrant
var(Advanced) bool		bGameRelevant;			// Always relevant for game
var(Advanced) bool		bCollideWhenPlacing;	// This actor collides with the world when placing.
var			  bool		bTravel;				// Actor is capable of travelling among servers.
var(Advanced) bool		bMovable;				// Actor can be moved.
var			  bool		bDestroyInPainVolume;	// destroy this actor if it enters a pain volume
var(Advanced) bool		bShouldBaseAtStartup;	// if true, find base for this actor at level startup, if collides with world and PHYS_None or PHYS_Rotating
var			  bool		bPendingDelete;			// set when actor is about to be deleted (since endstate and other functions called 
												// during deletion process before bDeleteMe is set).

//R6CODE    For collisions
var(Advanced) BOOL      m_bUseDifferentVisibleCollide;  // to use a different point to collide with this actor (in foreach VisibleCollidingActors)
var(Advanced) vector    m_vVisibleCenter;               // use this vector instead of location when m_bUseDifferentVisibleCollide is true
//end R6CODE

//-----------------------------------------------------------------------------
// Sound.

// Ambient sound.
var(Sound) float        SoundRadius;			// Radius of ambient sound.
var        bool         m_b3DSound;             // Does this actor emits sounds in 3D
var(Sound) byte         SoundPitch;				// Sound pitch shift, 64.0=none.


// Sound occlusion
enum ESoundOcclusion
{
	OCCLUSION_Default,
	OCCLUSION_None,
	OCCLUSION_BSP,
	OCCLUSION_StaticMeshes,
};
enum EPawnType
{
    PAWN_NotDefined,    // Not supposed to be used
    PAWN_Rainbow,
    PAWN_Terrorist,
    PAWN_Hostage,       // Hostage AND civilian
	PAWN_All
};
enum EGameModeInfo 
{
    GMI_None,          // no info or no rules game mode
    GMI_SinglePlayer,  // if the GM can be played in single
    GMI_Cooperative,   // if the GM can be played in Coop
    GMI_Adversarial,   // if the GM can be played in adversarial
    GMI_Squad          // if the GM can be played in Squad
};
enum EStance
{
    STAN_None,
    STAN_Standing,
    STAN_Crouching,
    STAN_Prone
};
enum ENetRole
{
	ROLE_None,              // No role at all.
	ROLE_DumbProxy,			// Dumb proxy of this actor.
	ROLE_SimulatedProxy,	// Locally simulated proxy of this actor.
	ROLE_AutonomousProxy,	// Locally autonomous proxy of this actor.
	ROLE_Authority,			// Authoritative control over the actor.
};
enum EDrawType
{
	DT_None,
	DT_Sprite,
	DT_Mesh,
	DT_Brush,
	DT_RopeSprite,
	DT_VerticalSprite,
	DT_Terraform,
	DT_SpriteAnimOnce,
	DT_StaticMesh,
	DT_DrawType,
	DT_Particle,
	DT_AntiPortal,
	DT_FluidSurface
} DrawType;

var const transient int		NetTag;
var			float			LastRenderTime;	// last time this actor was rendered.
var(Events) name			Tag;			// Actor's tag name.

// Execution and timer variables.
var				float       TimerRate;		// Timer event, 0=no timer.
var		const	float       TimerCounter;	// Counts up until it reaches TimerRate.
var(Advanced)	float		LifeSpan;		// How old the object lives before dying, 0=forever.

var transient MeshInstance MeshInstance;	// Mesh instance.

var(Display) float		  LODBias;

// Owner.
var         const Actor   Owner;			// Owner actor.
var(Object) name InitialState;
var(Object) name Group;

//-----------------------------------------------------------------------------
// Structures.

// Identifies a unique convex volume in the world.
struct PointRegion
{
	var zoneinfo Zone;       // Zone.
	var int      iLeaf;      // Bsp leaf.
	var byte     ZoneNumber; // Zone number.
};
enum ELoadBankSound
{
	LBS_Fix,
	LBS_UC,
	LBS_Map,
	LBS_Gun,
};
enum EMusicTransition
{
	MTRAN_None,
	MTRAN_Instant,
	MTRAN_Segue,
	MTRAN_Fade,
	MTRAN_FastFade,
	MTRAN_SlowFade,
};
enum EHostageNationality
{
    HN_French,
    HN_British,
    HN_Spanish,
    HN_Portuguese,
    HN_Norwegian
};
enum ETerroristNationality
{
    TN_Spanish1,
    TN_Spanish2,
    TN_German1,
    TN_German2,
    TN_Portuguese
};
enum eKillResult
{
    KR_None,
    KR_Wound,
    KR_Incapacitate,
    KR_Killed,
};
enum eStunResult
{
    SR_None,
    SR_Stunned,
    SR_Dazed,
    SR_KnockedOut,
};
enum ESoundOcclusion
{
	OCCLUSION_Default,
	OCCLUSION_None,
	OCCLUSION_BSP,
	OCCLUSION_StaticMeshes,
};
enum ELightType
{
	LT_None,
	LT_Steady,
	LT_Pulse,
	LT_Blink,
	LT_Flicker,
	LT_Strobe,
	LT_BackdropLight,
	LT_SubtlePulse,
	LT_TexturePaletteOnce,
	LT_TexturePaletteLoop
} LightType;

// Spatial light effect to use.
var(Lighting) enum ELightEffect
{
	LE_None,
	LE_TorchWaver,
	LE_FireWaver,
	LE_WateryShimmer,
	LE_Searchlight,
	LE_SlowWave,
	LE_FastWave,
	LE_CloudCast,
	LE_StaticSpot,
	LE_Shock,
	LE_Disco,
	LE_Warp,
	LE_Spotlight,
	LE_NonIncidence,
	LE_Shell,
	LE_OmniBumpMap,
	LE_Interference,
	LE_Cylinder,
	LE_Rotor,
	LE_Unused,
	LE_Sunlight
} LightEffect;

// Lighting info.
var(LightColor) float
	LightBrightness;
var(LightColor) byte
	LightHue,
	LightSaturation;

// Light properties.
var(Lighting) float
	LightRadius;
var(Lighting) byte
	LightPeriod,
	LightPhase,
	LightCone;

// Lighting.
var(Lighting) bool	     bSpecialLit;	// Only affects special-lit surfaces.
var(Lighting) bool	     bActorShadows; // Light casts actor shadows.
var(Lighting) bool	     bCorona;       // Light uses Skin as a corona.
var bool				 bLightChanged;	// Recalculate this light's lighting now.
var bool                 m_bLightingVisibility; // R6CODE

//-----------------------------------------------------------------------------
// Physics.

// Options.
var			  bool		  bIgnoreOutOfWorld; // Don't destroy if enters zone zero
var(Movement) bool        bBounce;           // Bounces when hits ground fast.
var(Movement) bool		  bFixedRotationDir; // Fixed direction of rotation.
var(Movement) bool		  bRotateToDesired;  // Rotate to DesiredRotation.
var           bool        bInterpolating;    // Performing interpolating.
var			  const bool  bJustTeleported;   // Used by engine physics - not valid for scripts.

// R6CODE
var           bool        m_bUseOriginalRotationInPlanning;
var           rotator     sm_Rotation;

// Physics properties.
var(Movement) float       Mass;				// Mass of this actor.
var(Movement) float       Buoyancy;			// Water buoyancy.
var(Movement) rotator	  RotationRate;		// Change in rotation per second.
var(Movement) rotator     DesiredRotation;	// Physics will smoothly rotate actor to this rotation if bRotateToDesired.
var			  Actor		  PendingTouch;		// Actor touched during move which wants to add an effect after the movement completes 
var       const vector    ColLocation;		// Actor's old location one move ago. Only for debugging

const MAXSTEPHEIGHT = 33.0; // Maximum step height walkable by pawns
const MINFLOORZ = 0.7; // minimum z value for floor normal (if less, not a walkable floor)
					   // 0.7 ~= 45 degree angle for floor

// R6DBGVECTORINFO
struct DbgVectorInfo
{
    var bool       m_bDisplay;  
    var vector     m_vLocation;
    var vector     m_vCylinder;
    var color      m_color;
    var string     m_szDef;
};
enum ELightEffect
{
	LE_None,
	LE_TorchWaver,
	LE_FireWaver,
	LE_WateryShimmer,
	LE_Searchlight,
	LE_SlowWave,
	LE_FastWave,
	LE_CloudCast,
	LE_StaticSpot,
	LE_Shock,
	LE_Disco,
	LE_Warp,
	LE_Spotlight,
	LE_NonIncidence,
	LE_Shell,
	LE_OmniBumpMap,
	LE_Interference,
	LE_Cylinder,
	LE_Rotor,
	LE_Unused,
	LE_Sunlight
} LightEffect;

// Lighting info.
var(LightColor) float
	LightBrightness;
var(LightColor) byte
	LightHue,
	LightSaturation;

// Light properties.
var(Lighting) float
	LightRadius;
var(Lighting) byte
	LightPeriod,
	LightPhase,
	LightCone;

// Lighting.
var(Lighting) bool	     bSpecialLit;	// Only affects special-lit surfaces.
var(Lighting) bool	     bActorShadows; // Light casts actor shadows.
var(Lighting) bool	     bCorona;       // Light uses Skin as a corona.
var bool				 bLightChanged;	// Recalculate this light's lighting now.
var bool                 m_bLightingVisibility; // R6CODE

//-----------------------------------------------------------------------------
// Physics.

// Options.
var			  bool		  bIgnoreOutOfWorld; // Don't destroy if enters zone zero
var(Movement) bool        bBounce;           // Bounces when hits ground fast.
var(Movement) bool		  bFixedRotationDir; // Fixed direction of rotation.
var(Movement) bool		  bRotateToDesired;  // Rotate to DesiredRotation.
var           bool        bInterpolating;    // Performing interpolating.
var			  const bool  bJustTeleported;   // Used by engine physics - not valid for scripts.

// R6CODE
var           bool        m_bUseOriginalRotationInPlanning;
var           rotator     sm_Rotation;

// Physics properties.
var(Movement) float       Mass;				// Mass of this actor.
var(Movement) float       Buoyancy;			// Water buoyancy.
var(Movement) rotator	  RotationRate;		// Change in rotation per second.
var(Movement) rotator     DesiredRotation;	// Physics will smoothly rotate actor to this rotation if bRotateToDesired.
var			  Actor		  PendingTouch;		// Actor touched during move which wants to add an effect after the movement completes 
var       const vector    ColLocation;		// Actor's old location one move ago. Only for debugging

const MAXSTEPHEIGHT = 33.0; // Maximum step height walkable by pawns
const MINFLOORZ = 0.7; // minimum z value for floor normal (if less, not a walkable floor)
					   // 0.7 ~= 45 degree angle for floor

// R6DBGVECTORINFO
struct DbgVectorInfo
{
    var bool       m_bDisplay;  
    var vector     m_vLocation;
    var vector     m_vCylinder;
    var color      m_color;
    var string     m_szDef;
};
enum EHUDDisplayType
{
    HDT_Normal,
    HDT_Hidden,
    HDT_FadeIn,
    HDT_Blink
};
enum EDisplayFlag
{
    DF_ShowOnlyInPlanning,
    DF_ShowOnlyIn3DView,
    DF_ShowInBoth
};
enum ETravelType
{
	TRAVEL_Absolute,	// Absolute URL.
	TRAVEL_Partial,		// Partial (carry name, reset server).
	TRAVEL_Relative,	// Relative URL.
};
enum EForceType
{
	FT_None,
	FT_DragAlong,
};
enum EVoicesPriority
{
    VP_Low,                                 // Can be interrupt at any time by another voices with superior priority
    VP_Medium,                              // Can stop low priority and play the current voice
    VP_High                                 // Stop and remove all sounds in low and medium alredy send and play new one
};
enum EHUDElement
{
    HE_HealthAndName,
    HE_Posture,
    HE_ActionIcon,
    HE_WeaponIconAndName,
    HE_WeaponAttachment,
    HE_Ammo,
    HE_Magazine,
    HE_ROF,
    HE_TeamHealth,
    HE_MovementMode,
    HE_ROE,
    HE_WPAction,
    HE_Reticule,
    HE_WPIcon,
    HE_OtherTeam,
    HE_PressGoCodeKey
};
enum ESendSoundStatus
{
    SSTATUS_SendToPlayer,
    SSTATUS_SendToMPTeam,
    SSTATUS_SendToAll
};
enum ESoundVolume
{
    VOLUME_Music,
    VOLUME_Voices,
    VOLUME_FX,
    VOLUME_Grenade
};

// --- Structs ---
struct PlayerMenuInfo
{
    var string szPlayerName;
    var string szKilledBy;                 // name of the player who killed me
    var INT    iKills;                     // Number of kills
    var INT    iEfficiency;                // Efficiency (hits/shot)
    var INT    iRoundsFired;               // Rounds fired (Bullets shot by the player)
	var INT    iRoundsHit;				   // Bullets shot by the player and that hit somebody
    var INT    iPingTime;                  // ping (The delay between player and server communication)
    var INT    iHealth;                    // health of this player
    var INT    iTeamSelection;
    var INT    iRoundsPlayed;              // game rounds played
    var INT    iRoundsWon;                 // game rounds won
    var INT    iDeathCount;                // number of rounds we died in this match
    var BOOL   bOwnPlayer;                 // This player is the player on this computer
    var BOOL   bSpectator;                 // treat as spectator?
    var BOOL   bPlayerReady;               // player ready icon
    var BOOL   bJoinedTeamLate;            // joined a team after game started
};

struct RandomTweenNum
{
    var()   float m_fMin;
    var()   float m_fMax;
    var     float m_fResult; // result of the last GetRandomTweenNum
};

struct ProjectorRenderInfoPtr { var int Ptr; };

struct PointRegion
{
	var zoneinfo Zone;       // Zone.
	var int      iLeaf;      // Bsp leaf.
	var byte     ZoneNumber; // Zone number.
};

struct AnimRep
{
	var name AnimSequence; 
	var bool bAnimLoop;	
	var byte AnimRate;		// note that with compression, max replicated animrate is 4.0
	var byte AnimFrame;
	var byte TweenRate;		// note that with compression, max replicated tweentime is 4 seconds
};

struct StaticMeshBatchRenderInfo
{
    var INT m_iBatchIndex;
    var INT m_iFirstIndex;
    var INT m_iMinVertexIndex;
    var INT m_iMaxVertexIndex;
};

struct IndexBufferPtr { var int Ptr; };

struct stCustomAvailability
{
    var EModeFlagOption eAvailabilityFlag;
    var string szGameType;
};

struct ProjectorRelativeRenderInfo
{
    var     ProjectorRenderInfoPtr  m_RenderInfoPtr;
    var     vector                  m_RelativeLocation;
    var     rotator                 m_RelativeRotation;
};

struct DbgVectorInfo
{
    var bool       m_bDisplay;  
    var vector     m_vLocation;
    var vector     m_vCylinder;
    var color      m_color;
    var string     m_szDef;
};

struct ResolutionInfo
{
    var INT iWidth;
    var INT iHeigh;
    var INT iRefreshRate;
};

struct R6HUDState
{
    var float           fTimeStamp;    
    var EHUDDisplayType eDisplay;
    var Color           color;
};

struct AnimStruct
{
	var() name AnimSequence;
	var() name BoneName;
	var() float AnimRate;
	var() byte alpha;
	var() byte LeadIn;
	var() byte LeadOut;
	var() bool bLoopAnim; 	
};

struct KRBVec
{
	var float	X, Y, Z;
};

// --- Variables ---
// var ? AnimFrame; // REMOVED IN 1.60
// var ? AnimRate; // REMOVED IN 1.60
// var ? AnimSequence; // REMOVED IN 1.60
// var ? TweenRate; // REMOVED IN 1.60
// var ? Z; // REMOVED IN 1.60
// var ? Zone; // REMOVED IN 1.60
// var ? ZoneNumber; // REMOVED IN 1.60
// var ? bAnimLoop; // REMOVED IN 1.60
// var ? bJoinedTeamLate; // REMOVED IN 1.60
// var ? bOwnPlayer; // REMOVED IN 1.60
// var ? bPlayerReady; // REMOVED IN 1.60
// var ? bSpectator; // REMOVED IN 1.60
// var ? color; // REMOVED IN 1.60
// var ? eDisplay; // REMOVED IN 1.60
// var ? fTimeStamp; // REMOVED IN 1.60
// var ? iDeathCount; // REMOVED IN 1.60
// var ? iEfficiency; // REMOVED IN 1.60
// var ? iHealth; // REMOVED IN 1.60
// var ? iHeigh; // REMOVED IN 1.60
// var ? iKills; // REMOVED IN 1.60
// var ? iLeaf; // REMOVED IN 1.60
// var ? iPingTime; // REMOVED IN 1.60
// var ? iRefreshRate; // REMOVED IN 1.60
// var ? iRoundsFired; // REMOVED IN 1.60
// var ? iRoundsHit; // REMOVED IN 1.60
// var ? iRoundsPlayed; // REMOVED IN 1.60
// var ? iRoundsWon; // REMOVED IN 1.60
// var ? iTeamSelection; // REMOVED IN 1.60
// var ? iWidth; // REMOVED IN 1.60
// var ? m_RelativeLocation; // REMOVED IN 1.60
// var ? m_RelativeRotation; // REMOVED IN 1.60
// var ? m_RenderInfoPtr; // REMOVED IN 1.60
// var ? m_bDisplay; // REMOVED IN 1.60
// var ? m_color; // REMOVED IN 1.60
// var ? m_fResult; // REMOVED IN 1.60
// var ? m_iBatchIndex; // REMOVED IN 1.60
// var ? m_iFirstIndex; // REMOVED IN 1.60
// var ? m_iMaxVertexIndex; // REMOVED IN 1.60
// var ? m_iMinVertexIndex; // REMOVED IN 1.60
// var ? m_szDef; // REMOVED IN 1.60
// var ? m_vCylinder; // REMOVED IN 1.60
// var ? m_vID; // REMOVED IN 1.60
// var ? m_vLocation; // REMOVED IN 1.60
// var ? szKilledBy; // REMOVED IN 1.60
// var ? szPlayerName; // REMOVED IN 1.60
// Scriptable.
// Level this actor is on.
var const LevelInfo Level;
var /* replicated */ ENetRole Role;
var const /* replicated */ Vector Location;
// ^ NEW IN 1.60
var const /* replicated */ Rotator Rotation;
// ^ NEW IN 1.60
var /* replicated */ Vector Velocity;
// ^ NEW IN 1.60
// Acceleration.
var Vector Acceleration;
var const /* replicated */ EPhysics Physics;
// ^ NEW IN 1.60
//#ifndef R6CHANGEWEAPONSYSTEM
//var Inventory             Inventory;     // Inventory chain.
//#endif
// Actor we're standing on.
var const /* replicated */ Actor Base;
// Pawn responsible for damage caused by this actor.
var /* replicated */ Pawn Instigator;
// Symmetric network flags, valid during replication only.
// Initial network update.
var const bool bNetInitial;
var const /* replicated */ float CollisionHeight;
// ^ NEW IN 1.60
var const /* replicated */ float CollisionRadius;
// ^ NEW IN 1.60
var name Event;
// ^ NEW IN 1.60
														// is "torn off" (becomes a ROLE_Authority) on clients to which it was being replicated.
//#ifdef R6CODE
// Wheter or not the ragdoll have control over the bone (used only for pawn)
var /* replicated */ bool m_bUseRagdoll;
var /* replicated */ ENetRole RemoteRole;
// Player owns this actor.
var const /* replicated */ bool bNetOwner;
// set when any attribute is assigned a value in unrealscript, reset when the actor is replicated
var const bool bNetDirty;
// if true, don't replicate actor class variables for this actor
var bool bSkipActorPropertyReplication;
var array<array> Skins;
// ^ NEW IN 1.60
// Performing interpolating.
var bool bInterpolating;
// Owner.
// Owner actor.
var const /* replicated */ Actor Owner;
var const /* replicated */ EDrawType DrawType;
// ^ NEW IN 1.60
// The actor's position and rotation.
// physics volume this actor is currently in
var const PhysicsVolume PhysicsVolume;
var /* replicated */ Rotator RotationRate;
// ^ NEW IN 1.60
// About to be deleted.
var const bool bDeleteMe;
var name Tag;
// ^ NEW IN 1.60
var /* replicated */ Sound AmbientSound;
// ^ NEW IN 1.60
var /* replicated */ bool bCollideWorld;
// ^ NEW IN 1.60
var const /* replicated */ Mesh Mesh;
// ^ NEW IN 1.60
// Collision and Physics treats this actor as world geometry
var bool bWorldGeometry;
var /* replicated */ Material Texture;
// ^ NEW IN 1.60
var /* replicated */ ERenderStyle Style;
// ^ NEW IN 1.60
// if true, replicate movement/location related properties
var bool bReplicateMovement;
// used to debug the reset system
var bool m_bResetSystemLog;
// True we are currently demo recording
var const bool bDemoRecording;
// if true, this actor is no longer replicated to new clients, and
var /* replicated */ bool bTearOff;
var /* replicated */ bool bUnlit;
// ^ NEW IN 1.60
var const /* replicated */ bool bCollideActors;
// ^ NEW IN 1.60
var /* replicated */ bool bHidden;
// ^ NEW IN 1.60
//var(Display) const float	DrawScale;			// Scaling factor, 1.0=normal size.
//R6
// Offset from box center for drawing.
var /* replicated */ Vector PrePivot;
var bool m_bTickOnlyWhenVisible;
var /* replicated */ Rotator DesiredRotation;
// ^ NEW IN 1.60
var /* replicated */ bool bBlockActors;
// ^ NEW IN 1.60
//R6SHADOW
var Projector Shadow;
var float Mass;
// ^ NEW IN 1.60
var bool bStasis;
// ^ NEW IN 1.60
var float LifeSpan;
// ^ NEW IN 1.60
var /* replicated */ bool bBlockPlayers;
// ^ NEW IN 1.60
var /* replicated */ bool bRotateToDesired;
// ^ NEW IN 1.60
// Physics properties.
// Actor touched during move which wants to add an effect after the movement completes
var Actor PendingTouch;
var bool bCanTeleport;
// ^ NEW IN 1.60
// if true, update velocity/location after initialization for simulated proxies
var bool bUpdateSimulatedPosition;
var name InitialState;
// ^ NEW IN 1.60
// Region this actor is in.
var const PointRegion Region;
var const /* replicated */ StaticMesh StaticMesh;
// ^ NEW IN 1.60
var const /* replicated */ Vector DrawScale3D;
// ^ NEW IN 1.60
var Actor m_AttachedTo;
// True if we're client-side demo recording and this call originated from the remote.
var const bool bClientDemoNetFunc;
// True we are currently recording a client-side demo
var const bool bClientDemoRecording;
// only replicated if bReplicateAnimations is true
var transient /* replicated */ AnimRep SimAnim;
var bool bHighDetail;
// ^ NEW IN 1.60
// Don't replicate any animations - animation done client-side
var bool bClientAnim;
var bool bAcceptsProjectors;
// ^ NEW IN 1.60
// Force to replicate Base and AttachmentBone, mostly for weapon
var bool m_bForceBaseReplication;
// Counts up until it reaches TimerRate.
var const float TimerCounter;
// Object responsible if the current ambience that should be hear by this actor.  Use when we switch from player to player
var Actor m_CurrentAmbianceObject;
// Some objects, like ZoneInfo, contains Entry and Exit Sound.  This lag is to know which of the m_CurrentAmbianceSounds object to use
var bool m_bUseExitSounds;
// Attachment related variables
// array of actors attached to this actor.
var const array<array> Attached;
var /* replicated */ bool bProjTarget;
// ^ NEW IN 1.60
//#endif R6CODE
// Animation dictated by owner.
var bool bAnimByOwner;
// Cause ripples when in contact with FluidSurface.
var bool bDisturbFluidSurface;
// Always relevant for network.
var bool bAlwaysRelevant;
// Replicate instigator to client (used by bNetTemporary projectiles).
var bool bReplicateInstigator;
														// bOnlyDirtyReplication only used with bAlwaysRelevant actors
// Should replicate SimAnim
var bool bReplicateAnimations;
// when spawned in game, after the game is started, this is set to true
var bool m_bSpawnedInGame;
// Actor who must be deleted when resetting the level
var bool m_bDeleteOnReset;
// Execution and timer variables.
// Timer event, 0=no timer.
var float TimerRate;
// Level object.
var transient const Level XLevel;
// Brush if DrawType=DT_Brush.
var const Model Brush;
var bool bGameRelevant;
// ^ NEW IN 1.60
// destroy this actor if it enters a pain volume
var bool bDestroyInPainVolume;
var bool m_bBulletGoThrough;
// ^ NEW IN 1.60
var /* replicated */ ELightType LightType;
// ^ NEW IN 1.60
var bool bBounce;
// ^ NEW IN 1.60
var /* replicated */ bool bFixedRotationDir;
// ^ NEW IN 1.60
// Used by engine physics - not valid for scripts.
var const bool bJustTeleported;
// Network control.
// Higher priorities means update it more frequently.
var float NetPriority;
// set to prevent re-initializing of actors spawned during level startup
var bool bScriptInitialized;
var float m_fCummulativeTick;
var byte m_wNbTickSkipped;
var byte m_wTickFrequency;
// Variable for skipping certain tick for unimportant actor
var bool m_bSkipTick;
var bool m_bForceStaticLighting;
// ^ NEW IN 1.60
var bool m_bBatchesStaticLightingUpdated;
var array<array> m_Batches;
var int m_iTracedLastTick;
var int m_iTracedCycles;
var int m_iTraceLastTick;
var int m_iTraceCycles;
var int m_iTickCycles;
var int m_iNbRenders;
var int m_iTotalRenderCycles;
var int m_iLastRenderTick;
var int m_iLastRenderCycles;
var byte m_HeatIntensity;
// ^ NEW IN 1.60
var byte m_u8RenderDataLastUpdate;
var int m_bInWeatherVolume;
var transient const IndexBufferPtr m_OutlineIndexBuffer;
var StaticMesh m_OutlineStaticMesh;
// 2 16-bits indices each
var array<array> m_OutlineIndices;
// Actor was modified in the editor
var bool m_bNeedOutlineUpdate;
var bool m_bOutlinedInPlanning;
// ^ NEW IN 1.60
var bool m_bHidePortal;
var bool m_bShouldHidePortal;
// ^ NEW IN 1.60
var bool m_bIsRealtime;
// ^ NEW IN 1.60
// Factor used by R6Tags.  if the scale changes (1.1 for rainbow character, 1 for Terrorists)
var /* replicated */ float m_fAttachFactor;
var array<array> m_aCustomAvailability;
// ^ NEW IN 1.60
var const EModeFlagOption m_eVirusUploadAdv;
// ^ NEW IN 1.60
var const EModeFlagOption m_eLimitSeatsAdv;
// ^ NEW IN 1.60
var const EModeFlagOption m_eIntruderAdv;
// ^ NEW IN 1.60
var const EModeFlagOption m_eGazAlertAdv;
// ^ NEW IN 1.60
var const EModeFlagOption m_eFreeBackupAdv;
// ^ NEW IN 1.60
var const EModeFlagOption m_eKamikaze;
// ^ NEW IN 1.60
var const EModeFlagOption m_eCountDown;
// ^ NEW IN 1.60
var const EModeFlagOption m_eCaptureTheEnemyAdv;
// ^ NEW IN 1.60
var const EModeFlagOption m_eScatteredHuntAdv;
// ^ NEW IN 1.60
var const EModeFlagOption m_eTerroristHuntAdv;
// ^ NEW IN 1.60
var const EModeFlagOption m_eSquadTeamDeathmatch;
// ^ NEW IN 1.60
var const EModeFlagOption m_eSquadDeathmatch;
// ^ NEW IN 1.60
var const EModeFlagOption m_eLoneWolf;
// ^ NEW IN 1.60
var const EModeFlagOption m_eEscort;
// ^ NEW IN 1.60
var const EModeFlagOption m_eBomb;
// ^ NEW IN 1.60
var const EModeFlagOption m_eTeamDeathmatch;
// ^ NEW IN 1.60
var const EModeFlagOption m_eDeathmatch;
// ^ NEW IN 1.60
var const EModeFlagOption m_eReconCoop;
// ^ NEW IN 1.60
var const EModeFlagOption m_eRecon;
// ^ NEW IN 1.60
var const EModeFlagOption m_eDefendCoop;
// ^ NEW IN 1.60
var const EModeFlagOption m_eDefend;
// ^ NEW IN 1.60
var const EModeFlagOption m_eHostageRescueAdv;
// ^ NEW IN 1.60
var const EModeFlagOption m_eHostageRescueCoop;
// ^ NEW IN 1.60
var const EModeFlagOption m_eHostageRescue;
// ^ NEW IN 1.60
var const EModeFlagOption m_eTerroristHuntCoop;
// ^ NEW IN 1.60
var const EModeFlagOption m_eTerroristHunt;
// ^ NEW IN 1.60
var const EModeFlagOption m_eMissionMode;
// ^ NEW IN 1.60
var const EModeFlagOption m_eStoryMode;
// ^ NEW IN 1.60
var const bool m_bHideInLowGoreLevel;
// ^ NEW IN 1.60
var bool m_bSpriteShowOver;
var byte m_u8SpritePlanningAngle;
// ^ NEW IN 1.60
var bool m_bSpriteShownIn3DInPlanning;
// ^ NEW IN 1.60
var bool m_bSpriteShowFlatInPlanning;
// ^ NEW IN 1.60
var bool m_bIsWalkable;
// ^ NEW IN 1.60
var bool m_bPlanningAlwaysDisplay;
// ^ NEW IN 1.60
var int m_iPlanningFloor_1;
// ^ NEW IN 1.60
var int m_iPlanningFloor_0;
// ^ NEW IN 1.60
var Color m_PlanningColor;
// ^ NEW IN 1.60
var EDisplayFlag m_eDisplayFlag;
// ^ NEW IN 1.60
var float m_fCoronaMaxSize;
// ^ NEW IN 1.60
var float m_fCoronaMinSize;
// ^ NEW IN 1.60
var float bCoronaMUL2XFactor;
// ^ NEW IN 1.60
var class<LocalMessage> MessageClass;
//#ifdef R6EDITORLOCKACTOR
// Locked in editor (no movement or rotation).
var bool bEdLocked;
var bool bLockLocation;
// ^ NEW IN 1.60
// Internal/path building
var transient bool bPathTemp;
// this actor should collide (if bWorldGeometry && bBlockActors is true) during path building (ignored if bStatic is true, as actor will always collide during path building)
var bool bPathColliding;
// actor is obsolete - warn level designers to remove it
var bool bObsolete;
// Internal UnrealEd.
var transient const bool bTempEditor;
// Should snap to grid in UnrealEd.
var transient bool bEdSnap;
var bool bEdShouldSnap;
// ^ NEW IN 1.60
//Editing flags
// Selected in UnrealEd.
var const bool bSelected;
var bool bDirectional;
// ^ NEW IN 1.60
var bool bHiddenEdGroup;
// ^ NEW IN 1.60
var bool bHiddenEd;
// ^ NEW IN 1.60
// Actor is currently relevant. Only valid server side, only when replicating variables.
var const bool bNetRelevant;
// How many seconds between net updates.
var float NetUpdateFrequency;
var float ForceScale;
var float ForceRadius;
var EForceType ForceType;
// #ifdef R6CODE
// rbrek - 12 nov 2001
//  used for bone rotation, represents the transition of a bone rotation
//  if == 1, either no bone rotation has been done or a bone rotation has been applied but the transition is complete.
//  if == 0, a bone rotation was requested and we are at the very start of the transition to the desired rotation.
var float m_fBoneRotationTransition;
var native const int KStepTag;
var KarmaParamsCollision KParams;
// ^ NEW IN 1.60
//#ifdef R6CHARLIGHTVALUE
// Light value of the actor in the range 0..1
var float fLightValue;
var array<array> m_dbgVectorInfo;
// Actor's old location one move ago. Only for debugging
var const Vector ColLocation;
var float Buoyancy;
// ^ NEW IN 1.60
var Rotator sm_Rotation;
// R6CODE
var bool m_bUseOriginalRotationInPlanning;
// Options.
// Don't destroy if enters zone zero
var bool bIgnoreOutOfWorld;
// R6CODE
var bool m_bLightingVisibility;
// Lighting.
// Recalculate this light's lighting now.
var bool bLightChanged;
var bool bCorona;
// ^ NEW IN 1.60
var /* replicated */ bool bActorShadows;
// ^ NEW IN 1.60
var /* replicated */ bool bSpecialLit;
// ^ NEW IN 1.60
var byte LightCone;
// ^ NEW IN 1.60
var /* replicated */ byte LightPhase;
// ^ NEW IN 1.60
var /* replicated */ byte LightPeriod;
// ^ NEW IN 1.60
var /* replicated */ float LightRadius;
// ^ NEW IN 1.60
var /* replicated */ byte LightSaturation;
// ^ NEW IN 1.60
var /* replicated */ byte LightHue;
// ^ NEW IN 1.60
var /* replicated */ float LightBrightness;
// ^ NEW IN 1.60
var /* replicated */ ELightEffect LightEffect;
// ^ NEW IN 1.60
var bool m_bLogNetTraffic;
// ^ NEW IN 1.60
// Second CollisionBox of the pawn
var /* replicated */ R6ColBox m_collisionBox2;
//R6COLLISIONBOX
// Second CollisionBox of the pawn
var /* replicated */ R6ColBox m_collisionBox;
var const bool bBlockKarma;
// ^ NEW IN 1.60
var bool bUseCylinderCollision;
// ^ NEW IN 1.60
var bool bAutoAlignToTerrain;
// ^ NEW IN 1.60
// R6CIRCUMSTANTIALACTION
var float m_fCircumstantialActionRange;
var byte m_iTracedBone;
// Collision flags.
//#ifndef R6CODE
//#endif // #ifndef R6CODE
// #ifdef R6PERBONECOLLISION
// Use per-bone collision
var bool m_bDoPerBoneTrace;
var bool m_bShotThrough;
// ^ NEW IN 1.60
var bool m_bPawnGoThrough;
// ^ NEW IN 1.60
var bool m_bSeeThrough;
// ^ NEW IN 1.60
var float TransientSoundRadius;
// ^ NEW IN 1.60
var float TransientSoundVolume;
// ^ NEW IN 1.60
var /* replicated */ name m_szSoundBoneName;
// ^ NEW IN 1.60
var ESoundOcclusion SoundOcclusion;
// ^ NEW IN 1.60
var /* replicated */ byte SoundPitch;
// ^ NEW IN 1.60
// Ambient sound.
// Does this actor emits sounds in 3D
var bool m_b3DSound;
var /* replicated */ float SoundRadius;
// ^ NEW IN 1.60
var Vector m_vVisibleCenter;
// ^ NEW IN 1.60
var bool m_bUseDifferentVisibleCollide;
// ^ NEW IN 1.60
// set when actor is about to be deleted (since endstate and other functions called
var bool bPendingDelete;
var bool bShouldBaseAtStartup;
// ^ NEW IN 1.60
var bool bMovable;
// ^ NEW IN 1.60
// Actor is capable of travelling among servers.
var bool bTravel;
var bool bCollideWhenPlacing;
// ^ NEW IN 1.60
// Advanced.
// keep HurtRadius from being reentrant
var bool bHurtEntry;
var bool bUseLightingFromBase;
// ^ NEW IN 1.60
var bool bStaticLighting;
// ^ NEW IN 1.60
var bool bShadowCast;
// ^ NEW IN 1.60
var float CullDistance;
// ^ NEW IN 1.60
//R6Code
var bool m_bAllowLOD;
var /* replicated */ Color m_fLightingAdditiveAmbiant;
// ^ NEW IN 1.60
var /* replicated */ float m_fLightingScaleFactor;
// ^ NEW IN 1.60
var array<array> NightVisionSkins;
// ^ NEW IN 1.60
var ConvexVolume AntiPortal;
// ^ NEW IN 1.60
var byte MaxLights;
// ^ NEW IN 1.60
var /* replicated */ byte AmbientGlow;
// ^ NEW IN 1.60
var /* replicated */ float DrawScale;
// ^ NEW IN 1.60
// Contains per-instance static mesh data, like static lighting data.
var StaticMeshInstance StaticMeshInstance;
// Projected textures on this actor
var transient const array<array> Projectors;
//R6CODE from UT2003
											// This actor cannot then move relative to base (setlocation etc.).
											// Dont set while currently based on something!
											//
// Transform of actor in base's ref frame. Doesn't change after SetBase.
var const Matrix HardRelMatrix;
var const bool bHardAttach;
// ^ NEW IN 1.60
// name of bone to which actor is attached (if attached to center of base, =='')
var const /* replicated */ name AttachmentBone;
// rotation relative to base/bone (valid if base exists)
var const /* replicated */ Rotator RelativeRotation;
// location relative to base/bone (valid if base exists)
var const /* replicated */ Vector RelativeLocation;
var name AttachTag;
// ^ NEW IN 1.60
var transient const int JoinedTag;
// Internal tags.
var native const int ActorTag;
var native const int LightingTag;
// ^ NEW IN 1.60
var native const int CollisionTag;
// ^ NEW IN 1.60
// Next actor in just-deleted chain.
var const Actor Deleted;
var transient const Vector OctreeBoxRadii;
var transient const Vector OctreeBoxCenter;
// Actor bounding box cached when added to Octree. Internal use only.
var transient const Box OctreeBox;
// Array of nodes of the octree Actor is currently in. Internal use only.
var transient const array<array> OctreeNodes;
// List of touching actors.
var const array<array> Touching;
// Internal.
// Internal latent function use.
var const float LatentFloat;
// BSP leaves this actor is in.
var transient array<array> Leaves;
//R6CODE This actor is drawn by its parent
var bool m_bDrawFromBase;
// When the we want play the sound only once. A check is made to know if the sound was already played.
var bool m_bSoundWasPlayed;
// Object responsible if the current ambience that should be hear by this actor.  Use when we switch from player to player
var Actor m_CurrentVolumeSound;
var array<array> m_ListOfZoneInfo;
// ^ NEW IN 1.60
var bool m_bIfDirectLineOfSight;
// ^ NEW IN 1.60
var bool m_bListOfZoneHearable;
// ^ NEW IN 1.60
var bool m_bPlayOnlyOnce;
// ^ NEW IN 1.60
var bool m_bPlayIfSameZone;
// ^ NEW IN 1.60
// ifdef R6Sound
var bool m_bInAmbientRange;
var float m_fSoundRadiusLinearFadeEnd;
// ^ NEW IN 1.60
var float m_fSoundRadiusLinearFadeDist;
// ^ NEW IN 1.60
var float m_fSoundRadiusActivation;
// ^ NEW IN 1.60
var float m_fSoundRadiusSaturation;
// ^ NEW IN 1.60
var float m_fAmbientSoundRadius;
// ^ NEW IN 1.60
var Sound AmbientSoundStop;
// ^ NEW IN 1.60
var name Group;
// ^ NEW IN 1.60
var float LODBias;
// ^ NEW IN 1.60
// Mesh instance.
var transient MeshInstance MeshInstance;
// last time this actor was rendered.
var float LastRenderTime;
var transient const int NetTag;
var bool m_bRenderOutOfWorld;
var bool m_bBypassAmbiant;
// ^ NEW IN 1.60
var bool m_bFirstTimeInZone;
var bool m_bShowInHeatVision;
//R6CODE
// if the true, eventGetReticuleInfo will get call
var const bool m_bReticuleInfo;
// used by networking code to flag compressed position replication
var bool bCompressedPosition;
//UT2K3
// Should replicate initial rotation
var const bool bNetInitialRotation;
//#endif // #ifdef R6CODE
// if true, only replicate actor if bNetDirty is true - useful if no C++ changed attributes (such as physics)
var bool bOnlyDirtyReplication;
// Actor should only be replicated if bandwidth available.
var const bool bNetOptional;
// Networking flags
// Tear-off simulation in network play.
var const bool bNetTemporary;
// Mainly for debugging - the way this actor was inserted into Octree.
var bool bWasSNFiltered;
var bool bShowOctreeNodes;
// Optimisation - only test ovelap against pawns. Used for influences etc.
var const bool bOnlyAffectPawns;
// when landing, orient base on slope of floor
var bool bOrientOnSlope;
//R6CODE
//var					bool    bAcceptsProjectors;	// Projectors can project onto this actor
// Projectors can project onto this actor but are relative to it -jfd
var bool m_bHandleRelativeProjectors;
// If PHYS_Trailer and true, offset from owner by PrePivot.
var bool bTrailerPrePivot;
// If PHYS_Trailer and true, have same rotation as owner.
var bool bTrailerSameRotation;
// Update even when players-only.
var const bool bAlwaysTick;
// Only owner can see this actor.
var /* replicated */ bool bOnlyOwnerSee;
// Everything but the owner can see this actor.
var bool bOwnerNoSee;
// Timer loops (else is one-shot).
var bool bTimerLoop;
// R6CODE
var bool m_bDynamicLightOnlyAffectPawns;
var bool bDynamicLight;
// ^ NEW IN 1.60
// Actor has been updated.
var transient const bool bTicked;
var bool m_bSkipHitDetection;
var bool m_bUseR6Availability;
// ^ NEW IN 1.60
//#ifdef R6CODE
// Overrides bNoDelete, we need bNoDelete set to true for Interactive objects, but we want to be able to override
// this if it should not be available based on game mode.
var const bool m_bR6Deletable;
var const bool bNoDelete;
// ^ NEW IN 1.60
// Flags.
// Does not move or change over time. Don't let L.D.s change this - screws up net play
var const bool bStatic;

// --- Functions ---
// function ? HurtRadius(...); // REMOVED IN 1.60
// function ? TakeDamage(...); // REMOVED IN 1.60
// Called immediately after gameplay begins.
//
event PostBeginPlay() {}
//
// Triggers.
//
event Trigger(Actor Other, Pawn EventInstigator) {}
final function ReplaceText(out string Text, string Replace, string With) {}
//
// Major notifications.
//
//event Destroyed();
//R6SHADOW
event Destroyed() {}
//
// Called immediately before gameplay begins.
//
event PreBeginPlay() {}
function Reset() {}
simulated function ResetOriginalData() {}
//
// Physics & world interaction.
//
event Timer() {}
event Touch(Actor Other) {}
//R6CODE
function int R6TakeDamage(int iKillValue, optional int iBulletGoup, int iBulletToArmorModifier, Vector vMomentum, Vector vHitLocation, Pawn instigatedBy, int iStunValue) {}
// ^ NEW IN 1.60
event Tick(float DeltaTime) {}
final native function KWake() {}
simulated function DisplayDebug(Canvas Canvas, out float YPos, out float YL) {}
// Level state.
event BeginPlay() {}
//
// Damage and kills.
//
event KilledBy(Pawn EventInstigator) {}
event UnTrigger(Actor Other, Pawn EventInstigator) {}
event Actor SpecialHandling(Pawn Other) {}
// ^ NEW IN 1.60
event UnTouch(Actor Other) {}
//#endif
final simulated native function Coords GetBoneCoords(name BoneName, optional bool bDontCallGetFrame) {}
// ^ NEW IN 1.60
final native function SetDrawScale(float NewScale) {}
event bool EncroachingOn(Actor Other) {}
// ^ NEW IN 1.60
//#ifdef R6CODE
simulated function FirstPassReset() {}
// called after PostBeginPlay.  On a net client, PostNetBeginPlay() is spawned after replicated variables have been initialized to
// their replicated values
event PostNetBeginPlay() {}
// Returns the human readable string representation of an object.
//
function string GetHumanReadableName() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// Save / Reset Original Data
//
//------------------------------------------------------------------
simulated function SaveOriginalData() {}
event Bump(Actor Other) {}
event PostTouch(Actor Other) {}
event HitWall(Vector HitNormal, Actor HitWall) {}
event EncroachedBy(Actor Other) {}
event BaseChange() {}
final native function StopAnimating(optional bool ClearAllButBase) {}
// Animation notifications.
event AnimEnd(int Channel) {}
// event called when Karmic actor hits with impact velocity over KImpactThreshold
event KImpact(Actor Other, Vector pos, Vector impactVel, Vector impactNorm) {}
event Attach(Actor Other) {}
final native function SetDrawScale3D(Vector NewScale3D) {}
final native function SetDrawType(EDrawType NewDrawType) {}
event Landed(Vector HitNormal) {}
event FellOutOfWorld() {}
event FinishedInterpolation() {}
event Falling() {}
event EndEvent() {}
event BeginEvent() {}
final simulated native function LinkMesh(Mesh NewMesh, optional bool bKeepAnim) {}
final native function StopAllMusic() {}
//R6SOUND
final native function bool PlayMusic(optional bool bForcePlayMusic, Sound Music) {}
// ^ NEW IN 1.60
//===========================================================================//
// R6QueryCircumstantialAction()                                             //
//  Get circumstantial action informations from an actor.                    //
//===========================================================================//
event R6QueryCircumstantialAction(out R6AbstractCircumstantialActionQuery Query, float fDistance, PlayerController PlayerController) {}
final native function GetAnimParams(int Channel, out name OutSeqName, out float OutAnimFrame, out float OutAnimRate) {}
final native function Plane GetRenderBoundingSphere() {}
// ^ NEW IN 1.60
final native function KAddImpulse(optional name BoneName, Vector Position, Vector Impulse) {}
final native function OnlyAffectPawns(bool B) {}
function PlayTeleportEffect(bool bOut, bool bSound) {}
function bool CanSplash() {}
// ^ NEW IN 1.60
simulated function StartInterpolation() {}
function SetDefaultDisplayProperties() {}
// Set the display properties of an actor.  By setting them through this function, it allows
// the actor to modify other components (such as a Pawn's weapon) or to adjust the result
// based on other factors (such as a Pawn's other inventory wanting to affect the result)
function SetDisplayProperties(bool bLighting, Material NewTexture, ERenderStyle NewStyle) {}
// Called by PlayerController when this actor becomes its ViewTarget.
//
function BecomeViewTarget() {}
// Called when carried into a new level, after AcceptInventory.
//
event TravelPostAccept() {}
function RenderOverlays(Canvas Canvas) {}
//------------------------------------------------------------------
// GetReticuleInfo: info displayed under the reticule.
//  optimized to work with the flag m_bReticuleInfo.
//	out: szName is the name identifying this Actor
//       return true if it's a friend or a neutral actor, False if enemy
//------------------------------------------------------------------
simulated event bool GetReticuleInfo(out string szName, Pawn ownerReticule) {}
// ^ NEW IN 1.60
event UsedBy(Pawn User) {}
// Execute a console command in the context of the current level and game engine.
native function string ConsoleCommand(string Command) {}
// ^ NEW IN 1.60
final native function FadeSound(ESoundSlot eSlot, int iFade, float fTime) {}
// ^ NEW IN 1.60
final native function ReturnSavedFadeValue(float fTime) {}
// ^ NEW IN 1.60
final simulated native function PlayOwnedSound(optional bool Attenuate, optional float Pitch, optional float Radius, optional bool bNoOverride, optional float Volume, optional ESoundSlot Slot, Sound Sound) {}
// ^ NEW IN 1.60
function DemoPlaySound(optional bool Attenuate, optional float Pitch, optional float Radius, optional bool bNoOverride, optional float Volume, optional ESoundSlot Slot, Sound Sound) {}
// ^ NEW IN 1.60
final native function float GetSoundDuration(Sound Sound) {}
// ^ NEW IN 1.60
final native function StopAllSoundsActor(Actor aActor) {}
// ^ NEW IN 1.60
final native function AddAndFindBankInSound(Sound Sound, ELoadBankSound eLBS) {}
// ^ NEW IN 1.60
final native function MakeNoise(optional ESoundType ESoundType, optional EPawnType ePawn, optional ENoiseType eNoise, float Loudness) {}
// ^ NEW IN 1.60
function R6MakeNoise2(EPawnType ePawn, ENoiseType eNoise, float fLoudness) {}
final native function AddSoundBank(string szBank, ELoadBankSound eLBS) {}
// ^ NEW IN 1.60
final native function string GetMapName(int Dir, string MapName, string NameEnding) {}
// ^ NEW IN 1.60
final native function GetNextSkin(out string SkinDesc, out string SkinName, int Dir, string CurrentSkin, string Prefix) {}
// ^ NEW IN 1.60
final native function string GetNextInt(int Num, string ClassName) {}
// ^ NEW IN 1.60
final native function ChangeVolumeType(ESoundSlot eSlot, float fVolume) {}
// ^ NEW IN 1.60
final native function GetNextIntDesc(out string Description, out string Entry, int Num, string ClassName) {}
final native function bool GetCacheEntry(out string FileName, out string Guid, int Num) {}
// ^ NEW IN 1.60
final native function bool MoveCacheEntry(optional string NewFilename, string Guid) {}
// ^ NEW IN 1.60
final native iterator function AllActors(optional name MatchTag, out Actor Actor, class<Actor> BaseClass) {}
// ^ NEW IN 1.60
final native iterator function DynamicActors(optional name MatchTag, out Actor Actor, class<Actor> BaseClass) {}
// ^ NEW IN 1.60
final native function bool ResetVolume_TypeSound(ESoundSlot eSlot) {}
// ^ NEW IN 1.60
final native iterator function ChildActors(out Actor Actor, class<Actor> BaseClass) {}
// ^ NEW IN 1.60
final native iterator function BasedActors(out Actor Actor, class<Actor> BaseClass) {}
// ^ NEW IN 1.60
final native iterator function TouchingActors(out Actor Actor, class<Actor> BaseClass) {}
// ^ NEW IN 1.60
final native iterator function TraceActors(optional Vector Extent, optional Vector Start, Vector End, out Vector HitNorm, out Vector HitLoc, out Actor Actor, class<Actor> BaseClass) {}
// ^ NEW IN 1.60
final native iterator function RadiusActors(optional Vector Loc, float Radius, out Actor Actor, class<Actor> BaseClass) {}
// ^ NEW IN 1.60
final native iterator function VisibleActors(optional Vector Loc, optional float Radius, out Actor Actor, class<Actor> BaseClass) {}
// ^ NEW IN 1.60
final native iterator function VisibleCollidingActors(optional bool bIgnoreHidden, optional Vector Loc, float Radius, out Actor Actor, class<Actor> BaseClass) {}
// ^ NEW IN 1.60
final native iterator function CollidingActors(optional Vector Loc, float Radius, out Actor Actor, class<Actor> BaseClass) {}
// ^ NEW IN 1.60
static final native operator Color Subtract_ColorColor(Color B, Color A) {}
// ^ NEW IN 1.60
final native function bool IsPlayingSound(Actor aActor, Sound Sound) {}
// ^ NEW IN 1.60
static final native operator Color Multiply_FloatColor(Color B, float A) {}
// ^ NEW IN 1.60
static final native operator Color Add_ColorColor(Color B, Color A) {}
// ^ NEW IN 1.60
final native function StopSound(Sound Sound) {}
// ^ NEW IN 1.60
static final native operator Color Multiply_ColorFloat(float B, Color A) {}
// ^ NEW IN 1.60
final native function SetPlanningMode(bool bDraw) {}
// ^ NEW IN 1.60
final native function PlaySound(Sound Sound, optional ESoundSlot Slot) {}
// ^ NEW IN 1.60
final native function SetFloorToDraw(int iFloor) {}
// ^ NEW IN 1.60
final native function SetTimer(float NewTimerRate, bool bLoop) {}
// ^ NEW IN 1.60
final native function RenderLevelFromMe(int iYSize, int iXSize, int iYMin, int iXMin) {}
// ^ NEW IN 1.60
final native function GetTagInformations(optional float vOwnerScale, out Rotator OutRotator, out Vector outVector, string TagName) {}
// ^ NEW IN 1.60
final native function DrawDashedLine(float fDashSize, Color Col, Vector vEnd, Vector vStart) {}
// ^ NEW IN 1.60
final native function DbgVectorReset(int vectorIndex) {}
// ^ NEW IN 1.60
final native function DbgVectorAdd(optional string szDef, int vectorIndex, Vector vCylinder, Vector vPoint) {}
// ^ NEW IN 1.60
final native function DbgAddLine(Color cColor, Vector vEnd, Vector vStart) {}
// ^ NEW IN 1.60
final native function DrawText3D(coerce string pString, Vector vPos) {}
// ^ NEW IN 1.60
final native function bool IsAvailableInGameType(string szGameType) {}
// ^ NEW IN 1.60
final native function GetFPlayerMenuInfo(out PlayerMenuInfo _iPlayerMenuInfo, int Index) {}
// ^ NEW IN 1.60
//
// Broadcast a localized message to all players.
// Most message deal with 0 to 2 related PRIs.
// The LocalMessage class defines how the PRI's and optional actor are used.
//
event BroadcastLocalizedMessage(optional Object OptionalObject, optional PlayerReplicationInfo RelatedPRI_2, optional PlayerReplicationInfo RelatedPRI_1, optional int Switch, class<LocalMessage> MessageClass) {}
final native function SetFPlayerMenuInfo(PlayerMenuInfo _iPlayerMenuInfo, int Index) {}
// ^ NEW IN 1.60
final native function GetPlayerSetupInfo(out string m_GadgetNameTwo, out string m_GadgetNameOne, out string m_BulletTypeTwo, out string m_WeaponGadgetNameTwo, out string m_WeaponNameTwo, out string m_BulletTypeOne, out string m_WeaponGadgetNameOne, out string m_WeaponNameOne, out string m_ArmorName, out string m_CharacterName) {}
// ^ NEW IN 1.60
final native function SetPlayerSetupInfo(string m_GadgetNameTwo, string m_GadgetNameOne, string m_BulletTypeTwo, string m_WeaponGadgetNameTwo, string m_WeaponNameTwo, string m_BulletTypeOne, string m_WeaponGadgetNameOne, string m_WeaponNameOne, string m_ArmorName, string m_CharacterName) {}
// ^ NEW IN 1.60
function LogResetSystem(bool bSaving) {}
function ClientAddSoundBank(string szBank) {}
final native function SortFPlayerMenuInfo(string szGameType, int LastIndex) {}
// ^ NEW IN 1.60
static final native function GetAvailableResolution(out int RefreshRate, out int Height, out int Width, int Index) {}
// ^ NEW IN 1.60
function bool IsInVolume(Volume aVolume) {}
// ^ NEW IN 1.60
static final native function NativeNonUbiMatchMakingAddress(out string RemoteIpAddress) {}
// ^ NEW IN 1.60
static final native function NativeNonUbiMatchMakingPassword(out string NonUbiPassword) {}
// ^ NEW IN 1.60
static final native function R6ServerInfo SaveServerOptions(optional string FileName) {}
// ^ NEW IN 1.60
static final native function SetServerBeacon(InternetInfo ServerBeacon) {}
// ^ NEW IN 1.60
event R6MakeNoise(ESoundType eType) {}
static final native function SetPBStatus(bool _bServerStatus, bool _bDisable) {}
// ^ NEW IN 1.60
static final native function LoadLoadingScreen(Texture pTex1, Texture pTex0, string MapName) {}
// ^ NEW IN 1.60
static final native function bool ReplaceTexture(Texture pTex, string FileName) {}
// ^ NEW IN 1.60
final native function string ConvertGameTypeIntToString(int iGameType) {}
// ^ NEW IN 1.60
final native function Actor Spawn(optional Actor SpawnOwner, optional name SpawnTag, optional Vector SpawnLocation, optional Rotator SpawnRotation, optional bool bNoCollisionFail, class<Actor> SpawnClass) {}
// ^ NEW IN 1.60
final native function int ConvertGameTypeToInt(string szGameType) {}
// ^ NEW IN 1.60
static final native function string GetGameVersion(optional bool _bModVersion, optional bool _bShortVersion) {}
// ^ NEW IN 1.60
static final native function EnableLoadingScreen(bool _enable) {}
// ^ NEW IN 1.60
static final native function AddMessageToConsole(optional byte bMessageUseBigFont, Color MsgColor, string Msg) {}
// ^ NEW IN 1.60
function UntriggerEvent(name EventName, Pawn EventInstigator, Actor Other) {}
static final native function string ConvertIntTimeToString(int iTimeToConvert, optional bool bAlignMinOnTwoDigits) {}
// ^ NEW IN 1.60
static final native function string GlobalIDToString(byte aBytes) {}
// ^ NEW IN 1.60
final native function bool FastTrace(optional Vector TraceStart, Vector TraceEnd) {}
// ^ NEW IN 1.60
final native function bool FindSpot(optional Vector vExtent, out Vector vLocation) {}
// ^ NEW IN 1.60
final native function Actor R6Trace(out optional Material Material, optional Vector Extent, optional int iTraceFlags, optional Vector TraceStart, Vector TraceEnd, out Vector HitNormal, out Vector HitLocation) {}
// ^ NEW IN 1.60
event TriggerEvent(name EventName, Pawn EventInstigator, Actor Other) {}
static final native function GlobalIDToBytes(string szIn, out byte aBytes) {}
// ^ NEW IN 1.60
static final native function Object LoadRandomBackgroundImage(optional string _szBackGroundSubFolder) {}
// ^ NEW IN 1.60
static final native function KMP2IOKarmaAllNativeFct(int WhatIdo, Actor _owner, optional float _var_int, optional float _var_float, optional Vector _var_vect) {}
// ^ NEW IN 1.60
final native function Error(coerce string S) {}
// ^ NEW IN 1.60
final native latent function Sleep(float Seconds) {}
// ^ NEW IN 1.60
final native function SetCollision(optional bool NewColActors, optional bool NewBlockActors, optional bool NewBlockPlayers) {}
// ^ NEW IN 1.60
final native function bool SetCollisionSize(float NewRadius, float NewHeight) {}
// ^ NEW IN 1.60
function Vector GetCollisionExtent() {}
// ^ NEW IN 1.60
final native function SetStaticMesh(StaticMesh NewStaticMesh) {}
final native function bool Move(Vector Delta) {}
// ^ NEW IN 1.60
final native function Actor Trace(out optional Material Material, optional Vector Extent, optional bool bTraceActors, optional Vector TraceStart, Vector TraceEnd, out Vector HitNormal, out Vector HitLocation) {}
// ^ NEW IN 1.60
final native function bool SetLocation(Vector NewLocation, optional bool bNoCheck) {}
// ^ NEW IN 1.60
final native function bool SetRotation(Rotator NewRotation) {}
// ^ NEW IN 1.60
//===========================================================================//
// R6FillSubAction()                                                         //
//  Small function used to fill a circumstantial action team submenu using   //
//  an action ID.                                                            //
//===========================================================================//
function R6FillSubAction(int iAction, int iSubMenu, out R6AbstractCircumstantialActionQuery Query) {}
// SetRelativeRotation() sets the rotation relative to the actor's base
final native function bool SetRelativeRotation(Rotator NewRotation) {}
// ^ NEW IN 1.60
final native function bool SetRelativeLocation(Vector NewLocation) {}
// ^ NEW IN 1.60
final native function bool MoveSmooth(Vector Delta) {}
// ^ NEW IN 1.60
final native function AutonomousPhysics(float DeltaSeconds) {}
// ^ NEW IN 1.60
final native function SetBase(Actor NewBase, optional Vector NewFloor) {}
// ^ NEW IN 1.60
final simulated function bool TouchingActor(Actor A) {}
// ^ NEW IN 1.60
function AddSoundBankName(string szBank) {}
// NearSpot() returns true is spot is within collision cylinder
final simulated function bool NearSpot(Vector Spot) {}
// ^ NEW IN 1.60
final native function SetOwner(Actor NewOwner) {}
// ^ NEW IN 1.60
final native function PlayAnim(name Sequence, optional float Rate, optional float TweenTime, optional int Channel, optional bool bBackward, optional bool bForceAnimRate) {}
// ^ NEW IN 1.60
final native function LoopAnim(name Sequence, optional float Rate, optional float TweenTime, optional int Channel, optional bool bBackward, optional bool bForceAnimRate) {}
// ^ NEW IN 1.60
// Returns the string representation of the name of an object without the package
// prefixes.
//
function string GetItemName(string FullName) {}
// ^ NEW IN 1.60
final native function TweenAnim(name Sequence, float Time, optional int Channel) {}
// ^ NEW IN 1.60
//=============================================================================
// get random number betweem a min and a max
//=============================================================================
static function float GetRandomTweenNum(out RandomTweenNum R) {}
// ^ NEW IN 1.60
final native function bool IsAnimating(optional int Channel) {}
// ^ NEW IN 1.60
final native latent function FinishAnim(optional int Channel) {}
// ^ NEW IN 1.60
final native function bool HasAnim(name Sequence) {}
// ^ NEW IN 1.60
final native function FreezeAnimAt(float Time, optional int Channel) {}
final native function bool IsTweening(int Channel) {}
// ^ NEW IN 1.60
final native function ClearChannel(int iChannel) {}
// ^ NEW IN 1.60
final native function name GetAnimGroup(name Sequence) {}
// ^ NEW IN 1.60
final native function EnableChannelNotify(int Channel, int Switch) {}
delegate ServerSendBankToLoad() {}
// Skeletal animation.
final simulated native function LinkSkelAnim(MeshAnimation Anim, optional Mesh NewMesh) {}
final simulated native function AnimBlendParams(int Stage, optional float BlendAlpha, optional float InTime, optional float OutTime, optional name BoneName) {}
final native function bool StopMusic(Sound StopMusic) {}
// ^ NEW IN 1.60
final native function AnimBlendToAlpha(int Stage, float TargetAlpha, float TimeInterval) {}
final native function float GetAnimBlendAlpha(int Stage) {}
// ^ NEW IN 1.60
final native function Rotator GetBoneRotation(name BoneName, optional int Space) {}
// ^ NEW IN 1.60
final native function bool AttachToBone(Actor Attachment, name BoneName) {}
// ^ NEW IN 1.60
final native function bool DetachFromBone(Actor Attachment) {}
// ^ NEW IN 1.60
// rbrek - 22 nov 2001
// added an argument to LockRootMotion() to allow using root motion with or without locking rotation of the root bone...
//#ifdef R6CODE
final native function LockRootMotion(int Lock, optional bool bUseRootRotation) {}
final native function SetBoneScale(int Slot, optional float BoneScale, optional name BoneName) {}
final native function SetBoneDirection(name BoneName, Rotator BoneTurn, optional Vector BoneTrans, optional float Alpha) {}
final native function SetBoneLocation(name BoneName, optional Vector BoneTrans, optional float Alpha) {}
final native function KRemoveLifterFromBone(name BoneName) {}
// You MUST turn collision off (KSetBlockKarma) before using bone lifters!
final native function KAddBoneLifter(InterpCurve Softness, float LateralFriction, InterpCurve LiftVel, name BoneName) {}
// Ragdoll-specific functions
final native function KSetSkelVel(optional bool AddToCurrent, optional Vector AngVelocity, Vector Velocity) {}
final native function bool AnimIsInGroup(int Channel, name GroupName) {}
// ^ NEW IN 1.60
final native function KEnableCollision(Actor Other) {}
// Disable/Enable Karma contact generation between this actor, and another actor.
// Collision is on by default.
final native function KDisableCollision(Actor Other) {}
// #ifdif R6CODE - rbrek - 10 oct 2001
final native function SetBoneRotation(name BoneName, optional Rotator BoneTurn, optional int Space, optional float Alpha, optional float InTime) {}
final native function KSetActorGravScale(float ActorGravScale) {}
final native function KSetBlockKarma(bool newBlock) {}
final native function KSetStayUpright(bool allowRotate, bool stayUpright) {}
final native function SetPhysics(EPhysics newPhysics) {}
// ^ NEW IN 1.60
final native function KSetImpactThreshold(float thresh) {}
final native function KGetCOMPosition(out Vector pos) {}
// ifdef WITH_KARMA
final native function KSetMass(float Mass) {}
final native function KGetCOMOffset(out Vector offset) {}
// Set inertia tensor assuming a mass of 1. Scaled by mass internally to calculate actual inertia tensor.
final native function KSetInertiaTensor(Vector it1, Vector it2) {}
final native function KGetInertiaTensor(out Vector it1, out Vector it2) {}
final native function KSetCOMOffset(Vector offset) {}
final native function KSetDampingProps(float lindamp, float angdamp) {}
final native function KSetRestitution(float rest) {}
final native function KGetDampingProps(out float lindamp, out float angdamp) {}
final native function KSetFriction(float friction) {}
final native function float KGetFriction() {}
// ^ NEW IN 1.60
final native function float KGetRestitution() {}
// ^ NEW IN 1.60
final native function float KGetMass() {}
// ^ NEW IN 1.60
final native function float KGetImpactThreshold() {}
// ^ NEW IN 1.60
final native function bool KIsAwake() {}
// ^ NEW IN 1.60
final native latent function FinishInterpolation() {}
// ^ NEW IN 1.60
final native function float KGetActorGravScale() {}
// ^ NEW IN 1.60
final native function float KGetSkelMass() {}
// ^ NEW IN 1.60
final native function KFreezeRagdoll() {}
final native function KRemoveAllBoneLifters() {}
// Used for only allowing a fixed maximum number of ragdolls in action.
final native function KMakeRagdollAvailable() {}
final native function bool KIsRagdollAvailable() {}
// ^ NEW IN 1.60
final native function Rotator GetRootRotationDelta() {}
// ^ NEW IN 1.60
final native function Vector GetRootLocationDelta() {}
// ^ NEW IN 1.60
final native function Rotator GetRootRotation() {}
// ^ NEW IN 1.60
final native function Vector GetRootLocation() {}
// ^ NEW IN 1.60
final native function bool WasSkeletonUpdated() {}
// ^ NEW IN 1.60
// event called when karma actor's velocity drops below KVelDropBelowThreshold;
event KVelDropBelow() {}
// event called when a ragdoll convulses (see KarmaParamsSkel)
event KSkelConvulse() {}
// event called just before sim to allow user to
// NOTE: you should ONLY put numbers into Force and Torque during this event!!!!
event KApplyForce(out Vector Force, out Vector Torque) {}
final native function UnLinkSkelAnim() {}
// ^ NEW IN 1.60
event GainedChild(Actor Other) {}
event LostChild(Actor Other) {}
final native function int GetNotifyChannel() {}
// ^ NEW IN 1.60
event ZoneChange(ZoneInfo NewZone) {}
event PhysicsVolumeChange(PhysicsVolume NewVolume) {}
event Detach(Actor Other) {}
event EndedRotation() {}
//#ifdef R6CODE
function SetAttachVar(Actor AttachActor, string StaticMeshTag, name PawnTag) {}
function MatineeAttach() {}
function MatineeDetach() {}
// #ifdef R6HEARTBEAT
simulated event bool ProcessHeart(out float fMul2, out float fMul1, float DeltaSeconds) {}
// ^ NEW IN 1.60
static final native function string GetMapNameExt() {}
// ^ NEW IN 1.60
static final native function GarbageCollect() {}
// ^ NEW IN 1.60
static final native function UpdateGraphicOptions() {}
// ^ NEW IN 1.60
static final native function Canvas GetCanvas() {}
// ^ NEW IN 1.60
static final native function bool IsVideoHardwareAtLeast64M() {}
// ^ NEW IN 1.60
final native function bool Destroy() {}
// ^ NEW IN 1.60
static final native function bool IsPBServerEnabled() {}
// ^ NEW IN 1.60
static final native function bool IsPBClientEnabled() {}
// ^ NEW IN 1.60
static final native function InternetInfo GetServerBeacon() {}
// ^ NEW IN 1.60
static final native function R6MissionDescription GetMissionDescription() {}
// ^ NEW IN 1.60
static final native function R6ServerInfo GetServerOptionsRefreshed() {}
// ^ NEW IN 1.60
static final native function R6ServerInfo GetServerOptions() {}
// ^ NEW IN 1.60
static final native function bool NativeNonUbiMatchMaking() {}
// ^ NEW IN 1.60
static final native function bool NativeNonUbiMatchMakingHost() {}
// ^ NEW IN 1.60
static final native function bool NativeStartedByGSClient() {}
// ^ NEW IN 1.60
static final native function int GetNbAvailableResolutions() {}
// ^ NEW IN 1.60
static final native function float GetTime() {}
// ^ NEW IN 1.60
static final native function R6GameOptions GetGameOptions() {}
// ^ NEW IN 1.60
static final native function R6ModMgr GetModMgr() {}
// ^ NEW IN 1.60
static final native function R6AbstractGameManager GetGameManager() {}
// ^ NEW IN 1.60
// Networking - called on client when actor is torn off (bTearOff==true)
event TornOff() {}
final native function bool ResetVolume_AllTypeSound() {}
// ^ NEW IN 1.60
final native function StopAllSounds() {}
// ^ NEW IN 1.60
final native function SaveCurrentFadeValue() {}
// ^ NEW IN 1.60
final native function bool PlayerCanSeeMe() {}
// ^ NEW IN 1.60
// Teleportation.
event bool PreTeleport(Teleporter InTeleporter) {}
// ^ NEW IN 1.60
event PostTeleport(Teleporter OutTeleporter) {}
final native function string GetURLMap() {}
// ^ NEW IN 1.60
final native function bool InPlanningMode() {}
// ^ NEW IN 1.60
// Called after PostBeginPlay.
//
simulated event SetInitialState() {}
// R6CODE +
simulated event SaveAndResetData() {}
// Called when carried onto a new level, before AcceptInventory.
//
event TravelPreAccept() {}
// Get localized message string associated with this actor
static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2) {}
// ^ NEW IN 1.60
function MatchStarting() {}
function string GetDebugName() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// dbgLogActor
//
//------------------------------------------------------------------
simulated function dbgLogActor(bool bVerbose) {}
function Actor R6GetRootActor() {}
// ^ NEW IN 1.60
delegate ServerForceStunResult(int iStunResult) {}
// ^ NEW IN 1.60
delegate ServerForceKillResult(int iKillResult) {}
// ^ NEW IN 1.60
//===========================================================================//
// R6ActionCanBeExecuted()                                                   //
//  Can the action be executed at this time ?                                //
//  If not, the action will be grayed out in the rose des vents.             //
//===========================================================================//
simulated function bool R6ActionCanBeExecuted(PlayerController PlayerController, int iAction) {}
// ^ NEW IN 1.60
//===========================================================================//
// R6CircumstantialActionCancel()                                            //
//  If the action it stop when the player is doing the action				 //
//===========================================================================//
function R6CircumstantialActionCancel() {}
//===========================================================================//
// R6GetCircumstantialActionProgress()                                       //
//  Once the progress bar is started, use this function to update it.        //
//  Progress should be updated using Level.TimeSeconds and the skill of the  //
//  player acting on it. Should return a number between 0 and 100            //
//===========================================================================//
function int R6GetCircumstantialActionProgress(Pawn actingPawn, R6AbstractCircumstantialActionQuery Query) {}
// ^ NEW IN 1.60
//===========================================================================//
// R6CircumstantialActionProgressStart()                                     //
//  Notify the actor that the player is starting to interact with it.        //
//===========================================================================//
function R6CircumstantialActionProgressStart(R6AbstractCircumstantialActionQuery Query) {}
//===========================================================================//
// R6GetCircumstantialActionString()                                         //
//  Translate an action ID to a string.                                      //
//===========================================================================//
simulated function string R6GetCircumstantialActionString(int iAction) {}
// ^ NEW IN 1.60

defaultproperties
{
}
