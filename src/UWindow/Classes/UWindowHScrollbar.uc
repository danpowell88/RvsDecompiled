//=============================================================================
// UWindowHScrollbar - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// UWindowHScrollBar - A horizontal scrollbar
//=============================================================================
class UWindowHScrollbar extends UWindowDialogControl;

var int m_iScrollBarID;  // the ID of the scroll bar
var bool bDisabled;
var bool bDragging;
var bool m_bHideSBWhenDisable;
var float MinPos;
var float MaxPos;
var float MaxVisible;
var float pos;  // offset to WinTop
var float ThumbStart;
// NEW IN 1.60
var float ThumbWidth;
var float NextClickTime;
var float DragX;
var float ScrollAmount;
var UWindowSBLeftButton LeftButton;
var UWindowSBRightButton RightButton;
var Color m_SelectedColor;
var Color m_NormalColor;

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

	// End:0x71 [Loop If]
	if((P > pos))
	{
		// End:0x6E
		if((!Scroll(1.0000000)))
		{
			// [Explicit Break]
			goto J0x71;
		}
		// [Loop Continue]
		goto J0x4C;
	}
	J0x71:

	return;
}

function bool Scroll(float Delta)
{
	local float OldPos;

	OldPos = pos;
	pos = (pos + Delta);
	CheckRange();
	Notify(1);
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
	MinPos = NewMinPos;
	MaxPos = (NewMaxPos - NewMaxVisible);
	MaxVisible = NewMaxVisible;
	CheckRange();
	Notify(1);
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
	LeftButton.bDisabled = bDisabled;
	RightButton.bDisabled = bDisabled;
	// End:0x8D
	if(bDisabled)
	{
		pos = 0.0000000;		
	}
	else
	{
		ThumbStart = (((pos - MinPos) * (WinWidth - ((float(2) * LookAndFeel.Size_ScrollbarButtonHeight) + float(2)))) / ((MaxPos + MaxVisible) - MinPos));
		ThumbWidth = ((MaxVisible * (WinWidth - ((float(2) * LookAndFeel.Size_ScrollbarButtonHeight) + float(2)))) / ((MaxPos + MaxVisible) - MinPos));
		// End:0x146
		if((ThumbWidth < LookAndFeel.Size_MinScrollbarHeight))
		{
			ThumbWidth = LookAndFeel.Size_MinScrollbarHeight;
		}
		// End:0x19B
		if(((ThumbWidth + ThumbStart) > ((WinWidth - LookAndFeel.Size_ScrollbarButtonHeight) - float(1))))
		{
			ThumbStart = (((WinWidth - LookAndFeel.Size_ScrollbarButtonHeight) - float(1)) - ThumbWidth);			
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
	m_SelectedColor = Root.Colors.ButtonTextColor[2];
	m_NormalColor = Root.Colors.White;
	LeftButton = UWindowSBLeftButton(CreateWindow(Class'UWindow.UWindowSBLeftButton', 0.0000000, 0.0000000, LookAndFeel.Size_ScrollbarButtonHeight, LookAndFeel.Size_ScrollbarWidth));
	RightButton = UWindowSBRightButton(CreateWindow(Class'UWindow.UWindowSBRightButton', (WinWidth - LookAndFeel.Size_ScrollbarButtonHeight), 0.0000000, LookAndFeel.Size_ScrollbarButtonHeight, LookAndFeel.Size_ScrollbarWidth));
	return;
}

function Register(UWindowDialogClientWindow W)
{
	super.Register(W);
	LeftButton.Register(W);
	RightButton.Register(W);
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	CheckRange();
	return;
}

function Paint(Canvas C, float X, float Y)
{
	// End:0x16
	if((bDisabled && m_bHideSBWhenDisable))
	{
		return;
	}
	// End:0x5C
	if(((MouseIsOver() || LeftButton.MouseIsOver()) || RightButton.MouseIsOver()))
	{
		SetBorderColor(m_SelectedColor);
		AdviceParent(true);		
	}
	else
	{
		// End:0x80
		if(m_BorderColor != m_NormalColor)
		{
			SetBorderColor(m_NormalColor);
			AdviceParent(false);
		}
	}
	LookAndFeel.SB_HDraw(self, C);
	return;
}

function LMouseDown(float X, float Y)
{
	super(UWindowWindow).LMouseDown(X, Y);
	// End:0x1B
	if(bDisabled)
	{
		return;
	}
	// End:0x51
	if((X < ThumbStart))
	{
		Scroll((-(MaxVisible - float(1))));
		NextClickTime = (GetTime() + 0.5000000);
		return;
	}
	// End:0x8C
	if((X > (ThumbStart + ThumbWidth)))
	{
		Scroll((MaxVisible - float(1)));
		NextClickTime = (GetTime() + 0.5000000);
		return;
	}
	// End:0xDE
	if(((X >= ThumbStart) && (X <= (ThumbStart + ThumbWidth))))
	{
		DragX = (X - ThumbStart);
		bDragging = true;
		Root.CaptureMouse();
		return;
	}
	return;
}

function Tick(float Delta)
{
	local bool bLeft, bRight;
	local float X, Y;

	// End:0x0B
	if(bDragging)
	{
		return;
	}
	bLeft = false;
	bRight = false;
	// End:0x61
	if(bMouseDown)
	{
		GetMouseXY(X, Y);
		bLeft = (X < ThumbStart);
		bRight = (X > (ThumbStart + ThumbWidth));
	}
	// End:0xBB
	if((((bMouseDown && (NextClickTime > float(0))) && (NextClickTime < GetTime())) && bLeft))
	{
		Scroll((-(MaxVisible - float(1))));
		NextClickTime = (GetTime() + 0.1000000);
	}
	// End:0x113
	if((((bMouseDown && (NextClickTime > float(0))) && (NextClickTime < GetTime())) && bRight))
	{
		Scroll((MaxVisible - float(1)));
		NextClickTime = (GetTime() + 0.1000000);
	}
	// End:0x143
	if(((!bMouseDown) || ((!bLeft) && (!bRight))))
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
		if(((X < (ThumbStart + DragX)) && (pos > MinPos)))
		{
			Scroll(-1.0000000);
			// [Loop Continue]
			goto J0x21;
		}
		J0x56:

		// End:0x8B [Loop If]
		if(((X > (ThumbStart + DragX)) && (pos < MaxPos)))
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

function MouseEnter()
{
	super.MouseEnter();
	AdviceParent(true);
	return;
}

function MouseLeave()
{
	super.MouseLeave();
	AdviceParent(false);
	return;
}

function AdviceParent(bool _bMouseEnter)
{
	// End:0x1B
	if(_bMouseEnter)
	{
		OwnerWindow.MouseEnter();		
	}
	else
	{
		OwnerWindow.MouseLeave();
	}
	return;
}

function SetHideWhenDisable(bool _bHideWhenDisable)
{
	m_bHideSBWhenDisable = _bHideWhenDisable;
	LeftButton.m_bHideSBWhenDisable = _bHideWhenDisable;
	RightButton.m_bHideSBWhenDisable = _bHideWhenDisable;
	return;
}

function SetBorderColor(Color C)
{
	m_BorderColor = C;
	LeftButton.m_BorderColor = C;
	RightButton.m_BorderColor = C;
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var h
