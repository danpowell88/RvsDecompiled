//=============================================================================
// R6ThermalScopeGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6ThermalScopeGadget.uc : This is the base Class scopes
//
//  Copyright 2001-2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6ThermalScopeGadget extends R6
    AbstractGadget;

var Actor m_FPThermalScopeModel;

simulated event Destroyed()
{
	super.Destroyed();
	DestroyFPGadget();
	return;
}

function ActivateGadget(bool bActivate, optional bool bControllerInBehindView)
{
	R6Pawn(m_OwnerCharacter).ToggleHeatVision();
	return;
}

simulated function UpdateAttachment(R6EngineWeapon weapOwner)
{
	local Vector vTagLocation;
	local Rotator rTagRotator;

	super.UpdateAttachment(weapOwner);
	m_GadgetShortName = Localize(m_NameID, "ID_SHORTNAME", "R6WeaponGadgets");
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
	// End:0x41
	if((m_FPThermalScopeModel == none))
	{
		m_FPThermalScopeModel = Spawn(Class'R6WeaponGadgets.R61stThermalScope');
	}
	// End:0x73
	if((m_FPThermalScopeModel != none))
	{
		R6AbstractWeapon(m_WeaponOwner).m_FPWeapon.AttachToBone(m_FPThermalScopeModel, 'TagThermal');
	}
	return;
}

simulated function DestroyFPGadget()
{
	local Actor aFPGadget;

	aFPGadget = m_FPThermalScopeModel;
	m_FPThermalScopeModel = none;
	// End:0x29
	if((aFPGadget != none))
	{
		aFPGadget.Destroy();
	}
	return;
}

defaultproperties
{
	m_NameID="ThermalScope"
	DrawType=8
	m_bDrawFromBase=true
	StaticMesh=StaticMesh'R63rdWeapons_SM.Gadgets.R63rdThermalScope'
}
