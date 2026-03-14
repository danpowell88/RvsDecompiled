//=============================================================================
// ACTION_EndSection - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_EndSection extends ScriptedAction
	editinlinenew
	collapsecategories
 hidecategories(Object);

function ProceedToNextAction(ScriptedController C)
{
	// End:0x44
	if(__NFUN_151__(C.IterationCounter, 0))
	{
		C.ActionNum = C.IterationSectionStart;
		__NFUN_166__(C.IterationCounter);		
	}
	else
	{
		__NFUN_161__(C.ActionNum, 1);
		C.IterationSectionStart = -1;
	}
	return;
}

function bool EndsSection()
{
	return true;
	return;
}

defaultproperties
{
	ActionString="end section"
}
