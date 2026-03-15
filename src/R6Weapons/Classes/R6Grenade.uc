//=============================================================================
// R6Grenade - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6Grenade.uc : Base class for all grenades types
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/17/09 * Created by Sebastien Lussier
//=============================================================================
class R6Grenade extends R6Bullet
    abstract
    native;

enum eGrenadePawnPose
{
	GPP_Stand,                      // 0
	GPP_Crouch,                     // 1
	GPP_ProneFacing                 // 2
};

enum eGrenadeBoneTarget
{
	GBT_Head,                       // 0
	GBT_Body,                       // 1
	GBT_LeftArm,                    // 2
	GBT_RightArm,                   // 3
	GBT_LeftLeg,                    // 4
	GBT_RightLeg                    // 5
};

struct sDamagePercentage
{
	var() float fHead;
	var() float fBody;
	var() float fArms;
	var() float fLegs;
};

var Actor.EPhysics m_eOldPhysic;  // When physic changes in MP.
var Actor.ESoundType m_eExplosionSoundType;
var Pawn.EGrenadeType m_eGrenadeType;
var() int m_iNumberOfFragments;
var bool m_bFirstImpact;
var bool m_bDestroyedByImpact;
var float m_fDuration;  // Time before all is stoped
var float m_fShakeRadius;
//
// Grenade Properties
//
var float m_fEffectiveOutsideKillRadius;
var(R6GrenadeSound) Sound m_sndExplosionSound;
var(R6GrenadeSound) Sound m_sndExplosionSoundStop;
var(R6GrenadeSound) Sound m_sndExplodeMetal;
var(R6GrenadeSound) Sound m_sndExplodeWater;
var(R6GrenadeSound) Sound m_sndExplodeAir;
var(R6GrenadeSound) Sound m_sndExplodeDirt;
var(R6GrenadeSound) Sound m_ImpactSound;  // Sound made when projectile hits something.
var(R6GrenadeSound) Sound m_ImpactGroundSound;
var(R6GrenadeSound) Sound m_ImpactWaterSound;
var(R6GrenadeSound) Sound m_sndEarthQuake;
var R6DemolitionsGadget m_Weapon;  // weapon who place or throw the grenade.  only use on demo gadgets.
var() Emitter m_pEmmiter;
var() Class<Emitter> m_pExplosionParticles;
var() Class<Emitter> m_pExplosionParticlesLOW;
var() Class<Light> m_pExplosionLight;
//decals
var Class<R6GrenadeDecal> m_GrenadeDecalClass;
var() sDamagePercentage m_DmgPercentStand;
var() sDamagePercentage m_DmgPercentCrouch;
var() sDamagePercentage m_DmgPercentProne;

simulated function Class<Emitter> GetGrenadeEmitter()
{
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	// End:0x3D
	if(((pGameOptions.LowDetailSmoke == true) && (m_pExplosionParticlesLOW != none)))
	{
		return m_pExplosionParticlesLOW;		
	}
	else
	{
		return m_pExplosionParticles;
	}
	return;
}

function SelfDestroy()
{
	// End:0x1C
	if((int(Level.NetMode) != int(NM_Client)))
	{
		Destroy();
	}
	return;
}

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsGripGrenadeA');
	super.PostBeginPlay();
	Activate();
	m_fEffectiveOutsideKillRadius = (m_fExplosionRadius - m_fKillBlastRadius);
	return;
}

function Activate()
{
	// End:0x16
	if((m_fExplosionDelay != float(0)))
	{
		SetTimer(m_fExplosionDelay, false);
	}
	return;
}

event Timer()
{
	Explode();
	SelfDestroy();
	return;
}

simulated event Destroyed()
{
	local Light pEffectLight;
	local Class<Emitter> pExplosionParticles;

	super(Actor).Destroyed();
	pExplosionParticles = GetGrenadeEmitter();
	// End:0x99
	if((m_bDestroyedByImpact == false))
	{
		// End:0x82
		if((default.m_fDuration == float(0)))
		{
			// End:0x66
			if((pExplosionParticles != none))
			{
				m_pEmmiter = Spawn(pExplosionParticles);
				m_pEmmiter.RemoteRole = ROLE_None;
				m_pEmmiter.Role = ROLE_Authority;
			}
			// End:0x7F
			if((m_pExplosionLight != none))
			{
				pEffectLight = Spawn(m_pExplosionLight);
			}			
		}
		else
		{
			// End:0x99
			if((m_pEmmiter != none))
			{
				m_pEmmiter.Destroy();
			}
		}
	}
	return;
}

simulated function FirstPassReset()
{
	SelfDestroy();
	return;
}

simulated function Explode()
{
	local Actor HitActor;
	local Vector vHitLocation, vHitNormal;
	local Material HitMaterial;
	local R6GrenadeDecal GrenadeDecal;
	local R6ActorSound pGrenadeSound;
	local Rotator GrenadeDecalRotation;

	// End:0x159
	if((m_sndExplosionSound == none))
	{
		HitActor = Trace(vHitLocation, vHitNormal, (Location - vect(0.0000000, 0.0000000, 40.0000000)), Location, false,, HitMaterial);
		// End:0x61
		if(((HitMaterial == none) && (m_sndExplodeAir != none)))
		{
			m_sndExplosionSound = m_sndExplodeAir;
		}
		// End:0xBA
		if((((m_sndExplosionSound == none) && (m_sndExplodeMetal != none)) && ((int(HitMaterial.m_eSurfIdForSnd) == int(10)) || (int(HitMaterial.m_eSurfIdForSnd) == int(11)))))
		{
			m_sndExplosionSound = m_sndExplodeMetal;
		}
		// End:0x113
		if((((m_sndExplosionSound == none) && (m_sndExplodeWater != none)) && ((int(HitMaterial.m_eSurfIdForSnd) == int(12)) || (int(HitMaterial.m_eSurfIdForSnd) == int(13)))))
		{
			m_sndExplosionSound = m_sndExplodeWater;
		}
		// End:0x159
		if((m_sndExplosionSound == none))
		{
			// End:0x137
			if((m_sndExplodeDirt != none))
			{
				m_sndExplosionSound = m_sndExplodeDirt;				
			}
			else
			{
				Log("Missing SOUND for the grenade!");
			}
		}
	}
	HurtPawns();
	R6MakeNoise(m_eExplosionSoundType);
	// End:0x1B3
	if((m_GrenadeDecalClass != none))
	{
		GrenadeDecalRotation.Pitch = 0;
		GrenadeDecalRotation.Yaw = 0;
		GrenadeDecalRotation.Roll = 0;
		GrenadeDecal = Spawn(m_GrenadeDecalClass,,, Location, GrenadeDecalRotation);
	}
	pGrenadeSound = Spawn(Class'Engine.R6ActorSound',,, Location);
	// End:0x26C
	if((pGrenadeSound != none))
	{
		// End:0x1F2
		if(IsA('R6FlashBang'))
		{
			pGrenadeSound.m_eTypeSound = 4;			
		}
		else
		{
			pGrenadeSound.m_eTypeSound = 2;
		}
		pGrenadeSound.m_ImpactSound = m_sndExplosionSound;
		pGrenadeSound.m_ImpactSoundStop = m_sndExplosionSoundStop;
		// End:0x258
		if((int(m_eGrenadeType) == int(1)))
		{
			pGrenadeSound.m_fExplosionDelay = (m_fDuration - float(35));			
		}
		else
		{
			pGrenadeSound.m_fExplosionDelay = m_fDuration;
		}
	}
	return;
}

simulated function HitWall(Vector HitNormal, Actor Wall)
{
	local Vector vHitLocation, vHitNormal, vTraceEnd, vTraceStart;
	local Actor pHit;
	local Material HitMaterial;

	// End:0x16
	if((m_fExplosionDelay == float(0)))
	{
		Explode();		
	}
	else
	{
		// End:0x6D
		if((((Wall != none) && (Instigator != none)) && (Instigator.m_collisionBox == Wall)))
		{
			vTraceEnd = (Location + (float(10) * Normal(Velocity)));
			__NFUN_267__(vTraceEnd, true) /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/;
			return;
		}
		// End:0xE5
		if(__NFUN_114__(Wall, Level))
		{
			vTraceStart = __NFUN_215__(Location, __NFUN_213__(float(10), HitNormal));
			vTraceEnd = __NFUN_216__(Location, __NFUN_213__(float(10), HitNormal));
			pHit = __NFUN_1806__(vHitLocation, vHitNormal, vTraceEnd, vTraceStart, __NFUN_158__(2, 16));
			// End:0xE5
			if(__NFUN_114__(pHit, none))
			{
				__NFUN_267__(vTraceEnd, true);
				return;
			}
		}
		// End:0x172
		if(__NFUN_130__(__NFUN_130__(__NFUN_119__(Wall, none), Wall.m_bBulletGoThrough), Wall.__NFUN_303__('R6InteractiveObject')))
		{
			Wall.R6TakeDamage(10000, 10000, Instigator, vHitLocation, Velocity, 0);
			vTraceEnd = __NFUN_216__(Location, __NFUN_213__(float(10), HitNormal));
			__NFUN_267__(vTraceEnd, true);
			__NFUN_221__(Velocity, 0.5000000);
			return;
		}
		DesiredRotation = __NFUN_320__();
		Velocity = __NFUN_213__(0.2000000, __NFUN_300__(Velocity, HitNormal));
		RotationRate.Yaw = int(__NFUN_175__(__NFUN_171__(__NFUN_171__(float(1000), __NFUN_225__(Velocity)), __NFUN_195__()), __NFUN_171__(float(500), __NFUN_225__(Velocity))));
		RotationRate.Pitch = int(__NFUN_175__(__NFUN_171__(__NFUN_171__(float(1000), __NFUN_225__(Velocity)), __NFUN_195__()), __NFUN_171__(float(500), __NFUN_225__(Velocity))));
		RotationRate.Roll = int(__NFUN_175__(__NFUN_171__(__NFUN_171__(float(1000), __NFUN_225__(Velocity)), __NFUN_195__()), __NFUN_171__(float(500), __NFUN_225__(Velocity))));
		// End:0x257
		if(__NFUN_177__(Velocity.Z, float(400)))
		{
			Velocity.Z = 400.0000000;			
		}
		else
		{
			// End:0x287
			if(__NFUN_176__(__NFUN_225__(Velocity), float(10)))
			{
				__NFUN_3970__(0);
				bBounce = false;
				RotationRate = rot(0, 0, 0);
			}
		}
		// End:0x32C
		if(m_bFirstImpact)
		{
			m_bFirstImpact = false;
			m_ImpactSound = m_ImpactGroundSound;
			pHit = __NFUN_277__(vHitLocation, vHitNormal, __NFUN_216__(Location, vect(0.0000000, 0.0000000, 40.0000000)), Location, false,, HitMaterial);
			// End:0x322
			if(__NFUN_130__(__NFUN_119__(HitMaterial, none), __NFUN_132__(__NFUN_154__(int(HitMaterial.m_eSurfIdForSnd), int(12)), __NFUN_154__(int(HitMaterial.m_eSurfIdForSnd), int(13)))))
			{
				m_ImpactSound = m_ImpactWaterSound;
			}
			__NFUN_264__(m_ImpactSound, 3);
		}
		R6MakeNoise(3);
	}
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

function float GetLocalizedDamagePercentage(R6Grenade.eGrenadePawnPose ePawnPose, R6Grenade.eGrenadeBoneTarget eBoneTarget)
{
	switch(ePawnPose)
	{
		// End:0x60
		case 0:
			switch(eBoneTarget)
			{
				// End:0x23
				case 0:
					return m_DmgPercentStand.fHead;
				// End:0x33
				case 1:
					return m_DmgPercentStand.fBody;
				// End:0x38
				case 2:
				// End:0x48
				case 3:
					return m_DmgPercentStand.fArms;
				// End:0x4D
				case 4:
				// End:0x5D
				case 5:
					return m_DmgPercentStand.fLegs;
				// End:0xFFFF
				default:
					break;
				}
		// End:0xB9
		case 1:
			switch(eBoneTarget)
			{
				// End:0x7C
				case 0:
					return m_DmgPercentCrouch.fHead;
				// End:0x8C
				case 1:
					return m_DmgPercentCrouch.fBody;
				// End:0x91
				case 2:
				// End:0xA1
				case 3:
					return m_DmgPercentCrouch.fArms;
				// End:0xA6
				case 4:
				// End:0xB6
				case 5:
					return m_DmgPercentCrouch.fLegs;
				// End:0xFFFF
				default:
					break;
				}
		// End:0x112
		case 2:
			switch(eBoneTarget)
			{
				// End:0xD5
				case 0:
					return m_DmgPercentProne.fHead;
				// End:0xE5
				case 1:
					return m_DmgPercentProne.fBody;
				// End:0xEA
				case 2:
				// End:0xFA
				case 3:
					return m_DmgPercentProne.fArms;
				// End:0xFF
				case 4:
				// End:0x10F
				case 5:
					return m_DmgPercentProne.fLegs;
				// End:0xFFFF
				default:
					break;
				}
		// End:0xFFFF
		default:
			return 0.0000000;
			break;
	}
	return;
}

function R6Grenade.eGrenadeBoneTarget HitRandomBodyPart(R6Grenade.eGrenadePawnPose ePawnPose)
{
	local float fRandVal, fLeftArmVal, fRightArmVal, fLeftLegVal, fRighLegVal, fBodyVal,
		fHeadVal;

	fRandVal = __NFUN_195__();
	fLeftArmVal = GetLocalizedDamagePercentage(ePawnPose, 2);
	fRightArmVal = __NFUN_174__(GetLocalizedDamagePercentage(ePawnPose, 3), fLeftArmVal);
	fLeftLegVal = __NFUN_174__(GetLocalizedDamagePercentage(ePawnPose, 4), fRightArmVal);
	fRighLegVal = __NFUN_174__(GetLocalizedDamagePercentage(ePawnPose, 5), fLeftLegVal);
	fBodyVal = __NFUN_174__(GetLocalizedDamagePercentage(ePawnPose, 1), fRighLegVal);
	fHeadVal = __NFUN_174__(GetLocalizedDamagePercentage(ePawnPose, 0), fBodyVal);
	// End:0xB2
	if(__NFUN_176__(fRandVal, fLeftArmVal))
	{
		return 2;		
	}
	else
	{
		// End:0xC7
		if(__NFUN_176__(fRandVal, fRightArmVal))
		{
			return 3;			
		}
		else
		{
			// End:0xDC
			if(__NFUN_176__(fRandVal, fLeftLegVal))
			{
				return 4;				
			}
			else
			{
				// End:0xF1
				if(__NFUN_176__(fRandVal, fRighLegVal))
				{
					return 5;					
				}
				else
				{
					// End:0x103
					if(__NFUN_176__(fRandVal, fBodyVal))
					{
						return 1;
					}
				}
			}
		}
	}
	return 0;
	return;
}

function R6Grenade.eGrenadePawnPose GetPawnPose(R6Pawn aPawn)
{
	local float fDistFeet, fDistHead;
	local Vector vFeet, vHead;

	// End:0xA7
	if(aPawn.m_bIsProne)
	{
		vFeet = aPawn.GetBoneCoords('R6 L Foot').Origin;
		vHead = aPawn.GetBoneCoords('R6 Head').Origin;
		fDistHead = __NFUN_225__(__NFUN_216__(vHead, Location));
		fDistFeet = __NFUN_225__(__NFUN_216__(vFeet, Location));
		// End:0xA4
		if(__NFUN_177__(__NFUN_175__(fDistFeet, fDistHead), __NFUN_171__(__NFUN_225__(__NFUN_216__(vFeet, vHead)), 0.7500000)))
		{
			return 2;			
		}
		else
		{
			return 0;
		}
	}
	// End:0xBC
	if(aPawn.bIsCrouched)
	{
		return 1;
	}
	return 0;
	return;
}

function HurtPawns()
{
	return;
}

defaultproperties
{
	m_eOldPhysic=2
	m_eExplosionSoundType=5
	m_iNumberOfFragments=4
	m_bFirstImpact=true
	m_fShakeRadius=1000.0000000
	m_ImpactGroundSound=Sound'Foley_CommonGrenade.Play_Grenades_GroundImpacts'
	m_sndEarthQuake=Sound'CommonWeapons.Play_GrenadeQuake'
	m_bIsGrenade=true
	m_fExplosionDelay=3.0000000
	Physics=2
	RemoteRole=2
	DrawType=8
	bHidden=false
	bStasis=false
	bNetTemporary=false
	bAlwaysRelevant=true
	m_bBypassAmbiant=true
	m_bRenderOutOfWorld=true
	m_bDoPerBoneTrace=false
	bIgnoreOutOfWorld=true
	bFixedRotationDir=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function HitRandomBodyPart
// REMOVED IN 1.60: function GetPawnPose
