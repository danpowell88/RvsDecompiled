//=============================================================================
// R6WindowTextListRadio - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowTextListRadio.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowTextListRadio extends R6WindowListRadio;

//var color   TextColor;           color for text            N.B. var already define in class UWindowDialogControl
var Color m_SelTextColor;  // color for selected text

function Paint(Canvas C, float fMouseX, float fMouseY)
{
	R6WindowLookAndFeel(LookAndFeel).List_DrawBackground(self, C);
	super.Paint(C, fMouseX, fMouseY);
	return;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local float fWidth, fHeight, fTextX, fTextY;
	local UWindowListBoxItem pListBoxItem;

	pListBoxItem = UWindowListBoxItem(Item);
	// End:0x4F
	if(pListBoxItem.bSelected)
	{
		C.SetDrawColor(m_SelTextColor.R, m_SelTextColor.G, m_SelTextColor.B);		
	}
	else
	{
		C.SetDrawColor(TextColor.R, TextColor.G, TextColor.B);
	}
	C.Font = Root.Fonts[0];
	// End:0x171
	if((pListBoxItem.HelpText != ""))
	{
		TextSize(C, pListBoxItem.HelpText, W, H);
		fTextY = ((m_fItemHeight - H) / float(2));
		switch(Align)
		{
			// End:0x103
			case 0:
				fTextX = 2.0000000;
				// End:0x140
				break;
			// End:0x11D
			case 1:
				fTextX = (WinWidth - W);
				// End:0x140
				break;
			// End:0x13D
			case 2:
				fTextX = ((WinWidth - W) / float(2));
				// End:0x140
				break;
			// End:0xFFFF
			default:
				break;
		}
		ClipText(C, (X + fTextX), (Y + fTextY), pListBoxItem.HelpText);
	}
	C.SetDrawColor(byte(255), byte(255), byte(255));
	return;
}

defaultproperties
{
	m_SelTextColor=(R=255,G=255,B=255,A=0)
	m_fItemHeight=16.0000000
	ListClass=Class'UWindow.UWindowListBoxItem'
	Align=2
}
