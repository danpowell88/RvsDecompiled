//=============================================================================
// ACTION_StopShooting - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_StopShooting extends ScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

function bool InitActionFor(ScriptedController C)
{
	C.bShootTarget = false;
	C.bShootSpray = false;
	return false;
	return;
}

