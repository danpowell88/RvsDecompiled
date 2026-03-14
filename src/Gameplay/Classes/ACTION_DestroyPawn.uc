//=============================================================================
// ACTION_DestroyPawn - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_DestroyPawn extends ScriptedAction
	editinlinenew
	collapsecategories
 hidecategories(Object);

function bool InitActionFor(ScriptedController C)
{
	C.DestroyPawn();
	return true;
	return;
}

defaultproperties
{
	bValidForTrigger=false
	ActionString="destroy pawn"
}
