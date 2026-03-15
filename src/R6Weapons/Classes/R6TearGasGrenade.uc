//=============================================================================
// R6TearGasGrenade - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6TearGasGrenade.uc : TearGas grenade
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/17/09 * Created by Joel Tremblay
//=============================================================================
class R6TearGasGrenade extends R6Grenade;

var bool m_bGrenadeExploded;
var float m_fExpansionTime;  // Time needed to reach maximum radius
var float m_fStartTime;  // Time at wich the explosion occured

function Timer()
{
	local R6SmokeCloud pCloud;

	// End:0x98
	if((!m_bGrenadeExploded))
	{
		SetTimer(0.5000000, true);
		m_fStartTime = Level.TimeSeconds;
		// End:0x88
		if((int(m_eGrenadeType) == int(1)))
		{
			pCloud = Spawn(Class'R6Weapons.R6SmokeCloud',,, (Location + vect(0.0000000, 0.0000000, 130.0000000)), rot(0, 0, 0));
			pCloud.SetCloud(self, 20.0000000, 500.0000000, 35.0000000);
		}
		m_bGrenadeExploded = true;
		Explode();
		return;
	}
	HurtPawns();
	return;
}

simulated function Explode()
{
	local Light pEffectLight;
	local Class<Emitter> pExplosionParticles;

	pExplosionParticles = GetGrenadeEmitter();
	// End:0x33
	if((pExplosionParticles != none))
	{
		m_pEmmiter = Spawn(pExplosionParticles);
		m_pExplosionParticles = none;
		m_pExplosionParticlesLOW = none;
	}
	// End:0x53
	if((m_pExplosionLight != none))
	{
		pEffectLight = Spawn(m_pExplosionLight);
		m_pExplosionLight = none;
	}
	// End:0x6B
	if((int(m_eGrenadeType) == int(2)))
	{
		bHidden = true;
	}
	super.Explode();
	return;
}

simulated event Destroyed()
{
	super.Destroyed();
	return;
}

function HurtPawns()
{
	local R6Pawn aPawn;
	local float fElapsedTime, fVisibilityRadius, fMessageRadius;

	fElapsedTime = (Level.TimeSeconds - m_fStartTime);
	// End:0x3B
	if((fElapsedTime > m_fDuration))
	{
		SetTimer(0.0000000, false);
		SelfDestroy();
		return;
	}
	// End:0x79
	if(((int(m_eGrenadeType) == int(1)) && (int(Physics) != int(0))))
	{
		// End:0x79
		if((m_pEmmiter != none))
		{
			m_pEmmiter.SetLocation(Location);
		}
	}
	// End:0xBD
	if((fElapsedTime < m_fExpansionTime))
	{
		fElapsedTime = (fElapsedTime / m_fExpansionTime);
		fMessageRadius = (m_fKillBlastRadius + (fElapsedTime * (m_fExplosionRadius - m_fKillBlastRadius)));		
	}
	else
	{
		fMessageRadius = m_fExplosionRadius;
	}
	// End:0x1A1
	foreach VisibleCollidingActors(Class'R6Engine.R6Pawn', aPawn, fMessageRadius, (Location + vect(0.0000000, 0.0000000, 125.0000000)))
	{
		// End:0x1A0
		if((aPawn.IsAlive() && (!aPawn.m_bHaveGasMask)))
		{
			aPawn.AffectedByGrenade(self, m_eGrenadeType);
			// End:0x1A0
			if((int(m_eGrenadeType) == int(2)))
			{
				// End:0x16F
				if((aPawn.m_fRepDecrementalBlurValue == float(300)))
				{
					aPawn.m_fRepDecrementalBlurValue = 301.0000000;					
				}
				else
				{
					aPawn.m_fRepDecrementalBlurValue = 300.0000000;
				}
				aPawn.m_fDecrementalBlurValue = aPawn.m_fRepDecrementalBlurValue;
			}
		}		
	}	
	return;
}

defaultproperties
{
	m_fExpansionTime=2.0000000
	m_eExplosionSoundType=3
	m_eGrenadeType=2
	m_iNumberOfFragments=0
	m_fDuration=60.0000000
	m_sndExplosionSound=Sound'Grenade_Gas.Play_GasGrenade_Expl'
	m_sndExplosionSoundStop=Sound'Grenade_Gas.Stop_Go_Gas_Silence'
	m_pExplosionParticles=Class'R6SFX.R6TearsGazGrenadeEffect'
	m_DmgPercentStand=(fHead=0.0800000,fBody=0.5000000,fArms=0.2000000,fLegs=0.2600000)
	m_DmgPercentCrouch=(fHead=0.1200000,fBody=0.2500000,fArms=0.3200000,fLegs=0.5000000)
	m_DmgPercentProne=(fHead=0.7600000,fBody=0.0200000,fArms=0.2000000,fLegs=0.0200000)
	m_iEnergy=0
	m_fKillStunTransfer=0.3500000
	m_fExplosionRadius=400.0000000
	m_fKillBlastRadius=100.0000000
	m_fExplosionDelay=2.0000000
	m_szAmmoName="Tear Gas Grenade"
	m_szBulletType="GRENADE"
	DrawScale=1.5000000
	StaticMesh=StaticMesh'R63rdWeapons_SM.Grenades.R63rdGrenadeTearGas'
}
