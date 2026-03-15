//=============================================================================
// ACTION_ChangeScript - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_ChangeScript extends ScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var ScriptedSequence NextScript;
var(Action) name NextScriptTag;

function ScriptedSequence GetScript(ScriptedSequence S)
{
	// End:0x83
	if(((NextScript == none) && (NextScriptTag != 'None')))
	{
		// End:0x3E
		foreach S.DynamicActors(Class'Gameplay.ScriptedSequence', NextScript, NextScriptTag)
		{
			// End:0x3E
			break;			
		}		
		// End:0x83
		if((NextScript == none))
		{
			Warn(((("No Next script found for " $ string(self)) $ " in ") $ string(S)));
			return S;
		}
	}
	return NextScript;
	return;
}

function bool InitActionFor(ScriptedController C)
{
	C.bBroken = true;
	return true;
	return;
}

defaultproperties
{
	bValidForTrigger=false
	ActionString="Change script"
}
