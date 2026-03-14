// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class BitmapMaterial extends RenderedMaterial
    native
    abstract
    noexport;

// --- Enums ---
enum ETexClampMode
{
    // enum values not recoverable from binary — see 1.56 source
};
enum ETextureFormat
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
var const int USize;
// ^ NEW IN 1.60
var const int VSize;
var const int VClamp;
// ^ NEW IN 1.60
var const int UClamp;
// ^ NEW IN 1.60
var const byte VBits;
var const byte UBits;
// ^ NEW IN 1.60
var ETexClampMode VClampMode;
// ^ NEW IN 1.60
var ETexClampMode UClampMode;
// ^ NEW IN 1.60
var const editconst ETextureFormat Format;
// ^ NEW IN 1.60

defaultproperties
{
}
