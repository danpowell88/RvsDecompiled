//=============================================================================
// R6WindowButtonSort - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowButtonSort.uc : Text buttons with triangle for type of sort
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/09/16 Created by Yannick Joly
//=============================================================================
class R6WindowButtonSort extends UWindowButton;

var bool m_bDrawSimpleBorder;
var bool m_bSetParam;  // Use to set the param in before paint one time
var bool m_bAscending;  // The selection is ascending or descending
var bool m_bDrawSortIcon;  // This button have to draw the sort icon
var bool m_bAbleToDrawSortIcon;  // If the button have enought space to draw the sort icon
var float m_fLMarge;
var float m_fXSortIconPos;  // pos in X of the icon
var float m_fYSortIconPos;  // pos in Y of the icon
var Texture m_TSortIcon;  // The icon for sort
var Font m_buttonFont;
var Region m_RSortIcon;  // The region of the triangle -- representation of ascending--descending

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H, fWidth;

	// End:0x1B2
	if(m_bSetParam)
	{
		m_bSetParam = false;
		// End:0x1B2
		if(__NFUN_123__(Text, ""))
		{
			// End:0x3F
			if(__NFUN_119__(m_buttonFont, none))
			{
				C.Font = m_buttonFont;				
			}
			else
			{
				C.Font = Root.Fonts[Font];
			}
			TextSize(C, Text, W, H);
			fWidth = WinWidth;
			// End:0x126
			if(__NFUN_176__(__NFUN_174__(__NFUN_174__(W, float(m_RSortIcon.W)), float(5)), WinWidth))
			{
				m_bAbleToDrawSortIcon = true;
				fWidth = __NFUN_175__(__NFUN_175__(WinWidth, float(m_RSortIcon.W)), float(5));
				m_fXSortIconPos = __NFUN_175__(__NFUN_175__(WinWidth, float(m_RSortIcon.W)), float(4));
				m_fYSortIconPos = __NFUN_172__(__NFUN_175__(WinHeight, float(m_RSortIcon.H)), float(2));
				m_fYSortIconPos = float(int(__NFUN_174__(m_fYSortIconPos, 0.5000000)));
			}
			switch(Align)
			{
				// End:0x140
				case 0:
					TextX = m_fLMarge;
					// End:0x184
					break;
				// End:0x15A
				case 1:
					TextX = __NFUN_175__(fWidth, W);
					// End:0x184
					break;
				// End:0x181
				case 2:
					TextX = __NFUN_174__(__NFUN_172__(__NFUN_175__(fWidth, W), float(2)), 0.5000000);
					// End:0x184
					break;
				// End:0xFFFF
				default:
					break;
			}
			TextY = __NFUN_172__(__NFUN_175__(WinHeight, H), float(2));
			TextY = float(int(__NFUN_174__(TextY, 0.5000000)));
		}
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	// End:0x164
	if(__NFUN_123__(Text, ""))
	{
		C.Style = 1;
		C.SpaceX = 0.0000000;
		C.Font = m_buttonFont;
		// End:0x164
		if(__NFUN_123__(Text, ""))
		{
			// End:0x92
			if(bDisabled)
			{
				C.__NFUN_2626__(m_DisabledTextColor.R, m_DisabledTextColor.G, m_DisabledTextColor.B);
				m_BorderColor = m_DisabledTextColor;				
			}
			else
			{
				// End:0xD3
				if(m_bSelected)
				{
					C.__NFUN_2626__(m_SelectedTextColor.R, m_SelectedTextColor.G, m_SelectedTextColor.B);
					m_BorderColor = m_SelectedTextColor;					
				}
				else
				{
					// End:0x114
					if(MouseIsOver())
					{
						C.__NFUN_2626__(m_OverTextColor.R, m_OverTextColor.G, m_OverTextColor.B);
						m_BorderColor = m_OverTextColor;						
					}
					else
					{
						C.__NFUN_2626__(TextColor.R, TextColor.G, TextColor.B);
						m_BorderColor = TextColor;
					}
				}
			}
			ClipText(C, TextX, TextY, Text, true);
		}
	}
	// End:0x261
	if(m_bDrawSortIcon)
	{
		// End:0x261
		if(m_bAbleToDrawSortIcon)
		{
			C.Style = 5;
			// End:0x1FA
			if(m_bAscending)
			{
				DrawStretchedTextureSegmentRot(C, m_fXSortIconPos, m_fYSortIconPos, float(m_RSortIcon.W), float(m_RSortIcon.H), float(m_RSortIcon.X), float(m_RSortIcon.Y), float(m_RSortIcon.W), float(m_RSortIcon.H), m_TSortIcon, -1.5700000);				
			}
			else
			{
				DrawStretchedTextureSegmentRot(C, m_fXSortIconPos, m_fYSortIconPos, float(m_RSortIcon.W), float(m_RSortIcon.H), float(m_RSortIcon.X), float(m_RSortIcon.Y), float(m_RSortIcon.W), float(m_RSortIcon.H), m_TSortIcon, 1.5700000);
			}
		}
	}
	// End:0x275
	if(m_bDrawSimpleBorder)
	{
		DrawSimpleBorder(C);
	}
	return;
}

defaultproperties
{
	m_bDrawSimpleBorder=true
	m_bSetParam=true
	m_fLMarge=2.0000000
	m_TSortIcon=Texture'R6MenuTextures.Gui_BoxScroll'
	m_RSortIcon=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=20514,ZoneNumber=0)
	m_iButtonID=-1
}
