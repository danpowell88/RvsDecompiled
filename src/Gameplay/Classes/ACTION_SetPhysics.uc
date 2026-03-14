// Scripted action that changes the physics simulation mode of the instigating actor
// (e.g. PHYS_Flying, PHYS_Falling, PHYS_None).
// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class ACTION_SetPhysics extends ScriptedAction;

// --- Variables ---
var EPhysics NewPhysicsMode;

// --- Functions ---
function bool InitActionFor(ScriptedController C) {}
function string GetActionString() {}

defaultproperties
{
}
