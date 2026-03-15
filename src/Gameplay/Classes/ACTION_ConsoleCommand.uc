//=============================================================================
// ACTION_ConsoleCommand - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  Class:  GamePlay.Action_ConsoleCommand
//  Parent: GamePlay.ScriptedAction
//
//  Executes a console command
// ====================================================================
class ACTION_ConsoleCommand extends ScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var(Action) string CommandStr;  // The console command to execute

function bool InitActionFor(ScriptedController C)
{
	// End:0x21
	if((CommandStr != ""))
	{
		C.ConsoleCommand(CommandStr);
	}
	return false;
	return;
}

function string GetActionString()
{
	return (ActionString @ CommandStr);
	return;
}

defaultproperties
{
	ActionString="console command"
}
