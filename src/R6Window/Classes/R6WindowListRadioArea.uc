//=============================================================================
// R6WindowListRadioArea - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6WindowListRadioArea.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowListRadioArea extends R6WindowTextListRadio;

var Class<R6WindowArea> AreaClass;

function Paint(Canvas C, float fMouseX, float fMouseY)
{
	local float Y;
	local UWindowList CurItem;

	CurItem = Items.Next;
	CurItem = Items.Next;
	J0x28:

	// End:0x80 [Loop If]
	if((CurItem != none))
	{
		DrawItem(C, CurItem, 0.0000000, Y, WinWidth, m_fItemHeight);
		Y = (Y + m_fItemHeight);
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0x28;
	}
	return;
}

//**************************
function SetSelectedItem(UWindowListBoxItem NewSelected)
{
	local UWindowListBoxItem CurSelected;

	CurSelected = m_SelectedItem;
	// End:0x35
	if((m_SelectedItem != none))
	{
		R6WindowListAreaItem(m_SelectedItem).m_Area.m_bSelected = false;
	}
	// End:0x9C
	if(((NewSelected != none) && (m_SelectedItem != NewSelected)))
	{
		// End:0x6D
		if((m_SelectedItem != none))
		{
			m_SelectedItem.bSelected = false;
		}
		m_SelectedItem = NewSelected;
		// End:0x94
		if((m_SelectedItem != none))
		{
			m_SelectedItem.bSelected = true;
		}
		Notify(2);
	}
	// End:0xC6
	if((m_SelectedItem != none))
	{
		R6WindowListAreaItem(m_SelectedItem).m_Area.m_bSelected = true;
	}
	return;
}

function SetDefaultButton(UWindowList Item)
{
	// End:0x26
	if((Item != none))
	{
		// End:0x26
		if((m_SelectedItem == none))
		{
			SetSelectedItem(UWindowListBoxItem(Item));
		}
	}
	return;
}

defaultproperties
{
	m_fItemHeight=50.0000000
	ListClass=Class'R6Window.R6WindowListAreaItem'
}
