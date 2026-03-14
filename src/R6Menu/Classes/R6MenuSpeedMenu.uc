//=============================================================================
// R6MenuSpeedMenu - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuSpeedMenu : ActionPoint Popup menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/30 * Created by Chaouky Garram
//=============================================================================
class R6MenuSpeedMenu extends R6MenuFramePopup;

function Created()
{
	super(R6WindowFramedWindow).Created();
	m_szWindowTitle = Localize("Order", "Speed", "R6Menu");
	m_ButtonList = R6MenuListSpeedButton(CreateWindow(Class'R6Menu.R6MenuListSpeedButton', float(m_iFrameWidth), m_fTitleBarHeight, 100.0000000, 100.0000000, self));
	return;
}

function AjustPosition(bool bDisplayUp, bool bDisplayLeft)
{
	m_bDisplayUp = bDisplayUp;
	m_bDisplayLeft = bDisplayLeft;
	// End:0x38
	if(__NFUN_242__(m_bDisplayLeft, true))
	{
		__NFUN_185__(WinLeft, __NFUN_174__(WinWidth, float(6)));
	}
	return;
}

defaultproperties
{
	m_iNbButton=3
}
