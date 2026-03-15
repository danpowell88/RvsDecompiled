//=============================================================================
// UWindowButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// UWindowButton - A button
//=============================================================================
class UWindowButton extends UWindowDialogControl;

var int m_iButtonID;  // Can be used to set a special Id to this button
var bool bDisabled;
var bool bStretched;
var bool bUseRegion;
//Button is Selected
var bool m_bSelected;
var bool m_bDrawButtonBorders;
var bool m_bUseRotAngle;
//R6CODE
var bool m_bPlayButtonSnd;
var bool m_bWaitSoundFinish;
var bool m_bSoundStart;
var float RegionScale;
var float ImageX;
// NEW IN 1.60
var float ImageY;
var float m_fRotAngle;  // Rad
var float m_fRotAngleWidth;
var float m_fRotAngleHeight;
var Texture UpTexture;
// NEW IN 1.60
var Texture DownTexture;
// NEW IN 1.60
var Texture DisabledTexture;
// NEW IN 1.60
var Texture OverTexture;
var Sound OverSound;
// NEW IN 1.60
var Sound DownSound;
var Region UpRegion;
// NEW IN 1.60
var Region DownRegion;
// NEW IN 1.60
var Region DisabledRegion;
// NEW IN 1.60
var Region OverRegion;
//Different State TextColor
var Color m_SelectedTextColor;
var Color m_DisabledTextColor;
var Color m_OverTextColor;

function Created()
{
	super.Created();
	TextColor = Root.Colors.ButtonTextColor[0];
	m_DisabledTextColor = Root.Colors.ButtonTextColor[1];
	m_OverTextColor = Root.Colors.ButtonTextColor[2];
	m_SelectedTextColor = Root.Colors.ButtonTextColor[3];
	m_fRotAngleWidth = WinWidth;
	m_fRotAngleHeight = WinHeight;
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	C.Font = Root.Fonts[Font];
	return;
}

function Paint(Canvas C, float X, float Y)
{
	C.Font = Root.Fonts[Font];
	C.Style = 5;
	// End:0x17A
	if(bDisabled)
	{
		// End:0x177
		if((DisabledTexture != none))
		{
			// End:0x12D
			if(bUseRegion)
			{
				// End:0xB6
				if(m_bUseRotAngle)
				{
					DrawStretchedTextureSegmentRot(C, ImageX, ImageY, m_fRotAngleWidth, m_fRotAngleHeight, float(DisabledRegion.X), float(DisabledRegion.Y), float(DisabledRegion.W), float(DisabledRegion.H), DisabledTexture, m_fRotAngle);					
				}
				else
				{
					DrawStretchedTextureSegment(C, ImageX, ImageY, Abs((float(DisabledRegion.W) * RegionScale)), Abs((float(DisabledRegion.H) * RegionScale)), float(DisabledRegion.X), float(DisabledRegion.Y), float(DisabledRegion.W), float(DisabledRegion.H), DisabledTexture);
				}				
			}
			else
			{
				// End:0x15D
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
		// End:0x2C0
		if(bMouseDown)
		{
			// End:0x2BD
			if((DownTexture != none))
			{
				// End:0x273
				if(bUseRegion)
				{
					// End:0x1FC
					if(m_bUseRotAngle)
					{
						DrawStretchedTextureSegmentRot(C, ImageX, ImageY, m_fRotAngleWidth, m_fRotAngleHeight, float(DownRegion.X), float(DownRegion.Y), float(DownRegion.W), float(DownRegion.H), DownTexture, m_fRotAngle);						
					}
					else
					{
						DrawStretchedTextureSegment(C, ImageX, ImageY, Abs((float(DownRegion.W) * RegionScale)), Abs((float(DownRegion.H) * RegionScale)), float(DownRegion.X), float(DownRegion.Y), float(DownRegion.W), float(DownRegion.H), DownTexture);
					}					
				}
				else
				{
					// End:0x2A3
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
			// End:0x406
			if(MouseIsOver())
			{
				// End:0x403
				if((OverTexture != none))
				{
					// End:0x3B9
					if(bUseRegion)
					{
						// End:0x342
						if(m_bUseRotAngle)
						{
							DrawStretchedTextureSegmentRot(C, ImageX, ImageY, m_fRotAngleWidth, m_fRotAngleHeight, float(OverRegion.X), float(OverRegion.Y), float(OverRegion.W), float(OverRegion.H), OverTexture, m_fRotAngle);							
						}
						else
						{
							DrawStretchedTextureSegment(C, ImageX, ImageY, Abs((float(OverRegion.W) * RegionScale)), Abs((float(OverRegion.H) * RegionScale)), float(OverRegion.X), float(OverRegion.Y), float(OverRegion.W), float(OverRegion.H), OverTexture);
						}						
					}
					else
					{
						// End:0x3E9
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
				// End:0x540
				if((UpTexture != none))
				{
					// End:0x4F6
					if(bUseRegion)
					{
						// End:0x47F
						if(m_bUseRotAngle)
						{
							DrawStretchedTextureSegmentRot(C, ImageX, ImageY, m_fRotAngleWidth, m_fRotAngleHeight, float(UpRegion.X), float(UpRegion.Y), float(UpRegion.W), float(UpRegion.H), UpTexture, m_fRotAngle);							
						}
						else
						{
							DrawStretchedTextureSegment(C, ImageX, ImageY, Abs((float(UpRegion.W) * RegionScale)), Abs((float(UpRegion.H) * RegionScale)), float(UpRegion.X), float(UpRegion.Y), float(UpRegion.W), float(UpRegion.H), UpTexture);
						}						
					}
					else
					{
						// End:0x526
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
	// End:0x554
	if(m_bDrawButtonBorders)
	{
		DrawSimpleBorder(C);
	}
	// End:0x647
	if((Text != ""))
	{
		// End:0x596
		if(bDisabled)
		{
			C.SetDrawColor(m_DisabledTextColor.R, m_DisabledTextColor.G, m_DisabledTextColor.B);			
		}
		else
		{
			// End:0x5CC
			if(m_bSelected)
			{
				C.SetDrawColor(m_SelectedTextColor.R, m_SelectedTextColor.G, m_SelectedTextColor.B);				
			}
			else
			{
				// End:0x602
				if(MouseIsOver())
				{
					C.SetDrawColor(m_OverTextColor.R, m_OverTextColor.G, m_OverTextColor.B);					
				}
				else
				{
					C.SetDrawColor(TextColor.R, TextColor.G, TextColor.B);
				}
			}
		}
		ClipText(C, TextX, TextY, Text, true);
	}
	return;
}

function AfterPaint(Canvas C, float X, float Y)
{
	// End:0x38
	if((m_bSoundStart && (!GetPlayerOwner().IsPlayingSound(GetPlayerOwner(), DownSound))))
	{
		Notify(2);
		m_bSoundStart = false;
	}
	return;
}

simulated function Click(float X, float Y)
{
	// End:0x0B
	if(bDisabled)
	{
		return;
	}
	// End:0x48
	if((m_bPlayButtonSnd && (DownSound != none)))
	{
		GetPlayerOwner().PlaySound(DownSound, 9);
		// End:0x48
		if(m_bWaitSoundFinish)
		{
			m_bSoundStart = true;
			return;
		}
	}
	Notify(2);
	return;
}

function DoubleClick(float X, float Y)
{
	// End:0x13
	if((!bDisabled))
	{
		Notify(11);
	}
	return;
}

function RClick(float X, float Y)
{
	// End:0x13
	if((!bDisabled))
	{
		Notify(6);
	}
	return;
}

function MClick(float X, float Y)
{
	// End:0x13
	if((!bDisabled))
	{
		Notify(5);
	}
	return;
}

defaultproperties
{
	m_bPlayButtonSnd=true
	RegionScale=1.0000000
	m_fRotAngle=1.5700000
	DownSound=Sound'SFX_Menus.Play_Button_Selection'
	bIgnoreLDoubleClick=true
	bIgnoreMDoubleClick=true
	bIgnoreRDoubleClick=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var n
// REMOVED IN 1.60: var Y
// REMOVED IN 1.60: var d
