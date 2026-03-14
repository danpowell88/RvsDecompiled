//=============================================================================
// R6WindowTextIconsListBox - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowTextIconsListBox.uc : New and improved List Box
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/22 * Created by Alexandre Dionne
//=============================================================================
class R6WindowTextIconsListBox extends R6WindowListBox;

const C_iFIRST_ICON_XPOS = 3;
const C_iDISTANCE_BETWEEN_ICON = 4;

var UWindowBase.ERenderStyle m_BGRenderStyle;
var bool bScrollable;
var bool m_IgnoreAllreadySelected;  // Don't send the click event if we select the same item that is currently selected
var float m_fFontSpacing;
var Texture m_BGSelTexture;  // BackGround texture under item when selected
var Texture m_HealthIconTexture;  // texture for the health icon
var Font m_Font;
var Font m_FontSeparator;  // font for the separator
var Color m_BGSelColor;  // BackGround color when selected
var Region m_BGSelRegion;  // BackGround texture Region under item when selected
var Color m_SeparatorTextColor;  // If we want the Separator to be displayed another color
var Color m_SelTextColor;  // color for selected text
var Color m_DisabledTextColor;  // color text item disabled

function Created()
{
	super.Created();
	m_Font = Root.Fonts[6];
	m_FontSeparator = Root.Fonts[11];
	TextColor = Root.Colors.m_LisBoxNormalTextColor;
	m_SelTextColor = Root.Colors.m_LisBoxSelectedTextColor;
	m_BGSelColor = Root.Colors.m_LisBoxSelectionColor;
	m_DisabledTextColor = Root.Colors.m_LisBoxDisabledTextColor;
	m_SeparatorTextColor = Root.Colors.m_LisBoxSpectatorTextColor;
	m_BGRenderStyle = 5;
	return;
}

function BeforePaint(Canvas C, float fMouseX, float fMouseY)
{
	// End:0x1F
	if(__NFUN_119__(m_VertSB, none))
	{
		m_VertSB.SetBorderColor(m_BorderColor);
	}
	super(UWindowDialogControl).BeforePaint(C, fMouseX, fMouseY);
	return;
}

function Paint(Canvas C, float fMouseX, float fMouseY)
{
	R6WindowLookAndFeel(LookAndFeel).R6List_DrawBackground(self, C);
	super.Paint(C, fMouseX, fMouseY);
	return;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local R6WindowListBoxItem pItem;
	local Region RIcon;
	local string szClipText;
	local float tW, tH, TextX, TextY;

	pItem = R6WindowListBoxItem(Item);
	// End:0xBF
	if(pItem.bSelected)
	{
		// End:0xBF
		if(__NFUN_119__(m_BGSelTexture, none))
		{
			C.Style = m_BGRenderStyle;
			C.__NFUN_2626__(m_BGSelColor.R, m_BGSelColor.G, m_BGSelColor.B);
			DrawStretchedTextureSegment(C, X, Y, W, H, float(m_BGSelRegion.X), float(m_BGSelRegion.Y), float(m_BGSelRegion.W), float(m_BGSelRegion.H), m_BGSelTexture);
		}
	}
	TextX = X;
	// End:0x2CC
	if(__NFUN_119__(pItem.m_Icon, none))
	{
		// End:0x107
		if(pItem.m_addedToSubList)
		{
			RIcon = pItem.m_IconRegion;			
		}
		else
		{
			RIcon = pItem.m_IconSelectedRegion;
		}
		C.Style = 5;
		C.__NFUN_2626__(Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);
		__NFUN_184__(TextX, float(3));
		DrawStretchedTextureSegment(C, TextX, GetYIconPos(Y, H, float(RIcon.H)), float(RIcon.W), float(RIcon.H), float(RIcon.X), float(RIcon.Y), float(RIcon.W), float(RIcon.H), pItem.m_Icon);
		__NFUN_184__(TextX, float(__NFUN_146__(4, RIcon.W)));
		// End:0x2CC
		if(pItem.m_Object.__NFUN_303__('R6Operative'))
		{
			// End:0x289
			if(pItem.m_addedToSubList)
			{
				C.__NFUN_2626__(m_DisabledTextColor.R, m_DisabledTextColor.G, m_DisabledTextColor.B);
			}
			__NFUN_184__(TextX, __NFUN_174__(float(4), DrawHealthIcon(C, TextX, Y, H, R6Operative(pItem.m_Object).m_iHealth)));
		}
	}
	C.Font = m_Font;
	// End:0x333
	if(pItem.m_IsSeparator)
	{
		C.Font = m_FontSeparator;
		C.__NFUN_2626__(m_SeparatorTextColor.R, m_SeparatorTextColor.G, m_SeparatorTextColor.B);		
	}
	else
	{
		// End:0x372
		if(pItem.m_addedToSubList)
		{
			C.__NFUN_2626__(m_DisabledTextColor.R, m_DisabledTextColor.G, m_DisabledTextColor.B);			
		}
		else
		{
			// End:0x3B1
			if(pItem.bSelected)
			{
				C.__NFUN_2626__(m_SelTextColor.R, m_SelTextColor.G, m_SelTextColor.B);				
			}
			else
			{
				C.__NFUN_2626__(TextColor.R, TextColor.G, TextColor.B);
			}
		}
	}
	C.SpaceX = m_fFontSpacing;
	C.Style = 5;
	szClipText = TextSize(C, pItem.HelpText, tW, tH, int(__NFUN_175__(W, TextX)), int(m_fFontSpacing));
	TextY = __NFUN_171__(__NFUN_175__(H, tH), 0.5000000);
	TextY = float(int(__NFUN_174__(TextY, 0.5000000)));
	C.__NFUN_2623__(TextX, __NFUN_174__(Y, TextY));
	C.__NFUN_465__(szClipText);
	return;
}

function float DrawHealthIcon(Canvas C, float _fX, float _fY, float _fH, int _iHealthStatus)
{
	local Region RHealthIcon;

	RHealthIcon = GetHealthIconRegion(_iHealthStatus);
	DrawStretchedTextureSegment(C, _fX, GetYIconPos(_fY, _fH, float(RHealthIcon.H)), float(RHealthIcon.W), float(RHealthIcon.H), float(RHealthIcon.X), float(RHealthIcon.Y), float(RHealthIcon.W), float(RHealthIcon.H), m_HealthIconTexture);
	return float(RHealthIcon.W);
	return;
}

function float GetYIconPos(float _fYItemPos, float _fItemHeight, float _fIconHeight)
{
	local float fTemp;

	fTemp = __NFUN_171__(__NFUN_175__(_fItemHeight, _fIconHeight), 0.5000000);
	fTemp = __NFUN_174__(float(int(__NFUN_174__(fTemp, 0.5000000))), _fYItemPos);
	return fTemp;
	return;
}

function Region GetHealthIconRegion(int _iOperativeHealth)
{
	local Region RTemp;

	RTemp.X = 500;
	RTemp.W = 8;
	RTemp.H = 8;
	switch(_iOperativeHealth)
	{
		// End:0x44
		case 0:
			RTemp.Y = 0;
			// End:0x75
			break;
		// End:0x58
		case 1:
			RTemp.Y = 8;
			// End:0x75
			break;
		// End:0x5D
		case 2:
		// End:0x72
		case 3:
			RTemp.Y = 16;
			// End:0x75
			break;
		// End:0xFFFF
		default:
			break;
	}
	return RTemp;
	return;
}

function SetSelectedItem(UWindowListBoxItem NewSelected)
{
	// End:0x8E
	if(__NFUN_130__(__NFUN_119__(NewSelected, none), __NFUN_242__(R6WindowListBoxItem(NewSelected).m_IsSeparator, false)))
	{
		// End:0x43
		if(__NFUN_130__(m_IgnoreAllreadySelected, __NFUN_114__(m_SelectedItem, NewSelected)))
		{
			return;
		}
		// End:0x5F
		if(__NFUN_119__(m_SelectedItem, none))
		{
			m_SelectedItem.bSelected = false;
		}
		m_SelectedItem = NewSelected;
		// End:0x86
		if(__NFUN_119__(m_SelectedItem, none))
		{
			m_SelectedItem.bSelected = true;
		}
		Notify(2);
	}
	return;
}

function SetScrollable(bool newScrollable)
{
	bScrollable = newScrollable;
	// End:0x6D
	if(newScrollable)
	{
		m_VertSB = R6WindowVScrollbar(CreateWindow(m_SBClass, __NFUN_175__(WinWidth, LookAndFeel.Size_ScrollbarWidth), 0.0000000, LookAndFeel.Size_ScrollbarWidth, WinHeight));
		m_VertSB.bAlwaysOnTop = true;		
	}
	else
	{
		// End:0x8E
		if(__NFUN_119__(m_VertSB, none))
		{
			m_VertSB.Close();
			m_VertSB = none;
		}
	}
	return;
}

defaultproperties
{
	m_IgnoreAllreadySelected=true
	m_BGSelTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_HealthIconTexture=Texture'R6HUD.HUDElements'
	m_BGSelColor=(R=0,G=0,B=128,A=0)
	m_BGSelRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=64802,ZoneNumber=0)
	m_SeparatorTextColor=(R=255,G=255,B=255,A=0)
	m_SelTextColor=(R=255,G=255,B=255,A=0)
	m_DisabledTextColor=(R=141,G=140,B=136,A=0)
	m_fItemHeight=11.0000000
	m_fSpaceBetItem=0.0000000
	ListClass=Class'R6Window.R6WindowListBoxItem'
	TextColor=(R=255,G=255,B=255,A=0)
}
