//=============================================================================
// UWindowEditBox - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// UWindowEditBox - simple edit box, for use in other controls such as 
// UWindowComboxBoxControl, UWindowEditBoxControl etc.
class UWindowEditBox extends UWindowDialogControl;

var int CaretOffset;    // index into Value where the next typed character will be inserted
var int MaxLength;      // hard cap on the number of characters Value may hold (default 255)
var bool bShowCaret;    // true when the blinking cursor pipe '|' should be drawn this frame
var bool bNumericOnly;  // when true, only digit characters '0'-'9' are accepted
var bool bNumericFloat; // when true, also allows a decimal point (alongside bNumericOnly digits)
var bool bCanEdit;      // master switch: if false, no keyboard input is processed at all
var bool bAllSelected;  // entire text is highlighted (painted inverted); next keypress replaces it
var bool bDelayedNotify;  // batch mode: suppress DE_Change notifications until editing ends
var bool bChangePending;  // set while bDelayedNotify is active and the value has been modified
var bool bControlDown;  // mirrors the live state of the Ctrl key
var bool bShiftDown;    // mirrors the live state of the Shift key (tracked but not yet used for range selection)
var bool bHistory;      // command-history mode: Up/Down arrows cycle through past submitted values
var bool bKeyDown;      // true between KeyDown and KeyUp; guards KeyType so inserts only fire for held keys
var bool m_bMouseOn;  // the mouse is over the window edit box
var bool m_bDrawEditBorders;  // when true, DrawSimpleBorder outlines the widget each frame
var bool m_bUseNewPaint;      // selects alternate paint path: centred/aligned text rather than scrolling text
var bool m_CurrentlyEditing;  // true once the box has accepted focus and is ready to receive keystrokes
var bool bSelectOnFocus;      // if true, SelectAll() fires automatically when keyboard focus arrives
var bool bPassword;           // password masking flag (tracked but masking not implemented in this version)
var bool m_bDrawEditBoxBG;  // draw the edit box background
var bool bShowLog;            // verbose debug logging via Log(); disable in release builds
var float LastDrawTime;       // timestamp of last caret blink-toggle, drives the 0.3 s blink interval
var float offset;             // horizontal scroll offset in pixels; negative = text scrolled left so caret stays visible
var UWindowDialogControl NotifyOwner; // redirect Notify() here instead of bubbling up (used by composite controls)
var UWindowEditBoxHistory HistoryList;    // sentinel head of the doubly-linked command history ring
var UWindowEditBoxHistory CurrentHistory; // current position in HistoryList; Up = newer, Down = older
var string Value;    // the text currently shown and editable in this box
var string Value2;   // secondary opaque value (e.g. an ID paired with displayed text in combo boxes)
var string OldValue; // snapshot of Value taken at last commit; Escape restores back to this

// Initialise LastDrawTime so the caret blink timer starts in a known state on first paint.
function Created()
{
	super.Created();
	LastDrawTime = GetTime(); // seed the blink timer; without this the first blink interval is undefined
	return;
}

// Enable or disable command-history navigation (Up/Down arrow key cycling through past entries).
// Lazily creates the sentinel node when first enabled; frees it when disabled.
function SetHistory(bool bInHistory)
{
	bHistory = bInHistory;
	// End:0x4B
	if((bHistory && (HistoryList == none)))
	{
		// Allocate the sentinel that anchors the doubly-linked history ring.
		HistoryList = new (none) Class'UWindow.UWindowEditBoxHistory';
		HistoryList.SetupSentinel();
		CurrentHistory = none; // no entry selected yet; the next Up press will move to the most-recent entry		
	}
	else
	{
		// End:0x71
		if(((!bHistory) && (HistoryList != none)))
		{
			// Release the history ring; GC will clean it up.
			HistoryList = none;
			CurrentHistory = none;
		}
	}
	return;
}

// Toggle whether the user can type into this box. Read-only labels set this to false.
function SetEditable(bool bEditable)
{
	bCanEdit = bEditable;
	return;
}

// Programmatically set the displayed text. Clamps to MaxLength, resets the caret to the end,
// clears the scroll offset, optionally pushes to history, and fires DE_Change (1).
// noUpdateHistory=true is used when navigating history entries so we don't create recursive entries.
function SetValue(string NewValue, optional string NewValue2, optional bool noUpdateHistory)
{
	Value = Left(NewValue, MaxLength); // enforce the character cap at assignment time
	Value2 = NewValue2;
	CaretOffset = Len(Value); // place caret at the end of the new text
	offset = 0.0000000;       // reset horizontal scroll so the start of the text is visible
	// End:0x4E
	if((!bHistory))
	{
		// Without history, OldValue is updated immediately so Escape can revert to this value.
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
				// Push the new value onto the front of the history ring.
				CurrentHistory = UWindowEditBoxHistory(HistoryList.Insert(Class'UWindow.UWindowEditBoxHistory'));
				CurrentHistory.HistoryText = Value;
				// End:0xD9
				if(bShowLog)
				{
					Log(("Set value CurrentHistory.HistoryText" @ CurrentHistory.HistoryText));
				}
			}
			// Reset position to sentinel so the next Up press navigates to the newest entry.
			CurrentHistory = HistoryList;
		}
	}
	Notify(1); // DE_Change: notify listeners that the value has changed
	return;
}

// Erase all text and reset internal state. Used when the user types while bAllSelected is set,
// or explicitly by Ctrl+X / Backspace / Delete with a full selection active.
function Clear()
{
	CaretOffset = 0;
	Value = "";
	Value2 = "";
	bAllSelected = false;
	// End:0x33
	if(bDelayedNotify)
	{
		// In delayed mode, defer the notification until DropSelection() fires.
		bChangePending = true;		
	}
	else
	{
		Notify(1); // DE_Change
	}
	return;
}

//This is the default function for enabling editing
// Despite the name this is also the primary entry point for activating the box for keyboard input.
// Clicking, double-clicking, and receiving focus all route through here.
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
		CaretOffset = Len(Value); // put caret at the end so the highlight covers the full string
		bAllSelected = (!bAllSelected); // toggle: first call selects all, second call deselects
	}
	// End:0x131
	if(bShowLog)
	{
		Log(((((((("SelectAll End: bcanedit" @ string(bCanEdit)) @ "m_CurrentlyEditing") @ string(m_CurrentlyEditing)) @ "value") @ Value) @ "bAllSelected") @ string(bAllSelected)));
	}
	return;
}

// Return the primary text currently held in the edit box.
function string GetValue()
{
	return Value;
	return;
}

// Return the secondary (opaque) value associated with the displayed text (e.g. an ID in a combo box).
function string GetValue2()
{
	return Value2;
	return;
}

// Forward notification events. When embedded in a composite control (e.g. UWindowEditBoxControl),
// NotifyOwner intercepts events instead of them bubbling up the normal window hierarchy.
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

// Insert each character of Text at the current caret position, one at a time.
// Feeding through Insert() ensures MaxLength is enforced per-character during paste.
function InsertText(string Text)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x39 [Loop If]
	if((i < Len(Text)))
	{
		// Asc() converts the character to its byte value; Insert() will reject if over MaxLength.
		Insert(byte(Asc(Mid(Text, i, 1))));
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

// Insert a single ASCII byte C at CaretOffset, splitting Value around that position.
// Returns false (and makes no change) if inserting would exceed MaxLength.
// The MaxLength check prevents over-long pastes even when called from the InsertText() loop.
function bool Insert(byte C)
{
	local string NewValue;

	// Build the new string: chars before caret + new char + chars from caret onward.
	NewValue = ((Left(Value, CaretOffset) $ Chr(int(C))) $ Mid(Value, CaretOffset));
	// End:0x3E
	if((Len(NewValue) > MaxLength))
	{
		return false; // would exceed cap; InsertText() simply stops inserting remaining characters
	}
	(CaretOffset++); // advance caret past the newly inserted character
	Value = NewValue;
	// End:0x64
	if(bDelayedNotify)
	{
		bChangePending = true;		
	}
	else
	{
		Notify(1); // DE_Change
	}
	return true;
	return;
}

// Delete the character immediately to the LEFT of the caret (classic Backspace behaviour).
// Returns false if the caret is already at position 0 (nothing to delete).
function bool Backspace()
{
	local string NewValue;

	// End:0x0D
	if((CaretOffset == 0))
	{
		return false; // already at start; nothing to erase
	}
	// Remove the character at CaretOffset-1 and move the caret back one position.
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
		Notify(1); // DE_Change
	}
	return true;
	return;
}

// Delete the character immediately to the RIGHT of the caret (Del key behaviour).
// The caret position does not change. Returns false if already at the end of the string.
// Note: unlike Backspace(), this always fires DE_Change immediately, ignoring bDelayedNotify.
function bool Delete()
{
	local string NewValue;

	// End:0x13
	if((CaretOffset == Len(Value)))
	{
		return false; // caret is past the last character; nothing to delete
	}
	// Splice out the character at CaretOffset without changing CaretOffset.
	NewValue = (Left(Value, CaretOffset) $ Mid(Value, (CaretOffset + 1)));
	Value = NewValue;
	Notify(1); // DE_Change
	return true;
	return;
}

// Move caret one word to the left (Ctrl+Left).
// Phase 1: skip any spaces immediately to the left of the caret (trailing whitespace of gap).
// Phase 2: skip non-space characters to land at the start of the preceding word.
function bool WordLeft()
{
	J0x00:
	// End:0x2F [Loop If]
	if(((CaretOffset > 0) && (Mid(Value, (CaretOffset - 1), 1) == " ")))
	{
		(CaretOffset--); // skip trailing whitespace of the previous word
		// [Loop Continue]
		goto J0x00;
	}
	J0x2F:

	// End:0x5E [Loop If]
	if(((CaretOffset > 0) && (Mid(Value, (CaretOffset - 1), 1) != " ")))
	{
		(CaretOffset--); // skip the word characters themselves
		// [Loop Continue]
		goto J0x2F;
	}
	// Reset blink timer so the cursor is immediately visible after movement.
	LastDrawTime = GetTime();
	bShowCaret = true;
	return true;
	return;
}

// Move caret one character to the left. Returns false if already at the start of the string.
function bool MoveLeft()
{
	// End:0x0D
	if((CaretOffset == 0))
	{
		return false;
	}
	(CaretOffset--);
	LastDrawTime = GetTime(); // reset blink timer so cursor is immediately visible after movement
	bShowCaret = true;
	return true;
	return;
}

// Move caret one character to the right. Returns false if already at the end of the string.
function bool MoveRight()
{
	// End:0x13
	if((CaretOffset == Len(Value)))
	{
		return false;
	}
	(CaretOffset++);
	LastDrawTime = GetTime(); // reset blink timer so cursor is immediately visible after movement
	bShowCaret = true;
	return true;
	return;
}

// Move caret one word to the right (Ctrl+Right).
// Phase 1: skip non-space characters (the body of the current word).
// Phase 2: skip spaces to land at the start of the next word.
function bool WordRight()
{
	J0x00:
	// End:0x32 [Loop If]
	if(((CaretOffset < Len(Value)) && (Mid(Value, CaretOffset, 1) != " ")))
	{
		(CaretOffset++); // advance through word characters
		// [Loop Continue]
		goto J0x00;
	}
	J0x32:

	// End:0x64 [Loop If]
	if(((CaretOffset < Len(Value)) && (Mid(Value, CaretOffset, 1) == " ")))
	{
		(CaretOffset++); // skip inter-word spaces
		// [Loop Continue]
		goto J0x32;
	}
	LastDrawTime = GetTime(); // reset blink timer so cursor is immediately visible
	bShowCaret = true;
	return true;
	return;
}

// Jump caret to the very beginning of the string (Home key).
function bool MoveHome()
{
	CaretOffset = 0;
	LastDrawTime = GetTime(); // reset blink so cursor is visible immediately
	bShowCaret = true;
	return true;
	return;
}

// Jump caret to the very end of the string (End key).
function bool MoveEnd()
{
	CaretOffset = Len(Value);
	LastDrawTime = GetTime(); // reset blink so cursor is visible immediately
	bShowCaret = true;
	return true;
	return;
}

// Copy the current value to the system clipboard (Ctrl+C).
// Only fires when all text is selected, or when the box is read-only (and currently focused).
function EditCopy()
{
	// End:0x36
	if(((bAllSelected || (!bCanEdit)) && m_CurrentlyEditing))
	{
		GetPlayerOwner().CopyToClipboard(Value);
	}
	return;
}

// Paste from the system clipboard at the current caret position (Ctrl+V).
// If all text is selected, it is cleared first so the paste replaces it entirely.
// InsertText feeds characters one at a time so MaxLength is enforced on each insertion.
function EditPaste()
{
	// End:0x39
	if((bCanEdit && m_CurrentlyEditing))
	{
		// End:0x23
		if(bAllSelected)
		{
			Clear(); // replace-on-paste: wipe existing text before inserting clipboard content
		}
		InsertText(GetPlayerOwner().PasteFromClipboard());
	}
	return;
}

// Cut selected text to the clipboard (Ctrl+X).
// Only removes text when bAllSelected is set — there is no partial selection in this widget.
// Falls back to EditCopy() when the box is not editable or not active (read-only safe copy).
function EditCut()
{
	// End:0x43
	if((bCanEdit && m_CurrentlyEditing))
	{
		// End:0x40
		if(bAllSelected)
		{
			GetPlayerOwner().CopyToClipboard(Value); // copy before erasing
			bAllSelected = false;
			Clear(); // erase text from the box
		}		
	}
	else
	{
		EditCopy(); // read-only fallback: copy without cutting
	}
	return;
}

// Receives printable character events (fired by the engine AFTER KeyDown, for typed glyphs).
// bKeyDown guard prevents spurious inserts; bControlDown guard prevents Ctrl+letter
// being treated as printable input (those shortcuts are handled in KeyDown's default case).
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
			// Typing while all-selected replaces the entire content with the new character.
			// End:0xA6
			if(bAllSelected)
			{
				Clear(); // wipe current text; the typed character is inserted below
			}
			bAllSelected = false;
			// End:0xE1
			if(bNumericOnly)
			{
				// 0x30='0', 0x39='9' — accept only decimal digit characters
				// End:0xDE
				if(((Key >= 48) && (Key <= 57)))
				{
					Insert(byte(Key));
				}				
			}
			else
			{
				// 0x20=space, 0xFF=highest Latin-1 character — accept all printable ASCII/Latin-1
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

// Track key-release events to keep modifier-key state mirrors up to date.
// bKeyDown is cleared unconditionally so KeyType() won't fire after the key is released.
function KeyUp(int Key, float X, float Y)
{
	bKeyDown = false;
	switch(Key)
	{
		// End:0x33
		case int(Root.Console.17): // VK_CONTROL (17)
			bControlDown = false;
			// End:0x5A
			break;
		// End:0x57
		case int(Root.Console.16): // VK_SHIFT (16)
			bShiftDown = false;
			// End:0x5A
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

// Handle all special / control keys. Printable characters are handled by KeyType() instead.
// bKeyDown is set here so KeyType() (fired next in the engine event chain) knows a key is held.
function KeyDown(int Key, float X, float Y)
{
	bKeyDown = true;
	switch(Key)
	{
		// End:0x33
		case int(Root.Console.17): // VK_CONTROL (17) — track Ctrl for Ctrl+C/V/X and word-movement
			bControlDown = true;
			// End:0x6D3
			break;
		// End:0x57
		case int(Root.Console.16): // VK_SHIFT (16) — tracked but not yet used for range selection
			bShiftDown = true;
			// End:0x6D3
			break;
		// End:0x191
		case int(Root.Console.27): // VK_ESCAPE (27) — cancel edits, revert to OldValue or prior history
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
					// No history: restore the snapshot taken when editing last began.
					SetValue(OldValue, "", true);					
				}
				else
				{
					// End:0x182
					if(((CurrentHistory != none) && (CurrentHistory.Next != none)))
					{
						// History mode: walk one step toward newer entries (Next = toward head).
						// End:0x113
						if(bShowLog)
						{
							Log(("CurrentHistory.HistoryText" @ CurrentHistory.HistoryText));
						}
						// End:0x15D
						if(bShowLog)
						{
							Log(("CurrentHistory.Next.HistoryText" @ UWindowEditBoxHistory(CurrentHistory.Next).HistoryText));
						}
						SetValue(UWindowEditBoxHistory(CurrentHistory.Next).HistoryText, "", true);
					}
				}
				MoveEnd();
				DropSelection(); // exit editing mode, fire any pending change notification
			}
			// End:0x6D3
			break;
		// End:0x279
		case int(Root.Console.13): // VK_RETURN (13) — commit the current value
			// End:0x276
			if((bCanEdit && m_CurrentlyEditing))
			{
				// End:0x1D7
				if((!bHistory))
				{
					// Snapshot the value so Escape can revert to it next time.
					OldValue = Value;					
				}
				else
				{
					// Push a new history entry for the submitted value.
					// End:0x257
					if((Value != ""))
					{
						CurrentHistory = UWindowEditBoxHistory(HistoryList.Insert(Class'UWindow.UWindowEditBoxHistory'));
						CurrentHistory.HistoryText = Value;
						// End:0x257
						if(bShowLog)
						{
							Log(("Set value CurrentHistory.HistoryText" @ CurrentHistory.HistoryText));
						}
					}
					CurrentHistory = HistoryList; // reset cursor to sentinel so Up goes to newest
				}
				MoveEnd();
				DropSelection(); // exit editing mode
				Notify(7); // DE_EnterPressed (7): signal owning control that Enter was pressed
			}
			// End:0x6D3
			break;
		// End:0x2A6
		case int(Root.Console.236): // IK_MouseWheelUp (236) — scroll wheel up while focused
			// End:0x2A3
			if(bCanEdit)
			{
				Notify(14); // DE_WheelUpPressed (14)
			}
			// End:0x6D3
			break;
		// End:0x2D3
		case int(Root.Console.237): // IK_MouseWheelDown (237) — scroll wheel down while focused
			// End:0x2D0
			if(bCanEdit)
			{
				Notify(15); // DE_WheelDownPressed (15)
			}
			// End:0x6D3
			break;
		// End:0x323
		case int(Root.Console.39): // VK_RIGHT (39) — move caret right (or word-right with Ctrl)
			// End:0x320
			if((bCanEdit && m_CurrentlyEditing))
			{
				// End:0x312
				if(bControlDown)
				{
					WordRight(); // jump to start of next word					
				}
				else
				{
					MoveRight(); // single character step
				}
				bAllSelected = false; // any movement clears the whole-text selection
			}
			// End:0x6D3
			break;
		// End:0x373
		case int(Root.Console.37): // VK_LEFT (37) — move caret left (or word-left with Ctrl)
			// End:0x370
			if((bCanEdit && m_CurrentlyEditing))
			{
				// End:0x362
				if(bControlDown)
				{
					WordLeft(); // jump to start of previous word					
				}
				else
				{
					MoveLeft(); // single character step
				}
				bAllSelected = false; // any movement clears the whole-text selection
			}
			// End:0x6D3
			break;
		// End:0x40D
		case int(Root.Console.38): // VK_UP (38) — navigate to a newer history entry
			// End:0x40A
			if(((bCanEdit && bHistory) && m_CurrentlyEditing))
			{
				bAllSelected = false;
				// End:0x40A
				if(((CurrentHistory != none) && (CurrentHistory.Next != none)))
				{
					// Next = toward head (newer entries); Up arrow moves forward in history.
					CurrentHistory = UWindowEditBoxHistory(CurrentHistory.Next);
					SetValue(CurrentHistory.HistoryText, "", true);
					MoveEnd();
				}
			}
			// End:0x6D3
			break;
		// End:0x4A7
		case int(Root.Console.40): // VK_DOWN (40) — navigate to an older history entry
			// End:0x4A4
			if(((bCanEdit && bHistory) && m_CurrentlyEditing))
			{
				bAllSelected = false;
				// End:0x4A4
				if(((CurrentHistory != none) && (CurrentHistory.Prev != none)))
				{
					// Prev = toward tail (older entries); Down arrow moves back in history.
					CurrentHistory = UWindowEditBoxHistory(CurrentHistory.Prev);
					SetValue(CurrentHistory.HistoryText, "", true);
					MoveEnd();
				}
			}
			// End:0x6D3
			break;
		// End:0x4E5
		case int(Root.Console.36): // VK_HOME (36) — jump caret to start of text
			// End:0x4E2
			if((bCanEdit && m_CurrentlyEditing))
			{
				MoveHome();
				bAllSelected = false;
			}
			// End:0x6D3
			break;
		// End:0x523
		case int(Root.Console.35): // VK_END (35) — jump caret to end of text
			// End:0x520
			if((bCanEdit && m_CurrentlyEditing))
			{
				MoveEnd();
				bAllSelected = false;
			}
			// End:0x6D3
			break;
		// End:0x573
		case int(Root.Console.8): // VK_BACK (8) — Backspace: delete character to the left of caret
			// End:0x570
			if((bCanEdit && m_CurrentlyEditing))
			{
				// End:0x562
				if(bAllSelected)
				{
					// Backspace while all-selected clears everything (like typing replaces selection).
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
		case int(Root.Console.46): // VK_DELETE (46) — Delete: delete character to the right of caret
			// End:0x5C0
			if((bCanEdit && m_CurrentlyEditing))
			{
				// End:0x5B2
				if(bAllSelected)
				{
					// Delete while all-selected clears everything.
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
		case int(Root.Console.190): // VK_OEM_PERIOD (190) — period key on main keyboard
		// End:0x60E
		case int(Root.Console.110): // VK_DECIMAL (110) — period key on numeric keypad
			// End:0x60B
			if(bNumericFloat)
			{
				// Only insert '.' when floating-point input is explicitly enabled.
				Insert(byte(Asc(".")));
			}
			// End:0x6D3
			break;
		// End:0xFFFF
		default:
			// End:0x68F
			if(bControlDown)
			{
				// Ctrl+C / Ctrl+V / Ctrl+X — case-insensitive clipboard shortcuts.
				// End:0x640
				if(((Key == Asc("c")) || (Key == Asc("C"))))
				{
					EditCopy();
				}
				// End:0x666
				if(((Key == Asc("v")) || (Key == Asc("V"))))
				{
					EditPaste();
				}
				// End:0x68C
				if(((Key == Asc("x")) || (Key == Asc("X"))))
				{
					EditCut();
				}				
			}
			else
			{
				// Non-Ctrl keys not handled above: pass to NotifyOwner or up the hierarchy.
				// This allows parent controls to react to arrow keys etc. that the edit box ignores.
				// End:0x6BB
				if((NotifyOwner != none))
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

// Mouse click: fire DE_Click (2) so parent controls can react (e.g. close a dropdown).
function Click(float X, float Y)
{
	Notify(2); // DE_Click
	// End:0x2A
	if(bShowLog)
	{
		Log("UWindowEditBox::Click");
	}
	return;
}

// Left mouse button down: activate the box and select all text, then fire DE_LMouseDown (10).
// Calls super on UWindowWindow directly to bypass UWindowDialogControl's default LMouseDown.
function LMouseDown(float X, float Y)
{
	// End:0x27
	if(bShowLog)
	{
		Log("UWindowEditBox::LMouseDown");
	}
	super(UWindowWindow).LMouseDown(X, Y);
	// End:0x6C
	if(bShowLog)
	{
		Log("UWindowEditBox::LMouseDown ->SelectAll()");
	}
	SelectAll(); // enter editing mode; first keystroke will replace the selected text
	Notify(10); // DE_LMouseDown (10)
	return;
}

// Render the edit box each frame: text, optional selection highlight, blinking caret, optional border.
// Two paint paths exist:
//   m_bUseNewPaint=true  — centred/aligned layout, used by combo box dropdowns.
//   m_bUseNewPaint=false — classic scrolling layout; offset scrolls so the caret stays visible.
function Paint(Canvas C, float X, float Y)
{
	local float W, H, TextY;

	C.Font = Root.Fonts[Font];
	TextColor = Root.Colors.BlueLight;
	// End:0x19B
	if(m_bUseNewPaint)
	{
		// New paint path: measure full string width then centre/align the text block.
		TextSize(C, Value, W, H);
		TextY = ((WinHeight - H) / float(2)); // vertically centre text within the widget height
		switch(Align)
		{
			// End:0xA9
			case 2: // TA_Center
				// 14 pixels are reserved for the combo-box drop-down arrow button on the right.
				offset = (((WinWidth - W) - float(14)) / float(2));
				// End:0xBF
				break;
			// End:0xFFFF
			default:
				// Non-centred: drift offset by 1 each frame (legacy leftward scroll behaviour).
				offset = (offset + float(1));
				// End:0xBF
				break;
				break;
		}
		C.SetDrawColor(TextColor.R, TextColor.G, TextColor.B);
		// End:0x17E
		if((m_CurrentlyEditing && bAllSelected))
		{
			// Draw a white rectangle behind the text to create a selection highlight.
			DrawStretchedTexture(C, offset, TextY, W, H, Texture'UWindow.WhiteTexture');
			// XOR each channel with 0xFF to invert the draw colour so text is legible on white.
			C.SetDrawColor(byte((255 ^ int(C.DrawColor.R))), byte((255 ^ int(C.DrawColor.G))), byte((255 ^ int(C.DrawColor.B))));
		}
		ClipText(C, offset, TextY, Value);		
	}
	else
	{
		// Classic scrolling paint path.
		TextSize(C, "A", W, H); // measure a reference glyph for line height; W is discarded here
		TextY = ((WinHeight - H) / float(2)); // vertically centre
		// W now holds the pixel width of the substring up to the caret; used for scroll and caret placement.
		TextSize(C, Left(Value, CaretOffset), W, H);
		// End:0x20F
		if(((W + offset) < float(0)))
		{
			// Caret would be off the left edge; scroll right until caret is at x=0.
			offset = (-W);
		}
		// End:0x25B
		if(((W + offset) > (WinWidth - float(2))))
		{
			// Caret would be off the right edge; scroll left so caret sits 2 px from the right border.
			offset = ((WinWidth - float(2)) - W);
			// End:0x25B
			if((offset > float(0)))
			{
				offset = 0.0000000; // never allow a positive (rightward) offset; text always left-aligns
			}
		}
		C.SetDrawColor(TextColor.R, TextColor.G, TextColor.B);
		// End:0x31F
		if((m_CurrentlyEditing && bAllSelected))
		{
			// Selection highlight: white rect spans the pre-caret text width, then invert colour.
			DrawStretchedTexture(C, (offset + float(1)), TextY, W, H, Texture'UWindow.WhiteTexture');
			C.SetDrawColor(byte((255 ^ int(C.DrawColor.R))), byte((255 ^ int(C.DrawColor.G))), byte((255 ^ int(C.DrawColor.B))));
		}
		ClipText(C, (offset + float(1)), TextY, Value); // +1 gives a 1-pixel left inset from the border
	}
	// --- Caret blink logic ---
	// End:0x36E
	if((((!m_CurrentlyEditing) || (!bHasKeyboardFocus)) || (!bCanEdit)))
	{
		// Hide the caret whenever the box is not in an active, focused, editable state.
		bShowCaret = false;		
	}
	else
	{
		// Toggle caret visibility every 0.3 seconds.
		// The GetTime() < LastDrawTime branch handles the rare case of a game-time counter wrap.
		// End:0x3B2
		if(((GetTime() > (LastDrawTime + 0.3000000)) || (GetTime() < LastDrawTime)))
		{
			LastDrawTime = GetTime();
			bShowCaret = (!bShowCaret);
		}
	}
	// End:0x3DF
	if(bShowCaret)
	{
		// Draw the caret as a '|' glyph, offset 1 pixel left of the caret x to visually centre it
		// between characters (the pipe glyph itself has a small width).
		ClipText(C, ((offset + W) - float(1)), TextY, "|");
	}
	// End:0x3F3
	if(m_bDrawEditBorders)
	{
		DrawSimpleBorder(C); // optional thin border outline around the whole widget
	}
	return;
}

// On close, drop the selection state and fire any pending change notification before hiding.
function Close(optional bool bByParent)
{
	DropSelection();
	super(UWindowWindow).Close(bByParent); // call UWindowWindow directly; skip UWindowDialogControl.Close
	return;
}

// Called when this window gains mouse/input focus. Enter editing mode if not already active.
function FocusWindow()
{
	super(UWindowWindow).FocusWindow();
	// End:0x2C
	if(bShowLog)
	{
		Log("FocusWindow ->SelectAll()");
	}
	// End:0x3D
	if((!m_CurrentlyEditing))
	{
		SelectAll(); // select all text so the first keystroke replaces it
	}
	return;
}

// Focus has moved to another window; exit editing mode and propagate the focus-lost event.
function FocusOtherWindow(UWindowWindow W)
{
	// End:0x1D
	if(bShowLog)
	{
		Log("FocusOtherWindow");
	}
	DropSelection(); // commit any pending changes and clear editing state
	// End:0x45
	if((NotifyOwner != none))
	{
		NotifyOwner.FocusOtherWindow(W);		
	}
	else
	{
		super(UWindowWindow).FocusOtherWindow(W);
	}
	return;
}

// Double-click selects all text, identical to single-click (no word-selection logic here).
function DoubleClick(float X, float Y)
{
	super(UWindowWindow).DoubleClick(X, Y);
	// End:0x36
	if(bShowLog)
	{
		Log("DoubleClick ->SelectAll()");
	}
	SelectAll();
	return;
}

// Called when keyboard focus arrives (Tab / programmatic focus).
// If bSelectOnFocus is set, immediately select all text so typing replaces it.
// Note: bHasKeyboardFocus is checked BEFORE super sets it, so the condition detects first-entry.
function KeyFocusEnter()
{
	// End:0x2A
	if(bShowLog)
	{
		Log("UWindowEditBox::KeyFocusEnter");
	}
	// End:0x6E
	if((bSelectOnFocus && (!bHasKeyboardFocus)))
	{
		// End:0x68
		if(bShowLog)
		{
			Log("KeyFocusEnter ->SelectAll()");
		}
		SelectAll();
	}
	super.KeyFocusEnter();
	return;
}

// Called when keyboard focus leaves (Tab away or focus stolen by another window).
// Commits the current value to OldValue or history before exiting editing mode.
function KeyFocusExit()
{
	// End:0x19
	if(bShowLog)
	{
		Log("KeyFocusExit");
	}
	// End:0xD1
	if((bCanEdit && m_CurrentlyEditing))
	{
		// End:0x46
		if((!bHistory))
		{
			OldValue = Value; // save as revert point for the next editing session			
		}
		else
		{
			// End:0xC6
			if((Value != ""))
			{
				// Push to history on focus-exit so Tab-to-next-field still saves the entry.
				CurrentHistory = UWindowEditBoxHistory(HistoryList.Insert(Class'UWindow.UWindowEditBoxHistory'));
				CurrentHistory.HistoryText = Value;
				// End:0xC6
				if(bShowLog)
				{
					Log(("Set value CurrentHistory.HistoryText" @ CurrentHistory.HistoryText));
				}
			}
			CurrentHistory = HistoryList; // reset position to sentinel
		}
	}
	DropSelection();
	super.KeyFocusExit();
	return;
}

// Exit editing mode: fire any deferred change notification, clear selection, reset caret to start,
// and release keyboard focus ownership so the focus system can move on.
function DropSelection()
{
	// End:0x22
	if(m_CurrentlyEditing)
	{
		// End:0x22
		if(bChangePending)
		{
			// bDelayedNotify was active; now fire the single batched DE_Change notification.
			bChangePending = false;
			Notify(1); // DE_Change
		}
	}
	bAllSelected = false;
	m_CurrentlyEditing = false;
	bKeyDown = false;    // clear stale key state so it doesn't carry into the next focus session
	MoveHome();          // reset caret to 0 so text starts from the left when re-focused
	CancelAcceptsFocus(); // release keyboard focus so other controls can receive input
	return;
}

// Track hover state; used for potential visual feedback (e.g. border highlight on hover).
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
	MaxLength=255  // sensible default cap; callers can raise this as needed (e.g. chat input)
	bCanEdit=true  // boxes are editable by default; set false for read-only / display-only labels
}
