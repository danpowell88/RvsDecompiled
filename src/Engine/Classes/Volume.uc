//=============================================================================
// Volume - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// Volume:  a bounding volume
// touch() and untouch() notifications to the volume as actors enter or leave it
// enteredvolume() and leftvolume() notifications when center of actor enters the volume
// pawns with bIsPlayer==true  cause playerenteredvolume notifications instead of actorenteredvolume()
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Volume extends Brush
    native
    notplaceable;

var() int LocationPriority;
var Actor AssociatedActor;  // this actor gets touch() and untouch notifications as the volume is entered or left
var() edfindable DecorationList DecoList;  // A list of decorations to be spawned inside the volume when the level starts
var() name AssociatedActorTag;  // Used by L.D. to specify tag of associated actor
var() localized string LocationName;

// Export UVolume::execEncompasses(FFrame&, void* const)
native function bool Encompasses(Actor Other);

function PostBeginPlay()
{
	super(Actor).PostBeginPlay();
	// End:0x40
	if(__NFUN_130__(__NFUN_255__(AssociatedActorTag, 'None'), __NFUN_255__(AssociatedActorTag, 'None')))
	{
		// End:0x3F
		foreach __NFUN_304__(Class'Engine.Actor', AssociatedActor, AssociatedActorTag)
		{
			// End:0x3F
			break;			
		}		
	}
	// End:0x5B
	if(__NFUN_119__(AssociatedActor, none))
	{
		__NFUN_113__('AssociatedTouch');
		InitialState = __NFUN_284__();
	}
	return;
}

function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	super(Actor).DisplayDebug(Canvas, YL, YPos);
	Canvas.__NFUN_465__(__NFUN_112__("AssociatedActor ", string(AssociatedActor)), false);
	__NFUN_184__(YPos, YL);
	Canvas.__NFUN_2623__(4.0000000, YPos);
	return;
}

state AssociatedTouch
{
	event Touch(Actor Other)
	{
		AssociatedActor.Touch(Other);
		return;
	}

	event UnTouch(Actor Other)
	{
		AssociatedActor.UnTouch(Other);
		return;
	}

	function BeginState()
	{
		local Actor A;

		// End:0x1C
		foreach __NFUN_307__(Class'Engine.Actor', A)
		{
			Touch(A);			
		}		
		return;
	}
	stop;
}

defaultproperties
{
	LocationName="unspecified"
	bSkipActorPropertyReplication=true
	bCollideActors=true
}
