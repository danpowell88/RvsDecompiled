//=============================================================================
// FractalTexture - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// FractalTexture: Base class of FireEngine fractal textures.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class FractalTexture extends Texture
    abstract
    native
    noexport
    safereplace
    hidecategories(Object);

// Transient editing parameters.
var transient int UMask;
var transient int VMask;
var transient int LightOutput;
var transient int SoundOutput;
var transient int GlobalPhase;
var transient byte DrawPhase;
var transient byte AuxPhase;

