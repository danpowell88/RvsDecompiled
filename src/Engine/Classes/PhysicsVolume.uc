//=============================================================================
// PhysicsVolume - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// PhysicsVolume:  a bounding volume which affects actor physics
// Each Actor is affected at any time by one PhysicsVolume
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class PhysicsVolume extends Volume
    native
    nativereplication
    notplaceable;

var() int Priority;  // determines which PhysicsVolume takes precedence if they overlap
var() bool bPainCausing;  // Zone causes pain.
var() bool bDestructive;  // Destroys most actors which enter it.
var() bool bNoInventory;
var() bool bMoveProjectiles;  // this velocity zone should impart velocity to projectiles and effects
var() bool bBounceVelocity;  // this velocity zone should bounce actors that land in it
var() bool bNeutralZone;  // Players can't take damage in this zone.
var bool bWaterVolume;
// Distance Fog
var(VolumeFog) bool bDistanceFog;  // There is distance fog in this physicsvolume.
var() float GroundFriction;
var() float TerminalVelocity;
var() float DamagePerSec;
var() float FluidFriction;
var(VolumeFog) float DistanceFogStart;
var(VolumeFog) float DistanceFogEnd;
var() Sound EntrySound;  // only if waterzone
var() Sound ExitSound;  // only if waterzone
var Info PainTimer;
var PhysicsVolume NextPhysicsVolume;
var() Class<Actor> EntryActor;  // e.g. a splash (only if water zone)
var() Class<Actor> ExitActor;  // e.g. a splash (only if water zone)
var() Vector ZoneVelocity;
var() Vector Gravity;
var() Vector ViewFlash;
// NEW IN 1.60
var() Vector ViewFog;
var(VolumeFog) Color DistanceFogColor;

simulated function Destroyed()
{
	super(Actor).Destroyed();
	Level.RemovePhysicsVolume(self);
	return;
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	Level.AddPhysicsVolume(self);
	// End:0x28
	if(__NFUN_150__(int(Role), int(ROLE_Authority)))
	{
		return;
	}
	// End:0x40
	if(bPainCausing)
	{
		PainTimer = __NFUN_278__(Class'Engine.VolumeTimer', self);
	}
	return;
}

event PhysicsChangedFor(Actor Other)
{
	return;
}

event ActorEnteredVolume(Actor Other)
{
	return;
}

event ActorLeavingVolume(Actor Other)
{
	return;
}

event PawnEnteredVolume(Pawn Other)
{
	// End:0x23
	if(Other.IsPlayerPawn())
	{
		TriggerEvent(Event, self, Other);
	}
	return;
}

event PawnLeavingVolume(Pawn Other)
{
	// End:0x23
	if(Other.IsPlayerPawn())
	{
		UntriggerEvent(Event, self, Other);
	}
	return;
}

function TimerPop(VolumeTimer t)
{
	local Actor A;

	// End:0x1C
	if(__NFUN_114__(t, PainTimer))
	{
		// End:0x1C
		if(__NFUN_129__(bPainCausing))
		{
			return;
		}
	}
	return;
}

function Trigger(Actor Other, Pawn EventInstigator)
{
	// End:0x41
	if(__NFUN_181__(DamagePerSec, float(0)))
	{
		bPainCausing = __NFUN_129__(bPainCausing);
		// End:0x41
		if(__NFUN_130__(bPainCausing, __NFUN_114__(PainTimer, none)))
		{
			PainTimer = __NFUN_278__(Class'Engine.VolumeTimer', self);
		}
	}
	return;
}

event Touch(Actor Other)
{
	super(Actor).Touch(Other);
	// End:0x56
	if(__NFUN_130__(__NFUN_130__(bNoInventory, Other.__NFUN_303__('Inventory')), __NFUN_114__(Other.Owner, none)))
	{
		Other.LifeSpan = 1.5000000;
		return;
	}
	// End:0xFB
	if(__NFUN_130__(bMoveProjectiles, __NFUN_218__(ZoneVelocity, vect(0.0000000, 0.0000000, 0.0000000))))
	{
		// End:0xA9
		if(__NFUN_154__(int(Other.Physics), int(6)))
		{
			__NFUN_223__(Other.Velocity, ZoneVelocity);			
		}
		else
		{
			// End:0xFB
			if(__NFUN_130__(Other.__NFUN_303__('Effects'), __NFUN_154__(int(Other.Physics), int(0))))
			{
				Other.__NFUN_3970__(6);
				__NFUN_223__(Other.Velocity, ZoneVelocity);
			}
		}
	}
	// End:0x124
	if(bPainCausing)
	{
		// End:0x124
		if(Other.bDestroyInPainVolume)
		{
			Other.__NFUN_279__();
			return;
		}
	}
	// End:0x14C
	if(__NFUN_130__(bWaterVolume, Other.CanSplash()))
	{
		PlayEntrySplash(Other);
	}
	return;
}

function PlayEntrySplash(Actor Other)
{
	local float SplashSize;
	local Actor splash;

	SplashSize = __NFUN_246__(__NFUN_171__(__NFUN_171__(0.0000300, Other.Mass), __NFUN_175__(float(250), __NFUN_171__(0.5000000, __NFUN_245__(-600.0000000, Other.Velocity.Z)))), 0.1000000, 1.0000000);
	// End:0x77
	if(__NFUN_119__(EntrySound, none))
	{
		// End:0x77
		if(__NFUN_119__(Other.Instigator, none))
		{
			__NFUN_512__(SplashSize);
		}
	}
	// End:0xAF
	if(__NFUN_119__(EntryActor, none))
	{
		splash = __NFUN_278__(EntryActor);
		// End:0xAF
		if(__NFUN_119__(splash, none))
		{
			splash.SetDrawScale(SplashSize);
		}
	}
	return;
}

event UnTouch(Actor Other)
{
	// End:0x28
	if(__NFUN_130__(bWaterVolume, Other.CanSplash()))
	{
		PlayExitSplash(Other);
	}
	return;
}

function PlayExitSplash(Actor Other)
{
	local float SplashSize;
	local Actor splash;

	SplashSize = __NFUN_246__(__NFUN_171__(0.0030000, Other.Mass), 0.1000000, 1.0000000);
	// End:0x5F
	if(__NFUN_119__(ExitActor, none))
	{
		splash = __NFUN_278__(ExitActor);
		// End:0x5F
		if(__NFUN_119__(splash, none))
		{
			splash.SetDrawScale(SplashSize);
		}
	}
	return;
}

defaultproperties
{
	GroundFriction=8.0000000
	TerminalVelocity=2500.0000000
	FluidFriction=0.3000000
	Gravity=(X=0.0000000,Y=0.0000000,Z=-1500.0000000)
	bAlwaysRelevant=true
	m_bSeeThrough=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var DamageType
// REMOVED IN 1.60: var g
// REMOVED IN 1.60: function CausePainTo
