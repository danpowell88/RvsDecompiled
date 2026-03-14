// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class TriggeredTexture extends Triggers;

// --- Variables ---
var /* replicated */ int CurrentTexture;
var Texture DestinationTexture;
// ^ NEW IN 1.60
var Texture Textures[10];
// ^ NEW IN 1.60
var bool bTriggerOnceOnly;
// ^ NEW IN 1.60

// --- Functions ---
simulated event RenderTexture(ScriptedTexture Tex) {}
simulated event PostBeginPlay() {}
simulated event Destroyed() {}
event Trigger(Actor Other, Pawn EventInstigator) {}

defaultproperties
{
}
