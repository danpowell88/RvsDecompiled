//=============================================================================
// ACTION_WaitForAnimEnd - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_WaitForAnimEnd extends LatentScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var(Action) int Channel;

function bool CompleteOnAnim(int Num)
{
	return (Channel == Num);
	return;
}

defaultproperties
{
	bValidForTrigger=false
	ActionString="Wait for animend"
}
