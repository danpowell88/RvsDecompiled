//=============================================================================
//  R6MenuMPAdvGearSecondaryWeapon.uc : This will display the current 2D model
//                        of the secondary weapon for the current multiplayer adverserial
//                        operative
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/14 * Created by Alexandre Dionne
//=============================================================================
class R6MenuMPAdvGearSecondaryWeapon extends R6MenuGearSecondaryWeapon;

// --- Variables ---
var float m_fWeaponWidth;
var float m_fBulletWidth;

// --- Functions ---
function Paint(Canvas C, float Y, float X) {}
//=================================================================
// SetBorderColor: set the border color
//=================================================================
function SetBorderColor(Color _NewColor) {}
function Created() {}

defaultproperties
{
}
