//=============================================================================
// R6ActorSound - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
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
		__NFUN_264__(m_ImpactSoundStop, m_eTypeSound) /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/;
		m_ImpactSound = m_ImpactSoundStop;
		m_ImpactSoundStop = none;		
	}
	else
	{
		// End:0x45
		if(__NFUN_2703__(self, m_ImpactSound))
		{
			__NFUN_280__(2.0000000, false);			
		}
		else
		{
			__NFUN_280__(0.0000000, false);
		}
	}
	return;
}

simulated function SpawnSound()
{
	__NFUN_264__(m_ImpactSound, m_eTypeSound);
	__NFUN_280__(m_fExplosionDelay, false);
	return;
}

simulated function FirstPassReset()
{
	__NFUN_279__();
	return;
}

auto state StartUp
{
	simulated function Tick(float DeltaTime)
	{
		// End:0x1F
		if(__NFUN_155__(int(Level.NetMode), int(NM_DedicatedServer)))
		{
			SpawnSound();
		}
		LifeSpan = __NFUN_174__(m_fExplosionDelay, float(10));
		__NFUN_118__('Tick');
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
