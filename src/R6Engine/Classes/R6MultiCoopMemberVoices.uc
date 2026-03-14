//=============================================================================
// R6MultiCoopMemberVoices - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6MultiCoopMemberVoices extends R6MultiCoopVoices;

var Sound m_sndGasThreat;
var Sound m_sndGrenadeThreat;

function Init(Actor aActor)
{
	super(R6Voices).Init(aActor);
	aActor.AddSoundBankName("Voices_Multi_Coop_AI");
	return;
}

function PlayRainbowTeamVoices(R6Pawn aPawn, Pawn.ERainbowTeamVoices eVoices)
{
	super.PlayRainbowTeamVoices(aPawn, eVoices);
	switch(eVoices)
	{
		// End:0x34
		case 10:
			aPawn.__NFUN_2730__(m_sndGasThreat, 8, 10);
			// End:0x54
			break;
		// End:0x51
		case 11:
			aPawn.__NFUN_2730__(m_sndGrenadeThreat, 8, 10);
			// End:0x54
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

defaultproperties
{
	m_sndGasThreat=Sound'Voices_Multi_Coop_AI.Play_AI_GasThreat'
	m_sndGrenadeThreat=Sound'Voices_Multi_Coop_AI.Play_AI_FragThreat'
	m_sndPlacingBug=Sound'Voices_Multi_Coop_AI.Play_AI_PlacingBug'
	m_sndBugActivated=Sound'Voices_Multi_Coop_AI.Play_AI_BugActivated'
	m_sndAccessingComputer=Sound'Voices_Multi_Coop_AI.Play_AI_AccessingComputer'
	m_sndComputerHacked=Sound'Voices_Multi_Coop_AI.Play_AI_FilesDownloaded'
	m_sndEscortingHostage=Sound'Voices_Multi_Coop_AI.Play_AI_Escorting'
	m_sndHostageSecured=Sound'Voices_Multi_Coop_AI.Play_AI_HostageSecured'
	m_sndPlacingExplosives=Sound'Voices_Multi_Coop_AI.Play_AI_PlacingExplosives'
	m_sndExplosivesReady=Sound'Voices_Multi_Coop_AI.Play_AI_ExplosivesReady'
	m_sndSecurityDeactivated=Sound'Voices_Multi_Coop_AI.Play_AI_SecurityDeactivated'
}
