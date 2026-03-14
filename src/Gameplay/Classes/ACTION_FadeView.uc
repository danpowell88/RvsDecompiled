//=============================================================================
// ACTION_FadeView - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ACTION_FadeView extends LatentScriptedAction
	editinlinenew
    collapsecategories
    hidecategories(Object);

var(Action) float FadeTime;
var(Action) Vector TargetFlash;

function bool InitActionFor(ScriptedController C)
{
	return true;
	return;
}

function string GetActionString()
{
	return __NFUN_168__(ActionString, string(FadeTime));
	return;
}

function bool TickedAction()
{
	return true;
	return;
}

function bool StillTicking(ScriptedController C, float DeltaTime)
{
	local bool bXDone, bYDone, bZDone;
	local Vector V;

	V = __NFUN_216__(C.GetInstigator().PhysicsVolume.ViewFlash, __NFUN_212__(__NFUN_216__(C.Instigator.PhysicsVolume.default.ViewFlash, TargetFlash), __NFUN_172__(DeltaTime, FadeTime)));
	// End:0x94
	if(__NFUN_176__(V.X, TargetFlash.X))
	{
		V.X = TargetFlash.X;
		bXDone = true;
	}
	// End:0xCA
	if(__NFUN_176__(V.Y, TargetFlash.Y))
	{
		V.Y = TargetFlash.Y;
		bYDone = true;
	}
	// End:0x100
	if(__NFUN_176__(V.Z, TargetFlash.Z))
	{
		V.Z = TargetFlash.Z;
		bZDone = true;
	}
	C.GetInstigator().PhysicsVolume.ViewFlash = V;
	// End:0x148
	if(__NFUN_130__(__NFUN_130__(bXDone, bYDone), bZDone))
	{
		return false;
	}
	return true;
	return;
}

defaultproperties
{
	FadeTime=5.0000000
	TargetFlash=(X=-2.0000000,Y=-2.0000000,Z=-2.0000000)
	ActionString="fade view"
}
