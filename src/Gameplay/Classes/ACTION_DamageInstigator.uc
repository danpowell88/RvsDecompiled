//=============================================================================
// ACTION_DamageInstigator - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_DamageInstigator extends ScriptedAction
	editinlinenew
	collapsecategories
 hidecategories(Object);

// NEW IN 1.60
var(Action) int m_iKillValue;
// NEW IN 1.60
var(Action) int m_iStunValue;

function bool InitActionFor(ScriptedController C)
{
	local Pawn Damaged;

	Damaged = C.GetInstigator();
	Damaged.R6TakeDamage(m_iKillValue, m_iStunValue, Damaged, Damaged.Location, vect(0.0000000, 0.0000000, 0.0000000), 0);
	return false;
	return;
}

function string GetActionString()
{
	return __NFUN_168__(__NFUN_168__(ActionString, string(m_iKillValue)), string(m_iStunValue));
	return;
}

defaultproperties
{
	m_iKillValue=500
	m_iStunValue=1000
	ActionString="Damage instigator"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var Damage
// REMOVED IN 1.60: var DamageType
