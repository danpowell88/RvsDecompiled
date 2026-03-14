//=============================================================================
// R6CommonRainbowMemberVoices - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6CommonRainbowMemberVoices extends R6CommonRainbowVoices;

function Init(Actor aActor)
{
	super(R6Voices).Init(aActor);
	aActor.AddSoundBankName("Voices_Common_3rd");
	return;
}

defaultproperties
{
	m_sndTerroristDown=Sound'Voices_Common_3rd.Play_3rd_TerroDown'
	m_sndTakeWound=Sound'Voices_Common_3rd.Play_3rd_Wounded'
	m_sndGoesDown=Sound'Voices_Common_3rd.Play_3rd_GoDown'
	m_sndEntersGas=Sound'Voices_Common_3rd.Play_3rd_Gagging'
}
