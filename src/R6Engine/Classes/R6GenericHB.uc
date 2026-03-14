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
	Velocity = __NFUN_213__(fSpeed, Vector(Rotation));
	Acceleration = __NFUN_212__(Vector(Rotation), float(50));
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
	if(__NFUN_119__(Wall, none))
	{
		// End:0x55
		if(__NFUN_130__(__NFUN_119__(Instigator, none), __NFUN_114__(Instigator.m_collisionBox, Wall)))
		{
			vTraceEnd = __NFUN_215__(Location, __NFUN_213__(float(10), __NFUN_226__(Velocity)));
			__NFUN_267__(vTraceEnd, true);
			return;
		}
		// End:0xDE
		if(__NFUN_130__(Wall.m_bBulletGoThrough, Wall.__NFUN_303__('R6InteractiveObject')))
		{
			Wall.R6TakeDamage(10000, 10000, Instigator, Wall.Location, Velocity, 0);
			vTraceEnd = __NFUN_216__(Location, __NFUN_213__(float(10), HitNormal));
			__NFUN_267__(vTraceEnd, true);
			__NFUN_221__(Velocity, 0.5000000);
			return;
		}
	}
	DesiredRotation = __NFUN_320__();
	Velocity = __NFUN_213__(0.3300000, __NFUN_300__(Velocity, HitNormal));
	RotationRate.Yaw = int(__NFUN_175__(__NFUN_171__(__NFUN_171__(float(1000), __NFUN_225__(Velocity)), __NFUN_195__()), __NFUN_171__(float(500), __NFUN_225__(Velocity))));
	RotationRate.Pitch = int(__NFUN_175__(__NFUN_171__(__NFUN_171__(float(1000), __NFUN_225__(Velocity)), __NFUN_195__()), __NFUN_171__(float(500), __NFUN_225__(Velocity))));
	RotationRate.Roll = int(__NFUN_175__(__NFUN_171__(__NFUN_171__(float(1000), __NFUN_225__(Velocity)), __NFUN_195__()), __NFUN_171__(float(500), __NFUN_225__(Velocity))));
	// End:0x1C3
	if(__NFUN_177__(Velocity.Z, float(400)))
	{
		Velocity.Z = 400.0000000;		
	}
	else
	{
		// End:0x1E0
		if(__NFUN_176__(__NFUN_225__(Velocity), float(50)))
		{
			__NFUN_3970__(0);
			bBounce = false;
		}
	}
	// End:0x29E
	if(m_bFirstImpact)
	{
		m_bFirstImpact = false;
		// End:0x29E
		if(__NFUN_155__(int(Level.NetMode), int(NM_DedicatedServer)))
		{
			m_ImpactSound = m_ImpactGroundSound;
			pHit = __NFUN_277__(vHitLocation, vHitNormal, __NFUN_216__(Location, vect(0.0000000, 0.0000000, 40.0000000)), Location, false,, HitMaterial);
			// End:0x294
			if(__NFUN_130__(__NFUN_119__(HitMaterial, none), __NFUN_132__(__NFUN_154__(int(HitMaterial.m_eSurfIdForSnd), int(12)), __NFUN_154__(int(HitMaterial.m_eSurfIdForSnd), int(13)))))
			{
				m_ImpactSound = m_ImpactWaterSound;
			}
			__NFUN_264__(m_ImpactSound, 3);
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
