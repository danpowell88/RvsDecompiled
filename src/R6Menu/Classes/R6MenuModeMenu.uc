//=============================================================================
// R6MenuModeMenu - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuModeMenu : ActionPoint Popup menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/30 * Created by Chaouky Garram
//=============================================================================
class R6MenuModeMenu extends R6MenuFramePopup;

function Created()
{
	super(R6WindowFramedWindow).Created();
	m_szWindowTitle = Localize("Order", "Mode", "R6Menu");
	m_ButtonList = R6MenuListModeButton(CreateWindow(Class'R6Menu.R6MenuListModeButton', float(m_iFrameWidth), m_fTitleBarHeight, 100.0000000, 100.0000000, self));
	return;
}

function HideWindow()
{
	super(UWindowWindow).HideWindow();
	R6MenuListModeButton(m_ButtonList).HidePopup();
	return;
}

defaultproperties
{
	m_iNbButton=3
}
