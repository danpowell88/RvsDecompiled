//=============================================================================
//  R6GameColors.uc : Define for all game colors, this will assure unifications of colors
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/13 * Created by Alexandre Dionne
//=============================================================================
class R6GameColors extends Object
    native;

// --- Variables ---
var config Color Black;
// ^ NEW IN 1.60
var config Color BlueLight;
// ^ NEW IN 1.60
var config Color Blue;
// ^ NEW IN 1.60
var config Color BlueDark;
// ^ NEW IN 1.60
var config Color Gold;
// ^ NEW IN 1.60
var config Color GrayDark;
// ^ NEW IN 1.60
var config Color GrayLight;
// ^ NEW IN 1.60
var config Color GreenLight;
// ^ NEW IN 1.60
var config Color Green;
// ^ NEW IN 1.60
var config Color GreenDark;
// ^ NEW IN 1.60
var config Color Orange;
// ^ NEW IN 1.60
var config Color RedLight;
// ^ NEW IN 1.60
var config Color Red;
// ^ NEW IN 1.60
var config Color RedDark;
// ^ NEW IN 1.60
var config Color White;
// ^ NEW IN 1.60
var config Color Yellow;
// ^ NEW IN 1.60
// colors for the player's HUD
var config Color TeamHUDColor[3];
// White with transparency
var config Color HUDWhite;
// Grey with transparency
var config Color HUDGrey;
// colors to be used for the menus
//RED, GREEN, GOLD
var config Color TeamColor[3];
var config Color TeamColorLight[3];
var config Color TeamColorDark[3];
//Normal, Disabled, Over, Selected
var config Color ButtonTextColor[4];
//the tooltip color for the menu
var config Color ToolTipColor;
//50% transparent for all pop ups in planning
var config int PopUpAlphaFactor;
var config Color m_cBGPopUpContour;
// ^ NEW IN 1.60
//Pop up back ground color
var config Color m_cBGPopUpWindow;
//Combo box fill up background color
var config Color m_ComboBGColor;
var config int EditBoxSelectAllAlpha;
var config int DarkBGAlpha;
var config Color m_LisBoxNormalTextColor;
// ^ NEW IN 1.60
var config Color m_LisBoxSelectedTextColor;
// ^ NEW IN 1.60
var config Color m_LisBoxSeparatorTextColor;
// ^ NEW IN 1.60
var config Color m_LisBoxSelectionColor;
// ^ NEW IN 1.60
var config Color m_LisBoxDisabledTextColor;
// ^ NEW IN 1.60
//*********************************
//List Box
//*********************************
var config Color m_LisBoxSpectatorTextColor;

defaultproperties
{
}
