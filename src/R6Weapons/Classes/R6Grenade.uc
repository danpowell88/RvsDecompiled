//=============================================================================
//  R6Grenade.uc : Base class for all grenades types
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/17/09 * Created by Sebastien Lussier
//=============================================================================
class R6Grenade extends R6Bullet
    native
    abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

// --- Enums ---
enum eGrenadeBoneTarget
{
    GBT_Head,
    GBT_Body,
    GBT_LeftArm,
    GBT_RightArm,
    GBT_LeftLeg,
    GBT_RightLeg        
};
enum eGrenadePawnPose
{
    GPP_Stand,          // Stand & Prone Siding
    GPP_Crouch,         // Crouch
    GPP_ProneFacing     // Prone, facing the grenade
};

// --- Structs ---
struct sDamagePercentage
{
    var() FLOAT fHead;
    var() FLOAT fBody;
    var() FLOAT fArms;
    var() FLOAT fLegs;
};

// --- Variables ---
var Sound m_sndExplosionSound;
var float m_fShakeRadius;
var Emitter m_pEmmiter;
// ^ NEW IN 1.60
var EGrenadeType m_eGrenadeType;
var class<Light> m_pExplosionLight;
// ^ NEW IN 1.60
var Sound m_sndEarthQuake;
// Time before all is stoped
var float m_fDuration;
var sDamagePercentage m_DmgPercentStand;
// ^ NEW IN 1.60
var sDamagePercentage m_DmgPercentCrouch;
// ^ NEW IN 1.60
var sDamagePercentage m_DmgPercentProne;
// ^ NEW IN 1.60
var class<Emitter> m_pExplosionParticlesLOW;
// ^ NEW IN 1.60
//
// Grenade Properties
//
var float m_fEffectiveOutsideKillRadius;
var bool m_bDestroyedByImpact;
// weapon who place or throw the grenade.  only use on demo gadgets.
var R6DemolitionsGadget m_Weapon;
// Sound made when projectile hits something.
var Sound m_ImpactSound;
var Sound m_sndExplodeMetal;
var Sound m_sndExplodeWater;
var Sound m_sndExplodeAir;
var Sound m_sndExplodeDirt;
var bool m_bFirstImpact;
var int m_iNumberOfFragments;
// ^ NEW IN 1.60
var class<Emitter> m_pExplosionParticles;
// ^ NEW IN 1.60
//decals
var class<R6GrenadeDecal> m_GrenadeDecalClass;
var ESoundType m_eExplosionSoundType;
var Sound m_ImpactWaterSound;
var Sound m_ImpactGroundSound;
var Sound m_sndExplosionSoundStop;
//When physic changes in MP.
var EPhysics m_eOldPhysic;

// --- Functions ---
function HurtPawns() {}
simulated function Explode() {}
event Timer() {}
simulated event Destroyed() {}
function Activate() {}
simulated function ProcessTouch(Vector vHitLocation, Actor Other) {}
singular simulated function Touch(Actor Other) {}
simulated function Landed(Vector HitNormal) {}
simulated function HitWall(Actor Wall, Vector HitNormal) {}
simulated function class<Emitter> GetGrenadeEmitter() {}
// ^ NEW IN 1.60
function float GetLocalizedDamagePercentage(eGrenadeBoneTarget eBoneTarget, eGrenadePawnPose ePawnPose) {}
// ^ NEW IN 1.60
function eGrenadePawnPose GetPawnPose(R6Pawn aPawn) {}
// ^ NEW IN 1.60
function eGrenadeBoneTarget HitRandomBodyPart(eGrenadePawnPose ePawnPose) {}
// ^ NEW IN 1.60
function SelfDestroy() {}
function PostBeginPlay() {}
simulated function FirstPassReset() {}

defaultproperties
{
}
