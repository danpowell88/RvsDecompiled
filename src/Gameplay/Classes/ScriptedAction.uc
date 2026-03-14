// Abstract base class for all scripted actions used in ScriptedSequence/ScriptedTrigger chains.
// Each subclass implements InitActionFor() to execute its specific behaviour when the
// ScriptedController advances to that step in the sequence.
// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class ScriptedAction extends Object
    abstract;

// --- Variables ---
var localized string ActionString;
var bool bValidForTrigger;

// --- Functions ---
function bool InitActionFor(ScriptedController C) {}
// ^ NEW IN 1.60
function string GetActionString() {}
// ^ NEW IN 1.60
function ProceedToNextAction(ScriptedController C) {}
function ScriptedSequence GetScript(ScriptedSequence S) {}
// ^ NEW IN 1.60
function bool StartsSection() {}
// ^ NEW IN 1.60
function bool EndsSection() {}
// ^ NEW IN 1.60
function ProceedToSectionEnd(ScriptedController C) {}

defaultproperties
{
}
