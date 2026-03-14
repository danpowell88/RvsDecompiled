// Scripted action that spawns an actor of the specified class at an optional offset
// relative to the pawn or the ScriptedSequence actor.
// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class ACTION_SpawnActor extends ScriptedAction;

// --- Variables ---
var name ActorTag;
var Rotator RotationOffset;
var Vector LocationOffset;
var class<Actor> ActorClass;
var bool bOffsetFromScriptedPawn;

// --- Functions ---
function bool InitActionFor(ScriptedController C) {}
function string GetActionString() {}

defaultproperties
{
}
