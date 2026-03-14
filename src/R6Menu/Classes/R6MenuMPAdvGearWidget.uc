//=============================================================================
//  R6MenuMPAdvGearWidget.uc : GearRoomMenu for multi-player adverserial
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/24 * Created by Alexandre Dionne
//=============================================================================
class R6MenuMPAdvGearWidget extends R6MenuWidget;

// --- Enums ---
enum e2DEquipment
{
    Primary_Weapon,
    Primary_WeaponGadget,
    Primary_Bullet,
    Primary_Gadget,
    Secondary_Weapon,
    Secondary_WeaponGadget,
    Secondary_Bullet,
    Secondary_Gadget
};

// --- Variables ---
// var ? bshowlog; // REMOVED IN 1.60
var R6Operative m_currentOperative;
var R6Operative m_BkpOperative;
// ^ NEW IN 1.60
//Right side when looking at an equipment item
var R6MenuMPAdvEquipmentDetailControl m_EquipmentDetails;
var bool bShowLog;
// ^ NEW IN 1.60
var class<R6WeaponGadgetDescription> m_OpSecondWeaponGadgetDesc;
var class<R6WeaponGadgetDescription> m_OpFirstWeaponGadgetDesc;
// ^ NEW IN 1.60
//Equipment of the selected Operative
var class<R6PrimaryWeaponDescription> m_OpFirstWeaponDesc;
var class<R6SecondaryWeaponDescription> m_OpSecondaryWeaponDesc;
var R6DescPrimaryMags m_PrimaryMagsGadget;
//Left part where we can take a look a selected equipment
var R6MenuMPAdvEquipmentSelectControl m_Equipment2dSelect;
var class<R6BulletDescription> m_OpSecondWeaponBulletDesc;
var class<R6BulletDescription> m_OpFirstWeaponBulletDesc;
// ^ NEW IN 1.60
var class<R6GadgetDescription> m_OpFirstGadgetDesc;
// ^ NEW IN 1.60
var class<R6GadgetDescription> m_OpSecondGadgetDesc;
//debug
var int m_iCounter;
//MissionPack1   // MPF1
var string PrimaryGadgetDesc;
var e2DEquipment m_e2DCurEquipmentSel;

// --- Functions ---
// function ? PopUpBoxDone(...); // REMOVED IN 1.60
function EquipmentSelected(e2DEquipment EquipmentSelected) {}
function EquipmentChanged(class<R6Description> DecriptionClass, int EquipmentSelected) {}
function string VerifyEquipment(string _szEquipmentToValid, int _equipmentType) {}
// ^ NEW IN 1.60
//MAKE SURE THIS FUNCTION IS THE SAME AS THE ONE IN THE SINGLEPLAYER GEAR ROOM
function TexRegion GetGadgetTexture(class<R6GadgetDescription> _CurrentGadget) {}
// ^ NEW IN 1.60
function GetMenuComEquipment(bool _bCkeckEquipment) {}
function setMenuComEquipment() {}
function VerifyAllEquipment(string _szPrimaryWeapon, string _szPrimaryWeaponGadget, string _szPrimaryGadget, string _szSecondaryWeapon, string _szSecondaryWeaponGadget, string _szSecondaryGadget) {}
// ^ NEW IN 1.60
function SetOperativeEquipment(bool _bCopyBkpToCurrent) {}
// ^ NEW IN 1.60
//=========================================================================================
// RefreshGearInfo: Refresh all the gear according the new restriction kit
//=========================================================================================
function RefreshGearInfo(bool _bForceUpdate) {}
static function bool CheckGadget(string _gadgetDesc, out optional class<R6GadgetDescription> _replaceGadgetClass, optional string _otherGadget, UWindowWindow _caller, bool _isSecondGadget) {}
// ^ NEW IN 1.60
function Created() {}
function ShowWindow() {}
function SetClassEquipment() {}
// ^ NEW IN 1.60
function AcceptSelection() {}
// ^ NEW IN 1.60
function CancelSelection() {}
// ^ NEW IN 1.60

defaultproperties
{
}
