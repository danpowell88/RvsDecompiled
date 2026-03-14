//=============================================================================
// Info - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// Info, the root of all information holding classes.
//=============================================================================
class Info extends Actor
	abstract
	native
	notplaceable
 hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

defaultproperties
{
	bHidden=true
	bSkipActorPropertyReplication=true
	bOnlyDirtyReplication=true
	NetUpdateFrequency=5.0000000
}
