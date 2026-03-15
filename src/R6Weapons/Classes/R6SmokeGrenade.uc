//=============================================================================
// R6SmokeGrenade - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6SmokeGrenade.uc : Normal frag grenade
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/17/09 * Created by Sebastien Lussier
//=============================================================================
class R6SmokeGrenade extends R6TearGasGrenade;

defaultproperties
{
	m_fExpansionTime=10.0000000
	m_eGrenadeType=1
	m_sndExplosionSound=Sound'Grenade_Smoke.Play_SmokeGrenade_Expl'
	m_sndExplosionSoundStop=Sound'Grenade_Smoke.Stop_Go_SmokeSilence'
	m_pExplosionParticles=Class'R6SFX.R6SmokeGrenadeEffect'
	m_pExplosionParticlesLOW=Class'R6SFX.R6SmokeGrenadeEffectLOW'
	m_fExplosionRadius=600.0000000
	m_fKillBlastRadius=0.0000000
	m_fExplosionDelay=1.0000000
	m_szAmmoName="Smoke Grenade"
	LifeSpan=60.0000000
	StaticMesh=StaticMesh'R63rdWeapons_SM.Grenades.R63rdGrenadeSmoke'
}
