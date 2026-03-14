//=============================================================================
// ACTION_PlayMusic - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_PlayMusic extends ScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var(Action) Actor.EMusicTransition Transition;
var(Action) bool bAffectAllPlayers;
var(Action) string Song;

function bool InitActionFor(ScriptedController C)
{
	local PlayerController P;
	local Controller A;

	// End:0x7D
	if(bAffectAllPlayers)
	{
		A = C.Level.ControllerList;
		J0x26:

		// End:0x7A [Loop If]
		if(__NFUN_119__(A, none))
		{
			// End:0x63
			if(A.__NFUN_303__('PlayerController'))
			{
				PlayerController(A).ClientSetMusic(Song, Transition);
			}
			A = A.nextController;
			// [Loop Continue]
			goto J0x26;
		}		
	}
	else
	{
		P = PlayerController(C.GetInstigator().Controller);
		// End:0xAD
		if(__NFUN_114__(P, none))
		{
			return false;
		}
		P.ClientSetMusic(Song, Transition);
	}
	return false;
	return;
}

function string GetActionString()
{
	return __NFUN_168__(ActionString, Song);
	return;
}

defaultproperties
{
	Transition=3
	bAffectAllPlayers=true
	ActionString="play song"
}
