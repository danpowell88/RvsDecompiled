//=============================================================================
// ZoneTrigger - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// ZoneTrigger.
//=============================================================================
class ZoneTrigger extends Trigger
    placeable;

//
// Called when something touches the trigger.
//
function Touch(Actor Other)
{
	local ZoneInfo Z;

	// End:0x9F
	if(IsRelevant(Other))
	{
		// End:0x69
		if((Event != 'None'))
		{
			// End:0x68
			foreach AllActors(Class'Engine.ZoneInfo', Z)
			{
				// End:0x67
				if((Z.ZoneTag == Event))
				{
					Z.Trigger(Other, Other.Instigator);
				}				
			}			
		}
		// End:0x92
		if((Message != ""))
		{
			Other.Instigator.ClientMessage(Message);
		}
		// End:0x9F
		if(bTriggerOnceOnly)
		{
			SetCollision(false);
		}
	}
	return;
}

//
// When something untouches the trigger.
//
function UnTouch(Actor Other)
{
	local ZoneInfo Z;

	// End:0x69
	if(IsRelevant(Other))
	{
		// End:0x69
		if((Event != 'None'))
		{
			// End:0x68
			foreach AllActors(Class'Engine.ZoneInfo', Z)
			{
				// End:0x67
				if((Z.ZoneTag == Event))
				{
					Z.UnTrigger(Other, Other.Instigator);
				}				
			}			
		}
	}
	return;
}

