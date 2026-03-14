//=============================================================================
//  R6AstractHUD.uc : Abstract base class for the Rainbow Six HUD.
//  Tracks HUD resolution and provides the helmet overlay toggle; subclassed by R6HUD in R6Game.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/16 * Created by Guillaume Borgia
//=============================================================================
class R6AbstractHUD extends HUD
    native
    abstract;

#exec OBJ LOAD FILE=..\Textures\R6HudFonts.utx PACKAGE=R6HudFonts

// --- Variables ---
// HUD resolution
var float m_fNewHUDResX;
var float m_fNewHUDResY;
var int m_iCycleHUDLayer;
var bool m_bGetRes;
var bool m_bToggleHelmet;
// this string is displayed 5 sec.
var string m_szStatusDetail;

// --- Functions ---
//===========================================================================//
// GetGoCodeStr()                                                            //
//===========================================================================//
function string GetGoCodeStr(EGoCode goCode) {}
// ^ NEW IN 1.60
//===========================================================================//
// DrawTexturePart()                                                         //
//===========================================================================//
function DrawTexturePart(float fSizeX, float fSizeY, Canvas C, Texture Tex, float fUStart, float fVStart) {}
//===========================================================================//
// HUDRes()                                                                  //
//  Change HUD resolution to make it appear bigger or smaller on screen.     //
//===========================================================================//
exec function HUDRes(string strRes) {}
function PostRender(Canvas C) {}
//===========================================================================//
// DrawTextCenteredInBox()                                                   //
//===========================================================================//
function DrawTextCenteredInBox(Canvas C, string strText, float fHeight, float fWidth, float fPosY, float fPosX) {}
//===========================================================================//
// GetRes()                                                                  //
//  Display current resolution.                                              //
//===========================================================================//
exec function GetRes() {}
exec function ToggleHelmet() {}
exec function CycleHUDLayer() {}
function StartFadeToBlack(int iSec, int iPercentageOfBlack) {}
function StopFadeToBlack() {}
function UpdateHudFilter() {}
function ActivateNoDeathCameraMsg(bool bToggleOn) {}

defaultproperties
{
}
