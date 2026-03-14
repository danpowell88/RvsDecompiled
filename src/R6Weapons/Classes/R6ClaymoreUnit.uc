//=============================================================================
// R6ClaymoreUnit - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6ClaymoreUnit.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/09 * Created by Rima Brek
//=============================================================================
class R6ClaymoreUnit extends R6DemolitionsUnit;

function HurtPawns()
{
	local R6InteractiveObject anObject;
	local R6Pawn aPawn, aPawnInstigator;
	local R6DemolitionsUnit aDemoUnit;
	local float fDistFromGrenade;
	local Vector vExplosionMomentum, vActorDir, vFacingDir;
	local int _iHealth, _PawnsHurtCount;
	local bool _bCompilingStats;
	local Controller aC;
	local R6PlayerController aPC;

	aPawnInstigator = R6Pawn(Instigator);
	_bCompilingStats = R6AbstractGameInfo(Level.Game).m_bCompilingStats;
	// End:0x69
	foreach __NFUN_312__(Class'R6Weapons.R6DemolitionsUnit', aDemoUnit, m_fKillBlastRadius, Location)
	{
		// End:0x68
		if(__NFUN_119__(aDemoUnit, self))
		{
			aDemoUnit.DestroyedByImpact();
		}		
	}	
	vFacingDir = Vector(__NFUN_316__(Rotation, rot(0, 32768, 0)));
	// End:0x148
	foreach __NFUN_312__(Class'R6Engine.R6InteractiveObject', anObject, m_fExplosionRadius, Location)
	{
		vActorDir = __NFUN_216__(anObject.Location, Location);
		vActorDir.Z = 0.0000000;
		vActorDir = __NFUN_226__(vActorDir);
		fDistFromGrenade = __NFUN_225__(__NFUN_216__(anObject.Location, Location));
		// End:0x128
		if(__NFUN_130__(__NFUN_177__(fDistFromGrenade, __NFUN_171__(m_fKillBlastRadius, 0.5000000)), __NFUN_176__(__NFUN_219__(vActorDir, vFacingDir), 0.7411810)))
		{
			continue;			
		}
		// End:0x147
		if(__NFUN_178__(fDistFromGrenade, m_fExplosionRadius))
		{
			DistributeDamage(anObject, Location);
		}		
	}	
	// End:0x41A
	foreach __NFUN_321__(Class'R6Engine.R6Pawn', aPawn, m_fExplosionRadius, Location)
	{
		// End:0x1DE
		if(__NFUN_130__(__NFUN_155__(int(Level.NetMode), int(NM_Standalone)), __NFUN_132__(__NFUN_130__(__NFUN_129__(aPawnInstigator.m_bCanFireFriends), aPawnInstigator.IsFriend(aPawn)), __NFUN_130__(__NFUN_129__(aPawnInstigator.m_bCanFireNeutrals), aPawnInstigator.IsNeutral(aPawn)))))
		{
			continue;			
		}
		// End:0x419
		if(__NFUN_155__(int(aPawn.m_eHealth), int(3)))
		{
			// End:0x419
			if(aPawn.__NFUN_1845__(Location))
			{
				fDistFromGrenade = __NFUN_225__(__NFUN_216__(aPawn.Location, Location));
				vActorDir = __NFUN_216__(aPawn.Location, Location);
				vActorDir.Z = 0.0000000;
				vActorDir = __NFUN_226__(vActorDir);
				// End:0x36C
				if(__NFUN_132__(__NFUN_178__(fDistFromGrenade, __NFUN_171__(m_fKillBlastRadius, 0.5000000)), __NFUN_130__(__NFUN_177__(__NFUN_219__(vActorDir, vFacingDir), 0.7411810), __NFUN_178__(fDistFromGrenade, m_fKillBlastRadius))))
				{
					vExplosionMomentum = __NFUN_212__(__NFUN_216__(aPawn.Location, Location), 0.2500000);
					aPawn.ServerForceKillResult(4);
					aPawn.R6TakeDamage(m_iEnergy, m_iEnergy, aPawnInstigator, aPawn.Location, vExplosionMomentum, 0);
					aPawn.ServerForceKillResult(0);
					// End:0x369
					if(__NFUN_130__(__NFUN_119__(aPawnInstigator, none), __NFUN_129__(aPawnInstigator.IsFriend(aPawn))))
					{
						__NFUN_165__(_PawnsHurtCount);
						R6AbstractGameInfo(Level.Game).IncrementRoundsFired(aPawnInstigator, _bCompilingStats);
					}
					// End:0x419
					continue;
				}
				// End:0x419
				if(__NFUN_177__(__NFUN_219__(vActorDir, vFacingDir), 0.7411810))
				{
					_iHealth = int(aPawn.m_eHealth);
					DistributeDamage(aPawn, Location);
					// End:0x419
					if(__NFUN_130__(__NFUN_130__(__NFUN_155__(_iHealth, int(aPawn.m_eHealth)), __NFUN_119__(aPawnInstigator, none)), __NFUN_129__(aPawnInstigator.IsFriend(aPawn))))
					{
						__NFUN_165__(_PawnsHurtCount);
						R6AbstractGameInfo(Level.Game).IncrementRoundsFired(aPawnInstigator, _bCompilingStats);
					}
				}
			}
		}		
	}	
	// End:0x44E
	if(__NFUN_154__(_PawnsHurtCount, 0))
	{
		R6AbstractGameInfo(Level.Game).IncrementRoundsFired(aPawnInstigator, _bCompilingStats);
	}
	aC = Level.ControllerList;
	J0x462:

	// End:0x564 [Loop If]
	if(__NFUN_119__(aC, none))
	{
		// End:0x54D
		if(__NFUN_130__(__NFUN_130__(__NFUN_119__(aC.Pawn, none), __NFUN_154__(int(aC.Pawn.m_ePawnType), int(1))), aC.Pawn.IsAlive()))
		{
			aPC = R6PlayerController(aC);
			// End:0x54D
			if(__NFUN_119__(aPC, none))
			{
				fDistFromGrenade = __NFUN_225__(__NFUN_216__(Location, aPC.Pawn.Location));
				// End:0x54D
				if(__NFUN_176__(fDistFromGrenade, m_fShakeRadius))
				{
					aPC.R6Shake(1.0000000, __NFUN_175__(m_fShakeRadius, fDistFromGrenade), 0.0500000);
					aPC.ClientPlaySound(m_sndEarthQuake, 3);
				}
			}
		}
		aC = aC.nextController;
		// [Loop Continue]
		goto J0x462;
	}
	return;
}

defaultproperties
{
	m_sndExplodeMetal=Sound'Gadget_Claymore.Play_Claymore_Expl_Metal'
	m_sndExplodeDirt=Sound'Gadget_Claymore.Play_Claymore_Expl_Dirt'
	m_pExplosionParticles=Class'R6SFX.R6ClaymoreMineEffect'
	m_pExplosionLight=Class'R6SFX.R6GrenadeLight'
	m_iEnergy=2000
	m_fExplosionRadius=700.0000000
	m_fKillBlastRadius=400.0000000
	m_szAmmoName="Claymore Mine"
	StaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdClaymore'
}
