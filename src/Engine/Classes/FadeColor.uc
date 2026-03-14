// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class FadeColor extends ConstantMaterial
    native;

// --- Enums ---
enum EColorFadeType
{
	FC_Linear,
	FC_Sinusoidal,
};

// --- Variables ---
var Color Color1;
var Color Color2;
var float FadePeriod;
var float FadePhase;
var EColorFadeType ColorFadeType;

defaultproperties
{
}
