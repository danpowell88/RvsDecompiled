//=============================================================================
// ACTION_Killinstigator - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_Killinstigator extends ScriptedAction
	editinlinenew
	collapsecategories
 hidecategories(Object);

function bool InitActionFor(ScriptedController C)
{
	C.GetInstigator().ServerForceKillResult(4);
	C.GetInstigator().R6TakeDamage(100000, 1000000, none, vect(0.0000000, 0.0000000, 0.0000000), vect(0.0000000, 0.0000000, 0.0000000), 0);
	C.GetInstigator().ServerForceKillResult(0);
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
	ActionString="Kill instigator"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var DamageType
