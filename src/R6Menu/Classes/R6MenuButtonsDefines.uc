//=============================================================================
// R6MenuButtonsDefines - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuButtonsDefines.uc : This is the definiton of all the buttons and some function to create it
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/09  * Create by Yannick Joly
//=============================================================================
class R6MenuButtonsDefines extends UWindowWindow;

enum eButLocalizationExt
{
	eBLE_None,                      // 0
	eBLE_DisableToolTip             // 1
};

struct STButton
{
	var string szButtonName;
	var string szTip;
	var float fWidth;
	var float fHeight;
	var int iButtonID;
};

// buttons parameters
var float m_fWidth;
var float m_fHeight;

function SetButtonsSizes(float _fWidth, float _fHeight)
{
	m_fWidth = _fWidth;
	m_fHeight = _fHeight;
	return;
}

function string GetButtonLoc(int _iButtonID, optional bool _bTip, optional R6MenuButtonsDefines.eButLocalizationExt _eBLE)
{
	local string szName, szTip, szExt;

	switch(_iButtonID)
	{
		// End:0x47
		case int(1):
			szName = Localize("MPCreateGame", "Options_RoundMatch", "R6Menu");
			// End:0xD3A
			break;
		// End:0x82
		case int(2):
			szName = Localize("MPCreateGame", "Options_Round", "R6Menu");
			// End:0xD3A
			break;
		// End:0xC3
		case int(3):
			szName = Localize("MPCreateGame", "Options_NbOfPlayers", "R6Menu");
			// End:0xD3A
			break;
		// End:0x102
		case int(4):
			szName = Localize("MPCreateGame", "Options_BombTimer", "R6Menu");
			// End:0xD3A
			break;
		// End:0x141
		case int(5):
			szName = Localize("MPCreateGame", "Options_Spectator", "R6Menu");
			// End:0xD3A
			break;
		// End:0x183
		case int(6):
			szName = Localize("MPCreateGame", "Options_RoundMission", "R6Menu");
			// End:0xD3A
			break;
		// End:0x1C1
		case int(7):
			szName = Localize("MPCreateGame", "Options_BetRound", "R6Menu");
			// End:0xD3A
			break;
		// End:0x200
		case int(8):
			szName = Localize("MPCreateGame", "Options_NbOfTerro", "R6Menu");
			// End:0xD3A
			break;
		// End:0x275
		case int(9):
			szName = Localize("MPCreateGame", "Options_ServerLocation", "R6Menu");
			szTip = Localize("Tip", "Options_ServerLocation", "R6Menu");
			// End:0xD3A
			break;
		// End:0x2E0
		case int(10):
			szName = Localize("MPCreateGame", "Options_Dedicated", "R6Menu");
			szTip = Localize("Tip", "Options_Dedicated", "R6Menu");
			// End:0xD3A
			break;
		// End:0x349
		case int(11):
			szName = Localize("MPCreateGame", "Options_Friendly", "R6Menu");
			szTip = Localize("Tip", "Options_Friendly", "R6Menu");
			// End:0xD3A
			break;
		// End:0x3BE
		case int(12):
			szName = Localize("MPCreateGame", "Options_AllowTeamNames", "R6Menu");
			szTip = Localize("Tip", "Options_AllowTeamNames", "R6Menu");
			// End:0xD3A
			break;
		// End:0x41F
		case int(13):
			szName = Localize("MPCreateGame", "Options_Auto", "R6Menu");
			szTip = Localize("Tip", "Options_Auto", "R6Menu");
			// End:0xD3A
			break;
		// End:0x47C
		case int(14):
			szName = Localize("MPCreateGame", "Options_TK", "R6Menu");
			szTip = Localize("Tip", "Options_TK", "R6Menu");
			// End:0xD3A
			break;
		// End:0x4E9
		case int(15):
			szName = Localize("MPCreateGame", "Options_AllowRadar", "R6Menu");
			szTip = Localize("Tip", "Options_AllowRadar", "R6Menu");
			// End:0xD3A
			break;
		// End:0x554
		case int(16):
			szName = Localize("MPCreateGame", "Options_RotateMap", "R6Menu");
			szTip = Localize("Tip", "Options_RotateMap", "R6Menu");
			// End:0xD3A
			break;
		// End:0x5BD
		case int(17):
			szName = Localize("MPCreateGame", "Options_AIBackup", "R6Menu");
			szTip = Localize("Tip", "Options_AIBackup", "R6Menu");
			// End:0xD3A
			break;
		// End:0x632
		case int(18):
			szName = Localize("MPCreateGame", "Options_ForceFPersonWp", "R6Menu");
			szTip = Localize("Tip", "Options_ForceFPersonWp", "R6Menu");
			// End:0xD3A
			break;
		// End:0x697
		case int(24):
			szName = Localize("MPCreateGame", "Options_FirstP", "R6Menu");
			szTip = Localize("Tip", "Options_FirstP", "R6Menu");
			// End:0xD3A
			break;
		// End:0x6FC
		case int(25):
			szName = Localize("MPCreateGame", "Options_ThirdP", "R6Menu");
			szTip = Localize("Tip", "Options_ThirdP", "R6Menu");
			// End:0xD3A
			break;
		// End:0x769
		case int(26):
			szName = Localize("MPCreateGame", "Options_FreeThirdP", "R6Menu");
			szTip = Localize("Tip", "Options_FreeThirdP", "R6Menu");
			// End:0xD3A
			break;
		// End:0x7CC
		case int(27):
			szName = Localize("MPCreateGame", "Options_Ghost", "R6Menu");
			szTip = Localize("Tip", "Options_Ghost", "R6Menu");
			// End:0xD3A
			break;
		// End:0x82D
		case int(28):
			szName = Localize("MPCreateGame", "Options_Fade", "R6Menu");
			szTip = Localize("Tip", "Options_Fade", "R6Menu");
			// End:0xD3A
			break;
		// End:0x896
		case int(29):
			szName = Localize("MPCreateGame", "Options_TeamOnly", "R6Menu");
			szTip = Localize("Tip", "Options_TeamOnly", "R6Menu");
			// End:0xD3A
			break;
		// End:0x949
		case int(22):
			szName = Localize("MPCreateGame", "Options_PunkBuster", "R6Menu");
			szTip = Localize("Tip", "Options_PunkBuster", "R6Menu");
			// End:0x946
			if((int(_eBLE) == int(1)))
			{
				szExt = Localize("MPCreateGame", "Options_PunkBuster", "R6Menu");
			}
			// End:0xD3A
			break;
		// End:0x9A7
		case int(30):
			szName = Localize("MultiPlayer", "ButtonLogIn", "R6Menu");
			szTip = Localize("Tip", "ButtonLogIn", "R6Menu");
			// End:0xD3A
			break;
		// End:0xA07
		case int(31):
			szName = Localize("MultiPlayer", "ButtonLogOut", "R6Menu");
			szTip = Localize("Tip", "ButtonLogOut", "R6Menu");
			// End:0xD3A
			break;
		// End:0xA63
		case int(32):
			szName = Localize("MultiPlayer", "ButtonJoin", "R6Menu");
			szTip = Localize("Tip", "ButtonJoin", "R6Menu");
			// End:0xD3A
			break;
		// End:0xAC3
		case int(33):
			szName = Localize("MultiPlayer", "ButtonJoinIP", "R6Menu");
			szTip = Localize("Tip", "ButtonJoinIP", "R6Menu");
			// End:0xD3A
			break;
		// End:0xB25
		case int(34):
			szName = Localize("MultiPlayer", "ButtonRefresh", "R6Menu");
			szTip = Localize("Tip", "ButtonRefresh", "R6Menu");
			// End:0xD3A
			break;
		// End:0xB85
		case int(35):
			szName = Localize("MultiPlayer", "ButtonCreate", "R6Menu");
			szTip = Localize("Tip", "ButtonCreate", "R6Menu");
			// End:0xD3A
			break;
		// End:0xBEC
		case int(23):
			szName = Localize("MPCreateGame", "Options_DiffLev", "R6Menu");
			szTip = Localize("Tip", "Options_DiffLev", "R6Menu");
			// End:0xD3A
			break;
		// End:0xC4C
		case int(19):
			szName = Localize("SinglePlayer", "Difficulty1", "R6Menu");
			szTip = Localize("Tip", "Diff_Recruit", "R6Menu");
			// End:0xD3A
			break;
		// End:0xCAC
		case int(20):
			szName = Localize("SinglePlayer", "Difficulty2", "R6Menu");
			szTip = Localize("Tip", "Diff_Veteran", "R6Menu");
			// End:0xD3A
			break;
		// End:0xD0A
		case int(21):
			szName = Localize("SinglePlayer", "Difficulty3", "R6Menu");
			szTip = Localize("Tip", "Diff_Elite", "R6Menu");
			// End:0xD3A
			break;
		// End:0xD1C
		case int(0):
			szName = "";
			// End:0xD3A
			break;
		// End:0xFFFF
		default:
			Log("Button not supported");
			// End:0xD3A
			break;
			break;
	}
	// End:0xD53
	if((int(_eBLE) != int(0)))
	{
		return szExt;		
	}
	else
	{
		// End:0xD65
		if(_bTip)
		{
			return szTip;			
		}
		else
		{
			return szName;
		}
	}
	return;
}

function GetCounterTipLoc(int _iButtonID, out string _szLeftTip, out string _szRightTip)
{
	switch(_iButtonID)
	{
		// End:0x6B
		case int(1):
			_szLeftTip = Localize("Tip", "Options_RoundMatch", "R6Menu");
			_szRightTip = Localize("Tip", "Options_RoundMatch", "R6Menu");
			// End:0x343
			break;
		// End:0xCB
		case int(2):
			_szLeftTip = Localize("Tip", "Options_RoundMin", "R6Menu");
			_szRightTip = Localize("Tip", "Options_RoundMax", "R6Menu");
			// End:0x343
			break;
		// End:0x137
		case int(3):
			_szLeftTip = Localize("Tip", "Options_NbOfPlayersMin", "R6Menu");
			_szRightTip = Localize("Tip", "Options_NbOfPlayersMax", "R6Menu");
			// End:0x343
			break;
		// End:0x199
		case int(4):
			_szLeftTip = Localize("Tip", "Options_BombTimer", "R6Menu");
			_szRightTip = Localize("Tip", "Options_BombTimer", "R6Menu");
			// End:0x343
			break;
		// End:0x1FB
		case int(5):
			_szLeftTip = Localize("Tip", "Options_Spectator", "R6Menu");
			_szRightTip = Localize("Tip", "Options_Spectator", "R6Menu");
			// End:0x343
			break;
		// End:0x263
		case int(6):
			_szLeftTip = Localize("Tip", "Options_RoundMission", "R6Menu");
			_szRightTip = Localize("Tip", "Options_RoundMission", "R6Menu");
			// End:0x343
			break;
		// End:0x2C3
		case int(7):
			_szLeftTip = Localize("Tip", "Options_BetRound", "R6Menu");
			_szRightTip = Localize("Tip", "Options_BetRound", "R6Menu");
			// End:0x343
			break;
		// End:0x325
		case int(8):
			_szLeftTip = Localize("Tip", "Options_NbOfTerro", "R6Menu");
			_szRightTip = Localize("Tip", "Options_NbOfTerro", "R6Menu");
			// End:0x343
			break;
		// End:0xFFFF
		default:
			Log("Button not supported");
			// End:0x343
			break;
			break;
	}
	return;
}

//===============================================================
// AddButtonCombo: Add a buttoncombo with item values in a list
//===============================================================
function AddButtonCombo(int _iButtonID, R6WindowListGeneral _R6WindowListGeneral, optional UWindowWindow _OwnerWindow)
{
	local STButton stButtonTemp;

	// End:0x21
	if((m_fWidth == float(0)))
	{
		m_fWidth = _R6WindowListGeneral.WinWidth;
	}
	// End:0x42
	if((m_fHeight == float(0)))
	{
		m_fHeight = _R6WindowListGeneral.WinHeight;
	}
	stButtonTemp.szButtonName = GetButtonLoc(_iButtonID);
	stButtonTemp.szTip = GetButtonLoc(_iButtonID, true);
	stButtonTemp.fWidth = m_fWidth;
	stButtonTemp.fHeight = m_fHeight;
	stButtonTemp.iButtonID = _iButtonID;
	AddCombo(stButtonTemp, _R6WindowListGeneral, UWindowDialogClientWindow(_OwnerWindow));
	return;
}

//===============================================================================================================
// 
//===============================================================================================================
function AddCombo(STButton _stButton, R6WindowListGeneral _R6WindowListGeneral, UWindowDialogClientWindow _pParentWindow)
{
	local R6WindowComboControl pR6WindowComboControl;
	local R6WindowListGeneralItem GeneralItem;

	GeneralItem = R6WindowListGeneralItem(_R6WindowListGeneral.Items.Append(_R6WindowListGeneral.ListClass));
	pR6WindowComboControl = R6WindowComboControl(_pParentWindow.CreateControl(Class'R6Window.R6WindowComboControl', 0.0000000, 0.0000000, _stButton.fWidth, LookAndFeel.Size_ComboHeight, _R6WindowListGeneral));
	pR6WindowComboControl.AdjustTextW(_stButton.szButtonName, 0.0000000, 0.0000000, (_stButton.fWidth * 0.5000000), LookAndFeel.Size_ComboHeight);
	pR6WindowComboControl.AdjustEditBoxW(0.0000000, 120.0000000, LookAndFeel.Size_ComboHeight);
	pR6WindowComboControl.SetEditBoxTip(_stButton.szTip);
	pR6WindowComboControl.SetValue("", "");
	pR6WindowComboControl.SetFont(6);
	pR6WindowComboControl.m_iButtonID = _stButton.iButtonID;
	GeneralItem.m_pR6WindowComboControl = pR6WindowComboControl;
	GeneralItem.m_iItemID = _stButton.iButtonID;
	return;
}

//===============================================================================================================
// 
//===============================================================================================================
function AddItemInComboButton(int _iButtonID, string _NewItem, string _SecondValue, R6WindowListGeneral _pListToUse)
{
	local R6WindowListGeneralItem TempItem;

	TempItem = R6WindowListGeneralItem(FindButtonItem(_iButtonID, _pListToUse));
	// End:0x72
	if((TempItem.m_pR6WindowComboControl != none))
	{
		// End:0x72
		if((TempItem.m_pR6WindowComboControl.m_iButtonID == _iButtonID))
		{
			TempItem.m_pR6WindowComboControl.AddItem(_NewItem, _SecondValue);
		}
	}
	return;
}

//===============================================================================================================
// 
//===============================================================================================================
function ChangeButtonComboValue(int _iButtonID, string _szNewValue, R6WindowListGeneral _pListToUse, optional bool _bDisabled)
{
	local int iTemFind;
	local R6WindowListGeneralItem TempItem;

	TempItem = R6WindowListGeneralItem(FindButtonItem(_iButtonID, _pListToUse));
	// End:0xCB
	if(((TempItem != none) && (TempItem.m_pR6WindowComboControl != none)))
	{
		// End:0xCB
		if((TempItem.m_pR6WindowComboControl.m_iButtonID == _iButtonID))
		{
			iTemFind = TempItem.m_pR6WindowComboControl.FindItemIndex2(_szNewValue, true);
			// End:0xAD
			if((iTemFind != -1))
			{
				TempItem.m_pR6WindowComboControl.SetSelectedIndex(iTemFind);
			}
			TempItem.m_pR6WindowComboControl.SetDisableButton(_bDisabled);
		}
	}
	return;
}

//===============================================================================================================
// GetButtonComboValue: get the value of the combo
//===============================================================================================================
function string GetButtonComboValue(int _iButtonID, R6WindowListGeneral _pListToUse)
{
	local R6WindowListGeneralItem TempItem;

	TempItem = R6WindowListGeneralItem(FindButtonItem(_iButtonID, _pListToUse));
	// End:0x76
	if(((TempItem != none) && (TempItem.m_pR6WindowComboControl != none)))
	{
		// End:0x76
		if((TempItem.m_pR6WindowComboControl.m_iButtonID == _iButtonID))
		{
			return TempItem.m_pR6WindowComboControl.GetValue2();
		}
	}
	return "";
	return;
}

//===============================================================
// AddButtonInt: Add a button with int values in a list
//===============================================================
function AddButtonInt(int _iButtonID, int _iMin, int _iMax, int _iInitialValue, R6WindowListGeneral _R6WindowListGeneral, optional UWindowWindow _OwnerWindow)
{
	local STButton stButtonTemp;

	// End:0x21
	if((m_fWidth == float(0)))
	{
		m_fWidth = _R6WindowListGeneral.WinWidth;
	}
	// End:0x42
	if((m_fHeight == float(0)))
	{
		m_fHeight = _R6WindowListGeneral.WinHeight;
	}
	stButtonTemp.szButtonName = GetButtonLoc(_iButtonID);
	stButtonTemp.szTip = GetButtonLoc(_iButtonID, true);
	stButtonTemp.fWidth = m_fWidth;
	stButtonTemp.fHeight = m_fHeight;
	stButtonTemp.iButtonID = _iButtonID;
	AddCounterButton(stButtonTemp, _iMin, _iMax, _iInitialValue, _R6WindowListGeneral, _OwnerWindow);
	return;
}

//===============================================================================================================
//
//===============================================================================================================
function AddCounterButton(STButton _stButton, int _iMinValue, int _iMaxValue, int _iDefaultValue, R6WindowListGeneral _R6WindowListGeneral, UWindowWindow _pParentWindow)
{
	local R6WindowCounter pR6WindowCounter;
	local R6WindowListGeneralItem GeneralItem;
	local string szLeftTip, szRightTip;

	GeneralItem = R6WindowListGeneralItem(_R6WindowListGeneral.Items.Append(_R6WindowListGeneral.ListClass));
	pR6WindowCounter = R6WindowCounter(_pParentWindow.CreateWindow(Class'R6Window.R6WindowCounter', 0.0000000, 0.0000000, _stButton.fWidth, _stButton.fHeight, _R6WindowListGeneral));
	pR6WindowCounter.bAlwaysBehind = true;
	pR6WindowCounter.ToolTipString = _stButton.szTip;
	pR6WindowCounter.m_iButtonID = _stButton.iButtonID;
	pR6WindowCounter.SetAdviceParent(true);
	pR6WindowCounter.CreateLabelText(0.0000000, 0.0000000, _stButton.fWidth, _stButton.fHeight);
	pR6WindowCounter.SetLabelText(_stButton.szButtonName, Root.Fonts[5], Root.Colors.White);
	pR6WindowCounter.CreateButtons((_stButton.fWidth - float(53)), 0.0000000, 53.0000000);
	pR6WindowCounter.SetDefaultValues(_iMinValue, _iMaxValue, _iDefaultValue);
	GetCounterTipLoc(_stButton.iButtonID, szLeftTip, szRightTip);
	pR6WindowCounter.SetButtonToolTip(szLeftTip, szRightTip);
	GeneralItem.m_pR6WindowCounter = pR6WindowCounter;
	GeneralItem.m_iItemID = _stButton.iButtonID;
	return;
}

//===============================================================================================================
// 
//===============================================================================================================
function ChangeButtonCounterValue(int _iButtonID, int _iNewValue, R6WindowListGeneral _pListToUse, optional bool _bNotAcceptClick)
{
	local R6WindowListGeneralItem TempItem;

	TempItem = R6WindowListGeneralItem(FindButtonItem(_iButtonID, _pListToUse));
	// End:0x99
	if(((TempItem != none) && (TempItem.m_pR6WindowCounter != none)))
	{
		// End:0x99
		if((TempItem.m_pR6WindowCounter.m_iButtonID == _iButtonID))
		{
			TempItem.m_pR6WindowCounter.SetCounterValue(_iNewValue);
			TempItem.m_pR6WindowCounter.m_bNotAcceptClick = _bNotAcceptClick;
		}
	}
	return;
}

//===============================================================================================================
// 
//===============================================================================================================
function int GetButtonCounterValue(int _iButtonID, R6WindowListGeneral _pListToUse)
{
	local R6WindowListGeneralItem TempItem;

	TempItem = R6WindowListGeneralItem(FindButtonItem(_iButtonID, _pListToUse));
	// End:0x75
	if(((TempItem != none) && (TempItem.m_pR6WindowCounter != none)))
	{
		// End:0x75
		if((TempItem.m_pR6WindowCounter.m_iButtonID == _iButtonID))
		{
			return TempItem.m_pR6WindowCounter.m_iCounter;
		}
	}
	return -1;
	return;
}

//===============================================================================================================
// SetButtonCounterUnlimited: set a counter button to use unlimited value
//===============================================================================================================
function SetButtonCounterUnlimited(int _iButtonID, bool _bUnlimitedCounterOnZero, R6WindowListGeneral _pListToUse)
{
	local R6WindowListGeneralItem TempItem;

	TempItem = R6WindowListGeneralItem(FindButtonItem(_iButtonID, _pListToUse));
	// End:0x7C
	if(((TempItem != none) && (TempItem.m_pR6WindowCounter != none)))
	{
		// End:0x7C
		if((TempItem.m_pR6WindowCounter.m_iButtonID == _iButtonID))
		{
			TempItem.m_pR6WindowCounter.m_bUnlimitedCounterOnZero = _bUnlimitedCounterOnZero;
		}
	}
	return;
}

//===============================================================
// AddButtonInt: Add a button with int values in a list
//===============================================================
function AddButtonBool(int _iButtonID, bool _bInitialValue, R6WindowListGeneral _R6WindowListGeneral, optional UWindowWindow _OwnerWindow)
{
	local STButton stButtonTemp;
	local int iInitialValue;

	// End:0x21
	if((m_fWidth == float(0)))
	{
		m_fWidth = _R6WindowListGeneral.WinWidth;
	}
	// End:0x42
	if((m_fHeight == float(0)))
	{
		m_fHeight = _R6WindowListGeneral.WinHeight;
	}
	stButtonTemp.szButtonName = GetButtonLoc(_iButtonID);
	stButtonTemp.szTip = GetButtonLoc(_iButtonID, true);
	stButtonTemp.fWidth = m_fWidth;
	stButtonTemp.fHeight = m_fHeight;
	stButtonTemp.iButtonID = _iButtonID;
	AddButtonBox(stButtonTemp, _bInitialValue, _R6WindowListGeneral, UWindowDialogClientWindow(_OwnerWindow));
	return;
}

//===============================================================================================================
// 
//===============================================================================================================
function AddButtonBox(STButton _stButton, bool _bSelected, R6WindowListGeneral _R6WindowListGeneral, UWindowDialogClientWindow _pParentWindow)
{
	local R6WindowButtonBox pR6WindowButtonBox;
	local R6WindowListGeneralItem GeneralItem;

	GeneralItem = R6WindowListGeneralItem(_R6WindowListGeneral.Items.Append(_R6WindowListGeneral.ListClass));
	pR6WindowButtonBox = R6WindowButtonBox(_pParentWindow.CreateControl(Class'R6Window.R6WindowButtonBox', 0.0000000, 0.0000000, _stButton.fWidth, _stButton.fHeight, _R6WindowListGeneral));
	pR6WindowButtonBox.m_TextFont = Root.Fonts[5];
	pR6WindowButtonBox.m_vTextColor = Root.Colors.White;
	pR6WindowButtonBox.m_vBorder = Root.Colors.White;
	pR6WindowButtonBox.m_bSelected = _bSelected;
	pR6WindowButtonBox.CreateTextAndBox(_stButton.szButtonName, _stButton.szTip, 0.0000000, _stButton.iButtonID);
	GeneralItem.m_pR6WindowButtonBox = pR6WindowButtonBox;
	GeneralItem.m_iItemID = _stButton.iButtonID;
	return;
}

//===============================================================================================================
// ChangeButtonBoxValue: Change the value of the button box
//===============================================================================================================
function ChangeButtonBoxValue(int _iButtonID, bool _bNewValue, R6WindowListGeneral _pListToUse, optional bool _bDisabled)
{
	local R6WindowListGeneralItem TempItem;

	TempItem = R6WindowListGeneralItem(FindButtonItem(_iButtonID, _pListToUse));
	// End:0xA9
	if(((TempItem != none) && (TempItem.m_pR6WindowButtonBox != none)))
	{
		TempItem.m_pR6WindowButtonBox.m_bSelected = _bNewValue;
		TempItem.m_pR6WindowButtonBox.bDisabled = _bDisabled;
		// End:0xA9
		if(_bDisabled)
		{
			TempItem.m_pR6WindowButtonBox.m_szToolTipWhenDisable = GetButtonLoc(_iButtonID, false, 1);
		}
	}
	return;
}

//===============================================================================================================
// GetButtonBoxValue: Get the value of a button box
//===============================================================================================================
function bool GetButtonBoxValue(int _iButtonID, R6WindowListGeneral _pListToUse)
{
	local R6WindowListGeneralItem TempItem;

	TempItem = R6WindowListGeneralItem(FindButtonItem(_iButtonID, _pListToUse));
	// End:0x55
	if(((TempItem != none) && (TempItem.m_pR6WindowButtonBox != none)))
	{
		return TempItem.m_pR6WindowButtonBox.m_bSelected;
	}
	return false;
	return;
}

//===============================================================================================================
// IsButtonBoxDisabled: The button is disable?
//===============================================================================================================
function bool IsButtonBoxDisabled(int _iButtonID, R6WindowListGeneral _pListToUse)
{
	local R6WindowListGeneralItem TempItem;

	TempItem = R6WindowListGeneralItem(FindButtonItem(_iButtonID, _pListToUse));
	// End:0x55
	if(((TempItem != none) && (TempItem.m_pR6WindowButtonBox != none)))
	{
		return TempItem.m_pR6WindowButtonBox.bDisabled;
	}
	return false;
	return;
}

// NEW IN 1.60
function AddFakeButton(R6WindowListGeneral _R6WindowListGeneral, optional UWindowWindow _OwnerWindow)
{
	local R6WindowListGeneralItem GeneralItem;

	GeneralItem = R6WindowListGeneralItem(_R6WindowListGeneral.Items.Append(_R6WindowListGeneral.ListClass));
	GeneralItem.m_bFakeItem = true;
	GeneralItem.m_iItemID = int(0);
	return;
}

function UWindowList FindButtonItem(int _iButtonID, R6WindowListGeneral _pListToUse)
{
	local UWindowList ListItem;
	local R6WindowListGeneralItem TempItem;

	// End:0x75
	if((_pListToUse != none))
	{
		ListItem = _pListToUse.Items.Next;
		J0x28:

		// End:0x75 [Loop If]
		if((ListItem != none))
		{
			TempItem = R6WindowListGeneralItem(ListItem);
			// End:0x5E
			if((TempItem.m_iItemID == _iButtonID))
			{
				// [Explicit Break]
				goto J0x75;
			}
			ListItem = ListItem.Next;
			// [Loop Continue]
			goto J0x28;
		}
	}
	J0x75:

	return ListItem;
	return;
}

//===============================================================================================================
// 
//===============================================================================================================
function AssociateButtons(int _iButtonID1, int _iButtonID2, int _iAssociateButCase, R6WindowListGeneral _R6WindowListGeneral)
{
	local UWindowList ListItem;
	local R6WindowListGeneralItem pItem1, pItem2, TempItem;

	ListItem = _R6WindowListGeneral.Items.Next;
	J0x1D:

	// End:0xD7 [Loop If]
	if((ListItem != none))
	{
		TempItem = R6WindowListGeneralItem(ListItem);
		// End:0xC0
		if((TempItem.m_pR6WindowCounter != none))
		{
			// End:0x86
			if((TempItem.m_pR6WindowCounter.m_iButtonID == _iButtonID1))
			{
				pItem1 = TempItem;
				// End:0x86
				if((pItem2 != none))
				{
					// [Explicit Break]
					goto J0xD7;
				}
			}
			// End:0xC0
			if((TempItem.m_pR6WindowCounter.m_iButtonID == _iButtonID2))
			{
				pItem2 = TempItem;
				// End:0xC0
				if((pItem1 != none))
				{
					// [Explicit Break]
					goto J0xD7;
				}
			}
		}
		ListItem = ListItem.Next;
		// [Loop Continue]
		goto J0x1D;
	}
	J0xD7:

	// End:0x132
	if(((pItem1 != none) && (pItem2 != none)))
	{
		pItem1.m_pR6WindowCounter.m_pAssociateButton = pItem2.m_pR6WindowCounter;
		pItem1.m_pR6WindowCounter.m_iAssociateButCase = _iAssociateButCase;
	}
	return;
}

