//=============================================================================
// BeamEmitter - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// BeamEmitter: An Unreal Beam Particle Emitter.
//=============================================================================
class BeamEmitter extends ParticleEmitter
    native
	editinlinenew;

enum EBeamEndPointType
{
	PTEP_Velocity,                  // 0
	PTEP_Distance,                  // 1
	PTEP_Offset,                    // 2
	PTEP_Actor,                     // 3
	PTEP_TraceOffset,               // 4
	PTEP_OffsetAsAbsolute           // 5
};

struct ParticleBeamData
{
	var Vector Location;
	var float t;
};

struct ParticleBeamEndPoint
{
	var() name ActorTag;
	var() RangeVector offset;
	var() float Weight;
};

struct ParticleBeamScale
{
	var() Vector FrequencyScale;
	var() float RelativeLength;
};

var(Beam) BeamEmitter.EBeamEndPointType DetermineEndPointBy;
var(Beam) int RotatingSheets;
var(BeamNoise) int LowFrequencyPoints;
var(BeamNoise) int HighFrequencyPoints;
var(BeamBranching) int BranchEmitter;
var(BeamNoise) bool UseHighFrequencyScale;
var(BeamNoise) bool UseLowFrequencyScale;
var(BeamNoise) bool NoiseDeterminesEndPoint;
var(BeamBranching) bool UseBranching;
var(BeamBranching) bool LinkupLifetime;
var(Beam) float BeamTextureUScale;
var(Beam) float BeamTextureVScale;
var(BeamNoise) float LFScaleRepeats;
var(BeamNoise) float HFScaleRepeats;
var(Beam) array<ParticleBeamEndPoint> BeamEndPoints;
var(BeamNoise) array<ParticleBeamScale> LFScaleFactors;
var(BeamNoise) array<ParticleBeamScale> HFScaleFactors;
var(Beam) Range BeamDistanceRange;
var(BeamNoise) RangeVector LowFrequencyNoiseRange;
var(BeamNoise) RangeVector HighFrequencyNoiseRange;
var(BeamBranching) Range BranchProbability;
var(BeamBranching) Range BranchSpawnAmountRange;
var transient int SheetsUsed;
var transient int VerticesPerParticle;
var transient int IndicesPerParticle;
var transient int PrimitivesPerParticle;
var transient float BeamValueSum;
var transient array<ParticleBeamData> HFPoints;
var transient array<Vector> LFPoints;
var transient array<Actor> HitActors;

defaultproperties
{
	LowFrequencyPoints=3
	HighFrequencyPoints=10
	BranchEmitter=-1
	BeamTextureUScale=1.0000000
	BeamTextureVScale=1.0000000
}
