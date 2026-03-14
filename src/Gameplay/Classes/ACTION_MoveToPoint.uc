// Latent scripted action that pathfinds the pawn to a tagged navigation point.
// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class ACTION_MoveToPoint extends LatentScriptedAction;

// --- Variables ---
// var ? Movetarget; // REMOVED IN 1.60
var Actor MoveTarget;
// ^ NEW IN 1.60
var name DestinationTag;
// ^ NEW IN 1.60

// --- Functions ---
function Actor GetMoveTargetFor(ScriptedController C) {}
function bool MoveToGoal() {}
function string GetActionString() {}

defaultproperties
{
}
