// UWindowEditBox - simple edit box, for use in other controls such as 
// UWindowComboxBoxControl, UWindowEditBoxControl etc.
class UWindowEditBox extends UWindowDialogControl;

// --- Variables ---
// var ? Offset; // REMOVED IN 1.60
var string Value;
var int CaretOffset;
var UWindowEditBoxHistory CurrentHistory;
var bool m_CurrentlyEditing;
var bool bAllSelected;
var bool bCanEdit;
var bool bShowLog;
var float offset;
// ^ NEW IN 1.60
var UWindowEditBoxHistory HistoryList;
var bool bShowCaret;
var float LastDrawTime;
var bool bHistory;
var UWindowDialogControl NotifyOwner;
var bool bControlDown;
var bool bChangePending;
var bool bKeyDown;
var bool bDelayedNotify;
var int MaxLength;
var string OldValue;
var bool bNumericFloat;
var bool bNumericOnly;
var string Value2;
var bool bShiftDown;
// the mouse is over the window edit box
var bool m_bMouseOn;
var bool m_bDrawEditBorders;
var bool m_bUseNewPaint;
var bool bSelectOnFocus;
// draw the edit box background
var bool m_bDrawEditBoxBG;
var bool bPassword;

// --- Functions ---
function Notify(byte E) {}
function bool Backspace() {}
// ^ NEW IN 1.60
function bool Delete() {}
// ^ NEW IN 1.60
function FocusOtherWindow(UWindowWindow W) {}
function Paint(Canvas C, float Y, float X) {}
function SetHistory(bool bInHistory) {}
function SetEditable(bool bEditable) {}
function SetValue(string NewValue, optional string NewValue2, optional bool noUpdateHistory) {}
// Inserts a character at the current caret position
function bool Insert(byte C) {}
// ^ NEW IN 1.60
function KeyDown(int Key, float X, float Y) {}
function KeyUp(int Key, float Y, float X) {}
function LMouseDown(float X, float Y) {}
function Close(optional bool bByParent) {}
function DoubleClick(float X, float Y) {}
function KeyType(int Key, float MouseY, float MouseX) {}
function InsertText(string Text) {}
function MouseLeave() {}
function MouseEnter() {}
function DropSelection() {}
function KeyFocusExit() {}
function KeyFocusEnter() {}
function FocusWindow() {}
function Click(float Y, float X) {}
function EditCut() {}
function EditPaste() {}
function EditCopy() {}
function bool MoveEnd() {}
// ^ NEW IN 1.60
function bool MoveHome() {}
// ^ NEW IN 1.60
function bool WordRight() {}
// ^ NEW IN 1.60
function bool MoveRight() {}
// ^ NEW IN 1.60
function bool MoveLeft() {}
// ^ NEW IN 1.60
function bool WordLeft() {}
// ^ NEW IN 1.60
function string GetValue2() {}
// ^ NEW IN 1.60
function string GetValue() {}
// ^ NEW IN 1.60
//This is the default function for enabling editing
function SelectAll() {}
function Clear() {}
function Created() {}

defaultproperties
{
}
