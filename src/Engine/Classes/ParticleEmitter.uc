//=============================================================================
// ParticleEmitter: Base class for sub- emitters.
//
// make sure to keep structs in sync in UnParticleSystem.h
//=============================================================================
class ParticleEmitter extends Object
    native
    abstract;

// --- Enums ---
enum EParticleCollisionSound
{
	PTSC_None,
	PTSC_LinearGlobal,
	PTSC_LinearLocal,
	PTSC_Random
};
enum EParticleEffectAxis
{
	PTEA_NegativeX,
	PTEA_PositiveZ
};
enum EParticleStartLocationShape
{
	PTLS_Box,
	PTLS_Sphere,
	PTLS_Polar
};
enum EParticleVelocityDirection
{
	PTVD_None,
	PTVD_StartPositionAndOwner,
	PTVD_OwnerAndStartPosition,
	PTVD_AddRadial
};
enum EParticleRotationSource
{
	PTRS_None,
	PTRS_Actor,
	PTRS_Offset,
	PTRS_Normal
};
enum EParticleCoordinateSystem
{
	PTCS_Independent,
	PTCS_Relative,
	PTCS_Absolute
};
enum EParticleDrawStyle
{
	PTDS_Regular,
	PTDS_AlphaBlend,
	PTDS_Modulated,
	PTDS_Translucent,
	PTDS_AlphaModulate_MightNotFogCorrectly,
	PTDS_Darken,
	PTDS_Brighten
};
enum EBlendMode
{
	BM_MODULATE,
	BM_MODULATE2X,
	BM_MODULATE4X,
	BM_ADD,
	BM_ADDSIGNED,
	BM_ADDSIGNED2X,
	BM_SUBTRACT,
	BM_ADDSMOOTH,
	BM_BLENDDIFFUSEALPHA,
	BM_BLENDTEXTUREALPHA,
	BM_BLENDFACTORALPHA,
	BM_BLENDTEXTUREALPHAPM,
	BM_BLENDCURRENTALPHA,
	BM_PREMODULATE,
	BM_MODULATEALPHA_ADDCOLOR,
	BM_MODULATEINVALPHA_ADDCOLOR,
	BM_MODULATEINVCOLOR_ADDALPHA,
	BM_HACK	
};

// --- Structs ---
struct ParticleSound
{
	var () sound	Sound;
	var () range	Radius;
	var () range	Pitch;
	var () int		Weight;
	var () range	Volume;
	var () range	Probability;
};

struct Particle
{
	var vector	Location;
	var vector	OldLocation;
	var vector	Velocity;
	var vector	StartSize;
	var vector	SpinsPerSecond;
	var vector	StartSpin;
	var vector	Size;
	var vector  StartLocation;
	var vector  ColorMultiplier;
	var color   Color;
	var float	Time;
	var float	MaxLifetime;
	var float	Mass;
	var int		HitCount;
	var int		Flags;
	var int		Subdivision;
//R6JFD
var float   m_fMinZ;
};

struct ParticleColorScale
{
	var () float	RelativeTime;		// always in range [0..1]
	var () color	Color;
};

struct ParticleTimeScale
{
	var () float	RelativeTime;		// always in range [0..1]
	var () float	RelativeSize;
};

// --- Variables ---
// var ? Color; // REMOVED IN 1.60
// var ? ColorMultiplier; // REMOVED IN 1.60
// var ? Flags; // REMOVED IN 1.60
// var ? HitCount; // REMOVED IN 1.60
// var ? Location; // REMOVED IN 1.60
// var ? Mass; // REMOVED IN 1.60
// var ? MaxLifetime; // REMOVED IN 1.60
// var ? OldLocation; // REMOVED IN 1.60
// var ? Pitch; // REMOVED IN 1.60
// var ? Probability; // REMOVED IN 1.60
// var ? Radius; // REMOVED IN 1.60
// var ? RelativeSize; // REMOVED IN 1.60
// var ? RelativeTime; // REMOVED IN 1.60
// var ? Size; // REMOVED IN 1.60
// var ? Sound; // REMOVED IN 1.60
// var ? SpinsPerSecond; // REMOVED IN 1.60
// var ? StartLocation; // REMOVED IN 1.60
// var ? StartSize; // REMOVED IN 1.60
// var ? StartSpin; // REMOVED IN 1.60
// var ? Subdivision; // REMOVED IN 1.60
// var ? Time; // REMOVED IN 1.60
// var ? Velocity; // REMOVED IN 1.60
// var ? Volume; // REMOVED IN 1.60
// var ? Weight; // REMOVED IN 1.60
// var ? m_fMinZ; // REMOVED IN 1.60
var int m_iPaused;
var transient bool AllParticlesDead;
var bool Disabled;
var Vector Acceleration;
var bool UseCollision;
var Vector ExtentMultiplier;
var RangeVector DampingFactorRange;
var bool UseCollisionPlanes;
var array<array> CollisionPlanes;
var bool UseMaxCollisions;
var Range MaxCollisions;
var int SpawnFromOtherEmitter;
var int SpawnAmount;
var RangeVector SpawnedVelocityScaleRange;
var bool UseSpawnedVelocityScale;
var EParticleCollisionSound CollisionSound;
var Range CollisionSoundIndex;
var Range CollisionSoundProbability;
var array<array> Sounds;
var bool UseColorScale;
var array<array> ColorScale;
var float ColorScaleRepeats;
var RangeVector ColorMultiplierRange;
var Plane FadeOutFactor;
var float FadeOutStartTime;
var bool FadeOut;
var Plane FadeInFactor;
var float FadeInEndTime;
var bool FadeIn;
var bool UseActorForces;
var EParticleCoordinateSystem CoordinateSystem;
var const int MaxParticles;
var bool ResetAfterChange;
var EParticleEffectAxis EffectAxis;
var bool RespawnDeadParticles;
var bool AutoDestroy;
var bool AutoReset;
var bool DisableFogging;
var Range AutoResetTimeRange;
var string Name;
var Vector StartLocationOffset;
var RangeVector StartLocationRange;
var int AddLocationFromOtherEmitter;
var EParticleStartLocationShape StartLocationShape;
var Range SphereRadiusRange;
var RangeVector StartLocationPolarRange;
var Range StartMassRange;
var int AlphaRef;
var bool AlphaTest;
var bool AcceptsProjectors;
var bool ZTest;
var bool ZWrite;
var EParticleRotationSource UseRotationFrom;
var bool SpinParticles;
var Rotator RotationOffset;
var Vector SpinCCWorCW;
var RangeVector SpinsPerSecondRange;
var RangeVector StartSpinRange;
var bool DampRotation;
var RangeVector RotationDampingFactorRange;
var Vector RotationNormal;
var bool UseSizeScale;
var bool UseRegularSizeScale;
var array<array> SizeScale;
var float SizeScaleRepeats;
var RangeVector StartSizeRange;
var bool UniformSize;
var float ParticlesPerSecond;
var float InitialParticlesPerSecond;
var bool AutomaticInitialSpawning;
var EParticleDrawStyle DrawStyle;
var Texture Texture;
var int TextureUSubdivisions;
var int TextureVSubdivisions;
var bool BlendBetweenSubdivisions;
var bool UseSubdivisionScale;
var array<array> SubdivisionScale;
var int SubdivisionStart;
var int SubdivisionEnd;
var bool UseRandomSubdivision;
var float SecondsBeforeInactive;
var float MinSquaredVelocity;
var Range InitialTimeRange;
var Range LifetimeRange;
var Range InitialDelayRange;
var RangeVector StartVelocityRange;
var Range StartVelocityRadialRange;
var Vector MaxAbsVelocity;
var RangeVector VelocityLossRange;
var int AddVelocityFromOtherEmitter;
var RangeVector AddVelocityMultiplierRange;
var EParticleVelocityDirection GetVelocityDirectionFrom;
var float WarmupTicksPerSecond;
var float RelativeWarmupTime;
var transient Emitter Owner;
var transient bool Initialized;
var transient bool Inactive;
var transient float InactiveTime;
var transient array<array> Particles;
// index into circular list of particles
var transient int ParticleIndex;
// currently active particles
var transient int ActiveParticles;
// used to keep track of fractional PPTick
var transient float PPSFraction;
var transient Box BoundingBox;
var transient Vector RealExtentMultiplier;
var transient bool RealDisableFogging;
var transient bool WarmedUp;
var transient int OtherIndex;
var transient float InitialDelay;
var transient Vector GlobalOffset;
var transient float TimeTillReset;
var transient int PS2Data;
var transient int MaxActiveParticles;
var transient int CurrentCollisionSoundIndex;
var transient float MaxSizeScale;
var transient int KillPending;
//R6JFD
var int m_iUseFastZCollision;

// --- Functions ---
native function SpawnParticle(int Amount) {}

defaultproperties
{
}
