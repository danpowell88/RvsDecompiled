//=============================================================================
// LookTarget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// LookTarget
//
// A convenience actor that you can point a matinee camera at.
//
// Isn't bStatic so you can attach these to movers and such.
//
//=============================================================================
class LookTarget extends Keypoint
    native
    placeable;

defaultproperties
{
	bStatic=false
	bNoDelete=true
	Texture=Texture'Engine.S_LookTarget'
}
