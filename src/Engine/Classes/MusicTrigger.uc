// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class MusicTrigger extends Triggers;

// --- Variables ---
var transient bool Triggered;
var bool FadeOutAllSongs;
// ^ NEW IN 1.60
var transient int SongHandle;
var string Song;
// ^ NEW IN 1.60
var float FadeInTime;
// ^ NEW IN 1.60
var float FadeOutTime;
// ^ NEW IN 1.60

// --- Functions ---
function Trigger(Actor Other, Pawn EventInstigator) {}

defaultproperties
{
}
