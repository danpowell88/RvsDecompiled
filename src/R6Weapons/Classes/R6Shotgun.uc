//=============================================================================
// R6Shotgun - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  R6Shotgun.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class R6Shotgun extends R6Weapons
 abstract;

function int NbBulletToShot()
{
	// End:0x29
	if(__NFUN_130__(__NFUN_119__(m_pBulletClass, none), __NFUN_122__(m_pBulletClass.default.m_szBulletType, "BUCK")))
	{
		return 9;
	}
	return 1;
	return;
}

defaultproperties
{
	m_eWeaponType=3
	m_eGripType=5
	m_ShellSingleFireSnd=Sound'CommonShotguns.Play_Shotgun_SingleShell'
	m_ShellEndFullAutoSnd=Sound'CommonShotguns.Play_Shotgun_EndShell'
	m_PawnWaitAnimLow="StandShotGunLow_nt"
	m_PawnWaitAnimHigh="StandShotGunHigh_nt"
	m_PawnWaitAnimProne="ProneShotGun_nt"
	m_PawnFiringAnim="StandFireShotGun"
	m_AttachPoint="TagRightHand"
	m_HoldAttachPoint="TagBack"
}
