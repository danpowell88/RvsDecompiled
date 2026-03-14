//=============================================================================
//  R6MenuGearPrimaryWeapon.uc : This will display the current 2D model
//                        of the Primary weapon for the current 
//                        operative
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/14 * Created by Alexandre Dionne
//=============================================================================
class R6MenuGearPrimaryWeapon extends UWindowDialogControl;

// --- Variables ---
var R6WindowButtonGear m_2DBullet;
//Weapon Gadget not to be confused with simple gadgets
var R6WindowButtonGear m_2DWeaponGadget;
var R6WindowButtonGear m_2DWeapon;
var Region m_LinesRegion;
var R6MenuAssignAllButton m_AssignAll;
var float m_2DWeaponWidth;
// ^ NEW IN 1.60
var Color m_InsideLinesColor;
var bool m_bCenterTexture;
var bool m_bAssignAllButton;
var float m_2DBulletHeight;
//Display Values
var float m_2DWeaponHeight;
//Lines separating items
var Texture m_LinesTexture;
var float m_fBulletWidth;
//Debug
var bool bShowLog;

// --- Functions ---
//=================================================================
// SetBorderColor: set the border color
//=================================================================
function SetBorderColor(Color _NewColor) {}
function Created() {}
//=================================================================
// ForceMouseOver: Force mouse over on all the window on this page
//=================================================================
function ForceMouseOver(bool _bForceMouseOver) {}
function Paint(Canvas C, float Y, float X) {}
function Register(UWindowDialogClientWindow W) {}
function SetWeaponTexture(Texture t, Region R) {}
function SetWeaponGadgetTexture(Region R, Texture t) {}
function SetBulletTexture(Region R, Texture t) {}
//===========================================================
// SetButtonStatus: set the status of all the buttons, colors maybe change here too
//===========================================================
function SetButtonsStatus(bool _bDisable) {}

defaultproperties
{
}
