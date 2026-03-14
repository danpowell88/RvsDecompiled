//=============================================================================
//  R6MenuGearSecondaryWeapon.uc : This will display the current 2D model
//                        of the secondary weapon for the current 
//                        operative
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/14 * Created by Alexandre Dionne
//=============================================================================
class R6MenuGearSecondaryWeapon extends UWindowDialogControl;

// --- Variables ---
var R6WindowButtonGear m_2DBullet;
var R6WindowButtonGear m_2DWeapon;
//Weapon Gadget not to be confused with simple gadgets
var R6WindowButtonGear m_2DWeaponGadget;
var Region m_LinesRegion;
var R6MenuAssignAllButton m_AssignAll;
var Color m_InsideLinesColor;
var float m_2DWeaponWidth;
//Lines separating items
var Texture m_LinesTexture;
var bool m_bCenterTexture;
var bool m_bAssignAllButton;
var float m_2DWeaponHeight;
var float m_2DBulletHeight;

// --- Functions ---
function Created() {}
//=================================================================
// SetBorderColor: set the border color
//=================================================================
function SetBorderColor(Color _NewColor) {}
function Paint(Canvas C, float Y, float X) {}
function Register(UWindowDialogClientWindow W) {}
function SetWeaponTexture(Region R, Texture t) {}
function SetWeaponGadgetTexture(Region R, Texture t) {}
function SetBulletTexture(Region R, Texture t) {}
//===========================================================
// SetButtonStatus: set the status of all the buttons, colors maybe change here too
//===========================================================
function SetButtonsStatus(bool _bDisable) {}
//=================================================================
// ForceMouseOver: Force mouse over on all the window on this page
//=================================================================
function ForceMouseOver(bool _bForceMouseOver) {}

defaultproperties
{
}
