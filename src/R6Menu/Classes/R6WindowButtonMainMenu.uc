//=============================================================================
// R6WindowButtonMainMenu - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowButtonMainMenu.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  This is the class for main men button
//  Because of it's fancy (Thanks to Adrian) look
//  It will not rely on the look and feel to display
//	And will be very specific
//
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//=============================================================================
class R6WindowButtonMainMenu extends UWindowButton;

enum eButtonActionType
{
	Button_SinglePlayer,            // 0
	Button_CustomMission,           // 1
	Button_Multiplayer,             // 2
	Button_Training,                // 3
	Button_Options,                 // 4
	Button_Replays,                 // 5
	Button_Credits,                 // 6
	Button_Quit,                    // 7
	Button_UbiComQuit,              // 8
	Button_UbiComReturn             // 9
};

// NEW IN 1.60
var R6WindowButtonMainMenu.eButtonActionType m_eButton_Action;
var int m_iTextRightPadding;
var int m_iMinXPos;
// NEW IN 1.60
var int m_iMaxXPos;
// NEW IN 1.60
var int m_iTotalScroll;
var bool m_bResizeToText;
var float m_fProgressTime;
// NEW IN 1.60
var float m_TextWidth;
var float m_fLMarge;
var float m_fFontSpacing;
var Texture m_OverAlphaTexture;
// NEW IN 1.60
var Texture m_OverScrollingTexture;
var Font m_buttonFont;
var Region m_OverAlphaRegion;
// NEW IN 1.60
var Region m_OverScrollingRegion;
var Color m_DownTextColor;

function Created()
{
	super.Created();
	m_OverTextColor = Root.Colors.White;
	TextColor = Root.Colors.White;
	m_DownTextColor = Root.Colors.BlueLight;
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H, ftextSize;

	// End:0x22
	if((m_buttonFont != none))
	{
		C.Font = m_buttonFont;		
	}
	else
	{
		C.Font = Root.Fonts[Font];
	}
	TextSize(C, Text, W, H);
	switch(Align)
	{
		// End:0x7A
		case 0:
			TextX = m_fLMarge;
			// End:0xDB
			break;
		// End:0xA6
		case 1:
			TextX = ((WinWidth - W) - (float(Len(Text)) * m_fFontSpacing));
			// End:0xDB
			break;
		// End:0xD8
		case 2:
			TextX = (((WinWidth - W) - (float(Len(Text)) * m_fFontSpacing)) / float(2));
			// End:0xDB
			break;
		// End:0xFFFF
		default:
			break;
	}
	TextY = ((WinHeight - H) / float(2));
	TextY = float(int((TextY + 0.5000000)));
	// End:0x188
	if(m_bResizeToText)
	{
		ftextSize = (W + (float(Len(Text)) * m_fFontSpacing));
		WinWidth = ((ftextSize + m_fLMarge) + float(m_iTextRightPadding));
		// End:0x16D
		if((int(Align) != int(0)))
		{
			(WinLeft += (TextX - m_fLMarge));
		}
		TextX = m_fLMarge;
		Align = 0;
		m_bResizeToText = false;
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local float tH;
	local int currentTextStyle;

	C.Font = Root.Fonts[Font];
	TextSize(C, Text, m_TextWidth, tH);
	// End:0x12F
	if(bDisabled)
	{
		// End:0x118
		if((DisabledTexture != none))
		{
			// End:0xCE
			if(bUseRegion)
			{
				DrawStretchedTextureSegment(C, ImageX, ImageY, (float(DisabledRegion.W) * RegionScale), (float(DisabledRegion.H) * RegionScale), float(DisabledRegion.X), float(DisabledRegion.Y), float(DisabledRegion.W), float(DisabledRegion.H), DisabledTexture);				
			}
			else
			{
				// End:0xFE
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
		DrawButtonText(C, m_DisabledTextColor, int(3));		
	}
	else
	{
		// End:0x197
		if(bMouseDown)
		{
			DrawButtonBackGround(C, Root.Colors.Blue, 3);
			DrawButtonScrollEffect(C, Root.Colors.BlueLight, 3);
			DrawButtonText(C, m_DownTextColor, int(1));			
		}
		else
		{
			// End:0x1FF
			if(MouseIsOver())
			{
				DrawButtonBackGround(C, Root.Colors.Blue, 3);
				DrawButtonScrollEffect(C, Root.Colors.BlueLight, 3);
				DrawButtonText(C, m_OverTextColor, int(1));				
			}
			else
			{
				// End:0x2D0
				if((UpTexture != none))
				{
					// End:0x286
					if(bUseRegion)
					{
						DrawStretchedTextureSegment(C, ImageX, ImageY, (float(UpRegion.W) * RegionScale), (float(UpRegion.H) * RegionScale), float(UpRegion.X), float(UpRegion.Y), float(UpRegion.W), float(UpRegion.H), UpTexture);						
					}
					else
					{
						// End:0x2B6
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
				DrawButtonText(C, TextColor, int(1));
			}
		}
	}
	return;
}

function DrawButtonText(Canvas C, Color currentTextColor, int currentStyle)
{
	// End:0xC0
	if((Text != ""))
	{
		// End:0x2E
		if((m_buttonFont != none))
		{
			C.Font = m_buttonFont;			
		}
		else
		{
			C.Font = Root.Fonts[Font];
		}
		C.SpaceX = 0.0000000;
		C.SetDrawColor(currentTextColor.R, currentTextColor.G, currentTextColor.B);
		C.Style = byte(currentStyle);
		ClipText(C, TextX, TextY, Text, true);
	}
	return;
}

function DrawButtonBackGround(Canvas C, Color currentDrawColor, int currentStyle)
{
	C.Style = byte(currentStyle);
	C.SetDrawColor(currentDrawColor.R, currentDrawColor.G, currentDrawColor.B);
	// End:0xAD
	if((m_OverAlphaTexture != none))
	{
		DrawStretchedTextureSegment(C, 0.0000000, ImageY, float(m_OverAlphaRegion.W), float(m_OverAlphaRegion.H), float(m_OverAlphaRegion.X), float(m_OverAlphaRegion.Y), float(m_OverAlphaRegion.W), float(m_OverAlphaRegion.H), m_OverAlphaTexture);
	}
	// End:0x12C
	if((OverTexture != none))
	{
		DrawStretchedTextureSegment(C, float(m_OverAlphaRegion.W), ImageY, (WinWidth - float((2 * m_OverAlphaRegion.W))), float(OverRegion.H), float(OverRegion.X), float(OverRegion.Y), float(OverRegion.W), float(OverRegion.H), OverTexture);
	}
	// End:0x1B5
	if((m_OverAlphaTexture != none))
	{
		DrawStretchedTextureSegment(C, (WinWidth - float(m_OverAlphaRegion.W)), ImageY, float(m_OverAlphaRegion.W), float(m_OverAlphaRegion.H), float((m_OverAlphaRegion.X + m_OverAlphaRegion.W)), float(m_OverAlphaRegion.Y), float((-m_OverAlphaRegion.W)), float(m_OverAlphaRegion.H), m_OverAlphaTexture);
	}
	return;
}

function DrawButtonScrollEffect(Canvas C, Color currentDrawColor, int currentStyle)
{
	local int targetPos, lastDisplayedPos, iDisplayXPos, iWidthModifier;
	local R6MenuRSLookAndFeel currentLookAndFeel;

	m_iMinXPos = int((TextX - float((m_OverScrollingRegion.W / 2))));
	m_iMaxXPos = int(((WinWidth - float(m_iTextRightPadding)) - float((m_OverScrollingRegion.W / 2))));
	m_iTotalScroll = (m_iMaxXPos - m_iMinXPos);
	currentLookAndFeel = R6MenuRSLookAndFeel(LookAndFeel);
	// End:0x25B
	if((currentLookAndFeel != none))
	{
		m_fProgressTime = FClamp(m_fProgressTime, 0.0000000, (float(m_iTotalScroll) / currentLookAndFeel.m_fScrollRate));
		// End:0xE6
		if(((m_fProgressTime == 0.0000000) || (m_fProgressTime == (float(m_iTotalScroll) / currentLookAndFeel.m_fScrollRate))))
		{
			(currentLookAndFeel.m_iMultiplyer *= float(-1));
		}
		targetPos = int((m_fProgressTime * currentLookAndFeel.m_fScrollRate));
		iDisplayXPos = Clamp((m_iMinXPos + targetPos), int((TextX - float(m_iTextRightPadding))), m_iMaxXPos);
		iWidthModifier = 0;
		// End:0x17C
		if((float((m_iMinXPos + targetPos)) < (TextX - float(m_iTextRightPadding))))
		{
			iWidthModifier = int((((TextX - float(m_iTextRightPadding)) - float(m_iMinXPos)) - float(targetPos)));
		}
		currentLookAndFeel.m_fCurrentPct = (float(targetPos) / float(m_iTotalScroll));
		C.Style = byte(currentStyle);
		C.SetDrawColor(currentDrawColor.R, currentDrawColor.G, currentDrawColor.B);
		DrawStretchedTextureSegment(C, float(iDisplayXPos), ImageY, float((m_OverScrollingRegion.W - iWidthModifier)), (float(m_OverScrollingRegion.H) * RegionScale), float((m_OverScrollingRegion.X + iWidthModifier)), float(m_OverScrollingRegion.Y), float((m_OverScrollingRegion.W - iWidthModifier)), float(m_OverScrollingRegion.H), m_OverScrollingTexture);
	}
	return;
}

function ResizeToText()
{
	m_bResizeToText = true;
	return;
}

function Tick(float DeltaTime)
{
	super(UWindowWindow).Tick(DeltaTime);
	// End:0x45
	if((MouseIsOver() || bMouseDown))
	{
		(m_fProgressTime += (DeltaTime * float(R6MenuRSLookAndFeel(LookAndFeel).m_iMultiplyer)));		
	}
	else
	{
		m_fProgressTime = ((R6MenuRSLookAndFeel(LookAndFeel).m_fCurrentPct * float(m_iTotalScroll)) / R6MenuRSLookAndFeel(LookAndFeel).m_fScrollRate);
	}
	return;
}

simulated function Click(float X, float Y)
{
	local R6MenuRootWindow r6Root;

	// End:0x0B
	if(bDisabled)
	{
		return;
	}
	super.Click(X, Y);
	r6Root = R6MenuRootWindow(Root);
	switch(m_eButton_Action)
	{
		// End:0x4B
		case 0:
			r6Root.ChangeCurrentWidget(5);
			// End:0xE7
			break;
		// End:0x64
		case 1:
			r6Root.ChangeCurrentWidget(14);
			// End:0xE7
			break;
		// End:0x7D
		case 2:
			r6Root.ChangeCurrentWidget(15);
			// End:0xE7
			break;
		// End:0x96
		case 3:
			r6Root.ChangeCurrentWidget(4);
			// End:0xE7
			break;
		// End:0xAF
		case 4:
			r6Root.ChangeCurrentWidget(16);
			// End:0xE7
			break;
		// End:0xC8
		case 6:
			r6Root.ChangeCurrentWidget(18);
			// End:0xE7
			break;
		// End:0xE1
		case 7:
			Root.ChangeCurrentWidget(38);
			// End:0xE7
			break;
		// End:0xFFFF
		default:
			// End:0xE7
			break;
			break;
	}
	return;
}

defaultproperties
{
	m_iTextRightPadding=4
	m_fLMarge=4.0000000
	m_OverAlphaTexture=Texture'R6MenuTextures.MainMenuMouseOver'
	m_OverScrollingTexture=Texture'R6MenuTextures.MainMenuMouseOver'
	m_OverAlphaRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=24098,ZoneNumber=0)
	m_OverScrollingRegion=(Zone=Class'R6Menu.R6MenuRootWindow',iLeaf=22306,ZoneNumber=0)
	bUseRegion=true
	ImageY=5.0000000
	OverTexture=Texture'R6MenuTextures.MainMenuMouseOver'
	OverRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=22818,ZoneNumber=0)
	Align=1
	Font=14
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var n
// REMOVED IN 1.60: var h
// REMOVED IN 1.60: var s
// REMOVED IN 1.60: var l
// REMOVED IN 1.60: var eButtonActionType
