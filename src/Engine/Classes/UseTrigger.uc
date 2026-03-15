//=============================================================================
// UseTrigger - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// UseTrigger: if a player stands within proximity of this trigger, and hits Use, 
// it will send Trigger/UnTrigger to actors whose names match 'EventName'.
//=============================================================================
class UseTrigger extends Triggers
    placeable;

var() localized string Message;

function UsedBy(Pawn User)
{
	TriggerEvent(Event, self, User);
	return;
}

function Touch(Actor Other)
{
	// End:0x3F
	if(((Message != "") && (Other.Instigator != none)))
	{
		Other.Instigator.ClientMessage(Message);
	}
	return;
}

