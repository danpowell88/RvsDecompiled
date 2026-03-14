//=============================================================================
//  R6InteractionRoseDesVents.uc : Basic interaction for the rose des vents
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/21 * Created by S�bastien Lussier
//=============================================================================
class R6InteractionRoseDesVents extends Interaction
    abstract;

#exec OBJ LOAD FILE=..\Textures\R6HUD.utx PACKAGE=R6HUD
#exec OBJ LOAD FILE=..\Textures\R6HudFonts.utx PACKAGE=R6HudFonts

// --- Constants ---
const C_RoseDesVentSize =  150;

// --- Variables ---
// var ? m_Color; // REMOVED IN 1.60
var R6PlayerController m_Player;
var int m_iCurrentMnuChoice;
var int m_iCurrentSubMnuChoice;
var bool m_bActionKeyDown;
var bool m_bIgnoreNextActionKeyRelease;
var Texture m_TexMNUItemNormalTop;
var Texture m_TexMNUItemNormalLeft;
var Sound m_RoseSelectSnd;
var string m_ActionKey;
var float m_iTextureWidth;
var float m_iTextureHeight;
var Texture m_TexMNUItemSelectedLeft;
var Texture m_TexMNUItemSelectedTop;
var Texture m_TexMNUItemSelectedSubLeft;
var Texture m_TexMNUItemSelectedSubTop;
var Texture m_TexMNUItemNormalSubLeft;
var Texture m_TexMNUItemNormalSubTop;
var bool bShowLog;
var const int C_iMouseDelta;
var Texture m_TexMNU;
var Font m_Font;
var Color m_color;                // Display color of this compass rose widget
// ^ NEW IN 1.60
var Sound m_RoseOpenSnd;

// --- Functions ---
//===========================================================================//
// Initialized()                                                             //
//===========================================================================//
event Initialized() {}
function ItemClicked(int iItem) {}
function ActionKeyPressed() {}
function bool IsValidMenuChoice(int iChoice) {}
// ^ NEW IN 1.60
//===========================================================================//
// KeyEvent()                                                                //
//===========================================================================//
function bool KeyEvent(EInputAction eAction, EInputKey eKey, float fDelta) {}
// ^ NEW IN 1.60
function SetMenuChoice(int iChoice) {}
function bool ItemHasSubMenu(int iItem) {}
// ^ NEW IN 1.60
//===========================================================================//
// CurrentItemHasSubMenu()                                                   //
//===========================================================================//
function bool CurrentItemHasSubMenu() {}
// ^ NEW IN 1.60
//===========================================================================//
// MenuItemEnabled()                                                         //
//===========================================================================//
function bool MenuItemEnabled(int iItem) {}
// ^ NEW IN 1.60
//===========================================================================//
// Override these
function GotoSubMenu() {}
function NoItemSelected() {}
function ItemRightClicked(int iItem) {}
function ActionKeyReleased() {}
//===========================================================================//
// DisplayMenu()                                                             //
//===========================================================================//
function DisplayMenu(bool bDisplay, optional bool bOpen) {}
//===========================================================================//
// DrawTextCenteredInBox()                                                   //
//===========================================================================//
function DrawTextCenteredInBox(Canvas C, string strText, float fHeight, float fPosX, float fPosY, float fWidth) {}
//===========================================================================//
// DrawRoseDesVents                                                          //
//===========================================================================//
function DrawRoseDesVents(Canvas C, int iMnuChoice) {}
//===========================================================================//
// GetCurrentMenuChoice()                                                    //
//===========================================================================//
function int GetCurrentMenuChoice() {}
// ^ NEW IN 1.60
//===========================================================================//
// GetCurrentSubMenuChoice()                                                 //
//===========================================================================//
function int GetCurrentSubMenuChoice() {}
// ^ NEW IN 1.60

state MenuDisplayed
{
//===========================================================================//
// KeyEvent()                                                                //
//===========================================================================//
    function bool KeyEvent(EInputAction eAction, EInputKey eKey, float fDelta) {}
// ^ NEW IN 1.60
}

defaultproperties
{
}
