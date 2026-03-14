//=============================================================================
// UWindowBitmap - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowBitmap extends UWindowDialogControl;

var int m_iDrawStyle;
var bool bStretch;
var bool bCenter;
var bool m_bHorizontalFlip;  // This is ton invert a texture horizontaly on verticaly
// NEW IN 1.60
var bool m_bVerticalFlip;
var float m_ImageX;
// NEW IN 1.60
var float m_ImageY;
var Texture t;
var Region R;

function Paint(Canvas C, float X, float Y)
{
	local int XAdjust, YAdjust, RegW, RegH;

	// End:0x0D
	if(__NFUN_114__(t, none))
	{
		return;
	}
	C.Style = byte(m_iDrawStyle);
	RegW = R.W;
	RegH = R.H;
	// End:0x6E
	if(m_bHorizontalFlip)
	{
		XAdjust = R.W;
		RegW = __NFUN_143__(R.W);
	}
	// End:0x99
	if(m_bVerticalFlip)
	{
		YAdjust = R.H;
		RegH = __NFUN_143__(R.H);
	}
	// End:0xFD
	if(bStretch)
	{
		DrawStretchedTextureSegment(C, m_ImageX, m_ImageY, WinWidth, WinHeight, float(__NFUN_146__(R.X, XAdjust)), float(__NFUN_146__(R.Y, YAdjust)), float(RegW), float(RegH), t);		
	}
	else
	{
		// End:0x197
		if(bCenter)
		{
			DrawStretchedTextureSegment(C, __NFUN_172__(__NFUN_175__(WinWidth, float(R.W)), float(2)), __NFUN_172__(__NFUN_175__(WinHeight, float(R.H)), float(2)), float(R.W), float(R.H), float(__NFUN_146__(R.X, XAdjust)), float(__NFUN_146__(R.Y, YAdjust)), float(RegW), float(RegH), t);			
		}
		else
		{
			DrawStretchedTextureSegment(C, m_ImageX, m_ImageY, float(R.W), float(R.H), float(__NFUN_146__(R.X, XAdjust)), float(__NFUN_146__(R.Y, YAdjust)), float(RegW), float(RegH), t);
		}
	}
	return;
}

defaultproperties
{
	m_iDrawStyle=1
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var p
// REMOVED IN 1.60: var Y
