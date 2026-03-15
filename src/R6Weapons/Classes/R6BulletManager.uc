//=============================================================================
// R6BulletManager - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
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
class R6BulletManager extends R6
    AbstractBulletManager;

const m_iNbBullets = 20;

var int m_iCurrentBullet;
var int m_iBulletSpeed;
var int m_iBulletEnergy;
var int m_iNextBulletGroupID;
// NEW IN 1.60
var R6Bullet m_BulletArray[20];

function InitBulletMgr(Pawn TheInstigator)
{
	m_iCurrentBullet = 0;
	J0x07:

	// End:0x7B [Loop If]
	if((m_iCurrentBullet < 20))
	{
		m_BulletArray[m_iCurrentBullet] = Spawn(Class'R6Weapons.R6Bullet',,,,, true);
		m_BulletArray[m_iCurrentBullet].SetCollision(false, false, false);
		m_BulletArray[m_iCurrentBullet].Instigator = TheInstigator;
		m_BulletArray[m_iCurrentBullet].m_BulletManager = self;
		(m_iCurrentBullet++);
		// [Loop Continue]
		goto J0x07;
	}
	m_iCurrentBullet = 0;
	return;
}

// bullet parameters are changed when changing weapon.  All bullets in the array will get the new parameters.
function SetBulletParameter(R6EngineWeapon AWeapon)
{
	local R6Weapons aR6Weapon;

	aR6Weapon = R6Weapons(AWeapon);
	// End:0x33
	if(((aR6Weapon == none) || (aR6Weapon.m_pBulletClass == none)))
	{
		return;
	}
	m_iBulletEnergy = aR6Weapon.m_pBulletClass.default.m_iEnergy;
	m_iCurrentBullet = 0;
	J0x57:

	// End:0x175 [Loop If]
	if((m_iCurrentBullet < 20))
	{
		m_BulletArray[m_iCurrentBullet].m_szBulletType = aR6Weapon.m_pBulletClass.default.m_szBulletType;
		m_BulletArray[m_iCurrentBullet].m_iEnergy = aR6Weapon.m_pBulletClass.default.m_iEnergy;
		m_BulletArray[m_iCurrentBullet].m_fKillStunTransfer = aR6Weapon.m_pBulletClass.default.m_fKillStunTransfer;
		m_BulletArray[m_iCurrentBullet].m_fRangeConversionConst = aR6Weapon.m_pBulletClass.default.m_fRangeConversionConst;
		m_BulletArray[m_iCurrentBullet].m_fRange = aR6Weapon.m_pBulletClass.default.m_fRange;
		m_BulletArray[m_iCurrentBullet].m_iPenetrationFactor = aR6Weapon.m_pBulletClass.default.m_iPenetrationFactor;
		(m_iCurrentBullet++);
		// [Loop Continue]
		goto J0x57;
	}
	m_iCurrentBullet = 0;
	return;
}

function SpawnBullet(Vector VPosition, Rotator rRotation, float fBulletSpeed, bool bFirstInShell)
{
	// End:0x13
	if((bFirstInShell == true))
	{
		(m_iNextBulletGroupID++);
	}
	m_BulletArray[m_iCurrentBullet].SetLocation(VPosition, true);
	m_BulletArray[m_iCurrentBullet].SetRotation(rRotation);
	m_BulletArray[m_iCurrentBullet].m_vSpawnedPosition = VPosition;
	m_BulletArray[m_iCurrentBullet].m_bBulletIsGone = true;
	m_BulletArray[m_iCurrentBullet].SetSpeed(fBulletSpeed);
	m_BulletArray[m_iCurrentBullet].SetCollision(true, true, false);
	m_BulletArray[m_iCurrentBullet].SetPhysics(6);
	m_BulletArray[m_iCurrentBullet].bStasis = false;
	m_BulletArray[m_iCurrentBullet].m_bBulletDeactivated = false;
	m_BulletArray[m_iCurrentBullet].m_iBulletGroupID = m_iNextBulletGroupID;
	m_BulletArray[m_iCurrentBullet].m_AffectedActor = none;
	m_BulletArray[m_iCurrentBullet].m_iEnergy = m_iBulletEnergy;
	(m_iCurrentBullet++);
	// End:0x148
	if((m_iCurrentBullet == 20))
	{
		m_iCurrentBullet = 0;
	}
	return;
}

// returns true if actor has not been affected by the same bullet group
// also sets the bullet to the affected actor
function bool AffectActor(int BulletGroup, Actor ActorAffected)
{
	local int iBulletIndex, iSaveBulletIndex;

	iBulletIndex = 0;
	J0x07:

	// End:0x83 [Loop If]
	if((iBulletIndex < 20))
	{
		// End:0x79
		if((m_BulletArray[iBulletIndex].m_iBulletGroupID == BulletGroup))
		{
			// End:0x54
			if((m_BulletArray[iBulletIndex].m_AffectedActor == ActorAffected))
			{
				return false;
				// [Explicit Continue]
				goto J0x79;
			}
			// End:0x79
			if((m_BulletArray[iBulletIndex].m_AffectedActor == none))
			{
				iSaveBulletIndex = iBulletIndex;
			}
		}
		J0x79:

		(iBulletIndex++);
		// [Loop Continue]
		goto J0x07;
	}
	m_BulletArray[iSaveBulletIndex].m_AffectedActor = ActorAffected;
	return true;
	return;
}

simulated event Destroyed()
{
	local int i, iSaveBulletIndex;

	i = 0;
	J0x07:

	// End:0x56 [Loop If]
	if((i < 20))
	{
		// End:0x4C
		if((m_BulletArray[i] != none))
		{
			m_BulletArray[i].m_BulletManager = none;
			m_BulletArray[i].Destroy();
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

defaultproperties
{
	RemoteRole=0
	bHidden=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_BulletArraym_iNbBullets
