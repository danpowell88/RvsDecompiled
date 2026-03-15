//=============================================================================
// R6MenuMPManageTab - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuMPManageTab.uc : Manage Tab for multiplayer menu
//                                         
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/03 * Created by Yannick Joly
//=============================================================================
class R6MenuMPManageTab extends UWindowDialogClientWindow;

var R6WindowTabControl m_pMainTabControl;

function Created()
{
	m_pMainTabControl = R6WindowTabControl(CreateControl(Class'R6Window.R6WindowTabControl', 0.0000000, 0.0000000, WinWidth, WinHeight));
	m_pMainTabControl.SetFont(7);
	LookAndFeel.Size_TabXOffset = 0.0000000;
	LookAndFeel.Size_TabAreaHeight = (WinHeight - LookAndFeel.Size_TabAreaOverhangHeight);
	return;
}

/////////////////////////////////////////////////////////////////
// this method add tab in a list use by UWindowTabControlTabArea
/////////////////////////////////////////////////////////////////
function AddTabInControl(string _Caption, string _TabToolTip, int _ItemID)
{
	local UWindowTabControlItem pItem;

	// End:0x7B
	if((m_pMainTabControl != none))
	{
		pItem = m_pMainTabControl.AddTab(_Caption, _ItemID);
		pItem.HelpText = _TabToolTip;
		pItem.SetItemColor(Root.Colors.White, Root.Colors.GrayLight);
	}
	return;
}

/////////////////////////////////////////////////////////////////
// this method receive a "msg" sent by ? dialogclientwindow or uwindowwindow
/////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
	local R6LanServers pLanServers;
	local R6GSServers pGameService;

	// End:0x67
	if((int(E) == 2))
	{
		// End:0x44
		if((R6MenuMultiPlayerWidget(OwnerWindow) != none))
		{
			R6MenuMultiPlayerWidget(OwnerWindow).ManageTabSelection(m_pMainTabControl.GetSelectedTabID());			
		}
		else
		{
			R6MenuMPCreateGameWidget(OwnerWindow).ManageTabSelection(m_pMainTabControl.GetSelectedTabID());
		}
	}
	// End:0xAF
	if(((int(E) == 6) && C.IsA('R6WindowServerListBox')))
	{
		// End:0xAF
		if((R6MenuMultiPlayerWidget(OwnerWindow) != none))
		{
			R6MenuMultiPlayerWidget(OwnerWindow).DisplayRightClickMenu();
		}
	}
	// End:0xE7
	if(((int(E) == 11) && C.IsA('R6WindowServerListBox')))
	{
		R6MenuMultiPlayerWidget(OwnerWindow).JoinSelectedServerRequested();
	}
	// End:0x12F
	if(((int(E) == 3) && C.IsA('R6WindowRightClickMenu')))
	{
		// End:0x12F
		if((R6MenuMultiPlayerWidget(OwnerWindow) != none))
		{
			R6MenuMultiPlayerWidget(OwnerWindow).UpdateFavorites();
		}
	}
	return;
}

