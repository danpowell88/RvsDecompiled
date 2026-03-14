//=============================================================================
// R6MenuListActionButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuListActionButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6MenuListActionButton extends R6MenuPopupListButton;

var bool m_bAutoSelect;

function Created()
{
	super(R6WindowListRadioButton).Created();
	m_FontForButtons = Root.Fonts[12];
	m_fItemHeight = float(R6MenuRSLookAndFeel(LookAndFeel).m_BLTitleL.Up.H);
	m_ButtonItem[int(0)] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuActionButtonItem(m_ButtonItem[int(0)]).m_eAction = 0;
	m_ButtonItem[int(0)].m_Button = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuPopUpStayDownButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[int(0)].m_Button.SetText(Localize("Order", "Action_None", "R6Menu"));
	m_ButtonItem[int(0)].m_Button.m_buttonFont = m_FontForButtons;
	m_ButtonItem[int(1)] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuActionButtonItem(m_ButtonItem[int(1)]).m_eAction = 1;
	m_ButtonItem[int(1)].m_Button = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuPopUpStayDownButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[int(1)].m_Button.SetText(Localize("Order", "Action_FragRoom", "R6Menu"));
	m_ButtonItem[int(1)].m_Button.m_buttonFont = m_FontForButtons;
	m_ButtonItem[int(2)] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuActionButtonItem(m_ButtonItem[int(2)]).m_eAction = 2;
	m_ButtonItem[int(2)].m_Button = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuPopUpStayDownButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[int(2)].m_Button.SetText(Localize("Order", "Action_FlashRoom", "R6Menu"));
	m_ButtonItem[int(2)].m_Button.m_buttonFont = m_FontForButtons;
	m_ButtonItem[int(3)] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuActionButtonItem(m_ButtonItem[int(3)]).m_eAction = 3;
	m_ButtonItem[int(3)].m_Button = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuPopUpStayDownButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[int(3)].m_Button.SetText(Localize("Order", "Action_Gas", "R6Menu"));
	m_ButtonItem[int(3)].m_Button.m_buttonFont = m_FontForButtons;
	m_ButtonItem[int(4)] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuActionButtonItem(m_ButtonItem[int(4)]).m_eAction = 4;
	m_ButtonItem[int(4)].m_Button = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuPopUpStayDownButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[int(4)].m_Button.SetText(Localize("Order", "Action_Smoke", "R6Menu"));
	m_ButtonItem[int(4)].m_Button.m_buttonFont = m_FontForButtons;
	m_ButtonItem[int(5)] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuActionButtonItem(m_ButtonItem[int(5)]).m_eAction = 5;
	m_ButtonItem[int(5)].m_Button = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuPopUpStayDownButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[int(5)].m_Button.SetText(Localize("Order", "Action_Snipe", "R6Menu"));
	R6MenuActionButtonItem(m_ButtonItem[int(5)]).m_Button.bDisabled = true;
	m_ButtonItem[int(5)].m_Button.m_buttonFont = m_FontForButtons;
	m_ButtonItem[int(6)] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuActionButtonItem(m_ButtonItem[int(6)]).m_eAction = 6;
	m_ButtonItem[int(6)].m_Button = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuPopUpStayDownButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[int(6)].m_Button.SetText(Localize("Order", "Action_BreachDoor", "R6Menu"));
	R6MenuActionButtonItem(m_ButtonItem[int(6)]).m_Button.bDisabled = true;
	m_ButtonItem[int(6)].m_Button.m_buttonFont = m_FontForButtons;
	return;
}

function SetSelectedItem(UWindowListBoxItem NewSelected)
{
	local R6PlanningInfo Planning;
	local R6PlanningCtrl OwnerCtrl;
	local R6MenuActionButtonItem SelectedItem;

	super(R6WindowListRadioButton).SetSelectedItem(NewSelected);
	OwnerCtrl = R6PlanningCtrl(GetPlayerOwner());
	SelectedItem = R6MenuActionButtonItem(m_SelectedItem);
	// End:0x71
	if(__NFUN_114__(m_SelectedItem, none))
	{
		__NFUN_231__("NoSelected Item in action button menu? that's weird!");
		return;
	}
	Planning = OwnerCtrl.m_pTeamInfo[OwnerCtrl.m_iCurrentTeam];
	// End:0x1BD
	if(__NFUN_129__(m_bAutoSelect))
	{
		Planning.SetCurrentPointAction(SelectedItem.m_eAction);
		// End:0x15E
		if(__NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_154__(int(SelectedItem.m_eAction), int(1)), __NFUN_154__(int(SelectedItem.m_eAction), int(2))), __NFUN_154__(int(SelectedItem.m_eAction), int(3))), __NFUN_154__(int(SelectedItem.m_eAction), int(4))))
		{
			OwnerCtrl.m_bClickToFindLocation = true;
			OwnerCtrl.m_bClickedOnRange = false;
			R6MenuRootWindow(Root).m_bUseAimIcon = true;
		}
		// End:0x19E
		if(__NFUN_154__(int(SelectedItem.m_eAction), int(5)))
		{
			OwnerCtrl.m_bSetSnipeDirection = true;
			R6MenuRootWindow(Root).m_bUseAimIcon = true;
		}
		R6MenuRootWindow(Root).m_PlanningWidget.m_bClosePopup = true;
	}
	return;
}

function DisplaySnipeButton(bool bDoIDisplay)
{
	R6MenuActionButtonItem(m_ButtonItem[int(5)]).m_Button.bDisabled = __NFUN_129__(bDoIDisplay);
	return;
}

function DisplayBreachDoor(bool bDoIDisplay)
{
	R6MenuActionButtonItem(m_ButtonItem[int(6)]).m_Button.bDisabled = __NFUN_129__(bDoIDisplay);
	return;
}

function ShowWindow()
{
	local Object.EPlanAction eAction;

	super(UWindowWindow).ShowWindow();
	eAction = R6PlanningCtrl(GetPlayerOwner()).m_pTeamInfo[R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam].GetAction();
	m_bAutoSelect = true;
	// End:0x71
	if(__NFUN_119__(m_ButtonItem[int(eAction)], m_SelectedItem))
	{
		SetSelectedItem(m_ButtonItem[int(eAction)]);
	}
	m_bAutoSelect = false;
	return;
}

defaultproperties
{
	m_iNbButton=7
	ListClass=Class'R6Menu.R6MenuActionButtonItem'
}
