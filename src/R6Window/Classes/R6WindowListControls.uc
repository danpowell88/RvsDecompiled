//=============================================================================
// R6WindowListControls - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowListControls.uc : Create the controls page in options. Scrollbar page with 3 types of the same items
//							  Title, selected item and line item
//							  see default properties for some settings
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/16 * Created by Yannick Joly
//=============================================================================
class R6WindowListControls extends R6WindowTextListBox;

var float m_fXOffSet;
var UWindowListBoxItem m_pPreviousItem;
var Texture m_BorderTexture;
// for the draw line
var Region m_BorderTextureRegion;

function Paint(Canvas C, float fMouseX, float fMouseY)
{
	local R6WindowLookAndFeel LAF;
	local UWindowList CurItem;
	local float Y, fdrawWidth, fListHeight, fItemHeight;
	local int i;

	LAF = R6WindowLookAndFeel(LookAndFeel);
	CurItem = Items.Next;
	// End:0x40
	if((CurItem != none))
	{
		fItemHeight = GetSizeOfAnItem(CurItem);
	}
	fListHeight = GetSizeOfList();
	// End:0xD1
	if((m_VertSB != none))
	{
		m_VertSB.SetRange(0.0000000, float(Items.CountShown()), float(int((fListHeight / fItemHeight))));
		J0x8C:

		// End:0xD1 [Loop If]
		if(((CurItem != none) && (float(i) < m_VertSB.pos)))
		{
			(i++);
			CurItem = CurItem.Next;
			// [Loop Continue]
			goto J0x8C;
		}
	}
	// End:0xFE
	if(((m_VertSB == none) || m_VertSB.isHidden()))
	{
		fdrawWidth = WinWidth;		
	}
	else
	{
		fdrawWidth = (WinWidth - m_VertSB.WinWidth);
	}
	m_iTotItemsDisplayed = 0;
	Y = float(LAF.m_SBHBorder.H);
	J0x13B:

	// End:0x209 [Loop If]
	if((((Y + fItemHeight) <= fListHeight) && (CurItem != none)))
	{
		// End:0x1F2
		if(CurItem.ShowThisItem())
		{
			// End:0x1AE
			if(UWindowListBoxItem(CurItem).m_bImALine)
			{
				DrawItem(C, CurItem, m_fXOffSet, Y, fdrawWidth, fItemHeight);				
			}
			else
			{
				DrawItem(C, CurItem, m_fXOffSet, Y, (fdrawWidth - m_fXOffSet), fItemHeight);
			}
			Y = (Y + fItemHeight);
			(m_iTotItemsDisplayed++);
		}
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0x13B;
	}
	return;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local float fXPos, fW, fH, fTextY;
	local int temp;
	local Texture t;
	local UWindowListBoxItem pListBoxItem;

	pListBoxItem = UWindowListBoxItem(Item);
	C.SetDrawColor(UWindowListBoxItem(Item).m_vItemColor.R, UWindowListBoxItem(Item).m_vItemColor.G, UWindowListBoxItem(Item).m_vItemColor.B);
	// End:0x133
	if(pListBoxItem.m_bImALine)
	{
		C.Style = 5;
		// End:0xC2
		if((((H % float(2)) > float(0)) && (float(m_BorderTextureRegion.H) <= 1.0000000)))
		{
			H = (H + float(1));
		}
		DrawStretchedTextureSegment(C, 1.0000000, (Y + (H * 0.5000000)), (W - float(1)), float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);		
	}
	else
	{
		// End:0x3BE
		if((pListBoxItem.HelpText != ""))
		{
			C.Style = 5;
			C.Font = Root.Fonts[11];
			C.SpaceX = m_fFontSpacing;
			TextSize(C, UWindowListBoxItem(Item).HelpText, fW, fH);
			fTextY = ((m_fItemHeight - fH) * 0.5000000);
			fTextY = float(int((TextY + 0.5000000)));
			// End:0x389
			if((pListBoxItem.m_szActionKey != ""))
			{
				t = Texture'UWindow.WhiteTexture';
				C.DrawColor = Root.Colors.Black;
				C.Style = 5;
				C.SetDrawColor(C.DrawColor.R, C.DrawColor.G, C.DrawColor.B, 50);
				DrawStretchedTexture(C, pListBoxItem.m_fXFakeEditBox, (Y + fTextY), pListBoxItem.m_fWFakeEditBox, H, t);
				C.SetDrawColor(pListBoxItem.m_vItemColor.R, pListBoxItem.m_vItemColor.G, pListBoxItem.m_vItemColor.B);
				TextSize(C, pListBoxItem.m_szFakeEditBoxValue, fW, fH);
				fXPos = (pListBoxItem.m_fXFakeEditBox + ((pListBoxItem.m_fWFakeEditBox - fW) / float(2)));
				ClipTextWidth(C, fXPos, (Y + fTextY), pListBoxItem.m_szFakeEditBoxValue, W);
			}
			ClipTextWidth(C, (X + float(2)), (Y + fTextY), pListBoxItem.HelpText, W);
		}
	}
	return;
}

function MouseMove(float X, float Y)
{
	super(R6WindowListBox).MouseMove(X, Y);
	ManageOverEffect(X, Y);
	return;
}

function MouseLeave()
{
	super(R6WindowListBox).MouseLeave();
	ManageOverEffect(0.0000000, 0.0000000);
	return;
}

function ManageOverEffect(float X, float Y)
{
	local UWindowListBoxItem OverItem;

	OverItem = GetItemAt(X, Y);
	// End:0x56
	if((m_pPreviousItem != none))
	{
		m_pPreviousItem.m_vItemColor = Root.Colors.White;
		m_pPreviousItem = none;
		ToolTip("");
	}
	// End:0xBA
	if((OverItem != none))
	{
		// End:0xBA
		if((!OverItem.m_bNotAffectByNotify))
		{
			OverItem.m_vItemColor = Root.Colors.BlueLight;
			ToolTip(OverItem.m_szToolTip);
			m_pPreviousItem = OverItem;
		}
	}
	return;
}

//=====================================================================
// SetSelectedItem: derivate from R6WindowListBox
//=====================================================================
function SetSelectedItem(UWindowListBoxItem NewSelected)
{
	// End:0x61
	if((NewSelected != none))
	{
		// End:0x27
		if((m_SelectedItem != none))
		{
			m_SelectedItem.bSelected = false;
		}
		m_SelectedItem = NewSelected;
		// End:0x4E
		if((m_SelectedItem != none))
		{
			m_SelectedItem.bSelected = true;
		}
		// End:0x61
		if((m_pPreviousItem != none))
		{
			Notify(2);
		}
	}
	return;
}

defaultproperties
{
	m_BorderTexture=Texture'UWindow.WhiteTexture'
	m_BorderTextureRegion=(Zone=StructProperty'R6Window.R6WindowSimpleFramedWindow.m_topLeftCornerR',iLeaf=290,ZoneNumber=0)
	m_fItemHeight=20.0000000
	m_fSpaceBetItem=0.0000000
}
