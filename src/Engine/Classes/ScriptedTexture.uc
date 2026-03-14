//=============================================================================
// ScriptedTexture: A scriptable Unreal texture
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class ScriptedTexture extends Texture
    noexport;

// --- Variables ---
// A SciptedTexture calls its Script's Render() method to draw to the texture at
// runtime
var Actor NotifyActor;
var Texture SourceTexture;
// ^ NEW IN 1.60
// C++ stuff
var transient const int Junk1;
// C++ stuff
var transient const int Junk2;
// C++ stuff
var transient const int Junk3;
// C++ stuff
var transient const float LocalTime;

// --- Functions ---
final native function DrawTile(bool bMasked, Texture Tex, float VL, float UL, float V, float U, float YL, float XL, float Y, float X) {}
final native function DrawText(Font Font, string Text, float Y, float X) {}
final native function DrawColoredText(Color FontColor, Font Font, string Text, float Y, float X) {}
final native function ReplaceTexture(Texture Tex) {}
final native function TextSize(Font Font, out float YL, out float XL, string Text) {}

defaultproperties
{
}
