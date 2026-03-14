//=============================================================================
// R6MenuOptionsControls - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuOptionsControls.uc : For mapping key, this class is specific, work with R6MenuOptionsTab
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/08/13 * Created by Yannick Joly
//============================================================================
class R6MenuOptionsControls extends R6MenuOptionsTab;

// NEW IN 1.60
var int m_iKeyToAssign;
// NEW IN 1.60
var R6WindowListControls m_pListControls;
// NEW IN 1.60
var UWindowListBoxItem m_pCurItem;
// NEW IN 1.60
var R6MenuOptionsMapKeys m_pOptControls;
// NEW IN 1.60
var R6WindowPopUpBox m_pPopUpKeyBG;
// NEW IN 1.60
var R6WindowPopUpBox m_pKeyMenuReAssignPopUp;
// NEW IN 1.60
var string m_szOldActionKey;

// NEW IN 1.60
function InitPageOptions()
{
	local float fXOffset, fYOffset;

	fXOffset = 0.0000000;
	fYOffset = 0.0000000;
	m_pListControls = R6WindowListControls(CreateControl(Class'R6Window.R6WindowListControls', fXOffset, fYOffset, __NFUN_175__(WinWidth, fXOffset), __NFUN_175__(__NFUN_175__(WinHeight, float(14)), fYOffset), self));
	m_pListControls.m_fItemHeight = 15.0000000;
	m_pListControls.m_fXOffSet = 5.0000000;
	CreateKeyPopUp();
	AddTitleItem("", m_pListControls);
	AddTitleItem(Localize("Keys", "Title_Move", "R6Menu"), m_pListControls);
	AddKeyItem(Localize("Keys", "K_MoveForward", "R6Menu"), Localize("Keys", "K_MoveForward", "R6Menu"), "MoveForward", m_pListControls);
	AddKeyItem(Localize("Keys", "K_MoveBackward", "R6Menu"), Localize("Keys", "K_MoveBackward", "R6Menu"), "MoveBackward", m_pListControls);
	AddKeyItem(Localize("Keys", "K_StrafeLeft", "R6Menu"), Localize("Keys", "K_StrafeLeft", "R6Menu"), "StrafeLeft", m_pListControls);
	AddKeyItem(Localize("Keys", "K_StrafeRight", "R6Menu"), Localize("Keys", "K_StrafeRight", "R6Menu"), "StrafeRight", m_pListControls);
	AddKeyItem(Localize("Keys", "K_PeekLeft", "R6Menu"), Localize("Keys", "K_PeekLeft", "R6Menu"), "PeekLeft", m_pListControls);
	AddKeyItem(Localize("Keys", "K_PeekRight", "R6Menu"), Localize("Keys", "K_PeekRight", "R6Menu"), "PeekRight", m_pListControls);
	AddKeyItem(Localize("Keys", "K_RaisePosture", "R6Menu"), Localize("Keys", "K_RaisePosture", "R6Menu"), "RaisePosture", m_pListControls);
	AddKeyItem(Localize("Keys", "K_LowerPosture", "R6Menu"), Localize("Keys", "K_LowerPosture", "R6Menu"), "LowerPosture", m_pListControls);
	AddKeyItem(Localize("Keys", "K_Run", "R6Menu"), Localize("Keys", "K_Run", "R6Menu"), "Run", m_pListControls);
	AddKeyItem(Localize("Keys", "K_FluidPosture", "R6Menu"), Localize("Keys", "K_FluidPosture", "R6Menu"), "FluidPosture", m_pListControls);
	AddLineItem(m_pListControls);
	AddTitleItem(Localize("Keys", "Title_Weapon", "R6Menu"), m_pListControls);
	AddKeyItem(Localize("Keys", "K_Reload", "R6Menu"), Localize("Keys", "K_Reload", "R6Menu"), "Reload", m_pListControls);
	AddKeyItem(Localize("Keys", "K_PrimaryWeapon", "R6Menu"), Localize("Keys", "K_PrimaryWeapon", "R6Menu"), "PrimaryWeapon", m_pListControls);
	AddKeyItem(Localize("Keys", "K_SecondaryWeapon", "R6Menu"), Localize("Keys", "K_SecondaryWeapon", "R6Menu"), "SecondaryWeapon", m_pListControls);
	AddKeyItem(Localize("Keys", "K_GadgetOne", "R6Menu"), Localize("Keys", "K_GadgetOne", "R6Menu"), "GadgetOne", m_pListControls);
	AddKeyItem(Localize("Keys", "K_GadgetTwo", "R6Menu"), Localize("Keys", "K_GadgetTwo", "R6Menu"), "GadgetTwo", m_pListControls);
	AddKeyItem(Localize("Keys", "K_ChangeRateOfFire", "R6Menu"), Localize("Keys", "K_ChangeRateOfFire", "R6Menu"), "ChangeRateOfFire", m_pListControls);
	AddKeyItem(Localize("Keys", "K_PrimaryFire", "R6Menu"), Localize("Keys", "K_PrimaryFire", "R6Menu"), "PrimaryFire", m_pListControls);
	AddKeyItem(Localize("Keys", "K_SecondaryFire", "R6Menu"), Localize("Keys", "K_SecondaryFire", "R6Menu"), "SecondaryFire", m_pListControls);
	AddKeyItem(Localize("Keys", "K_Zoom", "R6Menu"), Localize("Keys", "K_Zoom", "R6Menu"), "Zoom", m_pListControls);
	AddKeyItem(Localize("Keys", "K_InventoryMenu", "R6Menu"), Localize("Keys", "K_InventoryMenu", "R6Menu"), "InventoryMenu", m_pListControls);
	AddLineItem(m_pListControls);
	AddTitleItem(Localize("Keys", "Title_Orders", "R6Menu"), m_pListControls);
	AddKeyItem(Localize("Keys", "K_GoCodeAlpha", "R6Menu"), Localize("Keys", "K_GoCodeAlpha", "R6Menu"), "GoCodeAlpha", m_pListControls);
	AddKeyItem(Localize("Keys", "K_GoCodeBravo", "R6Menu"), Localize("Keys", "K_GoCodeBravo", "R6Menu"), "GoCodeBravo", m_pListControls);
	AddKeyItem(Localize("Keys", "K_GoCodeCharlie", "R6Menu"), Localize("Keys", "K_GoCodeCharlie", "R6Menu"), "GoCodeCharlie", m_pListControls);
	AddKeyItem(Localize("Keys", "K_GoCodeZulu", "R6Menu"), Localize("Keys", "K_GoCodeZulu", "R6Menu"), "GoCodeZulu", m_pListControls);
	AddKeyItem(Localize("Keys", "K_RulesOfEngagement", "R6Menu"), Localize("Keys", "K_RulesOfEngagement", "R6Menu"), "RulesOfEngagement", m_pListControls);
	AddKeyItem(Localize("Keys", "K_SkipDestination", "R6Menu"), Localize("Keys", "K_SkipDestination", "R6Menu"), "SkipDestination", m_pListControls);
	AddKeyItem(Localize("Keys", "K_ToggleAllTeamsHold", "R6Menu"), Localize("Keys", "K_ToggleAllTeamsHold", "R6Menu"), "ToggleAllTeamsHold", m_pListControls);
	AddKeyItem(Localize("Keys", "K_ToggleTeamHold", "R6Menu"), Localize("Keys", "K_ToggleTeamHold", "R6Menu"), "ToggleTeamHold", m_pListControls);
	AddKeyItem(Localize("Keys", "K_ToggleSniperControl", "R6Menu"), Localize("Keys", "K_ToggleSniperControl", "R6Menu"), "ToggleSniperControl", m_pListControls);
	AddLineItem(m_pListControls);
	AddTitleItem(Localize("Keys", "Title_Actions", "R6Menu"), m_pListControls);
	AddKeyItem(Localize("Keys", "K_GraduallyOpenDoor", "R6Menu"), Localize("Keys", "K_GraduallyOpenDoor", "R6Menu"), "GraduallyOpenDoor", m_pListControls);
	AddKeyItem(Localize("Keys", "K_GraduallyCloseDoor", "R6Menu"), Localize("Keys", "K_GraduallyCloseDoor", "R6Menu"), "GraduallyCloseDoor", m_pListControls);
	AddKeyItem(Localize("Keys", "K_SpeedUpDoor", "R6Menu"), Localize("Keys", "K_SpeedUpDoor", "R6Menu"), "SpeedUpDoor", m_pListControls);
	AddKeyItem(Localize("Keys", "K_Action", "R6Menu"), Localize("Keys", "K_Action", "R6Menu"), "Action", m_pListControls);
	AddKeyItem(Localize("Keys", "K_ToggleNightVision", "R6Menu"), Localize("Keys", "K_ToggleNightVision", "R6Menu"), "ToggleNightVision", m_pListControls);
	AddKeyItem(Localize("Keys", "K_NextTeam", "R6Menu"), Localize("Keys", "K_NextTeam", "R6Menu"), "NextTeam", m_pListControls);
	AddKeyItem(Localize("Keys", "K_PreviousTeam", "R6Menu"), Localize("Keys", "K_PreviousTeam", "R6Menu"), "PreviousTeam", m_pListControls);
	AddKeyItem(Localize("Keys", "K_NextMember", "R6Menu"), Localize("Keys", "K_NextMember", "R6Menu"), "NextMember", m_pListControls);
	AddKeyItem(Localize("Keys", "K_PreviousMember", "R6Menu"), Localize("Keys", "K_PreviousMember", "R6Menu"), "PreviousMember", m_pListControls);
	AddKeyItem(Localize("Keys", "K_ToggleMap", "R6Menu"), Localize("Keys", "K_ToggleMap", "R6Menu"), "ToggleMap", m_pListControls);
	AddKeyItem(Localize("Keys", "K_MapZoomIn", "R6Menu"), Localize("Keys", "K_MapZoomIn", "R6Menu"), "MapZoomIn", m_pListControls);
	AddKeyItem(Localize("Keys", "K_MapZoomOut", "R6Menu"), Localize("Keys", "K_MapZoomOut", "R6Menu"), "MapZoomOut", m_pListControls);
	AddKeyItem(Localize("Keys", "K_OperativeSelector", "R6Menu"), Localize("Keys", "K_OperativeSelector", "R6Menu"), "OperativeSelector", m_pListControls);
	AddLineItem(m_pListControls);
	AddTitleItem(Localize("Keys", "Title_MP", "R6Menu"), m_pListControls);
	AddKeyItem(Localize("Keys", "K_ToggleGameStats", "R6Menu"), Localize("Keys", "K_ToggleGameStats", "R6Menu"), "ToggleGameStats", m_pListControls);
	AddKeyItem(Localize("Keys", "K_Talk", "R6Menu"), Localize("Keys", "K_Talk", "R6Menu"), "Talk", m_pListControls);
	AddKeyItem(Localize("Keys", "K_TeamTalk", "R6Menu"), Localize("Keys", "K_TeamTalk", "R6Menu"), "TeamTalk", m_pListControls);
	AddKeyItem(Localize("Keys", "K_DrawingTool", "R6Menu"), Localize("Keys", "K_DrawingTool", "R6Menu"), "DrawingTool", m_pListControls);
	AddKeyItem(Localize("Keys", "K_PreRecMessages", "R6Menu"), Localize("Keys", "K_PreRecMessages", "R6Menu"), "PreRecMessages", m_pListControls);
	AddKeyItem(Localize("Keys", "K_VotingMenu", "R6Menu"), Localize("Keys", "K_VotingMenu", "R6Menu"), "VotingMenu", m_pListControls);
	AddLineItem(m_pListControls);
	AddTitleItem(Localize("Keys", "Title_Others", "R6Menu"), m_pListControls);
	AddKeyItem(Localize("Keys", "K_Console", "R6Menu"), Localize("Keys", "K_Console", "R6Menu"), "Console", m_pListControls);
	AddKeyItem(Localize("Keys", "K_ToggleAutoAim", "R6Menu"), Localize("Keys", "K_ToggleAutoAim", "R6Menu"), "ToggleAutoAim", m_pListControls);
	AddKeyItem(Localize("Keys", "K_Shot", "R6Menu"), Localize("Keys", "K_Shot", "R6Menu"), "Shot", m_pListControls);
	AddKeyItem(Localize("Keys", "K_ShowCompleteHud", "R6Menu"), Localize("Keys", "K_ShowCompleteHud", "R6Menu"), "ShowCompleteHud", m_pListControls);
	AddLineItem(m_pListControls);
	AddTitleItem(Localize("Keys", "Title_Planning", "R6Menu"), m_pListControls);
	AddKeyItem(Localize("Keys", "K_MoveUp", "R6Menu"), Localize("Keys", "K_MoveUp", "R6Menu"), "MoveUp", m_pListControls, true);
	AddKeyItem(Localize("Keys", "K_MoveDown", "R6Menu"), Localize("Keys", "K_MoveDown", "R6Menu"), "MoveDown", m_pListControls, true);
	AddKeyItem(Localize("Keys", "K_MoveLeft", "R6Menu"), Localize("Keys", "K_MoveLeft", "R6Menu"), "MoveLeft", m_pListControls, true);
	AddKeyItem(Localize("Keys", "K_MoveRight", "R6Menu"), Localize("Keys", "K_MoveRight", "R6Menu"), "MoveRight", m_pListControls, true);
	AddKeyItem(Localize("Keys", "K_ZoomIn", "R6Menu"), Localize("Keys", "K_ZoomIn", "R6Menu"), "ZoomIn", m_pListControls, true);
	AddKeyItem(Localize("Keys", "K_ZoomOut", "R6Menu"), Localize("Keys", "K_ZoomOut", "R6Menu"), "ZoomOut", m_pListControls, true);
	AddKeyItem(Localize("Keys", "K_LevelUp", "R6Menu"), Localize("Keys", "K_LevelUp", "R6Menu"), "LevelUp", m_pListControls, true);
	AddKeyItem(Localize("Keys", "K_LevelDown", "R6Menu"), Localize("Keys", "K_LevelDown", "R6Menu"), "LevelDown", m_pListControls, true);
	AddKeyItem(Localize("Keys", "K_RotateClockWise", "R6Menu"), Localize("Keys", "K_RotateClockWise", "R6Menu"), "RotateClockWise", m_pListControls, true);
	AddKeyItem(Localize("Keys", "K_RotateCounterClockWise", "R6Menu"), Localize("Keys", "K_RotateCounterClockWise", "R6Menu"), "RotateCounterClockWise", m_pListControls, true);
	AddKeyItem(Localize("Keys", "K_DeleteWaypoint", "R6Menu"), Localize("Keys", "K_DeleteWaypoint", "R6Menu"), "DeleteWaypoint", m_pListControls, true);
	AddKeyItem(Localize("Keys", "K_NextWaypoint", "R6Menu"), Localize("Keys", "K_NextWaypoint", "R6Menu"), "NextWaypoint", m_pListControls, true);
	AddKeyItem(Localize("Keys", "K_PrevWaypoint", "R6Menu"), Localize("Keys", "K_PrevWaypoint", "R6Menu"), "PrevWaypoint", m_pListControls, true);
	AddKeyItem(Localize("Keys", "K_FirstWaypoint", "R6Menu"), Localize("Keys", "K_FirstWaypoint", "R6Menu"), "FirstWaypoint", m_pListControls, true);
	AddKeyItem(Localize("Keys", "K_LastWaypoint", "R6Menu"), Localize("Keys", "K_LastWaypoint", "R6Menu"), "LastWaypoint", m_pListControls, true);
	AddKeyItem(Localize("Keys", "K_AngleUp", "R6Menu"), Localize("Keys", "K_AngleUp", "R6Menu"), "AngleUp", m_pListControls, true);
	AddKeyItem(Localize("Keys", "K_AngleDown", "R6Menu"), Localize("Keys", "K_AngleDown", "R6Menu"), "AngleDown", m_pListControls, true);
	AddKeyItem(Localize("Keys", "K_RedTeam", "R6Menu"), Localize("Keys", "K_RedTeam", "R6Menu"), "SwitchToRedTeam", m_pListControls, true);
	AddKeyItem(Localize("Keys", "K_GreenTeam", "R6Menu"), Localize("Keys", "K_GreenTeam", "R6Menu"), "SwitchToGreenTeam", m_pListControls, true);
	AddKeyItem(Localize("Keys", "K_GoldTeam", "R6Menu"), Localize("Keys", "K_GoldTeam", "R6Menu"), "SwitchToGoldTeam", m_pListControls, true);
	AddKeyItem(Localize("Keys", "K_ViewRed", "R6Menu"), Localize("Keys", "K_ViewRed", "R6Menu"), "ViewRedTeam", m_pListControls, true);
	AddKeyItem(Localize("Keys", "K_ViewGreen", "R6Menu"), Localize("Keys", "K_ViewGreen", "R6Menu"), "ViewGreenTeam", m_pListControls, true);
	AddKeyItem(Localize("Keys", "K_ViewGold", "R6Menu"), Localize("Keys", "K_ViewGold", "R6Menu"), "ViewGoldTeam", m_pListControls, true);
	InitResetButton();
	m_bInitComplete = true;
	return;
}

// NEW IN 1.60
function AddLineItem(R6WindowListControls _pR6WindowListControls)
{
	local UWindowListBoxItem NewItem;

	NewItem = UWindowListBoxItem(_pR6WindowListControls.Items.Append(_pR6WindowListControls.ListClass));
	NewItem.HelpText = "";
	NewItem.m_bImALine = true;
	NewItem.m_vItemColor = Root.Colors.White;
	NewItem.m_bNotAffectByNotify = true;
	return;
}

// NEW IN 1.60
function AddTitleItem(string _szTitle, R6WindowListControls _pR6WindowListControls)
{
	local UWindowListBoxItem NewItem;

	NewItem = UWindowListBoxItem(_pR6WindowListControls.Items.Append(_pR6WindowListControls.ListClass));
	NewItem.HelpText = _szTitle;
	NewItem.m_vItemColor = Root.Colors.White;
	NewItem.m_bNotAffectByNotify = true;
	return;
}

// NEW IN 1.60
function AddKeyItem(string _szTitle, string _szToolTip, string _szActionKey, R6WindowListControls _pR6WindowListControls, optional bool _bPlanningInput)
{
	local UWindowListBoxItem NewItem;

	NewItem = UWindowListBoxItem(_pR6WindowListControls.Items.Append(_pR6WindowListControls.ListClass));
	NewItem.HelpText = _szTitle;
	NewItem.m_szToolTip = _szToolTip;
	NewItem.m_vItemColor = Root.Colors.White;
	NewItem.m_szActionKey = _szActionKey;
	NewItem.m_szFakeEditBoxValue = GetLocKeyNameByActionKey(_szActionKey, _bPlanningInput);
	NewItem.m_fXFakeEditBox = 220.0000000;
	NewItem.m_fWFakeEditBox = __NFUN_175__(__NFUN_175__(WinWidth, NewItem.m_fXFakeEditBox), float(40));
	// End:0x10D
	if(_bPlanningInput)
	{
		NewItem.m_iItemID = 1;		
	}
	else
	{
		NewItem.m_iItemID = 0;
	}
	return;
}

// NEW IN 1.60
function UpdateOptionsInPage()
{
	local UWindowList ListItem;
	local string szTemp;

	ListItem = m_pListControls.Items.Next;
	J0x1D:

	// End:0xD0 [Loop If]
	if(__NFUN_119__(ListItem, none))
	{
		// End:0xB9
		if(__NFUN_129__(UWindowListBoxItem(ListItem).m_bNotAffectByNotify))
		{
			// End:0x8B
			if(__NFUN_154__(UWindowListBoxItem(ListItem).m_iItemID, 0))
			{
				UWindowListBoxItem(ListItem).m_szFakeEditBoxValue = GetLocKeyNameByActionKey(UWindowListBoxItem(ListItem).m_szActionKey, false);				
			}
			else
			{
				UWindowListBoxItem(ListItem).m_szFakeEditBoxValue = GetLocKeyNameByActionKey(UWindowListBoxItem(ListItem).m_szActionKey, true);
			}
		}
		ListItem = ListItem.Next;
		// [Loop Continue]
		goto J0x1D;
	}
	return;
}

// NEW IN 1.60
function string GetLocKeyNameByActionKey(string _szActionKey, optional bool _bPlanningInput)
{
	local string szTemp;
	local byte Key;

	Key = GetPlayerOwner().__NFUN_2706__(_szActionKey, _bPlanningInput);
	szTemp = GetPlayerOwner().__NFUN_2708__(Key, _bPlanningInput);
	szTemp = GetPlayerOwner().Player.Console.ConvertKeyToLocalisation(Key, szTemp);
	return szTemp;
	return;
}

// NEW IN 1.60
function CreateKeyPopUp()
{
	local R6WindowTextLabelExt pR6TextLabelExt;
	local float fPopUpWidth;

	fPopUpWidth = 380.0000000;
	m_pPopUpKeyBG = R6WindowPopUpBox(OwnerWindow.CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, OwnerWindow.WinWidth, OwnerWindow.WinHeight, self));
	m_pPopUpKeyBG.CreatePopUpFrameWindow(Localize("Options", "Opt_ControlsMapKey", "R6Menu"), 30.0000000, 130.0000000, 150.0000000, fPopUpWidth, 70.0000000);
	m_pPopUpKeyBG.CreateClientWindow(Class'R6Window.R6WindowTextLabelExt');
	m_pPopUpKeyBG.m_bForceButtonLine = true;
	pR6TextLabelExt = R6WindowTextLabelExt(m_pPopUpKeyBG.m_ClientArea);
	pR6TextLabelExt.SetNoBorder();
	pR6TextLabelExt.m_Font = Root.Fonts[5];
	pR6TextLabelExt.m_vTextColor = Root.Colors.White;
	pR6TextLabelExt.AddTextLabel("", 0.0000000, 3.0000000, fPopUpWidth, 2, false);
	pR6TextLabelExt.AddTextLabel("", 0.0000000, 15.0000000, fPopUpWidth, 2, false);
	pR6TextLabelExt.AddTextLabel(Localize("Options", "Key_Map", "R6Menu"), 0.0000000, 27.0000000, fPopUpWidth, 2, false);
	m_pPopUpKeyBG.Close();
	m_pKeyMenuReAssignPopUp = R6WindowPopUpBox(OwnerWindow.CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, OwnerWindow.WinWidth, OwnerWindow.WinHeight, self));
	m_pKeyMenuReAssignPopUp.CreatePopUpFrameWindow(Localize("Options", "Opt_ControlsReMapKey", "R6Menu"), 30.0000000, 140.0000000, 150.0000000, fPopUpWidth, 70.0000000);
	m_pKeyMenuReAssignPopUp.CreateClientWindow(Class'R6Window.R6WindowTextLabelExt');
	m_pKeyMenuReAssignPopUp.m_bForceButtonLine = true;
	pR6TextLabelExt = R6WindowTextLabelExt(m_pKeyMenuReAssignPopUp.m_ClientArea);
	pR6TextLabelExt.SetNoBorder();
	pR6TextLabelExt.m_Font = Root.Fonts[5];
	pR6TextLabelExt.m_vTextColor = Root.Colors.White;
	pR6TextLabelExt.AddTextLabel("", 0.0000000, 3.0000000, fPopUpWidth, 2, false);
	pR6TextLabelExt.AddTextLabel(Localize("Options", "Key_Press", "R6Menu"), 0.0000000, 27.0000000, fPopUpWidth, 2, false);
	m_pKeyMenuReAssignPopUp.Close();
	return;
}

// NEW IN 1.60
function ManagePopUpKey(UWindowDialogControl C)
{
	local R6WindowTextLabelExt pR6TextLabelExt;

	m_pCurItem = R6WindowListControls(C).GetSelectedItem();
	// End:0x1A1
	if(__NFUN_129__(m_pCurItem.m_bNotAffectByNotify))
	{
		pR6TextLabelExt = R6WindowTextLabelExt(m_pPopUpKeyBG.m_ClientArea);
		// End:0xDD
		if(__NFUN_122__(GetCurKeyName(), ""))
		{
			pR6TextLabelExt.ChangeTextLabel(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(m_pCurItem.HelpText, " "), Localize("Options", "Key_Advice", "R6Menu")), " "), Localize("Options", "Key_Nothing", "R6Menu")), 0);
			pR6TextLabelExt.ChangeTextLabel(" ", 1);			
		}
		else
		{
			pR6TextLabelExt.ChangeTextLabel(__NFUN_112__(__NFUN_112__(m_pCurItem.HelpText, " "), Localize("Options", "Key_Advice", "R6Menu")), 0);
			pR6TextLabelExt.ChangeTextLabel(GetCurKeyName(), 1);
		}
		m_pPopUpKeyBG.ShowWindow();
		m_pOptControls = R6MenuOptionsMapKeys(OwnerWindow.CreateWindow(Class'R6Menu.R6MenuOptionsMapKeys', 0.0000000, 0.0000000, OwnerWindow.WinWidth, OwnerWindow.WinHeight, self, true));
		m_pOptControls.Register(self);
	}
	return;
}

// NEW IN 1.60
function CloseAllKeyPopUp(optional bool _bCloseKeyControlTo)
{
	// End:0x24
	if(m_pPopUpKeyBG.bWindowVisible)
	{
		m_pPopUpKeyBG.Close();		
	}
	else
	{
		// End:0x45
		if(m_pKeyMenuReAssignPopUp.bWindowVisible)
		{
			m_pKeyMenuReAssignPopUp.Close();
		}
	}
	// End:0x5D
	if(_bCloseKeyControlTo)
	{
		m_pOptControls.HideWindow();
	}
	return;
}

// NEW IN 1.60
function UWindowListBoxItem GetCurrentKeyItem()
{
	return m_pCurItem;
	return;
}

// NEW IN 1.60
function string GetCurActionKey()
{
	return GetCurrentKeyItem().m_szActionKey;
	return;
}

// NEW IN 1.60
function string GetCurKeyName()
{
	return GetCurrentKeyItem().m_szFakeEditBoxValue;
	return;
}

// NEW IN 1.60
function int GetCurKeyInputClass()
{
	return GetCurrentKeyItem().m_iItemID;
	return;
}

// NEW IN 1.60
function RefreshKeyItem(string _szNewKeyValue)
{
	local UWindowListBoxItem pItem;

	pItem = m_pListControls.GetSelectedItem();
	// End:0x34
	if(__NFUN_119__(pItem, none))
	{
		pItem.m_szFakeEditBoxValue = _szNewKeyValue;
	}
	return;
}

// NEW IN 1.60
function KeyPressed(int Key)
{
	local R6WindowTextLabelExt pR6TextLabelExt;
	local string szTemp, szKeyName;
	local bool bUpdate, bPlanningInput;

	// End:0x14
	if(__NFUN_154__(GetCurKeyInputClass(), 1))
	{
		bPlanningInput = true;
	}
	// End:0x2E
	if(__NFUN_155__(m_iKeyToAssign, -1))
	{
		bUpdate = true;		
	}
	else
	{
		// End:0xAC
		if(__NFUN_129__(IsKeyValid(Key)))
		{
			CloseAllKeyPopUp(true);
			Root.SimplePopUp(Localize("Options", "Key_Invalid_Title", "R6Menu"), Localize("Options", "Key_Invalid", "R6Menu"), 0, int(2), false, self);
			return;
		}
		m_szOldActionKey = GetPlayerOwner().__NFUN_2707__(byte(Key), bPlanningInput);
		szTemp = Localize("Keys", __NFUN_112__("K_", m_szOldActionKey), "R6Menu", true);
		m_iKeyToAssign = Key;
		// End:0x1FF
		if(__NFUN_130__(__NFUN_123__(m_szOldActionKey, ""), __NFUN_123__(szTemp, "")))
		{
			szKeyName = GetPlayerOwner().Player.Console.ConvertKeyToLocalisation(byte(m_iKeyToAssign), GetPlayerOwner().__NFUN_2708__(byte(m_iKeyToAssign), bPlanningInput));
			pR6TextLabelExt = R6WindowTextLabelExt(m_pKeyMenuReAssignPopUp.m_ClientArea);
			pR6TextLabelExt.ChangeTextLabel(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(szKeyName, " "), Localize("Options", "Key_Assign", "R6Menu")), " "), Localize("Keys", __NFUN_112__("K_", m_szOldActionKey), "R6Menu")), 0);
			m_pKeyMenuReAssignPopUp.ShowWindow();
			m_pOptControls.ShowWindow();			
		}
		else
		{
			bUpdate = true;
		}
	}
	// End:0x295
	if(bUpdate)
	{
		szTemp = "INPUT";
		// End:0x23B
		if(bPlanningInput)
		{
			szTemp = "INPUTPLANNING";
		}
		szKeyName = GetPlayerOwner().__NFUN_2708__(byte(m_iKeyToAssign), bPlanningInput);
		GetPlayerOwner().__NFUN_2710__(__NFUN_168__(__NFUN_168__(szTemp, szKeyName), GetCurActionKey()));
		UpdateOptionsInPage();
		m_szOldActionKey = "";
		m_iKeyToAssign = -1;
	}
	return;
}

// NEW IN 1.60
function bool IsKeyValid(int _Key)
{
	local bool bValidKey;

	bValidKey = true;
	switch(_Key)
	{
		// End:0x28
		case int(Root.Console.91):
		// End:0x41
		case int(Root.Console.92):
		// End:0x65
		case int(Root.Console.93):
			bValidKey = false;
			// End:0x2AE
			break;
		// End:0xA9
		case int(Root.Console.1):
			// End:0xA6
			if(__NFUN_155__(GetCurKeyInputClass(), 1))
			{
				// End:0xA6
				if(__NFUN_122__(GetCurActionKey(), "Console"))
				{
					bValidKey = false;
				}
			}
			// End:0x2AE
			break;
		// End:0xC2
		case int(Root.Console.237):
		// End:0x2A0
		case int(Root.Console.236):
			// End:0x1AD
			if(__NFUN_154__(GetCurKeyInputClass(), 1))
			{
				switch(GetCurActionKey())
				{
					// End:0xFA
					case "MoveUp":
					// End:0x107
					case "MoveDown":
					// End:0x114
					case "MoveLeft":
					// End:0x122
					case "MoveRight":
					// End:0x12D
					case "ZoomIn":
					// End:0x139
					case "ZoomOut":
					// End:0x145
					case "LevelUp":
					// End:0x153
					case "LevelDown":
					// End:0x167
					case "RotateClockWise":
					// End:0x182
					case "RotateCounterClockWise":
					// End:0x18E
					case "AngleUp":
					// End:0x1A7
					case "AngleDown":
						bValidKey = false;
						// End:0x1AA
						break;
					// End:0xFFFF
					default:
						break;
				}				
			}
			else
			{
				switch(GetCurActionKey())
				{
					// End:0x1C5
					case "PrimaryFire":
					// End:0x1D7
					case "SecondaryFire":
					// End:0x1E2
					case "Reload":
					// End:0x1EA
					case "Run":
					// End:0x1FA
					case "SpeedUpDoor":
					// End:0x20B
					case "FluidPosture":
					// End:0x218
					case "PeekLeft":
					// End:0x226
					case "PeekRight":
					// End:0x236
					case "MoveForward":
					// End:0x245
					case "RunForward":
					// End:0x256
					case "MoveBackward":
					// End:0x265
					case "StrafeLeft":
					// End:0x275
					case "StrafeRight":
					// End:0x282
					case "TurningX":
					// End:0x29A
					case "TurningY":
						bValidKey = false;
						// End:0x29D
						break;
					// End:0xFFFF
					default:
						break;
				}
			}
			// End:0x2AE
			break;
		// End:0xFFFF
		default:
			bValidKey = true;
			// End:0x2AE
			break;
			break;
	}
	return bValidKey;
	return;
}

// NEW IN 1.60
function RestoreDefaultValue()
{
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.__NFUN_1009__();
	GetPlayerOwner().__NFUN_544__();
	UpdateOptionsInPage();
	return;
}

// NEW IN 1.60
function Notify(UWindowDialogControl C, byte E)
{
	local R6MenuOptionsWidget OptionsWidget;
	local bool bUpdateGameOptions;
	local R6GameOptions pGameOptions;

	pGameOptions = Class'Engine.Actor'.static.__NFUN_1009__();
	OptionsWidget = R6MenuOptionsWidget(OwnerWindow);
	// End:0x175
	if(__NFUN_154__(int(E), 2))
	{
		// End:0xE3
		if(C.__NFUN_303__('R6WindowButton'))
		{
			// End:0xCE
			if(__NFUN_114__(C, m_pGeneralButUse))
			{
				// End:0xCB
				if(__NFUN_114__(C, m_pGeneralButUse))
				{
					Root.SimplePopUp(Localize("Options", "ResetToDefault", "R6Menu"), Localize("Options", "ResetToDefaultConfirm", "R6Menu"), 55, 0, false, self);
				}				
			}
			else
			{
				m_iKeyToAssign = -1;
				CloseAllKeyPopUp(true);
			}			
		}
		else
		{
			// End:0x105
			if(C.__NFUN_303__('R6WindowListControls'))
			{
				ManagePopUpKey(C);				
			}
			else
			{
				// End:0x175
				if(C.__NFUN_303__('R6MenuOptionsMapKeys'))
				{
					CloseAllKeyPopUp(true);
					// End:0x161
					if(__NFUN_154__(m_pOptControls.m_iLastKeyPressed, int(GetPlayerOwner().Player.Console.27)))
					{
						m_iKeyToAssign = -1;						
					}
					else
					{
						KeyPressed(m_pOptControls.m_iLastKeyPressed);
					}
				}
			}
		}
	}
	return;
}

defaultproperties
{
	m_iKeyToAssign=-1
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_pCancelButton
// REMOVED IN 1.60: var m_iLastKeyPressed
// REMOVED IN 1.60: function Created
// REMOVED IN 1.60: function Register
// REMOVED IN 1.60: function ShowWindow
// REMOVED IN 1.60: function HideWindow
// REMOVED IN 1.60: function KeyDown
// REMOVED IN 1.60: function LMouseDown
// REMOVED IN 1.60: function MMouseDown
// REMOVED IN 1.60: function RMouseDown
// REMOVED IN 1.60: function MouseWheelDown
// REMOVED IN 1.60: function MouseWheelUp
