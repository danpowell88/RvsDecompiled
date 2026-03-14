//=============================================================================
// TexOscillator - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class TexOscillator extends TexModifier
	native
	editinlinenew
	collapsecategories
 hidecategories(Object,Material);

enum ETexOscillationType
{
	OT_Pan,                         // 0
	OT_Stretch,                     // 1
	OT_StretchRepeat                // 2
};

var() TexOscillator.ETexOscillationType UOscillationType;
var() TexOscillator.ETexOscillationType VOscillationType;
var() float UOscillationRate;
var() float VOscillationRate;
var() float UOscillationPhase;
var() float VOscillationPhase;
var() float UOscillationAmplitude;
var() float VOscillationAmplitude;
var() float UOffset;
var() float VOffset;
var Matrix M;

defaultproperties
{
	UOscillationRate=1.0000000
	VOscillationRate=1.0000000
	UOscillationAmplitude=0.1000000
	VOscillationAmplitude=0.1000000
}
