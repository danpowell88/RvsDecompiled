//=============================================================================
// Scout - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// Scout used for path generation.
//=============================================================================
class Scout extends Pawn
    native
    notplaceable;

var const float MaxLandingVelocity;

function PreBeginPlay()
{
	Destroy();
	return;
}

defaultproperties
{
	AccelRate=1.0000000
	bCollideActors=false
	bCollideWorld=false
	bBlockActors=false
	bBlockPlayers=false
	bProjTarget=false
	bPathColliding=true
	CollisionRadius=52.0000000
}
