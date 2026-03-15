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
	GotoState('Dispatch');
	return;
}

state Dispatch
{Begin:

	i = 0;
	J0x07:

	// End:0x6E [Loop If]
	if((i < 32))
	{
		// End:0x64
		if(((OutEvents[i] != 'None') && (OutEvents[i] != 'None')))
		{
			Sleep(OutDelays[i]);
			TriggerEvent(OutEvents[i], self, Instigator);
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	GotoState('None');
	stop;		
}

defaultproperties
{
	bObsolete=true
	Texture=Texture'Gameplay.S_Dispatcher'
}
