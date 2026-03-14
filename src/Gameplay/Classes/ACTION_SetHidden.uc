//=============================================================================
// ACTION_SetHidden - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_SetHidden extends ScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var(Action) bool bHidden;

function bool InitActionFor(ScriptedController C)
{
	C.GetInstigator().bHidden = bHidden;
	return false;
	return;
}

