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
	__NFUN_165__(i);
	// End:0x71
	if(__NFUN_132__(__NFUN_132__(__NFUN_153__(i, 16), __NFUN_254__(OutEvents[i], 'None')), __NFUN_254__(OutEvents[i], 'None')))
	{
		// End:0x6B
		if(bLoop)
		{
			i = 0;			
		}
		else
		{
			__NFUN_262__(false, false, false);
		}
	}
	return;
}

defaultproperties
{
	bObsolete=true
}
