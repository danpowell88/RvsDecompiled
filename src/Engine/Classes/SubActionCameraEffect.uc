//=============================================================================
// SubActionCameraEffect - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class SubActionCameraEffect extends MatSubAction
    native
	editinlinenew
    collapsecategories
    noexport;

var() editinline CameraEffect CameraEffect;
var() float StartAlpha;
// NEW IN 1.60
var() float EndAlpha;
var() bool DisableAfterDuration;

defaultproperties
{
	EndAlpha=1.0000000
	Icon=Texture'Engine.SubActionFade'
	Desc="Camera effect"
}
