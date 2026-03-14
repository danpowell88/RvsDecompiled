//=============================================================================
// R6WindowTextLabel - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowTextLabel.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/30 * Created by Alexandre Dionne
//=============================================================================
class R6WindowTextLabel extends UWindowWindow;

var UWindowBase.TextAlign Align;
var int m_TextDrawstyle;
var int m_DrawStyle;
var bool m_bDrawBorders;  // Draw the borders?
var bool m_bRefresh;
var bool m_bUseBGColor;  // Color BG texture
var bool m_bDrawBG;  // Draw the backGround??
var bool m_bUseExtRegion;  // use extremeties region for the background with m_BGTextureRegion
var bool m_bResizeToText;  // Resize the window to the text
var bool m_bFixedYPos;  // To force the y pos of the text
var float TextX;
// NEW IN 1.60
var float TextY;
var float m_fFontSpacing;  // Space between characters
var float m_fLMarge;  // Left Text Margin
var float m_fHBorderHeight;
// NEW IN 1.60
var float m_fVBorderWidth;
var float m_fHBorderPadding;
// NEW IN 1.60
var float m_fVBorderPadding;
var Font m_Font;
var Texture m_BGTexture;  // Put = None when no background is needed
var Texture m_HBorderTexture;
// NEW IN 1.60
var Texture m_VBorderTexture;
var Region m_BGTextureRegion;
var Region m_HBorderTextureRegion;
// NEW IN 1.60
var Region m_VBorderTextureRegion;
var Region m_BGExtRegion;  // use extremeties region (left and rigth arre the same)
var Color TextColor;
var Color m_BGColor;
var string Text;

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;

	// End:0x160
	if(m_bRefresh)
	{
		m_bRefresh = false;
		// End:0x160
		if(__NFUN_123__(Text, ""))
		{
			C.Font = m_Font;
			TextSize(C, Text, W, H);
			switch(Align)
			{
				// End:0x66
				case 0:
					TextX = m_fLMarge;
					// End:0xBC
					break;
				// End:0x99
				case 1:
					TextX = __NFUN_175__(__NFUN_175__(__NFUN_175__(WinWidth, W), __NFUN_171__(float(__NFUN_125__(Text)), m_fFontSpacing)), m_fVBorderWidth);
					// End:0xBC
					break;
				// End:0xB9
				case 2:
					TextX = __NFUN_172__(__NFUN_175__(WinWidth, W), float(2));
					// End:0xBC
					break;
				// End:0xFFFF
				default:
					break;
			}
			// End:0xF5
			if(__NFUN_129__(m_bFixedYPos))
			{
				TextY = __NFUN_172__(__NFUN_175__(WinHeight, H), float(2));
				TextY = float(int(__NFUN_174__(TextY, 0.5000000)));
			}
			// End:0x160
			if(m_bResizeToText)
			{
				WinWidth = __NFUN_174__(__NFUN_174__(W, __NFUN_171__(float(__NFUN_125__(Text)), m_fFontSpacing)), m_fLMarge);
				// End:0x145
				if(__NFUN_155__(int(Align), int(0)))
				{
					__NFUN_184__(WinLeft, __NFUN_175__(TextX, m_fLMarge));
				}
				TextX = m_fLMarge;
				Align = 0;
				m_bResizeToText = false;
			}
		}
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local Region RTemp;
	local float tempSpace;

	C.Style = byte(m_DrawStyle);
	// End:0x2FE
	if(__NFUN_130__(__NFUN_119__(m_BGTexture, none), m_bDrawBG))
	{
		// End:0x69
		if(m_bUseBGColor)
		{
			C.__NFUN_2626__(m_BGColor.R, m_BGColor.G, m_BGColor.B, m_BGColor.A);
		}
		// End:0x290
		if(m_bUseExtRegion)
		{
			RTemp.X = int(m_fVBorderWidth);
			RTemp.Y = int(m_fHBorderHeight);
			RTemp.W = m_BGExtRegion.W;
			RTemp.H = int(__NFUN_175__(WinHeight, __NFUN_171__(float(2), m_fHBorderHeight)));
			DrawStretchedTextureSegment(C, float(RTemp.X), float(RTemp.Y), float(RTemp.W), float(RTemp.H), float(m_BGExtRegion.X), float(m_BGExtRegion.Y), float(m_BGExtRegion.W), float(m_BGExtRegion.H), m_BGTexture);
			__NFUN_161__(RTemp.X, RTemp.W);
			RTemp.W = int(__NFUN_175__(WinWidth, float(__NFUN_144__(2, RTemp.X))));
			DrawStretchedTextureSegment(C, float(RTemp.X), float(RTemp.Y), float(RTemp.W), float(RTemp.H), float(m_BGTextureRegion.X), float(m_BGTextureRegion.Y), float(m_BGTextureRegion.W), float(m_BGTextureRegion.H), m_BGTexture);
			__NFUN_161__(RTemp.X, RTemp.W);
			RTemp.W = m_BGExtRegion.W;
			DrawStretchedTextureSegment(C, float(RTemp.X), float(RTemp.Y), float(RTemp.W), float(RTemp.H), float(__NFUN_146__(m_BGExtRegion.X, m_BGExtRegion.W)), float(m_BGExtRegion.Y), float(__NFUN_143__(m_BGExtRegion.W)), float(m_BGExtRegion.H), m_BGTexture);			
		}
		else
		{
			DrawStretchedTextureSegment(C, m_fVBorderWidth, m_fHBorderHeight, __NFUN_175__(WinWidth, __NFUN_171__(float(2), m_fVBorderWidth)), __NFUN_175__(WinHeight, __NFUN_171__(float(2), m_fHBorderHeight)), float(m_BGTextureRegion.X), float(m_BGTextureRegion.Y), float(m_BGTextureRegion.W), float(m_BGTextureRegion.H), m_BGTexture);
		}
	}
	// End:0x501
	if(m_bDrawBorders)
	{
		C.__NFUN_2626__(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
		// End:0x405
		if(__NFUN_119__(m_HBorderTexture, none))
		{
			DrawStretchedTextureSegment(C, m_fHBorderPadding, 0.0000000, __NFUN_175__(WinWidth, __NFUN_171__(float(2), m_fHBorderPadding)), m_fHBorderHeight, float(m_HBorderTextureRegion.X), float(m_HBorderTextureRegion.Y), float(m_HBorderTextureRegion.W), float(m_HBorderTextureRegion.H), m_HBorderTexture);
			DrawStretchedTextureSegment(C, m_fHBorderPadding, __NFUN_175__(WinHeight, m_fHBorderHeight), __NFUN_175__(WinWidth, __NFUN_171__(float(2), m_fHBorderPadding)), m_fHBorderHeight, float(m_HBorderTextureRegion.X), float(m_HBorderTextureRegion.Y), float(m_HBorderTextureRegion.W), float(m_HBorderTextureRegion.H), m_HBorderTexture);
		}
		// End:0x501
		if(__NFUN_119__(m_VBorderTexture, none))
		{
			DrawStretchedTextureSegment(C, 0.0000000, __NFUN_174__(m_fHBorderHeight, m_fVBorderPadding), m_fVBorderWidth, __NFUN_175__(__NFUN_175__(WinHeight, __NFUN_171__(float(2), m_fHBorderHeight)), __NFUN_171__(float(2), m_fVBorderPadding)), float(m_VBorderTextureRegion.X), float(m_VBorderTextureRegion.Y), float(m_VBorderTextureRegion.W), float(m_VBorderTextureRegion.H), m_VBorderTexture);
			DrawStretchedTextureSegment(C, __NFUN_175__(WinWidth, m_fVBorderWidth), __NFUN_174__(m_fHBorderHeight, m_fVBorderPadding), m_fVBorderWidth, __NFUN_175__(__NFUN_175__(WinHeight, __NFUN_171__(float(2), m_fHBorderHeight)), __NFUN_171__(float(2), m_fVBorderPadding)), float(m_VBorderTextureRegion.X), float(m_VBorderTextureRegion.Y), float(m_VBorderTextureRegion.W), float(m_VBorderTextureRegion.H), m_VBorderTexture);
		}
	}
	// End:0x5A4
	if(__NFUN_123__(Text, ""))
	{
		tempSpace = C.SpaceX;
		C.Font = m_Font;
		C.SpaceX = m_fFontSpacing;
		C.__NFUN_2626__(TextColor.R, TextColor.G, TextColor.B);
		C.Style = byte(m_TextDrawstyle);
		ClipText(C, TextX, TextY, Text, true);
	}
	return;
}

function SetProperties(string _text, UWindowBase.TextAlign _Align, Font _TypeOfFont, Color _TextColor, bool _bDrawBorders)
{
	Text = _text;
	Align = _Align;
	m_Font = _TypeOfFont;
	TextColor = _TextColor;
	m_bDrawBorders = _bDrawBorders;
	m_bRefresh = true;
	return;
}

/////////////////////////////////////////////////////////////////
// set a new text and update the position or not depending of _bRefresh
/////////////////////////////////////////////////////////////////
function SetNewText(string _szNewText, bool _bRefresh)
{
	Text = _szNewText;
	m_bRefresh = _bRefresh;
	return;
}

defaultproperties
{
	m_TextDrawstyle=3
	m_DrawStyle=5
	m_bDrawBorders=true
	m_bRefresh=true
	m_fLMarge=2.0000000
	m_fHBorderHeight=1.0000000
	m_fVBorderWidth=1.0000000
	m_BGTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_HBorderTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_VBorderTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_BGTextureRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=24866,ZoneNumber=0)
	m_HBorderTextureRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=16418,ZoneNumber=0)
	m_VBorderTextureRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=16418,ZoneNumber=0)
	TextColor=(R=255,G=255,B=255,A=0)
	m_BGColor=(R=255,G=255,B=255,A=0)
}
