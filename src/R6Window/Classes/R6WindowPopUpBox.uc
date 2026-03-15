//=============================================================================
// R6WindowPopUpBox - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6WindowPopUpBox.uc : This provides the simple frame for all the pop-up window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/04 * Created by Yannick Joly
//=============================================================================
class R6WindowPopUpBox extends UWindowWindow;

const C_fTITLE_TIME_OFFSET = 10;
const K_FBUTTON_HEIGHT_REGION = 25;
const K_BORDER_HOR_OFF = 1;
const K_BORDER_VER_OFF = 1;

enum eBorderType
{
	Border_Top,                     // 0
	Border_Bottom,                  // 1
	Border_Left,                    // 2
	Border_Right                    // 3
};

enum eCornerType
{
	No_Corners,                     // 0
	Top_Corners,                    // 1
	Bottom_Corners,                 // 2
	All_Corners                     // 3
};

struct stBorderForm
{
	var Color vColor;
	var float fXPos;
	var float fYPos;
	var float fWidth;
	var float fHeight;
	var bool bActive;
};

// NEW IN 1.60
var R6WindowPopUpBox.eCornerType m_eCornerType;
var UWindowBase.EPopUpID m_ePopUpID;
var UWindowBase.MessageBoxResult Result;
var UWindowBase.MessageBoxResult DefaultResult;
var int m_DrawStyle;
var int m_iPopUpButtonsType;
var bool m_bNoBorderToDraw;
var bool m_bBGFullScreen;  // true if you want the bck for all the screen, false the bck is only for the pop up size
var bool m_bBGClientArea;  // true, draw client area and header background
var bool m_bDetectKey;  // detect escape and enter key
var bool m_bForceButtonLine;  // force to draw the button line
var bool m_bDisablePopUpActive;  // the disable pop-up button is there
var bool m_bPopUpLock;  // if true, popup will not close, only hidewindow will close it
var bool m_bTextWindowOnly;
var bool m_bResizePopUpOnTextLabel;
var bool m_bHideAllChild;
var float m_fHBorderHeight;  // Border size
// NEW IN 1.60
var float m_fVBorderWidth;
//////////////////////////////
//Please make sure you set the Padding correctly if you use the offsets values
//////////////////////////////
var float m_fHBorderPadding;  // Allow the borders not to start in corners
// NEW IN 1.60
var float m_fVBorderPadding;
var float m_fHBorderOffset;  // Border offset if you want the borders to
// NEW IN 1.60
var float m_fVBorderOffset;
var Texture m_BGTexture;  // Put = None when no background is needed
var Texture m_HBorderTexture;
// NEW IN 1.60
var Texture m_VBorderTexture;
var Texture m_topLeftCornerT;
var UWindowWindow m_ClientArea;
var UWindowWindow m_ButClientArea;
var R6WindowTextLabelExt m_pTextLabel;
//This is to create the window that needs the frame
var Class<UWindowWindow> m_ClientClass;
var Region m_BGTextureRegion;  // the background texture region
var Region m_HBorderTextureRegion;
// NEW IN 1.60
var Region m_VBorderTextureRegion;
var Region m_topLeftCornerR;
var Region m_RWindowBorder;
var Region SimpleBorderRegion;
var stBorderForm m_sBorderForm[4];  // 0 = top ; 1 = down ; 2 = Left ; 3 = Right
var Color m_eCornerColor[4];
var Color m_vFullBGColor;  // the full back ground color
var Color m_vClientAreaColor;  // inside the frame pop-up -- include the header

// default initialisation
// we have to set after the create window the parameters you want
function Created()
{
	local int i;

	i = 0;
	J0x07:

	// End:0x9A [Loop If]
	if((i < 4))
	{
		m_sBorderForm[i].vColor = Root.Colors.BlueLight;
		m_sBorderForm[i].fXPos = 0.0000000;
		m_sBorderForm[i].fYPos = 0.0000000;
		m_sBorderForm[i].fWidth = 1.0000000;
		m_sBorderForm[i].bActive = false;
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	m_eCornerColor[int(3)] = Root.Colors.White;
	m_eCornerColor[int(1)] = Root.Colors.White;
	m_eCornerColor[int(2)] = Root.Colors.White;
	m_vFullBGColor = Root.Colors.m_cBGPopUpContour;
	m_vClientAreaColor = Root.Colors.m_cBGPopUpWindow;
	m_ClientArea = none;
	return;
}

//Just Pass any Control to this function to get it to show in the frame
function CreateClientWindow(Class<UWindowWindow> ClientClass, optional bool _bButtonBar, optional bool _bDrawClientOnBorder)
{
	m_ClientClass = ClientClass;
	// End:0x66
	if(_bButtonBar)
	{
		m_ButClientArea = CreateWindow(m_ClientClass, float(m_RWindowBorder.X), float(((m_RWindowBorder.Y + m_RWindowBorder.H) - 25)), float(m_RWindowBorder.W), 25.0000000, OwnerWindow);		
	}
	else
	{
		// End:0xD0
		if(_bDrawClientOnBorder)
		{
			m_ClientArea = CreateWindow(m_ClientClass, float((m_RWindowBorder.X + 1)), float((m_RWindowBorder.Y - 1)), float((m_RWindowBorder.W - (2 * 1))), float(((m_RWindowBorder.H + (2 * 1)) - 25)), OwnerWindow);			
		}
		else
		{
			m_ClientArea = CreateWindow(m_ClientClass, float(((m_RWindowBorder.X + 1) + 1)), float(m_RWindowBorder.Y), float(((m_RWindowBorder.W - (2 * 1)) - 1)), float((m_RWindowBorder.H - 25)), OwnerWindow);
		}
	}
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H, XOff, fWinWidth;
	local string _szTitleText;
	local float _TextHeight, _X, _Y, _fWidth, _fHeight;

	// End:0x135
	if((m_pTextLabel != none))
	{
		C.Font = Root.Fonts[8];
		_szTitleText = m_pTextLabel.GetTextLabel(0);
		TextSize(C, (("  " $ _szTitleText) $ "  "), W, H);
		// End:0x135
		if((W > m_pTextLabel.WinWidth))
		{
			XOff = (W - m_pTextLabel.WinWidth);
			_TextHeight = m_pTextLabel.WinHeight;
			_X = (m_pTextLabel.WinLeft - (XOff / float(2)));
			_Y = m_pTextLabel.WinTop;
			_fWidth = (m_pTextLabel.WinWidth + XOff);
			_fHeight = float(m_RWindowBorder.H);
			ModifyPopUpFrameWindow(_szTitleText, _TextHeight, _X, _Y, _fWidth, _fHeight);
		}
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	// End:0x7F
	if(m_bResizePopUpOnTextLabel)
	{
		// End:0x2A
		if((m_pTextLabel != none))
		{
			m_pTextLabel.m_bPreCalculatePos = m_bHideAllChild;
		}
		// End:0x4B
		if((m_ClientArea != none))
		{
			m_ClientArea.m_bPreCalculatePos = m_bHideAllChild;
		}
		// End:0x6C
		if((m_ButClientArea != none))
		{
			m_ButClientArea.m_bPreCalculatePos = m_bHideAllChild;
		}
		// End:0x7F
		if(m_bHideAllChild)
		{
			m_bHideAllChild = false;
			return;
		}
	}
	R6WindowLookAndFeel(LookAndFeel).DrawPopUpFrameWindow(self, C);
	// End:0xD8
	if(m_bTextWindowOnly)
	{
		// End:0xBC
		if((m_ClientArea != none))
		{
			m_ClientArea.HideWindow();
		}
		// End:0xD6
		if((m_ButClientArea != none))
		{
			m_ButClientArea.HideWindow();
		}
		return;
	}
	// End:0x186
	if(((m_ButClientArea != none) || m_bForceButtonLine))
	{
		C.SetDrawColor(byte(255), byte(255), byte(255));
		DrawStretchedTextureSegment(C, float((m_RWindowBorder.X + 1)), float(((m_RWindowBorder.Y + m_RWindowBorder.H) - 25)), float((m_RWindowBorder.W - 2)), 1.0000000, float(SimpleBorderRegion.X), float(SimpleBorderRegion.Y), float(SimpleBorderRegion.W), float(SimpleBorderRegion.H), m_BGTexture);
	}
	return;
}

//===========================================================================
// function to create a std pop up window with clientwindow (for button)
//===========================================================================
function CreateStdPopUpWindow(string _szPopUpTitle, float _fTextHeight, float _fXPos, float _fYPos, float _fWidth, float _fHeight, optional int _iButtonsType)
{
	CreateTextWindow(_szPopUpTitle, _fXPos, _fYPos, _fWidth, _fTextHeight);
	CreatePopUpFrame(_fXPos, (_fYPos + _fTextHeight), _fWidth, _fHeight);
	CreateClientWindow(Class'R6Window.R6WindowPopUpBoxCW', true);
	SetButtonsType(_iButtonsType);
	return;
}

//===========================================================================
// function to create a std pop up window (only the visual)
//===========================================================================
function CreatePopUpFrameWindow(string _szPopUpTitle, float _fTextHeight, float _fXPos, float _fYPos, float _fWidth, float _fHeight)
{
	CreateTextWindow(_szPopUpTitle, _fXPos, _fYPos, _fWidth, _fTextHeight);
	CreatePopUpFrame(_fXPos, (_fYPos + _fTextHeight), _fWidth, _fHeight);
	return;
}

function ModifyPopUpFrameWindow(string _szPopUpTitle, float _fTextHeight, float _fXPos, float _fYPos, float _fWidth, float _fHeight, optional int _iButtonsType)
{
	m_bTextWindowOnly = false;
	ModifyTextWindow(_szPopUpTitle, _fXPos, _fYPos, _fWidth, _fTextHeight);
	CreatePopUpFrame(_fXPos, (_fYPos + _fTextHeight), _fWidth, _fHeight);
	// End:0xD3
	if((m_ButClientArea != none))
	{
		m_ButClientArea.WinLeft = float(m_RWindowBorder.X);
		m_ButClientArea.WinTop = float(((m_RWindowBorder.Y + m_RWindowBorder.H) - 25));
		m_ButClientArea.WinWidth = float(m_RWindowBorder.W);
		m_ButClientArea.WinHeight = 25.0000000;
		SetButtonsType(_iButtonsType);
	}
	// End:0x149
	if((m_ClientArea != none))
	{
		m_ClientArea.WinLeft = float((m_RWindowBorder.X + 1));
		m_ClientArea.WinTop = float(m_RWindowBorder.Y);
		m_ClientArea.SetSize(float((m_RWindowBorder.W - (2 * 1))), float((m_RWindowBorder.H - 25)));
	}
	return;
}

//===========================================================================
// function create the text window
//===========================================================================
function CreateTextWindow(string _szTitleText, float _X, float _Y, float _fWidth, float _fHeight)
{
	m_pTextLabel = R6WindowTextLabelExt(CreateWindow(Class'R6Window.R6WindowTextLabelExt', _X, _Y, _fWidth, _fHeight, self));
	m_pTextLabel.SetBorderParam(0, 7.0000000, 0.0000000, 1.0000000, Root.Colors.White);
	m_pTextLabel.SetBorderParam(1, 1.0000000, 0.0000000, 1.0000000, Root.Colors.White);
	m_pTextLabel.SetBorderParam(2, 1.0000000, 1.0000000, 1.0000000, Root.Colors.White);
	m_pTextLabel.SetBorderParam(3, 1.0000000, 1.0000000, 1.0000000, Root.Colors.White);
	m_pTextLabel.m_Font = Root.Fonts[8];
	m_pTextLabel.m_vTextColor = Root.Colors.White;
	m_pTextLabel.AddTextLabel(_szTitleText, 0.0000000, 0.0000000, _fWidth, 2, false, 0.0000000, m_bResizePopUpOnTextLabel);
	m_pTextLabel.AddTextLabel("", (_fWidth - float(10)), 0.0000000, 0.0000000, 1, false, 0.0000000, true);
	m_pTextLabel.m_bTextCenterToWindow = true;
	m_pTextLabel.m_eCornerType = 1;
	SetCornerColor(1, Root.Colors.White);
	return;
}

function ModifyTextWindow(string _szTitleText, float _X, float _Y, float _fWidth, float _fHeight)
{
	// End:0x1DB
	if((m_pTextLabel != none))
	{
		m_pTextLabel.WinLeft = _X;
		m_pTextLabel.WinTop = _Y;
		m_pTextLabel.WinWidth = _fWidth;
		m_pTextLabel.WinHeight = _fHeight;
		m_pTextLabel.SetBorderParam(0, 7.0000000, 0.0000000, 1.0000000, Root.Colors.White);
		m_pTextLabel.SetBorderParam(1, 1.0000000, 0.0000000, 1.0000000, Root.Colors.White);
		m_pTextLabel.SetBorderParam(2, 1.0000000, 1.0000000, 1.0000000, Root.Colors.White);
		m_pTextLabel.SetBorderParam(3, 1.0000000, 1.0000000, 1.0000000, Root.Colors.White);
		m_pTextLabel.Clear();
		m_pTextLabel.m_vTextColor = Root.Colors.White;
		m_pTextLabel.AddTextLabel(_szTitleText, 0.0000000, 0.0000000, _fWidth, 2, false, 0.0000000, m_bResizePopUpOnTextLabel);
		m_pTextLabel.AddTextLabel("", (_fWidth - float(10)), 0.0000000, 0.0000000, 1, false, 0.0000000, true);
		m_pTextLabel.m_bTextCenterToWindow = true;
	}
	return;
}

function TextWindowOnly(string _szTitleText, float _X, float _Y, float _fWidth, float _fHeight)
{
	// End:0x1D4
	if((m_pTextLabel != none))
	{
		m_bTextWindowOnly = true;
		SetNoBorder();
		m_eCornerType = 0;
		m_RWindowBorder.H = 0;
		m_pTextLabel.WinLeft = _X;
		m_pTextLabel.WinTop = _Y;
		m_pTextLabel.WinWidth = _fWidth;
		m_pTextLabel.WinHeight = _fHeight;
		m_pTextLabel.SetBorderParam(0, 7.0000000, 0.0000000, 1.0000000, Root.Colors.White);
		m_pTextLabel.SetBorderParam(1, 7.0000000, 0.0000000, 1.0000000, Root.Colors.White);
		m_pTextLabel.SetBorderParam(2, 1.0000000, 1.0000000, 1.0000000, Root.Colors.White);
		m_pTextLabel.SetBorderParam(3, 1.0000000, 1.0000000, 1.0000000, Root.Colors.White);
		m_pTextLabel.m_eCornerType = 3;
		m_pTextLabel.Clear();
		m_pTextLabel.m_vTextColor = Root.Colors.White;
		m_pTextLabel.AddTextLabel(_szTitleText, 0.0000000, 0.0000000, _fWidth, 2, false);
		m_pTextLabel.m_bTextCenterToWindow = true;
	}
	return;
}

function UpdateTimeInTextLabel(int _iNewTime, optional string _StringInstead)
{
	local Color vTimeColor;
	local string szTemp;

	// End:0xC6
	if((m_pTextLabel != none))
	{
		vTimeColor = Root.Colors.White;
		// End:0x51
		if((_iNewTime < 10))
		{
			vTimeColor = Root.Colors.Red;
		}
		// End:0x6B
		if((_StringInstead != ""))
		{
			szTemp = _StringInstead;			
		}
		else
		{
			// End:0x85
			if((_iNewTime == -1))
			{
				szTemp = "";				
			}
			else
			{
				szTemp = Class'Engine.Actor'.static.ConvertIntTimeToString(_iNewTime);
			}
		}
		m_pTextLabel.ChangeColorLabel(vTimeColor, 1);
		m_pTextLabel.ChangeTextLabel(szTemp, 1);
	}
	return;
}

//===========================================================================
// function create the pop up frame under the text window
//===========================================================================
function CreatePopUpFrame(float _X, float _Y, float _fWidth, float _fHeight)
{
	local float fBorderSize, fBorderWidth;

	fBorderSize = 1.0000000;
	fBorderWidth = 1.0000000;
	m_RWindowBorder.X = int(_X);
	m_RWindowBorder.Y = int(_Y);
	m_RWindowBorder.W = int(_fWidth);
	m_RWindowBorder.H = int(_fHeight);
	ActiveBorder(int(0), false);
	SetBorderParam(int(1), 7.0000000, (_fHeight - fBorderSize), (_fWidth - float(14)), fBorderWidth, Root.Colors.White);
	SetBorderParam(int(2), fBorderSize, 0.0000000, fBorderWidth, (_fHeight - (float(2) * fBorderSize)), Root.Colors.White);
	SetBorderParam(int(3), (_fWidth - float(2)), 0.0000000, fBorderWidth, (_fHeight - (float(2) * fBorderSize)), Root.Colors.White);
	m_eCornerType = 2;
	SetCornerColor(int(2), Root.Colors.White);
	return;
}

//===========================================================================
// function to assign each border param
//===========================================================================
function SetBorderParam(int _iBorderType, float _X, float _Y, float _fWidth, float _fHeight, Color _vColor)
{
	m_sBorderForm[_iBorderType].fXPos = (_X + float(m_RWindowBorder.X));
	m_sBorderForm[_iBorderType].fYPos = (_Y + float(m_RWindowBorder.Y));
	m_sBorderForm[_iBorderType].fWidth = _fWidth;
	m_sBorderForm[_iBorderType].fHeight = _fHeight;
	m_sBorderForm[_iBorderType].vColor = _vColor;
	m_sBorderForm[_iBorderType].bActive = true;
	m_bNoBorderToDraw = false;
	return;
}

//===========================================================================
// function to active border or not
//===========================================================================
// active border or not
function ActiveBorder(int _iBorderType, bool _Active)
{
	local int i;
	local bool bNoBorderToDraw;

	m_sBorderForm[_iBorderType].bActive = _Active;
	bNoBorderToDraw = true;
	i = 0;
	J0x27:

	// End:0x5C [Loop If]
	if((i < 4))
	{
		// End:0x52
		if(m_sBorderForm[_iBorderType].bActive)
		{
			bNoBorderToDraw = false;
			// [Explicit Break]
			goto J0x5C;
		}
		(i++);
		// [Loop Continue]
		goto J0x27;
	}
	J0x5C:

	m_bNoBorderToDraw = bNoBorderToDraw;
	return;
}

function SetNoBorder()
{
	m_bNoBorderToDraw = true;
	return;
}

// set the corner color
function SetCornerColor(int _iCornerType, Color _Color)
{
	// End:0x2E
	if((_iCornerType == int(3)))
	{
		m_eCornerColor[int(1)] = _Color;
		m_eCornerColor[int(2)] = _Color;
	}
	m_eCornerColor[_iCornerType] = _Color;
	return;
}

//===========================================================================
// ResizePopUp: set a new width for the popup base on the size of the text label 
//===========================================================================
function ResizePopUp(float _fNewWidth)
{
	local float fTemp;
	local int ITemp;

	fTemp = ((640.0000000 - _fNewWidth) * 0.5000000);
	(fTemp += 0.5000000);
	ITemp = int(fTemp);
	m_bHideAllChild = true;
	ModifyPopUpFrameWindow(m_pTextLabel.GetTextLabel(0), m_pTextLabel.WinHeight, float(ITemp), m_pTextLabel.WinTop, _fNewWidth, float(m_RWindowBorder.H), m_iPopUpButtonsType);
	return;
}

function SetPopUpResizable(bool _bResizable)
{
	m_bResizePopUpOnTextLabel = _bResizable;
	m_bHideAllChild = _bResizable;
	return;
}

//===========================================================================
// function to set pop up window button 
//===========================================================================
function SetButtonsType(int _iButtonsType)
{
	m_iPopUpButtonsType = _iButtonsType;
	switch(_iButtonsType)
	{
		// End:0x28
		case int(2):
			SetupPopUpBox(2, 3, 3);
			// End:0x62
			break;
		// End:0x3C
		case int(4):
			SetupPopUpBox(4, 3);
			// End:0x62
			break;
		// End:0x50
		case int(5):
			SetupPopUpBox(5, 0);
			// End:0x62
			break;
		// End:0xFFFF
		default:
			SetupPopUpBox(1, 4, 3);
			// End:0x62
			break;
			break;
	}
	return;
}

//===========================================================================
// function to set pop up window button 
//===========================================================================
function SetupPopUpBox(UWindowBase.MessageBoxButtons Buttons, UWindowBase.MessageBoxResult InESCResult, optional UWindowBase.MessageBoxResult InEnterResult)
{
	// End:0x2E
	if((m_ButClientArea != none))
	{
		R6WindowPopUpBoxCW(m_ButClientArea).SetupPopUpBoxClient(Buttons, InESCResult, InEnterResult);
	}
	Result = InESCResult;
	DefaultResult = InESCResult;
	return;
}

//===========================================================================
// Close the pop up window and advice owner
//===========================================================================
function Close(optional bool bByParent)
{
	local R6GameOptions pGameOptions;
	local bool bGOSaveConfig;

	// End:0x0B
	if(m_bPopUpLock)
	{
		return;
	}
	super.Close(bByParent);
	// End:0x132
	if(m_bDisablePopUpActive)
	{
		// End:0x132
		if((m_ButClientArea != none))
		{
			pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
			bGOSaveConfig = true;
			switch(m_ePopUpID)
			{
				// End:0x83
				case 39:
					pGameOptions.PopUpQuickPlay = (!R6WindowPopUpBoxCW(m_ButClientArea).m_pDisablePopUpButton.m_bSelected);
					// End:0x11D
					break;
				// End:0xBA
				case 48:
					pGameOptions.PopUpLoadPlan = (!R6WindowPopUpBoxCW(m_ButClientArea).m_pDisablePopUpButton.m_bSelected);
					// End:0x11D
					break;
				// End:0xFFFF
				default:
					Log("Need to add your disable/enable pop-up ID in game options to have this feature ON");
					bGOSaveConfig = false;
					// End:0x11D
					break;
					break;
			}
			// End:0x132
			if(bGOSaveConfig)
			{
				pGameOptions.SaveConfig();
			}
		}
	}
	// End:0x151
	if((m_ButClientArea != none))
	{
		R6WindowPopUpBoxCW(m_ButClientArea).CancelAcceptsFocus();
	}
	OwnerWindow.PopUpBoxDone(Result, m_ePopUpID);
	// End:0x18E
	if((m_ClientArea != none))
	{
		m_ClientArea.PopUpBoxDone(Result, m_ePopUpID);
	}
	Result = DefaultResult;
	return;
}

//===========================================================================
// This allows the client area to get notified of showwindows
//===========================================================================
function ShowWindow()
{
	super.ShowWindow();
	// End:0x17
	if(m_bResizePopUpOnTextLabel)
	{
		m_bHideAllChild = true;
	}
	// End:0x3F
	if(m_bDetectKey)
	{
		// End:0x3F
		if((m_ButClientArea != none))
		{
			R6WindowPopUpBoxCW(m_ButClientArea).SetAcceptsFocus();
		}
	}
	// End:0x59
	if((m_ClientArea != none))
	{
		m_ClientArea.ShowWindow();
	}
	return;
}

function ShowLockPopUp()
{
	m_bPopUpLock = true;
	ShowWindow();
	return;
}

function HideWindow()
{
	m_bPopUpLock = false;
	super.HideWindow();
	return;
}

function WindowEvent(UWindowWindow.WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	super.WindowEvent(Msg, C, X, Y, Key);
	// End:0x7A
	if(m_bDetectKey)
	{
		// End:0x7A
		if((int(Msg) == int(9)))
		{
			// End:0x7A
			if((m_ButClientArea != none))
			{
				// End:0x7A
				if(m_ButClientArea.IsA('R6WindowPopUpBoxCW'))
				{
					R6WindowPopUpBoxCW(m_ButClientArea).KeyDown(Key, X, Y);
				}
			}
		}
	}
	return;
}

//=========================================================================================
// AddDisableDLG: add a disable text and box to disable-enable pop-up
//=========================================================================================
function AddDisableDLG()
{
	local R6GameOptions pGameOptions;

	// End:0xAC
	if((m_ButClientArea != none))
	{
		R6WindowPopUpBoxCW(m_ButClientArea).AddDisablePopUpButton();
		pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
		switch(m_ePopUpID)
		{
			// End:0x6F
			case 39:
				R6WindowPopUpBoxCW(m_ButClientArea).m_pDisablePopUpButton.m_bSelected = (!pGameOptions.PopUpQuickPlay);
				// End:0xAC
				break;
			// End:0xA6
			case 48:
				R6WindowPopUpBoxCW(m_ButClientArea).m_pDisablePopUpButton.m_bSelected = (!pGameOptions.PopUpLoadPlan);
				// End:0xAC
				break;
			// End:0xFFFF
			default:
				// End:0xAC
				break;
				break;
		}
	}
	m_bDisablePopUpActive = true;
	return;
}

//=========================================================================================
// RemoveDisableDLG: remove a disable text and box to disable-enable pop-up
//=========================================================================================
function RemoveDisableDLG()
{
	// End:0x1F
	if((m_ButClientArea != none))
	{
		R6WindowPopUpBoxCW(m_ButClientArea).RemoveDisablePopUpButton();
	}
	m_bDisablePopUpActive = false;
	return;
}

defaultproperties
{
	m_DrawStyle=5
	m_bBGFullScreen=true
	m_bBGClientArea=true
	m_bDetectKey=true
	m_fHBorderHeight=2.0000000
	m_fVBorderWidth=2.0000000
	m_fHBorderPadding=7.0000000
	m_fVBorderPadding=2.0000000
	m_fVBorderOffset=1.0000000
	m_BGTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_HBorderTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_VBorderTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_topLeftCornerT=Texture'R6MenuTextures.Gui_BoxScroll'
	m_ClientClass=Class'UWindow.UWindowClientWindow'
	m_BGTextureRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=17954,ZoneNumber=0)
	m_HBorderTextureRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=16418,ZoneNumber=0)
	m_VBorderTextureRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=16418,ZoneNumber=0)
	m_topLeftCornerR=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=3106,ZoneNumber=0)
	SimpleBorderRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=16418,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var eCornerType
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var h
// REMOVED IN 1.60: var g
// REMOVED IN 1.60: var t
