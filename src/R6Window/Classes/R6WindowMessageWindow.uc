//=============================================================================
// R6WindowMessageWindow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowMessageWindow.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowMessageWindow extends R6WindowFramedWindow;

var UWindowBase.TextAlign m_MessageAlign;
var UWindowBase.TextAlign m_MessageAlignY;
var float m_fMessageX;
// NEW IN 1.60
var float m_fMessageY;
var float m_fMessageTab;
var Color m_MessageColor;
var string m_szMessage;

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;

	super.BeforePaint(C, X, Y);
	// End:0x16B
	if(__NFUN_123__(m_szMessage, ""))
	{
		C.Font = Root.Fonts[0];
		TextSize(C, m_szMessage, W, H);
		// End:0xCB
		if(__NFUN_154__(int(m_MessageAlignY), int(2)))
		{
			m_fMessageY = __NFUN_174__(float(LookAndFeel.FrameT.H), __NFUN_172__(__NFUN_175__(__NFUN_175__(__NFUN_175__(WinHeight, float(LookAndFeel.FrameT.H)), float(LookAndFeel.FrameB.H)), H), float(2)));			
		}
		else
		{
			m_fMessageY = float(LookAndFeel.FrameT.H);
		}
		switch(m_MessageAlign)
		{
			// End:0x117
			case 0:
				m_fMessageX = __NFUN_174__(float(LookAndFeel.FrameL.W), m_fMessageTab);
				// End:0x16B
				break;
			// End:0x148
			case 1:
				m_fMessageX = __NFUN_175__(__NFUN_175__(WinWidth, W), float(LookAndFeel.FrameL.W));
				// End:0x16B
				break;
			// End:0x168
			case 2:
				m_fMessageX = __NFUN_172__(__NFUN_175__(WinWidth, W), float(2));
				// End:0x16B
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

function Paint(Canvas C, float X, float Y)
{
	super.Paint(C, X, Y);
	// End:0x7E
	if(__NFUN_123__(m_szMessage, ""))
	{
		C.__NFUN_2626__(m_MessageColor.R, m_MessageColor.G, m_MessageColor.B);
		ClipText(C, m_fMessageX, m_fMessageY, m_szMessage, true);
		C.__NFUN_2626__(byte(255), byte(255), byte(255));
	}
	return;
}

defaultproperties
{
	m_MessageColor=(R=255,G=255,B=255,A=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var Y
