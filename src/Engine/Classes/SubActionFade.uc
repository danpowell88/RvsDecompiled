//=============================================================================
// SubActionFade - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// SubActionFade:
//
// Fades to/from a color
//=============================================================================
class SubActionFade extends MatSubAction
    native
	editinlinenew;

var(Fade) bool bFadeOut;  // If TRUE, the screen is fading out (towards the color)
var(Fade) Color FadeColor;  // The color to use for the fade

defaultproperties
{
	bFadeOut=true
	Icon=Texture'Engine.SubActionFade'
	Desc="Fade"
}
