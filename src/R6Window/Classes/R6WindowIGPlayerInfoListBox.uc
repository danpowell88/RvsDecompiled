//=============================================================================
//  R6WindowIGPlayerInfoListBox : Class used to manage the "list box" of players
//      in the in game menus.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/27 * Created by John Bennett
//=============================================================================
class R6WindowIGPlayerInfoListBox extends R6WindowListBox;

// --- Variables ---
// var ? m_fYOffset; // REMOVED IN 1.60
// BackGround texture Region under item when selected
var Region m_BGSelRegion;
// BackGround color when selected
var Color m_BGSelColor;
//var color   TextColor;          // color for text            N.B. var already define in class UWindowDialogControl
// color for selected text
var Color m_SelTextColor;
// if the player is a spectator
var Color m_SpectatorColor;
var Font m_Font;
// BackGround texture under item when selected
var Texture m_BGSelTexture;
var ERenderStyle m_BGRenderStyle;
var int m_fYOffSet;
// ^ NEW IN 1.60

// --- Functions ---
function DrawItem(Canvas C, float H, UWindowList Item, float Y, float W, float X) {}
function BeforePaint(Canvas C, float fMouseX, float fMouseY) {}
function DrawIcon(float _fWidth, float _fHeight, float _fY, float _fX, int _iPlayerStats, Canvas C) {}
function Created() {}

defaultproperties
{
}
