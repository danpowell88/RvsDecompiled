//=============================================================================
//  R6WindowTextIconsListBox.uc : New and improved List Box
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/22 * Created by Alexandre Dionne
//=============================================================================
class R6WindowTextIconsListBox extends R6WindowListBox;

// --- Constants ---
const C_iDISTANCE_BETWEEN_ICON =  4;
const C_iFIRST_ICON_XPOS =  3;

// --- Variables ---
// var ? m_font; // REMOVED IN 1.60
// color text item disabled
var Color m_DisabledTextColor;
// BackGround color when selected
var Color m_BGSelColor;
// color for selected text
var Color m_SelTextColor;
// If we want the Separator to be displayed another color
var Color m_SeparatorTextColor;
// BackGround texture Region under item when selected
var Region m_BGSelRegion;
//Don't send the click event if we select the same item that is currently selected
var bool m_IgnoreAllreadySelected;
var float m_fFontSpacing;
// font for the separator
var Font m_FontSeparator;
var Font m_Font;
// ^ NEW IN 1.60
var ERenderStyle m_BGRenderStyle;
// BackGround texture under item when selected
var Texture m_BGSelTexture;
// texture for the health icon
var Texture m_HealthIconTexture;
var bool bScrollable;

// --- Functions ---
function SetScrollable(bool newScrollable) {}
function Paint(Canvas C, float fMouseX, float fMouseY) {}
function DrawItem(Canvas C, float H, float Y, float W, float X, UWindowList Item) {}
function BeforePaint(Canvas C, float fMouseX, float fMouseY) {}
function float DrawHealthIcon(Canvas C, float _fX, float _fY, float _fH, int _iHealthStatus) {}
// ^ NEW IN 1.60
function Region GetHealthIconRegion(int _iOperativeHealth) {}
// ^ NEW IN 1.60
function float GetYIconPos(float _fYItemPos, float _fItemHeight, float _fIconHeight) {}
// ^ NEW IN 1.60
function SetSelectedItem(UWindowListBoxItem NewSelected) {}
function Created() {}

defaultproperties
{
}
