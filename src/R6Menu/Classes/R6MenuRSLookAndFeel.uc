//=============================================================================
//  R6MenuRSLookAndFeel.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6MenuRSLookAndFeel extends R6WindowLookAndFeel;

// --- Constants ---
const SIZEBORDER =  3;
const BRSIZEBORDER =  15;
const RadioButtonHeight =  17;
const RadioButtonWidth =  16;

// --- Enums ---
enum ERSBLButton
{
    ERSBL_BLActive,
    ERSBL_BLLeft,
    ERSBL_BLRight
};
enum ENavBarButton
{
    NBB_Home,
    NBB_Option,
    NBB_Archive,
    NBB_TeleCom,
    NBB_Roster,
    NBB_Gear,
    NBB_Planning,
    NBB_Play,
    NBB_Load,
    NBB_Save
};
enum eSignChoiceButton
{
    eSCB_Accept,
    eSCB_Cancel
};

// --- Structs ---
struct STLapTopFramePlus// addon to LaptopFrame
{
	var Region T1;
	var Region T2;
    var Region T3;
    var Region T4On;    
	var Region T4Off;    
};

struct STLapTopFrame// extends STWindowFrame
{
    var Region TL;
    var Region T;
    var Region TR;
    var Region L;
    var Region R;
    var Region BL;
    var Region B;
    var Region BR;
    var Region L2;
    var Region R2;
	var Region L3;
    var Region R3;
	var Region L4;
	var Region R4;
	
};

struct STWindowFrame
{
    var Region	TL;
    var Region	T;
    var Region	TR;
    var Region	L;
    var Region	R;
    var Region	BL;
    var Region	B;
    var Region	BR;
};

struct STFrameColor
{
    var Color TextColor;
    var Color SelTextColor;
    var Color DisableColor;
    var Color TitleColor;
    var Color TitleBack;
    var Color ButtonBack;
    var Color SelButtonBack;
    var Color ButtonLine;
};

// --- Variables ---
// var ? B; // REMOVED IN 1.60
// var ? BL; // REMOVED IN 1.60
// var ? BR; // REMOVED IN 1.60
// var ? ButtonBack; // REMOVED IN 1.60
// var ? ButtonLine; // REMOVED IN 1.60
// var ? DisableColor; // REMOVED IN 1.60
// var ? L; // REMOVED IN 1.60
// var ? L2; // REMOVED IN 1.60
// var ? L3; // REMOVED IN 1.60
// var ? L4; // REMOVED IN 1.60
// var ? R; // REMOVED IN 1.60
// var ? R2; // REMOVED IN 1.60
// var ? R3; // REMOVED IN 1.60
// var ? R4; // REMOVED IN 1.60
// var ? SelButtonBack; // REMOVED IN 1.60
// var ? SelTextColor; // REMOVED IN 1.60
// var ? T; // REMOVED IN 1.60
// var ? T1; // REMOVED IN 1.60
// var ? T2; // REMOVED IN 1.60
// var ? T3; // REMOVED IN 1.60
// var ? T4Off; // REMOVED IN 1.60
// var ? T4On; // REMOVED IN 1.60
// var ? TL; // REMOVED IN 1.60
// var ? TR; // REMOVED IN 1.60
// var ? TextColor; // REMOVED IN 1.60
// var ? TitleBack; // REMOVED IN 1.60
// var ? TitleColor; // REMOVED IN 1.60
//-----------------------------------------------
//ListBox
var Region m_topLeftCornerR;
//-----------------------------------------------
// Laptop frame
var STLapTopFrame m_stLapTopFrame;
// Popup ActionPoint menu
var Region m_PopupArrowUp;
//-----------------------------------------------
//Square Border
var Region m_RSquareBgLeft;
var Region m_PopupArrowDown;
//-----------------------------------------------
// Create game menu
// the region of the arrow button for map list
var RegionButton m_RArrow[2];
var Region m_RSquareBgRight;
var Region m_RSquareBgMid;
var RegionButton m_BLTitleL;
// Menu Texture
var Texture m_NavBarTex;
//-----------------------------------------------
//R6WindowButtonMainMenu
var float m_fScrollRate;
//-----------------------------------------------
// Simple Pop-up Window (ex. JoinIp window with an edit box)
// accept button, cancel button
var RegionButton m_RBAcceptCancel[2];
var Texture m_TSquareBg;
//-----------------------------------------------
// Navigation Bar
var Region m_NavBarBack[12];
var Region m_FrameSBL;
var int m_fHSBButtonImageY;
var int m_fVSBButtonImageY;
// ^ NEW IN 1.60
//-----------------------------------------------
//Scroll Bar
var int m_fHSBButtonImageX;
var int m_fVSBButtonImageX;
// ^ NEW IN 1.60
//-----------------------------------------------
// In-Game Menu
var Texture m_TIcon;
var int m_iMultiplyer;
var float m_fCurrentPct;
// ^ NEW IN 1.60
var Region m_FrameSBR;
var Region m_FrameSB;
// the in-game menu intermission text header
var float m_fTextHeaderHeight;
var Region m_SBUpGear;
var Region m_SBDownGear;
var int m_fComboImageX;
// ^ NEW IN 1.60
//-----------------------------------------------
//Combo
var int m_fComboImageY;
var RegionButton m_BLTitleC;
var RegionButton m_BLTitleR;
var STLapTopFramePlus m_stLapTopFramePlus;
var Region m_SBScrollerActive;

// --- Functions ---
function Menu_DrawMenuBar(UWindowMenuBar W, Canvas C) {}
//======================================================================================
// Draw the pop-up frame
// IMPORTANT: the parameters for the window are set in R6WindowPopUpBox
//======================================================================================
function DrawPopUpFrameWindow(R6WindowPopUpBox W, Canvas C) {}
function R6List_DrawBackground(R6WindowListBox W, Canvas C) {}
function FW_DrawWindowFrame(UWindowFramedWindow W, Canvas C) {}
function R6FW_DrawWindowFrame(R6WindowFramedWindow W, Canvas C) {}
// ****** Combo Drawing Functions ******
function Combo_SetupSizes(UWindowComboControl W, Canvas C) {}
function Combo_Draw(UWindowComboControl W, Canvas C) {}
function Tab_DrawTab(UWindowTabControlTabArea Tab, Canvas C, float Y, float X, float W, bool bShowText, bool bActiveTab, string Text, bool bLeftmostTab, float H) {}
function DrawBox(UWindowWindow W, Canvas C, float X, float Y, float Width, float Height) {}
//===================================================================================================
// Draw the navigation bar (ex.: in briefing menu, at the bottom of the page
//===================================================================================================
function DrawNavigationBar(R6MenuNavigationBar W, Canvas C) {}
function Editbox_SetupSizes(UWindowEditControl W, Canvas C) {}
function DrawInGamePlayerStats(float _fY, float _fHeight, float _fWidth, UWindowWindow W, Canvas C, int _iPlayerStats, float _fX) {}
function SB_VDraw(UWindowVScrollbar W, Canvas C) {}
function Tab_SetupLeftButton(UWindowTabControlLeftButton W) {}
function Tab_SetupRightButton(UWindowTabControlRightButton W) {}
function SB_HDraw(UWindowHScrollbar W, Canvas C) {}
function Button_SetupMapList(UWindowButton W, bool _bInverseTex) {}
function DrawPopupButtonDown(R6MenuPopUpStayDownButton W, Canvas C) {}
function FW_SetupFrameButtons(UWindowFramedWindow W, Canvas C) {}
// ****** Scroll Bar ******
function SB_SetupUpButton(UWindowSBUpButton W) {}
function SB_SetupDownButton(UWindowSBDownButton W) {}
function Combo_SetupButton(UWindowComboButton W) {}
function SB_SetupLeftButton(UWindowSBLeftButton W) {}
function SB_SetupRightButton(UWindowSBRightButton W) {}
function R6FW_SetupFrameButtons(R6WindowFramedWindow W, Canvas C) {}
function FrameHitTest FW_HitTest(float X, float Y, UWindowFramedWindow W) {}
// ^ NEW IN 1.60
function FrameHitTest R6FW_HitTest(float X, float Y, R6WindowFramedWindow W) {}
// ^ NEW IN 1.60
function DrawPopupButtonUp(R6MenuPopUpStayDownButton W, Canvas C) {}
function DrawPopUpTextBackGround(UWindowWindow W, Canvas C, float _fHeight) {}
function DrawPopupButtonDisable(R6MenuPopUpStayDownButton W, Canvas C) {}
function DrawPopupButtonOver(R6MenuPopUpStayDownButton W, Canvas C) {}
//===================================================================
// Set the region for the accept and cancel(X) button
//===================================================================
function Button_SetupEnumSignChoice(UWindowButton W, int eRegionId) {}
// ****** R6 Add-On ******
function DrawWinTop(R6WindowHSplitter W, Canvas C) {}
function DrawHSplitterT(R6WindowHSplitter W, Canvas C) {}
function DrawHSplitterB(R6WindowHSplitter W, Canvas C) {}
//Function to draw a different background then the basic SimpleBorder
function DrawSpecialButtonBorder(R6WindowButton Button, Canvas C, float X, float Y) {}
function Menu_DrawMenuBarItem(UWindowMenuBar B, Canvas C, float X, float W, UWindowMenuBarItem i, float Y, float H) {}
//=================================================================================
// This is draw a combo list item
//=================================================================================
function ComboList_DrawItem(Canvas C, UWindowComboList Combo, float Y, float X, float H, float W, string Text, bool bSelected) {}
function Region FW_GetClientArea(UWindowFramedWindow W) {}
// ^ NEW IN 1.60
function DrawButtonBorder(UWindowWindow W, Canvas C, optional bool _bDefineBorderColor) {}
function DrawBGShading(UWindowWindow Window, Canvas C, float X, float Y, float W, float H) {}
// ****** Client Area Drawing Functions *******
function DrawClientArea(UWindowClientWindow W, Canvas C) {}
function Region R6FW_GetClientArea(R6WindowFramedWindow W) {}
// ^ NEW IN 1.60
function Texture R6GetTexture(R6WindowFramedWindow W) {}
// ^ NEW IN 1.60
//=================================================================================
// This is draw the border of a combo list item
//=================================================================================
function ComboList_DrawBackground(UWindowComboList W, Canvas C) {}
function Tab_DrawTabPageArea(UWindowPageControl W, Canvas C, UWindowPageWindow P) {}
function Tab_GetTabSize(UWindowTabControlTabArea Tab, Canvas C, string Text, out float W, out float H) {}
//=======================================================================================================
// This function return the region where to draw the icon X and Y depending of window region
// (W and H are 0)
//=======================================================================================================
function Region CenterIconInBox(Region _RIconRegion, float _fX, float _fY, float _fWidth, float _fHeight) {}
// ^ NEW IN 1.60
function List_DrawBackground(UWindowListControl W, Canvas C) {}
function Editbox_Draw(UWindowEditControl W, Canvas C) {}
function Tab_SetTabPageSize(UWindowPageControl W, UWindowPageWindow P) {}
function Setup() {}
function Menu_DrawPulldownMenuBackground(UWindowPulldownMenu W, Canvas C) {}
function Menu_DrawPulldownMenuItem(UWindowPulldownMenu M, UWindowPulldownMenuItem Item, Canvas C, float X, float Y, float W, float H, bool bSelected) {}
//=================================================================================================
// Get the size (height) of the header window (interwidget menu)
//=================================================================================================
function float GetTextHeaderSize() {}
// ^ NEW IN 1.60

defaultproperties
{
}
