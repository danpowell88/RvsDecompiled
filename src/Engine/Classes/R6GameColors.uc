//=============================================================================
// R6GameColors - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6GameColors.uc : Define for all game colors, this will assure unifications of colors
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/13 * Created by Alexandre Dionne
//=============================================================================
class R6GameColors extends Object
	native
 config;

var config int PopUpAlphaFactor;  // 50% transparent for all pop ups in planning
var config int EditBoxSelectAllAlpha;
var config int DarkBGAlpha;
var config Color Black;
// NEW IN 1.60
var config Color BlueLight;
// NEW IN 1.60
var config Color Blue;
// NEW IN 1.60
var config Color BlueDark;
// NEW IN 1.60
var config Color Gold;
// NEW IN 1.60
var config Color GrayDark;
// NEW IN 1.60
var config Color GrayLight;
// NEW IN 1.60
var config Color GreenLight;
// NEW IN 1.60
var config Color Green;
// NEW IN 1.60
var config Color GreenDark;
// NEW IN 1.60
var config Color Orange;
// NEW IN 1.60
var config Color RedLight;
// NEW IN 1.60
var config Color Red;
// NEW IN 1.60
var config Color RedDark;
// NEW IN 1.60
var config Color White;
// NEW IN 1.60
var config Color Yellow;
// colors for the player's HUD
var config Color TeamHUDColor[3];
var config Color HUDWhite;  // White with transparency
var config Color HUDGrey;  // Grey with transparency
// colors to be used for the menus
var config Color TeamColor[3];  // RED, GREEN, GOLD
var config Color TeamColorLight[3];
var config Color TeamColorDark[3];
var config Color ButtonTextColor[4];  // Normal, Disabled, Over, Selected
var config Color ToolTipColor;  // the tooltip color for the menu
var config Color m_cBGPopUpContour;  // Pop up back ground color
// NEW IN 1.60
var config Color m_cBGPopUpWindow;
var config Color m_ComboBGColor;  // Combo box fill up background color
//*********************************
//List Box
//*********************************
var config Color m_LisBoxNormalTextColor;
// NEW IN 1.60
var config Color m_LisBoxSelectedTextColor;
// NEW IN 1.60
var config Color m_LisBoxSeparatorTextColor;
// NEW IN 1.60
var config Color m_LisBoxSelectionColor;
// NEW IN 1.60
var config Color m_LisBoxDisabledTextColor;
// NEW IN 1.60
var config Color m_LisBoxSpectatorTextColor;

defaultproperties
{
	PopUpAlphaFactor=128
	EditBoxSelectAllAlpha=132
	DarkBGAlpha=77
	BlueLight=(R=129,G=209,B=239,A=0)
	Blue=(R=90,G=125,B=195,A=0)
	BlueDark=(R=25,G=30,B=50,A=0)
	Gold=(R=155,G=140,B=95,A=0)
	GrayDark=(R=50,G=50,B=50,A=0)
	GrayLight=(R=120,G=120,B=120,A=0)
	GreenLight=(R=119,G=168,B=112,A=0)
	Green=(R=60,G=182,B=0,A=0)
	GreenDark=(R=4,G=43,B=0,A=0)
	Orange=(R=255,G=192,B=0,A=0)
	RedLight=(R=255,G=150,B=142,A=0)
	Red=(R=182,G=0,B=0,A=0)
	RedDark=(R=47,G=6,B=8,A=0)
	White=(R=255,G=255,B=255,A=0)
	Yellow=(R=255,G=255,B=0,A=0)
	TeamHUDColor[0]=(R=196,G=31,B=9,A=75)
	TeamHUDColor[1]=(R=60,G=200,B=60,A=50)
	TeamHUDColor[2]=(R=216,G=165,B=8,A=50)
	HUDWhite=(R=255,G=255,B=255,A=255)
	HUDGrey=(R=255,G=255,B=255,A=100)
	TeamColor[0]=(R=182,G=0,B=0,A=255)
	TeamColor[1]=(R=60,G=182,B=0,A=255)
	TeamColor[2]=(R=204,G=150,B=0,A=255)
	TeamColorLight[0]=(R=215,G=64,B=51,A=255)
	TeamColorLight[1]=(R=94,G=215,B=51,A=255)
	TeamColorLight[2]=(R=215,G=184,B=51,A=255)
	TeamColorDark[0]=(R=51,G=0,B=0,A=255)
	TeamColorDark[1]=(R=17,G=51,B=0,A=255)
	TeamColorDark[2]=(R=82,G=60,B=0,A=255)
	ButtonTextColor[0]=(R=255,G=255,B=255,A=0)
	ButtonTextColor[1]=(R=120,G=120,B=120,A=0)
	ButtonTextColor[2]=(R=129,G=209,B=239,A=0)
	ButtonTextColor[3]=(R=129,G=209,B=239,A=0)
	ToolTipColor=(R=190,G=190,B=190,A=0)
	m_cBGPopUpContour=(R=0,G=0,B=0,A=180)
	m_ComboBGColor=(R=25,G=30,B=50,A=0)
	m_LisBoxNormalTextColor=(R=255,G=255,B=255,A=0)
	m_LisBoxSelectedTextColor=(R=255,G=255,B=255,A=0)
	m_LisBoxSeparatorTextColor=(R=129,G=209,B=239,A=0)
	m_LisBoxSelectionColor=(R=90,G=125,B=195,A=0)
	m_LisBoxDisabledTextColor=(R=120,G=120,B=120,A=0)
	m_LisBoxSpectatorTextColor=(R=120,G=120,B=120,A=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var w
// REMOVED IN 1.60: var r
