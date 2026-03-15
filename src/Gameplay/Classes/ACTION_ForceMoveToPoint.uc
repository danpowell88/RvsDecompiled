//=============================================================================
// ACTION_ForceMoveToPoint - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_ForceMoveToPoint extends ScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var byte originalPhys;
var Actor Dest;
var(Action) name DestinationTag;  // tag of destination - if none, then use the ScriptedSequence

function bool InitActionFor(ScriptedController C)
{
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
	originalPhys = C.Pawn.Physics;
	C.Pawn.SetCollision(false, false, false);
	C.Pawn.bCollideWorld = false;
	C.Pawn.__NFUN_267__(Dest.Location) /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/;
	C.Pawn.__NFUN_299__(Dest.Rotation);
	C.Pawn.__NFUN_3970__(0);
	return false;
	return;
}

