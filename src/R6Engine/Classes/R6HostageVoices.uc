//=============================================================================
// R6HostageVoices - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6HostageVoices extends R6Voices;

var Sound m_sndRun;
var Sound m_sndFrozen;
var Sound m_sndFoetal;
var Sound m_sndHears_Shooting;
var Sound m_sndRnbFollow;
var Sound m_sndRndStayPut;
var Sound m_sndRnbHurt;
var Sound m_sndEntersGas;
var Sound m_sndEntersSmoke;
var Sound m_sndClarkReprimand;

function Init(Actor aActor)
{
	super.Init(aActor);
	aActor.AddSoundBankName("Voices_Clark_Common");
	return;
}

function PlayHostageVoices(R6Pawn aPawn, Pawn.EHostageVoices EHostageVoices)
{
	// End:0x124
	if((aPawn != none))
	{
		switch(EHostageVoices)
		{
			// End:0x2F
			case 0:
				aPawn.PlayVoices(m_sndRun, 6, 15);
				// End:0x124
				break;
			// End:0x4C
			case 1:
				aPawn.PlayVoices(m_sndFrozen, 6, 15);
				// End:0x124
				break;
			// End:0x69
			case 2:
				aPawn.PlayVoices(m_sndFoetal, 6, 15);
				// End:0x124
				break;
			// End:0x86
			case 3:
				aPawn.PlayVoices(m_sndHears_Shooting, 6, 15);
				// End:0x124
				break;
			// End:0xA3
			case 4:
				aPawn.PlayVoices(m_sndRnbFollow, 6, 15);
				// End:0x124
				break;
			// End:0xC0
			case 5:
				aPawn.PlayVoices(m_sndRndStayPut, 6, 15);
				// End:0x124
				break;
			// End:0xDD
			case 6:
				aPawn.PlayVoices(m_sndRnbHurt, 6, 15);
				// End:0x124
				break;
			// End:0xFC
			case 8:
				aPawn.PlayVoices(m_sndEntersGas, 6, 15, 2);
				// End:0x124
				break;
			// End:0x104
			case 7:
				// End:0x124
				break;
			// End:0x121
			case 9:
				aPawn.PlayVoices(m_sndClarkReprimand, 8, 15);
				// End:0x124
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		return;
	}
}

defaultproperties
{
	m_sndClarkReprimand=Sound'Voices_Clark_Common.Play_Hostage_Reprimand'
}
