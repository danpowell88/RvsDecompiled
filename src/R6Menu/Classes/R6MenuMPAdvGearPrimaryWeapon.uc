//=============================================================================
// R6MenuMPAdvGearPrimaryWeapon - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuMPAdvGearPrimaryWeapon.uc : This will display the current 2D model
//                        of the Primary weapon for the current 
//                        operative in adversial mode
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/14 * Created by Alexandre Dionne
//=============================================================================
class R6MenuMPAdvGearPrimaryWeapon extends R6MenuGearPrimaryWeapon;

function Created()
{
	m_2DWeapon = R6WindowButtonGear(CreateWindow(Class'R6Window.R6WindowButtonGear', 0.0000000, 0.0000000, m_2DWeaponWidth, WinHeight, self));
	m_2DWeapon.bUseRegion = true;
	m_2DWeapon.m_iDrawStyle = 5;
	m_2DBullet = R6WindowButtonGear(CreateWindow(Class'R6Window.R6WindowButtonGear', m_2DWeaponWidth, 0.0000000, (WinWidth - m_2DWeaponWidth), (WinHeight / float(2)), self));
	m_2DBullet.bUseRegion = true;
	m_2DBullet.m_iDrawStyle = 5;
	m_2DWeaponGadget = R6WindowButtonGear(CreateWindow(Class'R6Window.R6WindowButtonGear', m_2DWeaponWidth, (m_2DBullet.WinTop + m_2DBullet.WinHeight), m_2DBullet.WinWidth, (WinHeight / float(2)), self));
	m_2DWeaponGadget.bUseRegion = true;
	m_2DWeaponGadget.m_iDrawStyle = 5;
	m_BorderColor = Root.Colors.GrayLight;
	m_InsideLinesColor = Root.Colors.GrayLight;
	return;
}

//=================================================================
// SetBorderColor: set the border color
//=================================================================
function SetBorderColor(Color _NewColor)
{
	m_BorderColor = _NewColor;
	return;
}

defaultproperties
{
	m_bAssignAllButton=false
	m_bCenterTexture=true
}
