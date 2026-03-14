//=============================================================================
// ACTION_TurnTowardPlayer - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_TurnTowardPlayer extends LatentScriptedAction
	editinlinenew
	collapsecategories
 hidecategories(Object);

function bool InitActionFor(ScriptedController C)
{
	C.ScriptedFocus = C.GetMyPlayer();
	C.CurrentAction = self;
	return true;
	return;
}

function bool TurnToGoal()
{
	return true;
	return;
}

function Actor GetMoveTargetFor(ScriptedController C)
{
	return C.GetMyPlayer();
	return;
}

defaultproperties
{
	bValidForTrigger=false
	ActionString="Turn toward player"
}
