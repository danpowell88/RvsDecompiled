// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class TexRotator extends TexModifier
    native;

// --- Enums ---
enum ETexRotationType
{
	TR_FixedRotation,
	TR_ConstantlyRotating,
	TR_OscillatingRotation,
};

// --- Variables ---
var Matrix M;
var ETexRotationType TexRotationType;
// ^ NEW IN 1.60
var Rotator Rotation;
// ^ NEW IN 1.60
var bool ConstantRotation;
var float UOffset;
// ^ NEW IN 1.60
var float VOffset;
// ^ NEW IN 1.60
var Rotator OscillationRate;
// ^ NEW IN 1.60
var Rotator OscillationAmplitude;
// ^ NEW IN 1.60
var Rotator OscillationPhase;
// ^ NEW IN 1.60

defaultproperties
{
}
