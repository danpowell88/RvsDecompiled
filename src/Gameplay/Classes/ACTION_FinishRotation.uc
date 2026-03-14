// Latent scripted action that stalls the sequence until the pawn finishes its current
// in-progress rotation (TurnToGoal returns true immediately, deferring to the tick loop).
// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class ACTION_FinishRotation extends LatentScriptedAction;

// --- Functions ---
function bool TurnToGoal() {}

defaultproperties
{
}
