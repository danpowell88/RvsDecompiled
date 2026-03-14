//=============================================================================
// R6HostageVoicesMaleSpanish - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6HostageVoicesMaleSpanish extends R6HostageVoices;

function Init(Actor aActor)
{
	super.Init(aActor);
	aActor.AddSoundBankName("Voices_M_Host_SP");
	return;
}

defaultproperties
{
	m_sndRun=Sound'Voices_M_Host_SP.Play_M_SpAcc_WithRnb_Terro'
	m_sndFrozen=Sound'Voices_M_Host_SP.Play_M_SpAcc_WithRnbNoTerro'
	m_sndFoetal=Sound'Voices_M_Host_SP.Play_M_SpAcc_TerroSeeRnb'
	m_sndHears_Shooting=Sound'Voices_M_Host_SP.Play_M_SpAcc_HearShot'
	m_sndRnbFollow=Sound'Voices_M_Host_SP.Play_M_SpAcc_RnbFollow'
	m_sndRndStayPut=Sound'Voices_M_Host_SP.Play_M_SpAcc_StayPut'
	m_sndRnbHurt=Sound'Voices_M_Host_SP.Play_M_SpAcc_RnbHurt'
	m_sndEntersGas=Sound'Voices_M_Host_SP.Play_M_SpAcc_GasGaggs'
}
