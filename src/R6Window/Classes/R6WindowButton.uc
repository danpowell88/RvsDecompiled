//=============================================================================
// R6WindowButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowButton extends UWindowButton;

enum eButtonType
{
	eNormalButton,                  // 0
	eCounterButton                  // 1
};

// NEW IN 1.60
var R6WindowButton.eButtonType m_eButtonType;
var int m_iDrawStyle;
var bool m_bResizeToText;
var bool m_bDrawBorders;
var bool m_bDrawSimpleBorder;
var bool m_bDrawSpecialBorder;
var bool m_bSetParam;  // Use to set the param in before paint one time
var bool m_bDefineBorderColor;
var bool m_bCheckForDownSizeFont;  // Switch to m_DownSizeFont is text doesn't fit the button
var float m_fLMarge;  // Usefull for text aligned left or to keep space at left of the text when we resize button to text
var float m_fRMarge;  // Usefull for text aligned right or to keep space at right of the text when we resize button to text
var float m_fFontSpacing;
var float m_fDownSizeFontSpacing;
var float m_textSize;
var float m_fTotalButtonsSize;  // this work with previous button pos
var float m_fMaxWinWidth;  // When we ask a button to resize make sure he doesn't grow to big
var float m_fOrgWinLeft;  // When we ask for resize text with different text size and the align is not TA_left, use org winleft
var R6WindowButton m_pRefButtonPos;  // the button that store size of all buttons
var R6WindowButton m_pPreviousButtonPos;  // If we have a previous button pos to positioning your current button
var Font m_buttonFont;
var Font m_DownSizeFont;  // Font to downsize to if text doesn't fit
var Texture m_BGSelecTexture;  // The background texture when you selected the button
var Color m_vButtonColor;

function Created()
{
	super.Created();
	m_fMaxWinWidth = WinWidth;
	m_fOrgWinLeft = WinLeft;
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H, TextWidth;

	// End:0x220
	if(m_bSetParam)
	{
		m_bSetParam = false;
		// End:0x220
		if((Text != ""))
		{
			// End:0x3F
			if((m_buttonFont != none))
			{
				C.Font = m_buttonFont;				
			}
			else
			{
				C.Font = Root.Fonts[Font];
			}
			TextSize(C, Text, W, H);
			TextWidth = (W + (float(Len(Text)) * m_fFontSpacing));
			switch(Align)
			{
				// End:0xB4
				case 0:
					TextX = m_fLMarge;
					// End:0xF8
					break;
				// End:0xD5
				case 1:
					TextX = ((WinWidth - m_fRMarge) - TextWidth);
					// End:0xF8
					break;
				// End:0xF5
				case 2:
					TextX = ((WinWidth - TextWidth) / float(2));
					// End:0xF8
					break;
				// End:0xFFFF
				default:
					break;
			}
			TextY = ((WinHeight - H) / float(2));
			TextY = float(int((TextY + 0.5000000)));
			// End:0x180
			if(m_bCheckForDownSizeFont)
			{
				m_bCheckForDownSizeFont = false;
				// End:0x170
				if(((m_DownSizeFont != none) && ((TextX + TextWidth) > WinWidth)))
				{
					m_buttonFont = m_DownSizeFont;
					m_fFontSpacing = m_fDownSizeFontSpacing;
				}
				m_bSetParam = m_bResizeToText;				
			}
			else
			{
				// End:0x1F5
				if(m_bResizeToText)
				{
					m_textSize = TextWidth;
					WinWidth = FMin(((m_textSize + m_fLMarge) + m_fRMarge), m_fMaxWinWidth);
					// End:0x1E2
					if((int(Align) != int(0)))
					{
						WinLeft = m_fOrgWinLeft;
						(WinLeft += (TextX - m_fLMarge));
					}
					TextX = m_fLMarge;
					m_bResizeToText = false;
				}
			}
			m_fTotalButtonsSize = WinWidth;
			// End:0x220
			if((m_pRefButtonPos != none))
			{
				(m_pRefButtonPos.m_fTotalButtonsSize += WinWidth);
			}
		}
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local float tempSpace;
	local Color vBorderColor;

	C.Style = byte(m_iDrawStyle);
	C.SetDrawColor(m_vButtonColor.R, m_vButtonColor.G, m_vButtonColor.B);
	// End:0x1A4
	if(bDisabled)
	{
		// End:0x1A1
		if((DisabledTexture != none))
		{
			// End:0xDB
			if((bUseRegion && bStretched))
			{
				DrawStretchedTextureSegment(C, ImageX, ImageY, (float(DisabledRegion.W) * RegionScale), (float(DisabledRegion.H) * RegionScale), float(DisabledRegion.X), float(DisabledRegion.Y), float(DisabledRegion.W), float(DisabledRegion.H), DisabledTexture);				
			}
			else
			{
				// End:0x157
				if(bUseRegion)
				{
					DrawStretchedTextureSegment(C, ImageX, ImageY, (float(DisabledRegion.W) * RegionScale), (float(DisabledRegion.H) * RegionScale), float(DisabledRegion.X), float(DisabledRegion.Y), float(DisabledRegion.W), float(DisabledRegion.H), DisabledTexture);					
				}
				else
				{
					// End:0x187
					if(bStretched)
					{
						DrawStretchedTexture(C, ImageX, ImageY, WinWidth, WinHeight, DisabledTexture);						
					}
					else
					{
						DrawClippedTexture(C, ImageX, ImageY, DisabledTexture);
					}
				}
			}
		}		
	}
	else
	{
		// End:0x2EC
		if(bMouseDown)
		{
			// End:0x2E9
			if((DownTexture != none))
			{
				// End:0x223
				if((bUseRegion && bStretched))
				{
					DrawStretchedTextureSegment(C, ImageX, ImageY, WinWidth, WinHeight, float(DownRegion.X), float(DownRegion.Y), float(DownRegion.W), float(DownRegion.H), DownTexture);					
				}
				else
				{
					// End:0x29F
					if(bUseRegion)
					{
						DrawStretchedTextureSegment(C, ImageX, ImageY, (float(DownRegion.W) * RegionScale), (float(DownRegion.H) * RegionScale), float(DownRegion.X), float(DownRegion.Y), float(DownRegion.W), float(DownRegion.H), DownTexture);						
					}
					else
					{
						// End:0x2CF
						if(bStretched)
						{
							DrawStretchedTexture(C, ImageX, ImageY, WinWidth, WinHeight, DownTexture);							
						}
						else
						{
							DrawClippedTexture(C, ImageX, ImageY, DownTexture);
						}
					}
				}
			}			
		}
		else
		{
			// End:0x434
			if(MouseIsOver())
			{
				// End:0x431
				if((OverTexture != none))
				{
					// End:0x36B
					if((bUseRegion && bStretched))
					{
						DrawStretchedTextureSegment(C, ImageX, ImageY, WinWidth, WinHeight, float(OverRegion.X), float(OverRegion.Y), float(OverRegion.W), float(OverRegion.H), OverTexture);						
					}
					else
					{
						// End:0x3E7
						if(bUseRegion)
						{
							DrawStretchedTextureSegment(C, ImageX, ImageY, (float(OverRegion.W) * RegionScale), (float(OverRegion.H) * RegionScale), float(OverRegion.X), float(OverRegion.Y), float(OverRegion.W), float(OverRegion.H), OverTexture);							
						}
						else
						{
							// End:0x417
							if(bStretched)
							{
								DrawStretchedTexture(C, ImageX, ImageY, WinWidth, WinHeight, OverTexture);								
							}
							else
							{
								DrawClippedTexture(C, ImageX, ImageY, OverTexture);
							}
						}
					}
				}				
			}
			else
			{
				// End:0x570
				if((UpTexture != none))
				{
					// End:0x4AA
					if((bUseRegion && bStretched))
					{
						DrawStretchedTextureSegment(C, ImageX, ImageY, WinWidth, WinHeight, float(UpRegion.X), float(UpRegion.Y), float(UpRegion.W), float(UpRegion.H), UpTexture);						
					}
					else
					{
						// End:0x526
						if(bUseRegion)
						{
							DrawStretchedTextureSegment(C, ImageX, ImageY, (float(UpRegion.W) * RegionScale), (float(UpRegion.H) * RegionScale), float(UpRegion.X), float(UpRegion.Y), float(UpRegion.W), float(UpRegion.H), UpTexture);							
						}
						else
						{
							// End:0x556
							if(bStretched)
							{
								DrawStretchedTexture(C, ImageX, ImageY, WinWidth, WinHeight, UpTexture);								
							}
							else
							{
								DrawClippedTexture(C, ImageX, ImageY, UpTexture);
							}
						}
					}
				}
			}
		}
	}
	// End:0x72D
	if((Text != ""))
	{
		// End:0x59E
		if((m_buttonFont != none))
		{
			C.Font = m_buttonFont;			
		}
		else
		{
			C.Font = Root.Fonts[Font];
		}
		C.Style = 1;
		tempSpace = C.SpaceX;
		C.SpaceX = m_fFontSpacing;
		// End:0x72D
		if((Text != ""))
		{
			// End:0x647
			if(bDisabled)
			{
				C.SetDrawColor(m_DisabledTextColor.R, m_DisabledTextColor.G, m_DisabledTextColor.B);
				m_BorderColor = m_DisabledTextColor;				
			}
			else
			{
				// End:0x688
				if(m_bSelected)
				{
					C.SetDrawColor(m_SelectedTextColor.R, m_SelectedTextColor.G, m_SelectedTextColor.B);
					m_BorderColor = m_SelectedTextColor;					
				}
				else
				{
					// End:0x6C9
					if(MouseIsOver())
					{
						C.SetDrawColor(m_OverTextColor.R, m_OverTextColor.G, m_OverTextColor.B);
						m_BorderColor = m_OverTextColor;						
					}
					else
					{
						C.SetDrawColor(TextColor.R, TextColor.G, TextColor.B);
						m_BorderColor = TextColor;
					}
				}
			}
			ClipText(C, TextX, TextY, Text, true);
			C.SpaceX = tempSpace;
		}
	}
	// End:0x79D
	if(m_bDrawBorders)
	{
		// End:0x766
		if(m_bDrawSpecialBorder)
		{
			R6WindowLookAndFeel(LookAndFeel).DrawSpecialButtonBorder(self, C, X, Y);			
		}
		else
		{
			// End:0x77D
			if(m_bDrawSimpleBorder)
			{
				DrawSimpleBorder(C);				
			}
			else
			{
				R6WindowLookAndFeel(LookAndFeel).DrawButtonBorder(self, C, m_bDefineBorderColor);
			}
		}
	}
	return;
}

//This function Allow a button to to change to a fall back
//Font if the current text doesn't fit in it's size;
function CheckToDownSizeFont(Font _FallBackFont, float _FallBackFontSpacing)
{
	m_DownSizeFont = _FallBackFont;
	m_fDownSizeFontSpacing = _FallBackFontSpacing;
	m_bCheckForDownSizeFont = true;
	m_bSetParam = true;
	return;
}

//===========================================================================================================
// This function indicate if text fits in the button width
//===========================================================================================================
function bool IsFontDownSizingNeeded()
{
	local float W, H, TextWidth, TextXPos;
	local Canvas C;

	C = Class'Engine.Actor'.static.GetCanvas();
	// End:0x34
	if((m_buttonFont != none))
	{
		C.Font = m_buttonFont;		
	}
	else
	{
		C.Font = Root.Fonts[Font];
	}
	TextSize(C, Text, W, H);
	TextWidth = (W + (float(Len(Text)) * m_fFontSpacing));
	switch(Align)
	{
		// End:0xA9
		case 0:
			TextXPos = m_fLMarge;
			// End:0xED
			break;
		// End:0xCA
		case 1:
			TextXPos = ((WinWidth - m_fRMarge) - TextWidth);
			// End:0xED
			break;
		// End:0xEA
		case 2:
			TextXPos = ((WinWidth - TextWidth) / float(2));
			// End:0xED
			break;
		// End:0xFFFF
		default:
			break;
	}
	return ((TextXPos + TextWidth) > WinWidth);
	return;
}

function ResizeToText()
{
	WinWidth = m_fMaxWinWidth;
	m_bResizeToText = true;
	m_bSetParam = true;
	return;
}

function SetButtonBorderColor(Color _vButtonBorderColor)
{
	m_bDefineBorderColor = true;
	m_BorderColor = _vButtonBorderColor;
	return;
}

function int GetButtonType()
{
	return int(m_eButtonType);
	return;
}

defaultproperties
{
	m_iDrawStyle=1
	m_bSetParam=true
	m_fLMarge=2.0000000
	m_vButtonColor=(R=255,G=255,B=255,A=0)
	m_iButtonID=-1
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var eButtonType
