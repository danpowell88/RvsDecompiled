//=============================================================================
// R6WindowStayDownButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowStayDownButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowStayDownButton extends R6WindowButton;

var bool m_bCanBeUnselected;
var bool m_bCheckSelectState;
var bool m_bUseOnlyNotifyMsg;  // the state of button selection is change outside, by a notify msg to button creator

function Paint(Canvas C, float X, float Y)
{
	local float tempSpace;

	// End:0x22
	if(__NFUN_119__(m_buttonFont, none))
	{
		C.Font = m_buttonFont;		
	}
	else
	{
		C.Font = Root.Fonts[Font];
	}
	C.Style = byte(m_iDrawStyle);
	// End:0x138
	if(bDisabled)
	{
		// End:0x135
		if(__NFUN_119__(DisabledTexture, none))
		{
			// End:0xEB
			if(bUseRegion)
			{
				DrawStretchedTextureSegment(C, ImageX, ImageY, __NFUN_171__(float(DisabledRegion.W), RegionScale), __NFUN_171__(float(DisabledRegion.H), RegionScale), float(DisabledRegion.X), float(DisabledRegion.Y), float(DisabledRegion.W), float(DisabledRegion.H), DisabledTexture);				
			}
			else
			{
				// End:0x11B
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
	else
	{
		// End:0x220
		if(__NFUN_132__(bMouseDown, m_bSelected))
		{
			// End:0x21D
			if(__NFUN_119__(DownTexture, none))
			{
				// End:0x1D3
				if(bUseRegion)
				{
					DrawStretchedTextureSegment(C, ImageX, ImageY, __NFUN_171__(float(DownRegion.W), RegionScale), __NFUN_171__(float(DownRegion.H), RegionScale), float(DownRegion.X), float(DownRegion.Y), float(DownRegion.W), float(DownRegion.H), DownTexture);					
				}
				else
				{
					// End:0x203
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
		else
		{
			// End:0x2FD
			if(MouseIsOver())
			{
				// End:0x2FA
				if(__NFUN_119__(OverTexture, none))
				{
					// End:0x2B0
					if(bUseRegion)
					{
						DrawStretchedTextureSegment(C, ImageX, ImageY, __NFUN_171__(float(OverRegion.W), RegionScale), __NFUN_171__(float(OverRegion.H), RegionScale), float(OverRegion.X), float(OverRegion.Y), float(OverRegion.W), float(OverRegion.H), OverTexture);						
					}
					else
					{
						// End:0x2E0
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
			else
			{
				// End:0x3CE
				if(__NFUN_119__(UpTexture, none))
				{
					// End:0x384
					if(bUseRegion)
					{
						DrawStretchedTextureSegment(C, ImageX, ImageY, __NFUN_171__(float(UpRegion.W), RegionScale), __NFUN_171__(float(UpRegion.H), RegionScale), float(UpRegion.X), float(UpRegion.Y), float(UpRegion.W), float(UpRegion.H), UpTexture);						
					}
					else
					{
						// End:0x3B4
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
	C.Style = 1;
	// End:0x53A
	if(__NFUN_123__(Text, ""))
	{
		// End:0x42C
		if(bDisabled)
		{
			C.__NFUN_2626__(m_DisabledTextColor.R, m_DisabledTextColor.G, m_DisabledTextColor.B);
			m_BorderColor = m_DisabledTextColor;			
		}
		else
		{
			// End:0x46D
			if(m_bSelected)
			{
				C.__NFUN_2626__(m_SelectedTextColor.R, m_SelectedTextColor.G, m_SelectedTextColor.B);
				m_BorderColor = m_SelectedTextColor;				
			}
			else
			{
				// End:0x4AE
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
		tempSpace = C.SpaceX;
		C.SpaceX = m_fFontSpacing;
		ClipText(C, TextX, TextY, Text, true);
		C.SpaceX = tempSpace;
	}
	return;
}

function LMouseDown(float X, float Y)
{
	local bool bChangeSelection;

	super(UWindowWindow).LMouseDown(X, Y);
	// End:0x1B
	if(bDisabled)
	{
		return;
	}
	// End:0x67
	if(__NFUN_129__(m_bUseOnlyNotifyMsg))
	{
		// End:0x67
		if(m_bCanBeUnselected)
		{
			bChangeSelection = true;
			// End:0x4F
			if(m_bCheckSelectState)
			{
				bChangeSelection = __NFUN_129__(m_bSelected);
			}
			// End:0x67
			if(bChangeSelection)
			{
				m_bSelected = __NFUN_129__(m_bSelected);
			}
		}
	}
	return;
}

defaultproperties
{
	m_bCanBeUnselected=true
}
