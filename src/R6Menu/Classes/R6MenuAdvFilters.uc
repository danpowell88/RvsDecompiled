//=============================================================================
// R6MenuAdvFilters - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuAdvFilters.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/07/21 * Created by Yannick Joly
//=============================================================================
class R6MenuAdvFilters extends UWindowDialogClientWindow;

var R6WindowListRestKit m_pListGen;

function Created()
{
	m_pListGen = R6WindowListRestKit(CreateWindow(Class'R6Window.R6WindowListRestKit', 0.0000000, 0.0000000, WinWidth, WinHeight, self));
	m_pListGen.m_fXItemOffset = 5.0000000;
	m_pListGen.bAlwaysBehind = true;
	return;
}

function AddButtonInList(bool _bSelected, string _szLoc, string _szTip, int _iButtonID)
{
	local R6WindowListGeneralItem NewItem;
	local float fXOffset, fYOffset, fYStep, fWidth, fHeight;

	local Font ButtonFont;
	local int i;

	fXOffset = 5.0000000;
	fYOffset = 7.0000000;
	fWidth = __NFUN_175__(WinWidth, __NFUN_171__(float(2), fXOffset));
	fHeight = 15.0000000;
	ButtonFont = Root.Fonts[5];
	NewItem = R6WindowListGeneralItem(m_pListGen.GetItemAtIndex(m_pListGen.Items.CountShown()));
	NewItem.m_pR6WindowButtonBox = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, 0.0000000, fWidth, fHeight, self));
	NewItem.m_pR6WindowButtonBox.m_TextFont = ButtonFont;
	NewItem.m_pR6WindowButtonBox.m_vTextColor = Root.Colors.White;
	NewItem.m_pR6WindowButtonBox.m_vBorder = Root.Colors.White;
	NewItem.m_pR6WindowButtonBox.m_bSelected = _bSelected;
	NewItem.m_pR6WindowButtonBox.m_szMiscText = "";
	NewItem.m_pR6WindowButtonBox.m_AdviceWindow = self;
	NewItem.m_pR6WindowButtonBox.CreateTextAndBox(_szLoc, _szTip, 0.0000000, _iButtonID);
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	// End:0x4B
	if(C.__NFUN_303__('R6WindowButtonBox'))
	{
		// End:0x4B
		if(__NFUN_154__(int(E), 2))
		{
			// End:0x4B
			if(__NFUN_119__(OwnerWindow, none))
			{
				R6MenuMPMenuTab(OwnerWindow).Notify(C, E);
			}
		}
	}
	return;
}

//=======================================================================================
// MouseWheelDown: advice scroll bar for mouse wheel down
//=======================================================================================
function MouseWheelDown(float X, float Y)
{
	// End:0x24
	if(__NFUN_119__(m_pListGen, none))
	{
		m_pListGen.MouseWheelDown(X, Y);
	}
	return;
}

//=======================================================================================
// MouseWheelUp: advice scroll bar for mouse wheel up
//=======================================================================================
function MouseWheelUp(float X, float Y)
{
	// End:0x24
	if(__NFUN_119__(m_pListGen, none))
	{
		m_pListGen.MouseWheelUp(X, Y);
	}
	return;
}

