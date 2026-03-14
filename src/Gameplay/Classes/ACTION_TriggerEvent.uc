//=============================================================================
// ACTION_TriggerEvent - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_TriggerEvent extends ScriptedAction
	editinlinenew
	collapsecategories
 hidecategories(Object);

var(Action) name Event;

function bool InitActionFor(ScriptedController C)
{
	C.TriggerEvent(Event, C.SequenceScript, C.GetInstigator());
	return false;
	return;
}

function string GetActionString()
{
	return __NFUN_168__(ActionString, string(Event));
	return;
}

defaultproperties
{
	ActionString="trigger event"
}
