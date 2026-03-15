//=============================================================================
// Action_PLAYANIM - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class Action_PLAYANIM extends ScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var(Action) byte AnimIterations;
var(Action) bool bLoopAnim;
var(Action) float BlendInTime;
var(Action) float BlendOutTime;
var(Action) float AnimRate;
var(Action) name BaseAnim;

function bool InitActionFor(ScriptedController C)
{
	C.AnimsRemaining = int(AnimIterations);
	// End:0x35
	if(PawnPlayBaseAnim(C, true))
	{
		C.CurrentAnimation = self;
	}
	return false;
	return;
}

function SetCurrentAnimationFor(ScriptedController C)
{
	// End:0x2C
	if(C.Pawn.IsAnimating(0))
	{
		C.CurrentAnimation = self;		
	}
	else
	{
		C.CurrentAnimation = none;
	}
	return;
}

function bool PawnPlayBaseAnim(ScriptedController C, bool bFirstPlay)
{
	// End:0x22
	if(((BaseAnim == 'None') || (BaseAnim == 'None')))
	{
		return false;
	}
	C.bControlAnimations = true;
	// End:0x63
	if(bFirstPlay)
	{
		C.Pawn.PlayAnim(BaseAnim, AnimRate, BlendInTime);		
	}
	else
	{
		// End:0xA4
		if((bLoopAnim || (C.AnimsRemaining > 0)))
		{
			C.Pawn.LoopAnim(BaseAnim, AnimRate);			
		}
		else
		{
			return false;
		}
	}
	return true;
	return;
}

function string GetActionString()
{
	return (ActionString @ string(BaseAnim));
	return;
}

defaultproperties
{
	BlendInTime=0.2000000
	BlendOutTime=0.2000000
	AnimRate=1.0000000
	bValidForTrigger=false
	ActionString="play animation"
}
