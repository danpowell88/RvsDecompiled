//=============================================================================
// R6WindowRadioButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowRadioButton.uc : Default Buttons used for radio buttons
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/01/07 * Created by Alexandre Dionne
//=============================================================================
class R6WindowRadioButton extends R6WindowButton;

var bool bCenter;

function Paint(Canvas C, float X, float Y)
{
	// End:0x22
	if(__NFUN_119__(m_buttonFont, none))
	{
		C.Font = m_buttonFont;		
	}
	else
	{
		C.Font = Root.Fonts[Font];
	}
	// End:0x69
	if(m_bDrawBorders)
	{
		R6WindowLookAndFeel(LookAndFeel).DrawButtonBorder(self, C, true);
	}
	C.Style = byte(m_iDrawStyle);
	C.__NFUN_2626__(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	// End:0x186
	if(bDisabled)
	{
		// End:0x183
		if(__NFUN_119__(DisabledTexture, none))
		{
			// End:0x139
			if(bUseRegion)
			{
				DrawStretchedTextureSegment(C, ImageX, ImageY, __NFUN_171__(float(DisabledRegion.W), RegionScale), __NFUN_171__(float(DisabledRegion.H), RegionScale), float(DisabledRegion.X), float(DisabledRegion.Y), float(DisabledRegion.W), float(DisabledRegion.H), DisabledTexture);				
			}
			else
			{
				// End:0x169
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
		// End:0x304
		if(m_bSelected)
		{
			// End:0x301
			if(__NFUN_119__(DownTexture, none))
			{
				// End:0x23B
				if(__NFUN_130__(bUseRegion, bCenter))
				{
					DrawStretchedTextureSegment(C, __NFUN_172__(__NFUN_175__(WinWidth, float(DownRegion.W)), float(2)), __NFUN_172__(__NFUN_175__(WinHeight, float(DownRegion.H)), float(2)), float(DownRegion.W), float(DownRegion.H), float(DownRegion.X), float(DownRegion.Y), float(DownRegion.W), float(DownRegion.H), DownTexture);					
				}
				else
				{
					// End:0x2B7
					if(bUseRegion)
					{
						DrawStretchedTextureSegment(C, ImageX, ImageY, __NFUN_171__(float(DownRegion.W), RegionScale), __NFUN_171__(float(DownRegion.H), RegionScale), float(DownRegion.X), float(DownRegion.Y), float(DownRegion.W), float(DownRegion.H), DownTexture);						
					}
					else
					{
						// End:0x2E7
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
			// End:0x3E1
			if(MouseIsOver())
			{
				// End:0x3DE
				if(__NFUN_119__(OverTexture, none))
				{
					// End:0x394
					if(bUseRegion)
					{
						DrawStretchedTextureSegment(C, ImageX, ImageY, __NFUN_171__(float(OverRegion.W), RegionScale), __NFUN_171__(float(OverRegion.H), RegionScale), float(OverRegion.X), float(OverRegion.Y), float(OverRegion.W), float(OverRegion.H), OverTexture);						
					}
					else
					{
						// End:0x3C4
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
				// End:0x4B2
				if(__NFUN_119__(UpTexture, none))
				{
					// End:0x468
					if(bUseRegion)
					{
						DrawStretchedTextureSegment(C, ImageX, ImageY, __NFUN_171__(float(UpRegion.W), RegionScale), __NFUN_171__(float(UpRegion.H), RegionScale), float(UpRegion.X), float(UpRegion.Y), float(UpRegion.W), float(UpRegion.H), UpTexture);						
					}
					else
					{
						// End:0x498
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
	// End:0x5B6
	if(__NFUN_123__(Text, ""))
	{
		// End:0x505
		if(bDisabled)
		{
			C.__NFUN_2626__(m_DisabledTextColor.R, m_DisabledTextColor.G, m_DisabledTextColor.B);			
		}
		else
		{
			// End:0x53B
			if(m_bSelected)
			{
				C.__NFUN_2626__(m_SelectedTextColor.R, m_SelectedTextColor.G, m_SelectedTextColor.B);				
			}
			else
			{
				// End:0x571
				if(MouseIsOver())
				{
					C.__NFUN_2626__(m_OverTextColor.R, m_OverTextColor.G, m_OverTextColor.B);					
				}
				else
				{
					C.__NFUN_2626__(TextColor.R, TextColor.G, TextColor.B);
				}
			}
		}
		ClipText(C, TextX, TextY, Text, true);
	}
	return;
}

defaultproperties
{
	bCenter=true
	m_iDrawStyle=5
	m_bDrawBorders=true
	bUseRegion=true
	ImageX=2.0000000
	ImageY=2.0000000
	DownTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	DownRegion=(Zone=Class'R6Window.R6WindowListBoxItem',iLeaf=13346,ZoneNumber=0)
}
