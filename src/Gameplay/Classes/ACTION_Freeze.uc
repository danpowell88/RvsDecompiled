//=============================================================================
// ACTION_Freeze - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_Freeze extends LatentScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

function bool InitActionFor(ScriptedController C)
{
	// End:0x5D
	if(__NFUN_119__(C.Pawn, none))
	{
		C.Pawn.bPhysicsAnimUpdate = false;
		C.Pawn.StopAnimating();
		C.Pawn.__NFUN_3970__(0);
	}
	C.CurrentAction = self;
	return true;
	return;
}

defaultproperties
{
	ActionString="Freeze"
}
