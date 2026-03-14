//=============================================================================
// R6WindowTextLabelExt - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowTextLabelExt.uc : An array of textlabel with each individual parameters
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/03 * Created by Yannick Joly
//=============================================================================
class R6WindowTextLabelExt extends R6WindowSimpleFramedWindowExt;

const iNumberOfLabelMax = 20;
const C_iMAX_SIZE_OF_TEXT_LABEL = 596;

struct TextLabel
{
	var Font TextFont;
	var Color TextColorFont;
	var string m_szTextLabel;
	var float X;
	var float XTextPos;
	var float Y;
	var float fWidth;
	var float fHeight;
	var float fXLine;
	var UWindowBase.TextAlign Align;
	var bool bDrawLineAtEnd;
	var bool bUpDownBG;
	var bool bResizeToText;
};

var UWindowBase.TextAlign Align;
var int m_TextDrawstyle;
var int m_DrawStyle;
var int m_iNumberOfLabel;
var bool m_bRefresh;
var bool m_bCheckToDrawLine;
var bool m_bTextCenterToWindow;  // center the text to the center of the window
var bool m_bUpDownBG;  // set to true if you want a background of editbox type behind your text
var float m_fTextX;
// NEW IN 1.60
var float m_fTextY;
var float m_fFontSpacing;  // Space between characters
var float m_fLMarge;  // Left Text Margin
var float m_fYLineOffset;  // OffSet for the draw line after text
var Font m_Font;
var Texture m_BGTexture;  // Put = None when no background is needed
var Color m_vTextColor;
var Color m_vLineColor;
// NEW IN 1.60
var TextLabel m_sTextLabelArray[20];
var string Text;

function Created()
{
	super.Created();
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H, fWinWidth, fRelativeX, fXTemp;

	local int i;

	// End:0x329
	if(m_bRefresh)
	{
		m_bRefresh = false;
		fXTemp = 0.0000000;
		m_bCheckToDrawLine = false;
		i = 0;
		J0x2B:

		// End:0x329 [Loop If]
		if(__NFUN_150__(i, m_iNumberOfLabel))
		{
			C.Font = m_sTextLabelArray[i].TextFont;
			fWinWidth = m_sTextLabelArray[i].fWidth;
			// End:0x198
			if(m_sTextLabelArray[i].bResizeToText)
			{
				TextSize(C, m_sTextLabelArray[i].m_szTextLabel, W, H);
				// End:0x195
				if(__NFUN_177__(W, WinWidth))
				{
					// End:0x104
					if(__NFUN_177__(W, float(596)))
					{
						m_sTextLabelArray[i].m_szTextLabel = TextSize(C, m_sTextLabelArray[i].m_szTextLabel, W, H, 596);
					}
					m_sTextLabelArray[i].XTextPos = 4.0000000;
					WinWidth = __NFUN_174__(W, float(__NFUN_144__(2, 4)));
					m_sTextLabelArray[i].fWidth = WinWidth;
					fWinWidth = m_sTextLabelArray[i].fWidth;
					// End:0x195
					if(__NFUN_130__(__NFUN_119__(OwnerWindow, none), OwnerWindow.__NFUN_303__('R6WindowPopUpBox')))
					{
						R6WindowPopUpBox(OwnerWindow).ResizePopUp(WinWidth);
					}
				}				
			}
			else
			{
				m_sTextLabelArray[i].m_szTextLabel = TextSize(C, m_sTextLabelArray[i].m_szTextLabel, W, H, int(fWinWidth));
			}
			switch(m_sTextLabelArray[i].Align)
			{
				// End:0x1FA
				case 0:
					fXTemp = m_fLMarge;
					// End:0x25B
					break;
				// End:0x238
				case 1:
					fXTemp = __NFUN_175__(__NFUN_175__(__NFUN_175__(fWinWidth, W), __NFUN_171__(float(__NFUN_125__(m_sTextLabelArray[i].m_szTextLabel)), m_fFontSpacing)), m_fVBorderWidth);
					// End:0x25B
					break;
				// End:0x258
				case 2:
					fXTemp = __NFUN_172__(__NFUN_175__(fWinWidth, W), float(2));
					// End:0x25B
					break;
				// End:0xFFFF
				default:
					break;
			}
			// End:0x29F
			if(m_sTextLabelArray[i].bDrawLineAtEnd)
			{
				m_sTextLabelArray[i].fXLine = __NFUN_174__(m_sTextLabelArray[i].X, fWinWidth);
				m_bCheckToDrawLine = true;
			}
			m_sTextLabelArray[i].XTextPos = __NFUN_174__(m_sTextLabelArray[i].X, fXTemp);
			// End:0x31F
			if(m_bTextCenterToWindow)
			{
				m_sTextLabelArray[i].Y = __NFUN_172__(__NFUN_175__(WinHeight, H), float(2));
				m_sTextLabelArray[i].Y = float(int(__NFUN_174__(m_sTextLabelArray[i].Y, 0.5000000)));
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x2B;
		}
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local float tempSpace;
	local int i;
	local Texture t;

	// End:0x20
	if(__NFUN_129__(GetActivateBorder()))
	{
		super.Paint(C, X, Y);
	}
	// End:0x106
	if(m_bCheckToDrawLine)
	{
		C.Style = byte(m_DrawStyle);
		C.__NFUN_2626__(m_vLineColor.R, m_vLineColor.G, m_vLineColor.B);
		i = 0;
		J0x70:

		// End:0x106 [Loop If]
		if(__NFUN_150__(i, __NFUN_147__(m_iNumberOfLabel, 1)))
		{
			// End:0xFC
			if(m_sTextLabelArray[i].bDrawLineAtEnd)
			{
				DrawStretchedTextureSegment(C, m_sTextLabelArray[i].fXLine, m_fYLineOffset, 1.0000000, __NFUN_175__(WinHeight, m_fYLineOffset), float(m_VBorderTextureRegion.X), float(m_VBorderTextureRegion.Y), float(m_VBorderTextureRegion.W), float(m_VBorderTextureRegion.H), m_VBorderTexture);
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x70;
		}
	}
	// End:0x362
	if(__NFUN_123__(m_sTextLabelArray[0].m_szTextLabel, ""))
	{
		tempSpace = C.SpaceX;
		C.Font = m_Font;
		C.SpaceX = m_fFontSpacing;
		m_vTextColor = m_sTextLabelArray[0].TextColorFont;
		C.__NFUN_2626__(m_vTextColor.R, m_vTextColor.G, m_vTextColor.B);
		C.Style = byte(m_TextDrawstyle);
		i = 0;
		J0x1AE:

		// End:0x34E [Loop If]
		if(__NFUN_150__(i, m_iNumberOfLabel))
		{
			// End:0x20C
			if(__NFUN_119__(m_sTextLabelArray[i].TextFont, m_Font))
			{
				m_Font = m_sTextLabelArray[i].TextFont;
				C.Font = m_sTextLabelArray[i].TextFont;
			}
			// End:0x269
			if(m_sTextLabelArray[i].TextColorFont != m_vTextColor)
			{
				m_vTextColor = m_sTextLabelArray[i].TextColorFont;
				C.__NFUN_2626__(m_vTextColor.R, m_vTextColor.G, m_vTextColor.B);
			}
			// End:0x308
			if(m_sTextLabelArray[i].bUpDownBG)
			{
				DrawUpDownBG(C, m_sTextLabelArray[i].X, m_sTextLabelArray[i].Y, m_sTextLabelArray[i].fWidth, m_sTextLabelArray[i].fHeight);
				C.Style = byte(m_TextDrawstyle);
				C.__NFUN_2626__(m_vTextColor.R, m_vTextColor.G, m_vTextColor.B);
			}
			ClipText(C, m_sTextLabelArray[i].XTextPos, m_sTextLabelArray[i].Y, m_sTextLabelArray[i].m_szTextLabel, true);
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x1AE;
		}
		C.SpaceX = tempSpace;
	}
	return;
}

//===============================================================================
// DrawUpDownBG: Draw the editbox background effect under the text if the bUpDownBG is true
//===============================================================================
function DrawUpDownBG(Canvas C, float _fX, float _fY, float _fW, float _fH)
{
	local Texture BGTexture;
	local Region RTexture;

	BGTexture = Texture'R6MenuTextures.Gui_BoxScroll';
	RTexture.X = 114;
	RTexture.Y = 47;
	RTexture.W = 2;
	RTexture.H = 13;
	C.Style = 5;
	C.__NFUN_2626__(Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);
	DrawStretchedTextureSegment(C, _fX, _fY, _fW, _fH, float(RTexture.X), float(RTexture.Y), float(RTexture.W), float(RTexture.H), BGTexture);
	return;
}

// use at create only
function int AddTextLabel(string _szTextToAdd, float _X, float _Y, float _fWidth, UWindowBase.TextAlign _Align, bool _bDrawLineAtEnd, optional float _fHeight, optional bool _bResizeToText)
{
	local int iIndex;

	iIndex = 0;
	// End:0x162
	if(__NFUN_150__(m_iNumberOfLabel, 20))
	{
		m_sTextLabelArray[m_iNumberOfLabel].m_szTextLabel = _szTextToAdd;
		m_sTextLabelArray[m_iNumberOfLabel].X = _X;
		m_sTextLabelArray[m_iNumberOfLabel].XTextPos = _X;
		m_sTextLabelArray[m_iNumberOfLabel].Y = _Y;
		m_sTextLabelArray[m_iNumberOfLabel].fWidth = _fWidth;
		// End:0xA7
		if(__NFUN_180__(_fHeight, float(0)))
		{
			m_sTextLabelArray[m_iNumberOfLabel].fHeight = 15.0000000;			
		}
		else
		{
			m_sTextLabelArray[m_iNumberOfLabel].fHeight = _fHeight;
		}
		m_sTextLabelArray[m_iNumberOfLabel].Align = _Align;
		m_sTextLabelArray[m_iNumberOfLabel].bDrawLineAtEnd = _bDrawLineAtEnd;
		m_sTextLabelArray[m_iNumberOfLabel].bResizeToText = _bResizeToText;
		m_sTextLabelArray[m_iNumberOfLabel].TextFont = m_Font;
		m_sTextLabelArray[m_iNumberOfLabel].TextColorFont = m_vTextColor;
		m_sTextLabelArray[m_iNumberOfLabel].bUpDownBG = m_bUpDownBG;
		iIndex = m_iNumberOfLabel;
		m_bRefresh = true;
		__NFUN_161__(m_iNumberOfLabel, 1);
	}
	return iIndex;
	return;
}

//===============================================================================
// According the index value, change the string. No check was done is the index is valid or not
//===============================================================================
function ChangeTextLabel(string _szNewStringLabel, int _iIndex)
{
	m_sTextLabelArray[_iIndex].m_szTextLabel = _szNewStringLabel;
	m_bRefresh = true;
	return;
}

//===============================================================================
// According the index value, change the color of the font. No check was done is the index is valid or not
//===============================================================================
function ChangeColorLabel(Color _vNewColorText, int _iIndex)
{
	m_sTextLabelArray[_iIndex].TextColorFont = _vNewColorText;
	m_bRefresh = true;
	return;
}

function string GetTextLabel(int _iIndex)
{
	return m_sTextLabelArray[_iIndex].m_szTextLabel;
	return;
}

function Color GetTextColor(int _iIndex)
{
	return m_sTextLabelArray[_iIndex].TextColorFont;
	return;
}

function Clear()
{
	local int i;

	i = 0;
	J0x07:

	// End:0x33 [Loop If]
	if(__NFUN_150__(i, m_iNumberOfLabel))
	{
		m_sTextLabelArray[i].m_szTextLabel = "";
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	m_iNumberOfLabel = 0;
	m_bRefresh = true;
	return;
}

defaultproperties
{
	m_TextDrawstyle=5
	m_DrawStyle=5
	m_bRefresh=true
	m_fLMarge=2.0000000
	m_fYLineOffset=1.0000000
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_sTextLabelArrayiNumberOfLabelMax
