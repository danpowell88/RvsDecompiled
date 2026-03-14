//=============================================================================
// Light - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// The light class.
//=============================================================================
class Light extends Actor
	native
 placeable;

defaultproperties
{
	LightType=1
	LightSaturation=255
	LightPeriod=32
	LightCone=128
	bStatic=true
	bHidden=true
	bNoDelete=true
	bMovable=false
	CollisionRadius=24.0000000
	CollisionHeight=24.0000000
	LightBrightness=64.0000000
	LightRadius=64.0000000
	Texture=Texture'Engine.S_Light'
}
