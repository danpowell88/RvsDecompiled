//=============================================================================
// ACTION_GotoAction - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_GotoAction extends ScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var(Action) int ActionNumber;

function ProceedToNextAction(ScriptedController C)
{
	C.ActionNum = __NFUN_250__(0, ActionNumber);
	return;
}

function string GetActionString()
{
	return __NFUN_168__(ActionString, string(ActionNumber));
	return;
}

defaultproperties
{
	ActionString="go to action"
}
