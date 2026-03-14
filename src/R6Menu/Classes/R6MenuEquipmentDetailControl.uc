//=============================================================================
//  R6MenuEquipmentDetailControl.uc : This control should provide functionalities
//                                      needed to select armor, weapons, bullets
//                                      gadgets for an operative
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================
class R6MenuEquipmentDetailControl extends UWindowDialogClientWindow;

// --- Variables ---
// var ? m_ListBox; // REMOVED IN 1.60
var R6WindowTextListBox m_listBox;
// ^ NEW IN 1.60
var R6MenuWeaponStats m_WeaponStats;
var R6WindowTextLabel m_Title;
var R6MenuEquipmentAnchorButtons m_AnchorButtons;
var R6WindowWrappedTextArea m_EquipmentText;
//To notify the gear menu
var int m_CurrentEquipmentType;
//class<R6GadgetDescription>
var array<array> m_AGadgets;
//class<R6PrimaryWeaponDescription>
var array<array> m_APrimaryWeapons;
//class<R6SecondaryWeaponDescription>
var array<array> m_ASecondaryWeapons;
//class<R6ArmorDescription>
var array<array> m_AArmors;
var R6MenuWeaponDetailRadioArea m_Buttons;
var float m_fListBoxHeight;
var float m_fAnchorAreaHeight;
var float m_fListBoxLabelHeight;
// ^ NEW IN 1.60
var Font m_DescriptionTextFont;
//For description Area
var Color m_DescriptionTextColor;
var bool m_bDrawListBg;

// --- Functions ---
function FillListBox(int _equipmentType) {}
function BuildAvailableEquipment() {}
function Created() {}
//This Hides Or display Anchor buttons for equipment that support it
function UpdateAnchorButtons(eAnchorEquipmentType _AEType) {}
function enableWeaponStats(bool _enable) {}
function NotifyEquipmentChanged(class<R6Description> DecriptionClass, int EquipmentSelected) {}
function class<R6GadgetDescription> GetCurrentGadget(bool _Primary) {}
// ^ NEW IN 1.60
function class<R6BulletDescription> GetCurrentWeaponBullet(bool _Primary) {}
// ^ NEW IN 1.60
function class<R6WeaponGadgetDescription> GetCurrentWeaponGadget(bool _Primary) {}
// ^ NEW IN 1.60
function class<R6SecondaryWeaponDescription> GetCurrentSecondaryWeapon() {}
// ^ NEW IN 1.60
function class<R6PrimaryWeaponDescription> GetCurrentPrimaryWeapon() {}
// ^ NEW IN 1.60
function R6Operative GetCurrentOperative() {}
// ^ NEW IN 1.60
function ChangePage(int _Page) {}
function Paint(Canvas C, float Y, float X) {}
function R6WindowListBoxItem CreateGadgetsSeparators() {}
// ^ NEW IN 1.60
function R6WindowListBoxItem CreatePrimaryWeaponsSeparators() {}
// ^ NEW IN 1.60
function Notify(UWindowDialogControl C, byte E) {}
//=============================================================================
// Simple bubble sort to list servers in alphabetical order of name
//=============================================================================
static function SortDescriptions(out array<array> Descriptions, string LocalizationFile, bool _bAscending, optional bool bUseTags) {}
function BuildAvailableMissionArmors() {}
function R6WindowListBoxItem CreateSecondaryWeaponsSeparators() {}
// ^ NEW IN 1.60
function bool IsAmorAvailable(class<R6ArmorDescription> lookedUpArmor, R6Operative currentOperative) {}
// ^ NEW IN 1.60
//=================================================================================
// ShowWindow: This is call when an equipement was selected, force the keyfocus on the list box
//=================================================================================
function ShowWindow() {}
function class<R6ArmorDescription> GetDefaultArmor() {}
// ^ NEW IN 1.60
function class<R6ArmorDescription> GetCurrentArmor() {}
// ^ NEW IN 1.60

defaultproperties
{
}
