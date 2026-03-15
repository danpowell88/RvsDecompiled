//=============================================================================
// R6WindowButtonBox - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowButtonBox.uc : This class create a window with differents buttons region that
//                         you can specify and return to the parent a msg when a region is click
//                         Possibility to have a text in front and a tooltip associate with it
//                         Is like : TEXT ...... CheckBox
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/09 * Created by Yannick Joly
//=============================================================================
class R6WindowButtonBox extends UWindowButton;

const C_fWIDTH_OF_MSG_BOX = 90;

enum eButtonBoxType
{
	BBT_Normal,                     // 0
	BBT_DeathCam,                   // 1
	BBT_ResKit                      // 2
};

var R6WindowButtonBox.eButtonBoxType m_eButtonType;  // the type of the button
var bool m_bRefresh;
var bool m_bMouseIsOver;  // to know if the mouse is on text or on the check box
var bool m_bMouseOnButton;  // to know is the mouse in on the window
var bool m_bSelected;  // true if the player selected the button
var bool m_bResizeToText;  // Resize the button to the box + text size
// NEW IN 1.60
var bool m_bAutomaticResizeFont;
var float m_fYTextPos;
var float m_fXText;
var float m_fXBox;
var float m_fYBox;
var float m_fXMsgBoxText;
var float m_fHMsgBoxText;
/////// we can find this in the R6WindowLookAndFeel
var Texture m_TButtonBG;  // the texture button
var Texture m_TDownTexture;
var Font m_TextFont;  // the text font (only one text font for all the buttons)
var UWindowWindow m_AdviceWindow;  // advice this window when a mouse wheel is down
var Region m_RButtonBG;  // the region of the button background
var Color m_vBorder;  // the color of the button border
var Color m_vTextColor;  // the text color (only one text color for all the buttons)
var string m_szMsgBoxText;  // the message box text
var string m_szMiscText;  // use to store any information useful for treatment
var string m_szToolTipWhenDisable;  // force to display a disable tooltip

//*********************************
//      DISPLAY FUNCTIONS
//*********************************
function BeforePaint(Canvas C, float X, float Y)
{
	local int i;

	// End:0x7B
	if(m_bRefresh)
	{
		m_bRefresh = false;
		// End:0x3F
		if((m_szMsgBoxText != ""))
		{
			m_fXMsgBoxText = AlignText(C, m_fXBox, 90.0000000, m_szMsgBoxText, 2);
		}
		// End:0x7B
		if((Text != ""))
		{
			m_fXText = AlignText(C, 0.0000000, (WinWidth - float(m_RButtonBG.W)), Text, 0);
		}
	}
	return;
}

function float AlignText(Canvas C, float _fXStartPos, float _fWidth, out string _szTextToAlign, UWindowBase.TextAlign _eTextAlign)
{
	local array<Font> ALowerFont;
	local string szTmpText;
	local float W, H, fXTemp, fLMarge, fDistBetBoxAndText;

	local int i;

	fXTemp = 0.0000000;
	fLMarge = 2.0000000;
	fDistBetBoxAndText = 4.0000000;
	i = 0;
	ALowerFont[ALowerFont.Length] = m_TextFont;
	// End:0x7F
	if(m_bAutomaticResizeFont)
	{
		ALowerFont[ALowerFont.Length] = Root.Fonts[6];
		ALowerFont[ALowerFont.Length] = Root.Fonts[10];
	}
	J0x7F:

	// End:0x11B [Loop If]
	if((i < ALowerFont.Length))
	{
		C.Font = ALowerFont[i];
		szTmpText = TextSize(C, _szTextToAlign, W, H, int(_fWidth));
		TextSize(C, _szTextToAlign, W, H);
		// End:0x104
		if((szTmpText != _szTextToAlign))
		{
			(i++);			
		}
		else
		{
			m_TextFont = ALowerFont[i];
			// [Explicit Break]
			goto J0x11B;
		}
		// [Loop Continue]
		goto J0x7F;
	}
	J0x11B:

	// End:0x135
	if((_szTextToAlign == m_szMsgBoxText))
	{
		m_fHMsgBoxText = H;
	}
	switch(_eTextAlign)
	{
		// End:0x186
		case 0:
			// End:0x171
			if((m_fXBox == float(0)))
			{
				fXTemp = ((float(m_RButtonBG.W) + _fXStartPos) + fLMarge);				
			}
			else
			{
				fXTemp = (_fXStartPos + fLMarge);
			}
			// End:0x1B0
			break;
		// End:0x1AD
		case 2:
			fXTemp = (_fXStartPos + ((_fWidth - W) / float(2)));
			// End:0x1B0
			break;
		// End:0xFFFF
		default:
			break;
	}
	m_fYTextPos = ((WinHeight - H) / float(2));
	m_fYTextPos = float(int((m_fYTextPos + 0.5000000)));
	// End:0x23E
	if(m_bResizeToText)
	{
		WinWidth = ((((float(m_RButtonBG.W) + _fXStartPos) + fLMarge) + W) + fDistBetBoxAndText);
		// End:0x23B
		if((m_fXBox != float(0)))
		{
			m_fXBox = (WinWidth - float(m_RButtonBG.W));
		}		
	}
	else
	{
		_szTextToAlign = szTmpText;
	}
	return fXTemp;
	return;
}

// draw all the button
function Paint(Canvas C, float X, float Y)
{
	local Color vTempColor;

	// End:0x6E
	if(((!bDisabled) || (m_szToolTipWhenDisable != "")))
	{
		m_bMouseIsOver = MouseIsOver();
		// End:0x6E
		if(m_bMouseOnButton)
		{
			// End:0x43
			if(bDisabled)
			{
				ToolTipString = m_szToolTipWhenDisable;
			}
			// End:0x6E
			if((ToolTipString != ""))
			{
				// End:0x66
				if(m_bMouseIsOver)
				{
					ToolTip(ToolTipString);					
				}
				else
				{
					ToolTip("");
				}
			}
		}
	}
	// End:0x9C
	if((int(m_eButtonType) == int(0)))
	{
		DrawCheckBox(C, m_fXBox, m_fYBox, m_bMouseIsOver);		
	}
	else
	{
		// End:0xC7
		if((int(m_eButtonType) == int(2)))
		{
			DrawResKitBotton(C, m_fXBox, m_fYBox, m_bMouseIsOver);
		}
	}
	// End:0x1DF
	if((Text != ""))
	{
		C.Font = m_TextFont;
		C.SpaceX = 0.0000000;
		vTempColor = m_vTextColor;
		// End:0x13C
		if(bDisabled)
		{
			C.SetDrawColor(m_DisabledTextColor.R, m_DisabledTextColor.G, m_DisabledTextColor.B);			
		}
		else
		{
			// End:0x17D
			if(m_bMouseIsOver)
			{
				vTempColor = m_OverTextColor;
				C.SetDrawColor(m_OverTextColor.R, m_OverTextColor.G, m_OverTextColor.B);				
			}
			else
			{
				// End:0x1C4
				if(vTempColor != m_vTextColor)
				{
					vTempColor = m_vTextColor;
					C.SetDrawColor(m_vTextColor.R, m_vTextColor.G, m_vTextColor.B);
				}
			}
		}
		ClipText(C, m_fXText, m_fYTextPos, Text, true);
	}
	return;
}

function DrawCheckBox(Canvas C, float _fXBox, float _fYBox, bool _bMouseOverButton)
{
	C.Style = 5;
	// End:0x47
	if(bDisabled)
	{
		C.SetDrawColor(m_DisabledTextColor.R, m_DisabledTextColor.G, m_DisabledTextColor.B);		
	}
	else
	{
		// End:0x7D
		if(_bMouseOverButton)
		{
			C.SetDrawColor(m_OverTextColor.R, m_OverTextColor.G, m_OverTextColor.B);			
		}
		else
		{
			C.SetDrawColor(m_vBorder.R, m_vBorder.G, m_vBorder.B);
		}
	}
	DrawStretchedTextureSegment(C, _fXBox, _fYBox, float(m_RButtonBG.W), float(m_RButtonBG.H), float(m_RButtonBG.X), float(m_RButtonBG.Y), float(m_RButtonBG.W), float(m_RButtonBG.H), m_TButtonBG);
	// End:0x182
	if(m_bSelected)
	{
		DrawStretchedTextureSegment(C, (2.0000000 + _fXBox), (2.0000000 + _fYBox), float(DownRegion.W), float(DownRegion.H), float(DownRegion.X), float(DownRegion.Y), float(DownRegion.W), float(DownRegion.H), DownTexture);
	}
	return;
}

function DrawResKitBotton(Canvas C, float _fXBox, float _fYBox, bool _bMouseOverButton)
{
	local float fYLineTop, fYLineBottom;

	C.Style = 5;
	C.Font = m_TextFont;
	// End:0x5B
	if(bDisabled)
	{
		C.SetDrawColor(m_DisabledTextColor.R, m_DisabledTextColor.G, m_DisabledTextColor.B);		
	}
	else
	{
		// End:0x91
		if(_bMouseOverButton)
		{
			C.SetDrawColor(m_OverTextColor.R, m_OverTextColor.G, m_OverTextColor.B);			
		}
		else
		{
			C.SetDrawColor(m_vBorder.R, m_vBorder.G, m_vBorder.B);
		}
	}
	fYLineTop = m_fYTextPos;
	fYLineBottom = ((m_fYTextPos + m_fHMsgBoxText) - float(2));
	DrawStretchedTextureSegment(C, _fXBox, fYLineTop, (WinWidth - _fXBox), float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	DrawStretchedTextureSegment(C, _fXBox, fYLineBottom, (WinWidth - _fXBox), float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	DrawStretchedTextureSegment(C, _fXBox, fYLineTop, float(m_BorderTextureRegion.W), (m_fHMsgBoxText - float(2)), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	DrawStretchedTextureSegment(C, ((_fXBox + float(90)) - float(m_BorderTextureRegion.W)), fYLineTop, float(m_BorderTextureRegion.W), (m_fHMsgBoxText - float(2)), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	ClipText(C, m_fXMsgBoxText, m_fYTextPos, m_szMsgBoxText, true);
	return;
}

//*********************************
//      MOUSE FUNCTIONS OVERLOADED
//*********************************
// Why overwrite this 2 functions, because the tooltip have to be on the text or the check box only
// not on all the window. We force it in Paint()
// overwrite uwindowwindow fct
function MouseEnter()
{
	m_bMouseOnButton = true;
	return;
}

// overwrite uwindowwindow fct
function MouseLeave()
{
	super(UWindowDialogControl).MouseLeave();
	m_bMouseOnButton = false;
	return;
}

//*********************************
//      CHECK 
//*********************************
function bool CheckText_Box_Region()
{
	local int i;
	local float fX, fY, FMin, FMax;

	GetMouseXY(fX, fY);
	FMin = m_fXBox;
	// End:0x47
	if((int(m_eButtonType) == int(0)))
	{
		FMax = (m_fXBox + float(m_RButtonBG.W));		
	}
	else
	{
		// End:0x68
		if((int(m_eButtonType) == int(2)))
		{
			FMax = (m_fXBox + float(90));
		}
	}
	// End:0x82
	if(InRange(fX, m_fXBox, FMax))
	{
		return true;
	}
	return false;
	return;
}

function bool InRange(float _fTestValue, float _fMin, float _fMax)
{
	// End:0x20
	if((_fTestValue > _fMin))
	{
		// End:0x20
		if((_fTestValue < _fMax))
		{
			return true;
		}
	}
	return false;
	return;
}

//*********************************
//      Create the button 
//*********************************
function CreateTextAndBox(string _szText, string _szToolTip, float _fXText, int _iButtonID, optional bool _bTextAfterBox, optional bool _bUseAutomaticResizeFont)
{
	Text = _szText;
	ToolTipString = _szToolTip;
	m_fXText = _fXText;
	m_iButtonID = _iButtonID;
	// End:0x43
	if(_bTextAfterBox)
	{
		m_fXBox = 0.0000000;		
	}
	else
	{
		m_fXBox = (WinWidth - float(m_RButtonBG.W));
	}
	m_fYBox = ((WinHeight - float(m_RButtonBG.H)) / float(2));
	m_fYBox = float(int((m_fYBox + 0.5000000)));
	m_bAutomaticResizeFont = _bUseAutomaticResizeFont;
	return;
}

function CreateTextAndMsgBox(string _szText, string _szToolTip, string _szTextBox, float _fXText, int _iButtonID)
{
	Text = _szText;
	ToolTipString = _szToolTip;
	m_fXText = _fXText;
	m_iButtonID = _iButtonID;
	m_fXBox = (WinWidth - float(90));
	ModifyMsgBox(_szTextBox);
	m_fYBox = 0.0000000;
	return;
}

//=============================================================================
// ModifyMsgBox: Modify the text inside the msg box depending if you're are in-game or not
//=============================================================================
function ModifyMsgBox(string _szTextBox)
{
	m_szMsgBoxText = _szTextBox;
	m_bRefresh = true;
	return;
}

//=============================================================================
// SetButtonBox: Set the regular param for this type of button, 
// for other type add a enum or set the member variable invidually
//=============================================================================
function SetButtonBox(bool _bSelected)
{
	m_TextFont = Root.Fonts[5];
	m_vTextColor = Root.Colors.White;
	m_vBorder = Root.Colors.White;
	m_bSelected = _bSelected;
	return;
}

//===============================================================
// SetNewWidth: set the new width of the button
//===============================================================
function SetNewWidth(float _fWidth)
{
	WinWidth = _fWidth;
	m_fXBox = (_fWidth - float(m_RButtonBG.W));
	m_bRefresh = true;
	return;
}

//*********************************
//      Get the selected status (change where you create the button by Notify)
//*********************************
function bool GetSelectStatus()
{
	// End:0x0B
	if(bDisabled)
	{
		return false;
	}
	// End:0x21
	if((m_bMouseOnButton && m_bMouseIsOver))
	{
		return true;
	}
	return false;
	return;
}

simulated function Click(float X, float Y)
{
	// End:0x0B
	if(bDisabled)
	{
		return;
	}
	// End:0x59
	if(GetSelectStatus())
	{
		// End:0x51
		if((m_bPlayButtonSnd && (DownSound != none)))
		{
			GetPlayerOwner().PlaySound(DownSound, 9);
			// End:0x51
			if(m_bWaitSoundFinish)
			{
				m_bSoundStart = true;
				return;
			}
		}
		Notify(2);
	}
	return;
}

//=======================================================================================
// MouseWheelDown: advice a window of your choice for mouse wheel down
//=======================================================================================
function MouseWheelDown(float X, float Y)
{
	// End:0x24
	if((m_AdviceWindow != none))
	{
		m_AdviceWindow.MouseWheelDown(X, Y);
	}
	return;
}

//=======================================================================================
// MouseWheelUp: advice a window of your choice for mouse wheel up
//=======================================================================================
function MouseWheelUp(float X, float Y)
{
	// End:0x24
	if((m_AdviceWindow != none))
	{
		m_AdviceWindow.MouseWheelUp(X, Y);
	}
	return;
}

defaultproperties
{
	m_bRefresh=true
	m_TButtonBG=Texture'R6MenuTextures.Gui_BoxScroll'
	m_RButtonBG=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=3106,ZoneNumber=0)
	m_vBorder=(R=15,G=136,B=176,A=0)
	m_vTextColor=(R=255,G=255,B=255,A=0)
	DownTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	DownRegion=(Zone=Class'R6Window.R6WindowListBoxItem',iLeaf=13346,ZoneNumber=0)
}
