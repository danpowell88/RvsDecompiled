//=============================================================================
// R6HostageVoicesFemaleFrench - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6HostageVoicesFemaleFrench extends R6HostageVoices;

function Init(Actor aActor)
{
	super.Init(aActor);
	aActor.AddSoundBankName("Voices_F_Host_FR");
	return;
}

defaultproperties
{
	m_sndRun=Sound'Voices_F_Host_FR.Play_F_FrAcc_WithRnb_Terro'
	m_sndFrozen=Sound'Voices_F_Host_FR.Play_F_FrAcc_WithRnbNoTerro'
	m_sndFoetal=Sound'Voices_F_Host_FR.Play_F_FrAcc_TerroSeeRnb'
	m_sndHears_Shooting=Sound'Voices_F_Host_FR.Play_F_FrAcc_HearShot'
	m_sndRnbFollow=Sound'Voices_F_Host_FR.Play_F_FrAcc_RnbFollow'
	m_sndRndStayPut=Sound'Voices_F_Host_FR.Play_F_FrAcc_StayPut'
	m_sndRnbHurt=Sound'Voices_F_Host_FR.Play_F_FrAcc_RnbHurt'
	m_sndEntersGas=Sound'Voices_F_Host_FR.Play_F_FrAcc_GasGaggs'
}
