//=============================================================================
// R6BreachingChargeUnit - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6BreachingChargeUnit.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/08 * Created by Rima Brek
//=============================================================================
class R6BreachingChargeUnit extends R6DemolitionsUnit;

//a bullet hit the demolition charge
function bool DestroyedByImpact()
{
	R6IORotatingDoor(Owner).RemoveBreach(self);
	return super.DestroyedByImpact();
	return;
}

function HurtPawns()
{
	local R6InteractiveObject anObject;
	local R6Pawn aPawn, aPawnInstigator;
	local R6DemolitionsUnit aDemoUnit;
	local float fDistFromCharge;
	local Vector vExplosionMomentum, vDoorCenter, vActorDir, vFacingDir;
	local Rotator rDoorInit;
	local int _iHealth, _PawnsHurtCount;
	local bool _bCompilingStats;
	local Controller aC;
	local R6PlayerController aPC;
	local float fDistFromGrenade;
	local Actor HitActor;
	local Vector vHitLocation, vHitNormal;

	aPawnInstigator = R6Pawn(Instigator);
	vDoorCenter = R6IORotatingDoor(Owner).m_vVisibleCenter;
	_PawnsHurtCount = 0;
	_bCompilingStats = R6AbstractGameInfo(Level.Game).m_bCompilingStats;
	// End:0x85
	if((DrawScale3D.Y > float(0)))
	{
		vFacingDir = Cross(Vector(Rotation), vect(0.0000000, 0.0000000, -1.0000000));		
	}
	else
	{
		vFacingDir = Cross(Vector(Rotation), vect(0.0000000, 0.0000000, 1.0000000));
	}
	// End:0xD6
	foreach VisibleCollidingActors(Class'R6Weapons.R6DemolitionsUnit', aDemoUnit, m_fKillBlastRadius, Location)
	{
		// End:0xD5
		if((aDemoUnit != self))
		{
			aDemoUnit.DestroyedByImpact();
		}		
	}	
	R6IORotatingDoor(Owner).R6TakeDamage(m_iEnergy, 0, Instigator, vect(0.0000000, 0.0000000, 0.0000000), vFacingDir, 0);
	// End:0x4D4
	foreach CollidingActors(Class'R6Engine.R6Pawn', aPawn, (m_fExplosionRadius + 800.0000000), vDoorCenter)
	{
		// End:0x1A5
		if(((int(Level.NetMode) != int(NM_Standalone)) && (((!aPawnInstigator.m_bCanFireFriends) && aPawnInstigator.IsFriend(aPawn)) || ((!aPawnInstigator.m_bCanFireNeutrals) && aPawnInstigator.IsNeutral(aPawn)))))
		{
			continue;			
		}
		// End:0x4D3
		if((int(aPawn.m_eHealth) != int(3)))
		{
			HitActor = aPawn.R6Trace(vHitLocation, vHitNormal, vDoorCenter, aPawn.Location, ((2 | 4) | 32));
			// End:0x24C
			if((HitActor != none))
			{
				HitActor = aPawn.R6Trace(vHitLocation, vHitNormal, vDoorCenter, (aPawn.Location + aPawn.EyePosition()), ((2 | 4) | 32));
			}
			// End:0x25B
			if((HitActor != none))
			{
				continue;				
			}
			fDistFromCharge = VSize((aPawn.Location - vDoorCenter));
			vActorDir = Normal((aPawn.Location - vDoorCenter));
			vExplosionMomentum = ((aPawn.Location - vDoorCenter) * 0.2500000);
			// End:0x368
			if((Dot(vActorDir, vFacingDir) < float(0)))
			{
				// End:0x364
				if((fDistFromCharge < (m_fExplosionRadius * 0.5000000)))
				{
					// End:0x336
					if(((aPawnInstigator != none) && (!aPawnInstigator.IsFriend(aPawn))))
					{
						(_PawnsHurtCount++);
						R6AbstractGameInfo(Level.Game).IncrementRoundsFired(aPawnInstigator, _bCompilingStats);
					}
					aPawn.R6TakeDamage(0, m_iEnergy, Instigator, aPawn.Location, vExplosionMomentum, 0);
				}
				continue;				
			}
			// End:0x422
			if((fDistFromCharge < m_fKillBlastRadius))
			{
				aPawn.ServerForceKillResult(4);
				aPawn.R6TakeDamage(m_iEnergy, m_iEnergy, Instigator, aPawn.Location, vExplosionMomentum, 0);
				aPawn.ServerForceKillResult(0);
				// End:0x41F
				if(((aPawnInstigator != none) && (!aPawnInstigator.IsFriend(aPawn))))
				{
					(_PawnsHurtCount++);
					R6AbstractGameInfo(Level.Game).IncrementRoundsFired(aPawnInstigator, _bCompilingStats);
				}
				// End:0x4D3
				continue;
			}
			// End:0x4C1
			if((fDistFromCharge <= m_fExplosionRadius))
			{
				_iHealth = int(aPawn.m_eHealth);
				DistributeDamage(aPawn, Location);
				// End:0x4C1
				if((((_iHealth != int(aPawn.m_eHealth)) && (aPawnInstigator != none)) && (!aPawnInstigator.IsFriend(aPawn))))
				{
					R6AbstractGameInfo(Level.Game).IncrementRoundsFired(aPawnInstigator, _bCompilingStats);
				}
			}
			aPawn.AffectedByGrenade(self, 4);
		}		
	}	
	// End:0x508
	if((_PawnsHurtCount == 0))
	{
		R6AbstractGameInfo(Level.Game).IncrementRoundsFired(aPawnInstigator, _bCompilingStats);
	}
	aC = Level.ControllerList;
	J0x51C:

	// End:0x61E [Loop If]
	if((aC != none))
	{
		// End:0x607
		if((((aC.Pawn != none) && (int(aC.Pawn.m_ePawnType) == int(1))) && aC.Pawn.IsAlive()))
		{
			aPC = R6PlayerController(aC);
			// End:0x607
			if((aPC != none))
			{
				fDistFromGrenade = VSize((Location - aPC.Pawn.Location));
				// End:0x607
				if((fDistFromGrenade < m_fShakeRadius))
				{
					aPC.R6Shake(1.0000000, (m_fShakeRadius - fDistFromGrenade), 0.0500000);
					aPC.ClientPlaySound(m_sndEarthQuake, 3);
				}
			}
		}
		aC = aC.nextController;
		// [Loop Continue]
		goto J0x51C;
	}
	return;
}

defaultproperties
{
	m_iNumberOfFragments=1
	m_sndExplosionSound=Sound'Gadget_BreachingCharge.Play_random_Breaching_Expl'
	m_pExplosionParticles=Class'R6SFX.R6BreachingChargeEffect'
	m_pExplosionLight=Class'R6SFX.R6GrenadeLight'
	m_iEnergy=8000
	m_fExplosionRadius=200.0000000
	m_fKillBlastRadius=100.0000000
	m_szAmmoName="Breaching Charge"
	Physics=0
	m_bDrawFromBase=true
	bCollideWorld=false
	StaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdBreachingCharge'
}
