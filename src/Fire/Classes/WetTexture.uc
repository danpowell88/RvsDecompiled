//=============================================================================
// WetTexture - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// WetTexture: Water amplitude used as displacement.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class WetTexture extends WaterTexture
	native
	noexport
	safereplace
 hidecategories(Object);

var(WaterPaint) Texture SourceTexture;
var transient Texture OldSourceTex;
var transient int LocalSourceBitmap;

