//=============================================================================
// ShadowBitmapMaterial - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ShadowBitmapMaterial extends BitmapMaterial
	native
	collapsecategories
 hidecategories(Object);

//R6SHADOW
var byte m_bOpacity;
var bool Dirty;
var bool m_bValid;
var float LightDistance;
// NEW IN 1.60
var float LightFOV;
var Actor ShadowActor;
var Vector LightDirection;
var Vector m_LightLocation;
var const transient int TextureInterfaces[2];

defaultproperties
{
	m_bOpacity=128
	Dirty=true
	Format=5
	UClampMode=1
	VClampMode=1
	UBits=7
	VBits=7
	USize=128
	VSize=128
	UClamp=128
	VClamp=128
}
