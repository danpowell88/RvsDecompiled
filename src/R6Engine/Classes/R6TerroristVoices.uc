//=============================================================================
// R6TerroristVoices - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6TerroristVoices extends R6Voices;

var Sound m_sndWounded;
var Sound m_sndTaunt;
var Sound m_sndSurrender;
var Sound m_sndSeesTearGas;
var Sound m_sndRunAway;
var Sound m_sndGrenade;
var Sound m_sndCoughsSmoke;
var Sound m_sndCoughsGas;
var Sound m_sndBackup;
var Sound m_sndSeesSurrenderedHostage;
var Sound m_sndSeesRainbow_LowAlert;
var Sound m_sndSeesRainbow_HighAlert;
var Sound m_sndSeesFreeHostage;
var Sound m_sndHearsNoize;

function PlayTerroristVoices(R6Pawn aPawn, Pawn.ETerroristVoices eTerroSound)
{
	// End:0x19A
	if((aPawn != none))
	{
		switch(eTerroSound)
		{
			// End:0x31
			case 0:
				aPawn.PlayVoices(m_sndWounded, 6, 5, 2);
				// End:0x19A
				break;
			// End:0x4E
			case 1:
				aPawn.PlayVoices(m_sndTaunt, 6, 10);
				// End:0x19A
				break;
			// End:0x6B
			case 2:
				aPawn.PlayVoices(m_sndSurrender, 6, 10);
				// End:0x19A
				break;
			// End:0x88
			case 3:
				aPawn.PlayVoices(m_sndSeesTearGas, 6, 10);
				// End:0x19A
				break;
			// End:0xA5
			case 4:
				aPawn.PlayVoices(m_sndRunAway, 6, 10);
				// End:0x19A
				break;
			// End:0xC2
			case 5:
				aPawn.PlayVoices(m_sndGrenade, 6, 10);
				// End:0x19A
				break;
			// End:0xCA
			case 6:
				// End:0x19A
				break;
			// End:0xE9
			case 7:
				aPawn.PlayVoices(m_sndCoughsGas, 6, 10, 2);
				// End:0x19A
				break;
			// End:0x106
			case 8:
				aPawn.PlayVoices(m_sndBackup, 6, 10);
				// End:0x19A
				break;
			// End:0x123
			case 9:
				aPawn.PlayVoices(m_sndSeesSurrenderedHostage, 6, 10);
				// End:0x19A
				break;
			// End:0x140
			case 10:
				aPawn.PlayVoices(m_sndSeesRainbow_LowAlert, 6, 10);
				// End:0x19A
				break;
			// End:0x15D
			case 11:
				aPawn.PlayVoices(m_sndSeesRainbow_HighAlert, 6, 10);
				// End:0x19A
				break;
			// End:0x17A
			case 12:
				aPawn.PlayVoices(m_sndSeesFreeHostage, 6, 10);
				// End:0x19A
				break;
			// End:0x197
			case 13:
				aPawn.PlayVoices(m_sndHearsNoize, 6, 10);
				// End:0x19A
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		return;
	}
}

