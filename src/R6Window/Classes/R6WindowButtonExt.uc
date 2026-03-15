//=============================================================================
// R6WindowButtonExt - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowButtonExt.uc : This class give the following type of button... 
//						   DESC TEXT                 BOX desc BOX desc BOX desc
//						   minimum of 1 box and max of 3
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/09 * Created by Yannick Joly
//=============================================================================
class R6WindowButtonExt extends UWindowButton;

struct CheckBox
{
	var string szText;
	var float fXBoxPos;
	var bool bSelected;
	var int iIndex;
};

var int m_iNumberOfCheckBox;  // the number of check box for this button
var int m_iCurSelectedBox;
var int m_iCheckBoxOver;  // the check box over index
var bool m_bOneTime;
var bool m_bMouseIsOver;  // to know if the mouse is on text or on the check box
var bool m_bMouseOnButton;  // to know is the mouse in on the window
var bool m_bSelected;  // true if the player selected the button
var float m_fTextWidth;
var float m_fYTextPos;
var float m_fXText;
var float m_fYBox;
/////// we can find this in the R6WindowLookAndFeel
var Texture m_TButtonBG;  // the texture button
var Texture m_TDownTexture;
var Font m_TextFont;  // the text font (only one text font for all the buttons)
var Region m_RButtonBG;  // the region of the button background
var Color m_vBorder;  // the color of the button border
var Color m_vTextColor;  // the text color (only one text color for all the buttons)
var CheckBox m_stCheckBox[3];

//*********************************
//      DISPLAY FUNCTIONS
//*********************************
function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H, fWinWidth;
	local int i;

	// End:0x85
	if(m_bOneTime)
	{
		m_bOneTime = false;
		// End:0x85
		if((Text != ""))
		{
			C.Font = m_TextFont;
			TextSize(C, Text, W, H);
			(m_fXText += float(2));
			m_fYTextPos = ((WinHeight - H) / float(2));
			m_fYTextPos = float(int((m_fYTextPos + 0.5000000)));
		}
	}
	return;
}

// draw all the button
function Paint(Canvas C, float X, float Y)
{
	local Color vTempColor;
	local int i;

	// End:0x62
	if((!bDisabled))
	{
		m_bMouseIsOver = MouseIsOver();
		// End:0x2E
		if(m_bMouseIsOver)
		{
			m_bMouseIsOver = CheckText_Box_Region();
		}
		// End:0x62
		if(m_bMouseOnButton)
		{
			// End:0x62
			if((ToolTipString != ""))
			{
				// End:0x5A
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
	DrawCheckBox(C, m_bMouseIsOver);
	// End:0x1F0
	if((Text != ""))
	{
		C.Font = m_TextFont;
		C.SpaceX = 0.0000000;
		vTempColor = m_vTextColor;
		// End:0xE8
		if(bDisabled)
		{
			C.SetDrawColor(m_DisabledTextColor.R, m_DisabledTextColor.G, m_DisabledTextColor.B);			
		}
		else
		{
			// End:0x129
			if(m_bMouseIsOver)
			{
				vTempColor = m_OverTextColor;
				C.SetDrawColor(m_OverTextColor.R, m_OverTextColor.G, m_OverTextColor.B);				
			}
			else
			{
				// End:0x170
				if(vTempColor != m_vTextColor)
				{
					vTempColor = m_vTextColor;
					C.SetDrawColor(m_vTextColor.R, m_vTextColor.G, m_vTextColor.B);
				}
			}
		}
		ClipText(C, m_fXText, m_fYTextPos, Text, true);
		i = 0;
		J0x192:

		// End:0x1F0 [Loop If]
		if((i < m_iNumberOfCheckBox))
		{
			ClipText(C, ((m_stCheckBox[i].fXBoxPos + float(m_RButtonBG.W)) + float(2)), m_fYTextPos, m_stCheckBox[i].szText, true);
			(i++);
			// [Loop Continue]
			goto J0x192;
		}
	}
	return;
}

function DrawCheckBox(Canvas C, bool _bMouseOverButton)
{
	local int i;

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
	i = 0;
	J0xAE:

	// End:0x1C3 [Loop If]
	if((i < m_iNumberOfCheckBox))
	{
		DrawStretchedTextureSegment(C, m_stCheckBox[i].fXBoxPos, m_fYBox, float(m_RButtonBG.W), float(m_RButtonBG.H), float(m_RButtonBG.X), float(m_RButtonBG.Y), float(m_RButtonBG.W), float(m_RButtonBG.H), m_TButtonBG);
		// End:0x1B9
		if(m_stCheckBox[i].bSelected)
		{
			DrawStretchedTextureSegment(C, (2.0000000 + m_stCheckBox[i].fXBoxPos), (2.0000000 + m_fYBox), float(DownRegion.W), float(DownRegion.H), float(DownRegion.X), float(DownRegion.Y), float(DownRegion.W), float(DownRegion.H), DownTexture);
		}
		(i++);
		// [Loop Continue]
		goto J0xAE;
	}
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
	local float fX, fY;

	GetMouseXY(fX, fY);
	i = 0;
	J0x17:

	// End:0x79 [Loop If]
	if((i < m_iNumberOfCheckBox))
	{
		// End:0x6F
		if(InRange(fX, m_stCheckBox[i].fXBoxPos, (m_stCheckBox[i].fXBoxPos + float(m_RButtonBG.W))))
		{
			m_iCheckBoxOver = i;
			return true;
		}
		(i++);
		// [Loop Continue]
		goto J0x17;
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
function CreateTextAndBox(string _szText, string _szToolTip, float _fXText, int _iButtonID, int _iNumberOfCheckBox)
{
	Text = _szText;
	ToolTipString = _szToolTip;
	m_fXText = _fXText;
	m_iButtonID = _iButtonID;
	m_iNumberOfCheckBox = _iNumberOfCheckBox;
	m_fYBox = ((WinHeight - float(m_RButtonBG.H)) / float(2));
	m_fYBox = float(int((m_fYTextPos + 0.5000000)));
	return;
}

//=============================================================================
// SetButtonBox: Set the regular param for this type of button, 
// for other type add a enum or set the member variable invidually
//=============================================================================
function SetCheckBox(string _szText, float _fXBoxPos, bool _bSelected, int _iIndex)
{
	m_stCheckBox[_iIndex].szText = _szText;
	m_stCheckBox[_iIndex].fXBoxPos = _fXBoxPos;
	m_stCheckBox[_iIndex].bSelected = _bSelected;
	// End:0x58
	if(_bSelected)
	{
		m_iCurSelectedBox = _iIndex;
	}
	m_TextFont = Root.Fonts[5];
	m_vTextColor = Root.Colors.White;
	m_vBorder = Root.Colors.White;
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

//===============================================
// Change the check box status
//===============================================
function ChangeCheckBoxStatus()
{
	// End:0x40
	if((m_iCurSelectedBox != m_iCheckBoxOver))
	{
		m_stCheckBox[m_iCurSelectedBox].bSelected = false;
		m_stCheckBox[m_iCheckBoxOver].bSelected = true;
		m_iCurSelectedBox = m_iCheckBoxOver;
	}
	return;
}

//===============================================
// SetCheckBoxStatus: Change the check box status depending the state in .ini 
//					  this function is specific, the selected state is store in int,
//					  so we have to switch to a bool before displaying it
//===============================================
function SetCheckBoxStatus(int _iSelected)
{
	m_iCurSelectedBox = _iSelected;
	switch(_iSelected)
	{
		// End:0x47
		case 0:
			m_stCheckBox[0].bSelected = true;
			m_stCheckBox[1].bSelected = false;
			m_stCheckBox[2].bSelected = false;
			// End:0xB8
			break;
		// End:0x7C
		case 1:
			m_stCheckBox[0].bSelected = false;
			m_stCheckBox[1].bSelected = true;
			m_stCheckBox[2].bSelected = false;
			// End:0xB8
			break;
		// End:0xB2
		case 2:
			m_stCheckBox[0].bSelected = false;
			m_stCheckBox[1].bSelected = false;
			m_stCheckBox[2].bSelected = true;
			// End:0xB8
			break;
		// End:0xFFFF
		default:
			// End:0xB8
			break;
			break;
	}
	return;
}

//===============================================
// GetCheckBoxStatus: Return the selected button index 
//===============================================
function int GetCheckBoxStatus()
{
	// End:0x15
	if(m_stCheckBox[0].bSelected)
	{
		return 0;		
	}
	else
	{
		// End:0x2A
		if(m_stCheckBox[1].bSelected)
		{
			return 1;			
		}
		else
		{
			// End:0x3E
			if(m_stCheckBox[2].bSelected)
			{
				return 2;
			}
		}
	}
	return;
}

defaultproperties
{
	m_bOneTime=true
	m_TButtonBG=Texture'R6MenuTextures.Gui_BoxScroll'
	m_RButtonBG=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=3106,ZoneNumber=0)
	m_vBorder=(R=15,G=136,B=176,A=0)
	m_vTextColor=(R=255,G=255,B=255,A=0)
	DownTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	DownRegion=(Zone=Class'R6Window.R6WindowListBoxItem',iLeaf=13346,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_pButtonBox1
// REMOVED IN 1.60: var m_pButtonBox2
// REMOVED IN 1.60: var m_pButtonBox3
// REMOVED IN 1.60: var m_pCurrentSelection
// REMOVED IN 1.60: var m_pTextLabel
// REMOVED IN 1.60: var m_pParent
// REMOVED IN 1.60: function CreatedMultipleButtons
// REMOVED IN 1.60: function Notify
