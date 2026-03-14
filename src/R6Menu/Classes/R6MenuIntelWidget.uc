//=============================================================================
//  R6MenuIntelWidget.uc : This is the Intel menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/12 * Created by Alexandre Dionne
//=============================================================================
class R6MenuIntelWidget extends R6MenuLaptopWidget;

// --- Constants ---
const szScrollTextArraySize =  10;
const K_fVideoWidth =  438;
const K_fVideoHeight =  230;

// --- Enums ---
enum EMenuIntelButtonID
{
    ButtonControlID,
    ButtonClarkID,
    ButtonSweenyID,
    ButtonNewsID,
    ButtonMissionID
};

// --- Variables ---
var R6WindowBitMap m_2DSpeaker;
var R6WindowWrappedTextArea m_MissionObjectives;
// ^ NEW IN 1.60
var R6WindowWrappedTextArea m_SrcrollingTextArea;
// ^ NEW IN 1.60
var Sound m_sndPlayEvent;
var float m_fVideoLeft;
// ^ NEW IN 1.60
var int m_iCurrentSpeaker;
var float m_fVideoBottom;
// ^ NEW IN 1.60
var R6MenuIntelRadioArea m_SpeakerControls;
var R6WindowTextLabel m_CodeName;
// ^ NEW IN 1.60
var R6WindowTextLabel m_DateTime;
// ^ NEW IN 1.60
var string m_szScrollingText;
var float m_fVideoRight;
// ^ NEW IN 1.60
var float m_fVideoTop;
// ^ NEW IN 1.60
var float m_fUpBGWidth;
// ^ NEW IN 1.60
var bool bShowLog;
var float m_fLabelHeight;
// ^ NEW IN 1.60
var float m_fPaddingBetweenElements;
// ^ NEW IN 1.60
var float m_fLaptopPadding;
// ^ NEW IN 1.60
var Font m_labelFont;
var R6MenuVideo m_MissionDesc;
var float m_fLeftTileModulo;
// ^ NEW IN 1.60
var float m_fRightBGWidth;
// ^ NEW IN 1.60
var float m_fBottomHeight;
// ^ NEW IN 1.60
var R6WindowTextLabel m_Location;
// ^ NEW IN 1.60
var float m_fRightTileModulo;
// ^ NEW IN 1.60
var float m_fBottomTileModulo;
// ^ NEW IN 1.60
var Region m_RControl;
// ^ NEW IN 1.60
var Region m_RClark;
// ^ NEW IN 1.60
var Region m_RSweeney;
// ^ NEW IN 1.60
var Region m_RNewsWire;
// ^ NEW IN 1.60
var Region m_RMissionOrder;
// ^ NEW IN 1.60
var Texture m_TSpeaker;
var Texture m_Texture;
var Font m_R6Font14;
var float m_fSpeakerWidgetWidth;
// ^ NEW IN 1.60
var float m_fSpeakerWidgetHeight;
// ^ NEW IN 1.60
var bool m_bAddText;

// --- Functions ---
function ShowWindow() {}
// set all the text corresponding with _szOriginal#
// return true if at least we find one valid sentence at _szOriginal
function bool SetMissionText(string _szOriginal) {}
// ^ NEW IN 1.60
function DisplayText(R6WindowWrappedTextArea _R6WindowWrappedTextArea, float _X, float _Y, Font _TextFont, Color _Color) {}
function Created() {}
function Paint(Canvas C, float X, float Y) {}
// depending the selected button, find the text corresponding and fill it in a text array ( this is for R6Mission.int)
// ex ID_CONTROL, ID_CONTROL1, ID_CONTROL2, ID_CONTROL3, etc...
function ManageButtonSelection(int _eButtonSelection) {}
function Reset() {}
function HideWindow() {}
function StopIntelWidgetSound() {}

defaultproperties
{
}
