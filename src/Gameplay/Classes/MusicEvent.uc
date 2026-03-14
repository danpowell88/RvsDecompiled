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
	if(__NFUN_122__(Song, ""))
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
		if(__NFUN_119__(A, none))
		{
			// End:0x5A
			if(A.__NFUN_303__('PlayerController'))
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
		if(__NFUN_114__(P, none))
		{
			return;
		}
		P.ClientSetMusic(Song, Transition);
	}
	// End:0xC9
	if(bOnceOnly)
	{
		__NFUN_262__(false, false, false);
		__NFUN_118__('Trigger');
	}
	return;
}

defaultproperties
{
	Transition=3
	bAffectAllPlayers=true
	bObsolete=true
}
