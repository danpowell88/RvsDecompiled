// Scripted action that redirects a player's camera to a tagged actor or to the pawn's
// current enemy (ViewTargetTag='Enemy').
// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class ACTION_SetViewTarget extends ScriptedAction;

// --- Variables ---
var name ViewTargetTag;
// ^ NEW IN 1.60
var Actor ViewTarget;

// --- Functions ---
function bool InitActionFor(ScriptedController C) {}
function string GetActionString() {}

defaultproperties
{
}
