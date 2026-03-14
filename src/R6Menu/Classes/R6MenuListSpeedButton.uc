//=============================================================================
// R6MenuListSpeedButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuListSpeedButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6MenuListSpeedButton extends R6MenuPopupListButton;

var bool m_bAutoSelect;

function Created()
{
	super(R6WindowListRadioButton).Created();
	m_FontForButtons = Root.Fonts[12];
	m_fItemHeight = float(R6MenuRSLookAndFeel(LookAndFeel).m_BLTitleL.Up.H);
	m_ButtonItem[int(0)] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuSpeedButtonItem(m_ButtonItem[int(0)]).m_eSpeed = 0;
	m_ButtonItem[int(0)].m_Button = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuPopUpStayDownButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[int(0)].m_Button.SetText(Localize("Order", "Speed_Blitz", "R6Menu"));
	m_ButtonItem[int(0)].m_Button.m_buttonFont = m_FontForButtons;
	m_ButtonItem[int(1)] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuSpeedButtonItem(m_ButtonItem[int(1)]).m_eSpeed = 1;
	m_ButtonItem[int(1)].m_Button = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuPopUpStayDownButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[int(1)].m_Button.SetText(Localize("Order", "Speed_Normal", "R6Menu"));
	m_ButtonItem[int(1)].m_Button.m_buttonFont = m_FontForButtons;
	m_ButtonItem[int(2)] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuSpeedButtonItem(m_ButtonItem[int(2)]).m_eSpeed = 2;
	m_ButtonItem[int(2)].m_Button = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuPopUpStayDownButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[int(2)].m_Button.SetText(Localize("Order", "Speed_Cautious", "R6Menu"));
	m_ButtonItem[int(2)].m_Button.m_buttonFont = m_FontForButtons;
	return;
}

function SetSelectedItem(UWindowListBoxItem NewSelected)
{
	local R6PlanningInfo Planning;

	super(R6WindowListRadioButton).SetSelectedItem(NewSelected);
	// End:0x50
	if(__NFUN_114__(m_SelectedItem, none))
	{
		__NFUN_231__("NoSelected Item in action button menu? that's weird!");
		return;
	}
	Planning = R6PlanningCtrl(GetPlayerOwner()).m_pTeamInfo[R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam];
	// End:0xCB
	if(__NFUN_129__(m_bAutoSelect))
	{
		Planning.SetMovementSpeed(R6MenuSpeedButtonItem(m_SelectedItem).m_eSpeed);
		R6MenuRootWindow(Root).m_PlanningWidget.m_bClosePopup = true;
	}
	return;
}

function ShowWindow()
{
	local Object.EMovementSpeed eSpeed;

	super(UWindowWindow).ShowWindow();
	eSpeed = R6PlanningCtrl(GetPlayerOwner()).m_pTeamInfo[R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam].GetMovementSpeed();
	m_bAutoSelect = true;
	// End:0x71
	if(__NFUN_119__(m_ButtonItem[int(eSpeed)], m_SelectedItem))
	{
		SetSelectedItem(m_ButtonItem[int(eSpeed)]);
	}
	m_bAutoSelect = false;
	return;
}

defaultproperties
{
	m_iNbButton=3
	ListClass=Class'R6Menu.R6MenuSpeedButtonItem'
}
