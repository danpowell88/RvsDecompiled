//=============================================================================
// Texture - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// Texture: An Unreal texture map.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Texture extends BitmapMaterial
	native
	noexport
	safereplace
 hidecategories(Object);

enum EEnvMapTransformType
{
	EMTT_ViewSpace,                 // 0
	EMTT_WorldSpace,                // 1
	EMTT_LightSpace                 // 2
};

enum ELODSet
{
	LODSET_None,                    // 0
	LODSET_World,                   // 1
	LODSET_Skin,                    // 2
	LODSET_Lightmap                 // 3
};

// Palette.
var() Palette Palette;
// Internal info.
var const Color MipZero;
var const Color MaxColor;
var const int InternalTime[2];
// Subtextures.
var deprecated Texture DetailTexture;  // Detail texture to apply.
var deprecated Texture EnvironmentMap;  // Environment map for this texture
// NEW IN 1.60
var deprecated Texture.EEnvMapTransformType EnvMapTransformType;
var deprecated float Specular;  // Specular lighting coefficient.
var(Surface) editconst bool bMasked;
var(Surface) bool bAlphaTexture;
var(Quality) private bool bHighColorQuality;  // High color quality hint.
var(Quality) private bool bHighTextureQuality;  // High color quality hint.
var private bool bRealtime;  // Texture changes in realtime.
var private bool bParametric;  // Texture data need not be stored.
var private transient bool bRealtimeChanged;  // Changed since last render.
var private const editconst bool bHasComp;  // !!OLDVER Whether a compressed version exists.
//#ifdef R6RASTERS
var int m_dwSize;
var int m_dwGetSizeLastFrame;
// NEW IN 1.60
var(Quality) Texture.ELODSet LODSet;
// Animation.
var(Animation) Texture AnimNext;
var transient Texture AnimCurrent;
var(Animation) byte PrimeCount;
var transient byte PrimeCurrent;
var(Animation) float MinFrameRate;
// NEW IN 1.60
var(Animation) float MaxFrameRate;
var transient float Accumulator;
// Mipmaps.
var native const array<int> Mips;
var const editconst BitmapMaterial.ETextureFormat CompFormat;  // !!OLDVER
var const transient int RenderInterface;
var const transient int __LastUpdateTime[2];

defaultproperties
{
	MipZero=(R=64,G=128,B=64,A=0)
	MaxColor=(R=255,G=255,B=255,A=255)
	LODSet=1
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var EEnvMapTransformType
// REMOVED IN 1.60: var ELODSet
// REMOVED IN 1.60: var e
