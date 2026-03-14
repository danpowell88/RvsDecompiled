//=============================================================================
// R6AbstractGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6AbstractGadget.uc : This is the base Class for all gadgets avalaible for weapons.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/02 * Created by Joel Tremblay
//=============================================================================
class R6AbstractGadget extends Actor
    abstract
    native
    nativereplication
    notplaceable;

var R6EngineWeapon.eGadgetType m_eGadgetType;
var R6EngineWeapon m_WeaponOwner;
var Pawn m_OwnerCharacter;
var name m_AttachmentName;
var string m_NameID;  // Weapon Name ID
var string m_GadgetName;
var string m_GadgetShortName;

simulated event Destroyed()
{
	super.Destroyed();
	m_WeaponOwner = none;
	m_OwnerCharacter = none;
	return;
}

simulated function InitGadget(R6EngineWeapon OwnerWeapon, Pawn OwnerCharacter)
{
	UpdateAttachment(OwnerWeapon);
	m_OwnerCharacter = OwnerCharacter;
	AttachFPGadget();
	return;
}

simulated function UpdateAttachment(R6EngineWeapon weapOwner)
{
	m_WeaponOwner = weapOwner;
	return;
}

simulated function AttachFPGadget()
{
	return;
}

simulated function DestroyFPGadget()
{
	return;
}

function ActivateGadget(bool bActivate, optional bool bControllerInBehindView)
{
	return;
}

function Vector GetGadgetMuzzleOffset()
{
	return vect(0.0000000, 0.0000000, 0.0000000);
	return;
}

function Toggle3rdBipod(bool bBipodOpen)
{
	return;
}

defaultproperties
{
	RemoteRole=0
	DrawType=0
	bSkipActorPropertyReplication=true
	m_bForceBaseReplication=true
	DrawScale3D=(X=-1.0000000,Y=-1.0000000,Z=1.0000000)
}
