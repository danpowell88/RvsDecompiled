// Scripted action that plays an animation (inheriting from Action_PLAYANIM) and then
// freezes the pawn in place when the animation finishes.
// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class ACTION_FreezeOnAnimEnd extends Action_PLAYANIM;

// --- Functions ---
function SetCurrentAnimationFor(ScriptedController C) {}
function bool InitActionFor(ScriptedController C) {}
// ^ NEW IN 1.60
function bool PawnPlayBaseAnim(ScriptedController C, bool bFirstPlay) {}
// ^ NEW IN 1.60

defaultproperties
{
}
