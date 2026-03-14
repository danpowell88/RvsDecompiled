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
	if(__NFUN_130__(__NFUN_114__(NextScript, none), __NFUN_255__(NextScriptTag, 'None')))
	{
		// End:0x3E
		foreach S.__NFUN_313__(Class'Gameplay.ScriptedSequence', NextScript, NextScriptTag)
		{
			// End:0x3E
			break;			
		}		
		// End:0x83
		if(__NFUN_114__(NextScript, none))
		{
			__NFUN_232__(__NFUN_112__(__NFUN_112__(__NFUN_112__("No Next script found for ", string(self)), " in "), string(S)));
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
