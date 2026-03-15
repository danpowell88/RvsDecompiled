//=============================================================================
// R6FragGrenade - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6FragGrenade.uc : Normal frag grenade
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/17/09 * Created by Sebastien Lussier
//=============================================================================
class R6FragGrenade extends R6Grenade;

var float m_fTimerCounter;

function Activate()
{
	// End:0x21
	if((m_fExplosionDelay != float(0)))
	{
		m_fTimerCounter = 0.0000000;
		SetTimer(0.2000000, true);
	}
	return;
}

simulated event Timer()
{
	local R6RainbowAI rainbowAI;
	local Controller aController;
	local R6Pawn aGrenadeOwner;
	local float fDangerZone;

	(m_fTimerCounter += 0.2000000);
	// End:0x2A
	if((m_fTimerCounter >= m_fExplosionDelay))
	{
		Explode();
		SelfDestroy();		
	}
	else
	{
		aGrenadeOwner = R6Pawn(Owner.Owner);
		// End:0x77
		if(((aGrenadeOwner != none) && (int(aGrenadeOwner.m_ePawnType) == int(1))))
		{
			fDangerZone = m_fKillBlastRadius;			
		}
		else
		{
			fDangerZone = m_fExplosionRadius;
		}
		aController = Level.ControllerList;
		J0x96:

		// End:0x17F [Loop If]
		if((aController != none))
		{
			rainbowAI = R6RainbowAI(aController);
			// End:0xD5
			if(((rainbowAI == none) || (rainbowAI.Pawn == none)))
			{				
			}
			else
			{
				// End:0x168
				if((VSize((Location - rainbowAI.Pawn.Location)) < fDangerZone))
				{
					// End:0x168
					if(((Velocity == vect(0.0000000, 0.0000000, 0.0000000)) || (Location.Z < rainbowAI.Pawn.Location.Z)))
					{
						rainbowAI.FragGrenadeInProximity(Location, (m_fExplosionDelay - m_fTimerCounter), fDangerZone);
					}
				}
			}
			aController = aController.nextController;
			// [Loop Continue]
			goto J0x96;
		}
	}
	return;
}

function Explode()
{
	local R6SmokeCloud pCloud;

	pCloud = Spawn(Class'R6Weapons.R6SmokeCloud',,, (Location + vect(0.0000000, 0.0000000, 125.0000000)), rot(0, 0, 0));
	pCloud.SetCloud(self, 1.5000000, 150.0000000, 4.0000000);
	SetTimer(0.0000000, false);
	super.Explode();
	return;
}

function HurtPawns()
{
	local R6InteractiveObject anObject;
	local R6DemolitionsUnit aDemoUnit;
	local R6Pawn aPawn, aPawnInstigator;
	local R6Grenade.eGrenadeBoneTarget eBoneTarget;
	local R6IORotatingDoor pImADoor;
	local float fDistFromGrenade, fDamagePercent, fEffectiveKillValue, fEffectiveStunValue;
	local Vector vDamageLocation, vExplosionMomentum;
	local int iCurrentFragment;
	local float fCurrentNumberOfFragments;
	local int _iHealth, _PawnsHurtCount;
	local bool _bCompilingStats;
	local Controller aC;
	local R6PlayerController aPC;

	aPawnInstigator = R6Pawn(Instigator);
	_bCompilingStats = R6AbstractGameInfo(Level.Game).m_bCompilingStats;
	// End:0x5E
	foreach VisibleCollidingActors(Class'R6Weapons.R6DemolitionsUnit', aDemoUnit, m_fKillBlastRadius, Location)
	{
		aDemoUnit.DestroyedByImpact();		
	}	
	// End:0x16F
	foreach VisibleCollidingActors(Class'R6Engine.R6InteractiveObject', anObject, m_fExplosionRadius, Location)
	{
		fDistFromGrenade = VSize((anObject.Location - Location));
		// End:0x16E
		if((fDistFromGrenade <= m_fExplosionRadius))
		{
			pImADoor = R6IORotatingDoor(anObject);
			// End:0xD7
			if((pImADoor != none))
			{
				vDamageLocation = pImADoor.m_vVisibleCenter;				
			}
			else
			{
				vDamageLocation = anObject.Location;
			}
			// End:0x10D
			if((fDistFromGrenade < m_fKillBlastRadius))
			{
				fEffectiveKillValue = float(Max(m_iEnergy, 0));				
			}
			else
			{
				fEffectiveKillValue = float(Max(int((float(m_iEnergy) * fDamagePercent)), 0));
			}
			// End:0x16E
			if((fEffectiveKillValue != float(0)))
			{
				vExplosionMomentum = (vDamageLocation - Location);
				anObject.R6TakeDamage(int(fEffectiveKillValue), 0, Instigator, vDamageLocation, vExplosionMomentum, 0);
			}
		}		
	}	
	// End:0x6A3
	foreach CollidingActors(Class'R6Engine.R6Pawn', aPawn, m_fExplosionRadius, Location)
	{
		// End:0x262
		if(((((int(Level.NetMode) != int(NM_Standalone)) && (int(aPawnInstigator.m_ePawnType) == int(1))) && (!((R6PlayerController(aPawn.Controller) != none) && (R6AbstractGameInfo(Level.Game).m_bFriendlyFire == true)))) && (((!aPawnInstigator.m_bCanFireFriends) && aPawnInstigator.IsFriend(aPawn)) || ((!aPawnInstigator.m_bCanFireNeutrals) && aPawnInstigator.IsNeutral(aPawn)))))
		{
			continue;			
		}
		// End:0x6A2
		if((int(aPawn.m_eHealth) != int(3)))
		{
			// End:0x6A2
			if(aPawn.PawnCanBeHurtFrom(Location))
			{
				fDistFromGrenade = VSize((aPawn.Location - Location));
				// End:0x3C1
				if((fDistFromGrenade <= m_fKillBlastRadius))
				{
					vExplosionMomentum = ((aPawn.Location - Location) * 0.2500000);
					aPawn.ServerForceKillResult(4);
					aPawn.R6TakeDamage(m_iEnergy, m_iEnergy, Instigator, aPawn.Location, vExplosionMomentum, 0);
					aPawn.ServerForceKillResult(0);
					// End:0x385
					if(((aPawnInstigator != none) && (!aPawnInstigator.IsFriend(aPawn))))
					{
						(_PawnsHurtCount++);
						R6AbstractGameInfo(Level.Game).IncrementRoundsFired(aPawnInstigator, _bCompilingStats);
					}
					// End:0x3BE
					if(bShowLog)
					{
						Log((("Pawn " $ string(aPawn)) $ " was killed by a grenade !"));
					}
					// End:0x6A2
					continue;
				}
				fDamagePercent = (1.0000000 - ((fDistFromGrenade - m_fKillBlastRadius) / m_fEffectiveOutsideKillRadius));
				// End:0x446
				if(bShowLog)
				{
					Log(((((("Actor " $ string(aPawn)) $ " was hit by a grenade.  Distance : ") $ string((fDistFromGrenade * 0.0100000))) $ " % : ") $ string(fDamagePercent)));
				}
				fCurrentNumberOfFragments = (float(m_iNumberOfFragments) * fDamagePercent);
				iCurrentFragment = 0;
				J0x461:

				// End:0x6A2 [Loop If]
				if((float(iCurrentFragment) < fCurrentNumberOfFragments))
				{
					eBoneTarget = HitRandomBodyPart(GetPawnPose(aPawn));
					switch(eBoneTarget)
					{
						// End:0x4B7
						case 0:
							vDamageLocation = aPawn.GetBoneCoords('R6 Head').Origin;
							// End:0x57D
							break;
						// End:0x4DE
						case 1:
							vDamageLocation = aPawn.GetBoneCoords('R6 Spine').Origin;
							// End:0x57D
							break;
						// End:0x505
						case 2:
							vDamageLocation = aPawn.GetBoneCoords('R6 L ForeArm').Origin;
							// End:0x57D
							break;
						// End:0x52C
						case 3:
							vDamageLocation = aPawn.GetBoneCoords('R6 R ForeArm').Origin;
							// End:0x57D
							break;
						// End:0x553
						case 4:
							vDamageLocation = aPawn.GetBoneCoords('R6 L Thigh').Origin;
							// End:0x57D
							break;
						// End:0x57A
						case 5:
							vDamageLocation = aPawn.GetBoneCoords('R6 R Thigh').Origin;
							// End:0x57D
							break;
						// End:0xFFFF
						default:
							break;
					}
					fDistFromGrenade = VSize((vDamageLocation - Location));
					fEffectiveKillValue = float(Max(int((float(m_iEnergy) * fDamagePercent)), 0));
					// End:0x698
					if((fEffectiveKillValue != float(0)))
					{
						fEffectiveStunValue = (fEffectiveKillValue + (fEffectiveKillValue * m_fKillStunTransfer));
						vExplosionMomentum = (vDamageLocation - Location);
						_iHealth = int(aPawn.m_eHealth);
						aPawn.R6TakeDamage(int(fEffectiveKillValue), int(fEffectiveStunValue), Instigator, vDamageLocation, vExplosionMomentum, 0);
						// End:0x698
						if((((_iHealth != int(aPawn.m_eHealth)) && (aPawnInstigator != none)) && (!aPawnInstigator.IsFriend(aPawn))))
						{
							(_PawnsHurtCount++);
							R6AbstractGameInfo(Level.Game).IncrementRoundsFired(aPawnInstigator, _bCompilingStats);
						}
					}
					(iCurrentFragment++);
					// [Loop Continue]
					goto J0x461;
				}
			}
		}		
	}	
	// End:0x6D7
	if((_PawnsHurtCount == 0))
	{
		R6AbstractGameInfo(Level.Game).IncrementRoundsFired(aPawnInstigator, _bCompilingStats);
	}
	aC = Level.ControllerList;
	J0x6EB:

	// End:0x7ED [Loop If]
	if((aC != none))
	{
		// End:0x7D6
		if((((aC.Pawn != none) && (int(aC.Pawn.m_ePawnType) == int(1))) && aC.Pawn.IsAlive()))
		{
			aPC = R6PlayerController(aC);
			// End:0x7D6
			if((aPC != none))
			{
				fDistFromGrenade = VSize((Location - aPC.Pawn.Location));
				// End:0x7D6
				if((fDistFromGrenade < m_fShakeRadius))
				{
					aPC.R6Shake(1.0000000, __NFUN_175__(m_fShakeRadius, fDistFromGrenade), 0.0500000);
					aPC.ClientPlaySound(m_sndEarthQuake, 3);
				}
			}
		}
		aC = aC.nextController;
		// [Loop Continue]
		goto J0x6EB;
	}
	return;
}

defaultproperties
{
	m_sndExplodeMetal=Sound'Grenade_Frag.Play_random_Frag_Expl_Metal'
	m_sndExplodeWater=Sound'Grenade_Frag.Play_Frag_Expl_Water'
	m_sndExplodeAir=Sound'Grenade_Frag.Play_Frag_Expl_Air'
	m_sndExplodeDirt=Sound'Grenade_Frag.Play_random_Frag_Expl_Dirt'
	m_pExplosionParticles=Class'R6SFX.R6FragGrenadeEffect'
	m_pExplosionLight=Class'R6SFX.R6GrenadeLight'
	m_GrenadeDecalClass=Class'R6Engine.R6GrenadeDecal'
	m_DmgPercentStand=(fHead=0.0800000,fBody=0.5000000,fArms=0.2000000,fLegs=0.2600000)
	m_DmgPercentCrouch=(fHead=0.1200000,fBody=0.2500000,fArms=0.3200000,fLegs=0.5000000)
	m_DmgPercentProne=(fHead=0.7600000,fBody=0.0200000,fArms=0.2000000,fLegs=0.0200000)
	m_iEnergy=3000
	m_fKillStunTransfer=0.3500000
	m_fExplosionRadius=500.0000000
	m_fKillBlastRadius=300.0000000
	m_fExplosionDelay=2.5000000
	m_szAmmoName="Fragmentation Grenade"
	m_szBulletType="GRENADE"
	LifeSpan=2.7000000
	DrawScale=1.5000000
	StaticMesh=StaticMesh'R63rdWeapons_SM.Grenades.R63rdGrenadeHE'
}
