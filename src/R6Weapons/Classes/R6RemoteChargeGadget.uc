//=============================================================================
// R6RemoteChargeGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6RemoteChargeGadget : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/04 * Created by Rima Brek
//=============================================================================
class R6RemoteChargeGadget extends R6DemolitionsGadget;

function PlaceChargeAnimation()
{
	ServerPlaceChargeAnimation();
	return;
}

function ServerPlaceChargeAnimation()
{
	R6Pawn(Owner).SetNextPendingAction(15);
	return;
}

function SetAmmoStaticMesh()
{
	m_FPWeapon.m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Items.R61stC4');
	return;
}

defaultproperties
{
	m_DetonatorStaticMesh=StaticMesh'R61stWeapons_SM.Items.R61stC4Detonator'
	m_ChargeStaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdC4'
	m_ChargeAttachPoint="TagC4Hand"
	m_pBulletClass=Class'R6Weapons.R6RemoteChargeUnit'
	m_pFPWeaponClass=Class'R61stWeapons.R61stRemoteCharge'
	m_SingleFireStereoSnd=Sound'Gadget_Claymore.Play_ClaymorePlacement'
	m_SingleFireEndStereoSnd=Sound'Gadget_Claymore.Stop_Claymore_Go'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_PawnWaitAnimLow="StandGrenade_nt"
	m_PawnWaitAnimHigh="StandGrenade_nt"
	m_PawnWaitAnimProne="ProneGrenade_nt"
	m_PawnFiringAnim="CrouchC4"
	m_AttachPoint="TagC4Hand"
	m_HUDTexturePos=(W=32.0000000,Y=419.0000000,Z=100.0000000)
	m_NameID="RemoteChargeGadget"
	StaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdC4Detonator'
}
