//=============================================================================
// R6ExplodingBarel - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6ExplodingBarel : 
//  Copyright 2003 Ubi Soft, Inc. All Rights Reserved.
//=============================================================================
class R6ExplodingBarel extends R6InteractiveObject
    placeable;

var(R6ActionObject) int m_iEnergy;
var(R6ActionObject) float m_fExplosionRadius;  // feel the sake
var(R6ActionObject) float m_fKillBlastRadius;  // killed by the bomb
var Emitter m_pEmmiter;
var Class<Light> m_pExplosionLight;

function int R6TakeDamage(int iKillValue, int iStunValue, Pawn instigatedBy, Vector vHitLocation, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGroup)
{
	local int iDamage;

	// End:0x0B
	if(m_bBroken)
	{
		return 0;
	}
	iDamage = super.R6TakeDamage(iKillValue, iStunValue, instigatedBy, vHitLocation, vMomentum, iBulletToArmorModifier, iBulletGroup);
	// End:0x54
	if(m_bBroken)
	{
		Instigator = instigatedBy;
		Explode();
	}
	return iDamage;
	return;
}

function Explode()
{
	local R6GrenadeDecal GrenadeDecal;
	local Rotator GrenadeDecalRotation;
	local Light pEffectLight;
	local Vector vDecalLoc;
	local float fDistFromBarel;
	local Actor aActor;
	local R6Pawn pPawn;
	local R6InteractiveObject pIO;
	local R6PlayerController pPC;
	local int iKillResult;

	AmbientSound = none;
	m_bBroken = true;
	vDecalLoc = Location;
	(vDecalLoc.Z -= float(55));
	GrenadeDecal = Spawn(Class'R6Engine.R6GrenadeDecal',,, vDecalLoc, GrenadeDecalRotation);
	m_pEmmiter = Spawn(Class'R6SFX.R6ExplosiveDrum');
	m_pEmmiter.RemoteRole = ROLE_AutonomousProxy;
	m_pEmmiter.Role = ROLE_Authority;
	pEffectLight = Spawn(m_pExplosionLight);
	// End:0x2C9
	foreach CollidingActors(Class'Engine.Actor', aActor, m_fExplosionRadius, Location)
	{
		pPawn = R6Pawn(aActor);
		// End:0x209
		if((pPawn != none))
		{
			// End:0x206
			if(pPawn.IsAlive())
			{
				// End:0x18E
				if(FastTrace(Location, pPawn.Location))
				{
					fDistFromBarel = VSize((pPawn.Location - Location));
					// End:0x119
					if((fDistFromBarel <= m_fKillBlastRadius))
					{
						iKillResult = 4;						
					}
					else
					{
						iKillResult = 2;
					}
					pPawn.ServerForceKillResult(iKillResult);
					pPawn.R6TakeDamage(m_iEnergy, m_iEnergy, Instigator, pPawn.Location, ((pPawn.Location - Location) * 0.2500000), 0);
					pPawn.ServerForceKillResult(0);
				}
				// End:0x206
				if(pPawn.IsAlive())
				{
					pPC = R6PlayerController(pPawn.Controller);
					// End:0x206
					if((pPC != none))
					{
						fDistFromBarel = VSize((pPawn.Location - Location));
						pPC.R6Shake(1.5000000, (m_fExplosionRadius - fDistFromBarel), 0.1000000);
					}
				}
			}
			// End:0x2C8
			continue;
		}
		pIO = R6InteractiveObject(aActor);
		// End:0x2C8
		if((pIO != none))
		{
			// End:0x2C8
			if((!pIO.m_bBroken))
			{
				fDistFromBarel = VSize((pIO.Location - Location));
				// End:0x2C8
				if(((fDistFromBarel <= m_fKillBlastRadius) || FastTrace(Location, pIO.Location)))
				{
					pIO.R6TakeDamage(m_iEnergy, m_iEnergy, Instigator, pIO.Location, ((pIO.Location - Location) * 0.2500000), 0);
				}
			}
		}		
	}	
	R6MakeNoise(5);
	return;
}

defaultproperties
{
	m_iEnergy=3000
	m_fExplosionRadius=1000.0000000
	m_fKillBlastRadius=500.0000000
	m_pExplosionLight=Class'R6SFX.R6GrenadeLight'
	m_iHitPoints=2000
	m_StateList[0]=(RandomMeshes=((fPercentage=100.0000000,Mesh=StaticMesh'R6SFX_SM.Other.ExplosiveDrum_Broken')),ActorList=((ActorToSpawn=Class'R6SFX.R6Fire_C',HelperName="Flame")))
	DrawType=8
	StaticMesh=StaticMesh'R6SFX_SM.Other.ExplosiveDrum'
}
