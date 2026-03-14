//=============================================================================
// Texture: An Unreal texture map.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Texture extends BitmapMaterial
    native
    safereplace
    noexport;

// --- Enums ---
enum EEnvMapTransformType
{
    // enum values not recoverable from binary — see 1.56 source
};
enum ELODSet
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
var transient const int __LastUpdateTime[2];
var transient const int RenderInterface;
//!!OLDVER
var const editconst ETextureFormat CompFormat;
// Mipmaps.
var native const array<int> Mips;
var transient float Accumulator;
var float MaxFrameRate;
// ^ NEW IN 1.60
var float MinFrameRate;
// ^ NEW IN 1.60
var transient byte PrimeCurrent;
var byte PrimeCount;
// ^ NEW IN 1.60
// Animation.
var transient Texture AnimCurrent;
var Texture AnimNext;
// ^ NEW IN 1.60
var ELODSet LODSet;
// ^ NEW IN 1.60
var int m_dwGetSizeLastFrame;
//#ifdef R6RASTERS
var int m_dwSize;
//!!OLDVER Whether a compressed version exists.
var const editconst bool bHasComp;
// Changed since last render.
var transient bool bRealtimeChanged;
// Texture data need not be stored.
var bool bParametric;
// Texture changes in realtime.
var bool bRealtime;
var bool bHighTextureQuality;
// ^ NEW IN 1.60
var bool bHighColorQuality;
// ^ NEW IN 1.60
var bool bAlphaTexture;
// ^ NEW IN 1.60
var editconst bool bMasked;
// ^ NEW IN 1.60
// Specular lighting coefficient.
var float Specular;
var EEnvMapTransformType EnvMapTransformType;
// ^ NEW IN 1.60
// Environment map for this texture
var Texture EnvironmentMap;
// Subtextures.
// Detail texture to apply.
var Texture DetailTexture;
var const int InternalTime[2];
var const Color MaxColor;
// Internal info.
var const Color MipZero;
var Palette Palette;
// ^ NEW IN 1.60

defaultproperties
{
}
