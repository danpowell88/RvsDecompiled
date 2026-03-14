// Scripted action that applies a configurable amount of damage (of a given DamageType)
// to the instigating pawn.  Can be used to stun or kill the pawn via script.
// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class ACTION_DamageInstigator extends ScriptedAction;

// --- Variables ---
var int m_iStunValue;
var int m_iKillValue;

// --- Functions ---
function bool InitActionFor(ScriptedController C) {}
function string GetActionString() {}

defaultproperties
{
}
