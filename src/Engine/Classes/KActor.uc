//=============================================================================
// KActor - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// KarmaActor.
// Just a handy class to derive off to make physics objects.
//=============================================================================
class KActor extends Actor
    native
    placeable;

var(Karma) bool bKTakeShot;
var() bool bOrientImpactEffect;
// NEW IN 1.60
var(Karma) float fKImpulseFactor;
var() float ImpactVolume;
var() float ImpactInterval;
var() Class<Actor> ImpactEffect;
// Ragdoll impact sounds.
var() array<Sound> ImpactSounds;
var transient float LastImpactTime;

// NEW IN 1.60
function int R6TakeDamage(int iKillValue, int iStunValue, Pawn instigatedBy, Vector vHitLocation, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGoup)
{
	local Vector ApplyImpulse;

	// End:0x56
	if((bKTakeShot && (iKillValue > 0)))
	{
		// End:0x29
		if((VSize(vMomentum) < 0.0010000))
		{
			return 0;
		}
		ApplyImpulse = ((Normal(vMomentum) * float(iKillValue)) / fKImpulseFactor);
		KAddImpulse(ApplyImpulse, vHitLocation);
	}
	return 0;
	return;
}

// Default behaviour when triggered is to wake up the physics.
function Trigger(Actor Other, Pawn EventInstigator)
{
	KWake();
	return;
}

// 
event KImpact(Actor Other, Vector pos, Vector impactVel, Vector impactNorm)
{
	local int numSounds, soundNum;

	// End:0x57
	if((Level.TimeSeconds > (LastImpactTime + ImpactInterval)))
	{
		numSounds = ImpactSounds.Length;
		// End:0x43
		if((numSounds > 0))
		{
			soundNum = Rand(numSounds);
		}
		LastImpactTime = Level.TimeSeconds;
	}
	return;
}

defaultproperties
{
	bKTakeShot=true
	fKImpulseFactor=1.0000000
	Physics=13
	RemoteRole=0
	DrawType=8
	bNoDelete=true
	bAcceptsProjectors=true
	bCollideActors=true
	bBlockActors=true
	bBlockPlayers=true
	bProjTarget=true
	bBlockKarma=true
	bEdShouldSnap=true
	CollisionRadius=1.0000000
	CollisionHeight=1.0000000
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function TakeDamage
