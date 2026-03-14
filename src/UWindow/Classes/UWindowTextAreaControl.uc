// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\UWindow.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class UWindowTextAreaControl extends UWindowDialogControl;

// --- Constants ---
const szTextArraySize =  80;

// --- Variables ---
var UWindowVScrollbar VertSB;
var int Lines;
// ^ NEW IN 1.60
//array of string?
var string TextArea[80];
var Font TextFontArea[80];
var Font AbsoluteFont;
var Color TextColorArea[80];
var float m_fYOffSet;
var int VisibleRows;
var float m_fXOffSet;
var bool bScrollable;
var int BufSize;
var bool bShowCaret;
// to know in before paint when the wrap clip the text is need
var bool m_bWrapClipText;
var float LastDrawTime;
var int Head;
// ^ NEW IN 1.60
var string Prompt;
var int Tail;
// ^ NEW IN 1.60
var bool bScrollOnResize;
var bool bCursor;
var int Font;

// --- Functions ---
function Paint(Canvas C, float X, float Y) {}
function BeforePaint(float Y, float X, Canvas C) {}
function SetScrollable(bool newScrollable) {}
function AddTextWithCanvas(float _fXOffSet, Canvas C, string NewLine, Color FontColor, Font _Font, float _fYOffset) {}
function SetPrompt(string NewPrompt) {}
function AddText(Font _Font, Color _TextColor, string _szNewLine) {}
function Clear(optional bool _bWrapText, optional bool _bClearArrayOnly) {}
function SetAbsoluteFont(Font f) {}
function Created() {}
function Resized() {}

defaultproperties
{
}
