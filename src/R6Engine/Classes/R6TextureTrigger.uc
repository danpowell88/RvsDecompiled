//=============================================================================
// R6TextureTrigger - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6TextureTrigger extends Trigger;

var(R6Trigger) Actor ActorToChange;
var(R6Trigger) array<Material> Skins;

function Touch(Actor Other)
{
	local int iSkinCount;

	super.Touch(Other);
	// End:0x57
	if(__NFUN_119__(ActorToChange, none))
	{
		iSkinCount = 0;
		J0x1D:

		// End:0x57 [Loop If]
		if(__NFUN_150__(iSkinCount, Skins.Length))
		{
			ActorToChange.Skins[iSkinCount] = Skins[iSkinCount];
			__NFUN_165__(iSkinCount);
			// [Loop Continue]
			goto J0x1D;
		}
	}
	return;
}

