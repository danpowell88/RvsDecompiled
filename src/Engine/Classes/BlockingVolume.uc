//=============================================================================
// BlockingVolume - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// BlockingVolume:  a bounding volume
// used to block certain classes of actors
// primary use is to provide collision for non-zero extent traces around static meshes 

//=============================================================================
class BlockingVolume extends Volume
	native
 notplaceable;

defaultproperties
{
	bWorldGeometry=true
	bBlockActors=true
	bBlockPlayers=true
}
