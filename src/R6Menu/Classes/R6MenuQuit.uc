//=============================================================================
// R6MenuQuit - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuQuit.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/08/12 * Created by Alexandre Dionne
//=============================================================================
class R6MenuQuit extends R6MenuWidget;

var R6WindowButton m_ButtonMainMenu;
var R6WindowButton m_ButtonQuit;
var R6MenuVideo m_QuitVideo;

function Created()
{
	local Font ButtonFont;

	ButtonFont = Root.Fonts[16];
	m_ButtonMainMenu = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', 10.0000000, 425.0000000, 250.0000000, 25.0000000, self));
	m_ButtonMainMenu.ToolTipString = Localize("Tip", "ButtonMainMenu", "R6Menu");
	m_ButtonMainMenu.Text = Localize("SinglePlayer", "ButtonMainMenu", "R6Menu");
	m_ButtonMainMenu.Align = 0;
	m_ButtonMainMenu.m_buttonFont = ButtonFont;
	m_ButtonMainMenu.ResizeToText();
	// End:0x12C
	if((Root.Console.m_bStartedByGSClient || Root.Console.m_bNonUbiMatchMakingHost))
	{
		m_ButtonMainMenu.bDisabled = true;
	}
	m_ButtonQuit = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', 10.0000000, 450.0000000, 250.0000000, 25.0000000, self));
	m_ButtonQuit.ToolTipString = Localize("MainMenu", "ButtonQuit", "R6Menu");
	m_ButtonQuit.Text = Localize("MainMenu", "ButtonQuit", "R6Menu");
	m_ButtonQuit.Align = 0;
	m_ButtonQuit.m_buttonFont = ButtonFont;
	m_ButtonQuit.ResizeToText();
	return;
}

function HideWindow()
{
	super(UWindowWindow).HideWindow();
	return;
}

function ShowWindow()
{
	super(UWindowWindow).ShowWindow();
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	// End:0x4E
	if((int(E) == 2))
	{
		switch(C)
		{
			// End:0x31
			case m_ButtonMainMenu:
				Root.ChangeCurrentWidget(7);
				// End:0x4E
				break;
			// End:0x4B
			case m_ButtonQuit:
				Root.DoQuitGame();
				// End:0x4E
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		return;
	}
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_UbiShop
// REMOVED IN 1.60: var m_BUbiShopUS
// REMOVED IN 1.60: var m_BUbiShopFR
// REMOVED IN 1.60: var m_BUbiShopUK
// REMOVED IN 1.60: var m_BUbiShopGR
// REMOVED IN 1.60: var szUbiShopUSAddress
// REMOVED IN 1.60: var szUbiShopFRAddress
// REMOVED IN 1.60: var szUbiShopUKAddress
// REMOVED IN 1.60: var szUbiShopGRAddress
// REMOVED IN 1.60: var m_RUSFlag
// REMOVED IN 1.60: var m_RFRFlag
// REMOVED IN 1.60: var m_RUKFlag
// REMOVED IN 1.60: var m_RGRFlag
// REMOVED IN 1.60: var m_IButWidth
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: var m_IYButPos
// REMOVED IN 1.60: var m_IXFirstButPos
