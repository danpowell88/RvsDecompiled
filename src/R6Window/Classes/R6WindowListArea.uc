//=============================================================================
// R6WindowListArea - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowListArea.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowListArea extends R6WindowTextListBox;

var Class<R6WindowArea> m_AreaClass;

function BeforePaint(Canvas C, float fMouseX, float fMouseY)
{
	local UWindowListBoxItem OverItem;

	m_VertSB.SetRange(0.0000000, float(Items.CountShown()), float(int((WinHeight / m_fItemHeight))));
	super.BeforePaint(C, fMouseX, fMouseY);
	return;
}

function Paint(Canvas C, float fMouseX, float fMouseY)
{
	local float Y;
	local UWindowList CurItem;
	local int i;

	CurItem = Items.Next;
	J0x14:

	// End:0x6D [Loop If]
	if(((CurItem != none) && (float(i) < m_VertSB.pos)))
	{
		(++i);
		R6WindowListAreaItem(CurItem).SetBack();
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0x14;
	}
	J0x6D:

	// End:0x101 [Loop If]
	if(((CurItem != none) && (float(i) < (m_VertSB.pos + m_VertSB.MaxVisible))))
	{
		DrawItem(C, CurItem, 0.0000000, Y, (WinWidth - m_VertSB.WinWidth), m_fItemHeight);
		Y = (Y + m_fItemHeight);
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0x6D;
	}
	return;
}

defaultproperties
{
	m_AreaClass=Class'R6Window.R6WindowArea'
	m_fItemHeight=50.0000000
	ListClass=Class'R6Window.R6WindowListAreaItem'
}
