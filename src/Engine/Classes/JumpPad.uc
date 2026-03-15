//=============================================================================
// JumpPad - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================
// Jumppad - bounces players/bots up
// not directly placeable.  Make a subclass with appropriate sound effect etc.
//
class JumpPad extends NavigationPoint
    native
    placeable
    hidecategories(Lighting,LightColor,Karma,Force);

var Actor JumpTarget;
var Vector JumpVelocity;
var() Vector JumpModifier;  // for tweaking JumpVelocity, if needed

event Touch(Actor Other)
{
	// End:0x12
	if((Pawn(Other) == none))
	{
		return;
	}
	PendingTouch = Other.PendingTouch;
	Other.PendingTouch = self;
	return;
}

event PostTouch(Actor Other)
{
	local Pawn P;

	P = Pawn(Other);
	// End:0x1D
	if((P == none))
	{
		return;
	}
	// End:0xAA
	if((AIController(P.Controller) != none))
	{
		P.Controller.MoveTarget = JumpTarget;
		P.Controller.Focus = JumpTarget;
		P.Controller.MoveTimer = 2.0000000;
		P.DestinationOffset = JumpTarget.CollisionRadius;
	}
	// End:0xD1
	if((int(P.Physics) == int(1)))
	{
		P.SetPhysics(2);
	}
	P.Velocity = (JumpVelocity + JumpModifier);
	P.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
	return;
}

defaultproperties
{
	JumpVelocity=(X=0.0000000,Y=0.0000000,Z=150.0000000)
	bDestinationOnly=true
	bCollideActors=true
}
