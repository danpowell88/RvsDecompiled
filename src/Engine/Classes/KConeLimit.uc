//=============================================================================
// KConeLimit - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// The Cone Limit joint class.
//=============================================================================

#exec Texture Import File=Textures\S_KConeLimit.pcx Name=S_KConeLimit Mips=Off MASKED=1
class KConeLimit extends KConstraint
    native
    placeable;

var(KarmaConstraint) float KHalfAngle;  // ( 65535 = 360 deg )
var(KarmaConstraint) float KStiffness;
var(KarmaConstraint) float KDamping;

defaultproperties
{
	KHalfAngle=8200.0000000
	KStiffness=50.0000000
	bDirectional=true
	Texture=Texture'Engine.S_KConeLimit'
}
