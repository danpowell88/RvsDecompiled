//=============================================================================
// R6SilencerGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6SilencerGadget.uc : This is the base Class for all Silencer.
//                        this class uses the Subgun silencer.  
//                        For other meshes overload this one
//  Copyright 2001-2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/1/31 * Created by Joel Tremblay
//=============================================================================
class R6SilencerGadget extends R6
    AbstractGadget;

var Actor m_FPSilencerModel;
var Class<Actor> m_pFPSilencerClass;

simulated event Destroyed()
{
	super.Destroyed();
	DestroyFPGadget();
	return;
}

simulated function Vector GetGadgetMuzzleOffset()
{
	local Vector vTagLocation;
	local Rotator rTagRotator;

	__NFUN_2008__("TAGSilencer", vTagLocation, rTagRotator, 1.0000000);
	return vTagLocation;
	return;
}

simulated function UpdateAttachment(R6EngineWeapon weapOwner)
{
	local Vector vTagLocation;
	local Rotator rTagRotator;

	super.UpdateAttachment(weapOwner);
	m_GadgetShortName = Localize(m_NameID, "ID_SHORTNAME", "R6WeaponGadgets");
	__NFUN_298__(none);
	__NFUN_298__(weapOwner, weapOwner.Location);
	weapOwner.__NFUN_2008__("TagMuzzle", vTagLocation, rTagRotator);
	SetRelativeLocation(vTagLocation);
	SetRelativeRotation(rTagRotator);
	return;
}

simulated function AttachFPGadget()
{
	local Vector vTagLocation;
	local Rotator rTagRotator;

	// End:0x28
	if(__NFUN_132__(__NFUN_114__(m_WeaponOwner, none), __NFUN_114__(R6AbstractWeapon(m_WeaponOwner).m_FPWeapon, none)))
	{
		return;
	}
	// End:0x41
	if(__NFUN_114__(m_FPSilencerModel, none))
	{
		m_FPSilencerModel = __NFUN_278__(m_pFPSilencerClass);
	}
	// End:0xA8
	if(__NFUN_119__(m_FPSilencerModel, none))
	{
		R6AbstractWeapon(m_WeaponOwner).m_FPWeapon.AttachToBone(m_FPSilencerModel, 'TagMuzzle');
		m_FPSilencerModel.__NFUN_2008__("TagMuzzle", vTagLocation, rTagRotator);
		m_WeaponOwner.m_FPFlashLocation = vTagLocation;
	}
	return;
}

simulated function DestroyFPGadget()
{
	local Actor aFPGadget;

	aFPGadget = m_FPSilencerModel;
	m_FPSilencerModel = none;
	// End:0x29
	if(__NFUN_119__(aFPGadget, none))
	{
		aFPGadget.__NFUN_279__();
	}
	return;
}

defaultproperties
{
	m_eGadgetType=5
	m_NameID="Silencer"
	m_bDrawFromBase=true
}
