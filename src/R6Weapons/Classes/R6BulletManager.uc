//========================================================================================
//  R6BulletManager.uc :   Manage all bullets for one character.
//                         Bullets are spawned and managed here.
//                         There's one manager per character. 
//
//  Copyright 2001-2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    06/07/2002 * Created by Joel Tremblay
//=============================================================================
class R6BulletManager extends R6AbstractBulletManager;

// --- Constants ---
const m_iNbBullets =  20;

// --- Variables ---
var int m_iCurrentBullet;
var R6Bullet m_BulletArray[20];
var int m_iBulletEnergy;
var int m_iNextBulletGroupID;
var int m_iBulletSpeed;

// --- Functions ---
function InitBulletMgr(Pawn TheInstigator) {}
function SpawnBullet(Vector VPosition, Rotator rRotation, float fBulletSpeed, bool bFirstInShell) {}
simulated event Destroyed() {}
// returns true if actor has not been affected by the same bullet group
// also sets the bullet to the affected actor
function bool AffectActor(Actor ActorAffected, int BulletGroup) {}
// ^ NEW IN 1.60
// bullet parameters are changed when changing weapon.  All bullets in the array will get the new parameters.
function SetBulletParameter(R6EngineWeapon AWeapon) {}

defaultproperties
{
}
