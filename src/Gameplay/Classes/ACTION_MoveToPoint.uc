//=============================================================================
// ACTION_MoveToPoint - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_MoveToPoint extends LatentScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var Actor MoveTarget;
var(Action) name DestinationTag;  // tag of destination - if none, then use the ScriptedSequence

function bool MoveToGoal()
{
	return true;
	return;
}

function Actor GetMoveTargetFor(ScriptedController C)
{
	// End:0x11
	if(__NFUN_119__(MoveTarget, none))
	{
		return MoveTarget;
	}
	MoveTarget = C.SequenceScript.GetMoveTarget();
	// End:0x72
	if(__NFUN_130__(__NFUN_255__(DestinationTag, 'None'), __NFUN_255__(DestinationTag, 'None')))
	{
		// End:0x71
		foreach C.__NFUN_304__(Class'Engine.Actor', MoveTarget, DestinationTag)
		{
			// End:0x71
			break;			
		}		
	}
	// End:0x9C
	if(__NFUN_119__(AIScript(MoveTarget), none))
	{
		MoveTarget = AIScript(MoveTarget).GetMoveTarget();
	}
	return MoveTarget;
	return;
}

function string GetActionString()
{
	return __NFUN_168__(ActionString, string(DestinationTag));
	return;
}

defaultproperties
{
	bValidForTrigger=false
	ActionString="Move to point"
}
