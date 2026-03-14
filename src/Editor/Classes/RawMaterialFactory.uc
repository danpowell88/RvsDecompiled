//=============================================================================
// RawMaterialFactory - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class RawMaterialFactory extends MaterialFactory;

var() Class<Material> MaterialClass;

function Material CreateMaterial(Object InOuter, string InPackage, string InGroup, string InName)
{
	// End:0x0D
	if(__NFUN_114__(MaterialClass, none))
	{
		return none;
	}
	return new (InOuter, InName, __NFUN_146__(4, 524288)) MaterialClass;
	return;
}

defaultproperties
{
	MaterialClass=Class'Engine.Shader'
	Description="Raw Material"
}
