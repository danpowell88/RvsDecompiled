//=============================================================================
// UWindowEditBox - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
// UWindowEditBox - simple edit box, for use in other controls such as 
// UWindowComboxBoxControl, UWindowEditBoxControl etc.
class UWindowEditBox extends UWindowDialogControl;

var int CaretOffset;
var int MaxLength;
var bool bShowCaret;
var bool bNumericOnly;
var bool bNumericFloat;
var bool bCanEdit;
var bool bAllSelected;
var bool bDelayedNotify;
var bool bChangePending;
var bool bControlDown;
var bool bShiftDown;
var bool bHistory;
var bool bKeyDown;
var bool m_bMouseOn;  // the mouse is over the window edit box
var bool m_bDrawEditBorders;
var bool m_bUseNewPaint;
var bool m_CurrentlyEditing;
var bool bSelectOnFocus;
var bool bPassword;
var bool m_bDrawEditBoxBG;  // draw the edit box background
var bool bShowLog;
var float LastDrawTime;
var float offset;
var UWindowDialogControl NotifyOwner;
var UWindowEditBoxHistory HistoryList;
var UWindowEditBoxHistory CurrentHistory;
var string Value;
var string Value2;
var string OldValue;

function Created()
{
	super.Created();
	LastDrawTime = GetTime();
	return;
}

function SetHistory(bool bInHistory)
{
	bHistory = bInHistory;
	// End:0x4B
	if((bHistory && (HistoryList == none)))
	{
		HistoryList = new (none) Class'UWindow.UWindowEditBoxHistory';
		HistoryList.SetupSentinel();
		CurrentHistory = none;		
	}
	else
	{
		// End:0x71
		if(((!bHistory) && (HistoryList != none)))
		{
			HistoryList = none;
			CurrentHistory = none;
		}
	}
	return;
}

function SetEditable(bool bEditable)
{
	bCanEdit = bEditable;
	return;
}

function SetValue(string NewValue, optional string NewValue2, optional bool noUpdateHistory)
{
	Value = Left(NewValue, MaxLength);
	Value2 = NewValue2;
	CaretOffset = Len(Value);
	offset = 0.0000000;
	// End:0x4E
	if((!bHistory))
	{
		OldValue = Value;		
	}
	else
	{
		// End:0xE4
		if((!noUpdateHistory))
		{
			// End:0xD9
			if((Value != ""))
			{
				CurrentHistory = UWindowEditBoxHistory(HistoryList.Insert(Class'UWindow.UWindowEditBoxHistory'));
				CurrentHistory.HistoryText = Value;
				// End:0xD9
				if(bShowLog)
				{
					Log(("Set value CurrentHistory.HistoryText" @ CurrentHistory.HistoryText));
				}
			}
			CurrentHistory = HistoryList;
		}
	}
	Notify(1);
	return;
}

function Clear()
{
	CaretOffset = 0;
	Value = "";
	Value2 = "";
	bAllSelected = false;
	// End:0x33
	if(bDelayedNotify)
	{
		bChangePending = true;		
	}
	else
	{
		Notify(1);
	}
	return;
}

//This is the default function for enabling editing
function SelectAll()
{
	// End:0x7A
	if(bShowLog)
	{
		Log(((((((("SelectAll Begin: bcanedit" @ string(bCanEdit)) @ "m_CurrentlyEditing") @ string(m_CurrentlyEditing)) @ "value") @ Value) @ "bAllSelected") @ string(bAllSelected)));
	}
	// End:0x91
	if(bCanEdit)
	{
		m_CurrentlyEditing = true;
		SetAcceptsFocus();
	}
	// End:0xB9
	if((Value != ""))
	{
		CaretOffset = Len(Value);
		bAllSelected = (!bAllSelected);
	}
	// End:0x131
	if(bShowLog)
	{
		Log(((((((("SelectAll End: bcanedit" @ string(bCanEdit)) @ "m_CurrentlyEditing") @ string(m_CurrentlyEditing)) @ "value") @ Value) @ "bAllSelected") @ string(bAllSelected)));
	}
	return;
}

function string GetValue()
{
	return Value;
	return;
}

function string GetValue2()
{
	return Value2;
	return;
}

function Notify(byte E)
{
	// End:0x22
	if((NotifyOwner != none))
	{
		NotifyOwner.Notify(E);		
	}
	else
	{
		super.Notify(E);
	}
	return;
}

function InsertText(string Text)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x39 [Loop If]
	if((i < Len(Text)))
	{
		Insert(byte(Asc(Mid(Text, i, 1))));
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

// Inserts a character at the current caret position
function bool Insert(byte C)
{
	local string NewValue;

	NewValue = ((Left(Value, CaretOffset) $ Chr(int(C))) $ Mid(Value, CaretOffset));
	// End:0x3E
	if((Len(NewValue) > MaxLength))
	{
		return false;
	}
	(CaretOffset++);
	Value = NewValue;
	// End:0x64
	if(bDelayedNotify)
	{
		bChangePending = true;		
	}
	else
	{
		Notify(1);
	}
	return true;
	return;
}

function bool Backspace()
{
	local string NewValue;

	// End:0x0D
	if((CaretOffset == 0))
	{
		return false;
	}
	NewValue = (Left(Value, (CaretOffset - 1)) $ Mid(Value, CaretOffset));
	(CaretOffset--);
	Value = NewValue;
	// End:0x56
	if(bDelayedNotify)
	{
		bChangePending = true;		
	}
	else
	{
		Notify(1);
	}
	return true;
	return;
}

function bool Delete()
{
	local string NewValue;

	// End:0x13
	if((CaretOffset == Len(Value)))
	{
		return false;
	}
	NewValue = (Left(Value, CaretOffset) $ Mid(Value, (CaretOffset + 1)));
	Value = NewValue;
	Notify(1);
	return true;
	return;
}

function bool WordLeft()
{
	J0x00:
	// End:0x2F [Loop If]
	if(((CaretOffset > 0) && (Mid(Value, (CaretOffset - 1), 1) == " ")))
	{
		(CaretOffset--);
		// [Loop Continue]
		goto J0x00;
	}
	J0x2F:

	// End:0x5E [Loop If]
	if(((CaretOffset > 0) && (Mid(Value, (CaretOffset - 1), 1) != " ")))
	{
		(CaretOffset--);
		// [Loop Continue]
		goto J0x2F;
	}
	LastDrawTime = GetTime();
	bShowCaret = true;
	return true;
	return;
}

function bool MoveLeft()
{
	// End:0x0D
	if((CaretOffset == 0))
	{
		return false;
	}
	(CaretOffset--);
	LastDrawTime = GetTime();
	bShowCaret = true;
	return true;
	return;
}

function bool MoveRight()
{
	// End:0x13
	if((CaretOffset == Len(Value)))
	{
		return false;
	}
	(CaretOffset++);
	LastDrawTime = GetTime();
	bShowCaret = true;
	return true;
	return;
}

function bool WordRight()
{
	J0x00:
	// End:0x32 [Loop If]
	if(((CaretOffset < Len(Value)) && (Mid(Value, CaretOffset, 1) != " ")))
	{
		(CaretOffset++);
		// [Loop Continue]
		goto J0x00;
	}
	J0x32:

	// End:0x64 [Loop If]
	if(((CaretOffset < Len(Value)) && (Mid(Value, CaretOffset, 1) == " ")))
	{
		(CaretOffset++);
		// [Loop Continue]
		goto J0x32;
	}
	LastDrawTime = GetTime();
	bShowCaret = true;
	return true;
	return;
}

function bool MoveHome()
{
	CaretOffset = 0;
	LastDrawTime = GetTime();
	bShowCaret = true;
	return true;
	return;
}

function bool MoveEnd()
{
	CaretOffset = Len(Value);
	LastDrawTime = GetTime();
	bShowCaret = true;
	return true;
	return;
}

function EditCopy()
{
	// End:0x36
	if(((bAllSelected || (!bCanEdit)) && m_CurrentlyEditing))
	{
		GetPlayerOwner().CopyToClipboard(Value);
	}
	return;
}

function EditPaste()
{
	// End:0x39
	if((bCanEdit && m_CurrentlyEditing))
	{
		// End:0x23
		if(bAllSelected)
		{
			Clear();
		}
		InsertText(GetPlayerOwner().PasteFromClipboard());
	}
	return;
}

function EditCut()
{
	// End:0x43
	if((bCanEdit && m_CurrentlyEditing))
	{
		// End:0x40
		if(bAllSelected)
		{
			GetPlayerOwner().CopyToClipboard(Value);
			bAllSelected = false;
			Clear();
		}		
	}
	else
	{
		EditCopy();
	}
	return;
}

function KeyType(int Key, float MouseX, float MouseY)
{
	// End:0x6D
	if(bShowLog)
	{
		Log(((((("UWindowEditBox::KeyType bCanEdit" @ string(bCanEdit)) @ "bKeyDown") @ string(bKeyDown)) @ "m_CurrentlyEditing") @ string(m_CurrentlyEditing)));
	}
	// End:0x10B
	if(((bCanEdit && bKeyDown) && m_CurrentlyEditing))
	{
		// End:0x10B
		if((!bControlDown))
		{
			// End:0xA6
			if(bAllSelected)
			{
				Clear();
			}
			bAllSelected = false;
			// End:0xE1
			if(bNumericOnly)
			{
				// End:0xDE
				if(((Key >= 48) && (Key <= 57)))
				{
					Insert(byte(Key));
				}				
			}
			else
			{
				// End:0x10B
				if(((Key >= 32) && (Key < 256)))
				{
					Insert(byte(Key));
				}
			}
		}
	}
	return;
}

function KeyUp(int Key, float X, float Y)
{
	bKeyDown = false;
	switch(Key)
	{
		// End:0x33
		case int(Root.Console.17):
			bControlDown = false;
			// End:0x5A
			break;
		// End:0x57
		case int(Root.Console.16):
			bShiftDown = false;
			// End:0x5A
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

function KeyDown(int Key, float X, float Y)
{
	bKeyDown = true;
	switch(Key)
	{
		// End:0x33
		case int(Root.Console.17):
			bControlDown = true;
			// End:0x6D3
			break;
		// End:0x57
		case int(Root.Console.16):
			bShiftDown = true;
			// End:0x6D3
			break;
		// End:0x191
		case int(Root.Console.27):
			// End:0x18E
			if((bCanEdit && m_CurrentlyEditing))
			{
				// End:0x9F
				if(bShowLog)
				{
					Log("Escape pressed");
				}
				// End:0xBB
				if((!bHistory))
				{
					SetValue(OldValue, "", true);					
				}
				else
				{
					// End:0x182
					if(((CurrentHistory != none) && (CurrentHistory.Next != none)))
					{
						// End:0x113
						if(bShowLog)
						{
							__NFUN_231__(__NFUN_168__("CurrentHistory.HistoryText", CurrentHistory.HistoryText));
						}
						// End:0x15D
						if(bShowLog)
						{
							__NFUN_231__(__NFUN_168__("CurrentHistory.Next.HistoryText", UWindowEditBoxHistory(CurrentHistory.Next).HistoryText));
						}
						SetValue(UWindowEditBoxHistory(CurrentHistory.Next).HistoryText, "", true);
					}
				}
				MoveEnd();
				DropSelection();
			}
			// End:0x6D3
			break;
		// End:0x279
		case int(Root.Console.13):
			// End:0x276
			if(__NFUN_130__(bCanEdit, m_CurrentlyEditing))
			{
				// End:0x1D7
				if(__NFUN_129__(bHistory))
				{
					OldValue = Value;					
				}
				else
				{
					// End:0x257
					if(__NFUN_123__(Value, ""))
					{
						CurrentHistory = UWindowEditBoxHistory(HistoryList.Insert(Class'UWindow.UWindowEditBoxHistory'));
						CurrentHistory.HistoryText = Value;
						// End:0x257
						if(bShowLog)
						{
							__NFUN_231__(__NFUN_168__("Set value CurrentHistory.HistoryText", CurrentHistory.HistoryText));
						}
					}
					CurrentHistory = HistoryList;
				}
				MoveEnd();
				DropSelection();
				Notify(7);
			}
			// End:0x6D3
			break;
		// End:0x2A6
		case int(Root.Console.236):
			// End:0x2A3
			if(bCanEdit)
			{
				Notify(14);
			}
			// End:0x6D3
			break;
		// End:0x2D3
		case int(Root.Console.237):
			// End:0x2D0
			if(bCanEdit)
			{
				Notify(15);
			}
			// End:0x6D3
			break;
		// End:0x323
		case int(Root.Console.39):
			// End:0x320
			if(__NFUN_130__(bCanEdit, m_CurrentlyEditing))
			{
				// End:0x312
				if(bControlDown)
				{
					WordRight();					
				}
				else
				{
					MoveRight();
				}
				bAllSelected = false;
			}
			// End:0x6D3
			break;
		// End:0x373
		case int(Root.Console.37):
			// End:0x370
			if(__NFUN_130__(bCanEdit, m_CurrentlyEditing))
			{
				// End:0x362
				if(bControlDown)
				{
					WordLeft();					
				}
				else
				{
					MoveLeft();
				}
				bAllSelected = false;
			}
			// End:0x6D3
			break;
		// End:0x40D
		case int(Root.Console.38):
			// End:0x40A
			if(__NFUN_130__(__NFUN_130__(bCanEdit, bHistory), m_CurrentlyEditing))
			{
				bAllSelected = false;
				// End:0x40A
				if(__NFUN_130__(__NFUN_119__(CurrentHistory, none), __NFUN_119__(CurrentHistory.Next, none)))
				{
					CurrentHistory = UWindowEditBoxHistory(CurrentHistory.Next);
					SetValue(CurrentHistory.HistoryText, "", true);
					MoveEnd();
				}
			}
			// End:0x6D3
			break;
		// End:0x4A7
		case int(Root.Console.40):
			// End:0x4A4
			if(__NFUN_130__(__NFUN_130__(bCanEdit, bHistory), m_CurrentlyEditing))
			{
				bAllSelected = false;
				// End:0x4A4
				if(__NFUN_130__(__NFUN_119__(CurrentHistory, none), __NFUN_119__(CurrentHistory.Prev, none)))
				{
					CurrentHistory = UWindowEditBoxHistory(CurrentHistory.Prev);
					SetValue(CurrentHistory.HistoryText, "", true);
					MoveEnd();
				}
			}
			// End:0x6D3
			break;
		// End:0x4E5
		case int(Root.Console.36):
			// End:0x4E2
			if(__NFUN_130__(bCanEdit, m_CurrentlyEditing))
			{
				MoveHome();
				bAllSelected = false;
			}
			// End:0x6D3
			break;
		// End:0x523
		case int(Root.Console.35):
			// End:0x520
			if(__NFUN_130__(bCanEdit, m_CurrentlyEditing))
			{
				MoveEnd();
				bAllSelected = false;
			}
			// End:0x6D3
			break;
		// End:0x573
		case int(Root.Console.8):
			// End:0x570
			if(__NFUN_130__(bCanEdit, m_CurrentlyEditing))
			{
				// End:0x562
				if(bAllSelected)
				{
					Clear();					
				}
				else
				{
					Backspace();
				}
				bAllSelected = false;
			}
			// End:0x6D3
			break;
		// End:0x5C3
		case int(Root.Console.46):
			// End:0x5C0
			if(__NFUN_130__(bCanEdit, m_CurrentlyEditing))
			{
				// End:0x5B2
				if(bAllSelected)
				{
					Clear();					
				}
				else
				{
					Delete();
				}
				bAllSelected = false;
			}
			// End:0x6D3
			break;
		// End:0x5DC
		case int(Root.Console.190):
		// End:0x60E
		case int(Root.Console.110):
			// End:0x60B
			if(bNumericFloat)
			{
				Insert(byte(__NFUN_237__(".")));
			}
			// End:0x6D3
			break;
		// End:0xFFFF
		default:
			// End:0x68F
			if(bControlDown)
			{
				// End:0x640
				if(__NFUN_132__(__NFUN_154__(Key, __NFUN_237__("c")), __NFUN_154__(Key, __NFUN_237__("C"))))
				{
					EditCopy();
				}
				// End:0x666
				if(__NFUN_132__(__NFUN_154__(Key, __NFUN_237__("v")), __NFUN_154__(Key, __NFUN_237__("V"))))
				{
					EditPaste();
				}
				// End:0x68C
				if(__NFUN_132__(__NFUN_154__(Key, __NFUN_237__("x")), __NFUN_154__(Key, __NFUN_237__("X"))))
				{
					EditCut();
				}				
			}
			else
			{
				// End:0x6BB
				if(__NFUN_119__(NotifyOwner, none))
				{
					NotifyOwner.KeyDown(Key, X, Y);					
				}
				else
				{
					super.KeyDown(Key, X, Y);
				}
			}
			// End:0x6D3
			break;
			break;
	}
	return;
}

function Click(float X, float Y)
{
	Notify(2);
	// End:0x2A
	if(bShowLog)
	{
		__NFUN_231__("UWindowEditBox::Click");
	}
	return;
}

function LMouseDown(float X, float Y)
{
	// End:0x27
	if(bShowLog)
	{
		__NFUN_231__("UWindowEditBox::LMouseDown");
	}
	super(UWindowWindow).LMouseDown(X, Y);
	// End:0x6C
	if(bShowLog)
	{
		__NFUN_231__("UWindowEditBox::LMouseDown ->SelectAll()");
	}
	SelectAll();
	Notify(10);
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local float W, H, TextY;

	C.Font = Root.Fonts[Font];
	TextColor = Root.Colors.BlueLight;
	// End:0x19B
	if(m_bUseNewPaint)
	{
		TextSize(C, Value, W, H);
		TextY = __NFUN_172__(__NFUN_175__(WinHeight, H), float(2));
		switch(Align)
		{
			// End:0xA9
			case 2:
				offset = __NFUN_172__(__NFUN_175__(__NFUN_175__(WinWidth, W), float(14)), float(2));
				// End:0xBF
				break;
			// End:0xFFFF
			default:
				offset = __NFUN_174__(offset, float(1));
				// End:0xBF
				break;
				break;
		}
		C.__NFUN_2626__(TextColor.R, TextColor.G, TextColor.B);
		// End:0x17E
		if(__NFUN_130__(m_CurrentlyEditing, bAllSelected))
		{
			DrawStretchedTexture(C, offset, TextY, W, H, Texture'UWindow.WhiteTexture');
			C.__NFUN_2626__(byte(__NFUN_157__(255, int(C.DrawColor.R))), byte(__NFUN_157__(255, int(C.DrawColor.G))), byte(__NFUN_157__(255, int(C.DrawColor.B))));
		}
		ClipText(C, offset, TextY, Value);		
	}
	else
	{
		TextSize(C, "A", W, H);
		TextY = __NFUN_172__(__NFUN_175__(WinHeight, H), float(2));
		TextSize(C, __NFUN_128__(Value, CaretOffset), W, H);
		// End:0x20F
		if(__NFUN_176__(__NFUN_174__(W, offset), float(0)))
		{
			offset = __NFUN_169__(W);
		}
		// End:0x25B
		if(__NFUN_177__(__NFUN_174__(W, offset), __NFUN_175__(WinWidth, float(2))))
		{
			offset = __NFUN_175__(__NFUN_175__(WinWidth, float(2)), W);
			// End:0x25B
			if(__NFUN_177__(offset, float(0)))
			{
				offset = 0.0000000;
			}
		}
		C.__NFUN_2626__(TextColor.R, TextColor.G, TextColor.B);
		// End:0x31F
		if(__NFUN_130__(m_CurrentlyEditing, bAllSelected))
		{
			DrawStretchedTexture(C, __NFUN_174__(offset, float(1)), TextY, W, H, Texture'UWindow.WhiteTexture');
			C.__NFUN_2626__(byte(__NFUN_157__(255, int(C.DrawColor.R))), byte(__NFUN_157__(255, int(C.DrawColor.G))), byte(__NFUN_157__(255, int(C.DrawColor.B))));
		}
		ClipText(C, __NFUN_174__(offset, float(1)), TextY, Value);
	}
	// End:0x36E
	if(__NFUN_132__(__NFUN_132__(__NFUN_129__(m_CurrentlyEditing), __NFUN_129__(bHasKeyboardFocus)), __NFUN_129__(bCanEdit)))
	{
		bShowCaret = false;		
	}
	else
	{
		// End:0x3B2
		if(__NFUN_132__(__NFUN_177__(GetTime(), __NFUN_174__(LastDrawTime, 0.3000000)), __NFUN_176__(GetTime(), LastDrawTime)))
		{
			LastDrawTime = GetTime();
			bShowCaret = __NFUN_129__(bShowCaret);
		}
	}
	// End:0x3DF
	if(bShowCaret)
	{
		ClipText(C, __NFUN_175__(__NFUN_174__(offset, W), float(1)), TextY, "|");
	}
	// End:0x3F3
	if(m_bDrawEditBorders)
	{
		DrawSimpleBorder(C);
	}
	return;
}

function Close(optional bool bByParent)
{
	DropSelection();
	super(UWindowWindow).Close(bByParent);
	return;
}

function FocusWindow()
{
	super(UWindowWindow).FocusWindow();
	// End:0x2C
	if(bShowLog)
	{
		__NFUN_231__("FocusWindow ->SelectAll()");
	}
	// End:0x3D
	if(__NFUN_129__(m_CurrentlyEditing))
	{
		SelectAll();
	}
	return;
}

function FocusOtherWindow(UWindowWindow W)
{
	// End:0x1D
	if(bShowLog)
	{
		__NFUN_231__("FocusOtherWindow");
	}
	DropSelection();
	// End:0x45
	if(__NFUN_119__(NotifyOwner, none))
	{
		NotifyOwner.FocusOtherWindow(W);		
	}
	else
	{
		super(UWindowWindow).FocusOtherWindow(W);
	}
	return;
}

function DoubleClick(float X, float Y)
{
	super(UWindowWindow).DoubleClick(X, Y);
	// End:0x36
	if(bShowLog)
	{
		__NFUN_231__("DoubleClick ->SelectAll()");
	}
	SelectAll();
	return;
}

function KeyFocusEnter()
{
	// End:0x2A
	if(bShowLog)
	{
		__NFUN_231__("UWindowEditBox::KeyFocusEnter");
	}
	// End:0x6E
	if(__NFUN_130__(bSelectOnFocus, __NFUN_129__(bHasKeyboardFocus)))
	{
		// End:0x68
		if(bShowLog)
		{
			__NFUN_231__("KeyFocusEnter ->SelectAll()");
		}
		SelectAll();
	}
	super.KeyFocusEnter();
	return;
}

function KeyFocusExit()
{
	// End:0x19
	if(bShowLog)
	{
		__NFUN_231__("KeyFocusExit");
	}
	// End:0xD1
	if(__NFUN_130__(bCanEdit, m_CurrentlyEditing))
	{
		// End:0x46
		if(__NFUN_129__(bHistory))
		{
			OldValue = Value;			
		}
		else
		{
			// End:0xC6
			if(__NFUN_123__(Value, ""))
			{
				CurrentHistory = UWindowEditBoxHistory(HistoryList.Insert(Class'UWindow.UWindowEditBoxHistory'));
				CurrentHistory.HistoryText = Value;
				// End:0xC6
				if(bShowLog)
				{
					__NFUN_231__(__NFUN_168__("Set value CurrentHistory.HistoryText", CurrentHistory.HistoryText));
				}
			}
			CurrentHistory = HistoryList;
		}
	}
	DropSelection();
	super.KeyFocusExit();
	return;
}

function DropSelection()
{
	// End:0x22
	if(m_CurrentlyEditing)
	{
		// End:0x22
		if(bChangePending)
		{
			bChangePending = false;
			Notify(1);
		}
	}
	bAllSelected = false;
	m_CurrentlyEditing = false;
	bKeyDown = false;
	MoveHome();
	CancelAcceptsFocus();
	return;
}

function MouseEnter()
{
	super.MouseEnter();
	m_bMouseOn = true;
	return;
}

function MouseLeave()
{
	super.MouseLeave();
	m_bMouseOn = false;
	return;
}

defaultproperties
{
	MaxLength=255
	bCanEdit=true
}
