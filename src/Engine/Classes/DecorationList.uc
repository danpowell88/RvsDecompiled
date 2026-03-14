//=============================================================================
// DecorationList - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// DecorationList:  Defines a list of decorations which can be attached to volumes
//=============================================================================
class DecorationList extends Keypoint
	native
 placeable;

struct DecorationType
{
	var() StaticMesh StaticMesh;
	var() Range Count;
	var() Range DrawScale;
	var() int bAlign;
	var() int bRandomPitch;
	var() int bRandomYaw;
	var() int bRandomRoll;
};

var(List) array<DecorationType> Decorations;

defaultproperties
{
	Texture=Texture'Engine.S_DecorationList'
}
