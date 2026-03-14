//=============================================================================
// Shader - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class Shader extends RenderedMaterial
    native
	editinlinenew
    collapsecategories
    hidecategories(Object);

enum EOutputBlending
{
	OB_Normal,                      // 0
	OB_Masked,                      // 1
	OB_Modulate,                    // 2
	OB_Translucent,                 // 3
	OB_Invisible,                   // 4
	OB_Brighten,                    // 5
	OB_Darken                       // 6
};

// NEW IN 1.60
var() Shader.EOutputBlending OutputBlending;
var() bool TwoSided;
var() bool Wireframe;
var bool ModulateStaticLighting2X;
var() bool PerformLightingOnSpecularPass;
var() editinlineuse Material Diffuse;
var() editinlineuse Material Opacity;
var() editinlineuse Material Specular;
var() editinlineuse Material SpecularityMask;
var() editinlineuse Material SelfIllumination;
var() editinlineuse Material SelfIlluminationMask;
var() editinlineuse Material Detail;

function Trigger(Actor Other, Actor EventInstigator)
{
	// End:0x24
	if(__NFUN_119__(Diffuse, none))
	{
		Diffuse.Trigger(Other, EventInstigator);
	}
	// End:0x48
	if(__NFUN_119__(Opacity, none))
	{
		Opacity.Trigger(Other, EventInstigator);
	}
	// End:0x6C
	if(__NFUN_119__(Specular, none))
	{
		Specular.Trigger(Other, EventInstigator);
	}
	// End:0x90
	if(__NFUN_119__(SpecularityMask, none))
	{
		SpecularityMask.Trigger(Other, EventInstigator);
	}
	// End:0xB4
	if(__NFUN_119__(SelfIllumination, none))
	{
		SelfIllumination.Trigger(Other, EventInstigator);
	}
	// End:0xD8
	if(__NFUN_119__(SelfIlluminationMask, none))
	{
		SelfIlluminationMask.Trigger(Other, EventInstigator);
	}
	// End:0xFC
	if(__NFUN_119__(FallbackMaterial, none))
	{
		FallbackMaterial.Trigger(Other, EventInstigator);
	}
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var EOutputBlending
