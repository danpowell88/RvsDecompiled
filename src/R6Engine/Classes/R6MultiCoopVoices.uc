//=============================================================================
// R6MultiCoopVoices - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6MultiCoopVoices extends R6Voices;

var Sound m_sndPlacingBug;
var Sound m_sndBugActivated;
var Sound m_sndAccessingComputer;
var Sound m_sndComputerHacked;
var Sound m_sndEscortingHostage;
var Sound m_sndHostageSecured;
var Sound m_sndPlacingExplosives;
var Sound m_sndExplosivesReady;
var Sound m_sndDesactivatingSecurity;
var Sound m_sndSecurityDeactivated;

function PlayRainbowTeamVoices(R6Pawn aPawn, Pawn.ERainbowTeamVoices eVoices)
{
	switch(eVoices)
	{
		// End:0x27
		case 0:
			aPawn.__NFUN_2730__(m_sndPlacingBug, 8, 10, 0, true);
			// End:0x14A
			break;
		// End:0x47
		case 1:
			aPawn.__NFUN_2730__(m_sndBugActivated, 8, 10, 0, true);
			// End:0x14A
			break;
		// End:0x67
		case 2:
			aPawn.__NFUN_2730__(m_sndAccessingComputer, 8, 10, 0, true);
			// End:0x14A
			break;
		// End:0x87
		case 3:
			aPawn.__NFUN_2730__(m_sndComputerHacked, 8, 10, 0, true);
			// End:0x14A
			break;
		// End:0xA7
		case 4:
			aPawn.__NFUN_2730__(m_sndEscortingHostage, 8, 10, 0, true);
			// End:0x14A
			break;
		// End:0xC7
		case 5:
			aPawn.__NFUN_2730__(m_sndHostageSecured, 8, 10, 2, true);
			// End:0x14A
			break;
		// End:0xE7
		case 6:
			aPawn.__NFUN_2730__(m_sndPlacingExplosives, 8, 10, 0, true);
			// End:0x14A
			break;
		// End:0x107
		case 7:
			aPawn.__NFUN_2730__(m_sndExplosivesReady, 8, 10, 0, true);
			// End:0x14A
			break;
		// End:0x127
		case 8:
			aPawn.__NFUN_2730__(m_sndDesactivatingSecurity, 8, 10, 0, true);
			// End:0x14A
			break;
		// End:0x147
		case 9:
			aPawn.__NFUN_2730__(m_sndSecurityDeactivated, 8, 10, 0, true);
			// End:0x14A
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

