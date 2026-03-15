//=============================================================================
// R6MenuListActionTypeButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuListActionTypeButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/22 * Created by Chaouky Garram
//=============================================================================
class R6MenuListActionTypeButton extends R6MenuPopupListButton;

var bool m_bAutoSelect;
var R6MenuActionMenu m_WinAction;

function Created()
{
	super(R6WindowListRadioButton).Created();
	m_FontForButtons = Root.Fonts[12];
	m_fItemHeight = float(R6MenuRSLookAndFeel(LookAndFeel).m_BLTitleL.Up.H);
	m_ButtonItem[int(0)] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuActionTypeButtonItem(m_ButtonItem[int(0)]).m_eActionType = 0;
	m_ButtonItem[int(0)].m_Button = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuPopUpStayDownButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[int(0)].m_Button.SetText(Localize("Order", "Type_Normal", "R6Menu"));
	R6MenuPopUpStayDownButton(m_ButtonItem[int(0)].m_Button).m_bSubMenu = true;
	m_ButtonItem[int(0)].m_Button.m_buttonFont = m_FontForButtons;
	m_ButtonItem[int(1)] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuActionTypeButtonItem(m_ButtonItem[int(1)]).m_eActionType = 1;
	m_ButtonItem[int(1)].m_Button = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuPopUpStayDownButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[int(1)].m_Button.SetText(Localize("Order", "Type_Milestone", "R6Menu"));
	R6MenuPopUpStayDownButton(m_ButtonItem[int(1)].m_Button).m_bSubMenu = true;
	m_ButtonItem[int(1)].m_Button.m_buttonFont = m_FontForButtons;
	m_ButtonItem[int(2)] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuActionTypeButtonItem(m_ButtonItem[int(2)]).m_eActionType = 2;
	m_ButtonItem[int(2)].m_Button = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuPopUpStayDownButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[int(2)].m_Button.SetText(Localize("Order", "Type_GoCode_Alpha", "R6Menu"));
	R6MenuPopUpStayDownButton(m_ButtonItem[int(2)].m_Button).m_bSubMenu = true;
	m_ButtonItem[int(2)].m_Button.m_buttonFont = m_FontForButtons;
	m_ButtonItem[int(3)] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuActionTypeButtonItem(m_ButtonItem[int(3)]).m_eActionType = 3;
	m_ButtonItem[int(3)].m_Button = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuPopUpStayDownButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[int(3)].m_Button.SetText(Localize("Order", "Type_GoCode_Bravo", "R6Menu"));
	R6MenuPopUpStayDownButton(m_ButtonItem[int(3)].m_Button).m_bSubMenu = true;
	m_ButtonItem[int(3)].m_Button.m_buttonFont = m_FontForButtons;
	m_ButtonItem[int(4)] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuActionTypeButtonItem(m_ButtonItem[int(4)]).m_eActionType = 4;
	m_ButtonItem[int(4)].m_Button = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuPopUpStayDownButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[int(4)].m_Button.SetText(Localize("Order", "Type_GoCode_Charlie", "R6Menu"));
	R6MenuPopUpStayDownButton(m_ButtonItem[int(4)].m_Button).m_bSubMenu = true;
	m_ButtonItem[int(4)].m_Button.m_buttonFont = m_FontForButtons;
	m_ButtonItem[int(5)] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuActionTypeButtonItem(m_ButtonItem[int(5)]).m_eActionType = 5;
	m_ButtonItem[int(5)].m_Button = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuPopUpStayDownButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[int(5)].m_Button.SetText(Localize("Order", "Type_Delete", "R6Menu"));
	m_ButtonItem[int(5)].m_Button.m_buttonFont = m_FontForButtons;
	return;
}

function SetSelectedItem(UWindowListBoxItem NewSelected)
{
	local R6PlanningInfo Planning;

	Planning = R6PlanningCtrl(GetPlayerOwner()).m_pTeamInfo[R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam];
	HidePopup();
	super(R6WindowListRadioButton).SetSelectedItem(NewSelected);
	// End:0xC3
	if((m_bAutoSelect != true))
	{
		// End:0x9B
		if((int(R6MenuActionTypeButtonItem(m_SelectedItem).m_eActionType) == int(5)))
		{
			Planning.DeleteNode();
			R6MenuRootWindow(Root).m_PlanningWidget.m_bClosePopup = true;			
		}
		else
		{
			Planning.SetActionType(R6MenuActionTypeButtonItem(m_SelectedItem).m_eActionType);
			ShowPopup();
		}
	}
	return;
}

function DisplayMilestoneButton()
{
	local bool bDoIDisplay;

	bDoIDisplay = (R6PlanningCtrl(GetPlayerOwner()).m_pTeamInfo[R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam].m_iNbMilestone < 9);
	R6MenuActionTypeButtonItem(m_ButtonItem[int(1)]).m_Button.bDisabled = (!bDoIDisplay);
	return;
}

function HidePopup()
{
	// End:0x1A
	if((m_WinAction != none))
	{
		m_WinAction.HideWindow();
	}
	return;
}

function ShowWindow()
{
	local Object.EPlanActionType eType;

	eType = R6PlanningCtrl(GetPlayerOwner()).GetCurrentActionType();
	super(UWindowWindow).ShowWindow();
	m_bAutoSelect = true;
	// End:0x53
	if((m_ButtonItem[int(eType)] != m_SelectedItem))
	{
		SetSelectedItem(m_ButtonItem[int(eType)]);
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
	if((m_WinAction == none))
	{
		m_WinAction = R6MenuActionMenu(R6MenuRootWindow(Root).m_PlanningWidget.CreateWindow(Class'R6Menu.R6MenuActionMenu', fGlobalLeft, ParentWindow.WinTop, 150.0000000, 100.0000000, OwnerWindow));		
	}
	else
	{
		m_WinAction.WinLeft = fGlobalLeft;
		m_WinAction.WinTop = ParentWindow.WinTop;
		m_WinAction.ShowWindow();
	}
	R6MenuListActionButton(m_WinAction.m_ButtonList).DisplaySnipeButton((int(R6MenuActionTypeButtonItem(m_SelectedItem).m_eActionType) > int(1)));
	R6MenuListActionButton(m_WinAction.m_ButtonList).DisplayBreachDoor(R6PlanningCtrl(GetPlayerOwner()).GetCurrentPoint().m_bDoorInRange);
	m_WinAction.AjustPosition(R6MenuFramePopup(OwnerWindow).m_bDisplayUp, R6MenuFramePopup(OwnerWindow).m_bDisplayLeft);
	// End:0x1D6
	if((R6MenuFramePopup(ParentWindow).m_bDisplayLeft == true))
	{
		(m_WinAction.WinLeft -= (ParentWindow.WinWidth - float(6)));
	}
	// End:0x21E
	if((R6MenuFramePopup(ParentWindow).m_bDisplayUp == true))
	{
		(m_WinAction.WinTop -= (m_WinAction.WinHeight - ParentWindow.WinHeight));
	}
	return;
}

defaultproperties
{
	m_iNbButton=6
	ListClass=Class'R6Menu.R6MenuActionTypeButtonItem'
}
