//=============================================================================
// R6HostageVoicesFemaleSpanish - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6HostageVoicesFemaleSpanish extends R6HostageVoices;

function Init(Actor aActor)
{
	super.Init(aActor);
	aActor.AddSoundBankName("Voices_F_Host_SP");
	return;
}

defaultproperties
{
	m_sndRun=Sound'Voices_F_Host_SP.Play_F_SpAcc_WithRnb_Terro'
	m_sndFrozen=Sound'Voices_F_Host_SP.Play_F_SpAcc_WithRnbNoTerro'
	m_sndFoetal=Sound'Voices_F_Host_SP.Play_F_SpAcc_TerroSeeRnb'
	m_sndHears_Shooting=Sound'Voices_F_Host_SP.Play_F_SpAcc_HearShot'
	m_sndRnbFollow=Sound'Voices_F_Host_SP.Play_F_SpAcc_RnbFollow'
	m_sndRndStayPut=Sound'Voices_F_Host_SP.Play_F_SpAcc_StayPut'
	m_sndRnbHurt=Sound'Voices_F_Host_SP.Play_F_SpAcc_RnbHurt'
	m_sndEntersGas=Sound'Voices_F_Host_SP.Play_F_SpAcc_GasGaggs'
}
