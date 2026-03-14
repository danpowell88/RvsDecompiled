//=============================================================================
// ACTION_Walk - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_Walk extends ScriptedAction
	editinlinenew
	collapsecategories
 hidecategories(Object);

function bool InitActionFor(ScriptedController C)
{
	C.Pawn.ShouldCrouch(false);
	C.Pawn.SetWalking(true);
	return false;
	return;
}

defaultproperties
{
	bValidForTrigger=false
	ActionString="walk"
}
