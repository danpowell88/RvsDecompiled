//=============================================================================
// ColorModifier - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ColorModifier extends Modifier
	native
	noteditinlinenew
	collapsecategories
 hidecategories(Object,Material);

var() bool RenderTwoSided;
var() bool AlphaBlend;
var() Color Color;

defaultproperties
{
	RenderTwoSided=true
	AlphaBlend=true
	Color=(R=255,G=255,B=255,A=255)
}
