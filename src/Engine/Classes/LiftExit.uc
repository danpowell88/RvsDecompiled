//=============================================================================
// LiftExit - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// LiftExit.
//=============================================================================
class LiftExit extends NavigationPoint
    native
    placeable
    hidecategories(Lighting,LightColor,Karma,Force);

var() byte SuggestedKeyFrame;  // mover keyframe associated with this exit - optional
var byte KeyFrame;
var Mover MyLift;
var() name LiftTag;

function bool SuggestMovePreparation(Pawn Other)
{
	// End:0xB8
	if(((Other.Base == MyLift) && (MyLift != none)))
	{
		// End:0x73
		if(((self.Location.Z < (Other.Location.Z + Other.CollisionHeight)) && Other.LineOfSightTo(self)))
		{
			return false;
		}
		Other.DesiredRotation = Rotator((Location - Other.Location));
		Other.Controller.WaitForMover(MyLift);
		return true;
	}
	return false;
	return;
}

defaultproperties
{
	SuggestedKeyFrame=255
	bNeverUseStrafing=true
	bForceNoStrafing=true
	bSpecialMove=true
	Texture=Texture'Engine.S_LiftExit'
}
