//=============================================================================
// MotionBlur - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class MotionBlur extends CameraEffect
    native
	editinlinenew
    collapsecategories
    noexport;

var() byte BlurAlpha;
var const int RenderTargets[2];
var const float LastFrameTime;

defaultproperties
{
	BlurAlpha=128
}
