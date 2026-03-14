//=============================================================================
// UWindowLabelControl - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowLabelControl extends UWindowDialogControl;

function Created()
{
	TextX = 0.0000000;
	TextY = 0.0000000;
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;

	super.BeforePaint(C, X, Y);
	TextSize(C, Text, W, H);
	WinHeight = __NFUN_174__(H, float(1));
	TextY = __NFUN_172__(__NFUN_175__(WinHeight, H), float(2));
	switch(Align)
	{
		// End:0x67
		case 0:
			// End:0xA4
			break;
		// End:0x87
		case 2:
			TextX = __NFUN_172__(__NFUN_175__(WinWidth, W), float(2));
			// End:0xA4
			break;
		// End:0xA1
		case 1:
			TextX = __NFUN_175__(WinWidth, W);
			// End:0xA4
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	// End:0x8B
	if(__NFUN_123__(Text, ""))
	{
		C.__NFUN_2626__(TextColor.R, TextColor.G, TextColor.B);
		C.Font = Root.Fonts[Font];
		ClipText(C, TextX, TextY, Text);
		C.__NFUN_2626__(byte(255), byte(255), byte(255));
	}
	return;
}

