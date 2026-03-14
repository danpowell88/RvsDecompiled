//=============================================================================
// R6DemolitionsUnit - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6DemolitionsUnit.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/09 * Created by Rima Brek
//=============================================================================
class R6DemolitionsUnit extends R6Grenade;

var bool m_bExploding;

function Activate()
{
	return;
}

simulated function HitWall(Vector HitNormal, Actor Wall)
{
	return;
}

simulated function Landed(Vector HitNormal)
{
	return;
}

singular simulated function Touch(Actor Other)
{
	return;
}

simulated function ProcessTouch(Actor Other, Vector vHitLocation)
{
	return;
}

function Explode()
{
	m_bExploding = true;
	super.Explode();
	SelfDestroy();
	return;
}

//a bullet hit the demolition charge
function bool DestroyedByImpact()
{
	__NFUN_278__(Class'R6SFX.R6BreakablePhone', none,, Location);
	m_Weapon.MyUnitIsDestroyed();
	m_bDestroyedByImpact = true;
	SelfDestroy();
	return true;
	return;
}

function DoorExploded()
{
	// End:0x11
	if(__NFUN_129__(m_bExploding))
	{
		DestroyedByImpact();
	}
	return;
}

function DistributeDamage(Actor anActor, Vector vLocationOfExplosion)
{
	local int iCurrentFragment;
	local float fCurrentNumberOfFragments;
	local Vector vHit, vHitNormal, vExplosionMomentum, vDamageLocation;
	local float fDistFromGrenade;
	local R6Grenade.eGrenadeBoneTarget eBoneTarget;
	local float fDamagePercent, fEffectiveKillValue, fEffectiveStunValue;
	local R6IORotatingDoor pImADoor;

	fDistFromGrenade = __NFUN_225__(__NFUN_216__(anActor.Location, Location));
	fDamagePercent = __NFUN_175__(1.0000000, __NFUN_172__(__NFUN_175__(fDistFromGrenade, m_fKillBlastRadius), m_fEffectiveOutsideKillRadius));
	// End:0x90
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Actor ", string(anActor)), " was hit by a grenade.  Distance : "), string(__NFUN_171__(fDistFromGrenade, 0.0100000))));
	}
	// End:0x281
	if(anActor.__NFUN_303__('R6Pawn'))
	{
		fCurrentNumberOfFragments = __NFUN_171__(float(m_iNumberOfFragments), fDamagePercent);
		iCurrentFragment = 0;
		J0xBF:

		// End:0x27E [Loop If]
		if(__NFUN_176__(float(iCurrentFragment), fCurrentNumberOfFragments))
		{
			eBoneTarget = HitRandomBodyPart(GetPawnPose(R6Pawn(anActor)));
			switch(eBoneTarget)
			{
				// End:0x11A
				case 0:
					vDamageLocation = anActor.GetBoneCoords('R6 Head').Origin;
					// End:0x1E0
					break;
				// End:0x141
				case 1:
					vDamageLocation = anActor.GetBoneCoords('R6 Spine').Origin;
					// End:0x1E0
					break;
				// End:0x168
				case 2:
					vDamageLocation = anActor.GetBoneCoords('R6 L ForeArm').Origin;
					// End:0x1E0
					break;
				// End:0x18F
				case 3:
					vDamageLocation = anActor.GetBoneCoords('R6 R ForeArm').Origin;
					// End:0x1E0
					break;
				// End:0x1B6
				case 4:
					vDamageLocation = anActor.GetBoneCoords('R6 L Thigh').Origin;
					// End:0x1E0
					break;
				// End:0x1DD
				case 5:
					vDamageLocation = anActor.GetBoneCoords('R6 R Thigh').Origin;
					// End:0x1E0
					break;
				// End:0xFFFF
				default:
					break;
			}
			fDistFromGrenade = __NFUN_225__(__NFUN_216__(vDamageLocation, vLocationOfExplosion));
			fEffectiveKillValue = float(__NFUN_250__(int(__NFUN_171__(float(m_iEnergy), fDamagePercent)), 0));
			// End:0x274
			if(__NFUN_181__(fEffectiveKillValue, float(0)))
			{
				fEffectiveStunValue = __NFUN_174__(fEffectiveKillValue, __NFUN_171__(fEffectiveKillValue, m_fKillStunTransfer));
				vExplosionMomentum = __NFUN_216__(vDamageLocation, vLocationOfExplosion);
				anActor.R6TakeDamage(int(fEffectiveKillValue), int(fEffectiveStunValue), Instigator, vDamageLocation, vExplosionMomentum, 0);
			}
			__NFUN_165__(iCurrentFragment);
			// [Loop Continue]
			goto J0xBF;
		}		
	}
	else
	{
		pImADoor = R6IORotatingDoor(anActor);
		// End:0x2B3
		if(__NFUN_119__(pImADoor, none))
		{
			vDamageLocation = pImADoor.m_vVisibleCenter;			
		}
		else
		{
			vDamageLocation = anActor.Location;
		}
		// End:0x2E9
		if(__NFUN_176__(fDistFromGrenade, m_fKillBlastRadius))
		{
			fEffectiveKillValue = float(__NFUN_250__(m_iEnergy, 0));			
		}
		else
		{
			fEffectiveKillValue = float(__NFUN_250__(int(__NFUN_171__(float(m_iEnergy), fDamagePercent)), 0));
		}
		// End:0x34A
		if(__NFUN_181__(fEffectiveKillValue, float(0)))
		{
			vExplosionMomentum = __NFUN_216__(vDamageLocation, vLocationOfExplosion);
			anActor.R6TakeDamage(int(fEffectiveKillValue), 0, Instigator, vDamageLocation, vExplosionMomentum, 0);
		}
	}
	return;
}

defaultproperties
{
	m_DmgPercentStand=(fHead=0.0800000,fBody=0.5000000,fArms=0.2000000,fLegs=0.2600000)
	m_DmgPercentCrouch=(fHead=0.1200000,fBody=0.2500000,fArms=0.3200000,fLegs=0.5000000)
	m_DmgPercentProne=(fHead=0.7600000,fBody=0.0200000,fArms=0.2000000,fLegs=0.0200000)
	m_fKillStunTransfer=0.3500000
	m_fExplosionDelay=0.0000000
	m_szBulletType="DEMOLITIONS"
}
