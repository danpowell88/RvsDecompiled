//=============================================================================
// R6WindowRootWindow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowRootWindow.uc : This root is an intermediate between uwindowrootwindow and all the menu root window
//							to have access for R6WindowPopUpBox
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/11/07 * Created by Yannick Joly
//=============================================================================
class R6WindowRootWindow extends UWindowRootWindow
    config;

struct stKeyAvailability
{
	var int iKey;
	var int iWidgetKA;
};

struct StWidget
{
	var UWindowWindow m_pWidget;
	var R6WindowPopUpBox m_pPopUpFrame;
	var UWindowRootWindow.eGameWidgetID m_eGameWidgetID;
	var name m_WidgetConsoleState;
	var int iWidgetKA;
};

var int m_iWidgetKA;  // widget key availability
var int m_iLastKeyDown;
var R6WindowPopUpBox m_pSimplePopUp;  // a real simple pop-up
// NEW IN 1.60
var Texture m_BGTexture[2];
var array<StWidget> m_pListOfActiveWidget;
var array<stKeyAvailability> m_pListOfKeyAvailability;
var array<R6WindowPopUpBox> m_pListOfFramePopUp;
var Region m_RSimplePopUp;  // the region of the simple popup
var Region m_RAddDlgSimplePopUp;  // Pop up with disable button
// MPF - Eric
var string m_szCurrentBackgroundSubDirectory;  // Directory of the background currently displayed

//=====================================================================================================
// SimplePopUp: Provide a simple pop-up
//=====================================================================================================
function SimplePopUp(string _szTitle, string _szText, UWindowBase.EPopUpID _ePopUpID, optional int _iButtonsType, optional bool bAddDisableDlg, optional UWindowWindow OwnerWindow)
{
	local R6WindowWrappedTextArea pTextZone;

	// End:0x17E
	if((m_pSimplePopUp == none))
	{
		m_pSimplePopUp = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000, OwnerWindow));
		m_pSimplePopUp.SetPopUpResizable((int(_ePopUpID) != int(56)));
		m_pSimplePopUp.bAlwaysOnTop = true;
		m_pSimplePopUp.CreateStdPopUpWindow(_szTitle, 25.0000000, float(m_RSimplePopUp.X), float(m_RSimplePopUp.Y), float(m_RSimplePopUp.W), float(m_RSimplePopUp.H), _iButtonsType);
		m_pSimplePopUp.CreateClientWindow(Class'R6Window.R6WindowWrappedTextArea');
		m_pSimplePopUp.m_ePopUpID = _ePopUpID;
		pTextZone = R6WindowWrappedTextArea(m_pSimplePopUp.m_ClientArea);
		pTextZone.SetScrollable(true);
		pTextZone.m_fXOffSet = 5.0000000;
		pTextZone.m_fYOffSet = 5.0000000;
		pTextZone.AddText(_szText, Root.Colors.White, Root.Fonts[12]);
		pTextZone.m_bDrawBorders = false;		
	}
	else
	{
		pTextZone = R6WindowWrappedTextArea(m_pSimplePopUp.m_ClientArea);
		pTextZone.Clear(true, true);
		pTextZone.AddText(_szText, Root.Colors.White, Root.Fonts[12]);
		m_pSimplePopUp.OwnerWindow = OwnerWindow;
		m_pSimplePopUp.SetPopUpResizable((int(_ePopUpID) != int(56)));
		m_pSimplePopUp.ModifyPopUpFrameWindow(_szTitle, 25.0000000, float(m_RSimplePopUp.X), float(m_RSimplePopUp.Y), float(m_RSimplePopUp.W), float(m_RSimplePopUp.H), _iButtonsType);
		m_pSimplePopUp.m_ePopUpID = _ePopUpID;
		m_pSimplePopUp.ShowWindow();
	}
	// End:0x2F0
	if((int(_ePopUpID) == int(56)))
	{
		m_pSimplePopUp.m_ePopUpID = _ePopUpID;
		m_pSimplePopUp.TextWindowOnly(_szTitle, float(m_RSimplePopUp.X), float(m_RSimplePopUp.Y), float(m_RSimplePopUp.W), float(m_RSimplePopUp.H));		
	}
	else
	{
		// End:0x359
		if(bAddDisableDlg)
		{
			m_pSimplePopUp.AddDisableDLG();
			m_pSimplePopUp.ModifyPopUpFrameWindow(_szTitle, 25.0000000, float(m_RAddDlgSimplePopUp.X), float(m_RAddDlgSimplePopUp.Y), float(m_RAddDlgSimplePopUp.W), float(m_RAddDlgSimplePopUp.H), _iButtonsType);			
		}
		else
		{
			m_pSimplePopUp.RemoveDisableDLG();
		}
	}
	// End:0x38B
	if(Console.IsInState('Game'))
	{
		Console.LaunchUWindow();
	}
	return;
}

//=====================================================================================================
// SimpleTextPopUp: Provide a simple pop-up for text only, no buttons
//=====================================================================================================
function SimpleTextPopUp(string _szText)
{
	SimplePopUp(_szText, "", 56, int(5));
	return;
}

function PopUpBoxDone(UWindowBase.MessageBoxResult Result, UWindowBase.EPopUpID _ePopUpID)
{
	m_RSimplePopUp = self.default.m_RSimplePopUp;
	switch(_ePopUpID)
	{
		// End:0x40
		case 33:
			// End:0x3D
			if((int(Result) == int(4)))
			{
				Console.m_bInterruptConnectionProcess = true;
			}
			// End:0x46
			break;
		// End:0xFFFF
		default:
			// End:0x46
			break;
			break;
	}
	return;
}

function UWindowBase.EPopUpID GetSimplePopUpID()
{
	// End:0x2E
	if(((m_pSimplePopUp != none) && m_pSimplePopUp.bWindowVisible))
	{
		return m_pSimplePopUp.m_ePopUpID;
	}
	return 0;
	return;
}

function ModifyPopUpInsideText(array<string> _ANewText)
{
	local R6WindowWrappedTextArea pTextZone;
	local int i;

	// End:0xC5
	if(((m_pSimplePopUp != none) && m_pSimplePopUp.bWindowVisible))
	{
		// End:0xC5
		if((int(m_pSimplePopUp.m_ePopUpID) == int(33)))
		{
			pTextZone = R6WindowWrappedTextArea(m_pSimplePopUp.m_ClientArea);
			pTextZone.Clear(true, true);
			i = 0;
			J0x69:

			// End:0xC5 [Loop If]
			if((i < _ANewText.Length))
			{
				pTextZone.AddText(_ANewText[i], Root.Colors.White, Root.Fonts[12]);
				(i++);
				// [Loop Continue]
				goto J0x69;
			}
		}
	}
	return;
}

//=============================================================================================
// FillListOfKeyAvailability: Fill the list of key availability
//							  Each widget (pop-up by a key) is define here
//=============================================================================================
function FillListOfKeyAvailability()
{
	return;
}

//=============================================================================================
// AddKeyInList: Add key in key list availability
//=============================================================================================
function AddKeyInList(int _iKey, int _iWKA)
{
	local stKeyAvailability stKeyATemp;

	stKeyATemp.iKey = _iKey;
	stKeyATemp.iWidgetKA = _iWKA;
	m_pListOfKeyAvailability[m_pListOfKeyAvailability.Length] = stKeyATemp;
	return;
}

//=========================================================================================================
// GetPopUpFrame: Get a pop-up frame
//=========================================================================================================
function R6WindowPopUpBox GetPopUpFrame(int _iIndex)
{
	local R6WindowPopUpBox pPopUpFrame;

	// End:0x24
	if((m_pListOfFramePopUp.Length > _iIndex))
	{
		pPopUpFrame = m_pListOfFramePopUp[_iIndex];		
	}
	else
	{
		pPopUpFrame = R6WindowPopUpBox(CreateWindow(Class'R6Window.R6WindowPopUpBox', 0.0000000, 0.0000000, 640.0000000, 480.0000000));
		pPopUpFrame.CreatePopUpFrameWindow("", 0.0000000, 0.0000000, 0.0000000, 0.0000000, 0.0000000);
		pPopUpFrame.m_bBGFullScreen = true;
		pPopUpFrame.HideWindow();
		m_pListOfFramePopUp[m_pListOfFramePopUp.Length] = pPopUpFrame;
	}
	return pPopUpFrame;
	return;
}

//===================================================================================
// ManagePrevWInHistory:  Remove the previous widget in the list (in fact the one that you have on the screen, you do a changewidget)
//===================================================================================
function ManagePrevWInHistory(bool _bClearPrevWInHistory, out int _iNbOfWidgetInList)
{
	// End:0x7E
	if(_bClearPrevWInHistory)
	{
		// End:0x7E
		if((_iNbOfWidgetInList != 0))
		{
			// End:0x4A
			if((m_pListOfActiveWidget[(_iNbOfWidgetInList - 1)].m_pPopUpFrame != none))
			{
				m_pListOfActiveWidget[(_iNbOfWidgetInList - 1)].m_pPopUpFrame.HideWindow();
			}
			m_pListOfActiveWidget[(_iNbOfWidgetInList - 1)].m_pWidget.HideWindow();
			m_pListOfActiveWidget.Remove((_iNbOfWidgetInList - 1), 1);
			(_iNbOfWidgetInList -= 1);
		}
	}
	return;
}

function bool IsWidgetIsInHistory(UWindowRootWindow.eGameWidgetID _eWidgetToFind)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x41 [Loop If]
	if((i < m_pListOfActiveWidget.Length))
	{
		// End:0x37
		if((int(m_pListOfActiveWidget[i].m_eGameWidgetID) == int(_eWidgetToFind)))
		{
			return true;
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return false;
	return;
}

//===================================================================================
// CloseAllWindow:  Process a hide window on all the window in the list 
//===================================================================================
function CloseAllWindow()
{
	local int i, iNbOfWindow;

	iNbOfWindow = m_pListOfActiveWidget.Length;
	i = 0;
	J0x13:

	// End:0x76 [Loop If]
	if((i < iNbOfWindow))
	{
		// End:0x52
		if((m_pListOfActiveWidget[i].m_pPopUpFrame != none))
		{
			m_pListOfActiveWidget[i].m_pPopUpFrame.HideWindow();
		}
		m_pListOfActiveWidget[i].m_pWidget.HideWindow();
		(i++);
		// [Loop Continue]
		goto J0x13;
	}
	m_pListOfActiveWidget.Remove(0, iNbOfWindow);
	return;
}

function SetLoadRandomBackgroundImage(string _szFolder)
{
	m_szCurrentBackgroundSubDirectory = _szFolder;
	Class'Engine.Actor'.static.LoadRandomBackgroundImage(_szFolder);
	return;
}

function PaintBackground(Canvas C, UWindowWindow _WidgetWindow)
{
	// End:0xA2
	if(((m_BGTexture[0] != none) && (m_BGTexture[1] != none)))
	{
		_WidgetWindow.DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, 512.0000000, 512.0000000, 0.0000000, 0.0000000, 512.0000000, 512.0000000, m_BGTexture[0]);
		_WidgetWindow.DrawStretchedTextureSegment(C, 512.0000000, 0.0000000, 512.0000000, 512.0000000, 0.0000000, 0.0000000, 512.0000000, 512.0000000, m_BGTexture[1]);
	}
	return;
}

function CheckConsoleTypingState(name _RequestConsoleState)
{
	// End:0x2B
	if(Console.IsInState('Typing'))
	{
		Console.ConsoleState = _RequestConsoleState;		
	}
	else
	{
		Console.GotoState(_RequestConsoleState);
	}
	return;
}

//===================================================================================================
// GetMapNameLocalisation: Get the map name localisation. Return true if we found a name
//===================================================================================================
function bool GetMapNameLocalisation(string _szMapName, out string _szMapNameLoc, optional bool _bReturnInitName)
{
	local int i, j;
	local R6Console R6Console;
	local R6MissionDescription mission;
	local LevelInfo pLevel;

	pLevel = GetLevel();
	R6Console = R6Console(Root.Console);
	_szMapNameLoc = "";
	i = 0;
	J0x34:

	// End:0xC6 [Loop If]
	if((i < R6Console.m_aMissionDescriptions.Length))
	{
		mission = R6Console.m_aMissionDescriptions[i];
		// End:0xBC
		if((Caps(mission.m_MapName) == Caps(_szMapName)))
		{
			_szMapNameLoc = Localize(mission.m_MapName, "ID_MENUNAME", mission.LocalizationFile, true);
			// [Explicit Break]
			goto J0xC6;
		}
		(++i);
		// [Loop Continue]
		goto J0x34;
	}
	J0xC6:

	// End:0xE8
	if((_bReturnInitName && (_szMapNameLoc == "")))
	{
		_szMapNameLoc = _szMapName;
	}
	return (_szMapNameLoc != "");
	return;
}

defaultproperties
{
	m_iLastKeyDown=-1
	m_BGTexture[0]=Texture'R6MenuBG.Backgrounds.GenericMainMenu0'
	m_BGTexture[1]=Texture'R6MenuBG.Backgrounds.GenericMainMenu1'
	m_RSimplePopUp=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=43554,ZoneNumber=0)
	m_RAddDlgSimplePopUp=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=42274,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var Texture
// REMOVED IN 1.60: function GetSimplePopUpID
