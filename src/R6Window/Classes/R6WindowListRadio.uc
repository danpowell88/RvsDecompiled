//=============================================================================
// R6WindowListRadio - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowListRadio.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowListRadio extends UWindowListControl;

var float m_fItemHeight;
var UWindowListBoxItem m_SelectedItem;
var R6WindowListRadio m_DoubleClickList;  // list to send items to on double-click
var string m_szDefaultHelpText;

function BeforePaint(Canvas C, float fMouseX, float fMouseY)
{
	local UWindowListBoxItem OverItem;
	local string szNewHelpText;

	szNewHelpText = m_szDefaultHelpText;
	// End:0x66
	if((m_SelectedItem != none))
	{
		OverItem = GetItemAt(fMouseX, fMouseY);
		// End:0x66
		if(((OverItem == m_SelectedItem) && (OverItem.HelpText != "")))
		{
			szNewHelpText = OverItem.HelpText;
		}
	}
	// End:0x88
	if((szNewHelpText != HelpText))
	{
		HelpText = szNewHelpText;
		Notify(13);
	}
	return;
}

function SetHelpText(string t)
{
	super(UWindowDialogControl).SetHelpText(t);
	m_szDefaultHelpText = t;
	return;
}

function Sort()
{
	Items.Sort();
	return;
}

function Paint(Canvas C, float fMouseX, float fMouseY)
{
	local float Y;
	local UWindowList CurItem;
	local int i;

	CurItem = Items.Next;
	Y = 0.0000000;
	J0x1F:

	// End:0x9A [Loop If]
	if(((Y < WinHeight) && (CurItem != none)))
	{
		// End:0x83
		if(CurItem.ShowThisItem())
		{
			DrawItem(C, CurItem, 0.0000000, Y, WinWidth, m_fItemHeight);
			Y = (Y + m_fItemHeight);
		}
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0x1F;
	}
	return;
}

function UWindowListBoxItem GetItemAt(float fMouseX, float fMouseY)
{
	local float Y;
	local UWindowList CurItem;
	local int i;

	// End:0x20
	if(((fMouseX < float(0)) || (fMouseX > WinWidth)))
	{
		return none;
	}
	CurItem = Items.Next;
	Y = 0.0000000;
	J0x3F:

	// End:0xC8 [Loop If]
	if(((Y < WinHeight) && (CurItem != none)))
	{
		// End:0xB1
		if(CurItem.ShowThisItem())
		{
			// End:0x9F
			if(((fMouseY >= Y) && (fMouseY <= (Y + m_fItemHeight))))
			{
				return UWindowListBoxItem(CurItem);
			}
			Y = (Y + m_fItemHeight);
		}
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0x3F;
	}
	return none;
	return;
}

function MakeSelectedVisible()
{
	local UWindowList CurItem;
	local int i;

	// End:0x0D
	if((m_SelectedItem == none))
	{
		return;
	}
	CurItem = Items.Next;
	J0x21:

	// End:0x6E [Loop If]
	if((CurItem != none))
	{
		// End:0x3E
		if((CurItem == m_SelectedItem))
		{
			// [Explicit Break]
			goto J0x6E;
		}
		// End:0x57
		if(CurItem.ShowThisItem())
		{
			(i++);
		}
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0x21;
	}
	J0x6E:

	return;
}

function SetSelectedItem(UWindowListBoxItem NewSelected)
{
	// End:0x67
	if(((NewSelected != none) && (m_SelectedItem != NewSelected)))
	{
		// End:0x38
		if((m_SelectedItem != none))
		{
			m_SelectedItem.bSelected = false;
		}
		m_SelectedItem = NewSelected;
		// End:0x5F
		if((m_SelectedItem != none))
		{
			m_SelectedItem.bSelected = true;
		}
		Notify(2);
	}
	return;
}

function SetSelected(float X, float Y)
{
	local UWindowListBoxItem NewSelected;

	NewSelected = GetItemAt(X, Y);
	SetSelectedItem(NewSelected);
	return;
}

function LMouseDown(float X, float Y)
{
	super(UWindowWindow).LMouseDown(X, Y);
	SetSelected(X, Y);
	return;
}

function DoubleClick(float X, float Y)
{
	super(UWindowWindow).DoubleClick(X, Y);
	// End:0x35
	if((GetItemAt(X, Y) == m_SelectedItem))
	{
		DoubleClickItem(m_SelectedItem);
	}
	return;
}

function ReceiveDoubleClickItem(R6WindowListRadio L, UWindowListBoxItem i)
{
	i.Remove();
	Items.AppendItem(i);
	SetSelectedItem(i);
	L.m_SelectedItem = none;
	L.Notify(1);
	Notify(1);
	return;
}

function DoubleClickItem(UWindowListBoxItem i)
{
	// End:0x2D
	if(((m_DoubleClickList != none) && (i != none)))
	{
		m_DoubleClickList.ReceiveDoubleClickItem(self, i);
	}
	return;
}

defaultproperties
{
	m_fItemHeight=10.0000000
}
