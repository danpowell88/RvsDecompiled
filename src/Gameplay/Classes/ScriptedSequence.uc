//=============================================================================
// ScriptedSequence
// Holds an ordered array of ScriptedAction objects that define a scripted
// behaviour for a Pawn.  When activated, a ScriptedController is spawned and
// steps through the actions one by one.
//=============================================================================
class ScriptedSequence extends AIScript;

// --- Variables ---
var array<array> Actions;
// ^ NEW IN 1.60
var class<ScriptedController> ScriptControllerClass;

// --- Functions ---
function bool ValidAction(int N) {}
// ^ NEW IN 1.60
function SpawnControllerFor(Pawn P) {}
function TakeOver(Pawn P) {}
function SetActions(ScriptedController C) {}

defaultproperties
{
}
