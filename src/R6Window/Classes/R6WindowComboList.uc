//=============================================================================
// R6WindowComboList - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowComboList.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowComboList extends UWindowComboList;

var UWindowBase.ERenderStyle m_BGRenderStyle;
var UWindowBase.ERenderStyle m_BGSelRenderStyle;
var Texture m_BGSelTexture;  // BackGround texture under item when selected
var Class<UWindowVScrollbar> m_SBClass;
var Color m_BGColor;  // BackGround color
var Color m_BGSelColor;  // BackGround color when selected
var Region m_BGSelRegion;  // BackGround texture Region under item when selected
//var color   TextColor;			// color for text            N.B. var already define in class UWindowDialogControl
var Color m_SelTextColor;  // color for selected text (item)
var Color m_DisableTextColor;  // color for disable text (item)

function Created()
{
	super.Created();
	TextColor = Root.Colors.m_LisBoxNormalTextColor;
	m_SelTextColor = Root.Colors.m_LisBoxSelectedTextColor;
	m_DisableTextColor = Root.Colors.m_LisBoxDisabledTextColor;
	m_BGSelColor = Root.Colors.m_LisBoxSelectionColor;
	m_BGRenderStyle = 1;
	m_BGSelRenderStyle = 5;
	m_BGColor = Root.Colors.m_ComboBGColor;
	return;
}

function Setup()
{
	VertSB = UWindowVScrollbar(CreateWindow(m_SBClass, (WinWidth - LookAndFeel.Size_ScrollbarWidth), 0.0000000, LookAndFeel.Size_ScrollbarWidth, WinHeight));
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;
	local int Count;
	local UWindowComboListItem i;
	local float ListX, ListY;

	Count = Items.Count();
	// End:0x48
	if((Count > MaxVisible))
	{
		WinHeight = (float((ItemHeight * MaxVisible)) + float((VBorder * 2)));		
	}
	else
	{
		VertSB.pos = 0.0000000;
		WinHeight = (float((ItemHeight * Count)) + float((VBorder * 2)));
	}
	ListX = Owner.EditBox.WinLeft;
	ListY = ((Owner.Button.WinTop + Owner.Button.WinHeight) - float(1));
	// End:0x172
	if((Count > MaxVisible))
	{
		VertSB.ShowWindow();
		VertSB.SetRange(0.0000000, float(Count), float(MaxVisible));
		VertSB.WinLeft = (WinWidth - LookAndFeel.Size_ScrollbarWidth);
		VertSB.WinTop = 0.0000000;
		VertSB.SetSize(LookAndFeel.Size_ScrollbarWidth, WinHeight);		
	}
	else
	{
		VertSB.HideWindow();
	}
	Owner.WindowToGlobal(ListX, ListY, WinLeft, WinTop);
	return;
}

//-----------------------------------------------------------------------------
// There was a bug in the paint in the parent class (UWindowComboList), to 
// avoid an ugly merge, overload the Paint() function here and correct the bug.
//-----------------------------------------------------------------------------
function Paint(Canvas C, float X, float Y)
{
	local int Count;
	local UWindowComboListItem i;

	DrawMenuBackground(C);
	Count = 0;
	C.Font = Root.Fonts[Font];
	i = UWindowComboListItem(Items.Next);
	J0x4E:

	// End:0x17C [Loop If]
	if((i != none))
	{
		// End:0x114
		if(VertSB.bWindowVisible)
		{
			// End:0x111
			if(((float(Count) >= VertSB.pos) && ((Count - int(VertSB.pos)) < MaxVisible)))
			{
				DrawItem(C, i, float(HBorder), (float(VBorder) + (float(ItemHeight) * (float(Count) - VertSB.pos))), ((WinWidth - float((2 * HBorder))) - VertSB.WinWidth), float(ItemHeight));
			}			
		}
		else
		{
			DrawItem(C, i, float(HBorder), float((VBorder + (ItemHeight * Count))), (WinWidth - float((2 * HBorder))), float(ItemHeight));
		}
		(Count++);
		i = UWindowComboListItem(i.Next);
		// [Loop Continue]
		goto J0x4E;
	}
	return;
}

function DrawMenuBackground(Canvas C)
{
	C.Style = m_BGRenderStyle;
	C.SetDrawColor(m_BGColor.R, m_BGColor.G, m_BGColor.B);
	DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, WinWidth, WinHeight, float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	DrawSimpleBorder(C);
	return;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local UWindowComboListItem pComboListItem;

	pComboListItem = UWindowComboListItem(Item);
	// End:0xDE
	if((Selected == Item))
	{
		C.Style = m_BGSelRenderStyle;
		C.SetDrawColor(m_BGSelColor.R, m_BGSelColor.G, m_BGSelColor.B);
		DrawStretchedTextureSegment(C, X, Y, W, H, float(m_BGSelRegion.X), float(m_BGSelRegion.Y), float(m_BGSelRegion.W), float(m_BGSelRegion.H), m_BGSelTexture);
		C.SetDrawColor(m_SelTextColor.R, m_SelTextColor.G, m_SelTextColor.B);		
	}
	else
	{
		// End:0x11D
		if(pComboListItem.bDisabled)
		{
			C.SetDrawColor(m_DisableTextColor.R, m_DisableTextColor.G, m_DisableTextColor.B);			
		}
		else
		{
			C.SetDrawColor(TextColor.R, TextColor.G, TextColor.B);
		}
	}
	ClipText(C, ((X + float(TextBorder)) + float(2)), (Y + float(3)), pComboListItem.Value);
	return;
}

defaultproperties
{
	m_BGSelTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_SBClass=Class'R6Window.R6WindowVScrollbar'
	m_BGSelRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=64802,ZoneNumber=0)
}
