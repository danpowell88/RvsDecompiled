//=============================================================================
// ACTION_TeleportToPoint - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_TeleportToPoint extends LatentScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var Actor Dest;
var(Action) name DestinationTag;  // tag of destination - if none, then use the ScriptedSequence

function bool InitActionFor(ScriptedController C)
{
	local Pawn P;

	Dest = C.SequenceScript.GetMoveTarget();
	// End:0x61
	if(((DestinationTag != 'None') && (DestinationTag != 'None')))
	{
		// End:0x60
		foreach C.AllActors(Class'Engine.Actor', Dest, DestinationTag)
		{
			// End:0x60
			break;			
		}		
	}
	P = C.GetInstigator();
	P.SetLocation(Dest.Location);
	P.SetRotation(Dest.Rotation);
	P.OldRotYaw = float(P.Rotation.Yaw);
	return false;
	return;
}

