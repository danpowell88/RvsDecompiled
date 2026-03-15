//=============================================================================
// R6TacticalLightGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6TacticalLightGadget.uc : This is the base Class for all gadgets avalaible for weapons.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/02 * Created by Joel Tremblay
//=============================================================================
class R6TacticalLightGadget extends R6
    AbstractGadget;

//var Actor m_TacticalBeam;         // Pointer to the tactical beam when the tactical light is activated;
//var (R6Attachment) class<Actor> m_pTacticalBeamClass;
var R6TacticalGlowLight m_GlowLight;

simulated event Destroyed()
{
	super.Destroyed();
	// End:0x24
	if((m_GlowLight != none))
	{
		m_GlowLight.Destroy();
		m_GlowLight = none;
	}
	return;
}

function ActivateGadget(bool bActivate, optional bool bControllerInBehindView)
{
	local Vector vTagLocation;
	local Rotator rTagRotator;
	local Vector vGlowLightLocation;
	local Rotator rGlowLightRotator;

	// End:0xF2
	if((bActivate == true))
	{
		// End:0xEF
		if(((bControllerInBehindView == true) || (int(Level.NetMode) != int(NM_Standalone))))
		{
			// End:0x5D
			if((m_GlowLight == none))
			{
				m_GlowLight = Spawn(Class'R6WeaponGadgets.R6TacticalGlowLight');
				m_GlowLight.SetOwner(m_WeaponOwner);
			}
			m_WeaponOwner.GetTagInformations("TagGadget", vTagLocation, rTagRotator, m_OwnerCharacter.m_fAttachFactor);
			m_GlowLight.SetBase(none);
			m_GlowLight.SetBase(m_WeaponOwner, m_WeaponOwner.Location);
			m_GlowLight.SetRelativeLocation((vTagLocation + vGlowLightLocation));
			m_GlowLight.SetRelativeRotation((rTagRotator + rGlowLightRotator));
		}		
	}
	else
	{
		// End:0x11D
		if((m_GlowLight != none))
		{
			m_GlowLight.SetBase(none);
			m_GlowLight.Destroy();
			m_GlowLight = none;
		}
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
	weapOwner.GetTagInformations("TagGadget", vTagLocation, rTagRotator);
	SetRelativeLocation(vTagLocation);
	SetRelativeRotation(rTagRotator);
	return;
}

defaultproperties
{
	m_eGadgetType=6
	DrawType=8
	m_bDrawFromBase=true
	StaticMesh=StaticMesh'R63rdWeapons_SM.Gadgets.R63rdTACSubGuns'
}
