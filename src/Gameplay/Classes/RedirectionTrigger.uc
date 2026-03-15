//=============================================================================
// RedirectionTrigger - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class RedirectionTrigger extends Triggers;

var() name RedirectionEvent;

function Trigger(Actor Other, Pawn EventInstigator)
{
	local Pawn P;

	// End:0x44
	foreach DynamicActors(Class'Engine.Pawn', P, Event)
	{
		// End:0x43
		if((P.Health > 0))
		{
			P.TriggerEvent(RedirectionEvent, self, P);
		}		
	}	
	return;
}

