// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class ACTION_SetAlertness extends ScriptedAction;

// --- Enums ---
enum EAlertnessType
{
	ALERTNESS_IgnoreAll,			// ignore any damage, etc. (even the physics part)
	ALERTNESS_IgnoreEnemies,		// react normally, but don't try to fight or anything
	ALERTNESS_StayOnScript,			// stay on script, but fight when possible
	ALERTNESS_LeaveScriptForCombat	// leave script when acquire enemy
};

// --- Variables ---
var EAlertnessType Alertness;

// --- Functions ---
function bool InitActionFor(ScriptedController C) {}
function string GetActionString() {}

defaultproperties
{
}
