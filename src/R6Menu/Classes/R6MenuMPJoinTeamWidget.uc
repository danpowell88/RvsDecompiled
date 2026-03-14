//=============================================================================
//  R6MenuMPJoinTeamWidget.uc : The first in game multi player menu window
//  the size of the window is 800 * 600
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//    2002/03/7  * Modify by Yannick Joly
//=============================================================================
class R6MenuMPJoinTeamWidget extends R6MenuWidget;

// --- Constants ---
const C_iMIN_TIME_FOR_WELCOME_SCREEN =  10;

// --- Variables ---
var R6WindowButtonMPInGame m_pButAlphaTeam;
var R6WindowButtonMPInGame m_pButBravoTeam;
var R6WindowButtonMPInGame m_pButAutoTeam;
var R6WindowTextLabelExt m_pInfoText;
//Character Texture
var R6WindowBitMap m_SingleChar;
var R6WindowButtonMPInGame m_pButSpectator;
var R6WindowButtonMPInGame m_pButCurrentSelected;
var R6WindowBitMap m_LeftChar;
var R6WindowBitMap m_RightChar;
var R6WindowBitMap m_BetweenCharIcon;
var Region m_RSpectatorChar;
var int m_iButtonHeight;
// ^ NEW IN 1.60
var bool m_bIsTeamGame;
//Vertical padding between buttons
var int m_iYBetweenButtonPadding;
// time before forcing auto team
var float m_fTimeAutoTeam;
var int m_iButtonWidth;
var Region m_pHelpReg;
var Region m_RBetweenChar;
var Texture m_TAlphaChar;
var Region m_RAlphaChar;
var Texture m_TBetaChar;
var Region m_RBetaChar;
// time before a refresh
var float m_fTimeForRefresh;
var R6MenuHelpWindow m_pHelpTextWindow;
var array<array> m_AArmorDescriptions;
var string m_szMenuRedTeamPawnClass;
// backup Class and check if they have changed (server can change them)
var string m_szMenuGreenTeamPawnClass;
var Texture m_TSpectatorChar;
var Texture m_TBetweenChar;
var int m_iBetweenCharYPos;
// ^ NEW IN 1.60
var int m_iBetweenCharXPos;
// ^ NEW IN 1.60
var int m_iRightCharYPos;
// ^ NEW IN 1.60
var int m_iRightCharXPos;
// ^ NEW IN 1.60
var int m_iLeftCharYPos;
// ^ NEW IN 1.60
var int m_iLeftCharXPos;
// ^ NEW IN 1.60
var int m_iSingleCharYPos;
// ^ NEW IN 1.60
var int m_iSingleCharXPos;
// ^ NEW IN 1.60

// --- Functions ---
//===============================================================================
//       Called by the root just after the showwindow()
//===============================================================================
function SetMenuToDisplay(string _szCurrentGameType) {}
//===============================================================================
//       Initial Creation of the text labels
//===============================================================================
function CreateTextLabels() {}
//===============================================================================
//       INIT SECTION Called after we display the page
//===============================================================================
//===============================================================================
//       Initial Creation of the buttons
//===============================================================================
function CreateButtons() {}
function Tick(float DeltaTime) {}
function RefreshButtonsStatus() {}
/////////////////////////////////////////////////////////////////
// display the help text in the m_pHelpTextWindow (derivate for uwindowwindow
/////////////////////////////////////////////////////////////////
function ToolTip(string strTip) {}
function RefreshButtons(string _szCurrentGameType) {}
//===============================================================================
//       This allow us to switch the right bitmap accordingly
//===============================================================================
function Notify(UWindowDialogControl C, byte E) {}
//===============================================================================
// Refresh server info after we display the menu page
//===============================================================================
function RefreshServerInfo() {}
//===============================================================================
// Fills the array with all R6ArmorDescription to retreive Level armor texture
// and texture coordinates
//===============================================================================
function FillDescriptionArray() {}
function HideWindow() {}
//===============================================================================
//       Called after the menu is displayed
//===============================================================================
function RefreshBitmaps() {}
//===============================================================================
//       Initial Creation of the Bitmaps
//===============================================================================
function CreateBitmaps() {}
function Created() {}

defaultproperties
{
}
