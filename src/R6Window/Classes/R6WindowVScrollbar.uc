//=============================================================================
// R6WindowVScrollbar - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowVScrollBar.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowVScrollbar extends UWindowVScrollbar;

var Class<UWindowSBUpButton> m_UpButtonClass;
var Class<UWindowSBDownButton> m_DownButtonClass;

function SetRange(float NewMinPos, float NewMaxPos, float NewMaxVisible, optional float NewScrollAmount)
{
	// End:0x18
	if((NewScrollAmount == float(0)))
	{
		NewScrollAmount = 1.0000000;
	}
	ScrollAmount = NewScrollAmount;
	MaxPos = (NewMaxPos - NewMaxVisible);
	MaxVisible = NewMaxVisible;
	MinPos = NewMinPos;
	CheckRange();
	return;
}

function CheckRange()
{
	// End:0x1D
	if((pos < MinPos))
	{
		pos = MinPos;		
	}
	else
	{
		// End:0x37
		if((pos > MaxPos))
		{
			pos = MaxPos;
		}
	}
	bDisabled = (MaxPos <= MinPos);
	DownButton.bDisabled = bDisabled;
	UpButton.bDisabled = bDisabled;
	// End:0xA3
	if(bDisabled)
	{
		pos = 0.0000000;
		ThumbStart = 0.0000000;
		ThumbHeight = 0.0000000;		
	}
	else
	{
		ThumbStart = (((pos - MinPos) * (WinHeight - ((float(2) * LookAndFeel.Size_ScrollbarButtonHeight) + float(2)))) / ((MaxPos + MaxVisible) - MinPos));
		ThumbHeight = ((MaxVisible * (WinHeight - ((float(2) * LookAndFeel.Size_ScrollbarButtonHeight) + float(2)))) / ((MaxPos + MaxVisible) - MinPos));
		// End:0x15C
		if((ThumbHeight < LookAndFeel.Size_MinScrollbarHeight))
		{
			ThumbHeight = LookAndFeel.Size_MinScrollbarHeight;
		}
		// End:0x1B1
		if(((ThumbHeight + ThumbStart) > ((WinHeight - LookAndFeel.Size_ScrollbarButtonHeight) - float(1))))
		{
			ThumbStart = (((WinHeight - LookAndFeel.Size_ScrollbarButtonHeight) - float(1)) - ThumbHeight);			
		}
		else
		{
			ThumbStart = ((ThumbStart + LookAndFeel.Size_ScrollbarButtonHeight) + float(1));
		}
	}
	return;
}

