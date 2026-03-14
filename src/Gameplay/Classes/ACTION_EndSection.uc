// Scripted action that marks the end of a looping section.  If IterationCounter > 0 it
// decrements the counter and jumps back to IterationSectionStart; otherwise continues.
// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class ACTION_EndSection extends ScriptedAction;

// --- Functions ---
function ProceedToNextAction(ScriptedController C) {}
function bool EndsSection() {}
// ^ NEW IN 1.60

defaultproperties
{
}
