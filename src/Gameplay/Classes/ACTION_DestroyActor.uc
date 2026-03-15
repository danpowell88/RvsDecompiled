//=============================================================================
// ACTION_DestroyActor - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_DestroyActor extends ScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var(Action) name DestroyTag;

function bool InitActionFor(ScriptedController C)
{
	local Actor A;

	// End:0x3B
	if((DestroyTag != 'None'))
	{
		// End:0x3A
		foreach C.AllActors(Class'Engine.Actor', A, DestroyTag)
		{
			A.Destroy();			
		}		
	}
	return false;
	return;
}

function string GetActionString()
{
	return ActionString;
	return;
}

defaultproperties
{
	ActionString="Destroy actor"
}
