//=============================================================================
//  R6MenuMPAdvEquipmentDetailControl.uc : This control should provide functionalities
//                                      needed to select armor, weapons, bullets
//                                      gadgets for an operative for adversial multi-player
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================
class R6MenuMPAdvEquipmentDetailControl extends R6MenuEquipmentDetailControl;

// --- Variables ---
// List of available primary weapon gadgets
var array<array> m_APriWpnGadget;
// List of available secondary weapon gadgets
var array<array> m_ASecWpnGadget;
var array<array> m_ADefaultWpnGadget;
//class<R6PrimaryWeaponDescription>
var array<array> m_ADefaultPrimaryWeapons;
//class<R6SecondaryWeaponDescription>
var array<array> m_ADefaultSecondaryWeapons;
//class<R6GadgetDescription>
var array<array> m_ADefaultGadgets;
// this is the last list index to know if your are in the same list
var int m_iLastListIndex;

// --- Functions ---
function class<R6WeaponGadgetDescription> GetCurrentWeaponGadget(bool _Primary) {}
// ^ NEW IN 1.60
function class<R6BulletDescription> GetCurrentWeaponBullet(bool _Primary) {}
// ^ NEW IN 1.60
function class<R6GadgetDescription> GetCurrentGadget(bool _Primary) {}
// ^ NEW IN 1.60
function NotifyEquipmentChanged(class<R6Description> DecriptionClass, int EquipmentSelected) {}
function enableWeaponStats(bool _enable) {}
//This Hides Or display Anchor buttons for equipment that support it
function UpdateAnchorButtons(eAnchorEquipmentType _AEType) {}
function Created() {}
function FillListBox(int _equipmentType) {}
function BuildAvailableEquipment() {}
//===================================================================
// GetAllPrimaryWeaponGadget: Get All Primary Weapon Gadget
//===================================================================
function GetAllWeaponGadget() {}
//===================================================================
// GetAllPrimaryWeapon: Get all the primary weapon
//===================================================================
function GetAllPrimaryWeapon() {}
//===================================================================
// GetAllSecondaryWeapon: Get all the secondary weapon
//===================================================================
function GetAllSecondaryWeapon() {}
//===================================================================
// GetAllGadgets: Get all gadgets
//===================================================================
function GetAllGadgets() {}
function CompareGearItemsWithServerRest(out array<array> _AGearItems, string _AServerRest) {}
function class<R6SecondaryWeaponDescription> GetCurrentSecondaryWeapon() {}
// ^ NEW IN 1.60
function class<R6PrimaryWeaponDescription> GetCurrentPrimaryWeapon() {}
// ^ NEW IN 1.60
function R6Operative GetCurrentOperative() {}
// ^ NEW IN 1.60

defaultproperties
{
}
