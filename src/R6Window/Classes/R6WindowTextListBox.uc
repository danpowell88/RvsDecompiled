//=============================================================================
// R6WindowTextListBox - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowTextListBox.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//    2001/12/13 * Modified by Alexandre Dionne
//=============================================================================
class R6WindowTextListBox extends R6WindowListBox;

const C_iSEL_BORDER_WIDTH = 2;

var UWindowBase.ERenderStyle m_BGRenderStyle;
var float m_fFontSpacing;
var Texture m_BGSelTexture;  // BackGround texture under item when selected
var Font m_Font;
var Font m_FontSeparator;  // font for the separator
var Color m_BGSelColor;  // BackGround color when selected
var Region m_BGSelRegion;  // BackGround texture Region under item when selected
//var color   TextColor;          // color for text            N.B. var already define in class UWindowDialogControl
var Color m_SelTextColor;  // color for selected text
var Color m_SeparatorTextColor;  // If we want the Separator to be displayed another color
var Color m_DisableTextColor;  // color for disable text (item)

function Created()
{
	super.Created();
	m_Font = Root.Fonts[6];
	m_FontSeparator = Root.Fonts[11];
	TextColor = Root.Colors.m_LisBoxNormalTextColor;
	m_SelTextColor = Root.Colors.m_LisBoxSelectedTextColor;
	m_BGSelColor = Root.Colors.m_LisBoxSelectionColor;
	m_SeparatorTextColor = Root.Colors.m_LisBoxSeparatorTextColor;
	m_DisableTextColor = Root.Colors.m_LisBoxDisabledTextColor;
	m_BGRenderStyle = 5;
	m_VertSB.SetHideWhenDisable(true);
	return;
}

function BeforePaint(Canvas C, float fMouseX, float fMouseY)
{
	m_VertSB.SetBorderColor(m_BorderColor);
	return;
}

function Paint(Canvas C, float fMouseX, float fMouseY)
{
	// End:0x25
	if(__NFUN_129__(m_bSkipDrawBorders))
	{
		R6WindowLookAndFeel(LookAndFeel).R6List_DrawBackground(self, C);
	}
	super.Paint(C, fMouseX, fMouseY);
	return;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local string szToDisplay;
	local float TextY, tW, tH, fTemp;
	local UWindowListBoxItem pListBoxItem;

	pListBoxItem = UWindowListBoxItem(Item);
	// End:0x397
	if(__NFUN_123__(pListBoxItem.HelpText, ""))
	{
		C.Font = m_Font;
		C.SpaceX = m_fFontSpacing;
		// End:0x8B
		if(m_bForceCaps)
		{
			szToDisplay = TextSize(C, __NFUN_235__(pListBoxItem.HelpText), tW, tH, int(W));			
		}
		else
		{
			szToDisplay = TextSize(C, pListBoxItem.HelpText, tW, tH, int(W));
		}
		// End:0x19E
		if(pListBoxItem.bSelected)
		{
			// End:0x171
			if(__NFUN_119__(m_BGSelTexture, none))
			{
				C.Style = m_BGRenderStyle;
				C.__NFUN_2626__(m_BGSelColor.R, m_BGSelColor.G, m_BGSelColor.B);
				DrawStretchedTextureSegment(C, X, Y, W, __NFUN_175__(H, m_fSpaceBetItem), float(m_BGSelRegion.X), float(m_BGSelRegion.Y), float(m_BGSelRegion.W), float(m_BGSelRegion.H), m_BGSelTexture);
			}
			C.__NFUN_2626__(m_SelTextColor.R, m_SelTextColor.G, m_SelTextColor.B);			
		}
		else
		{
			// End:0x1DD
			if(pListBoxItem.m_bDisabled)
			{
				C.__NFUN_2626__(m_DisableTextColor.R, m_DisableTextColor.G, m_DisableTextColor.B);				
			}
			else
			{
				// End:0x247
				if(__NFUN_130__(__NFUN_119__(R6WindowListBoxItem(Item), none), R6WindowListBoxItem(Item).m_IsSeparator))
				{
					C.Font = m_FontSeparator;
					C.__NFUN_2626__(m_SeparatorTextColor.R, m_SeparatorTextColor.G, m_SeparatorTextColor.B);					
				}
				else
				{
					C.__NFUN_2626__(TextColor.R, TextColor.G, TextColor.B);
				}
			}
		}
		C.Style = 5;
		ClipText(C, X, Y, szToDisplay, true);
		// End:0x397
		if(pListBoxItem.m_bUseSubText)
		{
			fTemp = __NFUN_174__(Y, tH);
			C.Font = pListBoxItem.m_stSubText.FontSubText;
			TextSize(C, pListBoxItem.m_stSubText.szGameTypeSelect, tW, tH);
			TextY = __NFUN_172__(__NFUN_175__(pListBoxItem.m_stSubText.fHeight, tH), float(2));
			TextY = float(int(__NFUN_174__(TextY, 0.5000000)));
			ClipTextWidth(C, __NFUN_174__(X, pListBoxItem.m_stSubText.fXOffset), __NFUN_174__(fTemp, TextY), pListBoxItem.m_stSubText.szGameTypeSelect, __NFUN_175__(W, float(12)));
		}
	}
	return;
}

function SetSelectedItem(UWindowListBoxItem NewSelected)
{
	local bool bNotify;

	// End:0xB9
	if(__NFUN_130__(__NFUN_119__(NewSelected, none), __NFUN_119__(m_SelectedItem, NewSelected)))
	{
		// End:0x30
		if(NewSelected.m_bDisabled)
		{
			return;
		}
		bNotify = true;
		// End:0x65
		if(__NFUN_119__(R6WindowListBoxItem(NewSelected), none))
		{
			bNotify = __NFUN_129__(R6WindowListBoxItem(NewSelected).m_IsSeparator);
		}
		// End:0xB9
		if(bNotify)
		{
			// End:0x8A
			if(__NFUN_119__(m_SelectedItem, none))
			{
				m_SelectedItem.bSelected = false;
			}
			m_SelectedItem = NewSelected;
			// End:0xB1
			if(__NFUN_119__(m_SelectedItem, none))
			{
				m_SelectedItem.bSelected = true;
			}
			Notify(2);
		}
	}
	return;
}

//=====================================================================================
// FindItemWithName: Find item depending is name 
//=====================================================================================
function UWindowList FindItemWithName(string _ItemName)
{
	local UWindowList CurItem;

	// End:0x0E
	if(__NFUN_122__(_ItemName, ""))
	{
		return none;
	}
	CurItem = Items.Next;
	J0x22:

	// End:0x7D [Loop If]
	if(__NFUN_119__(CurItem, none))
	{
		// End:0x66
		if(__NFUN_129__(R6WindowListBoxItem(CurItem).m_IsSeparator))
		{
			// End:0x66
			if(__NFUN_122__(R6WindowListBoxItem(CurItem).HelpText, _ItemName))
			{
				// [Explicit Break]
				goto J0x7D;
			}
		}
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0x22;
	}
	J0x7D:

	return CurItem;
	return;
}

defaultproperties
{
	m_BGSelTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_BGSelColor=(R=0,G=0,B=128,A=0)
	m_BGSelRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=64802,ZoneNumber=0)
	m_SelTextColor=(R=255,G=255,B=255,A=0)
	m_SeparatorTextColor=(R=255,G=255,B=255,A=0)
	m_fItemHeight=12.0000000
	m_fXItemOffset=5.0000000
	ListClass=Class'R6Window.R6WindowListBoxItem'
	TextColor=(R=255,G=255,B=255,A=0)
}
