//=============================================================================
//  R6MenuQuit.uc : Quit confirmation widget shown when the player tries to exit the game; offers Return to Main Menu or Quit to Desktop options.
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/08/12 * Created by Alexandre Dionne
//=============================================================================
class R6MenuQuit extends R6MenuWidget;

// --- Variables ---
// var ? m_BUbiShopFR; // REMOVED IN 1.60
// var ? m_BUbiShopGR; // REMOVED IN 1.60
// var ? m_BUbiShopUK; // REMOVED IN 1.60
// var ? m_BUbiShopUS; // REMOVED IN 1.60
// var ? m_IButHeight; // REMOVED IN 1.60
// var ? m_IXButOffset; // REMOVED IN 1.60
// var ? m_IYButPos; // REMOVED IN 1.60
// var ? m_RFRFlag; // REMOVED IN 1.60
// var ? m_RGRFlag; // REMOVED IN 1.60
// var ? m_RUKFlag; // REMOVED IN 1.60
// var ? m_RUSFlag; // REMOVED IN 1.60
// var ? m_UbiShop; // REMOVED IN 1.60
// var ? szUbiShopFRAddress; // REMOVED IN 1.60
// var ? szUbiShopGRAddress; // REMOVED IN 1.60
// var ? szUbiShopUKAddress; // REMOVED IN 1.60
// var ? szUbiShopUSAddress; // REMOVED IN 1.60
var R6WindowButton m_ButtonMainMenu;
var R6WindowButton m_ButtonQuit;
var R6MenuVideo m_QuitVideo;

// --- Functions ---
function Created() {}
function Notify(byte E, UWindowDialogControl C) {}
function ShowWindow() {}
function HideWindow() {}

defaultproperties
{
}
