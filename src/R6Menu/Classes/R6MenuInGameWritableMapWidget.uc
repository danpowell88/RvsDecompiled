//=============================================================================
//  R6MenuInGameWritableMapWidget.uc : Game Main Menu
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//	Main Menu
//
//  Revision history:
//    2002/04/05 * Created by Hugo Allaire
//=============================================================================
class R6MenuInGameWritableMapWidget extends R6MenuWidget;

#exec OBJ LOAD FILE="..\textures\Color.utx" Package="Color.Color"
#exec OBJ LOAD FILE="..\textures\R6WritableMapIcons.utx" Package="R6WritableMapIcons"

// --- Variables ---
var R6WindowRadioButton m_Icons[16];
var R6WindowRadioButton m_CurrentSelectedIcon;
var bool m_bIsDrawing;
var R6ColorPicker m_cColorPicker;
var const int c_iNbOfIcons;

// --- Functions ---
function Notify(UWindowDialogControl Button, byte Msg) {}
function LMouseDown(float Y, float X) {}
function Created() {}
function LMouseUp(float X, float Y) {}
function SendLineToTeam() {}
function Paint(Canvas C, float X, float Y) {}
function RMouseDown(float X, float Y) {}
function MouseMove(float X, float Y) {}
function MouseLeave() {}
function ShowWindow() {}
function HideWindow() {}

defaultproperties
{
}
