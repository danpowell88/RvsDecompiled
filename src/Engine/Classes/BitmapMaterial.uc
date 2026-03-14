//=============================================================================
// BitmapMaterial - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class BitmapMaterial extends RenderedMaterial
	abstract
	native
	collapsecategories
	noexport
 hidecategories(Object);

enum ETextureFormat
{
	TEXF_P8,                        // 0
	TEXF_RGBA7,                     // 1
	TEXF_RGB16,                     // 2
	TEXF_DXT1,                      // 3
	TEXF_RGB8,                      // 4
	TEXF_RGBA8,                     // 5
	TEXF_NODATA,                    // 6
	TEXF_DXT3,                      // 7
	TEXF_DXT5,                      // 8
	TEXF_L8,                        // 9
	TEXF_G16,                       // 10
	TEXF_RRRGGGBBB                  // 11
};

enum ETexClampMode
{
	TC_Wrap,                        // 0
	TC_Clamp                        // 1
};

// NEW IN 1.60
var(TextureFormat) const editconst BitmapMaterial.ETextureFormat Format;
// NEW IN 1.60
var(Texture) BitmapMaterial.ETexClampMode UClampMode;
// NEW IN 1.60
var(Texture) BitmapMaterial.ETexClampMode VClampMode;
var const byte UBits;
// NEW IN 1.60
var const byte VBits;
var const int USize;
// NEW IN 1.60
var const int VSize;
var(Texture) const int UClamp;
// NEW IN 1.60
var(Texture) const int VClamp;


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var ETextureFormat
// REMOVED IN 1.60: var ETexClampMode
// REMOVED IN 1.60: var s
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var p
