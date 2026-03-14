//=============================================================================
// RoundRobin: Each time it's triggered, it advances through a list of
// outgoing events.
// OBSOLETE - superceded by ScriptedTrigger
//=============================================================================
class RoundRobin extends Triggers
    notplaceable;

// --- Variables ---
// Internal counter.
var int i;
var name OutEvents[16];
// ^ NEW IN 1.60
var bool bLoop;
// ^ NEW IN 1.60

// --- Functions ---
//
// When RoundRobin is triggered...
//
function Trigger(Pawn EventInstigator, Actor Other) {}

defaultproperties
{
}
