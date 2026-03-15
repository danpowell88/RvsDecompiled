//=============================================================================
// R6MenuListModeButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuListModeButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6MenuListModeButton extends R6MenuPopupListButton;

var bool m_bAutoSelect;
var R6MenuSpeedMenu m_WinSpeed;

function Created()
{
	super(R6WindowListRadioButton).Created();
	m_FontForButtons = Root.Fonts[12];
	m_fItemHeight = float(R6MenuRSLookAndFeel(LookAndFeel).m_BLTitleL.Up.H);
	m_ButtonItem[int(0)] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuModeButtonItem(m_ButtonItem[int(0)]).m_eMode = 0;
	m_ButtonItem[int(0)].m_Button = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuPopUpStayDownButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[int(0)].m_Button.SetText(Localize("Order", "Mode_Assault", "R6Menu"));
	R6MenuPopUpStayDownButton(m_ButtonItem[int(0)].m_Button).m_bSubMenu = true;
	m_ButtonItem[int(0)].m_Button.m_buttonFont = m_FontForButtons;
	m_ButtonItem[int(1)] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuModeButtonItem(m_ButtonItem[int(1)]).m_eMode = 1;
	m_ButtonItem[int(1)].m_Button = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuPopUpStayDownButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[int(1)].m_Button.SetText(Localize("Order", "Mode_Infiltrate", "R6Menu"));
	R6MenuPopUpStayDownButton(m_ButtonItem[int(1)].m_Button).m_bSubMenu = true;
	m_ButtonItem[int(1)].m_Button.m_buttonFont = m_FontForButtons;
	m_ButtonItem[int(2)] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuModeButtonItem(m_ButtonItem[int(2)]).m_eMode = 2;
	m_ButtonItem[int(2)].m_Button = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuPopUpStayDownButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[int(2)].m_Button.SetText(Localize("Order", "Mode_Recon", "R6Menu"));
	R6MenuPopUpStayDownButton(m_ButtonItem[int(2)].m_Button).m_bSubMenu = true;
	m_ButtonItem[int(2)].m_Button.m_buttonFont = m_FontForButtons;
	return;
}

function SetSelectedItem(UWindowListBoxItem NewSelected)
{
	local R6PlanningInfo Planning;

	Planning = R6PlanningCtrl(GetPlayerOwner()).m_pTeamInfo[R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam];
	HidePopup();
	super(R6WindowListRadioButton).SetSelectedItem(NewSelected);
	// End:0x74
	if((m_bAutoSelect != true))
	{
		Planning.SetMovementMode(R6MenuModeButtonItem(m_SelectedItem).m_eMode);
		ShowPopup();
	}
	return;
}

function HidePopup()
{
	// End:0x1A
	if((m_WinSpeed != none))
	{
		m_WinSpeed.HideWindow();
	}
	return;
}

function ShowWindow()
{
	local Object.EMovementMode eMode;

	eMode = R6PlanningCtrl(GetPlayerOwner()).GetMovementMode();
	super(UWindowWindow).ShowWindow();
	m_bAutoSelect = true;
	// End:0x53
	if((m_ButtonItem[int(eMode)] != m_SelectedItem))
	{
		SetSelectedItem(m_ButtonItem[int(eMode)]);
	}
	m_bAutoSelect = false;
	return;
}

function ShowPopup()
{
	local float fGlobalLeft, fGlobalTop;

	WindowToGlobal(ParentWindow.WinLeft, ParentWindow.WinTop, fGlobalLeft, fGlobalTop);
	fGlobalLeft = (ParentWindow.WinLeft + ParentWindow.WinWidth);
	// End:0xAD
	if((m_WinSpeed == none))
	{
		m_WinSpeed = R6MenuSpeedMenu(R6MenuRootWindow(Root).m_PlanningWidget.CreateWindow(Class'R6Menu.R6MenuSpeedMenu', fGlobalLeft, ParentWindow.WinTop, 150.0000000, 100.0000000, OwnerWindow));		
	}
	else
	{
		m_WinSpeed.WinLeft = fGlobalLeft;
		m_WinSpeed.WinTop = ParentWindow.WinTop;
		m_WinSpeed.ShowWindow();
	}
	m_WinSpeed.AjustPosition(R6MenuFramePopup(OwnerWindow).m_bDisplayUp, R6MenuFramePopup(OwnerWindow).m_bDisplayLeft);
	// End:0x162
	if((R6MenuFramePopup(ParentWindow).m_bDisplayLeft == true))
	{
		(m_WinSpeed.WinLeft -= (ParentWindow.WinWidth - float(6)));
	}
	// End:0x1AA
	if((R6MenuFramePopup(ParentWindow).m_bDisplayUp == true))
	{
		(m_WinSpeed.WinTop -= (m_WinSpeed.WinHeight - ParentWindow.WinHeight));
	}
	return;
}

defaultproperties
{
	m_iNbButton=3
	ListClass=Class'R6Menu.R6MenuModeButtonItem'
}
