//=============================================================================
// ACTION_MoveToPlayer - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_MoveToPlayer extends LatentScriptedAction
	editinlinenew
	collapsecategories
 hidecategories(Object);

function bool MoveToGoal()
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
	ActionString="Move to player"
}
