//=============================================================================
// UWindowEditControl - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowEditControl extends UWindowDialogControl;

var float EditBoxWidth;
var float EditAreaDrawX;
// NEW IN 1.60
var float EditAreaDrawY;
var UWindowEditBox EditBox;

function Created()
{
	local Color C;

	super.Created();
	EditBox = UWindowEditBox(CreateWindow(Class'UWindow.UWindowEditBox', 0.0000000, 0.0000000, WinWidth, WinHeight));
	EditBox.NotifyOwner = self;
	EditBoxWidth = __NFUN_172__(WinWidth, float(2));
	SetEditTextColor(LookAndFeel.EditBoxTextColor);
	return;
}

function SetNumericOnly(bool bNumericOnly)
{
	EditBox.bNumericOnly = bNumericOnly;
	return;
}

function SetNumericFloat(bool bNumericFloat)
{
	EditBox.bNumericFloat = bNumericFloat;
	return;
}

function SetFont(int NewFont)
{
	super.SetFont(NewFont);
	EditBox.SetFont(NewFont);
	return;
}

function SetHistory(bool bInHistory)
{
	EditBox.SetHistory(bInHistory);
	return;
}

function SetEditTextColor(Color NewColor)
{
	EditBox.SetTextColor(NewColor);
	return;
}

function Clear()
{
	EditBox.Clear();
	return;
}

function string GetValue()
{
	return EditBox.GetValue();
	return;
}

function string GetValue2()
{
	return EditBox.GetValue2();
	return;
}

function SetValue(string NewValue, optional string NewValue2)
{
	EditBox.SetValue(NewValue, NewValue2);
	return;
}

function SetMaxLength(int MaxLength)
{
	EditBox.MaxLength = MaxLength;
	return;
}

function Paint(Canvas C, float X, float Y)
{
	LookAndFeel.Editbox_Draw(self, C);
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	super.BeforePaint(C, X, Y);
	LookAndFeel.Editbox_SetupSizes(self, C);
	return;
}

function SetDelayedNotify(bool bDelayedNotify)
{
	EditBox.bDelayedNotify = bDelayedNotify;
	return;
}

function FocusWindow()
{
	super(UWindowWindow).FocusWindow();
	EditBox.FocusWindow();
	return;
}

function KeyFocusEnter()
{
	EditBox.KeyFocusEnter();
	return;
}

function KeyFocusExit()
{
	EditBox.KeyFocusExit();
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var Y
