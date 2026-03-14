//=============================================================================
//  R6AbstractGadget.uc : This is the base Class for all gadgets avalaible for weapons.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/02 * Created by Joel Tremblay
//=============================================================================
class R6AbstractGadget extends Actor
    native
    nativereplication
    abstract;

// --- Variables ---
var R6EngineWeapon m_WeaponOwner;
var Pawn m_OwnerCharacter;
var name m_AttachmentName;
// Weapon Name ID
var string m_NameID;
var string m_GadgetName;
var string m_GadgetShortName;
var eGadgetType m_eGadgetType;

// --- Functions ---
simulated function InitGadget(Pawn OwnerCharacter, R6EngineWeapon OwnerWeapon) {}
simulated function UpdateAttachment(R6EngineWeapon weapOwner) {}
simulated event Destroyed() {}
simulated function AttachFPGadget() {}
simulated function DestroyFPGadget() {}
function ActivateGadget(bool bActivate, optional bool bControllerInBehindView) {}
function Vector GetGadgetMuzzleOffset() {}
// ^ NEW IN 1.60
function Toggle3rdBipod(bool bBipodOpen) {}

defaultproperties
{
}
