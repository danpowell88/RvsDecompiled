// Scripted action that displays a text message on the HUD.
// When bBroadcast is true the message is sent to all connected players.
// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class ACTION_DisplayMessage extends ScriptedAction;

// --- Variables ---
var string Message;
var name messagetype;
var bool bBroadcast;

// --- Functions ---
function bool InitActionFor(ScriptedController C) {}
function string GetActionString() {}

defaultproperties
{
}
