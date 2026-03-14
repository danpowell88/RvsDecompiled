//=============================================================================
// TexPanner - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class TexPanner extends TexModifier
	native
	editinlinenew
	collapsecategories
 hidecategories(Object,Material);

var() float PanRate;
var() Rotator PanDirection;
var Matrix M;

defaultproperties
{
	PanRate=0.1000000
}
