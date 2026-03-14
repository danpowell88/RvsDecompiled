//=============================================================================
// R6FlashBang - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  FlashBang.uc : Flashbang grenade
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/17/09 * Created by Sebastien Lussier
//=============================================================================
class R6FlashBang extends R6Grenade;

var float m_fBlindEffectRadius;

function HurtPawns()
{
	local R6Pawn aPawn;
	local R6InteractiveObject anObject;
	local float fDistFromFlashbang, fEffectiveStunValue;
	local Vector vDamageLocation, vExplosionMomentum, vHitLocation, vHitNormal;
	local Actor HitActor;

	// End:0x15B
	foreach __NFUN_321__(Class'R6Engine.R6Pawn', aPawn, m_fBlindEffectRadius, Location)
	{
		// End:0x15A
		if(__NFUN_155__(int(aPawn.m_eHealth), int(3)))
		{
			HitActor = aPawn.__NFUN_1806__(vHitLocation, vHitNormal, Location, __NFUN_215__(aPawn.Location, aPawn.EyePosition()), __NFUN_158__(__NFUN_158__(__NFUN_158__(1, 2), 4), 32));
			// End:0x15A
			if(__NFUN_114__(HitActor, none))
			{
				fDistFromFlashbang = __NFUN_225__(__NFUN_216__(aPawn.Location, Location));
				fEffectiveStunValue = __NFUN_171__(float(m_iEnergy), __NFUN_175__(float(1), __NFUN_172__(fDistFromFlashbang, m_fBlindEffectRadius)));
				vExplosionMomentum = __NFUN_212__(__NFUN_216__(vDamageLocation, Location), 0.2500000);
				vDamageLocation = aPawn.GetBoneCoords('R6 Head').Origin;
				aPawn.ServerForceStunResult(4);
				aPawn.R6TakeDamage(0, int(fEffectiveStunValue), Instigator, vDamageLocation, vExplosionMomentum, 0);
				aPawn.ServerForceStunResult(0);
				aPawn.AffectedByGrenade(self, 3);
			}
		}		
	}	
	// End:0x1DE
	foreach __NFUN_312__(Class'R6Engine.R6InteractiveObject', anObject, m_fExplosionRadius, Location)
	{
		// End:0x1DD
		if(__NFUN_130__(__NFUN_242__(anObject.m_bBreakableByFlashBang, true), __NFUN_151__(anObject.m_iHitPoints, 0)))
		{
			anObject.R6TakeDamage(1000, int(fEffectiveStunValue), Instigator, anObject.Location, vect(0.0000000, 0.0000000, 0.0000000), 0);
		}		
	}	
	return;
}

defaultproperties
{
	m_fBlindEffectRadius=5000.0000000
	m_eGrenadeType=3
	m_iNumberOfFragments=0
	m_sndExplosionSound=Sound'Grenade_FlashBang.Play_FlashBang_Expl'
	m_pExplosionParticles=Class'R6SFX.R6FlashBangEffect'
	m_pExplosionLight=Class'R6SFX.R6GrenadeLight'
	m_iEnergy=4000
	m_fKillStunTransfer=0.3500000
	m_fExplosionRadius=500.0000000
	m_fExplosionDelay=2.0000000
	m_szAmmoName="FlashBang Grenade"
	m_szBulletType="GRENADE"
	LifeSpan=2.0000000
	DrawScale=1.5000000
	StaticMesh=StaticMesh'R63rdWeapons_SM.Grenades.R63rdGrenadeFlashbang'
}
