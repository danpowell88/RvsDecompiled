//=============================================================================
// ACTION_WaitForPlayer - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_WaitForPlayer extends LatentScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var(Action) float Distance;

function bool InitActionFor(ScriptedController C)
{
	// End:0x19
	if(C.CheckIfNearPlayer(Distance))
	{
		return false;
	}
	C.CurrentAction = self;
	C.__NFUN_280__(0.1000000, true);
	return true;
	return;
}

function float GetDistance()
{
	return Distance;
	return;
}

function bool WaitForPlayer()
{
	return true;
	return;
}

defaultproperties
{
	Distance=150.0000000
	bValidForTrigger=false
	ActionString="Wait for player"
}
