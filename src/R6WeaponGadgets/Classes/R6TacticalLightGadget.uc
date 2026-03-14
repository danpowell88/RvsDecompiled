//=============================================================================
// R6TacticalLightGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6TacticalLightGadget.uc : This is the base Class for all gadgets avalaible for weapons.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/02 * Created by Joel Tremblay
//=============================================================================
class R6TacticalLightGadget extends R6AbstractGadget;

//var Actor m_TacticalBeam;         // Pointer to the tactical beam when the tactical light is activated;
//var (R6Attachment) class<Actor> m_pTacticalBeamClass;
var R6TacticalGlowLight m_GlowLight;

simulated event Destroyed()
{
	super.Destroyed();
	// End:0x24
	if(__NFUN_119__(m_GlowLight, none))
	{
		m_GlowLight.__NFUN_279__();
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
	if(__NFUN_242__(bActivate, true))
	{
		// End:0xEF
		if(__NFUN_132__(__NFUN_242__(bControllerInBehindView, true), __NFUN_155__(int(Level.NetMode), int(NM_Standalone))))
		{
			// End:0x5D
			if(__NFUN_114__(m_GlowLight, none))
			{
				m_GlowLight = __NFUN_278__(Class'R6WeaponGadgets.R6TacticalGlowLight');
				m_GlowLight.__NFUN_272__(m_WeaponOwner);
			}
			m_WeaponOwner.__NFUN_2008__("TagGadget", vTagLocation, rTagRotator, m_OwnerCharacter.m_fAttachFactor);
			m_GlowLight.__NFUN_298__(none);
			m_GlowLight.__NFUN_298__(m_WeaponOwner, m_WeaponOwner.Location);
			m_GlowLight.SetRelativeLocation(__NFUN_215__(vTagLocation, vGlowLightLocation));
			m_GlowLight.SetRelativeRotation(__NFUN_316__(rTagRotator, rGlowLightRotator));
		}		
	}
	else
	{
		// End:0x11D
		if(__NFUN_119__(m_GlowLight, none))
		{
			m_GlowLight.__NFUN_298__(none);
			m_GlowLight.__NFUN_279__();
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
	__NFUN_298__(none);
	__NFUN_298__(weapOwner, weapOwner.Location);
	weapOwner.__NFUN_2008__("TagGadget", vTagLocation, rTagRotator);
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
