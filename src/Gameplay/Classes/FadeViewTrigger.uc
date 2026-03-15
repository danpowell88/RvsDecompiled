//=============================================================================
// FadeViewTrigger - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class FadeViewTrigger extends Triggers;

var() bool bTriggerOnceOnly;
var bool bTriggered;
var() float FadeSeconds;
var(ZoneLight) Vector ViewFlash;
// NEW IN 1.60
var(ZoneLight) Vector ViewFog;
var() Vector TargetFlash;
var Vector OldViewFlash;

event Trigger(Actor Other, Pawn EventInstigator)
{
	// End:0x35
	if((bTriggered && (!bTriggerOnceOnly)))
	{
		bTriggered = false;
		PhysicsVolume.ViewFlash = OldViewFlash;		
	}
	else
	{
		bTriggered = true;
		OldViewFlash = PhysicsVolume.ViewFlash;
		GotoState('IsTriggered');
	}
	return;
}

state IsTriggered
{
	event Tick(float DeltaTime)
	{
		local Vector V;
		local bool bXDone, bYDone, bZDone;

		// End:0x12D
		if(bTriggered)
		{
			bXDone = false;
			bYDone = false;
			bZDone = false;
			V = (PhysicsVolume.ViewFlash - ((OldViewFlash - TargetFlash) * (DeltaTime / FadeSeconds)));
			// End:0x87
			if((V.X < TargetFlash.X))
			{
				V.X = TargetFlash.X;
				bXDone = true;
			}
			// End:0xBD
			if((V.Y < TargetFlash.Y))
			{
				V.Y = TargetFlash.Y;
				bYDone = true;
			}
			// End:0xF3
			if((V.Z < TargetFlash.Z))
			{
				V.Z = TargetFlash.Z;
				bZDone = true;
			}
			PhysicsVolume.ViewFlash = V;
			// End:0x12D
			if(((bXDone && bYDone) && bZDone))
			{
				GotoState('None');
			}
		}
		return;
	}
	stop;
}

defaultproperties
{
	FadeSeconds=5.0000000
	TargetFlash=(X=-2.0000000,Y=-2.0000000,Z=-2.0000000)
	bObsolete=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var g
