//=============================================================================
// R6GenericHB - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6GenericHB extends R6InteractiveObject
    abstract
    native
    placeable;

var bool m_bFirstImpact;
var Sound m_ImpactSound;  // Sound made when projectile hits something.
var Sound m_ImpactGroundSound;
var Sound m_ImpactWaterSound;

simulated function SetSpeed(float fSpeed)
{
	Velocity = (fSpeed * Vector(Rotation));
	Acceleration = (Vector(Rotation) * float(50));
	SetDrawType(8);
	return;
}

simulated event HitWall(Vector HitNormal, Actor Wall)
{
	local Vector vTraceEnd;
	local Rotator rotGrenade;
	local float fOldHeight;
	local Vector vHitLocation, vHitNormal;
	local Actor pHit;
	local Material HitMaterial;

	// End:0xDE
	if((Wall != none))
	{
		// End:0x55
		if(((Instigator != none) && (Instigator.m_collisionBox == Wall)))
		{
			vTraceEnd = (Location + (float(10) * Normal(Velocity)));
			SetLocation(vTraceEnd, true);
			return;
		}
		// End:0xDE
		if((Wall.m_bBulletGoThrough && Wall.IsA('R6InteractiveObject')))
		{
			Wall.R6TakeDamage(10000, 10000, Instigator, Wall.Location, Velocity, 0);
			vTraceEnd = (Location - (float(10) * HitNormal));
			SetLocation(vTraceEnd, true);
			(Velocity *= 0.5000000);
			return;
		}
	}
	DesiredRotation = RotRand();
	Velocity = (0.3300000 * MirrorVectorByNormal(Velocity, HitNormal));
	RotationRate.Yaw = int((((float(1000) * VSize(Velocity)) * FRand()) - (float(500) * VSize(Velocity))));
	RotationRate.Pitch = int((((float(1000) * VSize(Velocity)) * FRand()) - (float(500) * VSize(Velocity))));
	RotationRate.Roll = int((((float(1000) * VSize(Velocity)) * FRand()) - (float(500) * VSize(Velocity))));
	// End:0x1C3
	if((Velocity.Z > float(400)))
	{
		Velocity.Z = 400.0000000;		
	}
	else
	{
		// End:0x1E0
		if((VSize(Velocity) < float(50)))
		{
			SetPhysics(0);
			bBounce = false;
		}
	}
	// End:0x29E
	if(m_bFirstImpact)
	{
		m_bFirstImpact = false;
		// End:0x29E
		if((int(Level.NetMode) != int(NM_DedicatedServer)))
		{
			m_ImpactSound = m_ImpactGroundSound;
			pHit = Trace(vHitLocation, vHitNormal, (Location - vect(0.0000000, 0.0000000, 40.0000000)), Location, false,, HitMaterial);
			// End:0x294
			if(((HitMaterial != none) && ((int(HitMaterial.m_eSurfIdForSnd) == int(12)) || (int(HitMaterial.m_eSurfIdForSnd) == int(13)))))
			{
				m_ImpactSound = m_ImpactWaterSound;
			}
			PlaySound(m_ImpactSound, 3);
		}
	}
	R6MakeNoise(4);
	return;
}

simulated function Landed(Vector HitNormal)
{
	HitWall(HitNormal, none);
	return;
}

singular simulated function Touch(Actor Other)
{
	return;
}

simulated function ProcessTouch(Actor Other, Vector vHitLocation)
{
	HitWall(vHitLocation, Other);
	return;
}

defaultproperties
{
	m_bFirstImpact=true
	m_ImpactGroundSound=Sound'Foley_CommonGrenade.Play_Grenades_GroundImpacts'
	m_iHitPoints=1
	m_bBlockCoronas=true
	Physics=2
	DrawType=8
	bNoDelete=false
	bSkipActorPropertyReplication=false
	bCollideWorld=true
	bProjTarget=true
	m_bPawnGoThrough=true
	bFixedRotationDir=true
}
