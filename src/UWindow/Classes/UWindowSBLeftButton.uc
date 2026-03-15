//=============================================================================
// UWindowSBLeftButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// UWindowSBLeftButton - Scrollbar left button
//=============================================================================
class UWindowSBLeftButton extends UWindowButton;

var bool m_bHideSBWhenDisable;
var float NextClickTime;

function Created()
{
	bNoKeyboard = true;
	super.Created();
	LookAndFeel.SB_SetupLeftButton(self);
	return;
}

function Paint(Canvas C, float X, float Y)
{
	// End:0x16
	if((bDisabled && m_bHideSBWhenDisable))
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
	UWindowHScrollbar(ParentWindow).Scroll((-UWindowHScrollbar(ParentWindow).ScrollAmount));
	NextClickTime = (GetTime() + 0.5000000);
	return;
}

function Tick(float Delta)
{
	// End:0x66
	if(((bMouseDown && (NextClickTime > float(0))) && (NextClickTime < GetTime())))
	{
		UWindowHScrollbar(ParentWindow).Scroll((-UWindowHScrollbar(ParentWindow).ScrollAmount));
		NextClickTime = (GetTime() + 0.1000000);
	}
	// End:0x7C
	if((!bMouseDown))
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
