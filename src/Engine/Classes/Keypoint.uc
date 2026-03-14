//=============================================================================
// Keypoint - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// Keypoint, the base class of invisible actors which mark things.
//=============================================================================
class Keypoint extends Actor
	abstract
	native
 placeable;

defaultproperties
{
	bStatic=true
	bHidden=true
	CollisionRadius=10.0000000
	CollisionHeight=10.0000000
	Texture=Texture'Engine.S_Keypoint'
}
