//=============================================================================
//  R6MenuMPAdvEquipmentSelectControl.uc : This control should provide functionalities
//                                      needed to show 2d representations of equipment
//                                      multi-player adverserial    
//                                      
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================
class R6MenuMPAdvEquipmentSelectControl extends R6MenuEquipmentSelectControl;

// --- Variables ---
//Debug
var bool bShowLog;
var float m_fPrimaryGadgetWindowWidth;

// --- Functions ---
function class<R6WeaponGadgetDescription> GetCurrentWeaponGadget(bool _Primary) {}
// ^ NEW IN 1.60
function class<R6BulletDescription> GetCurrentWeaponBullet(bool _Primary) {}
// ^ NEW IN 1.60
function TexRegion GetCurrentGadgetTex(bool _Primary) {}
// ^ NEW IN 1.60
function Notify(byte E, UWindowDialogControl C) {}
function bool CenterGadgetTexture(bool _Primary) {}
// ^ NEW IN 1.60
function class<R6SecondaryWeaponDescription> GetCurrentSecondaryWeapon() {}
// ^ NEW IN 1.60
function class<R6PrimaryWeaponDescription> GetCurrentPrimaryWeapon() {}
// ^ NEW IN 1.60
function Init() {}
function Created() {}

defaultproperties
{
}
