//=============================================================================
// ACTION_PlaySound - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_PlaySound extends ScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var(Action) bool bAttenuate;
var(Action) float Volume;
var(Action) float Pitch;
var(Action) Sound Sound;

function bool InitActionFor(ScriptedController C)
{
	return false;
	return;
}

function string GetActionString()
{
	return (ActionString @ string(Sound));
	return;
}

defaultproperties
{
	bAttenuate=true
	Volume=1.0000000
	Pitch=1.0000000
	ActionString="play sound"
}
