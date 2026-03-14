//=============================================================================
// R6ClaymoreGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6ClaymoreGadget.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/06 * Created by Rima Brek
//=============================================================================
class R6ClaymoreGadget extends R6DemolitionsGadget;

function PlaceChargeAnimation()
{
	R6Pawn(Owner).PlayClaymoreAnimation();
	ServerPlaceChargeAnimation();
	return;
}

function ServerPlaceChargeAnimation()
{
	R6Pawn(Owner).SetNextPendingAction(17);
	return;
}

function SetAmmoStaticMesh()
{
	m_FPWeapon.m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Items.R61stClaymore');
	return;
}

defaultproperties
{
	m_DetonatorStaticMesh=StaticMesh'R61stWeapons_SM.Items.R61stClaymoreDetonator'
	m_ChargeStaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdClaymore'
	m_ChargeAttachPoint="TagClaymoreHand"
	m_pBulletClass=Class'R6Weapons.R6ClaymoreUnit'
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsGadgetClaymore'
	m_pFPWeaponClass=Class'R61stWeapons.R61stClaymore'
	m_SingleFireStereoSnd=Sound'Gadget_Claymore.Play_ClaymorePlacement'
	m_SingleFireEndStereoSnd=Sound'Gadget_Claymore.Stop_Claymore_Go'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_PawnWaitAnimLow="StandGrenade_nt"
	m_PawnWaitAnimHigh="StandGrenade_nt"
	m_PawnWaitAnimProne="ProneGrenade_nt"
	m_PawnFiringAnim="CrouchClaymore"
	m_PawnFiringAnimProne="ProneClaymore"
	m_AttachPoint="TagClaymoreHand"
	m_HUDTexturePos=(W=32.0000000,Y=452.0000000,Z=100.0000000)
	m_NameID="ClaymoreGadget"
	StaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdClaymoreDetonator'
}
