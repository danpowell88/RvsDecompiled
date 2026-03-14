//=============================================================================
// UWindowSBRightButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// UWindowSBRightButton - Scrollbar right button
//=============================================================================
class UWindowSBRightButton extends UWindowButton;

var bool m_bHideSBWhenDisable;
var float NextClickTime;

function Created()
{
	bNoKeyboard = true;
	super.Created();
	LookAndFeel.SB_SetupRightButton(self);
	return;
}

function Paint(Canvas C, float X, float Y)
{
	// End:0x16
	if(__NFUN_130__(bDisabled, m_bHideSBWhenDisable))
	{
		return;
	}
	super.Paint(C, X, Y);
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
	UWindowHScrollbar(ParentWindow).Scroll(UWindowHScrollbar(ParentWindow).ScrollAmount);
	NextClickTime = __NFUN_174__(GetTime(), 0.5000000);
	return;
}

function Tick(float Delta)
{
	// End:0x64
	if(__NFUN_130__(__NFUN_130__(bMouseDown, __NFUN_177__(NextClickTime, float(0))), __NFUN_176__(NextClickTime, GetTime())))
	{
		UWindowHScrollbar(ParentWindow).Scroll(UWindowHScrollbar(ParentWindow).ScrollAmount);
		NextClickTime = __NFUN_174__(GetTime(), 0.1000000);
	}
	// End:0x7A
	if(__NFUN_129__(bMouseDown))
	{
		NextClickTime = 0.0000000;
	}
	return;
}

function MouseLeave()
{
	super(UWindowDialogControl).MouseLeave();
	UWindowHScrollbar(OwnerWindow).MouseLeave();
	return;
}

function MouseEnter()
{
	super(UWindowDialogControl).MouseEnter();
	UWindowHScrollbar(OwnerWindow).MouseEnter();
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function BeforePaint
