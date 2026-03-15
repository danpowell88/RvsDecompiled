//=============================================================================
// UWindowTextAreaControl - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowTextAreaControl extends UWindowDialogControl;

const szTextArraySize = 80;

var int Font;
var int BufSize;
var int Head;
// NEW IN 1.60
var int Tail;
// NEW IN 1.60
var int Lines;
// NEW IN 1.60
var int VisibleRows;
var bool bCursor;
var bool bScrollable;
var bool bShowCaret;
var bool bScrollOnResize;
var bool m_bWrapClipText;  // to know in before paint when the wrap clip the text is need
var float m_fXOffSet;
var float m_fYOffSet;
var float LastDrawTime;
// NEW IN 1.60
var Font TextFontArea[80];
var Font AbsoluteFont;
var UWindowVScrollbar VertSB;
// NEW IN 1.60
var Color TextColorArea[80];
// NEW IN 1.60
var string TextArea[80];
var string Prompt;

function Created()
{
	LastDrawTime = GetTime();
	return;
}

function SetScrollable(bool newScrollable)
{
	bScrollable = newScrollable;
	// End:0x6D
	if(newScrollable)
	{
		VertSB = UWindowVScrollbar(CreateWindow(Class'UWindow.UWindowVScrollbar', (WinWidth - LookAndFeel.Size_ScrollbarWidth), 0.0000000, LookAndFeel.Size_ScrollbarWidth, WinHeight));
		VertSB.bAlwaysOnTop = true;		
	}
	else
	{
		// End:0x8E
		if((VertSB != none))
		{
			VertSB.Close();
			VertSB = none;
		}
	}
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	super.BeforePaint(C, X, Y);
	// End:0x89
	if((VertSB != none))
	{
		VertSB.WinTop = 0.0000000;
		VertSB.WinHeight = WinHeight;
		VertSB.WinWidth = LookAndFeel.Size_ScrollbarWidth;
		VertSB.WinLeft = (WinWidth - LookAndFeel.Size_ScrollbarWidth);
	}
	return;
}

function SetAbsoluteFont(Font f)
{
	AbsoluteFont = f;
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local int i, j, Line, TempHead, TempTail;

	local float XL, YL, W, H;

	// End:0x22
	if((AbsoluteFont != none))
	{
		C.Font = AbsoluteFont;		
	}
	else
	{
		C.Font = Root.Fonts[Font];
	}
	C.SetDrawColor(byte(255), byte(255), byte(255));
	TextSize(C, "TEST", XL, YL);
	VisibleRows = int((WinHeight / YL));
	TempHead = Head;
	TempTail = Tail;
	Line = TempHead;
	// End:0xD8
	if((Prompt == ""))
	{
		(Line--);
		// End:0xD8
		if((Line < 0))
		{
			(Line += BufSize);
		}
	}
	// End:0x183
	if(bScrollable)
	{
		// End:0x183
		if(((VertSB.MaxPos - VertSB.pos) >= float(0)))
		{
			(Line -= int((VertSB.MaxPos - VertSB.pos)));
			(TempTail -= int((VertSB.MaxPos - VertSB.pos)));
			// End:0x16C
			if((Line < 0))
			{
				(Line += BufSize);
			}
			// End:0x183
			if((TempTail < 0))
			{
				(TempTail += BufSize);
			}
		}
	}
	// End:0x199
	if((!bCursor))
	{
		bShowCaret = false;		
	}
	else
	{
		// End:0x1DD
		if(((GetTime() > (LastDrawTime + 0.3000000)) || (GetTime() < LastDrawTime)))
		{
			LastDrawTime = GetTime();
			bShowCaret = (!bShowCaret);
		}
	}
	i = 0;
	J0x1E4:

	// End:0x2C9 [Loop If]
	if((i < (VisibleRows + 1)))
	{
		ClipText(C, 2.0000000, (WinHeight - (YL * float((i + 1)))), TextArea[Line]);
		// End:0x28F
		if(((Line == Head) && bShowCaret))
		{
			TextSize(C, TextArea[Line], W, H);
			ClipText(C, W, (WinHeight - (YL * float((i + 1)))), "|");
		}
		// End:0x2A1
		if((TempTail == Line))
		{
			// [Explicit Break]
			goto J0x2C9;
		}
		(Line--);
		// End:0x2BF
		if((Line < 0))
		{
			(Line += BufSize);
		}
		(i++);
		// [Loop Continue]
		goto J0x1E4;
	}
	J0x2C9:

	return;
}

function AddText(string _szNewLine, Color _TextColor, Font _Font)
{
	TextColorArea[Lines] = _TextColor;
	TextFontArea[Lines] = _Font;
	TextArea[Lines] = _szNewLine;
	(Lines += 1);
	return;
}

function AddTextWithCanvas(Canvas C, float _fXOffSet, float _fYOffset, string NewLine, Font _Font, Color FontColor)
{
	local string szTempTextArea[80], Out, temp, szTSResult;
	local float XWordPos, fWidthToReduce, fTotalWToReduce, WordWidth, WordHeight;

	local int WordPos, TotalPos, PrevPos, TotalLinePos, numLines, PrevNumLines,
		i, iRealSizeOfWord, iNbLineTemp, iNbLineTempTotal;

	local bool bSentry;

	m_fXOffSet = _fXOffSet;
	m_fYOffSet = _fYOffset;
	fWidthToReduce = (_fXOffSet + float(11));
	fTotalWToReduce = ((2.0000000 * _fXOffSet) + float(11));
	iNbLineTemp = 0;
	temp = Caps(NewLine);
	szTempTextArea[iNbLineTemp] = NewLine;
	i = InStr(temp, "\\N");
	J0x75:

	// End:0xF8 [Loop If]
	if((i != -1))
	{
		temp = Mid(szTempTextArea[iNbLineTemp], (i + 2));
		szTempTextArea[iNbLineTemp] = Left(szTempTextArea[iNbLineTemp], i);
		(iNbLineTemp += 1);
		szTempTextArea[iNbLineTemp] = temp;
		temp = Caps(temp);
		i = InStr(temp, "\\N");
		// [Loop Continue]
		goto J0x75;
	}
	iNbLineTempTotal = iNbLineTemp;
	Out = "";
	bSentry = true;
	iNbLineTemp = 0;
	XWordPos = _fXOffSet;
	J0x125:

	// End:0x439 [Loop If]
	if(bSentry)
	{
		// End:0x17C
		if((Out == ""))
		{
			i = 0;
			PrevPos = 0;
			TotalLinePos = 0;
			TotalPos = 0;
			numLines = 1;
			PrevNumLines = 1;
			(i++);
			Out = szTempTextArea[iNbLineTemp];
		}
		WordPos = InStr(Out, " ");
		// End:0x1B6
		if((WordPos == -1))
		{
			temp = Out;
			WordPos = Len(temp);			
		}
		else
		{
			temp = (Left(Out, WordPos) $ " ");
		}
		C.Font = _Font;
		szTSResult = TextSize(C, temp, WordWidth, WordHeight, int((WinWidth - fTotalWToReduce)));
		// End:0x299
		if((((WordWidth + XWordPos) + fTotalWToReduce) > (WinWidth - _fXOffSet)))
		{
			// End:0x284
			if((XWordPos == _fXOffSet))
			{
				temp = szTSResult;
				WordPos = __NFUN_125__(temp);
				Out = __NFUN_127__(Out, WordPos);
				__NFUN_161__(TotalPos, WordPos);
				__NFUN_161__(TotalLinePos, WordPos);
			}
			XWordPos = _fXOffSet;
			__NFUN_165__(numLines);			
		}
		else
		{
			__NFUN_184__(XWordPos, WordWidth);
			__NFUN_161__(TotalPos, __NFUN_146__(WordPos, 1));
			__NFUN_161__(TotalLinePos, __NFUN_146__(WordPos, 1));
			Out = __NFUN_127__(Out, __NFUN_125__(temp));
		}
		// End:0x2F8
		if(__NFUN_130__(__NFUN_122__(Out, ""), __NFUN_151__(i, 0)))
		{
			bSentry = false;
		}
		// End:0x436
		if(__NFUN_132__(__NFUN_155__(numLines, PrevNumLines), __NFUN_129__(bSentry)))
		{
			// End:0x377
			if(__NFUN_153__(Lines, 80))
			{
				__NFUN_231__("Small problem over here, string array overloaded in UWindowTextAreaControl.uc");
				// [Explicit Break]
				goto J0x439;				
			}
			else
			{
				PrevNumLines = numLines;
				temp = __NFUN_127__(szTempTextArea[iNbLineTemp], PrevPos);
				TextArea[Lines] = __NFUN_128__(temp, TotalLinePos);
				TextColorArea[Lines] = FontColor;
				TextFontArea[Lines] = C.Font;
				PrevPos = TotalPos;
				TotalLinePos = 0;
				__NFUN_161__(Lines, 1);
				// End:0x436
				if(__NFUN_130__(__NFUN_150__(iNbLineTemp, iNbLineTempTotal), __NFUN_129__(bSentry)))
				{
					__NFUN_161__(iNbLineTemp, 1);
					Out = "";
					bSentry = true;
					XWordPos = _fXOffSet;
				}
			}
		}
		// [Loop Continue]
		goto J0x125;
	}
	J0x439:

	return;
}

function Resized()
{
	// End:0x51
	if(bScrollable)
	{
		VertSB.SetRange(0.0000000, float(Lines), float(VisibleRows));
		// End:0x51
		if(bScrollOnResize)
		{
			VertSB.pos = VertSB.MaxPos;
		}
	}
	return;
}

function SetPrompt(string NewPrompt)
{
	Prompt = NewPrompt;
	return;
}

function Clear(optional bool _bClearArrayOnly, optional bool _bWrapText)
{
	local int i;

	// End:0x59
	if(__NFUN_155__(Lines, 0))
	{
		i = 0;
		J0x12:

		// End:0x59 [Loop If]
		if(__NFUN_150__(i, 80))
		{
			TextArea[i] = "";
			TextFontArea[i] = none;
			__NFUN_162__(Lines, 1);
			// End:0x4F
			if(__NFUN_154__(Lines, 0))
			{
				// [Explicit Break]
				goto J0x59;
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x12;
		}
	}
	J0x59:

	TextArea[0] = "";
	TextFontArea[0] = none;
	// End:0x89
	if(bScrollable)
	{
		VertSB.pos = 0.0000000;
	}
	// End:0x9A
	if(_bWrapText)
	{
		m_bWrapClipText = true;
	}
	// End:0xD1
	if(__NFUN_129__(_bClearArrayOnly))
	{
		Head = 0;
		Tail = 0;
		m_fXOffSet = 0.0000000;
		m_fYOffSet = 0.0000000;
		m_bWrapClipText = true;
	}
	return;
}

defaultproperties
{
	BufSize=200
	bScrollOnResize=true
	m_bWrapClipText=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var TextFontAreaszTextArraySize
// REMOVED IN 1.60: var TextColorAreaszTextArraySize
// REMOVED IN 1.60: var TextAreaszTextArraySize
// REMOVED IN 1.60: var l
// REMOVED IN 1.60: var s
