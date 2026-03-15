//=============================================================================
// R6MenuMPAdvGearSecondaryWeapon - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
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

var float m_fWeaponWidth;
var float m_fBulletWidth;

function Created()
{
	m_2DWeapon = R6WindowButtonGear(CreateWindow(Class'R6Window.R6WindowButtonGear', 0.0000000, 0.0000000, m_fWeaponWidth, WinHeight, self));
	m_2DWeapon.bUseRegion = true;
	m_2DWeapon.m_iDrawStyle = 5;
	m_2DBullet = R6WindowButtonGear(CreateWindow(Class'R6Window.R6WindowButtonGear', m_fWeaponWidth, 0.0000000, m_fBulletWidth, WinHeight, self));
	m_2DBullet.bUseRegion = true;
	m_2DBullet.m_iDrawStyle = 5;
	m_2DWeaponGadget = R6WindowButtonGear(CreateWindow(Class'R6Window.R6WindowButtonGear', (m_fWeaponWidth + m_2DBullet.WinWidth), 0.0000000, ((WinWidth - m_2DBullet.WinWidth) - m_2DWeapon.WinWidth), WinHeight, self));
	m_2DWeaponGadget.bUseRegion = true;
	m_2DWeaponGadget.m_iDrawStyle = 5;
	m_BorderColor = Root.Colors.GrayLight;
	m_InsideLinesColor = Root.Colors.GrayLight;
	return;
}

function Paint(Canvas C, float X, float Y)
{
	DrawSimpleBorder(C);
	C.Style = 5;
	C.SetDrawColor(m_InsideLinesColor.R, m_InsideLinesColor.G, m_InsideLinesColor.B);
	DrawStretchedTextureSegment(C, m_2DWeapon.WinWidth, 0.0000000, float(m_LinesRegion.W), WinHeight, float(m_LinesRegion.X), float(m_LinesRegion.Y), float(m_LinesRegion.W), float(m_LinesRegion.H), m_LinesTexture);
	DrawStretchedTextureSegment(C, (m_2DBullet.WinLeft + m_2DBullet.WinWidth), 0.0000000, float(m_LinesRegion.W), WinHeight, float(m_LinesRegion.X), float(m_LinesRegion.Y), float(m_LinesRegion.W), float(m_LinesRegion.H), m_LinesTexture);
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
	m_fWeaponWidth=86.0000000
	m_fBulletWidth=73.0000000
	m_bAssignAllButton=false
	m_bCenterTexture=true
}
