//=============================================================================
// R6Bullet - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
// Class            r6bullet
// Created By       Joel Tremblay
// Date             2001/05/08
// Description      Bullet for the Rainbow combat model
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6Bullet extends R6
    AbstractBullet
    native;

enum eHitResult
{
	HR_NoMaterial,                  // 0
	HR_Explode,                     // 1
	HR_Ricochet,                    // 2
	HR_GoThrough                    // 3
};

var(Rainbow) int m_iEnergy;
var(Rainbow) int m_iPenetrationFactor;
var(Rainbow) int m_iNoArmorModifier;
var int m_iBulletGroupID;  // Especially for shotguns, this is used to determine which other bullets where spawned
var bool m_bBulletIsGone;
var bool m_bIsGrenade;
var bool m_bBulletDeactivated;
var bool bShowLog;
var(Rainbow) float m_fKillStunTransfer;
//for Range Conversion  x�/m_fRangeConversionConst + x  (for Kill)  x�/m_fRangeConversionConst (stun)
var(Rainbow) float m_fRangeConversionConst;
var(Rainbow) float m_fRange;
var(R6Grenade) float m_fExplosionRadius;
var(R6Grenade) float m_fKillBlastRadius;
var(Rainbow) float m_fExplosionDelay;  // delay before explosion (for grenades and mines)
                                  // at the same time from the same weapon (I don't mean from rapid fire but fragments from 
                                  // shells)
var Actor m_AffectedActor;  // which pawn did this bullet/fragment affect.
var R6BulletManager m_BulletManager;
var Vector m_vSpawnedPosition;  // used by BulletGoesThroughSurface
var(Rainbow) string m_szAmmoName;
var(Rainbow) string m_szAmmoType;
var(Rainbow) string m_szBulletType;

// Export UR6Bullet::execBulletGoesThroughSurface(FFrame&, void* const)
native(2001) final function R6Bullet.eHitResult BulletGoesThroughSurface(Actor TouchedSurface, Vector vHitLocation, out Vector vBulletVelocity, out Vector vRealHitLocation, out Vector vexitLocation, out Vector vexitNormal, out Class<R6WallHit> TouchedEffects, out Class<R6WallHit> ExitEffects);

function bool DestroyedByImpact()
{
	return false;
	return;
}

simulated function PostBeginPlay()
{
	super(Actor).PostBeginPlay();
	m_vSpawnedPosition = Location;
	m_bBulletIsGone = true;
	return;
}

simulated function SetSpeed(float fBulletSpeed)
{
	Velocity = (fBulletSpeed * Vector(Rotation));
	return;
}

// Bullet are not destroyed, but Deactivated and the reactivated by the bullet manager.
function DeactivateBullet()
{
	SetPhysics(0);
	bStasis = true;
	SetCollision(false, false, false);
	m_bBulletDeactivated = true;
	return;
}

//==============
// Touching
singular simulated function Touch(Actor Other)
{
	local Actor HitActor;
	local Vector vHitLocation, vHitNormal;
	local Material pMaterial;

	// End:0x47
	if(((((Other == Instigator) || (m_bBulletIsGone == false)) || (m_bBulletDeactivated == true)) || (Instigator.m_collisionBox == Other)))
	{
		return;
	}
	// End:0x74
	if((R6Bullet(Other) != none))
	{
		// End:0x74
		if(R6Bullet(Other).DestroyedByImpact())
		{
			DeactivateBullet();
		}
	}
	// End:0x1A5
	if(((Other.bProjTarget || (Other.bBlockActors && Other.bBlockPlayers)) || Other.IsA('R6ColBox')))
	{
		HitActor = Instigator.R6Trace(vHitLocation, vHitNormal, (Location + (Other.CollisionRadius * Normal((Location - m_vSpawnedPosition)))), m_vSpawnedPosition, (4 | 1));
		// End:0x163
		if((HitActor == Other))
		{
			ProcessTouch(Other, vHitLocation);
			// End:0x160
			if((pMaterial != none))
			{
				SpawnSFX(pMaterial.m_pHitEffect, vHitLocation, Rotator(vHitNormal), Other, 0);
			}			
		}
		else
		{
			ProcessTouch(Other, (Other.Location + (Other.CollisionRadius * Normal((Location - Other.Location)))));
		}
	}
	return;
}

//============================================================================
// function ProcessTouch - 
//============================================================================
simulated function ProcessTouch(Actor Other, Vector vHitLocation)
{
	local float fResultKillEnergy, fResultStunEnergy, fRange;
	local R6Pawn OtherPawn, instigatorPawn;

	// End:0x2CC
	if((Other != Instigator))
	{
		// End:0x2A3
		if((int(Role) == int(ROLE_Authority)))
		{
			fRange = VSize((Location - m_vSpawnedPosition));
			(fRange /= float(100));
			fResultKillEnergy = (float(m_iEnergy) - RangeConversion(fRange));
			// End:0x72
			if((fResultKillEnergy < 10.0000000))
			{
				fResultKillEnergy = 10.0000000;
			}
			fResultStunEnergy = ((float(m_iEnergy) + (fResultKillEnergy * m_fKillStunTransfer)) - StunLoss(fRange));
			// End:0xB4
			if((fResultKillEnergy < 15.0000000))
			{
				fResultKillEnergy = 15.0000000;
			}
			// End:0x136
			if(bShowLog)
			{
				Log(((((((((((("Bullet" $ string(self)) $ " Hit ") $ string(Other)) $ " By :") $ string(Instigator)) $ " at location ") $ string(vHitLocation)) $ " with energy : ") $ string(fResultKillEnergy)) $ " : ") $ string(fResultKillEnergy)));
			}
			OtherPawn = R6Pawn(Other);
			// End:0x1C2
			if(((OtherPawn == none) && Other.IsA('R6ColBox')))
			{
				// End:0x1A9
				if((R6ColBox(Other).m_fFeetColBoxRadius != 0.0000000))
				{
					OtherPawn = R6Pawn(Other.Base.Base);					
				}
				else
				{
					OtherPawn = R6Pawn(Other.Base);
				}
			}
			instigatorPawn = R6Pawn(Instigator);
			// End:0x245
			if((((OtherPawn != none) && ((!instigatorPawn.m_bCanFireFriends) && instigatorPawn.IsFriend(OtherPawn))) || ((!instigatorPawn.m_bCanFireNeutrals) && instigatorPawn.IsNeutral(OtherPawn))))
			{
				m_iEnergy = 0;				
			}
			else
			{
				m_iEnergy = Other.R6TakeDamage(int(fResultKillEnergy), int(fResultStunEnergy), Instigator, vHitLocation, Velocity, m_iNoArmorModifier, m_iBulletGroupID);
			}
			// End:0x2A3
			if(((m_iEnergy == 0) || (m_szBulletType == "JHP")))
			{
				DeactivateBullet();
			}
		}
		// End:0x2CC
		if(bShowLog)
		{
			Log(((string(self) @ "Hit :") $ string(Other.Name)));
		}
	}
	return;
}

//============================================================================
// function SpawnSFX - 
//============================================================================
simulated function SpawnSFX(Class<R6WallHit> fxClass, Vector vLocation, Rotator vRotation, Actor pSource, R6WallHit.EHitType eType)
{
	local R6WallHit WallHitEffect;

	// End:0x74
	if((fxClass != none))
	{
		WallHitEffect = Spawn(fxClass,,, vLocation, vRotation);
		// End:0x60
		if((WallHitEffect != none))
		{
			// End:0x60
			if((m_BulletManager.AffectActor(m_iBulletGroupID, pSource) == false))
			{
				WallHitEffect.m_bPlayEffectSound = false;
			}
		}
		WallHitEffect.m_eHitType = eType;
	}
	return;
}

//============================================================================
// event HitWall  - 
//============================================================================
simulated event HitWall(Vector vHitNormal, Actor Wall)
{
	local R6Bullet.eHitResult eHitResult;
	local Class<R6WallHit> CurrentHitEffect, ExitHitEffect;
	local Vector vRealHitLocation, vexitLocation, vexitNormal;
	local int iInitialEnergy;
	local Vector vRangeVector;
	local float fDistance;

	iInitialEnergy = m_iEnergy;
	eHitResult = BulletGoesThroughSurface(Wall, Location, Velocity, vRealHitLocation, vexitLocation, vexitNormal, CurrentHitEffect, ExitHitEffect);
	// End:0xE1
	if(((Wall.IsA('R6InteractiveObject') || Wall.IsA('R6MorphMeshActor')) || Wall.IsA('Mover')))
	{
		vRangeVector = (vRealHitLocation - m_vSpawnedPosition);
		fDistance = (VSize(vRangeVector) * 0.0100000);
		Wall.R6TakeDamage(int((float(iInitialEnergy) - RangeConversion(fDistance))), 0, Instigator, vRealHitLocation, Velocity, m_iPenetrationFactor, -1);
	}
	switch(eHitResult)
	{
		// End:0x14C
		case 3:
			SpawnSFX(CurrentHitEffect, vRealHitLocation, Rotator(vHitNormal), Wall, 0);
			SpawnSFX(ExitHitEffect, vexitLocation, Rotator(vexitNormal), Wall, 2);
			// End:0x149
			if((!SetLocation((vexitLocation + (vexitNormal * float(2))))))
			{
				DeactivateBullet();
			}
			// End:0x1DF
			break;
		// End:0x178
		case 1:
			SpawnSFX(CurrentHitEffect, vRealHitLocation, Rotator(vHitNormal), Wall, 0);
			DeactivateBullet();
			// End:0x1DF
			break;
		// End:0x1A4
		case 2:
			SpawnSFX(CurrentHitEffect, vRealHitLocation, Rotator(vHitNormal), Wall, 1);
			DeactivateBullet();
			// End:0x1DF
			break;
		// End:0x1B2
		case 0:
			DeactivateBullet();
			// End:0x1DF
			break;
		// End:0xFFFF
		default:
			Log("!!! We have a serious problem HERE !!!");
			break;
	}
	return;
}

function float RangeConversion(float fRange)
{
	return (((fRange * fRange) * m_fRangeConversionConst) + m_fRangeConversionConst);
	return;
}

function float StunLoss(float fRange)
{
	return ((fRange * fRange) * m_fRangeConversionConst);
	return;
}

defaultproperties
{
	m_iEnergy=100
	m_iPenetrationFactor=1
	m_fKillStunTransfer=0.0100000
	m_fRangeConversionConst=0.1000000
	m_fRange=100.0000000
	m_szAmmoName="R6Bullet"
	m_szAmmoType="Normal"
	m_szBulletType="JHP"
	RemoteRole=0
	DrawType=0
	AmbientGlow=167
	SoundPitch=100
	bHidden=true
	bStasis=true
	bNetTemporary=true
	bReplicateInstigator=true
	m_bDeleteOnReset=true
	bGameRelevant=true
	bCollideActors=true
	bCollideWorld=true
	m_bDoPerBoneTrace=true
	bBounce=true
	SoundRadius=4.0000000
	NetPriority=2.5000000
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function BulletGoesThroughSurface
