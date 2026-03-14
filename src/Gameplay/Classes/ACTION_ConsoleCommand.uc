//=============================================================================
// ACTION_ConsoleCommand - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
// ====================================================================
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
	if(__NFUN_123__(CommandStr, ""))
	{
		C.ConsoleCommand(CommandStr);
	}
	return false;
	return;
}

function string GetActionString()
{
	return __NFUN_168__(ActionString, CommandStr);
	return;
}

defaultproperties
{
	ActionString="console command"
}
