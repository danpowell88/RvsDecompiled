//=============================================================================
// ACTION_IfRandomPct - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_IfRandomPct extends ScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var(Action) float Probability;

function ProceedToNextAction(ScriptedController C)
{
	(C.ActionNum += 1);
	// End:0x28
	if((FRand() > Probability))
	{
		ProceedToSectionEnd(C);
	}
	return;
}

function bool StartsSection()
{
	return true;
	return;
}

