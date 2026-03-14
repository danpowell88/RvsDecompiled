//=============================================================================
// ACTION_IfCondition - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_IfCondition extends ScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var TriggeredCondition t;
var(Action) name TriggeredConditionTag;

function ProceedToNextAction(ScriptedController C)
{
	// End:0x3F
	if(__NFUN_130__(__NFUN_114__(t, none), __NFUN_255__(TriggeredConditionTag, 'None')))
	{
		// End:0x3E
		foreach C.__NFUN_304__(Class'Gameplay.TriggeredCondition', t, TriggeredConditionTag)
		{
			// End:0x3E
			break;			
		}		
	}
	__NFUN_161__(C.ActionNum, 1);
	// End:0x6F
	if(__NFUN_129__(t.bEnabled))
	{
		ProceedToSectionEnd(C);
	}
	return;
}

function bool StartsSection()
{
	return true;
	return;
}

function string GetActionString()
{
	return __NFUN_168__(__NFUN_168__(ActionString, string(t)), string(TriggeredConditionTag));
	return;
}

defaultproperties
{
	ActionString="If condition"
}
