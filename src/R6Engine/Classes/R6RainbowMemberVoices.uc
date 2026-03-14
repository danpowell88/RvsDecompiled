//=============================================================================
// R6RainbowMemberVoices - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6RainbowMemberVoices extends R6Voices;

var Sound m_sndContact;
var Sound m_sndContactRear;
var Sound m_sndContactAndEngages;
var Sound m_sndContactRearAndEngages;
var Sound m_sndTeamRegroupOnLead;
var Sound m_sndTeamReformOnLead;
var Sound m_sndTeamReceiveOrder;
var Sound m_sndTeamOrderFromLeadNil;
var Sound m_sndNoMoreFrag;
var Sound m_sndNoMoreSmoke;
var Sound m_sndNoMoreGas;
var Sound m_sndNoMoreFlash;
var Sound m_sndOnLadder;
var Sound m_sndMemberDown;
var Sound m_sndAmmoOut;
var Sound m_sndFragNear;
var Sound m_sndEntersGasCloud;
var Sound m_sndTakingFire;
var Sound m_sndTeamHoldUp;
var Sound m_sndTeamMoveOut;
var Sound m_sndHostageFollow;
var Sound m_sndHostageStay;
var Sound m_sndHostageSafe;
var Sound m_sndHostageSecured;
var Sound m_sndRainbowHitRainbow;
var Sound m_sndRainbowHitHostage;
var Sound m_sndDoorReform;

function Init(Actor aActor)
{
	super.Init(aActor);
	aActor.AddSoundBankName("Voices_3rdPersonRainbow");
	return;
}

function PlayRainbowMemberVoices(R6Pawn aPawn, Pawn.ERainbowMembersVoices eRainbowVoices)
{
	switch(eRainbowVoices)
	{
		// End:0x24
		case 0:
			aPawn.__NFUN_2730__(m_sndContact, 8, 15);
			// End:0x327
			break;
		// End:0x41
		case 1:
			aPawn.__NFUN_2730__(m_sndContactRear, 8, 15);
			// End:0x327
			break;
		// End:0x5E
		case 2:
			aPawn.__NFUN_2730__(m_sndContactAndEngages, 8, 15);
			// End:0x327
			break;
		// End:0x7B
		case 3:
			aPawn.__NFUN_2730__(m_sndContactRearAndEngages, 8, 15);
			// End:0x327
			break;
		// End:0x98
		case 4:
			aPawn.__NFUN_2730__(m_sndTeamRegroupOnLead, 8, 15);
			// End:0x327
			break;
		// End:0xB5
		case 5:
			aPawn.__NFUN_2730__(m_sndTeamReformOnLead, 8, 15);
			// End:0x327
			break;
		// End:0xD2
		case 6:
			aPawn.__NFUN_2730__(m_sndTeamReceiveOrder, 8, 15);
			// End:0x327
			break;
		// End:0xEF
		case 7:
			aPawn.__NFUN_2730__(m_sndTeamOrderFromLeadNil, 8, 15);
			// End:0x327
			break;
		// End:0x10C
		case 8:
			aPawn.__NFUN_2730__(m_sndNoMoreFrag, 8, 15);
			// End:0x327
			break;
		// End:0x129
		case 9:
			aPawn.__NFUN_2730__(m_sndNoMoreSmoke, 8, 15);
			// End:0x327
			break;
		// End:0x146
		case 10:
			aPawn.__NFUN_2730__(m_sndNoMoreGas, 8, 15);
			// End:0x327
			break;
		// End:0x163
		case 11:
			aPawn.__NFUN_2730__(m_sndNoMoreFlash, 8, 15);
			// End:0x327
			break;
		// End:0x180
		case 12:
			aPawn.__NFUN_2730__(m_sndOnLadder, 8, 15);
			// End:0x327
			break;
		// End:0x19F
		case 13:
			aPawn.__NFUN_2730__(m_sndMemberDown, 8, 10, 2);
			// End:0x327
			break;
		// End:0x1BC
		case 14:
			aPawn.__NFUN_2730__(m_sndAmmoOut, 8, 15);
			// End:0x327
			break;
		// End:0x1D9
		case 15:
			aPawn.__NFUN_2730__(m_sndFragNear, 8, 15);
			// End:0x327
			break;
		// End:0x1F9
		case 16:
			aPawn.__NFUN_2730__(m_sndEntersGasCloud, 8, 5, 0, true);
			// End:0x327
			break;
		// End:0x216
		case 17:
			aPawn.__NFUN_2730__(m_sndTakingFire, 8, 15);
			// End:0x327
			break;
		// End:0x233
		case 18:
			aPawn.__NFUN_2730__(m_sndTeamHoldUp, 8, 15);
			// End:0x327
			break;
		// End:0x250
		case 19:
			aPawn.__NFUN_2730__(m_sndTeamMoveOut, 8, 15);
			// End:0x327
			break;
		// End:0x270
		case 20:
			aPawn.__NFUN_2730__(m_sndHostageFollow, 8, 15, 0, true);
			// End:0x327
			break;
		// End:0x290
		case 22:
			aPawn.__NFUN_2730__(m_sndHostageSafe, 8, 15, 0, true);
			// End:0x327
			break;
		// End:0x2B0
		case 21:
			aPawn.__NFUN_2730__(m_sndHostageStay, 8, 15, 0, true);
			// End:0x327
			break;
		// End:0x2CD
		case 23:
			aPawn.__NFUN_2730__(m_sndHostageSecured, 8, 15);
			// End:0x327
			break;
		// End:0x2EA
		case 24:
			aPawn.__NFUN_2730__(m_sndRainbowHitRainbow, 8, 15);
			// End:0x327
			break;
		// End:0x307
		case 25:
			aPawn.__NFUN_2730__(m_sndRainbowHitHostage, 8, 15);
			// End:0x327
			break;
		// End:0x324
		case 26:
			aPawn.__NFUN_2730__(m_sndDoorReform, 8, 15);
			// End:0x327
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

defaultproperties
{
	m_sndContact=Sound'Voices_3rdPersonRainbow.Play_Terro_EntersView'
	m_sndContactRear=Sound'Voices_3rdPersonRainbow.Play_Terro_EntersViewRear'
	m_sndContactAndEngages=Sound'Voices_3rdPersonRainbow.Play_TerroView_Engage'
	m_sndContactRearAndEngages=Sound'Voices_3rdPersonRainbow.Play_TerroViewRear_Engage'
	m_sndTeamRegroupOnLead=Sound'Voices_3rdPersonRainbow.Play_LeadRegroup'
	m_sndTeamReformOnLead=Sound'Voices_3rdPersonRainbow.Play_TeamRegroup_OnLead'
	m_sndTeamReceiveOrder=Sound'Voices_3rdPersonRainbow.Play_Order_FromLead'
	m_sndTeamOrderFromLeadNil=Sound'Voices_3rdPersonRainbow.Play_Order_FromLead_Nil'
	m_sndOnLadder=Sound'Voices_3rdPersonRainbow.Play_Receive_Order_Ladder'
	m_sndMemberDown=Sound'Voices_3rdPersonRainbow.Play_MemberDown'
	m_sndAmmoOut=Sound'Voices_3rdPersonRainbow.Play_Ammo_Out'
	m_sndEntersGasCloud=Sound'Voices_3rdPersonRainbow.Play_GasCloud_In'
	m_sndTakingFire=Sound'Voices_3rdPersonRainbow.Play_TakingFire'
	m_sndTeamHoldUp=Sound'Voices_3rdPersonRainbow.Play_Team_HoldUp'
	m_sndTeamMoveOut=Sound'Voices_3rdPersonRainbow.Play_Team_MoveOut'
	m_sndHostageFollow=Sound'Voices_3rdPersonRainbow.Play_Tell_Hostage_Follow'
	m_sndHostageStay=Sound'Voices_3rdPersonRainbow.Play_Tell_Hostage_Stay'
	m_sndHostageSafe=Sound'Voices_3rdPersonRainbow.Play_Team_HostageSafe'
	m_sndHostageSecured=Sound'Voices_3rdPersonRainbow.Play_Team_HostageSecured'
	m_sndRainbowHitRainbow=Sound'Voices_3rdPersonRainbow.Play_Rainbow_HitRainbow'
	m_sndRainbowHitHostage=Sound'Voices_3rdPersonRainbow.Play_Rainbow_HitCivil'
	m_sndDoorReform=Sound'Voices_3rdPersonRainbow.Play_Rainbow_DoorReform'
}
