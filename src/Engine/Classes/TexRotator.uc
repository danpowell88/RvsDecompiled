//=============================================================================
// TexRotator - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class TexRotator extends TexModifier
	native
	editinlinenew
	collapsecategories
 hidecategories(Object,Material);

enum ETexRotationType
{
	TR_FixedRotation,               // 0
	TR_ConstantlyRotating,          // 1
	TR_OscillatingRotation          // 2
};

var() TexRotator.ETexRotationType TexRotationType;
var deprecated bool ConstantRotation;
var() float UOffset;
var() float VOffset;
var Matrix M;
var() Rotator Rotation;
var() Rotator OscillationRate;
var() Rotator OscillationAmplitude;
var() Rotator OscillationPhase;

