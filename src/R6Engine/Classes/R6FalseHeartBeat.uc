//=============================================================================
// R6FalseHeartBeat - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6FalseHeartBeat extends R6GenericHB
    native
    placeable;

var int m_iNoCircleBeat;  // Current circle to be start display
var float m_fHeartBeatTime[2];  // Heart Beat time in ms, one for each cicle
var float m_fHeartBeatFrequency;  // Number of heart beat by minutes.
var Pawn m_HeartBeatPuckOwner;  // set to the player pawn that threw the puck (used instead of Instigator)

simulated function FirstPassReset()
{
	super(R6InteractiveObject).FirstPassReset();
	__NFUN_279__();
	return;
}

simulated event PostBeginPlay()
{
	// End:0x4A
	if(__NFUN_155__(int(Level.NetMode), int(NM_Client)))
	{
		m_fHeartBeatTime[0] = float(__NFUN_167__(int(__NFUN_172__(float(1000), __NFUN_172__(m_fHeartBeatFrequency, float(60))))));
		m_fHeartBeatTime[1] = m_fHeartBeatTime[0];
	}
	return;
}

simulated event bool ProcessHeart(float DeltaSeconds, out float fMul1, out float fMul2)
{
	local int Index;
	local float fHeartBeatFrenquency, fRest, fMul;
	local bool bStartNewBeat;

	bStartNewBeat = false;
	Index = 0;
	J0x0F:

	// End:0x40 [Loop If]
	if(__NFUN_150__(Index, 2))
	{
		__NFUN_184__(m_fHeartBeatTime[Index], __NFUN_171__(DeltaSeconds, float(1000)));
		__NFUN_165__(Index);
		// [Loop Continue]
		goto J0x0F;
	}
	fHeartBeatFrenquency = __NFUN_172__(1000.0000000, __NFUN_172__(m_fHeartBeatFrequency, float(60)));
	// End:0xB8
	if(__NFUN_177__(m_fHeartBeatTime[m_iNoCircleBeat], fHeartBeatFrenquency))
	{
		fRest = __NFUN_175__(m_fHeartBeatTime[m_iNoCircleBeat], fHeartBeatFrenquency);
		__NFUN_165__(m_iNoCircleBeat);
		// End:0x9F
		if(__NFUN_153__(m_iNoCircleBeat, 2))
		{
			m_iNoCircleBeat = 0;
		}
		m_fHeartBeatTime[m_iNoCircleBeat] = fRest;
		bStartNewBeat = true;
	}
	// End:0xE2
	if(__NFUN_176__(m_fHeartBeatTime[0], float(500)))
	{
		fMul1 = __NFUN_171__(0.0012000, m_fHeartBeatTime[0]);		
	}
	else
	{
		fMul1 = 0.6000000;
	}
	// End:0x117
	if(__NFUN_176__(m_fHeartBeatTime[1], float(500)))
	{
		fMul2 = __NFUN_171__(0.0012000, m_fHeartBeatTime[1]);		
	}
	else
	{
		fMul2 = 0.6000000;
	}
	return bStartNewBeat;
	return;
}

defaultproperties
{
	m_fHeartBeatFrequency=70.0000000
	m_iCurrentState=-1
	m_StateList[0]=(RandomMeshes=((fPercentage=100.0000000)),ActorList=((ActorToSpawn=Class'R6SFX.R6BreakablePhone')),SoundList=(Sound'CommonGadget_Explosion.Play_PuckExplode'))
}
