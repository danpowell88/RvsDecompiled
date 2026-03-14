// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class Shader extends RenderedMaterial
    native;

// --- Enums ---
enum EOutputBlending
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
var Material SelfIlluminationMask;
// ^ NEW IN 1.60
var Material SelfIllumination;
// ^ NEW IN 1.60
var Material SpecularityMask;
// ^ NEW IN 1.60
var Material Specular;
// ^ NEW IN 1.60
var Material Opacity;
// ^ NEW IN 1.60
var Material Diffuse;
// ^ NEW IN 1.60
var Material Detail;
// ^ NEW IN 1.60
var EOutputBlending OutputBlending;
// ^ NEW IN 1.60
var bool TwoSided;
// ^ NEW IN 1.60
var bool Wireframe;
// ^ NEW IN 1.60
var bool ModulateStaticLighting2X;
var bool PerformLightingOnSpecularPass;
// ^ NEW IN 1.60

// --- Functions ---
function Trigger(Actor EventInstigator, Actor Other) {}

defaultproperties
{
}
