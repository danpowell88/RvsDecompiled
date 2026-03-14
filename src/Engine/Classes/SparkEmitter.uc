//=============================================================================
// SparkEmitter - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// Emitter: An Unreal Spark Particle Emitter.
//=============================================================================
class SparkEmitter extends ParticleEmitter
    native
	editinlinenew;

struct ParticleSparkData
{
	var float TimeBeforeVisible;
	var float TimeBetweenSegments;
	var Vector StartLocation;
	var Vector StartVelocity;
};

var(Spark) Range LineSegmentsRange;
var(Spark) Range TimeBeforeVisibleRange;
var(Spark) Range TimeBetweenSegmentsRange;
var transient int NumSegments;
var transient int VerticesPerParticle;
var transient int IndicesPerParticle;
var transient int PrimitivesPerParticle;
var transient VertexBuffer VertexBuffer;
var transient IndexBuffer IndexBuffer;
var transient array<ParticleSparkData> SparkData;

defaultproperties
{
	LineSegmentsRange=(Min=5.0000000,Max=5.0000000)
}
