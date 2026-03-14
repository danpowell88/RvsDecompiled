//=============================================================================
// MusicTrigger - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class MusicTrigger extends Triggers
 placeable;

var() bool FadeOutAllSongs;
var() float FadeInTime;
var() float FadeOutTime;
var() string Song;
var transient int SongHandle;
var transient bool Triggered;

function Trigger(Actor Other, Pawn EventInstigator)
{
	// End:0x0C
	if(FadeOutAllSongs)
	{		
	}
	else
	{
		// End:0x22
		if(__NFUN_129__(Triggered))
		{
			Triggered = true;			
		}
		else
		{
			Triggered = false;
			// End:0x38
			if(__NFUN_155__(SongHandle, 0))
			{				
			}
			else
			{
				__NFUN_231__("WARNING: invalid song handle");
			}
		}
	}
	return;
}

defaultproperties
{
	bCollideActors=false
}
