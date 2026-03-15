//=============================================================================
// UWindowEditControl - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowEditControl extends UWindowDialogControl;

var float EditBoxWidth;         // Width of the edit box portion of the control
var float EditAreaDrawX;        // X draw offset for the edit area bevel
// NEW IN 1.60
var float EditAreaDrawY;        // Y draw offset for the edit area bevel (added in 1.60)
var UWindowEditBox EditBox;     // The child edit box window that handles text input

// Creates the EditBox child window and initializes the edit area and text color.
function Created()

	super.Created();
	EditBox = UWindowEditBox(CreateWindow(Class'UWindow.UWindowEditBox', 0.0000000, 0.0000000, WinWidth, WinHeight));
	EditBox.NotifyOwner = self;
	EditBoxWidth = (WinWidth / float(2));
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

// Returns the current text in the edit box (primary value).
function string GetValue()
{
	return EditBox.GetValue();
	return;
}

// Returns the secondary value string stored alongside the primary value.
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

// Delegates painting to the LookAndFeel Editbox_Draw function.
function Paint(Canvas C, float X, float Y)
	return;
}

// Called before Paint each frame; asks LookAndFeel to recalculate layout sizes.
function BeforePaint(Canvas C, float X, float Y)
{
	super.BeforePaint(C, X, Y);
	LookAndFeel.Editbox_SetupSizes(self, C);
	return;
}

// When enabled, change notifications are delayed until the edit box loses focus.
function SetDelayedNotify(bool bDelayedNotify)
{
	EditBox.bDelayedNotify = bDelayedNotify;
	return;
}

// Propagates window focus to the inner edit box child window.
function FocusWindow()
{
	super(UWindowWindow).FocusWindow();
	EditBox.FocusWindow();
	return;
}

// Called when keyboard focus enters this control; forwards to the edit box.
function KeyFocusEnter()
{
	EditBox.KeyFocusEnter();
	return;
}

// Called when keyboard focus leaves this control; forwards to the edit box.
function KeyFocusExit()
{
	EditBox.KeyFocusExit();
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var Y
