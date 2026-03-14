// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class ScrollingMessageTexture extends ClientScriptedTexture;

// --- Variables ---
var PlayerController Player;
var int Position;
var float LastDrawTime;
var string OldText;
var localized string ScrollingMessage;
// ^ NEW IN 1.60
var localized string HisMessage;
// ^ NEW IN 1.60
var localized string HerMessage;
var Font Font;
// ^ NEW IN 1.60
var bool bResetPosOnTextChange;
// ^ NEW IN 1.60
var float YPos;
// ^ NEW IN 1.60
var Color FontColor;
// ^ NEW IN 1.60
var int ScrollWidth;
// ^ NEW IN 1.60
var bool bCaps;
// ^ NEW IN 1.60
var int PixelsPerSecond;
// ^ NEW IN 1.60

// --- Functions ---
simulated function string Replace(string Text, string Match, string Replacement) {}
// ^ NEW IN 1.60
simulated function FindPlayer() {}
simulated event RenderTexture(ScriptedTexture Tex) {}

defaultproperties
{
}
