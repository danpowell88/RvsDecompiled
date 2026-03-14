//=============================================================================
// ScriptedTexture - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// ScriptedTexture: A scriptable Unreal texture
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class ScriptedTexture extends Texture
    safereplace
    hidecategories(Object);

// A SciptedTexture calls its Script's Render() method to draw to the texture at
// runtime
var Actor NotifyActor;
var() Texture SourceTexture;
var const transient int Junk1;  // C++ stuff
var const transient int Junk2;  // C++ stuff
var const transient int Junk3;  // C++ stuff
var const transient float LocalTime;  // C++ stuff

// Export UScriptedTexture::execDrawTile(FFrame&, void* const)
native(473) final function DrawTile(float X, float Y, float XL, float YL, float U, float V, float UL, float VL, Texture Tex, bool bMasked);

// Export UScriptedTexture::execDrawText(FFrame&, void* const)
native(472) final function DrawText(float X, float Y, string Text, Font Font);

// Export UScriptedTexture::execDrawColoredText(FFrame&, void* const)
native(474) final function DrawColoredText(float X, float Y, string Text, Font Font, Color FontColor);

// Export UScriptedTexture::execReplaceTexture(FFrame&, void* const)
native(475) final function ReplaceTexture(Texture Tex);

// Export UScriptedTexture::execTextSize(FFrame&, void* const)
native(476) final function TextSize(string Text, out float XL, out float YL, Font Font);

