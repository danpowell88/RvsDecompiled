//=============================================================================
// ACTION_ShootTarget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_ShootTarget extends ScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var(Action) int NumShots;
var(Action) bool bSpray;
var(Action) name FiringMode;

function bool InitActionFor(ScriptedController C)
{
	C.NumShots = NumShots;
	C.FiringMode = FiringMode;
	C.bShootTarget = true;
	C.bShootSpray = bSpray;
	return false;
	return;
}

defaultproperties
{
	ActionString="shoot target"
}
