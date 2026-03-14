//=============================================================================
// ScriptedSequence
// used for setting up scripted sequences for pawns.
// A ScriptedController is spawned to carry out the scripted sequence.
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
