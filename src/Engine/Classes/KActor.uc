//=============================================================================
// KarmaActor.
// Just a handy class to derive off to make physics objects.
//=============================================================================
class KActor extends Actor
    native;

// --- Variables ---
var transient float LastImpactTime;
var float ImpactInterval;
// ^ NEW IN 1.60
var array<array> ImpactSounds;
// ^ NEW IN 1.60
var float fKImpulseFactor;
// ^ NEW IN 1.60
var bool bKTakeShot;
var float ImpactVolume;
// ^ NEW IN 1.60
var class<Actor> ImpactEffect;
// ^ NEW IN 1.60
var bool bOrientImpactEffect;
// ^ NEW IN 1.60

// --- Functions ---
// function ? TakeDamage(...); // REMOVED IN 1.60
// Default behaviour when triggered is to wake up the physics.
function Trigger(Actor Other, Pawn EventInstigator) {}
function int R6TakeDamage(Vector vMomentum, int iKillValue, Vector vHitLocation, int iStunValue, Pawn instigatedBy, int iBulletToArmorModifier, optional int iBulletGoup) {}
// ^ NEW IN 1.60
//
event KImpact(Actor Other, Vector pos, Vector impactVel, Vector impactNorm) {}

defaultproperties
{
}
