//=============================================================================
// Dispatcher - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// Dispatcher: receives one trigger (corresponding to its name) as input, 
// then triggers a set of specifid events with optional delays.
// OBSOLETE - superceded by ScriptedTrigger
//=============================================================================
class Dispatcher extends Triggers;

var int i;  // Internal counter.
var() float OutDelays[32];  // Relative delays before generating events.
var() name OutEvents[32];  // Events to generate.

//
// When dispatcher is triggered...
//
function Trigger(Actor Other, Pawn EventInstigator)
{
	Instigator = EventInstigator;
	__NFUN_113__('Dispatch');
	return;
}

state Dispatch
{Begin:

	i = 0;
	J0x07:

	// End:0x6E [Loop If]
	if(__NFUN_150__(i, 32))
	{
		// End:0x64
		if(__NFUN_130__(__NFUN_255__(OutEvents[i], 'None'), __NFUN_255__(OutEvents[i], 'None')))
		{
			__NFUN_256__(OutDelays[i]);
			TriggerEvent(OutEvents[i], self, Instigator);
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	__NFUN_113__('None');
	stop;		
}

defaultproperties
{
	bObsolete=true
	Texture=Texture'Gameplay.S_Dispatcher'
}
