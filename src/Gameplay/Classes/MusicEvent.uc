//=============================================================================
// MusicEvent - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// MusicEvent.
// OBSOLETE - superceded by ScriptedTrigger
//=============================================================================
class MusicEvent extends Triggers;

var() Actor.EMusicTransition Transition;
var() bool bSilence;
var() bool bOnceOnly;
var() bool bAffectAllPlayers;
// Variables.
var() string Song;

// When gameplay starts.
function BeginPlay()
{
	// End:0x20
	if((Song == ""))
	{
		Song = Level.Song;
	}
	// End:0x29
	if(bSilence)
	{
	}
	return;
}

// When triggered.
function Trigger(Actor Other, Pawn EventInstigator)
{
	local PlayerController P;
	local Controller A;

	// End:0x74
	if(bAffectAllPlayers)
	{
		A = Level.ControllerList;
		J0x1D:

		// End:0x71 [Loop If]
		if((A != none))
		{
			// End:0x5A
			if(A.IsA('PlayerController'))
			{
				PlayerController(A).ClientSetMusic(Song, Transition);
			}
			A = A.nextController;
			// [Loop Continue]
			goto J0x1D;
		}		
	}
	else
	{
		P = PlayerController(EventInstigator.Controller);
		// End:0x9A
		if((P == none))
		{
			return;
		}
		P.ClientSetMusic(Song, Transition);
	}
	// End:0xC9
	if(bOnceOnly)
	{
		SetCollision(false, false, false);
		Disable('Trigger');
	}
	return;
}

defaultproperties
{
	Transition=3
	bAffectAllPlayers=true
	bObsolete=true
}
