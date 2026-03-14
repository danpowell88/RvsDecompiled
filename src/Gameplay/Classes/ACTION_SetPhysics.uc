//=============================================================================
// ACTION_SetPhysics - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_SetPhysics extends ScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var(Action) Actor.EPhysics NewPhysicsMode;

function bool InitActionFor(ScriptedController C)
{
	C.GetInstigator().__NFUN_3970__(NewPhysicsMode);
	return false;
	return;
}

function string GetActionString()
{
	return __NFUN_168__(ActionString, string(NewPhysicsMode));
	return;
}

defaultproperties
{
	ActionString="change physics to "
}
