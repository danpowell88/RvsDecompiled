//============================================================================//
// Class            r6bullet
// Created By       Joel Tremblay
// Date             2001/05/08
// Description      Bullet for the Rainbow combat model
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6Bullet extends R6AbstractBullet
    native;

#exec NEW StaticMesh FILE="models\Tracer.ASE" NAME="Tracer" Yaw=16384

// --- Enums ---
enum eHitResult
{
    HR_NoMaterial,
    HR_Explode,
    HR_Ricochet,
    HR_GoThrough,
};

// --- Variables ---
var int m_iEnergy;
var float m_fKillBlastRadius;
// ^ NEW IN 1.60
var float m_fExplosionRadius;
// ^ NEW IN 1.60
var float m_fExplosionDelay;
// ^ NEW IN 1.60
//used by BulletGoesThroughSurface
var Vector m_vSpawnedPosition;
var bool bShowLog;
//for Range Conversion  x�/m_fRangeConversionConst + x  (for Kill)  x�/m_fRangeConversionConst (stun)
var float m_fRangeConversionConst;
var float m_fKillStunTransfer;
var string m_szBulletType;
// Especially for shotguns, this is used to determine which other bullets where spawned
var int m_iBulletGroupID;
                                  // at the same time from the same weapon (I don't mean from rapid fire but fragments from
                                  // shells)
// which pawn did this bullet/fragment affect.
var Actor m_AffectedActor;
var R6BulletManager m_BulletManager;
var bool m_bBulletDeactivated;
var bool m_bBulletIsGone;
var float m_fRange;
var int m_iPenetrationFactor;
var int m_iNoArmorModifier;
var string m_szAmmoName;
var string m_szAmmoType;
var bool m_bIsGrenade;

// --- Functions ---
simulated function PostBeginPlay() {}
function bool DestroyedByImpact() {}
// ^ NEW IN 1.60
//==============
// Touching
singular simulated function Touch(Actor Other) {}
//============================================================================
// function ProcessTouch -
//============================================================================
simulated function ProcessTouch(Actor Other, Vector vHitLocation) {}
//============================================================================
// event HitWall  -
//============================================================================
simulated event HitWall(Actor Wall, Vector vHitNormal) {}
function float RangeConversion(float fRange) {}
// ^ NEW IN 1.60
function float StunLoss(float fRange) {}
// ^ NEW IN 1.60
//============================================================================
// function SpawnSFX -
//============================================================================
simulated function SpawnSFX(class<R6WallHit> fxClass, EHitType eType, Actor pSource, Rotator vRotation, Vector vLocation) {}
simulated function SetSpeed(float fBulletSpeed) {}
final native function eHitResult BulletGoesThroughSurface(Actor TouchedSurface, Vector vHitLocation, out Vector vBulletVelocity, out Vector vRealHitLocation, out Vector vexitLocation, out Vector vexitNormal, out class<R6WallHit> TouchedEffects, out class<R6WallHit> ExitEffects) {}
// ^ NEW IN 1.60
// Bullet are not destroyed, but Deactivated and the reactivated by the bullet manager.
function DeactivateBullet() {}

defaultproperties
{
}
