//=============================================================================
// R6WindowCounter - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6WindowCounter.uc : This class permit to create a window with a - and + button
//                       and display the counter in the middle
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//  16/04/2002 Created by Yannick Joly
//=============================================================================
class R6WindowCounter extends UWindowDialogClientWindow;

const C_fBUTTONS_CHECK_TIME = 1;

enum eAssociateButCase
{
	EABC_Down,                      // 0
	EABC_Up                         // 1
};

var int m_iAssociateButCase;
var int m_iStepCounter;  // the -/+ step that each time you press the button
var int m_iCounter;  // the Counter
var int m_iMinCounter;  // The minimum for the counter
var int m_iMaxCounter;  // The maximum for the counter
var int m_iButtonID;
var bool m_bAdviceParent;  // advice the parent window (for tool tip effect and stuff like that)
var bool m_bNotAcceptClick;  // this is a fake button.
var bool m_bUnlimitedCounterOnZero;  // this counter is unlimited when the value is 0
var bool m_bButPressed;  // the +/- buttons are pressed
var float m_fTimeCheckBut;  // timer
var float m_fTimeToWait;  // the time to wait, by default C_fBUTTONS_CHECK_TIME
var R6WindowCounter m_pAssociateButton;  // the associate button, perform and action with this button
var R6WindowButton m_pSubButton;  // the substract button
var R6WindowButton m_pPlusButton;  // the adding button
var R6WindowTextLabel m_pTextInfo;  // display the info text
var R6WindowTextLabel m_pNbOfCounter;  // display the number of the counter

//===============================================================
// Create the text label window
//===============================================================
function CreateLabelText(float _fX, float _fY, float _fWidth, float _fHeight)
{
	m_pTextInfo = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', _fX, _fY, _fWidth, _fHeight, self));
	m_pTextInfo.bAlwaysBehind = true;
	return;
}

//===============================================================
// Set the text label param
//===============================================================
function SetLabelText(string _szText, Font _TextFont, Color _vTextColor)
{
	// End:0x79
	if((m_pTextInfo != none))
	{
		m_pTextInfo.Text = _szText;
		m_pTextInfo.m_Font = _TextFont;
		m_pTextInfo.TextColor = _vTextColor;
		m_pTextInfo.m_bDrawBorders = false;
		m_pTextInfo.Align = 0;
		m_pTextInfo.m_BGTexture = none;
	}
	return;
}

//===============================================================
// Create the two buttons (- and +) plus the text label in the center
//===============================================================
function CreateButtons(float _fX, float _fY, float _fSizeOfCounter)
{
	local Region RDisableRegion, RNormalRegion;
	local float fHeight, fButtonWidth, fButtonHeight;

	RNormalRegion.X = 49;
	RNormalRegion.Y = 24;
	RNormalRegion.W = 10;
	RNormalRegion.H = 10;
	RDisableRegion.X = 49;
	RDisableRegion.Y = 44;
	RDisableRegion.W = 10;
	RDisableRegion.H = 10;
	fButtonWidth = float(R6WindowLookAndFeel(LookAndFeel).m_RButtonBackGround.W);
	fButtonHeight = float(R6WindowLookAndFeel(LookAndFeel).m_RButtonBackGround.H);
	fHeight = ((WinHeight - fButtonHeight) / float(2));
	fHeight = float(int((fHeight + 0.5000000)));
	m_pSubButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', _fX, _fY, fButtonWidth, fButtonHeight));
	m_pSubButton.SetButtonBorderColor(Root.Colors.White);
	m_pSubButton.m_vButtonColor = Root.Colors.White;
	m_pSubButton.m_bDrawBorders = true;
	m_pSubButton.bUseRegion = true;
	m_pSubButton.DownTexture = R6WindowLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pSubButton.DownRegion = RDisableRegion;
	m_pSubButton.OverTexture = R6WindowLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pSubButton.OverRegion = RNormalRegion;
	m_pSubButton.UpTexture = R6WindowLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pSubButton.UpRegion = RNormalRegion;
	m_pSubButton.ImageX = 2.0000000;
	m_pSubButton.ImageY = 2.0000000;
	m_pSubButton.m_iDrawStyle = int(5);
	m_pSubButton.m_eButtonType = 1;
	m_pNbOfCounter = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', (_fX + fButtonWidth), _fY, (_fSizeOfCounter - (float(2) * fButtonWidth)), fButtonHeight));
	m_pNbOfCounter.m_bDrawBorders = false;
	m_pNbOfCounter.m_BGTextureRegion.X = 113;
	m_pNbOfCounter.m_BGTextureRegion.Y = 47;
	m_pNbOfCounter.m_BGTextureRegion.W = 2;
	m_pNbOfCounter.m_BGTextureRegion.H = 13;
	m_pNbOfCounter.m_fHBorderHeight = 0.0000000;
	m_pNbOfCounter.Text = string(m_iCounter);
	m_pNbOfCounter.Align = 2;
	m_pNbOfCounter.m_Font = Root.Fonts[5];
	m_pNbOfCounter.TextColor = Root.Colors.BlueLight;
	RNormalRegion.X = 59;
	RDisableRegion.X = 59;
	m_pPlusButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', ((_fX - fButtonWidth) + _fSizeOfCounter), _fY, fButtonWidth, fButtonHeight));
	m_pPlusButton.SetButtonBorderColor(Root.Colors.White);
	m_pPlusButton.m_vButtonColor = Root.Colors.White;
	m_pPlusButton.m_bDrawBorders = true;
	m_pPlusButton.bUseRegion = true;
	m_pPlusButton.DownTexture = R6WindowLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pPlusButton.DownRegion = RDisableRegion;
	m_pPlusButton.OverTexture = R6WindowLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pPlusButton.OverRegion = RNormalRegion;
	m_pPlusButton.UpTexture = R6WindowLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pPlusButton.UpRegion = RNormalRegion;
	m_pPlusButton.ImageX = 2.0000000;
	m_pPlusButton.ImageY = 2.0000000;
	m_pPlusButton.m_iDrawStyle = int(5);
	m_pPlusButton.m_eButtonType = 1;
	return;
}

//===============================================================
// Set button tool tip string, the same tip for the two button!
//===============================================================
function SetButtonToolTip(string _szLeftToolTip, string _szRightToolTip)
{
	// End:0x1F
	if((m_pSubButton != none))
	{
		m_pSubButton.ToolTipString = _szLeftToolTip;
	}
	// End:0x3E
	if((m_pPlusButton != none))
	{
		m_pPlusButton.ToolTipString = _szRightToolTip;
	}
	return;
}

//===============================================================
// set the counter values, min max and default
//===============================================================
function SetDefaultValues(int _iMin, int _iMax, int _iDefaultValue)
{
	m_iMinCounter = _iMin;
	m_iMaxCounter = _iMax;
	// End:0x27
	if(CheckValueForUnlimitedCounter(_iDefaultValue, true))
	{
		return;
	}
	m_iCounter = CheckValue(_iDefaultValue);
	m_pNbOfCounter.Text = string(m_iCounter);
	return;
}

function SetCounterValue(int _iNewValue)
{
	// End:0x11
	if(CheckValueForUnlimitedCounter(_iNewValue, false))
	{
		return;
	}
	m_iCounter = CheckValue(_iNewValue);
	m_pNbOfCounter.SetNewText(string(m_iCounter), true);
	return;
}

function bool CheckValueForUnlimitedCounter(int _iValue, bool _bDefaultValue)
{
	// End:0x61
	if(m_bUnlimitedCounterOnZero)
	{
		// End:0x61
		if(((_iValue < m_iMinCounter) && (_iValue == 0)))
		{
			m_iCounter = 0;
			// End:0x4B
			if(_bDefaultValue)
			{
				m_pNbOfCounter.Text = "--";				
			}
			else
			{
				m_pNbOfCounter.SetNewText("--", true);
			}
			return true;
		}
	}
	return false;
	return;
}

function int CheckValue(int _iValue)
{
	// End:0x18
	if((_iValue > m_iMaxCounter))
	{
		return m_iMaxCounter;		
	}
	else
	{
		// End:0x30
		if((_iValue < m_iMinCounter))
		{
			return m_iMinCounter;			
		}
		else
		{
			return _iValue;
		}
	}
	return;
}

function bool CheckAddButton()
{
	// End:0x38
	if(m_bUnlimitedCounterOnZero)
	{
		// End:0x38
		if((m_iCounter == 0))
		{
			m_iCounter = m_iMinCounter;
			m_pNbOfCounter.SetNewText(string(m_iCounter), true);
			return true;
		}
	}
	// End:0x73
	if(((m_iCounter + m_iStepCounter) <= m_iMaxCounter))
	{
		(m_iCounter += m_iStepCounter);
		m_pNbOfCounter.SetNewText(string(m_iCounter), true);
		return true;
	}
	return false;
	return;
}

function bool CheckSubButton()
{
	local float bSubValue;

	bSubValue = float((m_iCounter - m_iStepCounter));
	// End:0x4B
	if(m_bUnlimitedCounterOnZero)
	{
		// End:0x4B
		if((bSubValue < float(m_iMinCounter)))
		{
			m_iCounter = 0;
			m_pNbOfCounter.SetNewText("--", true);
			return true;
		}
	}
	// End:0x81
	if((bSubValue >= float(m_iMinCounter)))
	{
		(m_iCounter -= m_iStepCounter);
		m_pNbOfCounter.SetNewText(string(m_iCounter), true);
		return true;
	}
	return false;
	return;
}

//===============================================================
// advice parent window that you are on one of the button
//===============================================================
function SetAdviceParent(bool _bAdviceParent)
{
	m_bAdviceParent = _bAdviceParent;
	return;
}

//=============================================================
// Tick: check for mousedown on +/- buttons and simulate click on thoses buttons to +/- the counter
//=============================================================
function Tick(float DeltaTime)
{
	local bool bButPressed;

	(m_fTimeCheckBut += (DeltaTime * m_fTimeCheckBut));
	// End:0x9C
	if((m_fTimeCheckBut >= m_fTimeToWait))
	{
		m_fTimeCheckBut = 0.5000000;
		m_fTimeToWait = 1.0000000;
		bButPressed = m_bButPressed;
		m_bButPressed = false;
		m_bButPressed = IsMouseDown(m_pSubButton);
		m_bButPressed = (IsMouseDown(m_pPlusButton) || m_bButPressed);
		// End:0x9C
		if((bButPressed && m_bButPressed))
		{
			(m_fTimeToWait *= 0.5000000);
		}
	}
	return;
}

//=============================================================
// IsMouseDown: Check if the +/- buttons are pressed ant the player keep the mouse cursor on it
//=============================================================
function bool IsMouseDown(UWindowDialogControl _pButton)
{
	// End:0x2C
	if((_pButton != none))
	{
		// End:0x2C
		if(_pButton.bMouseDown)
		{
			Notify(_pButton, 2);
			return true;
		}
	}
	return false;
	return;
}

//===============================================================
// notify and notify parent if m_bAdviceParent is true
//===============================================================
function Notify(UWindowDialogControl C, byte E)
{
	// End:0x1A4
	if((int(E) == 2))
	{
		// End:0x19
		if(m_bNotAcceptClick)
		{
			return;
		}
		switch(C)
		{
			// End:0xDF
			case m_pPlusButton:
				// End:0xC6
				if(CheckAddButton())
				{
					// End:0x9F
					if((m_pAssociateButton != none))
					{
						// End:0x9F
						if((m_iAssociateButCase == int(1)))
						{
							// End:0x9F
							if((m_iCounter > m_pAssociateButton.m_iCounter))
							{
								m_pAssociateButton.m_iCounter = m_iCounter;
								m_pAssociateButton.m_pNbOfCounter.SetNewText(string(m_pAssociateButton.m_iCounter), true);
							}
						}
					}
					// End:0xC6
					if(m_bAdviceParent)
					{
						UWindowDialogClientWindow(ParentWindow).Notify(C, E);
					}
				}
				// End:0xDC
				if((!m_bButPressed))
				{
					m_fTimeCheckBut = 0.5000000;
				}
				// End:0x1A1
				break;
			// End:0x19E
			case m_pSubButton:
				// End:0x185
				if(CheckSubButton())
				{
					// End:0x15E
					if((m_pAssociateButton != none))
					{
						// End:0x15E
						if((m_iAssociateButCase == int(0)))
						{
							// End:0x15E
							if((m_iCounter < m_pAssociateButton.m_iCounter))
							{
								m_pAssociateButton.m_iCounter = m_iCounter;
								m_pAssociateButton.m_pNbOfCounter.SetNewText(string(m_pAssociateButton.m_iCounter), true);
							}
						}
					}
					// End:0x185
					if(m_bAdviceParent)
					{
						UWindowDialogClientWindow(ParentWindow).Notify(C, E);
					}
				}
				// End:0x19B
				if((!m_bButPressed))
				{
					m_fTimeCheckBut = 0.5000000;
				}
				// End:0x1A1
				break;
			// End:0xFFFF
			default:
				break;
		}		
	}
	else
	{
		// End:0x2A9
		if((int(E) == 12))
		{
			m_pSubButton.SetButtonBorderColor(Root.Colors.BlueLight);
			m_pSubButton.m_vButtonColor = Root.Colors.BlueLight;
			m_pPlusButton.SetButtonBorderColor(Root.Colors.BlueLight);
			m_pPlusButton.m_vButtonColor = Root.Colors.BlueLight;
			// End:0x27B
			if((m_pTextInfo != none))
			{
				m_pTextInfo.TextColor = Root.Colors.BlueLight;
			}
			// End:0x2A6
			if(m_bAdviceParent)
			{
				ParentWindow.ToolTip(R6WindowButton(C).ToolTipString);
			}			
		}
		else
		{
			// End:0x39A
			if((int(E) == 9))
			{
				m_pSubButton.SetButtonBorderColor(Root.Colors.White);
				m_pSubButton.m_vButtonColor = Root.Colors.White;
				m_pPlusButton.SetButtonBorderColor(Root.Colors.White);
				m_pPlusButton.m_vButtonColor = Root.Colors.White;
				// End:0x380
				if((m_pTextInfo != none))
				{
					m_pTextInfo.TextColor = Root.Colors.White;
				}
				// End:0x39A
				if(m_bAdviceParent)
				{
					ParentWindow.ToolTip("");
				}
			}
		}
	}
	return;
}

defaultproperties
{
	m_iStepCounter=1
	m_iMaxCounter=99
}
