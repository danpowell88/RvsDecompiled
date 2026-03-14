// Latent scripted action that instantly teleports the pawn to a tagged navigation point,
// bypassing pathfinding and movement.
// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class ACTION_TeleportToPoint extends LatentScriptedAction;

// --- Variables ---
var Actor Dest;
var name DestinationTag;
// ^ NEW IN 1.60

// --- Functions ---
function bool InitActionFor(ScriptedController C) {}

defaultproperties
{
}
