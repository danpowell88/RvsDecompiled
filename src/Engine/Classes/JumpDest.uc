//=============================================================================
// JumpDest - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// JumpDest.
// specifies positions that can be reached with greater than normal jump
// forced paths will check for greater than normal jump capability
// NOTE these have NO relation to JumpPads
//=============================================================================
class JumpDest extends NavigationPoint
    native
    notplaceable
    hidecategories(Lighting,LightColor,Karma,Force);

var int NumUpstreamPaths;
var ReachSpec UpstreamPaths[8];
var Vector NeededJump[8];

function int GetPathIndex(ReachSpec Path)
{
	local int i;

	// End:0x0D
	if((Path == none))
	{
		return 0;
	}
	i = 0;
	J0x14:

	// End:0x45 [Loop If]
	if((i < 4))
	{
		// End:0x3B
		if((UpstreamPaths[i] == Path))
		{
			return i;
		}
		(i++);
		// [Loop Continue]
		goto J0x14;
	}
	return 0;
	return;
}

event int SpecialCost(Pawn Other, ReachSpec Path)
{
	local int Num;

	Num = GetPathIndex(Path);
	// End:0x77
	if((Abs((Other.JumpZ / Other.PhysicsVolume.Gravity.Z)) >= Abs((NeededJump[Num].Z / Other.PhysicsVolume.default.Gravity.Z))))
	{
		return 100;
	}
	return 10000000;
	return;
}

event bool SuggestMovePreparation(Pawn Other)
{
	local int Num;

	// End:0x16
	if((Other.Controller == none))
	{
		return false;
	}
	Num = GetPathIndex(Other.Controller.CurrentPath);
	// End:0x9E
	if((Abs((Other.JumpZ / Other.PhysicsVolume.Gravity.Z)) < Abs((NeededJump[Num].Z / Other.PhysicsVolume.default.Gravity.Z))))
	{
		return false;
	}
	Other.Controller.MoveTarget = self;
	Other.Controller.Destination = Location;
	Other.bNoJumpAdjust = true;
	Other.Velocity = NeededJump[Num];
	Other.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
	Other.SetPhysics(2);
	Other.Controller.SetFall();
	Other.DestinationOffset = CollisionRadius;
	return false;
	return;
}

defaultproperties
{
	bSpecialForced=true
}
