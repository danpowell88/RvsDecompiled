//=============================================================================
// R6AbstractBulletManager - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6AbstractBulletManager.uc :   Abstract class for bullet manager.
//
//  Copyright 2001-2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    10/07/2002 * Created by Joel Tremblay
//=============================================================================
class R6AbstractBulletManager extends Actor
    notplaceable;

function SetBulletParameter(R6EngineWeapon AWeapon)
{
	return;
}

function InitBulletMgr(Pawn TheInstigator)
{
	return;
}

function bool AffectActor(int BulletGroup, Actor ActorAffected)
{
	return;
}

function SpawnBullet(Vector VPosition, Rotator rRotation, float fBulletSpeed, bool bFirstInShell)
{
	return;
}

