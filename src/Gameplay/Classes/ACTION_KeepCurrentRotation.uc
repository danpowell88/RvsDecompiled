//=============================================================================
// ACTION_KeepCurrentRotation - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_KeepCurrentRotation extends ScriptedAction
	editinlinenew
	collapsecategories
 hidecategories(Object);

function bool InitActionFor(ScriptedController C)
{
	C.bUseScriptFacing = false;
	return false;
	return;
}

defaultproperties
{
	ActionString="keep current rotation"
}
