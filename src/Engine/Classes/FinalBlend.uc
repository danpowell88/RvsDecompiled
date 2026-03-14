// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class FinalBlend extends Modifier
    native;

// --- Enums ---
enum EFrameBufferBlending
{
	FB_Overwrite,
	FB_Modulate,
	FB_AlphaBlend,
	FB_AlphaModulate_MightNotFogCorrectly,
	FB_Translucent,
	FB_Darken,
	FB_Brighten,
	FB_Invisible,
    FB_Modulate1X,
    FB_Highlight
};

// --- Variables ---
var EFrameBufferBlending FrameBufferBlending;
var bool ZWrite;
var bool ZTest;
var bool AlphaTest;
var bool TwoSided;
var byte AlphaRef;
var bool m_bAddZBias;

defaultproperties
{
}
