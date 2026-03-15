//=============================================================================
// ACTION_PlayLocalSound - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_PlayLocalSound extends ScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var(Action) Sound Sound;

function bool InitActionFor(ScriptedController C)
{
	local PlayerController P;

	// End:0x30
	foreach C.DynamicActors(Class'Engine.PlayerController', P)
	{
		P.ClientPlaySound(Sound, 3);		
	}	
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
	ActionString="play sound"
}
