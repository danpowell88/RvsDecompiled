// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\UWindow.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class UWindowEditControl extends UWindowDialogControl;

// --- Variables ---
var UWindowEditBox EditBox;
var float EditBoxWidth;
var float EditAreaDrawX;
// ^ NEW IN 1.60
var float EditAreaDrawY;

// --- Functions ---
function SetFont(int NewFont) {}
function BeforePaint(Canvas C, float X, float Y) {}
function SetNumericOnly(bool bNumericOnly) {}
function SetNumericFloat(bool bNumericFloat) {}
function SetHistory(bool bInHistory) {}
function SetEditTextColor(Color NewColor) {}
function SetValue(string NewValue, optional string NewValue2) {}
function SetMaxLength(int MaxLength) {}
function Paint(Canvas C, float Y, float X) {}
function SetDelayedNotify(bool bDelayedNotify) {}
function KeyFocusExit() {}
function KeyFocusEnter() {}
function FocusWindow() {}
function string GetValue2() {}
// ^ NEW IN 1.60
function string GetValue() {}
// ^ NEW IN 1.60
function Clear() {}
function Created() {}

defaultproperties
{
}
