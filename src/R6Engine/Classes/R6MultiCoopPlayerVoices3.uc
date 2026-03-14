//=============================================================================
// R6MultiCoopPlayerVoices3 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6MultiCoopPlayerVoices3 extends R6MultiCoopVoices;

function Init(Actor aActor)
{
	super(R6Voices).Init(aActor);
	aActor.AddSoundBankName("Voices_Multi_Coop_Team3");
	return;
}

defaultproperties
{
	m_sndPlacingBug=Sound'Voices_Multi_Coop_Team3.Play_Team3_PlacingBug'
	m_sndBugActivated=Sound'Voices_Multi_Coop_Team3.Play_Team3_BugActivated'
	m_sndAccessingComputer=Sound'Voices_Multi_Coop_Team3.Play_Team3_AccessingComputer'
	m_sndComputerHacked=Sound'Voices_Multi_Coop_Team3.Play_Team3_FilesDownloaded'
	m_sndEscortingHostage=Sound'Voices_Multi_Coop_Team3.Play_Team3_Escorting'
	m_sndHostageSecured=Sound'Voices_Multi_Coop_Team3.Play_Team3_HostageSecured'
	m_sndPlacingExplosives=Sound'Voices_Multi_Coop_Team3.Play_Team3_PlacingExplosives'
	m_sndExplosivesReady=Sound'Voices_Multi_Coop_Team3.Play_Team3_ExplosivesReady'
}
