// Scripted action that force-moves the pawn directly to a tagged destination without
// pathfinding, temporarily overriding its physics mode.
// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class ACTION_ForceMoveToPoint extends ScriptedAction;

// --- Variables ---
var Actor Dest;
var name DestinationTag;
// ^ NEW IN 1.60
var byte originalPhys;

// --- Functions ---
function bool InitActionFor(ScriptedController C) {}

defaultproperties
{
}
