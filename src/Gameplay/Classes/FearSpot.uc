//=============================================================================
// FearSpot.
// Creatures will tend to back away when entering this spot
// To be effective, there should also not be any paths going through the area
//=============================================================================
class FearSpot extends Triggers;

var() bool bInitiallyActive;

function Touch( actor Other )
{
	if ( bInitiallyActive && (Pawn(Other) != None) && (Pawn(Other).Controller != None) )
		Pawn(Other).Controller.FearThisSpot(self);
}

function Trigger( actor Other, pawn EventInstigator )
{
	bInitiallyActive = !bInitiallyActive;
}

defaultproperties
{
     RemoteRole=ROLE_None
     CollisionRadius=200.000000
}
