//=============================================================================
// FractalTextureFactory - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class FractalTextureFactory extends MaterialFactory;

enum EResolution
{
	Pixels_1,                       // 0
	Pixels_2,                       // 1
	Pixels_4,                       // 2
	Pixels_8,                       // 3
	Pixels_16,                      // 4
	Pixels_32,                      // 5
	Pixels_64,                      // 6
	Pixels_128,                     // 7
	Pixels_256                      // 8
};

var() FractalTextureFactory.EResolution Width;
// NEW IN 1.60
var() FractalTextureFactory.EResolution Height;

defaultproperties
{
	Width=8
	Height=8
	Description="Real-time Procedural Texture"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: var Class
// REMOVED IN 1.60: function CreateMaterial
