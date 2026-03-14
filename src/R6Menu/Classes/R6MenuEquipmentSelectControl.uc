//=============================================================================
//  R6MenuEquipmentSelectControl.uc : This control should provide functionalities
//                                      needed to show 2d representations of equipment
//                                      
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================
class R6MenuEquipmentSelectControl extends UWindowDialogClientWindow;

// --- Variables ---
var R6MenuGearSecondaryWeapon m_2DWeaponSecondary;
var R6MenuGearPrimaryWeapon m_2DWeaponPrimary;
var R6MenuGearGadget m_2DGadgetPrimary;
var R6MenuGearGadget m_2DGadgetSecondary;
var R6MenuGearArmor m_2DArmor;
var R6WindowButtonGear m_HighlightedButton;
//Assign All equimnent to all assigned operatives
var R6MenuAssignAllButton m_AssignAllToAllButton;
var float m_fPrimaryWindowHeight;
//Display variables
var float m_fArmorWindowWidth;
var Color m_DisableColor;
var float m_fSecondaryWindowHeight;
var Color m_EnableColor;
var bool m_bDisableControls;
var float m_fPrimaryGadgetWindowHeight;
//Debug
var bool bShowLog;
var Region m_RAssignAllToAllDisable;
var Region m_RAssignAllToAllDown;
// ^ NEW IN 1.60
var Region m_RAssignAllToAllOver;
// ^ NEW IN 1.60
var Region m_RAssignAllToAllUp;
// ^ NEW IN 1.60
var Texture m_TAssignAllToAllButton;

// --- Functions ---
function Notify(UWindowDialogControl C, byte E) {}
function bool CenterGadgetTexture(bool _Primary) {}
// ^ NEW IN 1.60
function TexRegion GetCurrentGadgetTex(bool _Primary) {}
// ^ NEW IN 1.60
function class<R6BulletDescription> GetCurrentWeaponBullet(bool _Primary) {}
// ^ NEW IN 1.60
function class<R6WeaponGadgetDescription> GetCurrentWeaponGadget(bool _Primary) {}
// ^ NEW IN 1.60
function class<R6SecondaryWeaponDescription> GetCurrentSecondaryWeapon() {}
// ^ NEW IN 1.60
function class<R6PrimaryWeaponDescription> GetCurrentPrimaryWeapon() {}
// ^ NEW IN 1.60
function Created() {}
function setHighLight(R6WindowButtonGear newButton) {}
function DisableControls(bool _Disable) {}
function UpdateDetails() {}
function class<R6ArmorDescription> GetCurrentArmor() {}
// ^ NEW IN 1.60

defaultproperties
{
}
