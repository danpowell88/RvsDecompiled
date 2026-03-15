//=============================================================================
// UWindowVScrollbar - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// UWindowVScrollBar - A vertical scrollbar
//=============================================================================
class UWindowVScrollbar extends UWindowWindow;

var bool bDragging;
var bool bDisabled;
var bool m_bHideSBWhenDisable;
var bool m_bUseSpecialEffect;  // For look and feel effecs
var float MinPos;
var float MaxPos;
var float MaxVisible;
var float pos;  // offset to WinTop
var float ThumbStart;
// NEW IN 1.60
var float ThumbHeight;
var float NextClickTime;
var float DragY;
var float ScrollAmount;
var UWindowSBUpButton UpButton;
var UWindowSBDownButton DownButton;

function Show(float P)
{
	// End:0x0F
	if((P < float(0)))
	{
		return;
	}
	// End:0x27
	if((P > (MaxPos + MaxVisible)))
	{
		return;
	}
	J0x27:

	// End:0x4C [Loop If]
	if((P < pos))
	{
		// End:0x49
		if((!Scroll(-1.0000000)))
		{
			// [Explicit Break]
			goto J0x4C;
		}
		// [Loop Continue]
		goto J0x27;
	}
	J0x4C:

	// End:0x7D [Loop If]
	if(((P - pos) > (MaxVisible - float(1))))
	{
		// End:0x7A
		if((!Scroll(1.0000000)))
		{
			// [Explicit Break]
			goto J0x7D;
		}
		// [Loop Continue]
		goto J0x4C;
	}
	J0x7D:

	return;
}

function bool Scroll(float Delta)
{
	local float OldPos;

	OldPos = pos;
	pos = (pos + Delta);
	CheckRange();
	return (pos == (OldPos + Delta));
	return;
}

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
	// End:0x98
	if(bDisabled)
	{
		pos = 0.0000000;
		ThumbStart = 0.0000000;		
	}
	else
	{
		ThumbStart = (((pos - MinPos) * (WinHeight - ((float(2) * LookAndFeel.Size_ScrollbarButtonHeight) + float(2)))) / ((MaxPos + MaxVisible) - MinPos));
		ThumbHeight = ((MaxVisible * (WinHeight - ((float(2) * LookAndFeel.Size_ScrollbarButtonHeight) + float(2)))) / ((MaxPos + MaxVisible) - MinPos));
		// End:0x151
		if((ThumbHeight < LookAndFeel.Size_MinScrollbarHeight))
		{
			ThumbHeight = LookAndFeel.Size_MinScrollbarHeight;
		}
		// End:0x1A6
		if(((ThumbHeight + ThumbStart) > ((WinHeight - LookAndFeel.Size_ScrollbarButtonHeight) - float(1))))
		{
			ThumbStart = (((WinHeight - LookAndFeel.Size_ScrollbarButtonHeight) - ThumbHeight) - float(1));			
		}
		else
		{
			ThumbStart = ((ThumbStart + LookAndFeel.Size_ScrollbarButtonHeight) + float(1));
		}
	}
	return;
}

function Created()
{
	UpButton = UWindowSBUpButton(CreateWindow(Class'UWindow.UWindowSBUpButton', 0.0000000, 0.0000000, LookAndFeel.Size_ScrollbarWidth, LookAndFeel.Size_ScrollbarButtonHeight));
	DownButton = UWindowSBDownButton(CreateWindow(Class'UWindow.UWindowSBDownButton', 0.0000000, (WinHeight - LookAndFeel.Size_ScrollbarButtonHeight), LookAndFeel.Size_ScrollbarWidth, LookAndFeel.Size_ScrollbarButtonHeight));
	return;
}

function SetEffect(bool _effect)
{
	m_bUseSpecialEffect = _effect;
	LookAndFeel.SB_SetupUpButton(UpButton);
	LookAndFeel.SB_SetupDownButton(DownButton);
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	UpButton.WinTop = 0.0000000;
	UpButton.WinLeft = 0.0000000;
	UpButton.WinWidth = LookAndFeel.Size_ScrollbarWidth;
	UpButton.WinHeight = LookAndFeel.Size_ScrollbarButtonHeight;
	DownButton.WinTop = (WinHeight - LookAndFeel.Size_ScrollbarButtonHeight);
	DownButton.WinLeft = 0.0000000;
	DownButton.WinWidth = LookAndFeel.Size_ScrollbarWidth;
	DownButton.WinHeight = LookAndFeel.Size_ScrollbarButtonHeight;
	CheckRange();
	return;
}

function Paint(Canvas C, float X, float Y)
{
	// End:0x0B
	if(isHidden())
	{
		return;
	}
	LookAndFeel.SB_VDraw(self, C);
	return;
}

function bool isHidden()
{
	return (bDisabled && m_bHideSBWhenDisable);
	return;
}

function LMouseDown(float X, float Y)
{
	super.LMouseDown(X, Y);
	// End:0x1B
	if(bDisabled)
	{
		return;
	}
	// End:0x51
	if((Y < ThumbStart))
	{
		Scroll((-(MaxVisible - float(1))));
		NextClickTime = (GetTime() + 0.5000000);
		return;
	}
	// End:0x8C
	if((Y > (ThumbStart + ThumbHeight)))
	{
		Scroll((MaxVisible - float(1)));
		NextClickTime = (GetTime() + 0.5000000);
		return;
	}
	// End:0xDE
	if(((Y >= ThumbStart) && (Y <= (ThumbStart + ThumbHeight))))
	{
		DragY = (Y - ThumbStart);
		bDragging = true;
		Root.CaptureMouse();
		return;
	}
	return;
}

function MouseWheelDown(float X, float Y)
{
	Scroll(2.0000000);
	return;
}

function MouseWheelUp(float X, float Y)
{
	Scroll(-2.0000000);
	return;
}

function Tick(float Delta)
{
	local bool bUp, bDown;
	local float X, Y;

	// End:0x0B
	if(bDragging)
	{
		return;
	}
	bUp = false;
	bDown = false;
	// End:0x61
	if(bMouseDown)
	{
		GetMouseXY(X, Y);
		bUp = (Y < ThumbStart);
		bDown = (Y > (ThumbStart + ThumbHeight));
	}
	// End:0xBB
	if((((bMouseDown && (NextClickTime > float(0))) && (NextClickTime < GetTime())) && bUp))
	{
		Scroll((-(MaxVisible - float(1))));
		NextClickTime = (GetTime() + 0.1000000);
	}
	// End:0x113
	if((((bMouseDown && (NextClickTime > float(0))) && (NextClickTime < GetTime())) && bDown))
	{
		Scroll((MaxVisible - float(1)));
		NextClickTime = (GetTime() + 0.1000000);
	}
	// End:0x143
	if(((!bMouseDown) || ((!bUp) && (!bDown))))
	{
		NextClickTime = 0.0000000;
	}
	return;
}

function MouseMove(float X, float Y)
{
	// End:0x8E
	if(((bDragging && bMouseDown) && (!bDisabled)))
	{
		J0x21:

		// End:0x56 [Loop If]
		if(((Y < (ThumbStart + DragY)) && (pos > MinPos)))
		{
			Scroll(-1.0000000);
			// [Loop Continue]
			goto J0x21;
		}
		J0x56:

		// End:0x8B [Loop If]
		if(((Y > (ThumbStart + DragY)) && (pos < MaxPos)))
		{
			Scroll(1.0000000);
			// [Loop Continue]
			goto J0x56;
		}		
	}
	else
	{
		bDragging = false;
	}
	return;
}

function SetBorderColor(Color C)
{
	m_BorderColor = C;
	UpButton.m_BorderColor = C;
	DownButton.m_BorderColor = C;
	return;
}

function SetHideWhenDisable(bool _bHideWhenDisable)
{
	m_bHideSBWhenDisable = _bHideWhenDisable;
	UpButton.m_bHideSBWhenDisable = _bHideWhenDisable;
	DownButton.m_bHideSBWhenDisable = _bHideWhenDisable;
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var t
