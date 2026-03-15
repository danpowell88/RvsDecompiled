//=============================================================================
// R6MenuMPCreateGameTab - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuMPMenuTab.uc : All the create game tab menu were define overhere
//                       You can choose only one of the 3 possible settings!!!!
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/15  * Create by Yannick Joly
//=============================================================================
class R6MenuMPCreateGameTab extends UWindowDialogClientWindow;

const K_HALFWINDOWWIDTH = 310;

enum eCreateGameWindow_ID
{
	eCGW_NotDefine,                 // 0
	eCGW_Opt,                       // 1
	eCGW_Camera,                    // 2
	eCGW_MapList,                   // 3
	eCGW_Password,                  // 4
	eCGW_AdminPassword,             // 5
	eCGW_LeftAdvOpt,                // 6
	eCGW_RightAdvOpt                // 7
};

struct stServerGameOpt
{
	var UWindowWindow pGameOptList;
	var Actor.EGameModeInfo eGameMode;  // the gamemode with list was associate
	var R6MenuMPCreateGameTab.eCreateGameWindow_ID eCGWindowID;
};

var Actor.EGameModeInfo m_eCurrentGameMode;  // the current game mode
var bool m_bInitComplete;  // the init is complete or not
var bool m_bNewServerProfile;
var bool m_bInGame;  // temp
var R6MenuButtonsDefines m_pButtonsDef;
var array<R6MenuMPCreateGameTab> m_ALinkWindow;
var array<stServerGameOpt> m_AServerGameOpt;  // an array of all buttons list and their associate gamemode
//temp until you can get the info from modmanager
var array<Actor.EGameModeInfo> m_ANbOfGameMode;
var array<string> m_ALocGameMode;

//*******************************************************************************************
// INIT
//*******************************************************************************************
function Created()
{
	m_ANbOfGameMode[0] = GetPlayerOwner().3;
	m_ANbOfGameMode[1] = GetPlayerOwner().2;
	m_ALocGameMode[0] = Localize("MultiPlayer", "GameMode_Adversarial", "R6Menu");
	m_ALocGameMode[1] = Localize("MultiPlayer", "GameMode_Cooperative", "R6Menu");
	super(UWindowWindow).Created();
	m_pButtonsDef = R6MenuButtonsDefines(GetButtonsDefinesUnique(Root.MenuClassDefines.ClassButtonsDefines));
	m_pButtonsDef.SetButtonsSizes((310.0000000 - float(15)), 15.0000000);
	return;
}

//===============================================================
// CreateListOfButtons: create the stServerGameOpt for this list of buttons
//===============================================================
function CreateListOfButtons(float _fX, float _fY, float _fW, float _fH, Actor.EGameModeInfo _eGameMode, R6MenuMPCreateGameTab.eCreateGameWindow_ID _eCGWindowID)
{
	local stServerGameOpt stNewSGOItem;
	local R6WindowListGeneral pTempList;

	pTempList = R6WindowListGeneral(CreateWindow(Class'R6Window.R6WindowListGeneral', _fX, _fY, _fW, _fH, self));
	pTempList.bAlwaysBehind = true;
	stNewSGOItem.pGameOptList = pTempList;
	stNewSGOItem.eGameMode = _eGameMode;
	stNewSGOItem.eCGWindowID = _eCGWindowID;
	AddWindowInCreateGameArray(stNewSGOItem);
	UpdateButtons(stNewSGOItem.eGameMode, stNewSGOItem.eCGWindowID);
	return;
}

//===============================================================
// UpdateButtons: do the init of the buttons you need
//===============================================================
function UpdateButtons(Actor.EGameModeInfo _eGameMode, R6MenuMPCreateGameTab.eCreateGameWindow_ID _eCGWindowID, optional bool _bUpdateValue)
{
	return;
}

function R6WindowButtonAndEditBox CreateButAndEditBox(float _X, float _Y, float _W, float _H, string _szButName, string _szButTip, string _szCheckBoxTip)
{
	local R6WindowButtonAndEditBox pNewBut;

	pNewBut = R6WindowButtonAndEditBox(CreateControl(Class'R6Window.R6WindowButtonAndEditBox', _X, _Y, _W, _H, self));
	pNewBut.m_TextFont = Root.Fonts[5];
	pNewBut.m_vTextColor = Root.Colors.White;
	pNewBut.m_vBorder = Root.Colors.White;
	pNewBut.m_bSelected = false;
	pNewBut.CreateTextAndBox(_szButName, _szButTip, 0.0000000, 1);
	pNewBut.CreateEditBox(((310.0000000 * 0.5000000) - float(36)));
	pNewBut.m_pEditBox.EditBox.bPassword = true;
	pNewBut.m_pEditBox.EditBox.MaxLength = 16;
	pNewBut.SetEditBoxTip(_szCheckBoxTip);
	return pNewBut;
	return;
}

function SetButtonAndEditBox(R6MenuMPCreateGameTab.eCreateGameWindow_ID _eCGW_ID, string _szEditBoxValue, bool _bSelected)
{
	local R6WindowButtonAndEditBox pBut;

	pBut = R6WindowButtonAndEditBox(GetList(GetCurrentGameMode(), _eCGW_ID));
	// End:0x5A
	if((pBut != none))
	{
		pBut.m_pEditBox.SetValue(_szEditBoxValue);
		pBut.m_bSelected = _bSelected;
	}
	return;
}

//*******************************************************************************************
// UTILITIES FUNCTIONS
//*******************************************************************************************
function AddLinkWindow(R6MenuMPCreateGameTab _pLinkWindow)
{
	m_ALinkWindow[m_ALinkWindow.Length] = _pLinkWindow;
	return;
}

//===============================================================
// AddWindowInCreateGameArray: add Window object in creategame array window. 
//===============================================================
function AddWindowInCreateGameArray(stServerGameOpt _NewList)
{
	m_AServerGameOpt[m_AServerGameOpt.Length] = _NewList;
	return;
}

//===============================================================
// GetList: get list base on his gamemode and ID
//===============================================================
function UWindowWindow GetList(Actor.EGameModeInfo _eGameMode, R6MenuMPCreateGameTab.eCreateGameWindow_ID _eCGWindowID)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x70 [Loop If]
	if((i < m_AServerGameOpt.Length))
	{
		// End:0x66
		if(((int(m_AServerGameOpt[i].eGameMode) == int(_eGameMode)) && (int(m_AServerGameOpt[i].eCGWindowID) == int(_eCGWindowID))))
		{
			return m_AServerGameOpt[i].pGameOptList;
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return none;
	return;
}

function UpdateMenuOptions(int _iButID, bool _bNewValue, R6WindowListGeneral _pOptionsList, optional bool _bChangeByUserClick)
{
	return;
}

//===============================================================
// SetCurrentGameMode: set the new game mode
//===============================================================
function SetCurrentGameMode(Actor.EGameModeInfo _eGameMode, optional bool _bAdviceLinkWindow)
{
	local int i;

	// End:0x44
	if(_bAdviceLinkWindow)
	{
		i = 0;
		J0x10:

		// End:0x44 [Loop If]
		if((i < m_ALinkWindow.Length))
		{
			m_ALinkWindow[i].SetCurrentGameMode(_eGameMode);
			(i++);
			// [Loop Continue]
			goto J0x10;
		}
	}
	i = 0;
	J0x4B:

	// End:0xDC [Loop If]
	if((i < m_AServerGameOpt.Length))
	{
		// End:0xD2
		if((int(m_AServerGameOpt[i].eGameMode) != int(_eGameMode)))
		{
			// End:0xB8
			if(m_AServerGameOpt[i].pGameOptList.IsA('R6WindowListGeneral'))
			{
				R6WindowListGeneral(m_AServerGameOpt[i].pGameOptList).ChangeVisualItems(false);
			}
			m_AServerGameOpt[i].pGameOptList.HideWindow();
		}
		(i++);
		// [Loop Continue]
		goto J0x4B;
	}
	i = 0;
	J0xE3:

	// End:0x17F [Loop If]
	if((i < m_AServerGameOpt.Length))
	{
		// End:0x175
		if((int(m_AServerGameOpt[i].eGameMode) == int(_eGameMode)))
		{
			m_AServerGameOpt[i].pGameOptList.ShowWindow();
			// End:0x16A
			if(m_AServerGameOpt[i].pGameOptList.IsA('R6WindowListGeneral'))
			{
				R6WindowListGeneral(m_AServerGameOpt[i].pGameOptList).ChangeVisualItems(true);
			}
			m_eCurrentGameMode = _eGameMode;
		}
		(i++);
		// [Loop Continue]
		goto J0xE3;
	}
	RefreshCGButtons();
	return;
}

function Actor.EGameModeInfo GetCurrentGameMode()
{
	return m_eCurrentGameMode;
	return;
}

//*******************************************************************************************
// IN-GAME FUNCTIONS
//*******************************************************************************************
function Refresh()
{
	return;
}

function bool SendNewMapSettings(out byte _bMapCount)
{
	return false;
	return;
}

function bool SendNewServerSettings()
{
	return false;
	return;
}

//*******************************************************************************************
// SERVER OPTIONS FUNCTIONS
//*******************************************************************************************
//=======================================================================
// RefreshServerOpt: Refresh the creategame options according the value find in class R6ServerInfo (init from server.ini)
//=======================================================================
function RefreshServerOpt(optional bool _bNewServerProfile)
{
	RefreshCGButtons();
	return;
}

function RefreshCGButtons()
{
	local int i;

	i = 0;
	J0x07:

	// End:0x67 [Loop If]
	if((i < m_AServerGameOpt.Length))
	{
		// End:0x5D
		if((int(m_AServerGameOpt[i].eGameMode) == int(GetCurrentGameMode())))
		{
			UpdateButtons(m_AServerGameOpt[i].eGameMode, m_AServerGameOpt[i].eCGWindowID, true);
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

function SetServerOptions()
{
	return;
}

//*******************************************************************************************
// NOTIFY FUNCTIONS
//*******************************************************************************************
//=================================================================
// notify the parent window by using the appropriate parent function
//=================================================================
function Notify(UWindowDialogControl C, byte E)
{
	local bool bProcessNotify;

	// End:0x35
	if((int(E) == 2))
	{
		// End:0x35
		if(C.IsA('R6WindowButtonBox'))
		{
			ManageR6ButtonBoxNotify(C);
			bProcessNotify = true;
		}
	}
	// End:0x5C
	if(((bProcessNotify && m_bInitComplete) && (!m_bNewServerProfile)))
	{
		SetServerOptions();
	}
	return;
}

//=================================================================
// manage the R6WindowButton notify message
//=================================================================
function ManageR6ButtonNotify(UWindowDialogControl C, byte E)
{
	switch(E)
	{
		// End:0x65
		case 9:
			R6WindowButton(C).SetButtonBorderColor(Root.Colors.White);
			R6WindowButton(C).TextColor = Root.Colors.White;
			// End:0xC6
			break;
		// End:0xC3
		case 12:
			R6WindowButton(C).SetButtonBorderColor(Root.Colors.BlueLight);
			R6WindowButton(C).TextColor = Root.Colors.BlueLight;
			// End:0xC6
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

/////////////////////////////////////////////////////////////////
// manage the R6WindowButtonBox notify message
/////////////////////////////////////////////////////////////////
function ManageR6ButtonBoxNotify(UWindowDialogControl C)
{
	// End:0x83
	if(R6WindowButtonBox(C).GetSelectStatus())
	{
		R6WindowButtonBox(C).m_bSelected = (!R6WindowButtonBox(C).m_bSelected);
		UpdateMenuOptions(R6WindowButtonBox(C).m_iButtonID, R6WindowButtonBox(C).m_bSelected, R6WindowListGeneral(GetList(GetCurrentGameMode(), 1)), true);
	}
	return;
}

/////////////////////////////////////////////////////////////////
// manage the R6WindowButtonAndEditBox notify message
/////////////////////////////////////////////////////////////////
function ManageR6ButtonAndEditBoxNotify(UWindowDialogControl C)
{
	// End:0x42
	if(R6WindowButtonAndEditBox(C).GetSelectStatus())
	{
		R6WindowButtonAndEditBox(C).m_bSelected = (!R6WindowButtonAndEditBox(C).m_bSelected);
	}
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_bShowLog
