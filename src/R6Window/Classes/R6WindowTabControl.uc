//=============================================================================
// R6WindowTabControl - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowTabControl.uc : Manage, display tab menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/02 * Created by Yannick Joly
//=============================================================================
class R6WindowTabControl extends UWindowTabControl;

function Created()
{
	super.Created();
	m_bNotDisplayBkg = true;
	return;
}

function GotoTab(UWindowTabControlItem NewSelected, optional bool bByUser)
{
	local float fGlobalX, fGlobalY;

	// End:0x2C
	if(((SelectedTab != NewSelected) && bByUser))
	{
		LookAndFeel.PlayMenuSound(self, 5);
	}
	SelectedTab = NewSelected;
	TabArea.bShowSelected = true;
	Notify(2);
	return;
}

function int GetSelectedTabID()
{
	local UWindowTabControlItem i;

	i = UWindowTabControlItem(Items.Next);
	J0x19:

	// End:0x5E [Loop If]
	if((i != none))
	{
		// End:0x42
		if((i == SelectedTab))
		{
			return i.m_iItemID;
		}
		i = UWindowTabControlItem(i.Next);
		// [Loop Continue]
		goto J0x19;
	}
	return 0;
	return;
}

// why we overwrite tooltip string overhere, to transmit the string to the parent window where the management of
// this string is done
function ToolTip(string strTip)
{
	ParentWindow.ToolTip(strTip);
	return;
}

