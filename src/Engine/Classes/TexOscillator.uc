// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class TexOscillator extends TexModifier
    native;

// --- Enums ---
enum ETexOscillationType
{
	OT_Pan,
	OT_Stretch,
	OT_StretchRepeat
};

// --- Variables ---
var float UOscillationRate;
// ^ NEW IN 1.60
var float VOscillationRate;
// ^ NEW IN 1.60
var float UOscillationPhase;
// ^ NEW IN 1.60
var float VOscillationPhase;
// ^ NEW IN 1.60
var float UOscillationAmplitude;
// ^ NEW IN 1.60
var float VOscillationAmplitude;
// ^ NEW IN 1.60
var ETexOscillationType UOscillationType;
// ^ NEW IN 1.60
var ETexOscillationType VOscillationType;
// ^ NEW IN 1.60
var float UOffset;
// ^ NEW IN 1.60
var float VOffset;
// ^ NEW IN 1.60
var Matrix M;

defaultproperties
{
}
