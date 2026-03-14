//=============================================================================
// FadeColor - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class FadeColor extends ConstantMaterial
    native
	editinlinenew
    collapsecategories
    hidecategories(Object);

enum EColorFadeType
{
	FC_Linear,                      // 0
	FC_Sinusoidal                   // 1
};

var() FadeColor.EColorFadeType ColorFadeType;
var() float FadePeriod;
var() float FadePhase;
var() Color Color1;
var() Color Color2;

