//=============================================================================
// R6MenuGearGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuGearGadget.uc : This will display the current 2D model
//                        of one of the 2 gadgets selected for the current 
//                        operative
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/14 * Created by Alexandre Dionne
//=============================================================================
class R6MenuGearGadget extends UWindowDialogControl;

var bool m_bAssignAllButton;
var bool m_bCenterTexture;
var float m_2DGadgetWidth;
var R6MenuAssignAllButton m_AssignAll;
var R6WindowButtonGear m_2DGadget;

function Created()
{
	m_BorderColor = Root.Colors.GrayLight;
	// End:0xF8
	if((m_bAssignAllButton == true))
	{
		m_AssignAll = R6MenuAssignAllButton(CreateWindow(Class'R6Menu.R6MenuAssignAllButton', ((WinWidth - float(Class'R6Menu.R6MenuAssignAllButton'.default.UpRegion.W)) - float(1)), 0.0000000, float(Class'R6Menu.R6MenuAssignAllButton'.default.UpRegion.W), WinHeight, self));
		m_AssignAll.ToolTipString = Localize("Tip", "GearRoomItemAll", "R6Menu");
		m_AssignAll.ImageX = 0.0000000;
		m_AssignAll.ImageY = ((WinHeight - float(Class'R6Menu.R6MenuAssignAllButton'.default.UpRegion.H)) / float(2));
	}
	m_2DGadget = R6WindowButtonGear(CreateWindow(Class'R6Window.R6WindowButtonGear', 0.0000000, 0.0000000, m_2DGadgetWidth, WinHeight, self));
	m_2DGadget.ToolTipString = Localize("Tip", "GearRoomItem", "R6Menu");
	m_2DGadget.bUseRegion = true;
	m_2DGadget.m_iDrawStyle = 5;
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
	m_2DGadget.Register(W);
	return;
}

function SetGadgetTexture(Texture t, Region R)
{
	m_2DGadget.DisabledTexture = t;
	m_2DGadget.DisabledRegion = R;
	m_2DGadget.DownTexture = t;
	m_2DGadget.DownRegion = R;
	m_2DGadget.OverTexture = t;
	m_2DGadget.OverRegion = R;
	m_2DGadget.UpTexture = t;
	m_2DGadget.UpRegion = R;
	// End:0x120
	if(m_bCenterTexture)
	{
		m_2DGadget.ImageX = ((m_2DGadget.WinWidth - float(m_2DGadget.UpRegion.W)) / float(2));
		m_2DGadget.ImageY = ((m_2DGadget.WinHeight - float(m_2DGadget.UpRegion.H)) / float(2));		
	}
	else
	{
		m_2DGadget.ImageX = m_2DGadget.default.ImageX;
		m_2DGadget.ImageY = m_2DGadget.default.ImageY;
	}
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
	m_2DGadget.bDisabled = _bDisable;
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
	m_2DGadget.ForceMouseOver(_bForceMouseOver);
	return;
}

defaultproperties
{
	m_bAssignAllButton=true
	m_2DGadgetWidth=66.0000000
}
