//=============================================================================
// R6WindowListRestKit - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowListRestKit.uc : The list for restriction kit. This list is for the same type of button. Same
//							 width, same height, etc.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/11/18 * Created by Yannick Joly
//=============================================================================
class R6WindowListRestKit extends UWindowListControl;

var float m_fItemHeight;  // the size of each item
var float m_fSpaceBetItem;  // the space in between item
var float m_fXItemOffset;  // the item X offset pos
var float m_fYOffSet;  // the first item start in m_fYOffset pos
var R6WindowVScrollbar m_VertSB;
var Class<R6WindowVScrollbar> m_SBClass;

function Created()
{
	super.Created();
	m_VertSB = R6WindowVScrollbar(CreateWindow(m_SBClass, (WinWidth - LookAndFeel.Size_ScrollbarWidth), 0.0000000, LookAndFeel.Size_ScrollbarWidth, WinHeight));
	m_VertSB.SetHideWhenDisable(true);
	return;
}

function Paint(Canvas C, float fMouseX, float fMouseY)
{
	local UWindowList CurItem;
	local R6WindowLookAndFeel LAF;
	local float fItemHeight, fListHeight, fdrawWidth, Y;
	local int i;

	LAF = R6WindowLookAndFeel(LookAndFeel);
	CurItem = Items.Next;
	// End:0x31
	if((CurItem == none))
	{
		return;
	}
	fItemHeight = GetSizeOfAnItem();
	fListHeight = ((WinHeight - float((2 * LAF.m_SBHBorder.H))) - m_fYOffSet);
	fdrawWidth = (WinWidth - (float(2) * m_fXItemOffset));
	// End:0x15F
	if((m_VertSB != none))
	{
		m_VertSB.SetRange(0.0000000, float(Items.CountShown()), float(int((fListHeight / fItemHeight))));
		// End:0xEB
		if((!m_VertSB.isHidden()))
		{
			(fdrawWidth -= m_VertSB.WinWidth);
		}
		J0xEB:

		// End:0x15F [Loop If]
		if(((CurItem != none) && (float(i) < m_VertSB.pos)))
		{
			R6WindowListGeneralItem(CurItem).m_pR6WindowButtonBox.HideWindow();
			// End:0x148
			if(CurItem.ShowThisItem())
			{
				(i++);
			}
			CurItem = CurItem.Next;
			// [Loop Continue]
			goto J0xEB;
		}
	}
	Y = (float(LAF.m_SBHBorder.H) + m_fYOffSet);
	J0x181:

	// End:0x203 [Loop If]
	if((((Y + fItemHeight) <= fListHeight) && (CurItem != none)))
	{
		// End:0x1EC
		if(CurItem.ShowThisItem())
		{
			DrawItem(C, CurItem, m_fXItemOffset, Y, fdrawWidth, fItemHeight);
			Y = (Y + fItemHeight);
		}
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0x181;
	}
	J0x203:

	// End:0x242 [Loop If]
	if((CurItem != none))
	{
		R6WindowListGeneralItem(CurItem).m_pR6WindowButtonBox.HideWindow();
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0x203;
	}
	return;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local R6WindowListGeneralItem pListGenItem;

	pListGenItem = R6WindowListGeneralItem(Item);
	pListGenItem.m_pR6WindowButtonBox.WinTop = (WinTop + Y);
	// End:0xB3
	if((pListGenItem.m_pR6WindowButtonBox.WinWidth != W))
	{
		pListGenItem.m_pR6WindowButtonBox.WinLeft = (WinLeft + X);
		pListGenItem.m_pR6WindowButtonBox.WinHeight = H;
		pListGenItem.m_pR6WindowButtonBox.SetNewWidth(W);
	}
	pListGenItem.m_pR6WindowButtonBox.ShowWindow();
	return;
}

function float GetSizeOfAnItem()
{
	local float fTotalItemHeigth;

	fTotalItemHeigth = (m_fItemHeight + m_fSpaceBetItem);
	return fTotalItemHeigth;
	return;
}

//=======================================================================================
// MouseWheelDown: advice scroll bar for mouse wheel down
//=======================================================================================
function MouseWheelDown(float X, float Y)
{
	// End:0x24
	if((m_VertSB != none))
	{
		m_VertSB.MouseWheelDown(X, Y);
	}
	return;
}

//=======================================================================================
// MouseWheelUp: advice scroll bar for mouse wheel up
//=======================================================================================
function MouseWheelUp(float X, float Y)
{
	// End:0x24
	if((m_VertSB != none))
	{
		m_VertSB.MouseWheelUp(X, Y);
	}
	return;
}

defaultproperties
{
	m_fItemHeight=16.0000000
	m_fSpaceBetItem=2.0000000
	m_fYOffSet=2.0000000
	m_SBClass=Class'R6Window.R6WindowVScrollbar'
	ListClass=Class'R6Window.R6WindowListGeneralItem'
}
