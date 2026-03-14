// Scripted action that plays a named base animation on the pawn with configurable blend
// times, playback rate, iteration count, and looping.
// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class Action_PLAYANIM extends ScriptedAction;

// --- Variables ---
var name BaseAnim;
var float AnimRate;
var float BlendInTime;
var byte AnimIterations;
var bool bLoopAnim;
var float BlendOutTime;

// --- Functions ---
function SetCurrentAnimationFor(ScriptedController C) {}
function bool InitActionFor(ScriptedController C) {}
// ^ NEW IN 1.60
function bool PawnPlayBaseAnim(ScriptedController C, bool bFirstPlay) {}
// ^ NEW IN 1.60
function string GetActionString() {}
// ^ NEW IN 1.60

defaultproperties
{
}
