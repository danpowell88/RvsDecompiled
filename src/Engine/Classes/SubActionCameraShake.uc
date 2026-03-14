//=============================================================================
// SubActionCameraShake - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// SubActionCameraShake:
//
// Shakes the camera randomly.
//=============================================================================
class SubActionCameraShake extends MatSubAction
	native
	editinlinenew;

var(Shake) RangeVector Shake;

defaultproperties
{
	Icon=Texture'Engine.SubActionCameraShake'
	Desc="Shake"
}
