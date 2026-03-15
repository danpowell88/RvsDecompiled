//=============================================================================
// R6BipodGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  R6BipodGadget.uc
//
//  Copyright 2001-2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/29/04 * Created by Joel Tremblay
//=============================================================================
class R6BipodGadget extends R6
    AbstractGadget;

var(R6Meshes) StaticMesh CloseSM;
var(R6Meshes) StaticMesh OpenSM;

simulated function Toggle3rdBipod(bool bBipodOpen)
{
	// End:0x1A
	if((bBipodOpen == false))
	{
		SetStaticMesh(CloseSM);		
	}
	else
	{
		SetStaticMesh(OpenSM);
	}
	return;
}

simulated function UpdateAttachment(R6EngineWeapon weapOwner)
{
	local Vector vTagLocation;
	local Rotator rTagRotator;

	super.UpdateAttachment(weapOwner);
	SetBase(none);
	SetBase(weapOwner, weapOwner.Location);
	weapOwner.GetTagInformations("TagBipod", vTagLocation, rTagRotator);
	SetRelativeLocation(vTagLocation);
	SetRelativeRotation(rTagRotator);
	return;
}

defaultproperties
{
	m_eGadgetType=3
	DrawType=8
	m_bDrawFromBase=true
}
