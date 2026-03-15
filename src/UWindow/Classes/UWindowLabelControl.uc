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
	WinHeight = (H + float(1));
	TextY = ((WinHeight - H) / float(2));
	switch(Align)
	{
		// End:0x67
		case 0:
			// End:0xA4
			break;
		// End:0x87
		case 2:
			TextX = ((WinWidth - W) / float(2));
			// End:0xA4
			break;
		// End:0xA1
		case 1:
			TextX = (WinWidth - W);
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
	if((Text != ""))
	{
		C.SetDrawColor(TextColor.R, TextColor.G, TextColor.B);
		C.Font = Root.Fonts[Font];
		ClipText(C, TextX, TextY, Text);
		C.SetDrawColor(byte(255), byte(255), byte(255));
	}
	return;
}

