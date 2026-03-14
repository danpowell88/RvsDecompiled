//=============================================================================
// ParticleEmitter - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// ParticleEmitter: Base class for sub- emitters.
//
// make sure to keep structs in sync in UnParticleSystem.h
//=============================================================================
class ParticleEmitter extends Object
    abstract
    native
	editinlinenew;

enum EBlendMode
{
	BM_MODULATE,                    // 0
	BM_MODULATE2X,                  // 1
	BM_MODULATE4X,                  // 2
	BM_ADD,                         // 3
	BM_ADDSIGNED,                   // 4
	BM_ADDSIGNED2X,                 // 5
	BM_SUBTRACT,                    // 6
	BM_ADDSMOOTH,                   // 7
	BM_BLENDDIFFUSEALPHA,           // 8
	BM_BLENDTEXTUREALPHA,           // 9
	BM_BLENDFACTORALPHA,            // 10
	BM_BLENDTEXTUREALPHAPM,         // 11
	BM_BLENDCURRENTALPHA,           // 12
	BM_PREMODULATE,                 // 13
	BM_MODULATEALPHA_ADDCOLOR,      // 14
	BM_MODULATEINVALPHA_ADDCOLOR,   // 15
	BM_MODULATEINVCOLOR_ADDALPHA,   // 16
	BM_HACK                         // 17
};

enum EParticleDrawStyle
{
	PTDS_Regular,                   // 0
	PTDS_AlphaBlend,                // 1
	PTDS_Modulated,                 // 2
	PTDS_Translucent,               // 3
	PTDS_AlphaModulate_MightNotFogCorrectly,// 4
	PTDS_Darken,                    // 5
	PTDS_Brighten                   // 6
};

enum EParticleCoordinateSystem
{
	PTCS_Independent,               // 0
	PTCS_Relative,                  // 1
	PTCS_Absolute                   // 2
};

enum EParticleRotationSource
{
	PTRS_None,                      // 0
	PTRS_Actor,                     // 1
	PTRS_Offset,                    // 2
	PTRS_Normal                     // 3
};

enum EParticleVelocityDirection
{
	PTVD_None,                      // 0
	PTVD_StartPositionAndOwner,     // 1
	PTVD_OwnerAndStartPosition,     // 2
	PTVD_AddRadial                  // 3
};

enum EParticleStartLocationShape
{
	PTLS_Box,                       // 0
	PTLS_Sphere,                    // 1
	PTLS_Polar                      // 2
};

enum EParticleEffectAxis
{
	PTEA_NegativeX,                 // 0
	PTEA_PositiveZ                  // 1
};

enum EParticleCollisionSound
{
	PTSC_None,                      // 0
	PTSC_LinearGlobal,              // 1
	PTSC_LinearLocal,               // 2
	PTSC_Random                     // 3
};

struct ParticleTimeScale
{
	var() float RelativeTime;  // always in range [0..1]
	var() float RelativeSize;
};

struct ParticleColorScale
{
	var() float RelativeTime;  // always in range [0..1]
	var() Color Color;
};

struct Particle
{
	var Vector Location;
	var Vector OldLocation;
	var Vector Velocity;
	var Vector StartSize;
	var Vector SpinsPerSecond;
	var Vector StartSpin;
	var Vector Size;
	var Vector StartLocation;
	var Vector ColorMultiplier;
	var Color Color;
	var float Time;
	var float MaxLifetime;
	var float Mass;
	var int HitCount;
	var int Flags;
	var int Subdivision;
//R6JFD
	var float m_fMinZ;
};

struct ParticleSound
{
	var() Sound Sound;
	var() Range Radius;
	var() Range Pitch;
	var() int Weight;
	var() Range Volume;
	var() Range Probability;
};

var(Collision) ParticleEmitter.EParticleCollisionSound CollisionSound;
var(General) ParticleEmitter.EParticleCoordinateSystem CoordinateSystem;
var(General) ParticleEmitter.EParticleEffectAxis EffectAxis;
var(Location) ParticleEmitter.EParticleStartLocationShape StartLocationShape;
var(Rotation) ParticleEmitter.EParticleRotationSource UseRotationFrom;
var(Texture) ParticleEmitter.EParticleDrawStyle DrawStyle;
var(Velocity) ParticleEmitter.EParticleVelocityDirection GetVelocityDirectionFrom;
var(Collision) int SpawnFromOtherEmitter;
var(Collision) int SpawnAmount;
var(General) const int MaxParticles;
var(Location) int AddLocationFromOtherEmitter;
var(Rendering) int AlphaRef;
var(Texture) int TextureUSubdivisions;
var(Texture) int TextureVSubdivisions;
var(Texture) int SubdivisionStart;
var(Texture) int SubdivisionEnd;
var(Velocity) int AddVelocityFromOtherEmitter;
//R6JFD
var(R6Misc) int m_iUseFastZCollision;
var(R6Misc) int m_iPaused;
var(Collision) bool UseCollision;
var(Collision) bool UseCollisionPlanes;
var(Collision) bool UseMaxCollisions;
var(Collision) bool UseSpawnedVelocityScale;
var(Color) bool UseColorScale;
var(Fading) bool FadeOut;
var(Fading) bool FadeIn;
var(Force) bool UseActorForces;
var(General) bool ResetAfterChange;
var(Local) bool RespawnDeadParticles;
var(Local) bool AutoDestroy;
var(Local) bool AutoReset;
var(Local) bool Disabled;
var(Local) bool DisableFogging;
var(Rendering) bool AlphaTest;
var(Rendering) bool AcceptsProjectors;
var(Rendering) bool ZTest;
var(Rendering) bool ZWrite;
var(Rotation) bool SpinParticles;
var(Rotation) bool DampRotation;
var(Size) bool UseSizeScale;
var(Size) bool UseRegularSizeScale;
var(Size) bool UniformSize;
var(Spawning) bool AutomaticInitialSpawning;
var(Texture) bool BlendBetweenSubdivisions;
var(Texture) bool UseSubdivisionScale;
var(Texture) bool UseRandomSubdivision;
var(Color) float ColorScaleRepeats;
var(Fading) float FadeOutStartTime;
var(Fading) float FadeInEndTime;
var(Size) float SizeScaleRepeats;
var(Spawning) float ParticlesPerSecond;
var(Spawning) float InitialParticlesPerSecond;
var(Tick) float SecondsBeforeInactive;
var(Tick) float MinSquaredVelocity;
var(Warmup) float WarmupTicksPerSecond;
var(Warmup) float RelativeWarmupTime;
var(Texture) Texture Texture;
var(Collision) array<Plane> CollisionPlanes;
var(Sound) array<ParticleSound> Sounds;
var(Color) array<ParticleColorScale> ColorScale;
var(Size) array<ParticleTimeScale> SizeScale;
var(Texture) array<float> SubdivisionScale;
var(Acceleration) Vector Acceleration;
var(Collision) Vector ExtentMultiplier;
var(Collision) RangeVector DampingFactorRange;
var(Collision) Range MaxCollisions;
var(Collision) RangeVector SpawnedVelocityScaleRange;
var(Collision) Range CollisionSoundIndex;
var(Collision) Range CollisionSoundProbability;
var(Color) RangeVector ColorMultiplierRange;
var(Fading) Plane FadeOutFactor;
var(Fading) Plane FadeInFactor;
var(Local) Range AutoResetTimeRange;
var(Location) Vector StartLocationOffset;
var(Location) RangeVector StartLocationRange;
var(Location) Range SphereRadiusRange;
var(Location) RangeVector StartLocationPolarRange;
var(Mass) Range StartMassRange;
var(Rotation) Rotator RotationOffset;
var(Rotation) Vector SpinCCWorCW;
var(Rotation) RangeVector SpinsPerSecondRange;
var(Rotation) RangeVector StartSpinRange;
var(Rotation) RangeVector RotationDampingFactorRange;
var(Rotation) Vector RotationNormal;
var(Size) RangeVector StartSizeRange;
var(Time) Range InitialTimeRange;
var(Time) Range LifetimeRange;
var(Time) Range InitialDelayRange;
var(Velocity) RangeVector StartVelocityRange;
var(Velocity) Range StartVelocityRadialRange;
var(Velocity) Vector MaxAbsVelocity;
var(Velocity) RangeVector VelocityLossRange;
var(Velocity) RangeVector AddVelocityMultiplierRange;
var(Local) string Name;
var transient int ParticleIndex;  // index into circular list of particles
var transient int ActiveParticles;  // currently active particles
var transient int OtherIndex;
var transient int PS2Data;
var transient int MaxActiveParticles;
var transient int CurrentCollisionSoundIndex;
var transient int KillPending;
var transient bool Initialized;
var transient bool Inactive;
var transient bool RealDisableFogging;
var transient bool AllParticlesDead;
var transient bool WarmedUp;
var transient float InactiveTime;
var transient float PPSFraction;  // used to keep track of fractional PPTick
var transient float InitialDelay;
var transient float TimeTillReset;
var transient float MaxSizeScale;
var transient Emitter Owner;
var transient array<Particle> Particles;
var transient Box BoundingBox;
var transient Vector RealExtentMultiplier;
var transient Vector GlobalOffset;

// Export UParticleEmitter::execSpawnParticle(FFrame&, void* const)
native function SpawnParticle(int Amount);

defaultproperties
{
	DrawStyle=3
	SpawnFromOtherEmitter=-1
	MaxParticles=10
	AddLocationFromOtherEmitter=-1
	AddVelocityFromOtherEmitter=-1
	RespawnDeadParticles=true
	AlphaTest=true
	ZTest=true
	UseRegularSizeScale=true
	AutomaticInitialSpawning=true
	SecondsBeforeInactive=1.0000000
	Texture=Texture'Engine.S_Emitter'
	ExtentMultiplier=(X=1.0000000,Y=1.0000000,Z=1.0000000)
	DampingFactorRange=(X=(Min=1.0000000,Max=1.0000000),Y=(Min=1.0000000,Max=1.0000000),Z=(Min=1.0000000,Max=1.0000000))
	ColorMultiplierRange=(X=(Min=1.0000000,Max=1.0000000),Y=(Min=1.0000000,Max=1.0000000),Z=(Min=1.0000000,Max=1.0000000))
	FadeOutFactor=(W=1.0000000,X=1.0000000,Y=1.0000000,Z=1.0000000)
	FadeInFactor=(W=1.0000000,X=1.0000000,Y=1.0000000,Z=1.0000000)
	StartMassRange=(Min=1.0000000,Max=1.0000000)
	SpinCCWorCW=(X=0.5000000,Y=0.5000000,Z=0.5000000)
	StartSizeRange=(X=(Min=100.0000000,Max=100.0000000),Y=(Min=100.0000000,Max=100.0000000),Z=(Min=100.0000000,Max=100.0000000))
	LifetimeRange=(Min=4.0000000,Max=4.0000000)
	AddVelocityMultiplierRange=(X=(Min=1.0000000,Max=1.0000000),Y=(Min=1.0000000,Max=1.0000000),Z=(Min=1.0000000,Max=1.0000000))
}
