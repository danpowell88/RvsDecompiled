//=============================================================================
// ScriptedTrigger
// A ScriptedSequence subclass that self-activates on level start (via
// PostBeginPlay) and can be re-triggered by level events.
// Replaces the older Counter, Dispatcher, and SpecialEventTrigger actors.
//=============================================================================
class ScriptedTrigger extends ScriptedSequence;

// --- Functions ---
function PostBeginPlay() {}
function bool ValidAction(int N) {}
// ^ NEW IN 1.60

defaultproperties
{
}
