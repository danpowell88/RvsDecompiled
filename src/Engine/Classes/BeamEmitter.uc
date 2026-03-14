//=============================================================================
// BeamEmitter: An Unreal Beam Particle Emitter.
//=============================================================================
class BeamEmitter extends ParticleEmitter
    native;

// --- Enums ---
enum EBeamEndPointType
{
	PTEP_Velocity,
	PTEP_Distance,
	PTEP_Offset,
	PTEP_Actor,
	PTEP_TraceOffset,
	PTEP_OffsetAsAbsolute
};

// --- Structs ---
struct ParticleBeamScale
{
	var () vector		FrequencyScale;
	var () float		RelativeLength;
};

struct ParticleBeamEndPoint
{
	var () name			ActorTag;
	var () rangevector	Offset;
	var () float		Weight;
};

struct ParticleBeamData
{
	var vector	Location;
	var float	t;
};

// --- Variables ---
// var ? ActorTag; // REMOVED IN 1.60
// var ? FrequencyScale; // REMOVED IN 1.60
// var ? Location; // REMOVED IN 1.60
// var ? Offset; // REMOVED IN 1.60
// var ? RelativeLength; // REMOVED IN 1.60
// var ? Weight; // REMOVED IN 1.60
// var ? t; // REMOVED IN 1.60
var Range BeamDistanceRange;
var array<array> BeamEndPoints;
var EBeamEndPointType DetermineEndPointBy;
var float BeamTextureUScale;
var float BeamTextureVScale;
var int RotatingSheets;
var RangeVector LowFrequencyNoiseRange;
var int LowFrequencyPoints;
var RangeVector HighFrequencyNoiseRange;
var int HighFrequencyPoints;
var array<array> LFScaleFactors;
var array<array> HFScaleFactors;
var float LFScaleRepeats;
var float HFScaleRepeats;
var bool UseHighFrequencyScale;
var bool UseLowFrequencyScale;
var bool NoiseDeterminesEndPoint;
var bool UseBranching;
var Range BranchProbability;
var int BranchEmitter;
var Range BranchSpawnAmountRange;
var bool LinkupLifetime;
var transient int SheetsUsed;
var transient int VerticesPerParticle;
var transient int IndicesPerParticle;
var transient int PrimitivesPerParticle;
var transient float BeamValueSum;
var transient array<array> HFPoints;
var transient array<array> LFPoints;
var transient array<array> HitActors;

defaultproperties
{
}
