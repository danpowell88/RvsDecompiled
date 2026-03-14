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
	if(__NFUN_180__(NewScrollAmount, float(0)))
	{
		NewScrollAmount = 1.0000000;
	}
	ScrollAmount = NewScrollAmount;
	MaxPos = __NFUN_175__(NewMaxPos, NewMaxVisible);
	MaxVisible = NewMaxVisible;
	MinPos = NewMinPos;
	CheckRange();
	return;
}

function CheckRange()
{
	// End:0x1D
	if(__NFUN_176__(pos, MinPos))
	{
		pos = MinPos;		
	}
	else
	{
		// End:0x37
		if(__NFUN_177__(pos, MaxPos))
		{
			pos = MaxPos;
		}
	}
	bDisabled = __NFUN_178__(MaxPos, MinPos);
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
		ThumbStart = __NFUN_172__(__NFUN_171__(__NFUN_175__(pos, MinPos), __NFUN_175__(WinHeight, __NFUN_174__(__NFUN_171__(float(2), LookAndFeel.Size_ScrollbarButtonHeight), float(2)))), __NFUN_175__(__NFUN_174__(MaxPos, MaxVisible), MinPos));
		ThumbHeight = __NFUN_172__(__NFUN_171__(MaxVisible, __NFUN_175__(WinHeight, __NFUN_174__(__NFUN_171__(float(2), LookAndFeel.Size_ScrollbarButtonHeight), float(2)))), __NFUN_175__(__NFUN_174__(MaxPos, MaxVisible), MinPos));
		// End:0x15C
		if(__NFUN_176__(ThumbHeight, LookAndFeel.Size_MinScrollbarHeight))
		{
			ThumbHeight = LookAndFeel.Size_MinScrollbarHeight;
		}
		// End:0x1B1
		if(__NFUN_177__(__NFUN_174__(ThumbHeight, ThumbStart), __NFUN_175__(__NFUN_175__(WinHeight, LookAndFeel.Size_ScrollbarButtonHeight), float(1))))
		{
			ThumbStart = __NFUN_175__(__NFUN_175__(__NFUN_175__(WinHeight, LookAndFeel.Size_ScrollbarButtonHeight), float(1)), ThumbHeight);			
		}
		else
		{
			ThumbStart = __NFUN_174__(__NFUN_174__(ThumbStart, LookAndFeel.Size_ScrollbarButtonHeight), float(1));
		}
	}
	return;
}

