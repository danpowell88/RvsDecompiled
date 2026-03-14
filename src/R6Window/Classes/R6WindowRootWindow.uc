//=============================================================================
//  R6WindowRootWindow.uc : This root is an intermediate between uwindowrootwindow and all the menu root window
//							to have access for R6WindowPopUpBox
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/11/07 * Created by Yannick Joly
//=============================================================================
class R6WindowRootWindow extends UWindowRootWindow;

// --- Structs ---
struct stKeyAvailability
{
	var INT								iKey;
	var INT								iWidgetKA;
};

struct StWidget
{
	var UWindowWindow					m_pWidget;
	var R6WindowPopUpBox                m_pPopUpFrame; 
	var eGameWidgetID					m_eGameWidgetID;
	var name							m_WidgetConsoleState;
	var INT								iWidgetKA;
};

// --- Variables ---
// var ? iKey; // REMOVED IN 1.60
// var ? iWidgetKA; // REMOVED IN 1.60
// var ? m_WidgetConsoleState; // REMOVED IN 1.60
// var ? m_eGameWidgetID; // REMOVED IN 1.60
// var ? m_pPopUpFrame; // REMOVED IN 1.60
// var ? m_pWidget; // REMOVED IN 1.60
// a real simple pop-up
var R6WindowPopUpBox m_pSimplePopUp;
// the region of the simple popup
var Region m_RSimplePopUp;
var array<array> m_pListOfActiveWidget;
var Texture m_BGTexture[2];
// ^ NEW IN 1.60
// Pop up with disable button
var Region m_RAddDlgSimplePopUp;
var array<array> m_pListOfFramePopUp;
var array<array> m_pListOfKeyAvailability;
// MPF - Eric
// Directory of the background currently displayed
var string m_szCurrentBackgroundSubDirectory;
var int m_iLastKeyDown;
// widget key availability
var int m_iWidgetKA;

// --- Functions ---
function SetLoadRandomBackgroundImage(string _szFolder) {}
function PaintBackground(Canvas C, UWindowWindow _WidgetWindow) {}
function CheckConsoleTypingState(name _RequestConsoleState) {}
//=====================================================================================================
// SimpleTextPopUp: Provide a simple pop-up for text only, no buttons
//=====================================================================================================
function SimpleTextPopUp(string _szText) {}
function PopUpBoxDone(MessageBoxResult Result, EPopUpID _ePopUpID) {}
//=============================================================================================
// AddKeyInList: Add key in key list availability
//=============================================================================================
function AddKeyInList(int _iKey, int _iWKA) {}
//=====================================================================================================
// SimplePopUp: Provide a simple pop-up
//=====================================================================================================
function SimplePopUp(EPopUpID _ePopUpID, string _szTitle, optional int _iButtonsType, string _szText, optional UWindowWindow OwnerWindow, optional bool bAddDisableDlg) {}
//=========================================================================================================
// GetPopUpFrame: Get a pop-up frame
//=========================================================================================================
function R6WindowPopUpBox GetPopUpFrame(int _iIndex) {}
// ^ NEW IN 1.60
//===================================================================================
// ManagePrevWInHistory:  Remove the previous widget in the list (in fact the one that you have on the screen, you do a changewidget)
//===================================================================================
function ManagePrevWInHistory(out int _iNbOfWidgetInList, bool _bClearPrevWInHistory) {}
//===================================================================================
// CloseAllWindow:  Process a hide window on all the window in the list
//===================================================================================
function CloseAllWindow() {}
//===================================================================================================
// GetMapNameLocalisation: Get the map name localisation. Return true if we found a name
//===================================================================================================
function bool GetMapNameLocalisation(out string _szMapNameLoc, string _szMapName, optional bool _bReturnInitName) {}
// ^ NEW IN 1.60
function ModifyPopUpInsideText(array<array> _ANewText) {}
function bool IsWidgetIsInHistory(eGameWidgetID _eWidgetToFind) {}
// ^ NEW IN 1.60
//=============================================================================================
// FillListOfKeyAvailability: Fill the list of key availability
//							  Each widget (pop-up by a key) is define here
//=============================================================================================
function FillListOfKeyAvailability() {}
function EPopUpID GetSimplePopUpID() {}
// ^ NEW IN 1.60

defaultproperties
{
}
