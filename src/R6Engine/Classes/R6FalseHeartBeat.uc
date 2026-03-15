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
	Destroy();
	return;
}

simulated event PostBeginPlay()
{
	// End:0x4A
	if((int(Level.NetMode) != int(NM_Client)))
	{
		m_fHeartBeatTime[0] = float(Rand(int((float(1000) / (m_fHeartBeatFrequency / float(60))))));
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
	if((Index < 2))
	{
		(m_fHeartBeatTime[Index] += (DeltaSeconds * float(1000)));
		(Index++);
		// [Loop Continue]
		goto J0x0F;
	}
	fHeartBeatFrenquency = (1000.0000000 / (m_fHeartBeatFrequency / float(60)));
	// End:0xB8
	if((m_fHeartBeatTime[m_iNoCircleBeat] > fHeartBeatFrenquency))
	{
		fRest = (m_fHeartBeatTime[m_iNoCircleBeat] - fHeartBeatFrenquency);
		(m_iNoCircleBeat++);
		// End:0x9F
		if((m_iNoCircleBeat >= 2))
		{
			m_iNoCircleBeat = 0;
		}
		m_fHeartBeatTime[m_iNoCircleBeat] = fRest;
		bStartNewBeat = true;
	}
	// End:0xE2
	if((m_fHeartBeatTime[0] < float(500)))
	{
		fMul1 = (0.0012000 * m_fHeartBeatTime[0]);		
	}
	else
	{
		fMul1 = 0.6000000;
	}
	// End:0x117
	if((m_fHeartBeatTime[1] < float(500)))
	{
		fMul2 = (0.0012000 * m_fHeartBeatTime[1]);		
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
