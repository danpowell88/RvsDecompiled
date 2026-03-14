// Scripted action that starts a music track with a given transition type, optionally
// sending it to all connected players.
// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class ACTION_PlayMusic extends ScriptedAction;

// --- Variables ---
var string Song;
var EMusicTransition Transition;
var bool bAffectAllPlayers;

// --- Functions ---
function bool InitActionFor(ScriptedController C) {}
function string GetActionString() {}

defaultproperties
{
}
