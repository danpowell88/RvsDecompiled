//=============================================================================
// R6MiniScopeGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MiniScopeGadget.uc : This is the base Class for all gadgets avalaible for weapons.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/02 * Created by Joel Tremblay
//=============================================================================
class R6MiniScopeGadget extends R6
    AbstractGadget;

var Actor m_FPMiniScopeModel;
var Texture m_ScopeTexure;
var Texture m_ScopeAdd;
var(R6Attachment) Class<Actor> m_pFPMiniScopeClass;

simulated event Destroyed()
{
	super.Destroyed();
	DestroyFPGadget();
	return;
}

function InitGadget(R6EngineWeapon OwnerWeapon, Pawn OwnerCharacter)
{
	OwnerWeapon.m_fMaxZoom = 3.5000000;
	OwnerWeapon.UseScopeStaticMesh();
	super.InitGadget(OwnerWeapon, OwnerCharacter);
	return;
}

function ActivateGadget(bool bActivate, optional bool bControllerInBehindView)
{
	return;
}

simulated function UpdateAttachment(R6EngineWeapon weapOwner)
{
	local Vector vTagLocation;
	local Rotator rTagRotator;

	super.UpdateAttachment(weapOwner);
	m_GadgetShortName = Localize(m_NameID, "ID_SHORTNAME", "R6WeaponGadgets");
	SetBase(none);
	SetBase(weapOwner, weapOwner.Location);
	weapOwner.GetTagInformations("TagScope", vTagLocation, rTagRotator);
	SetRelativeLocation(vTagLocation);
	SetRelativeRotation(rTagRotator);
	return;
}

simulated function AttachFPGadget()
{
	// End:0x28
	if(((m_WeaponOwner == none) || (R6AbstractWeapon(m_WeaponOwner).m_FPWeapon == none)))
	{
		return;
	}
	// End:0x6C
	if(((m_FPMiniScopeModel == none) && (m_pFPMiniScopeClass != none)))
	{
		m_FPMiniScopeModel = Spawn(m_pFPMiniScopeClass);
		m_FPMiniScopeModel.SetOwner(self);
		m_FPMiniScopeModel.RemoteRole = ROLE_None;
	}
	// End:0xD8
	if((m_FPMiniScopeModel != none))
	{
		R6AbstractWeapon(m_WeaponOwner).m_FPWeapon.AttachToBone(m_FPMiniScopeModel, 'TagScope');
		R6AbstractWeapon(m_WeaponOwner).m_FPWeapon.SwitchFPMesh();
		R6AbstractWeapon(m_WeaponOwner).m_FPHands.SwitchFPAnim();
	}
	m_WeaponOwner.m_ScopeTexture = m_ScopeTexure;
	m_WeaponOwner.m_ScopeAdd = m_ScopeAdd;
	return;
}

simulated function DestroyFPGadget()
{
	local Actor temp;

	// End:0x29
	if((m_FPMiniScopeModel != none))
	{
		temp = m_FPMiniScopeModel;
		m_FPMiniScopeModel = none;
		temp.Destroy();
	}
	return;
}

defaultproperties
{
	m_ScopeTexure=Texture'Inventory_t.Scope.ScopeBlurTex_3'
	m_ScopeAdd=Texture'Inventory_t.Scope.ScopeBlurTex_3add'
	m_pFPMiniScopeClass=Class'R6WeaponGadgets.R61stMiniScope'
	m_NameID="MiniScope"
	DrawType=8
	m_bDrawFromBase=true
	StaticMesh=StaticMesh'R63rdWeapons_SM.Gadgets.R63rdMiniScope'
}
