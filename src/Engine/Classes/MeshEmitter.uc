//=============================================================================
// Emitter: An Unreal Mesh Particle Emitter.
//=============================================================================
class MeshEmitter extends ParticleEmitter
    native;

// --- Variables ---
var StaticMesh StaticMesh;
var bool UseMeshBlendMode;
var bool RenderTwoSided;
var bool UseParticleColor;
var transient Vector MeshExtent;

defaultproperties
{
}
