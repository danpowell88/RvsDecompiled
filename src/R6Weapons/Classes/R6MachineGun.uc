//=============================================================================
// R6MachineGun - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  R6MachineGun.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class R6MachineGun extends R6Weapons
 abstract;

defaultproperties
{
	m_eRateOfFire=2
	m_eWeaponType=5
	m_eGripType=3
	m_bBipod=true
	m_ShellFullAutoSnd=Sound'CommonLMGs.Play_LMG_AutoShells'
	m_ShellEndFullAutoSnd=Sound'CommonLMGs.Stop_LMG_AutoShells_Go'
	m_BipodSnd=Sound'Gadget_Bipod.Play_Bipod_Extraction'
	m_PawnWaitAnimLow="StandLMGLow_nt"
	m_PawnWaitAnimHigh="StandLMGHigh_nt"
	m_PawnWaitAnimProne="ProneLMG_nt"
	m_PawnFiringAnim="StandFireLmg"
	m_PawnFiringAnimProne="ProneBipodFireLMG"
	m_PawnReloadAnim="StandReloadLMG"
	m_PawnReloadAnimTactical="StandReloadLMG"
	m_PawnReloadAnimProne="ProneReloadLMG"
	m_PawnReloadAnimProneTactical="ProneReloadLMG"
	m_AttachPoint="TagRightHand"
	m_HoldAttachPoint="TagBack"
}
