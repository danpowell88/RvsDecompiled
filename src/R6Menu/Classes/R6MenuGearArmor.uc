//=============================================================================
// R6MenuGearArmor - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuGearArmor.uc : This will display the current 2D model
//                        of the Armor for the current 
//                        operative
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/14 * Created by Alexandre Dionne
//=============================================================================
class R6MenuGearArmor extends UWindowDialogControl;

var R6WindowButtonGear m_2DArmor;
var R6MenuAssignAllButton m_AssignAll;

function Created()
{
	m_BorderColor = Root.Colors.GrayLight;
	m_AssignAll = R6MenuAssignAllButton(CreateWindow(Class'R6Menu.R6MenuAssignAllButton', ((WinWidth - float(Class'R6Menu.R6MenuAssignAllButton'.default.UpRegion.W)) - float(1)), 0.0000000, float(Class'R6Menu.R6MenuAssignAllButton'.default.UpRegion.W), WinHeight, self));
	m_AssignAll.ToolTipString = Localize("Tip", "GearRoomArmorAll", "R6Menu");
	m_AssignAll.ImageX = 0.0000000;
	m_AssignAll.ImageY = ((WinHeight - float(Class'R6Menu.R6MenuAssignAllButton'.default.UpRegion.H)) / float(2));
	m_2DArmor = R6WindowButtonGear(CreateWindow(Class'R6Window.R6WindowButtonGear', 0.0000000, 0.0000000, (WinWidth - m_AssignAll.WinWidth), WinHeight, self));
	m_2DArmor.ToolTipString = Localize("Tip", "GearRoomArmor", "R6Menu");
	m_2DArmor.bUseRegion = true;
	m_2DArmor.m_iDrawStyle = 5;
	return;
}

function Register(UWindowDialogClientWindow W)
{
	super.Register(W);
	m_AssignAll.Register(W);
	m_2DArmor.Register(W);
	return;
}

function SetArmorTexture(Texture t, Region R)
{
	m_2DArmor.DisabledTexture = t;
	m_2DArmor.DisabledRegion = R;
	m_2DArmor.DownTexture = t;
	m_2DArmor.DownRegion = R;
	m_2DArmor.OverTexture = t;
	m_2DArmor.OverRegion = R;
	m_2DArmor.UpTexture = t;
	m_2DArmor.UpRegion = R;
	return;
}

function Paint(Canvas C, float X, float Y)
{
	DrawSimpleBorder(C);
	return;
}

//===========================================================
// SetButtonStatus: set the status of all the buttons, colors maybe change here too
//===========================================================
function SetButtonsStatus(bool _bDisable)
{
	m_AssignAll.SetButtonStatus(_bDisable);
	m_2DArmor.bDisabled = _bDisable;
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
	m_2DArmor.ForceMouseOver(_bForceMouseOver);
	return;
}

