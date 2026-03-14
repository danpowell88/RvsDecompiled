// Scripted action that makes the pawn fire at its current target a set number of times,
// with an optional spray-fire mode.
// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class ACTION_ShootTarget extends ScriptedAction;

// --- Variables ---
var bool bSpray;
var name FiringMode;
var int NumShots;

// --- Functions ---
function bool InitActionFor(ScriptedController C) {}

defaultproperties
{
}
