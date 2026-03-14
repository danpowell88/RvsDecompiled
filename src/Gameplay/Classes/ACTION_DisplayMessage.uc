//=============================================================================
// ACTION_DisplayMessage - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_DisplayMessage extends ScriptedAction
	editinlinenew
	collapsecategories
 hidecategories(Object);

var(Action) bool bBroadcast;
var(Action) name messagetype;
var(Action) string Message;

function bool InitActionFor(ScriptedController C)
{
	// End:0x46
	if(bBroadcast)
	{
		C.Level.Game.Broadcast(C.GetInstigator(), Message, messagetype);		
	}
	else
	{
		C.GetInstigator().ClientMessage(Message, messagetype);
	}
	return false;
	return;
}

function string GetActionString()
{
	return __NFUN_168__(ActionString, Message);
	return;
}

defaultproperties
{
	messagetype="CriticalEvent"
	ActionString="display message"
}
