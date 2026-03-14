//=============================================================================
// Camera - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// A camera, used in UnrealEd.
//=============================================================================
class Camera extends PlayerController
    native
    config(User)
    notplaceable;

defaultproperties
{
	bDirectional=true
	CollisionRadius=16.0000000
	CollisionHeight=39.0000000
	LightBrightness=100.0000000
	LightRadius=16.0000000
	Texture=Texture'Engine.S_Camera'
	Location=(X=-500.0000000,Y=-300.0000000,Z=300.0000000)
}
