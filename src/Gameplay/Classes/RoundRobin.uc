//=============================================================================
// RoundRobin - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// RoundRobin: Each time it's triggered, it advances through a list of
// outgoing events.
// OBSOLETE - superceded by ScriptedTrigger
//=============================================================================
class RoundRobin extends Triggers;

var int i;  // Internal counter.
var() bool bLoop;  // Whether to loop when get to end.
var() name OutEvents[16];  // Events to generate.

//
// When RoundRobin is triggered...
//
function Trigger(Actor Other, Pawn EventInstigator)
{
	TriggerEvent(OutEvents[i], self, EventInstigator);
	(i++);
	// End:0x71
	if((((i >= 16) || (OutEvents[i] == 'None')) || (OutEvents[i] == 'None')))
	{
		// End:0x6B
		if(bLoop)
		{
			i = 0;			
		}
		else
		{
			SetCollision(false, false, false);
		}
	}
	return;
}

defaultproperties
{
	bObsolete=true
}
