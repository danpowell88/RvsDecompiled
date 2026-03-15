//=============================================================================
// MeshEmitter - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// Emitter: An Unreal Mesh Particle Emitter.
//=============================================================================
class MeshEmitter extends ParticleEmitter
    native
	editinlinenew;

var(Mesh) bool UseMeshBlendMode;
var(Mesh) bool RenderTwoSided;
var(Mesh) bool UseParticleColor;
var(Mesh) StaticMesh StaticMesh;
var transient Vector MeshExtent;

defaultproperties
{
	UseMeshBlendMode=true
	StartSizeRange=(X=(Min=1.0000000,Max=1.0000000),Y=(Min=1.0000000,Max=1.0000000),Z=(Min=1.0000000,Max=1.0000000))
}
