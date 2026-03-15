//=============================================================================
// R6MuzzleGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MuzzleGadget.uc : This is the base Class for all Silencer.
//                        this class uses the Subgun silencer.  
//                        For other meshes overload this one
//  Copyright 2001-2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/3/20 * Created by Serge Dore
//=============================================================================
class R6MuzzleGadget extends R6
    AbstractGadget;

var Actor m_FPMuzzelModel;
var(R6Attachment) Class<Actor> m_pFPMuzzleClass;

replication
{
	// Pos:0x000
	reliable if((bNetOwner && (int(Role) == int(ROLE_Authority))))
		m_FPMuzzelModel;
}

simulated event Destroyed()
{
	super.Destroyed();
	DestroyFPGadget();
	return;
}

simulated function UpdateAttachment(R6EngineWeapon weapOwner)
{
	local Vector vTagLocation;
	local Rotator rTagRotator;

	super.UpdateAttachment(weapOwner);
	SetBase(none);
	SetBase(weapOwner, weapOwner.Location);
	weapOwner.GetTagInformations("TagMuzzle", vTagLocation, rTagRotator);
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
	// End:0x4C
	if((m_FPMuzzelModel == none))
	{
		// End:0x4C
		if((m_pFPMuzzleClass != none))
		{
			m_FPMuzzelModel = Spawn(m_pFPMuzzleClass);
		}
	}
	// End:0x7E
	if((m_FPMuzzelModel != none))
	{
		R6AbstractWeapon(m_WeaponOwner).m_FPWeapon.AttachToBone(m_FPMuzzelModel, 'TagMuzzle');
	}
	return;
}

simulated function DestroyFPGadget()
{
	local Actor temp;

	// End:0x29
	if((m_FPMuzzelModel != none))
	{
		temp = m_FPMuzzelModel;
		m_FPMuzzelModel = none;
		temp.Destroy();
	}
	return;
}

defaultproperties
{
	m_eGadgetType=4
	m_NameID="Muzzle"
	m_bDrawFromBase=true
}
