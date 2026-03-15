//=============================================================================
// DefaultPhysicsVolume - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// DefaultPhysicsVolume:  the default physics volume for areas of the level with 
// no physics volume specified
//=============================================================================
class DefaultPhysicsVolume extends PhysicsVolume
    native
    notplaceable;

function Destroyed()
{
	Log((string(self) $ " destroyed!"));
	assert(false);
	return;
}

defaultproperties
{
	RemoteRole=0
	bStatic=false
	bNoDelete=false
	bAlwaysRelevant=false
}
