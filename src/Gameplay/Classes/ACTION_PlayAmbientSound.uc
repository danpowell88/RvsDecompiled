//=============================================================================
// ACTION_PlayAmbientSound - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_PlayAmbientSound extends ScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var(Action) byte SoundVolume;
var(Action) byte SoundPitch;
var(Action) float SoundRadius;
var(Action) Sound AmbientSound;

function bool InitActionFor(ScriptedController C)
{
	// End:0x62
	if(__NFUN_119__(AmbientSound, none))
	{
		C.SequenceScript.AmbientSound = AmbientSound;
		C.SequenceScript.SoundPitch = SoundPitch;
		C.SequenceScript.SoundRadius = SoundRadius;
	}
	return false;
	return;
}

function string GetActionString()
{
	return __NFUN_168__(ActionString, string(AmbientSound));
	return;
}

defaultproperties
{
	SoundVolume=128
	SoundPitch=64
	SoundRadius=64.0000000
	ActionString="play ambient sound"
}
