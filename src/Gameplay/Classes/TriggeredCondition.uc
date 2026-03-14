// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class TriggeredCondition extends Triggers;

// --- Variables ---
var bool bEnabled;
// ^ NEW IN 1.60
var bool bInitialValue;
var bool bToggled;
// ^ NEW IN 1.60
var bool bTriggerControlled;
// ^ NEW IN 1.60

// --- Functions ---
// function ? Untrigger(...); // REMOVED IN 1.60
function PostBeginPlay() {}
function Trigger(Actor Other, Pawn EventInstigator) {}
function UnTrigger(Actor Other, Pawn EventInstigator) {}
// ^ NEW IN 1.60

defaultproperties
{
}
