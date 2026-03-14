//=============================================================================
// ACTION_FreezeOnAnimEnd - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_FreezeOnAnimEnd extends Action_PLAYANIM
	editinlinenew
	collapsecategories
 hidecategories(Object);

function bool InitActionFor(ScriptedController C)
{
	C.CurrentAnimation = self;
	return true;
	return;
}

function SetCurrentAnimationFor(ScriptedController C)
{
	C.CurrentAnimation = self;
	return;
}

function bool PawnPlayBaseAnim(ScriptedController C, bool bFirstPlay)
{
	// End:0x5D
	if(__NFUN_119__(C.Pawn, none))
	{
		C.Pawn.bPhysicsAnimUpdate = false;
		C.Pawn.StopAnimating();
		C.Pawn.__NFUN_3970__(0);
	}
	return true;
	return;
}

