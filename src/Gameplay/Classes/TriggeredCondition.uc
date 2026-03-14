//=============================================================================
// TriggeredCondition - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class TriggeredCondition extends Triggers;

var() bool bToggled;
var() bool bEnabled;
var() bool bTriggerControlled;  // false if untriggered
var bool bInitialValue;

function PostBeginPlay()
{
	super(Actor).PostBeginPlay();
	bInitialValue = bEnabled;
	return;
}

function Trigger(Actor Other, Pawn EventInstigator)
{
	// End:0x1B
	if(bToggled)
	{
		bEnabled = __NFUN_129__(bEnabled);		
	}
	else
	{
		bEnabled = __NFUN_129__(bInitialValue);
	}
	return;
}

function UnTrigger(Actor Other, Pawn EventInstigator)
{
	// End:0x16
	if(bTriggerControlled)
	{
		bEnabled = bInitialValue;
	}
	return;
}

