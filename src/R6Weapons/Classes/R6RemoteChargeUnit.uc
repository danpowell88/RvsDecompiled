//=============================================================================
// R6RemoteChargeUnit - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6RemoteChargeUnit.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/08 * Created by Rima Brek
//=============================================================================
class R6RemoteChargeUnit extends R6DemolitionsUnit;

function HurtPawns()
{
	local R6InteractiveObject anObject;
	local R6Pawn aPawn, aPawnInstigator;
	local R6DemolitionsUnit aDemoUnit;
	local float fDistFromGrenade;
	local Vector vExplosionMomentum;
	local int _iHealth, _PawnsHurtCount;
	local bool _bCompilingStats;
	local Controller aC;
	local R6PlayerController aPC;

	aPawnInstigator = R6Pawn(Instigator);
	_bCompilingStats = R6AbstractGameInfo(Level.Game).m_bCompilingStats;
	// End:0x69
	foreach VisibleCollidingActors(Class'R6Weapons.R6DemolitionsUnit', aDemoUnit, m_fKillBlastRadius, Location)
	{
		// End:0x68
		if((aDemoUnit != self))
		{
			aDemoUnit.DestroyedByImpact();
		}		
	}	
	// End:0xC1
	foreach VisibleCollidingActors(Class'R6Engine.R6InteractiveObject', anObject, m_fExplosionRadius, Location)
	{
		fDistFromGrenade = VSize((anObject.Location - Location));
		// End:0xC0
		if((fDistFromGrenade <= m_fExplosionRadius))
		{
			DistributeDamage(anObject, Location);
		}		
	}	
	// End:0x315
	foreach CollidingActors(Class'R6Engine.R6Pawn', aPawn, m_fExplosionRadius, Location)
	{
		// End:0x157
		if(((int(Level.NetMode) != int(NM_Standalone)) && (((!aPawnInstigator.m_bCanFireFriends) && aPawnInstigator.IsFriend(aPawn)) || ((!aPawnInstigator.m_bCanFireNeutrals) && aPawnInstigator.IsNeutral(aPawn)))))
		{
			continue;			
		}
		// End:0x314
		if((int(aPawn.m_eHealth) != int(3)))
		{
			// End:0x314
			if(aPawn.PawnCanBeHurtFrom(Location))
			{
				fDistFromGrenade = VSize((aPawn.Location - Location));
				// End:0x27D
				if((fDistFromGrenade <= m_fKillBlastRadius))
				{
					vExplosionMomentum = ((aPawn.Location - Location) * 0.2500000);
					aPawn.ServerForceKillResult(4);
					aPawn.R6TakeDamage(m_iEnergy, m_iEnergy, Instigator, aPawn.Location, vExplosionMomentum, 0);
					aPawn.ServerForceKillResult(0);
					// End:0x27A
					if(((aPawnInstigator != none) && (!aPawnInstigator.IsFriend(aPawn))))
					{
						(_PawnsHurtCount++);
						R6AbstractGameInfo(Level.Game).IncrementRoundsFired(aPawnInstigator, _bCompilingStats);
					}
					// End:0x314
					continue;
				}
				_iHealth = int(aPawn.m_eHealth);
				DistributeDamage(aPawn, Location);
				// End:0x314
				if((((_iHealth != int(aPawn.m_eHealth)) && (aPawnInstigator != none)) && (!aPawnInstigator.IsFriend(aPawn))))
				{
					(_PawnsHurtCount++);
					R6AbstractGameInfo(Level.Game).IncrementRoundsFired(aPawnInstigator, _bCompilingStats);
				}
			}
		}		
	}	
	// End:0x349
	if((_PawnsHurtCount == 0))
	{
		R6AbstractGameInfo(Level.Game).IncrementRoundsFired(aPawnInstigator, _bCompilingStats);
	}
	aC = Level.ControllerList;
	J0x35D:

	// End:0x45F [Loop If]
	if((aC != none))
	{
		// End:0x448
		if((((aC.Pawn != none) && (int(aC.Pawn.m_ePawnType) == int(1))) && aC.Pawn.IsAlive()))
		{
			aPC = R6PlayerController(aC);
			// End:0x448
			if((aPC != none))
			{
				fDistFromGrenade = VSize((Location - aPC.Pawn.Location));
				// End:0x448
				if((fDistFromGrenade < m_fShakeRadius))
				{
					aPC.R6Shake(1.0000000, (m_fShakeRadius - fDistFromGrenade), 0.0500000);
					aPC.ClientPlaySound(m_sndEarthQuake, 3);
				}
			}
		}
		aC = aC.nextController;
		// [Loop Continue]
		goto J0x35D;
	}
	return;
}

defaultproperties
{
	m_sndExplodeMetal=Sound'Gadget_Claymore.Play_Claymore_Expl_Metal'
	m_sndExplodeDirt=Sound'Gadget_Claymore.Play_Claymore_Expl_Dirt'
	m_pExplosionParticles=Class'R6SFX.R6FragGrenadeEffect'
	m_pExplosionLight=Class'R6SFX.R6GrenadeLight'
	m_iEnergy=2000
	m_fExplosionRadius=600.0000000
	m_fKillBlastRadius=300.0000000
	m_szAmmoName="C4 Remote Charge"
	StaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdC4'
}
