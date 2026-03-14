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
	if(__NFUN_176__(P, float(0)))
	{
		return;
	}
	// End:0x27
	if(__NFUN_177__(P, __NFUN_174__(MaxPos, MaxVisible)))
	{
		return;
	}
	J0x27:

	// End:0x4C [Loop If]
	if(__NFUN_176__(P, pos))
	{
		// End:0x49
		if(__NFUN_129__(Scroll(-1.0000000)))
		{
			// [Explicit Break]
			goto J0x4C;
		}
		// [Loop Continue]
		goto J0x27;
	}
	J0x4C:

	// End:0x7D [Loop If]
	if(__NFUN_177__(__NFUN_175__(P, pos), __NFUN_175__(MaxVisible, float(1))))
	{
		// End:0x7A
		if(__NFUN_129__(Scroll(1.0000000)))
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
	pos = __NFUN_174__(pos, Delta);
	CheckRange();
	return __NFUN_180__(pos, __NFUN_174__(OldPos, Delta));
	return;
}

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
	// End:0x98
	if(bDisabled)
	{
		pos = 0.0000000;
		ThumbStart = 0.0000000;		
	}
	else
	{
		ThumbStart = __NFUN_172__(__NFUN_171__(__NFUN_175__(pos, MinPos), __NFUN_175__(WinHeight, __NFUN_174__(__NFUN_171__(float(2), LookAndFeel.Size_ScrollbarButtonHeight), float(2)))), __NFUN_175__(__NFUN_174__(MaxPos, MaxVisible), MinPos));
		ThumbHeight = __NFUN_172__(__NFUN_171__(MaxVisible, __NFUN_175__(WinHeight, __NFUN_174__(__NFUN_171__(float(2), LookAndFeel.Size_ScrollbarButtonHeight), float(2)))), __NFUN_175__(__NFUN_174__(MaxPos, MaxVisible), MinPos));
		// End:0x151
		if(__NFUN_176__(ThumbHeight, LookAndFeel.Size_MinScrollbarHeight))
		{
			ThumbHeight = LookAndFeel.Size_MinScrollbarHeight;
		}
		// End:0x1A6
		if(__NFUN_177__(__NFUN_174__(ThumbHeight, ThumbStart), __NFUN_175__(__NFUN_175__(WinHeight, LookAndFeel.Size_ScrollbarButtonHeight), float(1))))
		{
			ThumbStart = __NFUN_175__(__NFUN_175__(__NFUN_175__(WinHeight, LookAndFeel.Size_ScrollbarButtonHeight), ThumbHeight), float(1));			
		}
		else
		{
			ThumbStart = __NFUN_174__(__NFUN_174__(ThumbStart, LookAndFeel.Size_ScrollbarButtonHeight), float(1));
		}
	}
	return;
}

function Created()
{
	UpButton = UWindowSBUpButton(CreateWindow(Class'UWindow.UWindowSBUpButton', 0.0000000, 0.0000000, LookAndFeel.Size_ScrollbarWidth, LookAndFeel.Size_ScrollbarButtonHeight));
	DownButton = UWindowSBDownButton(CreateWindow(Class'UWindow.UWindowSBDownButton', 0.0000000, __NFUN_175__(WinHeight, LookAndFeel.Size_ScrollbarButtonHeight), LookAndFeel.Size_ScrollbarWidth, LookAndFeel.Size_ScrollbarButtonHeight));
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
	DownButton.WinTop = __NFUN_175__(WinHeight, LookAndFeel.Size_ScrollbarButtonHeight);
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
	return __NFUN_130__(bDisabled, m_bHideSBWhenDisable);
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
	if(__NFUN_176__(Y, ThumbStart))
	{
		Scroll(__NFUN_169__(__NFUN_175__(MaxVisible, float(1))));
		NextClickTime = __NFUN_174__(GetTime(), 0.5000000);
		return;
	}
	// End:0x8C
	if(__NFUN_177__(Y, __NFUN_174__(ThumbStart, ThumbHeight)))
	{
		Scroll(__NFUN_175__(MaxVisible, float(1)));
		NextClickTime = __NFUN_174__(GetTime(), 0.5000000);
		return;
	}
	// End:0xDE
	if(__NFUN_130__(__NFUN_179__(Y, ThumbStart), __NFUN_178__(Y, __NFUN_174__(ThumbStart, ThumbHeight))))
	{
		DragY = __NFUN_175__(Y, ThumbStart);
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
		bUp = __NFUN_176__(Y, ThumbStart);
		bDown = __NFUN_177__(Y, __NFUN_174__(ThumbStart, ThumbHeight));
	}
	// End:0xBB
	if(__NFUN_130__(__NFUN_130__(__NFUN_130__(bMouseDown, __NFUN_177__(NextClickTime, float(0))), __NFUN_176__(NextClickTime, GetTime())), bUp))
	{
		Scroll(__NFUN_169__(__NFUN_175__(MaxVisible, float(1))));
		NextClickTime = __NFUN_174__(GetTime(), 0.1000000);
	}
	// End:0x113
	if(__NFUN_130__(__NFUN_130__(__NFUN_130__(bMouseDown, __NFUN_177__(NextClickTime, float(0))), __NFUN_176__(NextClickTime, GetTime())), bDown))
	{
		Scroll(__NFUN_175__(MaxVisible, float(1)));
		NextClickTime = __NFUN_174__(GetTime(), 0.1000000);
	}
	// End:0x143
	if(__NFUN_132__(__NFUN_129__(bMouseDown), __NFUN_130__(__NFUN_129__(bUp), __NFUN_129__(bDown))))
	{
		NextClickTime = 0.0000000;
	}
	return;
}

function MouseMove(float X, float Y)
{
	// End:0x8E
	if(__NFUN_130__(__NFUN_130__(bDragging, bMouseDown), __NFUN_129__(bDisabled)))
	{
		J0x21:

		// End:0x56 [Loop If]
		if(__NFUN_130__(__NFUN_176__(Y, __NFUN_174__(ThumbStart, DragY)), __NFUN_177__(pos, MinPos)))
		{
			Scroll(-1.0000000);
			// [Loop Continue]
			goto J0x21;
		}
		J0x56:

		// End:0x8B [Loop If]
		if(__NFUN_130__(__NFUN_177__(Y, __NFUN_174__(ThumbStart, DragY)), __NFUN_176__(pos, MaxPos)))
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
