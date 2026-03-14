// Abstract base for scripted actions that take time to complete (latent actions).
// The ScriptedController keeps calling StillTicking() each frame until the action
// signals completion via one of the CompleteWhen*() or CompleteOnAnim() helpers.
// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class LatentScriptedAction extends ScriptedAction
    abstract;

// --- Functions ---
function bool InitActionFor(ScriptedController C) {}
// ^ NEW IN 1.60
function Actor GetMoveTargetFor(ScriptedController C) {}
// ^ NEW IN 1.60
function bool TurnToGoal() {}
// ^ NEW IN 1.60
function bool MoveToGoal() {}
// ^ NEW IN 1.60
function bool CompleteWhenTriggered() {}
// ^ NEW IN 1.60
function bool StillTicking(ScriptedController C, float DeltaTime) {}
// ^ NEW IN 1.60
function bool CompleteWhenTimer() {}
// ^ NEW IN 1.60
function bool WaitForPlayer() {}
// ^ NEW IN 1.60
function bool TickedAction() {}
// ^ NEW IN 1.60
function float GetDistance() {}
// ^ NEW IN 1.60
function bool CompleteOnAnim(int Channel) {}
// ^ NEW IN 1.60
function DisplayDebug(out float YPos, Canvas Canvas, out float YL) {}

defaultproperties
{
}
