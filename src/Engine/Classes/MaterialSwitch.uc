//=============================================================================
// MaterialSwitch - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class MaterialSwitch extends Modifier
    native
	editinlinenew
    collapsecategories
    hidecategories(Object,Material,Modifier);

var() int Current;
var() editinline array<editinline Material> Materials;

function Trigger(Actor Other, Actor EventInstigator)
{
	__NFUN_165__(Current);
	// End:0x1E
	if(__NFUN_153__(Current, Materials.Length))
	{
		Current = 0;
	}
	Material = Materials[Current];
	// End:0x53
	if(__NFUN_119__(Material, none))
	{
		Material.Trigger(Other, EventInstigator);
	}
	// End:0x77
	if(__NFUN_119__(FallbackMaterial, none))
	{
		FallbackMaterial.Trigger(Other, EventInstigator);
	}
	return;
}

