//=============================================================================
// ACTION_WaitForTimer - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_WaitForTimer extends LatentScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var(Action) float PauseTime;

function bool InitActionFor(ScriptedController C)
{
	C.CurrentAction = self;
	C.__NFUN_280__(PauseTime, false);
	return true;
	return;
}

function bool CompleteWhenTriggered()
{
	return true;
	return;
}

function bool CompleteWhenTimer()
{
	return true;
	return;
}

function string GetActionString()
{
	return __NFUN_168__(ActionString, string(PauseTime));
	return;
}

defaultproperties
{
	ActionString="Wait for timer"
}
