//=============================================================================
// Emitter: An Unreal Spark Particle Emitter.
//=============================================================================
class SparkEmitter extends ParticleEmitter
    native;

// --- Structs ---
struct ParticleSparkData
{
	var	float	TimeBeforeVisible;
	var float	TimeBetweenSegments;
	var vector	StartLocation;
	var vector	StartVelocity;
};

// --- Variables ---
// var ? StartLocation; // REMOVED IN 1.60
// var ? StartVelocity; // REMOVED IN 1.60
// var ? TimeBeforeVisible; // REMOVED IN 1.60
// var ? TimeBetweenSegments; // REMOVED IN 1.60
var Range LineSegmentsRange;
var Range TimeBeforeVisibleRange;
var Range TimeBetweenSegmentsRange;
var transient array<array> SparkData;
var transient VertexBuffer VertexBuffer;
var transient IndexBuffer IndexBuffer;
var transient int NumSegments;
var transient int VerticesPerParticle;
var transient int IndicesPerParticle;
var transient int PrimitivesPerParticle;

defaultproperties
{
}
