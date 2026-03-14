// Scripted action that conditionally skips the next action based on whether a named
// TriggeredCondition actor has been triggered.
// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class ACTION_IfCondition extends ScriptedAction;

// --- Variables ---
// var ? T; // REMOVED IN 1.60
var TriggeredCondition t;
// ^ NEW IN 1.60
var name TriggeredConditionTag;
// ^ NEW IN 1.60

// --- Functions ---
function ProceedToNextAction(ScriptedController C) {}
function bool StartsSection() {}
// ^ NEW IN 1.60
function string GetActionString() {}
// ^ NEW IN 1.60

defaultproperties
{
}
