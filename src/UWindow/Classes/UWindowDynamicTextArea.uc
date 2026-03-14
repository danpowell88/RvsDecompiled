// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\UWindow.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class UWindowDynamicTextArea extends UWindowDialogControl;

// --- Variables ---
var UWindowVScrollbar VertSB;
// private
var UWindowDynamicTextRow List;
var int VisibleRows;
var int Count;
var float DefaultTextHeight;
var Color TextColor;
var bool bDirty;
var bool bAutoScrollbar;
var Font AbsoluteFont;
var class<UWindowDynamicTextRow> RowClass;
var config int MaxLines;
var bool bTopCentric;
// Assumes !bTopCentric, !bScrollOnResize
var bool bVariableRowHeight;
var float WrapWidth;
var float OldW;
// ^ NEW IN 1.60
var float OldH;
var int Font;
var bool bHCenter;
var bool bVCenter;
var bool bScrollOnResize;

// --- Functions ---
function SetAbsoluteFont(Font f) {}
function SetFont(int f) {}
function SetTextColor(Color C) {}
function TextAreaClipText(optional bool bCheckHotKey, coerce string S, float DrawY, float DrawX, Canvas C) {}
function TextAreaTextSize(out float H, out float W, string Text, Canvas C) {}
function BeforePaint(float Y, float X, Canvas C) {}
function Paint(Canvas C, float MouseY, float MouseX) {}
function UWindowDynamicTextRow AddText(string NewLine) {}
// ^ NEW IN 1.60
function UWindowDynamicTextRow SplitRowAt(UWindowDynamicTextRow L, int SplitPos) {}
// ^ NEW IN 1.60
function RemoveNextWord(out string Text, out string NextWord) {}
// find where to break the line
function int GetWrapPos(Canvas C, UWindowDynamicTextRow L, float MaxWidth) {}
// ^ NEW IN 1.60
function WordWrap(bool bForce, Canvas C) {}
function RemoveWrap(UWindowDynamicTextRow L) {}
function WrapRow(UWindowDynamicTextRow L, Canvas C) {}
function UWindowDynamicTextRow CheckMaxRows() {}
// ^ NEW IN 1.60
function float DrawTextLine(Canvas C, UWindowDynamicTextRow L, float Y) {}
// ^ NEW IN 1.60
function Clear() {}
function Created() {}

defaultproperties
{
}
