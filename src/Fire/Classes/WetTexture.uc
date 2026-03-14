//=============================================================================
// WetTexture: Water amplitude used as displacement.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class WetTexture extends WaterTexture
    native
    noexport;

// --- Variables ---
var Texture SourceTexture;
// ^ NEW IN 1.60
var transient Texture OldSourceTex;
var transient int LocalSourceBitmap;

defaultproperties
{
}
