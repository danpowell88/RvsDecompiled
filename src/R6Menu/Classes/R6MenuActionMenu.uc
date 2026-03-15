//=============================================================================
// R6MenuActionMenu - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuActionMenu : ActionPoint Popup menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/20 * Created by Chaouky Garram
//=============================================================================
class R6MenuActionMenu extends R6MenuFramePopup;

function Created()
{
	super(R6WindowFramedWindow).Created();
	m_szWindowTitle = Localize("Order", "Action", "R6Menu");
	m_ButtonList = R6MenuListActionButton(CreateWindow(Class'R6Menu.R6MenuListActionButton', 1.0000000, m_fTitleBarHeight, 100.0000000, 100.0000000, self));
	return;
}

function AjustPosition(bool bDisplayUp, bool bDisplayLeft)
{
	m_bDisplayUp = bDisplayUp;
	m_bDisplayLeft = bDisplayLeft;
	// End:0x38
	if((m_bDisplayLeft == true))
	{
		(WinLeft -= (WinWidth + float(6)));
	}
	return;
}

defaultproperties
{
	m_iNbButton=7
}
