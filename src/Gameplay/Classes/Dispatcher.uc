//=============================================================================
// Dispatcher: receives one trigger (corresponding to its name) as input, 
// then triggers a set of specifid events with optional delays.
// OBSOLETE - superceded by ScriptedTrigger
//=============================================================================
class Dispatcher extends Triggers
    notplaceable;

#exec Texture Import File=Textures\Dispatch.pcx Name=S_Dispatcher Mips=Off MASKED=1

// --- Variables ---
// Internal counter.
var int i;
var name OutEvents[32];
// ^ NEW IN 1.60
var float OutDelays[32];
// ^ NEW IN 1.60

// --- Functions ---
//
// When dispatcher is triggered...
//
function Trigger(Pawn EventInstigator, Actor Other) {}

state Dispatch
{
}

defaultproperties
{
}
