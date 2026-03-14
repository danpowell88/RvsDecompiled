//=============================================================================
// UWindowMessageBoxArea - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowMessageBoxArea extends UWindowWindow;

var string Message;

function float GetHeight(Canvas C)
{
	local float tW, tH, H;
	local int L;
	local float OldWinHeight;

	OldWinHeight = WinHeight;
	WinHeight = 1000.0000000;
	C.Font = Root.Fonts[0];
	TextSize(C, "A", tW, tH);
	L = WrapClipText(C, 0.0000000, 0.0000000, Message,,,, true);
	H = __NFUN_171__(tH, float(L));
	WinHeight = OldWinHeight;
	return H;
	return;
}

function Paint(Canvas C, float X, float Y)
{
	C.Font = Root.Fonts[0];
	C.__NFUN_2626__(0, 0, 0);
	WrapClipText(C, 0.0000000, 0.0000000, Message);
	C.__NFUN_2626__(byte(255), byte(255), byte(255));
	return;
}

