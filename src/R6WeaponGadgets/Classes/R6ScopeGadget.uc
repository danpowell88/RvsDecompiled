//=============================================================================
// R6ScopeGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6ScopeGadget.uc : This is the base Class scopes
//
//  Copyright 2001-2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/1/31 * Created by Joel Tremblay
//=============================================================================
class R6ScopeGadget extends R6
    AbstractGadget;

simulated function UpdateAttachment(R6EngineWeapon weapOwner)
{
	local Vector vTagLocation;
	local Rotator rTagRotator;

	super.UpdateAttachment(weapOwner);
	SetBase(none);
	SetBase(weapOwner, weapOwner.Location);
	weapOwner.GetTagInformations("TagScope", vTagLocation, rTagRotator);
	SetRelativeLocation(vTagLocation);
	SetRelativeRotation(rTagRotator);
	return;
}

defaultproperties
{
	m_eGadgetType=1
	DrawType=8
	m_bDrawFromBase=true
	StaticMesh=StaticMesh'R63rdWeapons_SM.Gadgets.R63rdDefaultScope'
}
