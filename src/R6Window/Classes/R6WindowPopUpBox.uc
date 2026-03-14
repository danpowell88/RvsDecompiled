//=============================================================================
//  R6WindowPopUpBox.uc : This provides the simple frame for all the pop-up window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/04 * Created by Yannick Joly
//=============================================================================
class R6WindowPopUpBox extends UWindowWindow;

// --- Constants ---
const C_fTITLE_TIME_OFFSET =  10;
const K_FBUTTON_HEIGHT_REGION =  25;
const K_BORDER_HOR_OFF =  1;
const K_BORDER_VER_OFF =  1;

// --- Enums ---
enum eCornerType // To draw some corners
{
	No_Corners,
    Top_Corners,
	Bottom_Corners,       
	All_Corners
} m_eCornerType;

struct stBorderForm
{
    var color   vColor;
    var FLOAT   fXPos;
    var FLOAT   fYPos;
    var FLOAT   fWidth;
    var FLOAT   fHeight;
    var bool    bActive;
//    var bool    bBorderSet;
};
enum eBorderType     // the type of the border you want 
{
    Border_Top,
    Border_Bottom,
    Border_Left,
    Border_Right 
};

// --- Structs ---
struct stBorderForm
{
    var color   vColor;
    var FLOAT   fXPos;
    var FLOAT   fYPos;
    var FLOAT   fWidth;
    var FLOAT   fHeight;
    var bool    bActive;
//    var bool    bBorderSet;
};

// --- Variables ---
// var ? bActive; // REMOVED IN 1.60
// var ? fHeight; // REMOVED IN 1.60
// var ? fWidth; // REMOVED IN 1.60
// var ? fXPos; // REMOVED IN 1.60
// var ? fYPos; // REMOVED IN 1.60
// var ? vColor; // REMOVED IN 1.60
var R6WindowTextLabelExt m_pTextLabel;
var UWindowWindow m_ClientArea;
var Region m_RWindowBorder;
var UWindowWindow m_ButClientArea;
var EPopUpID m_ePopUpID;
// 0 = top ; 1 = down ; 2 = Left ; 3 = Right
var stBorderForm m_sBorderForm[4];
var MessageBoxResult Result;
var bool m_bHideAllChild;
var Color m_eCornerColor[4];
var bool m_bResizePopUpOnTextLabel;
//This is to create the window that needs the frame
var class<UWindowWindow> m_ClientClass;
var Region SimpleBorderRegion;
var bool m_bNoBorderToDraw;
// the disable pop-up button is there
var bool m_bDisablePopUpActive;
// if true, popup will not close, only hidewindow will close it
var bool m_bPopUpLock;
var bool m_bTextWindowOnly;
var eCornerType m_eCornerType;
// ^ NEW IN 1.60
var int m_iPopUpButtonsType;
// detect escape and enter key
var bool m_bDetectKey;
var MessageBoxResult DefaultResult;
// force to draw the button line
var bool m_bForceButtonLine;
// true if you want the bck for all the screen, false the bck is only for the pop up size
var bool m_bBGFullScreen;
// inside the frame pop-up -- include the header
var Color m_vClientAreaColor;
// the full back ground color
var Color m_vFullBGColor;
// Put = None when no background is needed
var Texture m_BGTexture;
var Texture m_HBorderTexture;
// ^ NEW IN 1.60
var Texture m_VBorderTexture;
var Texture m_topLeftCornerT;
// the background texture region
var Region m_BGTextureRegion;
var Region m_HBorderTextureRegion;
// ^ NEW IN 1.60
var Region m_VBorderTextureRegion;
// ^ NEW IN 1.60
var Region m_topLeftCornerR;
var float m_fHBorderHeight;
// ^ NEW IN 1.60
// Border size
var float m_fVBorderWidth;
var float m_fHBorderPadding;
// ^ NEW IN 1.60
//////////////////////////////
//Please make sure you set the Padding correctly if you use the offsets values
//////////////////////////////
// Allow the borders not to start in corners
var float m_fVBorderPadding;
var float m_fHBorderOffset;
// ^ NEW IN 1.60
// Border offset if you want the borders to
var float m_fVBorderOffset;
var int m_DrawStyle;
// true, draw client area and header background
var bool m_bBGClientArea;

// --- Functions ---
//===========================================================================
// function to create a std pop up window with clientwindow (for button)
//===========================================================================
function CreateStdPopUpWindow(float _fTextHeight, float _fXPos, float _fYPos, float _fWidth, optional int _iButtonsType, float _fHeight, string _szPopUpTitle) {}
//===========================================================================
// function to create a std pop up window (only the visual)
//===========================================================================
function CreatePopUpFrameWindow(float _fTextHeight, float _fXPos, float _fYPos, float _fWidth, float _fHeight, string _szPopUpTitle) {}
function ModifyPopUpFrameWindow(float _fTextHeight, float _fXPos, float _fYPos, float _fWidth, optional int _iButtonsType, float _fHeight, string _szPopUpTitle) {}
function TextWindowOnly(float _fWidth, float _fHeight, float _Y, float _X, string _szTitleText) {}
function SetPopUpResizable(bool _bResizable) {}
//===========================================================================
// function to set pop up window button
//===========================================================================
function SetButtonsType(int _iButtonsType) {}
function WindowEvent(WinMessage Msg, float X, float Y, int Key, Canvas C) {}
//=========================================================================================
// AddDisableDLG: add a disable text and box to disable-enable pop-up
//=========================================================================================
function AddDisableDLG() {}
function BeforePaint(Canvas C, float X, float Y) {}
function Paint(Canvas C, float X, float Y) {}
//Just Pass any Control to this function to get it to show in the frame
function CreateClientWindow(optional bool _bDrawClientOnBorder, optional bool _bButtonBar, class<UWindowWindow> ClientClass) {}
//===========================================================================
// function create the text window
//===========================================================================
function CreateTextWindow(float _fWidth, float _fHeight, float _Y, float _X, string _szTitleText) {}
//===========================================================================
// function to set pop up window button
//===========================================================================
function SetupPopUpBox(MessageBoxResult InESCResult, optional MessageBoxResult InEnterResult, MessageBoxButtons Buttons) {}
// default initialisation
// we have to set after the create window the parameters you want
function Created() {}
//===========================================================================
// ResizePopUp: set a new width for the popup base on the size of the text label
//===========================================================================
function ResizePopUp(float _fNewWidth) {}
//===========================================================================
// function to assign each border param
//===========================================================================
function SetBorderParam(int _iBorderType, Color _vColor, float _fHeight, float _fWidth, float _Y, float _X) {}
// set the corner color
function SetCornerColor(Color _Color, int _iCornerType) {}
//===========================================================================
// function create the pop up frame under the text window
//===========================================================================
function CreatePopUpFrame(float _fHeight, float _fWidth, float _Y, float _X) {}
function ModifyTextWindow(float _fWidth, float _fHeight, float _Y, float _X, string _szTitleText) {}
//===========================================================================
// Close the pop up window and advice owner
//===========================================================================
function Close(optional bool bByParent) {}
//===========================================================================
// function to active border or not
//===========================================================================
// active border or not
function ActiveBorder(int _iBorderType, bool _Active) {}
function UpdateTimeInTextLabel(int _iNewTime, optional string _StringInstead) {}
function SetNoBorder() {}
//===========================================================================
// This allows the client area to get notified of showwindows
//===========================================================================
function ShowWindow() {}
function ShowLockPopUp() {}
function HideWindow() {}
//=========================================================================================
// RemoveDisableDLG: remove a disable text and box to disable-enable pop-up
//=========================================================================================
function RemoveDisableDLG() {}

defaultproperties
{
}
