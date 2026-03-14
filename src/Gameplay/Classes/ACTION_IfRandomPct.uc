// Scripted action that randomly skips the next action based on a probability value
// (0.0 = never skip, 1.0 = always skip).
// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class ACTION_IfRandomPct extends ScriptedAction;

// --- Variables ---
var float Probability;

// --- Functions ---
function ProceedToNextAction(ScriptedController C) {}
function bool StartsSection() {}
// ^ NEW IN 1.60

defaultproperties
{
}
