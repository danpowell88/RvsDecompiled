//=============================================================================
// AIScript - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// AIScript - used by Level Designers to specify special AI scripts for pawns 
// placed in a level, and to change which type of AI controller to use for a pawn.
// AIScripts can be shared by one or many pawns. 
// Game specific subclasses of AIScript will have editable properties defining game specific behavior and AI
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class AIScript extends Keypoint
    native
    placeable;

var bool bNavigate;  // if true, put an associated path in the navigation network
var bool bLoggingEnabled;
var AIMarker myMarker;
var() Class<AIController> ControllerClass;

function SpawnControllerFor(Pawn P)
{
	local AIController C;

	// End:0x3B
	if((ControllerClass == none))
	{
		// End:0x21
		if((P.ControllerClass == none))
		{
			return;
		}
		C = Spawn(P.ControllerClass);		
	}
	else
	{
		C = Spawn(ControllerClass);
	}
	C.MyScript = self;
	C.Possess(P);
	return;
}

function Actor GetMoveTarget()
{
	// End:0x11
	if((myMarker != none))
	{
		return myMarker;
	}
	return self;
	return;
}

function TakeOver(Pawn P)
{
	return;
}

