//=============================================================================
// R6MenuGearPrimaryWeapon - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuGearPrimaryWeapon.uc : This will display the current 2D model
//                        of the Primary weapon for the current 
//                        operative
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/14 * Created by Alexandre Dionne
//=============================================================================
class R6MenuGearPrimaryWeapon extends UWindowDialogControl;

var bool m_bAssignAllButton;
var bool m_bCenterTexture;
//Debug
var bool bShowLog;
//Display Values
var float m_2DWeaponWidth;
// NEW IN 1.60
var float m_2DWeaponHeight;
var float m_fBulletWidth;
var float m_2DBulletHeight;
var R6MenuAssignAllButton m_AssignAll;
var R6WindowButtonGear m_2DWeapon;
var R6WindowButtonGear m_2DBullet;
var R6WindowButtonGear m_2DWeaponGadget;  // Weapon Gadget not to be confused with simple gadgets
//Lines separating items
var Texture m_LinesTexture;
var Region m_LinesRegion;
var Color m_InsideLinesColor;

function Created()
{
	m_InsideLinesColor = Root.Colors.GrayLight;
	m_BorderColor = Root.Colors.GrayLight;
	// End:0x113
	if((m_bAssignAllButton == true))
	{
		m_AssignAll = R6MenuAssignAllButton(CreateWindow(Class'R6Menu.R6MenuAssignAllButton', ((WinWidth - float(Class'R6Menu.R6MenuAssignAllButton'.default.UpRegion.W)) - float(1)), 0.0000000, float(Class'R6Menu.R6MenuAssignAllButton'.default.UpRegion.W), m_2DWeaponHeight));
		m_AssignAll.ToolTipString = Localize("Tip", "GearRoomAssign", "R6Menu");
		m_AssignAll.ImageX = 0.0000000;
		m_AssignAll.ImageY = ((WinHeight - float(Class'R6Menu.R6MenuAssignAllButton'.default.UpRegion.H)) / float(2));
	}
	m_2DWeapon = R6WindowButtonGear(CreateWindow(Class'R6Window.R6WindowButtonGear', 0.0000000, 0.0000000, m_2DWeaponWidth, m_2DWeaponHeight, self));
	m_2DWeapon.ToolTipString = Localize("Tip", "GearRoomPriWeapon", "R6Menu");
	m_2DWeapon.bUseRegion = true;
	m_2DWeapon.m_iDrawStyle = 5;
	m_2DBullet = R6WindowButtonGear(CreateWindow(Class'R6Window.R6WindowButtonGear', m_2DWeaponWidth, 0.0000000, m_fBulletWidth, m_2DBulletHeight, self));
	m_2DBullet.ToolTipString = Localize("Tip", "GearRoomAmmo", "R6Menu");
	m_2DBullet.bUseRegion = true;
	m_2DBullet.m_iDrawStyle = 5;
	m_2DWeaponGadget = R6WindowButtonGear(CreateWindow(Class'R6Window.R6WindowButtonGear', m_2DWeaponWidth, (m_2DBullet.WinTop + m_2DBullet.WinHeight), m_2DBullet.WinWidth, (WinHeight - m_2DBulletHeight), self));
	m_2DWeaponGadget.ToolTipString = Localize("Tip", "GearRoomAttach", "R6Menu");
	m_2DWeaponGadget.bUseRegion = true;
	m_2DWeaponGadget.m_iDrawStyle = 5;
	return;
}

function Register(UWindowDialogClientWindow W)
{
	super.Register(W);
	// End:0x2B
	if((m_bAssignAllButton == true))
	{
		m_AssignAll.Register(W);
	}
	m_2DWeapon.Register(W);
	m_2DBullet.Register(W);
	m_2DWeaponGadget.Register(W);
	return;
}

function SetWeaponTexture(Texture t, Region R)
{
	m_2DWeapon.DisabledTexture = t;
	m_2DWeapon.DisabledRegion = R;
	m_2DWeapon.DownTexture = t;
	m_2DWeapon.DownRegion = R;
	m_2DWeapon.OverTexture = t;
	m_2DWeapon.OverRegion = R;
	m_2DWeapon.UpTexture = t;
	m_2DWeapon.UpRegion = R;
	// End:0x11D
	if(m_bCenterTexture)
	{
		m_2DWeapon.ImageX = ((m_2DWeapon.WinWidth - float(m_2DWeapon.UpRegion.W)) / float(2));
		m_2DWeapon.ImageY = ((m_2DWeapon.WinHeight - float(m_2DWeapon.UpRegion.H)) / float(2));
	}
	return;
}

function SetWeaponGadgetTexture(Texture t, Region R)
{
	m_2DWeaponGadget.DisabledTexture = t;
	m_2DWeaponGadget.DisabledRegion = R;
	m_2DWeaponGadget.DownTexture = t;
	m_2DWeaponGadget.DownRegion = R;
	m_2DWeaponGadget.OverTexture = t;
	m_2DWeaponGadget.OverRegion = R;
	m_2DWeaponGadget.UpTexture = t;
	m_2DWeaponGadget.UpRegion = R;
	// End:0x11D
	if(m_bCenterTexture)
	{
		m_2DWeaponGadget.ImageX = ((m_2DWeaponGadget.WinWidth - float(m_2DWeaponGadget.UpRegion.W)) / float(2));
		m_2DWeaponGadget.ImageY = ((m_2DWeaponGadget.WinHeight - float(m_2DWeaponGadget.UpRegion.H)) / float(2));
	}
	return;
}

function SetBulletTexture(Texture t, Region R)
{
	m_2DBullet.DisabledTexture = t;
	m_2DBullet.DisabledRegion = R;
	m_2DBullet.DownTexture = t;
	m_2DBullet.DownRegion = R;
	m_2DBullet.OverTexture = t;
	m_2DBullet.OverRegion = R;
	m_2DBullet.UpTexture = t;
	m_2DBullet.UpRegion = R;
	// End:0x11D
	if(m_bCenterTexture)
	{
		m_2DBullet.ImageX = ((m_2DBullet.WinWidth - float(m_2DBullet.UpRegion.W)) / float(2));
		m_2DBullet.ImageY = ((m_2DBullet.WinHeight - float(m_2DBullet.UpRegion.H)) / float(2));
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	C.Style = 5;
	C.SetDrawColor(m_InsideLinesColor.R, m_InsideLinesColor.G, m_InsideLinesColor.B);
	DrawStretchedTextureSegment(C, m_2DWeaponWidth, 0.0000000, float(m_LinesRegion.W), WinHeight, float(m_LinesRegion.X), float(m_LinesRegion.Y), float(m_LinesRegion.W), float(m_LinesRegion.H), m_LinesTexture);
	DrawStretchedTextureSegment(C, (m_2DWeaponWidth + float(1)), m_2DWeaponGadget.WinTop, (m_2DWeaponGadget.WinWidth - float(1)), float(m_LinesRegion.H), float(m_LinesRegion.X), float(m_LinesRegion.Y), float(m_LinesRegion.W), float(m_LinesRegion.H), m_LinesTexture);
	DrawSimpleBorder(C);
	return;
}

//===========================================================
// SetButtonStatus: set the status of all the buttons, colors maybe change here too
//===========================================================
function SetButtonsStatus(bool _bDisable)
{
	m_AssignAll.SetButtonStatus(_bDisable);
	m_2DWeapon.bDisabled = _bDisable;
	m_2DBullet.bDisabled = _bDisable;
	m_2DWeaponGadget.bDisabled = _bDisable;
	return;
}

//=================================================================
// SetBorderColor: set the border color
//=================================================================
function SetBorderColor(Color _NewColor)
{
	m_AssignAll.SetBorderColor(_NewColor);
	m_BorderColor = _NewColor;
	return;
}

//=================================================================
// ForceMouseOver: Force mouse over on all the window on this page
//=================================================================
function ForceMouseOver(bool _bForceMouseOver)
{
	m_2DWeapon.ForceMouseOver(_bForceMouseOver);
	m_2DBullet.ForceMouseOver(_bForceMouseOver);
	m_2DWeaponGadget.ForceMouseOver(_bForceMouseOver);
	return;
}

defaultproperties
{
	m_bAssignAllButton=true
	m_2DWeaponWidth=130.0000000
	m_2DWeaponHeight=79.0000000
	m_fBulletWidth=65.0000000
	m_2DBulletHeight=35.0000000
	m_LinesTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_LinesRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=16418,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var t
