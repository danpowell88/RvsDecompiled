//=============================================================================
// R6AssaultRifle - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  R6AssaultRifle.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class R6AssaultRifle extends R6Weapons
 abstract;

defaultproperties
{
	m_eRateOfFire=2
	m_eWeaponType=2
	m_ShellSingleFireSnd=Sound'CommonAssaultRiffles.Play_Assault_SingleShell'
	m_ShellBurstFireSnd=Sound'CommonAssaultRiffles.Play_Assault_TripleShells'
	m_ShellEndFullAutoSnd=Sound'CommonAssaultRiffles.Play_Assault_EndShells'
	m_AttachPoint="TagRightHand"
	m_HoldAttachPoint="TagBack"
}
