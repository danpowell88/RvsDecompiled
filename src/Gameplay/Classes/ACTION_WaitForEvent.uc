// Latent scripted action that pauses the sequence until a named external event is
// triggered (via a TriggeredCondition or level Trigger).
// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class ACTION_WaitForEvent extends LatentScriptedAction;

// --- Variables ---
// var ? T; // REMOVED IN 1.60
var TriggeredCondition t;
// ^ NEW IN 1.60
var name ExternalEvent;
// ^ NEW IN 1.60

// --- Functions ---
function bool InitActionFor(ScriptedController C) {}
function bool CompleteWhenTriggered() {}
function string GetActionString() {}

defaultproperties
{
}
