//=============================================================================
// R6WindowHSplitter - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowHSplitter.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

//=============================================================================
// R6WindowHSplitter - a horizontal splitter component
//=============================================================================
class R6WindowHSplitter extends UWindowLabelControl;

enum ESplitterType
{
	ST_TopWin,                      // 0
	ST_SplitterTop,                 // 1
	ST_SplitterBottom               // 2
};

var R6WindowHSplitter.ESplitterType m_eSplitterType;

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;

	C.Font = Root.Fonts[Font];
	TextSize(C, Text, W, H);
	TextY = ((WinHeight - H) / float(2));
	switch(Align)
	{
		// End:0x65
		case 0:
			// End:0xA2
			break;
		// End:0x85
		case 2:
			TextX = ((WinWidth - W) / float(2));
			// End:0xA2
			break;
		// End:0x9F
		case 1:
			TextX = (WinWidth - W);
			// End:0xA2
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	switch(m_eSplitterType)
	{
		// End:0x29
		case 0:
			R6WindowLookAndFeel(LookAndFeel).DrawWinTop(self, C);
			// End:0x6D
			break;
		// End:0x4B
		case 1:
			R6WindowLookAndFeel(LookAndFeel).DrawHSplitterT(self, C);
			// End:0x6D
			break;
		// End:0x6A
		case 2:
			R6WindowLookAndFeel(LookAndFeel).DrawHSplitterB(self, C);
		// End:0xFFFF
		default:
			break;
	}
	super.Paint(C, X, Y);
	return;
}

