//=============================================================================
// ScriptedAction - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ScriptedAction extends Object
    abstract
	editinlinenew
    collapsecategories
    hidecategories(Object);

var bool bValidForTrigger;
var localized string ActionString;

function bool InitActionFor(ScriptedController C)
{
	return false;
	return;
}

function bool EndsSection()
{
	return false;
	return;
}

function bool StartsSection()
{
	return false;
	return;
}

function ScriptedSequence GetScript(ScriptedSequence S)
{
	return S;
	return;
}

function ProceedToNextAction(ScriptedController C)
{
	(C.ActionNum += 1);
	return;
}

function ProceedToSectionEnd(ScriptedController C)
{
	local int Nesting;
	local ScriptedAction A;

	J0x00:
	// End:0xAD [Loop If]
	if((C.ActionNum < C.SequenceScript.Actions.Length))
	{
		A = C.SequenceScript.Actions[C.ActionNum];
		// End:0x73
		if(A.StartsSection())
		{
			(Nesting++);			
		}
		else
		{
			// End:0x99
			if(A.EndsSection())
			{
				(Nesting--);
				// End:0x99
				if((Nesting < 0))
				{
					return;
				}
			}
		}
		(C.ActionNum += 1);
		// [Loop Continue]
		goto J0x00;
	}
	return;
}

function string GetActionString()
{
	return ActionString;
	return;
}

defaultproperties
{
	bValidForTrigger=true
	ActionString="unspecified action"
}
