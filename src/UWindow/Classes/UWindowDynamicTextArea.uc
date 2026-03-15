//=============================================================================
// UWindowDynamicTextArea - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowDynamicTextArea extends UWindowDialogControl
    config;

var config int MaxLines;
var int Count;
var int VisibleRows;
var int Font;
var bool bTopCentric;
var bool bScrollOnResize;
var bool bVCenter;
var bool bHCenter;
var bool bAutoScrollbar;
var bool bVariableRowHeight;  // Assumes !bTopCentric, !bScrollOnResize
var bool bDirty;
var float DefaultTextHeight;
var float WrapWidth;
var float OldW;
// NEW IN 1.60
var float OldH;
// private
var UWindowDynamicTextRow List;
var UWindowVScrollbar VertSB;
var Font AbsoluteFont;
var Class<UWindowDynamicTextRow> RowClass;
var Color TextColor;

function Created()
{
	super.Created();
	VertSB = UWindowVScrollbar(CreateWindow(Class'UWindow.UWindowVScrollbar', (WinWidth - LookAndFeel.Size_ScrollbarWidth), 0.0000000, LookAndFeel.Size_ScrollbarWidth, WinHeight));
	VertSB.bAlwaysOnTop = true;
	Clear();
	return;
}

function Clear()
{
	bDirty = true;
	// End:0x38
	if((List != none))
	{
		// End:0x29
		if((List.Next == none))
		{
			return;
		}
		List.DestroyList();
	}
	List = new RowClass;
	List.SetupSentinel();
	return;
}

function SetAbsoluteFont(Font f)
{
	AbsoluteFont = f;
	return;
}

function SetFont(int f)
{
	Font = f;
	return;
}

function SetTextColor(Color C)
{
	TextColor = C;
	return;
}

function TextAreaClipText(Canvas C, float DrawX, float DrawY, coerce string S, optional bool bCheckHotKey)
{
	ClipText(C, DrawX, DrawY, S, bCheckHotKey);
	return;
}

function TextAreaTextSize(Canvas C, string Text, out float W, out float H)
{
	TextSize(C, Text, W, H);
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	super.BeforePaint(C, X, Y);
	VertSB.WinTop = 0.0000000;
	VertSB.WinHeight = WinHeight;
	VertSB.WinWidth = LookAndFeel.Size_ScrollbarWidth;
	VertSB.WinLeft = (WinWidth - LookAndFeel.Size_ScrollbarWidth);
	return;
}

function Paint(Canvas C, float MouseX, float MouseY)
{
	local UWindowDynamicTextRow L;
	local int SkipCount, DrawCount, i;
	local float Y, Junk;
	local bool bWrapped;

	C.SetDrawColor(TextColor.R, TextColor.G, TextColor.B);
	// End:0x4C
	if((AbsoluteFont != none))
	{
		C.Font = AbsoluteFont;		
	}
	else
	{
		C.Font = Root.Fonts[Font];
	}
	// End:0xBC
	if(((OldW != WinWidth) || (OldH != WinHeight)))
	{
		WordWrap(C, true);
		OldW = WinWidth;
		OldH = WinHeight;
		bWrapped = true;		
	}
	else
	{
		// End:0xD9
		if(bDirty)
		{
			WordWrap(C, false);
			bWrapped = true;
		}
	}
	// End:0x1D1
	if(bWrapped)
	{
		TextAreaTextSize(C, "A", Junk, DefaultTextHeight);
		VisibleRows = int((WinHeight / DefaultTextHeight));
		Count = List.Count();
		VertSB.SetRange(0.0000000, float(Count), float(VisibleRows));
		// End:0x18B
		if(bScrollOnResize)
		{
			// End:0x16E
			if(bTopCentric)
			{
				VertSB.pos = 0.0000000;				
			}
			else
			{
				VertSB.pos = VertSB.MaxPos;
			}
		}
		// End:0x1D1
		if((bAutoScrollbar && (!bVariableRowHeight)))
		{
			// End:0x1C2
			if((Count <= VisibleRows))
			{
				VertSB.HideWindow();				
			}
			else
			{
				VertSB.ShowWindow();
			}
		}
	}
	// End:0x3AD
	if(bTopCentric)
	{
		SkipCount = int(VertSB.pos);
		L = UWindowDynamicTextRow(List.Next);
		i = 0;
		J0x210:

		// End:0x24F [Loop If]
		if(((i < SkipCount) && (L != none)))
		{
			L = UWindowDynamicTextRow(L.Next);
			(i++);
			// [Loop Continue]
			goto J0x210;
		}
		// End:0x291
		if((bVCenter && (Count <= VisibleRows)))
		{
			Y = float(int(((WinHeight - (float(Count) * DefaultTextHeight)) / float(2))));			
		}
		else
		{
			Y = 1.0000000;
		}
		DrawCount = 0;
		J0x2A3:

		// End:0x30B [Loop If]
		if((Y < WinHeight))
		{
			(DrawCount++);
			// End:0x2FC
			if((L != none))
			{
				(Y += DrawTextLine(C, L, Y));
				L = UWindowDynamicTextRow(L.Next);				
			}
			else
			{
				(Y += DefaultTextHeight);
			}
			// [Loop Continue]
			goto J0x2A3;
		}
		// End:0x3AA
		if(bVariableRowHeight)
		{
			VisibleRows = (DrawCount - 1);
			J0x322:

			// End:0x34F [Loop If]
			if(((VertSB.pos + float(VisibleRows)) > float(Count)))
			{
				(VisibleRows--);
				// [Loop Continue]
				goto J0x322;
			}
			VertSB.SetRange(0.0000000, float(Count), float(VisibleRows));
			// End:0x3AA
			if(bAutoScrollbar)
			{
				// End:0x39B
				if((Count <= VisibleRows))
				{
					VertSB.HideWindow();					
				}
				else
				{
					VertSB.ShowWindow();
				}
			}
		}		
	}
	else
	{
		SkipCount = Max(0, int((float(Count) - (float(VisibleRows) + VertSB.pos))));
		L = UWindowDynamicTextRow(List.Last);
		i = 0;
		J0x3F8:

		// End:0x43B [Loop If]
		if(((i < SkipCount) && (L != List)))
		{
			L = UWindowDynamicTextRow(L.Prev);
			(i++);
			// [Loop Continue]
			goto J0x3F8;
		}
		Y = (WinHeight - DefaultTextHeight);
		J0x44D:

		// End:0x4BF [Loop If]
		if((((L != List) && (L != none)) && (Y > (-DefaultTextHeight))))
		{
			DrawTextLine(C, L, Y);
			Y = (Y - DefaultTextHeight);
			L = UWindowDynamicTextRow(L.Prev);
			// [Loop Continue]
			goto J0x44D;
		}
	}
	return;
}

function UWindowDynamicTextRow AddText(string NewLine)
{
	local UWindowDynamicTextRow L;
	local string temp;
	local int i;

	bDirty = true;
	i = InStr(NewLine, "\\n");
	// End:0x53
	if((i != -1))
	{
		temp = Mid(NewLine, (i + 2));
		NewLine = Left(NewLine, i);		
	}
	else
	{
		temp = "";
	}
	L = CheckMaxRows();
	// End:0x89
	if((L != none))
	{
		List.AppendItem(L);		
	}
	else
	{
		L = UWindowDynamicTextRow(List.Append(RowClass));
	}
	L.Text = NewLine;
	L.WrapParent = none;
	L.bRowDirty = true;
	// End:0xF4
	if((temp != ""))
	{
		AddText(temp);
	}
	return L;
	return;
}

function UWindowDynamicTextRow CheckMaxRows()
{
	local UWindowDynamicTextRow L;

	L = none;
	J0x07:

	// End:0x7C [Loop If]
	if((((MaxLines > 0) && (List.Count() > (MaxLines - 1))) && (List.Next != none)))
	{
		L = UWindowDynamicTextRow(List.Next);
		RemoveWrap(L);
		L.Remove();
		// [Loop Continue]
		goto J0x07;
	}
	return L;
	return;
}

function WordWrap(Canvas C, bool bForce)
{
	local UWindowDynamicTextRow L;

	L = UWindowDynamicTextRow(List.Next);
	J0x19:

	// End:0x83 [Loop If]
	if((L != none))
	{
		// End:0x67
		if(((L.WrapParent == none) && (L.bRowDirty || bForce)))
		{
			WrapRow(C, L);
		}
		L = UWindowDynamicTextRow(L.Next);
		// [Loop Continue]
		goto J0x19;
	}
	bDirty = false;
	return;
}

function WrapRow(Canvas C, UWindowDynamicTextRow L)
{
	local UWindowDynamicTextRow CurrentRow, N;
	local float MaxWidth;
	local int WrapPos;

	// End:0x56
	if((WrapWidth == float(0)))
	{
		// End:0x48
		if((VertSB.bWindowVisible || bAutoScrollbar))
		{
			MaxWidth = (WinWidth - VertSB.WinWidth);			
		}
		else
		{
			MaxWidth = WinWidth;
		}		
	}
	else
	{
		MaxWidth = WrapWidth;
	}
	L.bRowDirty = false;
	N = UWindowDynamicTextRow(L.Next);
	// End:0xD1
	if(((N == none) || (N.WrapParent != L)))
	{
		// End:0xD1
		if((GetWrapPos(C, L, MaxWidth) == -1))
		{
			return;
		}
	}
	RemoveWrap(L);
	CurrentRow = L;
	J0xE7:

	// End:0x131 [Loop If]
	if(true)
	{
		WrapPos = GetWrapPos(C, CurrentRow, MaxWidth);
		// End:0x118
		if((WrapPos == -1))
		{
			// [Explicit Break]
			goto J0x131;
		}
		CurrentRow = SplitRowAt(CurrentRow, WrapPos);
		// [Loop Continue]
		goto J0xE7;
	}
	J0x131:

	return;
}

function float DrawTextLine(Canvas C, UWindowDynamicTextRow L, float Y)
{
	local float X, W, H;

	// End:0x8C
	if(bHCenter)
	{
		TextAreaTextSize(C, L.Text, W, H);
		// End:0x6D
		if(VertSB.bWindowVisible)
		{
			X = float(int((((WinWidth - VertSB.WinWidth) - W) / float(2))));			
		}
		else
		{
			X = float(int(((WinWidth - W) / float(2))));
		}		
	}
	else
	{
		X = 2.0000000;
	}
	TextAreaClipText(C, X, Y, L.Text);
	return DefaultTextHeight;
	return;
}

// find where to break the line
function int GetWrapPos(Canvas C, UWindowDynamicTextRow L, float MaxWidth)
{
	local float W, H, LineWidth, NextWordWidth;
	local string Input, NextWord;
	local int WordsThisRow, WrapPos;

	TextAreaTextSize(C, L.Text, W, H);
	// End:0x38
	if((W <= MaxWidth))
	{
		return -1;
	}
	Input = L.Text;
	WordsThisRow = 0;
	LineWidth = 0.0000000;
	WrapPos = 0;
	NextWord = "";
	J0x6D:

	// End:0x115 [Loop If]
	if(((Input != "") || (NextWord != "")))
	{
		// End:0xBD
		if((NextWord == ""))
		{
			RemoveNextWord(Input, NextWord);
			TextAreaTextSize(C, NextWord, NextWordWidth, H);
		}
		// End:0xE9
		if(((WordsThisRow > 0) && ((LineWidth + NextWordWidth) > MaxWidth)))
		{
			return WrapPos;			
		}
		else
		{
			__NFUN_161__(WrapPos, __NFUN_125__(NextWord));
			__NFUN_184__(LineWidth, NextWordWidth);
			NextWord = "";
			__NFUN_165__(WordsThisRow);
		}
		// [Loop Continue]
		goto J0x6D;
	}
	return -1;
	return;
}

function UWindowDynamicTextRow SplitRowAt(UWindowDynamicTextRow L, int SplitPos)
{
	local UWindowDynamicTextRow N;

	N = UWindowDynamicTextRow(L.InsertAfter(RowClass));
	// End:0x4A
	if(__NFUN_114__(L.WrapParent, none))
	{
		N.WrapParent = L;		
	}
	else
	{
		N.WrapParent = L.WrapParent;
	}
	N.Text = __NFUN_127__(L.Text, SplitPos);
	L.Text = __NFUN_128__(L.Text, SplitPos);
	return N;
	return;
}

function RemoveNextWord(out string Text, out string NextWord)
{
	local int i;

	i = __NFUN_126__(Text, " ");
	// End:0x35
	if(__NFUN_154__(i, -1))
	{
		NextWord = Text;
		Text = "";		
	}
	else
	{
		J0x35:

		// End:0x54 [Loop If]
		if(__NFUN_122__(__NFUN_127__(Text, i, 1), " "))
		{
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x35;
		}
		NextWord = __NFUN_128__(Text, i);
		Text = __NFUN_127__(Text, i);
	}
	return;
}

function RemoveWrap(UWindowDynamicTextRow L)
{
	local UWindowDynamicTextRow N;

	N = UWindowDynamicTextRow(L.Next);
	J0x19:

	// End:0x96 [Loop If]
	if(__NFUN_130__(__NFUN_119__(N, none), __NFUN_114__(N.WrapParent, L)))
	{
		L.Text = __NFUN_112__(L.Text, N.Text);
		N.Remove();
		N = UWindowDynamicTextRow(L.Next);
		// [Loop Continue]
		goto J0x19;
	}
	return;
}

defaultproperties
{
	bScrollOnResize=true
	RowClass=Class'UWindow.UWindowDynamicTextRow'
	TextColor=(R=255,G=255,B=255,A=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var H
