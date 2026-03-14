//=============================================================================
// R6SAHeartBeatJammer - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6SAHeartBeatJammer extends R6GenericHB
    native
    placeable;

simulated function FirstPassReset()
{
	super(R6InteractiveObject).FirstPassReset();
	__NFUN_279__();
	return;
}

defaultproperties
{
	m_iCurrentState=-1
	m_StateList[0]=(RandomMeshes=((fPercentage=100.0000000)),ActorList=((ActorToSpawn=Class'R6SFX.R6BreakablePhone')),SoundList=(Sound'CommonGadget_Explosion.Play_PuckExplode'))
}
