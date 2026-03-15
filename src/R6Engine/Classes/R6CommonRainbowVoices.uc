//=============================================================================
// R6CommonRainbowVoices - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6CommonRainbowVoices extends R6Voices;

var Sound m_sndTerroristDown;
var Sound m_sndTakeWound;
var Sound m_sndGoesDown;
var Sound m_sndEntersSmoke;
var Sound m_sndEntersGas;
// NEW IN 1.60
var Sound m_sndCoughOxygene;
// NEW IN 1.60
var Sound m_sndSuffocation;

function PlayCommonRainbowVoices(R6Pawn aPawn, Pawn.ECommonRainbowVoices eRainbowVoices)
{
	switch(eRainbowVoices)
	{
		// End:0x26
		case 0:
			aPawn.PlayVoices(m_sndTerroristDown, 8, 10, 1);
			// End:0xCC
			break;
		// End:0x45
		case 1:
			aPawn.PlayVoices(m_sndTakeWound, 6, 5, 2);
			// End:0xCC
			break;
		// End:0x64
		case 2:
			aPawn.PlayVoices(m_sndGoesDown, 6, 5, 2);
			// End:0xCC
			break;
		// End:0x6C
		case 3:
			// End:0xCC
			break;
		// End:0x8B
		case 4:
			aPawn.PlayVoices(m_sndEntersGas, 6, 5, 2);
			// End:0xCC
			break;
		// End:0xAA
		case 5:
			aPawn.PlayVoices(m_sndCoughOxygene, 6, 5, 2);
			// End:0xCC
			break;
		// End:0xC9
		case 6:
			aPawn.PlayVoices(m_sndSuffocation, 6, 5, 2);
			// End:0xCC
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

