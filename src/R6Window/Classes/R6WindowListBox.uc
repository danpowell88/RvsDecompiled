//=============================================================================
// R6WindowListBox - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6WindowListBox.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowListBox extends UWindowListControl;

// Controls how corner decoration art interacts with scrollbar placement.
// No_Corners / No_Borders: scrollbar sits flush with the right edge of the control.
// Top_Corners / Bottom_Corners / All_Corners: scrollbar is inset by m_iListVPadding
// to leave room for the corner artwork drawn by the look-and-feel.
enum eCornerType
{
	No_Corners,                     // 0
	No_Borders,                     // 1
	Top_Corners,                    // 2
	Bottom_Corners,                 // 3
	All_Corners                     // 4
};

// NEW IN 1.60
var R6WindowListBox.eCornerType m_eCornerType;  // determines scrollbar inset and corner art style
var int m_iTotItemsDisplayed;  // the number of items displayed on the window
var bool m_bDragging;         // true while the user is drag-reordering a row with mouse held
var bool m_bCanDrag;          // allow drag-to-reorder within this list
var bool m_bCanDragExternal;  // allow dragging items out to another R6WindowListBox
var bool m_bActiveOverEffect; // when true, border color changes on mouse hover
var bool m_bIgnoreUserClicks;  // If you only want the code to determine selected elements
var bool m_bForceCaps;  // force to capital letter in draw item
var bool m_bSkipDrawBorders;  // skip border rendering (e.g. for borderless list panels)
var float m_fItemHeight;  // the size of each item
var float m_fSpaceBetItem;  // the space in between item
var float m_fDragY;  // last Y coord during drag; determines insert-before vs insert-after
var float m_fXItemOffset;  // the item X offset pos
var float m_fXItemRightPadding;  // Padding on the right of an item
var R6WindowVScrollbar m_VertSB;      // child vertical scrollbar window
var UWindowListBoxItem m_SelectedItem;  // currently selected row (single-selection model)
var Texture m_TIcon;  // where are the icon tex
var R6WindowListBox m_DoubleClickList;  // list to send items to on double-click
var UWindowWindow m_DoubleClickClient;  // on double click send info to this specific client
var Class<R6WindowVScrollbar> m_SBClass;  // scrollbar class to instantiate; subclasses can override
var Color m_vMouseOverWindow;  // the mouseover window border color
var Color m_vInitBorderColor;  // the initial border color (use setbordercolor fct)
var string m_szDefaultHelpText;  // help text to restore after tooltip overrides

// Creates the vertical scrollbar as a child window aligned to the right edge of this control.
// Called once by the UWindow framework when this window is first constructed.
function Created()
{
	super.Created();
	// Scrollbar sits at (WinWidth - scrollbarWidth, 0), sized (scrollbarWidth, WinHeight)
	m_VertSB = R6WindowVScrollbar(CreateWindow(m_SBClass, (WinWidth - LookAndFeel.Size_ScrollbarWidth), 0.0000000, LookAndFeel.Size_ScrollbarWidth, WinHeight));
	return;
}

// Stores the help text in both the base class field and m_szDefaultHelpText,
// so tooltip logic can temporarily override the displayed text and restore it later.
function SetHelpText(string t)
{
	super(UWindowDialogControl).SetHelpText(t);
	m_szDefaultHelpText = t;
	return;
}

// Delegates sorting to UWindowList.Sort(), which calls UWindowListBoxItem.Compare()
// to determine item order. Subclasses override Compare() to customise sort behaviour.
function Sort()
{
	Items.Sort();
	return;
}

// Main rendering function. Implements virtual scrolling: only the rows that fit within
// the visible area are drawn, starting from the current scrollbar position.
// All items are assumed to have the same height (SDK comment confirms this constraint).
function Paint(Canvas C, float fMouseX, float fMouseY)
{
	local R6WindowLookAndFeel LAF;
	local UWindowList CurItem;
	local float Y, fdrawWidth, fListHeight, fItemHeight;
	local int i;

	LAF = R6WindowLookAndFeel(LookAndFeel);
	// Items is the sentinel node; Items.Next is the first real item
	CurItem = Items.Next;
	// End:0x40
	if((CurItem != none))
	{
		// All rows are the same height, so we only need to measure once
		fItemHeight = GetSizeOfAnItem(CurItem);
	}
	fListHeight = GetSizeOfList();
	// End:0xD1
	if((m_VertSB != none))
	{
		// Update scrollbar: range=[0, totalShownItems], pageSize=number of fully visible rows
		m_VertSB.SetRange(0.0000000, float(Items.CountShown()), float(int((fListHeight / fItemHeight))));
		J0x8C:

		// Skip items scrolled above the visible area (virtual scroll: advance CurItem past hidden rows)
		// End:0xD1 [Loop If]
		if(((CurItem != none) && (float(i) < m_VertSB.pos)))
		{
			(i++);
			CurItem = CurItem.Next;
			// [Loop Continue]
			goto J0x8C;
		}
	}
	// Draw width = full window width minus scrollbar, right padding, and left item offset
	// End:0x10C
	if(((m_VertSB == none) || m_VertSB.isHidden()))
	{
		fdrawWidth = ((WinWidth - m_fXItemRightPadding) - m_fXItemOffset);		
	}
	else
	{
		fdrawWidth = (((WinWidth - m_VertSB.WinWidth) - m_fXItemRightPadding) - m_fXItemOffset);
	}
	m_iTotItemsDisplayed = 0;
	// Start drawing just below the top horizontal border strip (m_SBHBorder.H pixels tall)
	Y = float(LAF.m_SBHBorder.H);
	J0x157:

	// Draw visible rows until we run out of vertical space or items
	// End:0x1F7 [Loop If]
	if((((Y + fItemHeight) <= (fListHeight + float(LAF.m_SBHBorder.H))) && (CurItem != none)))
	{
		// End:0x1E0
		if(CurItem.ShowThisItem())
		{
			DrawItem(C, CurItem, m_fXItemOffset, Y, fdrawWidth, fItemHeight);
			Y = (Y + fItemHeight);
			(m_iTotItemsDisplayed++);
		}
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0x157;
	}
	return;
}

// Returns the total pixel height of one row: base item height + inter-item spacing,
// plus optional sub-text height. All rows must be the same height (SDK comment confirms this).
function float GetSizeOfAnItem(UWindowList _pItem)
{
	local float fTotalItemHeigth;

	fTotalItemHeigth = (m_fItemHeight + m_fSpaceBetItem);
	// End:0x48
	if(UWindowListBoxItem(_pItem).m_bUseSubText)
	{
		// Sub-text adds a secondary smaller line below the main item label (e.g. a subtitle or status)
		(fTotalItemHeigth += UWindowListBoxItem(_pItem).m_stSubText.fHeight);
	}
	return fTotalItemHeigth;
	return;
}

// Returns the usable vertical drawing area: window height minus the top and bottom
// horizontal border strip heights (m_SBHBorder.H pixels each side).
// Always call SetSize(W, H) on this control to ensure WinHeight is correct first.
function float GetSizeOfList()
{
	return (WinHeight - float((2 * R6WindowLookAndFeel(LookAndFeel).m_SBHBorder.H)));
	return;
}

// Repositions and resizes the vertical scrollbar after the window dimensions change.
// The scrollbar's left edge depends on m_eCornerType:
//   No_Corners / No_Borders: flush with right edge (no inset)
//   Top/Bottom/All_Corners: inset by m_iListVPadding to clear the corner artwork.
// NOTE: Always use SetSize(W, H) to resize this control, not raw WinWidth/WinHeight.
function Resized()
{
	super(UWindowWindow).Resized();
	// End:0xCF
	if((m_VertSB != none))
	{
		switch(m_eCornerType)
		{
			// End:0x1D
			case 0:
			// End:0x49
			case 1:
				// No corner art: scrollbar sits flush with the right edge
				m_VertSB.WinLeft = (WinWidth - LookAndFeel.Size_ScrollbarWidth);
				// End:0x99
				break;
			// End:0x4E
			case 2:
			// End:0x53
			case 3:
			// End:0x96
			case 4:
				// Corner art present: inset the scrollbar by m_iListVPadding to avoid overlap
				m_VertSB.WinLeft = ((WinWidth - m_VertSB.WinWidth) - float(R6WindowLookAndFeel(LookAndFeel).m_iListVPadding));
				// End:0x99
				break;
			// End:0xFFFF
			default:
				break;
		}
		m_VertSB.WinTop = 0.0000000;
		m_VertSB.SetSize(LookAndFeel.Size_ScrollbarWidth, WinHeight);
	}
	return;
}

// Changes the visual corner style and immediately repositions the scrollbar to match.
function SetCornerType(R6WindowListBox.eCornerType _NewCornerType)
{
	m_eCornerType = _NewCornerType;
	Resized();
	return;
}

// Hit-tests a mouse position and returns the list item at that screen coordinate, or None.
// Uses the same virtual-scroll offset logic as Paint() so the result always matches
// what is visually drawn on screen.
function UWindowListBoxItem GetItemAt(float fMouseX, float fMouseY)
{
	local R6WindowLookAndFeel LAF;
	local UWindowList CurItem;
	local float Y, fdrawWidth, fListHeight, fItemHeight;
	local int i;

	LAF = R6WindowLookAndFeel(LookAndFeel);
	// The scrollbar column is not a valid click target; compute the actual item area width
	// End:0x3D
	if(((m_VertSB == none) || m_VertSB.isHidden()))
	{
		fdrawWidth = WinWidth;		
	}
	else
	{
		fdrawWidth = (WinWidth - m_VertSB.WinWidth);
	}
	// Reject clicks outside the item area (left of 0 or right of the scrollbar boundary)
	// End:0x78
	if(((fMouseX < float(0)) || (fMouseX > fdrawWidth)))
	{
		return none;
	}
	CurItem = Items.Next;
	// End:0xA8
	if((CurItem != none))
	{
		fItemHeight = GetSizeOfAnItem(CurItem);
	}
	fListHeight = GetSizeOfList();
	// End:0x116
	if((m_VertSB != none))
	{
		// Skip items that are scrolled above the visible area (mirrors Paint()'s skip loop)
		J0xBF:

		// End:0x116 [Loop If]
		if(((CurItem != none) && (float(i) < m_VertSB.pos)))
		{
			// End:0xFF
			if(CurItem.ShowThisItem())
			{
				(i++);
			}
			CurItem = CurItem.Next;
			// [Loop Continue]
			goto J0xBF;
		}
	}
	// Begin hit-testing from the top of the visible drawing area (below the top border strip)
	Y = float(LAF.m_SBHBorder.H);
	J0x131:

	// Walk visible rows, checking whether fMouseY falls within each row's Y range
	// End:0x1DF [Loop If]
	if((((Y + fItemHeight) <= (fListHeight + float(LAF.m_SBHBorder.H))) && (CurItem != none)))
	{
		// End:0x1C8
		if(CurItem.ShowThisItem())
		{
			// The inter-item gap (m_fSpaceBetItem pixels at the bottom of each row) is NOT clickable
			// End:0x1B6
			if(((fMouseY >= Y) && (fMouseY <= ((Y + fItemHeight) - m_fSpaceBetItem))))
			{
				return UWindowListBoxItem(CurItem);
			}
			Y = (Y + fItemHeight);
		}
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0x131;
	}
	return none;
	return;
}

// Scrolls the list so the currently selected item is visible in the viewport.
// Called after keyboard navigation changes to keep the selection on-screen.
function MakeSelectedVisible()
{
	local UWindowList CurItem;
	local int i;

	// End:0x0D
	if((m_VertSB == none))
	{
		return;
	}
	// Re-sync the scrollbar range in case the item count changed since last paint
	m_VertSB.SetRange(0.0000000, float(Items.CountShown()), float(int((GetSizeOfList() / GetSizeOfAnItem(Items.Next)))));
	// End:0x5F
	if((m_SelectedItem == none))
	{
		return;
	}
	// Count the number of shown items that precede the selected item (its visible row index)
	CurItem = Items.Next;
	J0x73:

	// End:0xC0 [Loop If]
	if((CurItem != none))
	{
		// End:0x90
		if((CurItem == m_SelectedItem))
		{
			// [Explicit Break]
			goto J0xC0;
		}
		// End:0xA9
		if(CurItem.ShowThisItem())
		{
			(i++);
		}
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0x73;
	}
	J0xC0:

	// Tell the scrollbar to ensure row i is within the visible range
	m_VertSB.Show(float(i));
	return;
}

// Sets the active selection: deselects the previous item, selects the new one,
// and fires Notify(2) (DE_Click) to inform the parent window of the selection change.
// No-op if NewSelected is already selected or is None.
function SetSelectedItem(UWindowListBoxItem NewSelected)
{
	// End:0x67
	if(((NewSelected != none) && (m_SelectedItem != NewSelected)))
	{
		// End:0x38
		if((m_SelectedItem != none))
		{
			m_SelectedItem.bSelected = false;
		}
		m_SelectedItem = NewSelected;
		// End:0x5F
		if((m_SelectedItem != none))
		{
			m_SelectedItem.bSelected = true;
		}
		// 2 = DE_Click: notify parent that the selected item has changed
		Notify(2);
	}
	return;
}

// Converts a click coordinate to an item and selects it.
// Resets ClickTime (the double-click timer) when a different item is clicked, preventing
// a stale click time from triggering a double-click on the newly selected item.
function SetSelected(float X, float Y)
{
	local UWindowListBoxItem NewSelected;

	NewSelected = GetItemAt(X, Y);
	// End:0x30
	if((NewSelected != m_SelectedItem))
	{
		// Different item clicked; reset double-click timer so a single click on a new
		// item can't accidentally trigger a double-click via a leftover timestamp
		ClickTime = 0.0000000;
	}
	SetSelectedItem(NewSelected);
	return;
}

// Handles left mouse button press: gives keyboard focus to this control, selects
// the clicked row, and starts a drag-reorder session if dragging is enabled.
function LMouseDown(float X, float Y)
{
	// End:0x0B
	if(m_bIgnoreUserClicks)
	{
		return;
	}
	super(UWindowWindow).LMouseDown(X, Y);
	SetAcceptsFocus();
	SetSelected(X, Y);
	// End:0x67
	if((m_bCanDrag || m_bCanDragExternal))
	{
		// Capture the mouse so we keep receiving MouseMove events even if the cursor leaves this window
		m_bDragging = true;
		Root.CaptureMouse();
		m_fDragY = Y;
	}
	return;
}

// Fires DoubleClickItem only when the item under the cursor still matches the currently
// selected item. This guards against cursor drift between the two clicks of a double-click.
function DoubleClick(float X, float Y)
{
	// End:0x18
	if((m_bIgnoreUserClicks || (m_SelectedItem == none)))
	{
		return;
	}
	// End:0x3D
	if((GetItemAt(X, Y) == m_SelectedItem))
	{
		DoubleClickItem(m_SelectedItem);
	}
	return;
}

// Called on the destination list when an item is double-clicked to transfer it from source
// list L. The item is removed from L, appended to this list, and both lists fire
// Notify(1) (DE_Change) to inform their parents that their contents have changed.
function ReceiveDoubleClickItem(R6WindowListBox L, UWindowListBoxItem i)
{
	i.Remove();
	Items.AppendItem(i);
	SetSelectedItem(i);
	// Clear source list's selection since the item no longer lives there
	L.m_SelectedItem = none;
	// 1 = DE_Change: notify both lists that their item sets have changed
	L.Notify(1);
	Notify(1);
	return;
}

// Fires the double-click action: broadcasts Notify(11) (DE_DoubleClick) to the parent,
// optionally notifies a specific registered client window, and optionally transfers
// the item to m_DoubleClickList (e.g. moving a player from "available" to "selected" list).
function DoubleClickItem(UWindowListBoxItem i)
{
	// End:0x0B
	if(m_bIgnoreUserClicks)
	{
		return;
	}
	// 11 = DE_DoubleClick
	Notify(11);
	// End:0x30
	if((m_DoubleClickClient != none))
	{
		// Also notify the specific registered client window (e.g. a dialog panel watching this list)
		m_DoubleClickClient.NotifyWindow(self, 11);
	}
	// End:0x5D
	if(((m_DoubleClickList != none) && (i != none)))
	{
		// Transfer the item to the paired destination list (e.g. "available" -> "selected")
		m_DoubleClickList.ReceiveDoubleClickItem(self, i);
	}
	return;
}

// overwrite UWindowWindow Mouse Enter
// When m_bActiveOverEffect is set, highlight the list border with the hover color.
function MouseEnter()
{
	super(UWindowDialogControl).MouseEnter();
	// End:0x1A
	if(m_bActiveOverEffect)
	{
		// Swap to the hover border color configured via SetOverBorderColorEffect()
		m_BorderColor = m_vMouseOverWindow;
	}
	return;
}

// overwrite UWindowWindow Mouse Leave
// Restore the original border color when the cursor exits the list.
function MouseLeave()
{
	super(UWindowDialogControl).MouseLeave();
	// End:0x1A
	if(m_bActiveOverEffect)
	{
		// Restore the saved initial border color set by SetOverBorderColorEffect()
		m_BorderColor = m_vInitBorderColor;
	}
	return;
}

// Handles drag-to-reorder while the left mouse button is held.
// Compares the current Y to m_fDragY to decide whether to insert before or after the hovered row.
// For external-drag mode, delegates to CheckExternalDrag() if the cursor leaves this list.
function MouseMove(float X, float Y)
{
	local UWindowListBoxItem OverItem;

	super(UWindowDialogControl).MouseMove(X, Y);
	// End:0xFA
	if((m_bDragging && bMouseDown))
	{
		OverItem = GetItemAt(X, Y);
		// End:0xCE
		if((((m_bCanDrag && (OverItem != m_SelectedItem)) && (OverItem != none)) && (m_SelectedItem != none)))
		{
			// Remove the selected item from its current position then reinsert near the hover target
			m_SelectedItem.Remove();
			// End:0xA3
			if((Y < m_fDragY))
			{
				// Dragged upward: insert before the item under the cursor
				OverItem.InsertItemBefore(m_SelectedItem);				
			}
			else
			{
				// Dragged downward: insert after the item under the cursor
				OverItem.InsertItemAfter(m_SelectedItem, true);
			}
			// 1 = DE_Change: notify parent that the item order has changed
			Notify(1);
			// Update reference Y for the next movement comparison
			m_fDragY = Y;			
		}
		else
		{
			// End:0xF7
			if((m_bCanDragExternal && (CheckExternalDrag(X, Y) != none)))
			{
				// Drag has crossed into another list; that list now owns the mouse capture
				m_bDragging = false;
			}
		}		
	}
	else
	{
		m_bDragging = false;
	}
	return;
}

// Forward mouse wheel down events to the vertical scrollbar for scrolling.
function MouseWheelDown(float X, float Y)
{
	// End:0x24
	if((m_VertSB != none))
	{
		m_VertSB.MouseWheelDown(X, Y);
	}
	return;
}

// Forward mouse wheel up events to the vertical scrollbar for scrolling.
function MouseWheelUp(float X, float Y)
{
	// End:0x24
	if((m_VertSB != none))
	{
		m_VertSB.MouseWheelUp(X, Y);
	}
	return;
}

// Called when an item from another R6WindowListBox (ExternalControl) is dragged into
// this list. Subclasses should return false without calling this if they want to deny
// the transfer. On acceptance, the item is spliced out of the source list and inserted
// at the hovered position here; this list then takes over mouse capture for continued dragging.
function bool ExternalDragOver(UWindowDialogControl ExternalControl, float X, float Y)
{
	local R6WindowListBox B;
	local UWindowListBoxItem OverItem;

	// Only accept drags from other R6WindowListBox instances with a valid selection
	B = R6WindowListBox(ExternalControl);
	// End:0x134
	if(((B != none) && (B.m_SelectedItem != none)))
	{
		OverItem = GetItemAt(X, Y);
		// Remove the item from the source list
		B.m_SelectedItem.Remove();
		// End:0x8A
		if((OverItem != none))
		{
			// Insert before the item currently under the cursor
			OverItem.InsertItemBefore(B.m_SelectedItem);			
		}
		else
		{
			// No item under cursor: append to the end of this list
			Items.AppendItem(B.m_SelectedItem);
		}
		SetSelectedItem(B.m_SelectedItem);
		// Clear the source list's selection since the item has moved
		B.m_SelectedItem = none;
		// 1 = DE_Change: notify both lists that their contents have changed
		B.Notify(1);
		Notify(1);
		// End:0x132
		if((m_bCanDrag || m_bCanDragExternal))
		{
			// Transfer mouse capture to this list so drag-reordering continues here
			Root.CancelCapture();
			m_bDragging = true;
			bMouseDown = true;
			Root.CaptureMouse(self);
			m_fDragY = Y;
		}
		return true;
	}
	return false;
	return;
}

// Clears the current selection without notifying the parent window.
// Use this to programmatically deselect all rows (e.g. when clearing the list).
function DropSelection()
{
	// End:0x1C
	if((m_SelectedItem != none))
	{
		m_SelectedItem.bSelected = false;
	}
	m_SelectedItem = none;
	return;
}

//=======================================================================
// Get the selected item
// return None if no item was selected
//=======================================================================
function UWindowListBoxItem GetSelectedItem()
{
	return m_SelectedItem;
	return;
}

//=======================================================================
// Set the border color
// Why use a fct for this, because we need to initialize the intial color too
// for mouveenter and mouse leave effect when you go on this window
//=======================================================================
// Activates the mouse-hover border color effect.
// Sets both the current border color AND the saved initial color so MouseLeave
// can restore it. Use this instead of setting m_BorderColor directly when you
// also want the hover highlight to work.
function SetOverBorderColorEffect(Color _vBorderColor)
{
	m_BorderColor = _vBorderColor;
	// Save as the baseline so MouseLeave can restore it
	m_vInitBorderColor = _vBorderColor;
	m_bActiveOverEffect = true;
	return;
}

//=======================================================================================================
// This function return the region where to draw the icon X and Y depending of window region
// (W and H are 0)
//=======================================================================================================
// Returns the pixel position to draw an icon centered inside a cell rectangle.
// The +0.5 before INT() performs nearest-integer rounding rather than always truncating,
// avoiding a systematic 1-pixel off-center bias at odd cell or icon sizes.
// The returned Region has W=0 and H=0; only X and Y are meaningful.
function Region CenterIconInBox(float _fX, float _fY, float _fWidth, float _fHeight, Region _RIconRegion)
{
	local Region RTemp;
	local float fTemp;

	// Horizontal: (cellWidth - iconWidth) / 2, rounded to nearest pixel, offset by cell X
	fTemp = ((_fWidth - float(_RIconRegion.W)) / float(2));
	RTemp.X = int((_fX + float(int((fTemp + 0.5000000)))));  // +0.5 for nearest-integer rounding
	// Vertical: (cellHeight - iconHeight) / 2, rounded, offset by cell Y
	fTemp = ((_fHeight - float(_RIconRegion.H)) / float(2));
	RTemp.Y = int(float(int((fTemp + 0.5000000))));  // +0.5 for nearest-integer rounding
	(RTemp.Y += int(_fY));
	return RTemp;
	return;
}

//=======================================================================================================
// GetCenterXPos: return the center pos of the region according the text size
//=======================================================================================================
// Returns the X pixel offset to center text of _fTextWidth inside a column of _fTagWidth.
// The +0.5 rounds to the nearest integer pixel rather than always truncating downward.
function int GetCenterXPos(float _fTagWidth, float _fTextWidth)
{
	return int((((_fTagWidth - _fTextWidth) * 0.5000000) + 0.5000000));
	return;
}

// Resets the list completely: scrolls back to the top, clears the selection, and removes all items.
function Clear()
{
	// Reset scroll position to zero before clearing so the scrollbar reflects the empty state
	m_VertSB.pos = 0.0000000;
	m_SelectedItem = none;
	Items.Clear();
	return;
}

//=======================================================================================================
// KeyDown: manage key down for list (movements in the list...)
// Key codes are EInputKey enum values that the decompiler emitted as integers:
//   38=IK_Up, 40=IK_Down, 36=IK_Home, 35=IK_End, 13=IK_Enter,
//   34=IK_PageDown, 33=IK_PageUp, 27=IK_Escape
//=======================================================================================================
function KeyDown(int Key, float X, float Y)
{
	local UWindowListBoxItem TempItem, OldSelection;

	// End:0x57
	if((m_SelectedItem == none))
	{
		// No current selection: on any key press, select the first valid item
		// End:0x55
		if((Items.Count() > 0))
		{
			TempItem = CheckForNextItem(UWindowListBoxItem(Items.Next));
			// End:0x55
			if((TempItem != none))
			{
				SetSelectedItem(TempItem);
			}
		}
		return;
	}
	OldSelection = m_SelectedItem;
	switch(Key)
	{
		// 38 = IK_Up: move selection to the previous visible, non-disabled, non-separator row
		// End:0xAC
		case int(Root.Console.38):
			TempItem = CheckForPrevItem(m_SelectedItem);
			// End:0xA9
			if((TempItem != none))
			{
				SetSelectedItem(TempItem);
			}
			// End:0x268
			break;
		// 40 = IK_Down: move selection to the next visible, non-disabled, non-separator row
		// End:0xEF
		case int(Root.Console.40):
			TempItem = CheckForNextItem(m_SelectedItem);
			// End:0xEC
			if((TempItem != none))
			{
				SetSelectedItem(TempItem);
			}
			// End:0x268
			break;
		// 36 = IK_Home: jump to the first valid item in the list
		// End:0x137
		case int(Root.Console.36):
			TempItem = CheckForNextItem(UWindowListBoxItem(Items));
			// End:0x134
			if((TempItem != none))
			{
				SetSelectedItem(TempItem);
			}
			// End:0x268
			break;
		// 35 = IK_End: jump to the last valid item in the list
		// End:0x188
		case int(Root.Console.35):
			TempItem = CheckForLastItem(UWindowListBoxItem(Items.Last));
			// End:0x185
			if((TempItem != none))
			{
				SetSelectedItem(TempItem);
			}
			// End:0x268
			break;
		// 13 = IK_Enter: activate the selected item (same effect as double-clicking it)
		// End:0x1BA
		case int(Root.Console.13):
			// End:0x1B7
			if((!m_bIgnoreUserClicks))
			{
				DoubleClickItem(m_SelectedItem);
			}
			// End:0x268
			break;
		// 34 = IK_PageDown: advance selection by one page's worth of visible rows
		// End:0x1FD
		case int(Root.Console.34):
			TempItem = CheckForPageDown(m_SelectedItem);
			// End:0x1FA
			if((TempItem != none))
			{
				SetSelectedItem(TempItem);
			}
			// End:0x268
			break;
		// 33 = IK_PageUp: move selection back by one page's worth of visible rows
		// End:0x240
		case int(Root.Console.33):
			TempItem = CheckForPageUp(m_SelectedItem);
			// End:0x23D
			if((TempItem != none))
			{
				SetSelectedItem(TempItem);
			}
			// End:0x268
			break;
		// 27 = IK_Escape: release keyboard focus from this list
		// End:0x262
		case int(Root.Console.27):
			CancelAcceptsFocus();
			// End:0x268
			break;
		// End:0xFFFF
		default:
			// End:0x268
			break;
			break;
	}
	// If the selection moved, scroll the list to keep it visible
	// End:0x27D
	if((OldSelection != m_SelectedItem))
	{
		MakeSelectedVisible();
	}
	super(UWindowDialogControl).KeyDown(Key, X, Y);
	return;
}

//===================================================================================
// CheckForNextItem: check for the next valid item on the list
// Skips disabled items and separator items, walking forward until a selectable row
// is found. Returns None if no valid item exists after _StartItem.
//===================================================================================
function UWindowListBoxItem CheckForNextItem(UWindowListBoxItem _StartItem)
{
	local UWindowListBoxItem TempItem;
	local bool bIsASeparator;

	// End:0x0D
	if((_StartItem == none))
	{
		return none;
	}
	TempItem = UWindowListBoxItem(_StartItem.Next);
	// End:0x49
	if(((TempItem == none) || (!TempItem.ShowThisItem())))
	{
		return none;
	}
	// Only check for separator flag when the list uses R6WindowListBoxItem
	// End:0x6D
	if(IsASeparatorItem())
	{
		bIsASeparator = R6WindowListBoxItem(TempItem).m_IsSeparator;
	}
	J0x6D:

	// End:0xED [Loop If]
	if((TempItem.m_bDisabled || bIsASeparator))
	{
		TempItem = UWindowListBoxItem(TempItem.Next);
		// End:0xC6
		if(((TempItem == none) || (!TempItem.ShowThisItem())))
		{
			return none;
		}
		// End:0xEA
		if(IsASeparatorItem())
		{
			bIsASeparator = R6WindowListBoxItem(TempItem).m_IsSeparator;
		}
		// [Loop Continue]
		goto J0x6D;
	}
	return TempItem;
	return;
}

//===================================================================================
// CheckForPrevItem: check for the prev valid item on the list
// Skips disabled and separator items walking backward. Returns None when the list
// sentinel (Items) is reached, meaning we're already at the beginning.
//===================================================================================
function UWindowListBoxItem CheckForPrevItem(UWindowListBoxItem _StartItem)
{
	local UWindowListBoxItem TempItem;
	local bool bIsASeparator;

	// End:0x0D
	if((_StartItem == none))
	{
		return none;
	}
	TempItem = UWindowListBoxItem(_StartItem.Prev);
	// End:0x4D
	if(((TempItem == Items.Sentinel) || (TempItem == none)))
	{
		// Hit the sentinel (or past it): no previous item exists
		return none;
	}
	// End:0x71
	if(IsASeparatorItem())
	{
		bIsASeparator = R6WindowListBoxItem(TempItem).m_IsSeparator;
	}
	J0x71:

	// End:0xF1 [Loop If]
	if((TempItem.m_bDisabled || bIsASeparator))
	{
		TempItem = UWindowListBoxItem(TempItem.Prev);
		// End:0xCA
		if(((TempItem == none) || (TempItem == UWindowListBoxItem(Items))))
		{
			// Hit None or the list's sentinel head node: no more previous items
			return none;
		}
		// End:0xEE
		if(IsASeparatorItem())
		{
			bIsASeparator = R6WindowListBoxItem(TempItem).m_IsSeparator;
		}
		// [Loop Continue]
		goto J0x71;
	}
	return TempItem;
	return;
}

//===================================================================================
// CheckForLastItem: check for the last valid item on the list
// If the last item is disabled or a separator, delegates to CheckForPrevItem to find
// the nearest valid item before it.
//===================================================================================
function UWindowListBoxItem CheckForLastItem(UWindowListBoxItem _LastItem)
{
	local bool bIsASeparator;

	// End:0x0D
	if((_LastItem == none))
	{
		return none;
	}
	// End:0x31
	if(IsASeparatorItem())
	{
		bIsASeparator = R6WindowListBoxItem(_LastItem).m_IsSeparator;
	}
	// End:0x5A
	if((_LastItem.m_bDisabled || bIsASeparator))
	{
		return CheckForPrevItem(_LastItem);
	}
	return _LastItem;
	return;
}

//===================================================================================
// CheckForPageDown: check for the next page down valid item on the list
// Advances up to iMaxItemsDisplayed steps forward. If the end of the list is reached
// early, returns the last valid item found (ValidItem) rather than None.
//===================================================================================
function UWindowListBoxItem CheckForPageDown(UWindowListBoxItem _StartItem)
{
	local UWindowListBoxItem TempItem, ValidItem;
	local int i, iMaxItemsDisplayed;
	local bool bIsASeparator;

	// End:0x0D
	if((_StartItem == none))
	{
		return none;
	}
	TempItem = _StartItem;
	i = 1;
	ValidItem = TempItem;
	// Page size = number of fully visible rows in the current list height
	iMaxItemsDisplayed = int((GetSizeOfList() / GetSizeOfAnItem(TempItem)));
	J0x45:

	// End:0xB6 [Loop If]
	if((i < iMaxItemsDisplayed))
	{
		TempItem = UWindowListBoxItem(TempItem.Next);
		// End:0x8F
		if(((TempItem == none) || (i == m_iTotItemsDisplayed)))
		{
			// Hit end of list before filling a full page; return the furthest valid item
			return ValidItem;
		}
		// End:0xB3
		if(TempItem.ShowThisItem())
		{
			(i++);
			ValidItem = TempItem;
		}
		// [Loop Continue]
		goto J0x45;
	}
	// Full page traversed: return the next valid item after TempItem
	return CheckForNextItem(TempItem);
	return;
}

//===================================================================================
// CheckForPageUp: check for the next page up valid item on the list
// Walks backward iMaxItemsDisplayed steps. Returns ValidItem if the beginning of
// the list (sentinel) is reached before a full page is traversed.
//===================================================================================
function UWindowListBoxItem CheckForPageUp(UWindowListBoxItem _StartItem)
{
	local UWindowListBoxItem TempItem, ValidItem;
	local int i, iMaxItemsDisplayed;
	local bool bIsASeparator;

	// End:0x0D
	if((_StartItem == none))
	{
		return none;
	}
	TempItem = _StartItem;
	i = 1;
	ValidItem = TempItem;
	// Page size = number of fully visible rows in the current list height
	iMaxItemsDisplayed = int((GetSizeOfList() / GetSizeOfAnItem(TempItem)));
	J0x45:

	// End:0xCC [Loop If]
	if((i < iMaxItemsDisplayed))
	{
		TempItem = UWindowListBoxItem(TempItem.Prev);
		// End:0xA5
		if((((TempItem == none) || (i == m_iTotItemsDisplayed)) || (TempItem == UWindowListBoxItem(Items))))
		{
			// Hit beginning of list before filling a full page; return the furthest valid item
			return ValidItem;
		}
		// End:0xC9
		if(TempItem.ShowThisItem())
		{
			(i++);
			ValidItem = TempItem;
		}
		// [Loop Continue]
		goto J0x45;
	}
	// Full page traversed: return the previous valid item before TempItem
	return CheckForPrevItem(TempItem);
	return;
}

//===================================================================================
// SwapItem: Move an item in the list, by default is to the next element.
//			 Restrictions: Can apply swap on disable/separator item
// Uses remove-and-reinsert rather than swapping data, so all item pointers remain valid.
//===================================================================================
function bool SwapItem(UWindowListBoxItem _pItem, bool _bUp)
{
	local UWindowListBoxItem TempItem, BkpItem;

	// End:0x0D
	if((_pItem == none))
	{
		return false;
	}
	TempItem = _pItem;
	// End:0x8E
	if(_bUp)
	{
		TempItem = UWindowListBoxItem(TempItem.Prev);
		// End:0x5D
		if(((TempItem == none) || (TempItem == UWindowListBoxItem(Items))))
		{
			// Already at the top of the list; can't move up further
			return false;
		}
		// Remove from current position and insert before the item above it
		BkpItem = _pItem;
		_pItem.Remove();
		TempItem.InsertItemBefore(BkpItem);		
	}
	else
	{
		TempItem = UWindowListBoxItem(TempItem.Next);
		// End:0xB4
		if((TempItem == none))
		{
			// Already at the bottom of the list; can't move down further
			return false;
		}
		// Remove from current position and insert after the item below it
		BkpItem = _pItem;
		_pItem.Remove();
		TempItem.InsertItemAfter(BkpItem);
	}
	MakeSelectedVisible();
	return true;
	return;
}

//===================================================================================
// IsASeparatorItem: check if item have separator
// Returns true when ListClass is R6WindowListBoxItem, which is the only subclass that
// carries the m_IsSeparator flag. Plain UWindowListBoxItem does not have that field,
// so we must guard all accesses to m_IsSeparator behind this check.
//===================================================================================
function bool IsASeparatorItem()
{
	return (ListClass == Class'R6Window.R6WindowListBoxItem');
	return;
}

// Called by the UWindow framework when keyboard focus enters this control.
function KeyFocusEnter()
{
	SetAcceptsFocus();
	return;
}

// Called by the UWindow framework when keyboard focus leaves this control.
function KeyFocusExit()
{
	CancelAcceptsFocus();
	return;
}

defaultproperties
{
	m_fItemHeight=10.0000000     // each row is 10 pixels tall by default
	m_fSpaceBetItem=4.0000000    // 4-pixel gap between rows (not clickable — see GetItemAt)
	m_fXItemOffset=2.0000000     // 2-pixel left inset for item text / icons
	m_TIcon=Texture'R6MenuTextures.Credits.TeamBarIcon'  // default icon texture atlas
	m_SBClass=Class'R6Window.R6WindowVScrollbar'
	m_vMouseOverWindow=(R=129,G=209,B=239,A=0)  // light steel-blue hover border color
	ListClass=Class'UWindow.UWindowListBoxItem'  // override with R6WindowListBoxItem for separator support
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var eCornerType
