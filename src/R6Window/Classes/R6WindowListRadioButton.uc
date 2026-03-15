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
	if((m_fItemWidth == float(0)))
	{
		m_fItemWidth = WinWidth;
	}
	X = ((WinWidth - m_fItemWidth) / float(2));
	CurItem = Items.Next;
	J0x44:

	// End:0xC3 [Loop If]
	if((CurItem != none))
	{
		DrawItem(C, CurItem, X, Y, m_fItemWidth, m_fItemHeight);
		(Y += (m_fItemHeight + m_fItemVPadding));
		// End:0xAC
		if((Y >= WinHeight))
		{
			Y = 0.0000000;
			(X += WinWidth);
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
	if((pListButtonItem.m_Button != none))
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
	if(((fMouseX < float(0)) || (fMouseX > WinWidth)))
	{
		return none;
	}
	// End:0x2D
	if((Items == none))
	{
		return none;
	}
	CurItem = Items.Next;
	X = 0.0000000;
	J0x4C:

	// End:0x19D [Loop If]
	if(((X < WinWidth) && (CurItem != none)))
	{
		// End:0x132
		if(((fMouseX >= X) && (fMouseX <= (X + WinWidth))))
		{
			Y = 0.0000000;
			J0x9A:

			// End:0x12F [Loop If]
			if(((Y < WinHeight) && (CurItem != none)))
			{
				// End:0xFA
				if(CurItem.ShowThisItem())
				{
					// End:0xFA
					if(((fMouseY >= Y) && (fMouseY <= (Y + m_fItemHeight))))
					{
						return UWindowListBoxItem(CurItem);
					}
				}
				// End:0x119
				if((CurItem != none))
				{
					CurItem = CurItem.Next;
				}
				(Y += (m_fItemHeight + m_fItemVPadding));
				// [Loop Continue]
				goto J0x9A;
			}			
		}
		else
		{
			j = 0;
			J0x139:

			// End:0x18E [Loop If]
			if(((CurItem != none) && (float(j) < (WinHeight / (m_fItemHeight + m_fItemVPadding)))))
			{
				// End:0x184
				if((CurItem != none))
				{
					CurItem = CurItem.Next;
				}
				(j++);
				// [Loop Continue]
				goto J0x139;
			}
		}
		(X += WinWidth);
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
	if((m_SelectedItem != none))
	{
		R6WindowListButtonItem(m_SelectedItem).m_Button.m_bSelected = false;
	}
	super(R6WindowListRadio).SetSelectedItem(NewSelected);
	// End:0x70
	if(m_bCanBeUnselected)
	{
		// End:0x70
		if((CurSelected == m_SelectedItem))
		{
			m_SelectedItem.bSelected = false;
			m_SelectedItem = none;
		}
	}
	// End:0x9A
	if((m_SelectedItem != none))
	{
		R6WindowListButtonItem(m_SelectedItem).m_Button.m_bSelected = true;
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

function UWindowListBoxItem GetElement(int ButtonID)
{
	local UWindowList CurItem;
	local bool Found;
	local int i;

	// End:0x0D
	if((ButtonID < 0))
	{
		return none;
	}
	// End:0x1A
	if((Items == none))
	{
		return none;
	}
	CurItem = Items.Next;
	i = 0;
	J0x35:

	// End:0xAB [Loop If]
	if(((i < Items.Count()) && (Found == false)))
	{
		// End:0x8D
		if((R6WindowListButtonItem(CurItem).m_Button.m_iButtonID == ButtonID))
		{
			Found = true;
			// [Explicit Continue]
			goto J0xA1;
		}
		CurItem = CurItem.Next;
		J0xA1:

		(i++);
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
