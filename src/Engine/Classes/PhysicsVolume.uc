//=============================================================================
// PhysicsVolume:  a bounding volume which affects actor physics
// Each Actor is affected at any time by one PhysicsVolume
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class PhysicsVolume extends Volume
    native
    nativereplication;

// --- Variables ---
var bool bWaterVolume;
var bool bPainCausing;
// ^ NEW IN 1.60
var PhysicsVolume NextPhysicsVolume;
var Info PainTimer;
var Vector Gravity;
// ^ NEW IN 1.60
var Vector ZoneVelocity;
// ^ NEW IN 1.60
var class<Actor> ExitActor;
// ^ NEW IN 1.60
var class<Actor> EntryActor;
// ^ NEW IN 1.60
var float DamagePerSec;
// ^ NEW IN 1.60
var Sound EntrySound;
// ^ NEW IN 1.60
var Vector ViewFlash;
// ^ NEW IN 1.60
var Vector ViewFog;
// ^ NEW IN 1.60
var bool bNoInventory;
// ^ NEW IN 1.60
var bool bMoveProjectiles;
// ^ NEW IN 1.60
var float GroundFriction;
// ^ NEW IN 1.60
var float TerminalVelocity;
// ^ NEW IN 1.60
var int Priority;
// ^ NEW IN 1.60
var Sound ExitSound;
// ^ NEW IN 1.60
var float FluidFriction;
// ^ NEW IN 1.60
var bool bDestructive;
// ^ NEW IN 1.60
var bool bBounceVelocity;
// ^ NEW IN 1.60
var bool bNeutralZone;
// ^ NEW IN 1.60
var bool bDistanceFog;
// ^ NEW IN 1.60
var Color DistanceFogColor;
// ^ NEW IN 1.60
var float DistanceFogStart;
// ^ NEW IN 1.60
var float DistanceFogEnd;
// ^ NEW IN 1.60

// --- Functions ---
// function ? CausePainTo(...); // REMOVED IN 1.60
// function ? touch(...); // REMOVED IN 1.60
// function ? untouch(...); // REMOVED IN 1.60
event PawnLeavingVolume(Pawn Other) {}
event PawnEnteredVolume(Pawn Other) {}
simulated function PostBeginPlay() {}
event PhysicsChangedFor(Actor Other) {}
simulated function Destroyed() {}
function TimerPop(VolumeTimer t) {}
event UnTouch(Actor Other) {}
// ^ NEW IN 1.60
function PlayEntrySplash(Actor Other) {}
function PlayExitSplash(Actor Other) {}
event Touch(Actor Other) {}
// ^ NEW IN 1.60
event ActorEnteredVolume(Actor Other) {}
event ActorLeavingVolume(Actor Other) {}
function Trigger(Actor Other, Pawn EventInstigator) {}

defaultproperties
{
}
