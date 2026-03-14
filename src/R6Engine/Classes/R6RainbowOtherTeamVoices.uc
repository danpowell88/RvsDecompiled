//=============================================================================
// R6RainbowOtherTeamVoices - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6RainbowOtherTeamVoices extends R6Voices;

var Sound m_sndSniperHasTarget;
var Sound m_sndSniperLooseTarget;
var Sound m_sndSniperTangoDown;
var Sound m_sndMemberDown;
var Sound m_sndRainbowHitRainbow;
var Sound m_sndObjective1;
var Sound m_sndObjective2;
var Sound m_sndObjective3;
var Sound m_sndObjective4;
var Sound m_sndObjective5;
var Sound m_sndObjective6;
var Sound m_sndObjective7;
var Sound m_sndObjective8;
var Sound m_sndObjective9;
var Sound m_sndObjective10;
var Sound m_sndWaitAlpha;
var Sound m_sndWaitBravo;
var Sound m_sndWaitCharlie;
var Sound m_sndWaitZulu;
var Sound m_sndEntersSmoke;
var Sound m_sndEntersGas;
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
var Sound m_sndStatusEngaging;
var Sound m_sndStatusMoving;
var Sound m_sndStatusWaiting;
var Sound m_sndStatusWaitAlpha;
var Sound m_sndStatusWaitBravo;
var Sound m_sndStatusWaitCharlie;
var Sound m_sndStatusWaitZulu;
var Sound m_sndStatusSniperWaitAlpha;
var Sound m_sndStatusSniperWaitBravo;
var Sound m_sndStatusSniperWaitCharlie;
var Sound m_sndStatusSniperUntilAlpha;
var Sound m_sndStatusSniperUntilBravo;
var Sound m_sndStatusSniperUntilCharlie;

function PlayRainbowOtherTeamVoices(R6Pawn aPawn, Pawn.ERainbowOtherTeamVoices eRainbowVoices)
{
	switch(eRainbowVoices)
	{
		// End:0x27
		case 0:
			aPawn.__NFUN_2730__(m_sndSniperHasTarget, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x47
		case 1:
			aPawn.__NFUN_2730__(m_sndSniperLooseTarget, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x67
		case 2:
			aPawn.__NFUN_2730__(m_sndSniperTangoDown, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x87
		case 3:
			aPawn.__NFUN_2730__(m_sndMemberDown, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0xA7
		case 4:
			aPawn.__NFUN_2730__(m_sndRainbowHitRainbow, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0xC7
		case 5:
			aPawn.__NFUN_2730__(m_sndObjective1, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0xE7
		case 6:
			aPawn.__NFUN_2730__(m_sndObjective2, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x107
		case 7:
			aPawn.__NFUN_2730__(m_sndObjective3, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x127
		case 8:
			aPawn.__NFUN_2730__(m_sndObjective4, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x147
		case 9:
			aPawn.__NFUN_2730__(m_sndObjective5, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x167
		case 10:
			aPawn.__NFUN_2730__(m_sndObjective6, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x187
		case 11:
			aPawn.__NFUN_2730__(m_sndObjective7, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x1A7
		case 12:
			aPawn.__NFUN_2730__(m_sndObjective8, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x1C7
		case 13:
			aPawn.__NFUN_2730__(m_sndObjective9, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x1E7
		case 14:
			aPawn.__NFUN_2730__(m_sndObjective10, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x207
		case 15:
			aPawn.__NFUN_2730__(m_sndWaitAlpha, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x227
		case 16:
			aPawn.__NFUN_2730__(m_sndWaitBravo, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x247
		case 17:
			aPawn.__NFUN_2730__(m_sndWaitCharlie, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x267
		case 18:
			aPawn.__NFUN_2730__(m_sndWaitZulu, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x26F
		case 19:
			// End:0x431
			break;
		// End:0x28E
		case 20:
			aPawn.__NFUN_2730__(m_sndEntersGas, 6, 5, 2);
			// End:0x431
			break;
		// End:0x2AE
		case 21:
			aPawn.__NFUN_2730__(m_sndStatusEngaging, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x2CE
		case 22:
			aPawn.__NFUN_2730__(m_sndStatusMoving, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x2EE
		case 23:
			aPawn.__NFUN_2730__(m_sndStatusWaiting, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x30E
		case 24:
			aPawn.__NFUN_2730__(m_sndStatusWaitAlpha, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x32E
		case 25:
			aPawn.__NFUN_2730__(m_sndStatusWaitBravo, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x34E
		case 26:
			aPawn.__NFUN_2730__(m_sndStatusWaitCharlie, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x36E
		case 27:
			aPawn.__NFUN_2730__(m_sndStatusWaitZulu, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x38E
		case 28:
			aPawn.__NFUN_2730__(m_sndStatusSniperWaitAlpha, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x3AE
		case 29:
			aPawn.__NFUN_2730__(m_sndStatusSniperWaitBravo, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x3CE
		case 30:
			aPawn.__NFUN_2730__(m_sndStatusSniperWaitCharlie, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x3EE
		case 31:
			aPawn.__NFUN_2730__(m_sndStatusSniperUntilAlpha, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x40E
		case 32:
			aPawn.__NFUN_2730__(m_sndStatusSniperUntilBravo, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0x42E
		case 33:
			aPawn.__NFUN_2730__(m_sndStatusSniperUntilCharlie, 8, 15, 0, true);
			// End:0x431
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

function PlayRainbowTeamVoices(R6Pawn aPawn, Pawn.ERainbowTeamVoices eRainbowVoices)
{
	switch(eRainbowVoices)
	{
		// End:0x27
		case 0:
			aPawn.__NFUN_2730__(m_sndPlacingBug, 8, 15, 0, true);
			// End:0x14A
			break;
		// End:0x47
		case 1:
			aPawn.__NFUN_2730__(m_sndBugActivated, 8, 15, 0, true);
			// End:0x14A
			break;
		// End:0x67
		case 2:
			aPawn.__NFUN_2730__(m_sndAccessingComputer, 8, 15, 0, true);
			// End:0x14A
			break;
		// End:0x87
		case 3:
			aPawn.__NFUN_2730__(m_sndComputerHacked, 8, 15, 0, true);
			// End:0x14A
			break;
		// End:0xA7
		case 4:
			aPawn.__NFUN_2730__(m_sndEscortingHostage, 8, 15, 0, true);
			// End:0x14A
			break;
		// End:0xC7
		case 5:
			aPawn.__NFUN_2730__(m_sndHostageSecured, 8, 15, 2, true);
			// End:0x14A
			break;
		// End:0xE7
		case 6:
			aPawn.__NFUN_2730__(m_sndPlacingExplosives, 8, 15, 0, true);
			// End:0x14A
			break;
		// End:0x107
		case 7:
			aPawn.__NFUN_2730__(m_sndExplosivesReady, 8, 15, 0, true);
			// End:0x14A
			break;
		// End:0x127
		case 8:
			aPawn.__NFUN_2730__(m_sndDesactivatingSecurity, 8, 15, 0, true);
			// End:0x14A
			break;
		// End:0x147
		case 9:
			aPawn.__NFUN_2730__(m_sndSecurityDeactivated, 8, 15, 0, true);
			// End:0x14A
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

