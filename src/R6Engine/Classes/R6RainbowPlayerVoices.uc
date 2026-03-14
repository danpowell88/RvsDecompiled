//=============================================================================
// R6RainbowPlayerVoices - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6RainbowPlayerVoices extends R6Voices;

var Sound m_sndTeamRegroup;
var Sound m_sndTeamMove;
var Sound m_sndTeamHold;
var Sound m_sndAllTeamsHold;
var Sound m_sndAllTeamsMove;
var Sound m_sndTeamMoveAndFrag;
var Sound m_sndTeamMoveAndGas;
var Sound m_sndTeamMoveAndSmoke;
var Sound m_sndTeamMoveAndFlash;
var Sound m_sndTeamOpenDoor;
var Sound m_sndTeamCloseDoor;
var Sound m_sndTeamOpenShudder;
var Sound m_sndTeamCloseShudder;
var Sound m_sndTeamOpenAndClear;
var Sound m_sndTeamOpenAndFrag;
var Sound m_sndTeamOpenAndGas;
var Sound m_sndTeamOpenAndSmoke;
var Sound m_sndTeamOpenAndFlash;
var Sound m_sndTeamOpenFragAndClear;
var Sound m_sndTeamOpenGasAndClear;
var Sound m_sndTeamOpenSmokeAndClear;
var Sound m_sndTeamOpenFlashAndClear;
var Sound m_sndTeamFragAndClear;
var Sound m_sndTeamGasAndClear;
var Sound m_sndTeamSmokeAndClear;
var Sound m_sndTeamFlashAndClear;
var Sound m_sndTeamUseLadder;
var Sound m_sndTeamSecureTerrorist;
var Sound m_sndTeamGoGetHostage;
var Sound m_sndTeamHostageStayPut;
var Sound m_sndTeamStatusReport;
var Sound m_sndTeamUseElectronic;
var Sound m_sndTeamUseDemolition;
var Sound m_sndAlphaGoCode;
var Sound m_sndBravoGoCode;
var Sound m_sndCharlieGoCode;
var Sound m_sndZuluGoCode;
var Sound m_sndOrderTeamWithGoCode;
var Sound m_sndHostageFollow;
var Sound m_sndHostageStay;
var Sound m_sndHostageSafe;
var Sound m_sndHostageSecured;
var Sound m_sndMemberDown;
var Sound m_sndSniperFree;
var Sound m_sndSniperHold;

function Init(Actor aActor)
{
	super.Init(aActor);
	aActor.AddSoundBankName("Voices_1rstPersonRainbow");
	return;
}

function PlayRainbowPlayerVoices(R6Pawn aPawn, Pawn.ERainbowPlayerVoices eRainbowVoices)
{
	switch(eRainbowVoices)
	{
		// End:0x24
		case 0:
			aPawn.__NFUN_2730__(m_sndTeamRegroup, 8, 10);
			// End:0x526
			break;
		// End:0x41
		case 1:
			aPawn.__NFUN_2730__(m_sndTeamMove, 8, 10);
			// End:0x526
			break;
		// End:0x5E
		case 2:
			aPawn.__NFUN_2730__(m_sndTeamHold, 8, 10);
			// End:0x526
			break;
		// End:0x7B
		case 3:
			aPawn.__NFUN_2730__(m_sndAllTeamsHold, 8, 10);
			// End:0x526
			break;
		// End:0x98
		case 4:
			aPawn.__NFUN_2730__(m_sndAllTeamsMove, 8, 10);
			// End:0x526
			break;
		// End:0xB5
		case 5:
			aPawn.__NFUN_2730__(m_sndTeamMoveAndFrag, 8, 10);
			// End:0x526
			break;
		// End:0xD2
		case 6:
			aPawn.__NFUN_2730__(m_sndTeamMoveAndGas, 8, 10);
			// End:0x526
			break;
		// End:0xEF
		case 7:
			aPawn.__NFUN_2730__(m_sndTeamMoveAndSmoke, 8, 10);
			// End:0x526
			break;
		// End:0x10C
		case 8:
			aPawn.__NFUN_2730__(m_sndTeamMoveAndFlash, 8, 10);
			// End:0x526
			break;
		// End:0x129
		case 9:
			aPawn.__NFUN_2730__(m_sndTeamOpenDoor, 8, 10);
			// End:0x526
			break;
		// End:0x146
		case 10:
			aPawn.__NFUN_2730__(m_sndTeamCloseDoor, 8, 10);
			// End:0x526
			break;
		// End:0x163
		case 11:
			aPawn.__NFUN_2730__(m_sndTeamOpenShudder, 8, 10);
			// End:0x526
			break;
		// End:0x180
		case 12:
			aPawn.__NFUN_2730__(m_sndTeamCloseShudder, 8, 10);
			// End:0x526
			break;
		// End:0x19D
		case 13:
			aPawn.__NFUN_2730__(m_sndTeamOpenAndClear, 8, 10);
			// End:0x526
			break;
		// End:0x1BA
		case 14:
			aPawn.__NFUN_2730__(m_sndTeamOpenAndFrag, 8, 10);
			// End:0x526
			break;
		// End:0x1D7
		case 15:
			aPawn.__NFUN_2730__(m_sndTeamOpenAndGas, 8, 10);
			// End:0x526
			break;
		// End:0x1F4
		case 16:
			aPawn.__NFUN_2730__(m_sndTeamOpenAndSmoke, 8, 10);
			// End:0x526
			break;
		// End:0x211
		case 17:
			aPawn.__NFUN_2730__(m_sndTeamOpenAndFlash, 8, 10);
			// End:0x526
			break;
		// End:0x22E
		case 18:
			aPawn.__NFUN_2730__(m_sndTeamOpenFragAndClear, 8, 10);
			// End:0x526
			break;
		// End:0x24B
		case 19:
			aPawn.__NFUN_2730__(m_sndTeamOpenGasAndClear, 8, 10);
			// End:0x526
			break;
		// End:0x268
		case 20:
			aPawn.__NFUN_2730__(m_sndTeamOpenSmokeAndClear, 8, 10);
			// End:0x526
			break;
		// End:0x285
		case 21:
			aPawn.__NFUN_2730__(m_sndTeamOpenFlashAndClear, 8, 10);
			// End:0x526
			break;
		// End:0x2A2
		case 22:
			aPawn.__NFUN_2730__(m_sndTeamFragAndClear, 8, 10);
			// End:0x526
			break;
		// End:0x2BF
		case 23:
			aPawn.__NFUN_2730__(m_sndTeamGasAndClear, 8, 10);
			// End:0x526
			break;
		// End:0x2DC
		case 24:
			aPawn.__NFUN_2730__(m_sndTeamSmokeAndClear, 8, 10);
			// End:0x526
			break;
		// End:0x2F9
		case 25:
			aPawn.__NFUN_2730__(m_sndTeamFlashAndClear, 8, 10);
			// End:0x526
			break;
		// End:0x316
		case 26:
			aPawn.__NFUN_2730__(m_sndTeamUseLadder, 8, 10);
			// End:0x526
			break;
		// End:0x333
		case 27:
			aPawn.__NFUN_2730__(m_sndTeamSecureTerrorist, 8, 10);
			// End:0x526
			break;
		// End:0x350
		case 28:
			aPawn.__NFUN_2730__(m_sndTeamGoGetHostage, 8, 10);
			// End:0x526
			break;
		// End:0x36D
		case 29:
			aPawn.__NFUN_2730__(m_sndTeamHostageStayPut, 8, 10);
			// End:0x526
			break;
		// End:0x38A
		case 30:
			aPawn.__NFUN_2730__(m_sndTeamStatusReport, 8, 10);
			// End:0x526
			break;
		// End:0x3A7
		case 32:
			aPawn.__NFUN_2730__(m_sndTeamUseDemolition, 8, 10);
			// End:0x526
			break;
		// End:0x3C4
		case 31:
			aPawn.__NFUN_2730__(m_sndTeamUseElectronic, 8, 10);
			// End:0x526
			break;
		// End:0x3E1
		case 33:
			aPawn.__NFUN_2730__(m_sndAlphaGoCode, 8, 10);
			// End:0x526
			break;
		// End:0x3FE
		case 34:
			aPawn.__NFUN_2730__(m_sndBravoGoCode, 8, 10);
			// End:0x526
			break;
		// End:0x41B
		case 35:
			aPawn.__NFUN_2730__(m_sndCharlieGoCode, 8, 10);
			// End:0x526
			break;
		// End:0x438
		case 36:
			aPawn.__NFUN_2730__(m_sndZuluGoCode, 8, 10);
			// End:0x526
			break;
		// End:0x458
		case 37:
			aPawn.__NFUN_2730__(m_sndOrderTeamWithGoCode, 8, 15, 0, true);
			// End:0x526
			break;
		// End:0x475
		case 38:
			aPawn.__NFUN_2730__(m_sndHostageFollow, 8, 10);
			// End:0x526
			break;
		// End:0x492
		case 39:
			aPawn.__NFUN_2730__(m_sndHostageStay, 8, 10);
			// End:0x526
			break;
		// End:0x4AF
		case 40:
			aPawn.__NFUN_2730__(m_sndHostageSafe, 8, 10);
			// End:0x526
			break;
		// End:0x4CC
		case 41:
			aPawn.__NFUN_2730__(m_sndHostageSecured, 8, 10);
			// End:0x526
			break;
		// End:0x4E9
		case 42:
			aPawn.__NFUN_2730__(m_sndMemberDown, 8, 10);
			// End:0x526
			break;
		// End:0x506
		case 43:
			aPawn.__NFUN_2730__(m_sndSniperFree, 8, 10);
			// End:0x526
			break;
		// End:0x523
		case 44:
			aPawn.__NFUN_2730__(m_sndSniperHold, 8, 10);
			// End:0x526
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

defaultproperties
{
	m_sndTeamRegroup=Sound'Voices_1rstPersonRainbow.Play_Team_Regroup_Order'
	m_sndTeamMove=Sound'Voices_1rstPersonRainbow.Play_Team_Move_Order'
	m_sndTeamHold=Sound'Voices_1rstPersonRainbow.Play_Team_Hold_Up'
	m_sndAllTeamsHold=Sound'Voices_1rstPersonRainbow.Play_All_Team_Hold_Up'
	m_sndAllTeamsMove=Sound'Voices_1rstPersonRainbow.Play_All_Team_Move_Out'
	m_sndTeamMoveAndFrag=Sound'Voices_1rstPersonRainbow.Play_Move_Frag'
	m_sndTeamMoveAndGas=Sound'Voices_1rstPersonRainbow.Play_Move_Gas'
	m_sndTeamMoveAndSmoke=Sound'Voices_1rstPersonRainbow.Play_Move_Smoke'
	m_sndTeamMoveAndFlash=Sound'Voices_1rstPersonRainbow.Play_Move_Flash'
	m_sndTeamOpenDoor=Sound'Voices_1rstPersonRainbow.Play_Open_Door'
	m_sndTeamCloseDoor=Sound'Voices_1rstPersonRainbow.Play_Close_Door'
	m_sndTeamOpenShudder=Sound'Voices_1rstPersonRainbow.Play_Open_Window'
	m_sndTeamCloseShudder=Sound'Voices_1rstPersonRainbow.Play_Close_Window'
	m_sndTeamOpenAndClear=Sound'Voices_1rstPersonRainbow.Play_Open_Door_Clear'
	m_sndTeamOpenAndFrag=Sound'Voices_1rstPersonRainbow.Play_Open_Door_Frag'
	m_sndTeamOpenAndGas=Sound'Voices_1rstPersonRainbow.Play_Open_Door_Gas'
	m_sndTeamOpenAndSmoke=Sound'Voices_1rstPersonRainbow.Play_Open_Door_Smoke'
	m_sndTeamOpenAndFlash=Sound'Voices_1rstPersonRainbow.Play_Open_Door_Flash'
	m_sndTeamOpenFragAndClear=Sound'Voices_1rstPersonRainbow.Play_Open_Door_Frag_Clear'
	m_sndTeamOpenGasAndClear=Sound'Voices_1rstPersonRainbow.Play_Open_Door_Gas_Clear'
	m_sndTeamOpenSmokeAndClear=Sound'Voices_1rstPersonRainbow.Play_Open_Door_Smoke_Clear'
	m_sndTeamOpenFlashAndClear=Sound'Voices_1rstPersonRainbow.Play_Open_Door_Flash_Clear'
	m_sndTeamFragAndClear=Sound'Voices_1rstPersonRainbow.Play_Team_Frag_Clear'
	m_sndTeamGasAndClear=Sound'Voices_1rstPersonRainbow.Play_Team_Gas_Clear'
	m_sndTeamSmokeAndClear=Sound'Voices_1rstPersonRainbow.Play_Team_Smoke_Clear'
	m_sndTeamFlashAndClear=Sound'Voices_1rstPersonRainbow.Play_Team_Flash_Clear'
	m_sndTeamUseLadder=Sound'Voices_1rstPersonRainbow.Play_Team_Ladder'
	m_sndTeamSecureTerrorist=Sound'Voices_1rstPersonRainbow.Play_Team_Secure_Terro'
	m_sndTeamGoGetHostage=Sound'Voices_1rstPersonRainbow.Play_Team_Get_Hostage'
	m_sndTeamHostageStayPut=Sound'Voices_1rstPersonRainbow.Play_Team_Hostage_Order'
	m_sndTeamStatusReport=Sound'Voices_1rstPersonRainbow.Play_Call_Team_Status'
	m_sndTeamUseElectronic=Sound'Voices_1rstPersonRainbow.Play_Use_Electronic'
	m_sndTeamUseDemolition=Sound'Voices_1rstPersonRainbow.Play_Use_Demolition'
	m_sndAlphaGoCode=Sound'Voices_1rstPersonRainbow.Play_Give_AlphaGo'
	m_sndBravoGoCode=Sound'Voices_1rstPersonRainbow.Play_Give_BravoGo'
	m_sndCharlieGoCode=Sound'Voices_1rstPersonRainbow.Play_Give_CharlieGo'
	m_sndZuluGoCode=Sound'Voices_1rstPersonRainbow.Play_Give_ZuluGo'
	m_sndOrderTeamWithGoCode=Sound'Voices_1rstPersonRainbow.Play_Give_Order_TeamGo'
	m_sndHostageFollow=Sound'Voices_1rstPersonRainbow.Play_Hostage_Follow'
	m_sndHostageStay=Sound'Voices_1rstPersonRainbow.Play_Hostage_Stay'
	m_sndHostageSafe=Sound'Voices_1rstPersonRainbow.Play_Player_HostageSafe'
	m_sndHostageSecured=Sound'Voices_1rstPersonRainbow.Play_Player_HostageSecured'
	m_sndMemberDown=Sound'Voices_1rstPersonRainbow.Play_RainbowDown'
	m_sndSniperFree=Sound'Voices_1rstPersonRainbow.Play_Player_Sniper_Shoot'
	m_sndSniperHold=Sound'Voices_1rstPersonRainbow.Play_Player_Sniper_NotShoot'
}
