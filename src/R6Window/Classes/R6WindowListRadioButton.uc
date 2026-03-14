//=============================================================================
// R6WindowListRadioButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowListRadioButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowListRadioButton extends R6WindowTextListRadio;

var bool m_bCanBeUnselected;  // item can be unselected
var float m_fItemWidth;
var float m_fItemVPadding;

function Created()
{
	super(UWindowListControl).Created();
	return;
}

//When the window is resized.
function ChangeItemsSize(float iNewSize)
{
	return;
}

function Paint(Canvas C, float MouseX, float MouseY)
{
	local float X, Y;
	local UWindowList CurItem;

	// End:0x18
	if(__NFUN_180__(m_fItemWidth, float(0)))
	{
		m_fItemWidth = WinWidth;
	}
	X = __NFUN_172__(__NFUN_175__(WinWidth, m_fItemWidth), float(2));
	CurItem = Items.Next;
	J0x44:

	// End:0xC3 [Loop If]
	if(__NFUN_119__(CurItem, none))
	{
		DrawItem(C, CurItem, X, Y, m_fItemWidth, m_fItemHeight);
		__NFUN_184__(Y, __NFUN_174__(m_fItemHeight, m_fItemVPadding));
		// End:0xAC
		if(__NFUN_179__(Y, WinHeight))
		{
			Y = 0.0000000;
			__NFUN_184__(X, WinWidth);
		}
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0x44;
	}
	return;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local R6WindowListButtonItem pListButtonItem;

	pListButtonItem = R6WindowListButtonItem(Item);
	// End:0x7B
	if(__NFUN_119__(pListButtonItem.m_Button, none))
	{
		pListButtonItem.m_Button.WinLeft = X;
		pListButtonItem.m_Button.WinTop = Y;
		pListButtonItem.m_Button.WinHeight = H;
	}
	return;
}

function UWindowListBoxItem GetItemAt(float fMouseX, float fMouseY)
{
	local float X, Y;
	local UWindowList CurItem;
	local int i, j;

	// End:0x20
	if(__NFUN_132__(__NFUN_176__(fMouseX, float(0)), __NFUN_177__(fMouseX, WinWidth)))
	{
		return none;
	}
	// End:0x2D
	if(__NFUN_114__(Items, none))
	{
		return none;
	}
	CurItem = Items.Next;
	X = 0.0000000;
	J0x4C:

	// End:0x19D [Loop If]
	if(__NFUN_130__(__NFUN_176__(X, WinWidth), __NFUN_119__(CurItem, none)))
	{
		// End:0x132
		if(__NFUN_130__(__NFUN_179__(fMouseX, X), __NFUN_178__(fMouseX, __NFUN_174__(X, WinWidth))))
		{
			Y = 0.0000000;
			J0x9A:

			// End:0x12F [Loop If]
			if(__NFUN_130__(__NFUN_176__(Y, WinHeight), __NFUN_119__(CurItem, none)))
			{
				// End:0xFA
				if(CurItem.ShowThisItem())
				{
					// End:0xFA
					if(__NFUN_130__(__NFUN_179__(fMouseY, Y), __NFUN_178__(fMouseY, __NFUN_174__(Y, m_fItemHeight))))
					{
						return UWindowListBoxItem(CurItem);
					}
				}
				// End:0x119
				if(__NFUN_119__(CurItem, none))
				{
					CurItem = CurItem.Next;
				}
				__NFUN_184__(Y, __NFUN_174__(m_fItemHeight, m_fItemVPadding));
				// [Loop Continue]
				goto J0x9A;
			}			
		}
		else
		{
			j = 0;
			J0x139:

			// End:0x18E [Loop If]
			if(__NFUN_130__(__NFUN_119__(CurItem, none), __NFUN_176__(float(j), __NFUN_172__(WinHeight, __NFUN_174__(m_fItemHeight, m_fItemVPadding)))))
			{
				// End:0x184
				if(__NFUN_119__(CurItem, none))
				{
					CurItem = CurItem.Next;
				}
				__NFUN_165__(j);
				// [Loop Continue]
				goto J0x139;
			}
		}
		__NFUN_184__(X, WinWidth);
		// [Loop Continue]
		goto J0x4C;
	}
	return none;
	return;
}

function SetSelectedItem(UWindowListBoxItem NewSelected)
{
	local UWindowListBoxItem CurSelected;

	CurSelected = m_SelectedItem;
	// End:0x35
	if(__NFUN_119__(m_SelectedItem, none))
	{
		R6WindowListButtonItem(m_SelectedItem).m_Button.m_bSelected = false;
	}
	super(R6WindowListRadio).SetSelectedItem(NewSelected);
	// End:0x70
	if(m_bCanBeUnselected)
	{
		// End:0x70
		if(__NFUN_114__(CurSelected, m_SelectedItem))
		{
			m_SelectedItem.bSelected = false;
			m_SelectedItem = none;
		}
	}
	// End:0x9A
	if(__NFUN_119__(m_SelectedItem, none))
	{
		R6WindowListButtonItem(m_SelectedItem).m_Button.m_bSelected = true;
	}
	return;
}

function SetDefaultButton(UWindowList Item)
{
	// End:0x26
	if(__NFUN_119__(Item, none))
	{
		// End:0x26
		if(__NFUN_114__(m_SelectedItem, none))
		{
			SetSelectedItem(UWindowListBoxItem(Item));
		}
	}
	return;
}

function UWindowListBoxItem GetElement(int ButtonID)
{
	local UWindowList CurItem;
	local bool Found;
	local int i;

	// End:0x0D
	if(__NFUN_150__(ButtonID, 0))
	{
		return none;
	}
	// End:0x1A
	if(__NFUN_114__(Items, none))
	{
		return none;
	}
	CurItem = Items.Next;
	i = 0;
	J0x35:

	// End:0xAB [Loop If]
	if(__NFUN_130__(__NFUN_150__(i, Items.Count()), __NFUN_242__(Found, false)))
	{
		// End:0x8D
		if(__NFUN_154__(R6WindowListButtonItem(CurItem).m_Button.m_iButtonID, ButtonID))
		{
			Found = true;
			// [Explicit Continue]
			goto J0xA1;
		}
		CurItem = CurItem.Next;
		J0xA1:

		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x35;
	}
	// End:0xC2
	if(Found)
	{
		return UWindowListBoxItem(CurItem);		
	}
	else
	{
		return none;
	}
	return;
}

defaultproperties
{
	m_fItemHeight=50.0000000
	ListClass=Class'R6Window.R6WindowListButtonItem'
}
