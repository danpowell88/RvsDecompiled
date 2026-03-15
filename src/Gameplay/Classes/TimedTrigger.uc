//=============================================================================
// TimedTrigger - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// TimedTrigger: causes an event after X seconds.
//=============================================================================
class TimedTrigger extends Trigger;

var() bool bRepeating;
var() float DelaySeconds;

function Timer()
{
	TriggerEvent(Event, self, none);
	// End:0x1B
	if((!bRepeating))
	{
		Destroy();
	}
	return;
}

function MatchStarting()
{
	SetTimer(DelaySeconds, bRepeating);
	return;
}

defaultproperties
{
	DelaySeconds=1.0000000
	bCollideActors=false
	bObsolete=true
}
