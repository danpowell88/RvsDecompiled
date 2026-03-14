//=============================================================================
// R6Gadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6Gadget.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/05 * Created by Rima Brek
//=============================================================================
class R6Gadget extends R6Weapons
	abstract
 native;

simulated function TurnOffEmitters(bool bTurnOff)
{
	return;
}

simulated function DisableWeaponOrGadget()
{
	// End:0x38
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_112__(string(self), " DisableWeaponOrGadget() was called..."));
	}
	return;
}

function SetHoldAttachPoint()
{
	// End:0x17
	if(__NFUN_154__(m_InventoryGroup, 4))
	{
		m_HoldAttachPoint = m_HoldAttachPoint2;
	}
	return;
}

function GiveMoreAmmo()
{
	__NFUN_135__(m_iNbBulletsInWeapon, byte(m_iClipCapacity));
	return;
}

defaultproperties
{
	m_stAccuracyValues=(fBaseAccuracy=0.1000000,fShuffleAccuracy=0.1000000,fWalkingAccuracy=0.1000000,fWalkingFastAccuracy=0.1000000,fRunningAccuracy=0.1000000,fReticuleTime=1.0000000,fAccuracyChange=1.0000000,fWeaponJump=1.0000000)
	m_eWeaponType=7
	m_eGripType=0
	m_InventoryGroup=3
	m_HoldAttachPoint="TagItemBack1"
	m_HoldAttachPoint2="TagItemBack2"
}
