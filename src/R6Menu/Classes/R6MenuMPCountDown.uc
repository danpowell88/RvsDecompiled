//=============================================================================
// R6MenuMPCountDown - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuMPCountDown.uc : this menu show the count down before the game start in multi 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/12/09 * Created by Yannick Joly
//=============================================================================
class R6MenuMPCountDown extends UWindowWindow;

const C_iWAIT_XFRAMES = 10;

var int m_iLastValue;
var int m_iFrameRefresh;
var R6WindowTextLabel m_pCountDownLabel;  // the countdown text window
var R6WindowTextLabel m_pCountDown;  // the countdown text window

function Created()
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;

	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	m_pCountDownLabel = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 185.0000000, 180.0000000, 270.0000000, 20.0000000, self));
	m_pCountDownLabel.SetProperties(Localize("POPUP", "PopUpTitle_CountDown", "R6Menu"), 2, Root.Fonts[15], Root.Colors.White, false);
	m_pCountDownLabel.m_bResizeToText = true;
	m_pCountDown = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 185.0000000, 200.0000000, 270.0000000, 20.0000000, self));
	m_pCountDown.SetProperties("", 2, Root.Fonts[15], Root.Colors.White, false);
	m_pCountDown.m_bResizeToText = true;
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local int iServerCountDownTime;
	local R6MenuInGameMultiPlayerRootWindow r6Root;

	// End:0x85
	if(__NFUN_151__(m_iFrameRefresh, 10))
	{
		m_iFrameRefresh = 0;
		r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
		iServerCountDownTime = __NFUN_250__(1, int(R6GameReplicationInfo(r6Root.m_R6GameMenuCom.m_GameRepInfo).GetRoundTime()));
		// End:0x85
		if(__NFUN_155__(iServerCountDownTime, m_iLastValue))
		{
			m_pCountDown.SetNewText(string(iServerCountDownTime), true);
			m_iLastValue = iServerCountDownTime;
		}
	}
	__NFUN_165__(m_iFrameRefresh);
	return;
}

defaultproperties
{
	m_iLastValue=-1
	m_iFrameRefresh=11
}
