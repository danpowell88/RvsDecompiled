//=============================================================================
//  R6ExplodingBarel : 
//  Copyright 2003 Ubi Soft, Inc. All Rights Reserved.
//=============================================================================
class R6ExplodingBarel extends R6InteractiveObject;

// --- Variables ---
var int m_iEnergy;
// ^ NEW IN 1.60
var Emitter m_pEmmiter;
var float m_fExplosionRadius;
// ^ NEW IN 1.60
var float m_fKillBlastRadius;
// ^ NEW IN 1.60
var class<Light> m_pExplosionLight;

// --- Functions ---
function int R6TakeDamage(Pawn instigatedBy, optional int iBulletGroup, int iBulletToArmorModifier, Vector vMomentum, Vector vHitLocation, int iStunValue, int iKillValue) {}
// ^ NEW IN 1.60
function Explode() {}

defaultproperties
{
}
