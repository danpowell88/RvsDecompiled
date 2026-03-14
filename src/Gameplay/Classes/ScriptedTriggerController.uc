//=============================================================================
// ScriptedTriggerController
// used for playing ScriptedTrigger scripts
// A ScriptedTriggerController never has a pawn
//=============================================================================
class ScriptedTriggerController extends ScriptedController;

// --- Functions ---
function SetNewScript(ScriptedSequence NewScript) {}
function InitializeFor(ScriptedTrigger t) {}
function DestroyPawn() {}
function ClearAnimation() {}

state Scripting
{
    function Trigger(Pawn EventInstigator, Actor Other) {}
    function LeaveScripting() {}
}

state Broken
{
}

defaultproperties
{
}
