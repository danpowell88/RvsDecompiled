//=============================================================================
// ACTION_ChangeLevel - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_ChangeLevel extends ScriptedAction
	editinlinenew
	collapsecategories
 hidecategories(Object);

var(Action) bool bShowLoadingMessage;
var(Action) string URL;

function bool InitActionFor(ScriptedController C)
{
	// End:0x2A
	if(bShowLoadingMessage)
	{
		C.Level.ServerTravel(URL, false);		
	}
	else
	{
		C.Level.ServerTravel(__NFUN_112__(URL, "?quiet"), false);
	}
	return true;
	return;
}

function string GetActionString()
{
	return ActionString;
	return;
}

defaultproperties
{
	ActionString="Change level"
}
