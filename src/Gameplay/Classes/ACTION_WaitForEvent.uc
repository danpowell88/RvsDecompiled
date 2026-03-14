//=============================================================================
// ACTION_WaitForEvent - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_WaitForEvent extends LatentScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var TriggeredCondition t;
var(Action) name ExternalEvent;  // tag to give controller (to affect triggering)

function bool InitActionFor(ScriptedController C)
{
	// End:0x2E
	if(__NFUN_114__(t, none))
	{
		// End:0x2D
		foreach C.__NFUN_304__(Class'Gameplay.TriggeredCondition', t, ExternalEvent)
		{
			// End:0x2D
			break;			
		}		
	}
	// End:0x4F
	if(__NFUN_130__(__NFUN_119__(t, none), t.bEnabled))
	{
		return false;
	}
	C.CurrentAction = self;
	C.Tag = ExternalEvent;
	return true;
	return;
}

function bool CompleteWhenTriggered()
{
	return true;
	return;
}

function string GetActionString()
{
	return __NFUN_168__(ActionString, string(ExternalEvent));
	return;
}

defaultproperties
{
	ActionString="Wait for external event"
}
