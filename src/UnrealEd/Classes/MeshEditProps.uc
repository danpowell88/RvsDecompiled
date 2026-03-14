//=============================================================================
// MeshEditProps - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// Object to facilitate properties editing
//=============================================================================
//  Animation / Mesh editor object to expose/shuttle only selected editable 
//  parameters from UMeshAnim/ UMesh objects back and forth in the editor.
//
class MeshEditProps extends Object
    native
    hidecategories(Object);

struct LODLevel
{
	var() float DistanceFactor;
	var() float ReductionFactor;
	var() float Hysteresis;
	var() int MaxInfluences;
	var() bool SwitchRedigest;
};

var const int WBrowserAnimationPtr;
var(Redigest) int LODStyle;  // Make drop-down box w. styles...
var(Mesh) float VisSphereRadius;
var(LOD) float LOD_Strength;
var(Animation) MeshAnimation DefaultAnimation;
var(Skin) array<Material> Material;
var(LOD) array<LODLevel> LODLevels;
var(Mesh) Vector Scale;
var(Mesh) Vector Translation;
var(Mesh) Rotator Rotation;
var(Mesh) Vector MinVisBound;
var(Mesh) Vector MaxVisBound;
var(Mesh) Vector VisSphereCenter;

defaultproperties
{
	Scale=(X=1.0000000,Y=1.0000000,Z=1.0000000)
}
