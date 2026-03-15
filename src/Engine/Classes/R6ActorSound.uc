//=============================================================================
// R6ActorSound - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
// Class            R6ActorSound.uc
//----------------------------------------------------------------------------//
//============================================================================//
class R6ActorSound extends Actor
    notplaceable;

var Actor.ESoundSlot m_eTypeSound;
var float m_fExplosionDelay;
var Sound m_ImpactSound;
var Sound m_ImpactSoundStop;

replication
{
	// Pos:0x000
	reliable if((int(Role) == int(ROLE_Authority)))
		m_ImpactSound, m_ImpactSoundStop, 
		m_eTypeSound, m_fExplosionDelay;
}

simulated function Timer()
{
	// End:0x2D
	if((m_ImpactSoundStop != none))
	{
		PlaySound(m_ImpactSoundStop, m_eTypeSound);
		m_ImpactSound = m_ImpactSoundStop;
		m_ImpactSoundStop = none;		
	}
	else
	{
		// End:0x45
		if(IsPlayingSound(self, m_ImpactSound))
		{
			SetTimer(2.0000000, false);			
		}
		else
		{
			SetTimer(0.0000000, false);
		}
	}
	return;
}

simulated function SpawnSound()
{
	PlaySound(m_ImpactSound, m_eTypeSound);
	SetTimer(m_fExplosionDelay, false);
	return;
}

simulated function FirstPassReset()
{
	Destroy();
	return;
}

auto state StartUp
{
	simulated function Tick(float DeltaTime)
	{
		// End:0x1F
		if((int(Level.NetMode) != int(NM_DedicatedServer)))
		{
			SpawnSound();
		}
		LifeSpan = (m_fExplosionDelay + float(10));
		Disable('Tick');
		return;
	}
	stop;
}

defaultproperties
{
	RemoteRole=2
	DrawType=0
	bHidden=true
	bNetOptional=true
	bAlwaysRelevant=true
	m_bDeleteOnReset=true
	m_fSoundRadiusActivation=5600.0000000
	Texture=none
}
