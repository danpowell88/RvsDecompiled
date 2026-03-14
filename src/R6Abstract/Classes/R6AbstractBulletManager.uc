//========================================================================================
//  R6AbstractBulletManager.uc :   Abstract class for bullet manager.
//
//  Copyright 2001-2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    10/07/2002 * Created by Joel Tremblay
//=============================================================================
class R6AbstractBulletManager extends Actor;

// --- Functions ---
function SetBulletParameter(R6EngineWeapon AWeapon) {}
function InitBulletMgr(Pawn TheInstigator) {}
function bool AffectActor(int BulletGroup, Actor ActorAffected) {}
// ^ NEW IN 1.60
function SpawnBullet(Vector VPosition, Rotator rRotation, float fBulletSpeed, bool bFirstInShell) {}

defaultproperties
{
}
