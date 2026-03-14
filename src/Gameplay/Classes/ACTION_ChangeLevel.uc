// Scripted action that performs a server-side level transition to the given URL.
// Used in mission scripts to chain levels together or trigger mission-end sequences.
// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class ACTION_ChangeLevel extends ScriptedAction;

// --- Variables ---
var string URL;
var bool bShowLoadingMessage;

// --- Functions ---
function bool InitActionFor(ScriptedController C) {}
function string GetActionString() {}

defaultproperties
{
}
