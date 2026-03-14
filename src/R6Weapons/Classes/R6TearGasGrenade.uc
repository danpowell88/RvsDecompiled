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
	if(__NFUN_129__(m_bGrenadeExploded))
	{
		__NFUN_280__(0.5000000, true);
		m_fStartTime = Level.TimeSeconds;
		// End:0x88
		if(__NFUN_154__(int(m_eGrenadeType), int(1)))
		{
			pCloud = __NFUN_278__(Class'R6Weapons.R6SmokeCloud',,, __NFUN_215__(Location, vect(0.0000000, 0.0000000, 130.0000000)), rot(0, 0, 0));
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
	if(__NFUN_119__(pExplosionParticles, none))
	{
		m_pEmmiter = __NFUN_278__(pExplosionParticles);
		m_pExplosionParticles = none;
		m_pExplosionParticlesLOW = none;
	}
	// End:0x53
	if(__NFUN_119__(m_pExplosionLight, none))
	{
		pEffectLight = __NFUN_278__(m_pExplosionLight);
		m_pExplosionLight = none;
	}
	// End:0x6B
	if(__NFUN_154__(int(m_eGrenadeType), int(2)))
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

	fElapsedTime = __NFUN_175__(Level.TimeSeconds, m_fStartTime);
	// End:0x3B
	if(__NFUN_177__(fElapsedTime, m_fDuration))
	{
		__NFUN_280__(0.0000000, false);
		SelfDestroy();
		return;
	}
	// End:0x79
	if(__NFUN_130__(__NFUN_154__(int(m_eGrenadeType), int(1)), __NFUN_155__(int(Physics), int(0))))
	{
		// End:0x79
		if(__NFUN_119__(m_pEmmiter, none))
		{
			m_pEmmiter.__NFUN_267__(Location);
		}
	}
	// End:0xBD
	if(__NFUN_176__(fElapsedTime, m_fExpansionTime))
	{
		fElapsedTime = __NFUN_172__(fElapsedTime, m_fExpansionTime);
		fMessageRadius = __NFUN_174__(m_fKillBlastRadius, __NFUN_171__(fElapsedTime, __NFUN_175__(m_fExplosionRadius, m_fKillBlastRadius)));		
	}
	else
	{
		fMessageRadius = m_fExplosionRadius;
	}
	// End:0x1A1
	foreach __NFUN_312__(Class'R6Engine.R6Pawn', aPawn, fMessageRadius, __NFUN_215__(Location, vect(0.0000000, 0.0000000, 125.0000000)))
	{
		// End:0x1A0
		if(__NFUN_130__(aPawn.IsAlive(), __NFUN_129__(aPawn.m_bHaveGasMask)))
		{
			aPawn.AffectedByGrenade(self, m_eGrenadeType);
			// End:0x1A0
			if(__NFUN_154__(int(m_eGrenadeType), int(2)))
			{
				// End:0x16F
				if(__NFUN_180__(aPawn.m_fRepDecrementalBlurValue, float(300)))
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
