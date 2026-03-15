//=============================================================================
// Modifier - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class Modifier extends Material
    abstract
    native
	editinlinenew
    collapsecategories
    hidecategories(Object,Material);

var() editinlineuse Material Material;

function Trigger(Actor Other, Actor EventInstigator)
{
	// End:0x24
	if((Material != none))
	{
		Material.Trigger(Other, EventInstigator);
	}
	// End:0x48
	if((FallbackMaterial != none))
	{
		FallbackMaterial.Trigger(Other, EventInstigator);
	}
	return;
}

