//=============================================================================
// R6SubMachineGun - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  R6SubMachineGun.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class R6SubMachineGun extends R6Weapons
    abstract;

defaultproperties
{
	m_eRateOfFire=2
	m_eWeaponType=1
	m_ShellSingleFireSnd=Sound'CommonSMG.Play_SMG_SingleShells'
	m_ShellBurstFireSnd=Sound'CommonSMG.Play_SMG_TripleShells'
	m_ShellEndFullAutoSnd=Sound'CommonSMG.Play_SMG_EndShells'
	m_AttachPoint="TagRightHand"
	m_HoldAttachPoint="TagBack"
}
