//=============================================================================
// R6MultiCommonVoices - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6MultiCommonVoices extends R6Voices;

var Sound m_sndFragThrow;
var Sound m_sndFlashThrow;
var Sound m_sndGasThrow;
var Sound m_sndSmokeThrow;
var Sound m_sndActivatingBomb;
var Sound m_sndBombActivated;
var Sound m_sndDeactivatingBomb;
var Sound m_sndBombDeactivated;

function Init(Actor aActor)
{
	super.Init(aActor);
	aActor.AddSoundBankName("Voices_Multi_Common");
	return;
}

function PlayMultiCommonVoices(R6Pawn aPawn, Pawn.EMultiCommonVoices eVoices)
{
	switch(eVoices)
	{
		// End:0x26
		case 0:
			aPawn.__NFUN_2730__(m_sndFragThrow, 8, 10, 1);
			// End:0x102
			break;
		// End:0x45
		case 1:
			aPawn.__NFUN_2730__(m_sndFlashThrow, 8, 10, 1);
			// End:0x102
			break;
		// End:0x64
		case 2:
			aPawn.__NFUN_2730__(m_sndGasThrow, 8, 10, 1);
			// End:0x102
			break;
		// End:0x83
		case 3:
			aPawn.__NFUN_2730__(m_sndSmokeThrow, 8, 10, 1);
			// End:0x102
			break;
		// End:0xA2
		case 4:
			aPawn.__NFUN_2730__(m_sndActivatingBomb, 8, 10, 1);
			// End:0x102
			break;
		// End:0xC1
		case 5:
			aPawn.__NFUN_2730__(m_sndBombActivated, 8, 10, 1);
			// End:0x102
			break;
		// End:0xE0
		case 6:
			aPawn.__NFUN_2730__(m_sndDeactivatingBomb, 8, 10, 1);
			// End:0x102
			break;
		// End:0xFF
		case 7:
			aPawn.__NFUN_2730__(m_sndBombDeactivated, 8, 10, 1);
			// End:0x102
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

defaultproperties
{
	m_sndFragThrow=Sound'Voices_Multi_Common.Play_Common_FragThrow'
	m_sndFlashThrow=Sound'Voices_Multi_Common.Play_Common_FlashThrow'
	m_sndGasThrow=Sound'Voices_Multi_Common.Play_Common_GasThrow'
	m_sndSmokeThrow=Sound'Voices_Multi_Common.Play_Common_SmokeThrow'
	m_sndActivatingBomb=Sound'Voices_Multi_Common.Play_Common_ActivatingBomb'
	m_sndBombActivated=Sound'Voices_Multi_Common.Play_Common_BombActivated'
	m_sndDeactivatingBomb=Sound'Voices_Multi_Common.Play_Common_DeactivatingBomb'
	m_sndBombDeactivated=Sound'Voices_Multi_Common.Play_Common_BombDeactivated'
}
