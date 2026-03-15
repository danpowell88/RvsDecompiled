//=============================================================================
// MaterialTrigger - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class MaterialTrigger extends Triggers
    placeable;

var() array<Material> MaterialsToTrigger;

function Trigger(Actor Other, Pawn EventInstigator)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x51 [Loop If]
	if((i < MaterialsToTrigger.Length))
	{
		// End:0x47
		if((MaterialsToTrigger[i] != none))
		{
			MaterialsToTrigger[i].Trigger(Other, EventInstigator);
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

defaultproperties
{
	bCollideActors=false
	Texture=Texture'Engine.S_MaterialTrigger'
}
