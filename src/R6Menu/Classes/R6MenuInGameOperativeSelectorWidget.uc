//=============================================================================
//  R6MenuInGameWritableMapWidget.uc : Game Main Menu
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//	Main Menu
//
//  Revision history:
//    2002/04/05 * Created by Hugo Allaire
//=============================================================================
class R6MenuInGameOperativeSelectorWidget extends R6MenuWidget;

// --- Variables ---
var const int c_ColumnWidth;
var array<array> aItems;
var const int c_InsideMarginY;
var const int c_InsideMarginX;
var const int c_RowHeight;
var const int c_OutsideMarginX;
var const int c_OutsideMarginY;
var R6GameOptions m_pGameOptions;
var bool m_bIsSinglePlayer;
var bool m_bInitalized;
var Sound m_OperativeOpenSnd;

// --- Functions ---
function Paint(Canvas C, float X, float Y) {}
function UpdateOperativeItems() {}
function HideWindow() {}
function ShowWindow() {}

defaultproperties
{
}
