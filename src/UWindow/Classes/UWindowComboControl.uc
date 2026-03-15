//=============================================================================
// UWindowComboControl - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowComboControl extends UWindowDialogControl;

var bool bListVisible;          // True when the dropdown list is currently visible
var bool bCanEdit;              // True when the text portion is directly editable by the user
var bool bButtons;              // True when left/right step buttons are shown alongside the combo
var bool m_bDisabled;           // True when the combo is disabled and non-interactive
var bool m_bSelectedByUser;     // True when the current value was set by a user interaction
var float EditBoxWidth;         // Width of the edit/label area portion of the control
var float EditAreaDrawX;        // X draw offset for the edit/bevel area
// NEW IN 1.60
var float EditAreaDrawY;        // Y draw offset for the edit/bevel area (added in 1.60)
var UWindowEditBox EditBox;     // Child window that displays (and optionally edits) the value
var UWindowComboButton Button;  // Child button that triggers the dropdown
var UWindowComboLeftButton LeftButton;    // Left step button (active when bButtons is true)
var UWindowComboRightButton RightButton;  // Right step button (active when bButtons is true)
var UWindowComboList List;               // The dropdown list popup child window
var Class<UWindowComboList> ListClass;   // Class used to instantiate the dropdown list

// Initializes the combo control, creating the edit box, dropdown button, and list child windows.
function Created()
	EditBox.NotifyOwner = self;
	EditBoxWidth = (WinWidth / float(2));
	EditBox.bTransient = true;
	Button = UWindowComboButton(CreateWindow(Class'UWindow.UWindowComboButton', (WinWidth - LookAndFeel.Size_ComboButtonWidth), 0.0000000, LookAndFeel.Size_ComboButtonWidth, LookAndFeel.Size_ComboHeight));
	Button.Owner = self;
	List = UWindowComboList(Root.CreateWindow(ListClass, 0.0000000, 0.0000000, 100.0000000, 100.0000000));
	List.LookAndFeel = LookAndFeel;
	List.Owner = self;
	List.Setup();
	List.HideWindow();
	bListVisible = false;
	SetEditTextColor(LookAndFeel.EditBoxTextColor);
	return;
}

// Enables or disables the left/right step buttons flanking the dropdown arrow.
function SetButtons(bool bInButtons)
{
	bButtons = bInButtons;
	// End:0x8B
	if(bInButtons)
	{
		LeftButton = UWindowComboLeftButton(CreateWindow(Class'UWindow.UWindowComboLeftButton', (WinWidth - float(12)), 0.0000000, 12.0000000, LookAndFeel.Size_ComboHeight));
		RightButton = UWindowComboRightButton(CreateWindow(Class'UWindow.UWindowComboRightButton', (WinWidth - float(12)), 0.0000000, 12.0000000, LookAndFeel.Size_ComboHeight));		
	}
	else
	{
		LeftButton = none;
		RightButton = none;
	}
	return;
}

// Handles child window events; left-click opens the dropdown (or closes it if already open).
function Notify(byte E)
{
	super.Notify(E);
	// End:0x5F
	if((int(E) == 10))
	{
		// End:0x59
		if(((!bListVisible) && (!m_bDisabled)))
		{
			// End:0x56
			if((!bCanEdit))
			{
				DropDown();
				Root.CaptureMouse(List);
			}			
		}
		else
		{
			CloseUp();
		}
	}
	return;
}

// Returns the index of the first list item whose primary value matches V (-1 if not found).
function int FindItemIndex(string V, optional bool bIgnoreCase)
{
	return List.FindItemIndex(V, bIgnoreCase);
	return;
}

function RemoveItem(int Index)
{
	List.RemoveItem(Index);
	return;
}

// Returns the index of the first list item whose secondary value matches V2 (-1 if not found).
function int FindItemIndex2(string v2, optional bool bIgnoreCase)
{
	return List.FindItemIndex2(v2, bIgnoreCase);
	return;
}

// Closes the control; collapses the dropdown list first if it is currently open.
function Close(optional bool bByParent)
{
	// End:0x1A
	if((bByParent && bListVisible))
	{
		CloseUp();
	}
	super(UWindowWindow).Close(bByParent);
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

function SetEditTextColor(Color NewColor)
{
	EditBox.SetTextColor(NewColor);
	return;
}

function SetEditable(bool bNewCanEdit)
{
	bCanEdit = bNewCanEdit;
	EditBox.SetEditable(bCanEdit);
	return;
}

// Returns the index of the currently selected item, or -1 if no match is found.
function int GetSelectedIndex()
{
	return List.FindItemIndex(GetValue());
	return;
}

// Selects the item at the given list index, updating the displayed value.
function SetSelectedIndex(int Index)
{
	SetValue(List.GetItemValue(Index), List.GetItemValue2(Index));
	return;
}

// Returns the primary value string currently displayed in the edit box.
function string GetValue()
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

function Paint(Canvas C, float X, float Y)
{
	LookAndFeel.Combo_Draw(self, C);
	return;
}

function AddItem(string S, optional string S2, optional int SortWeight)
{
	List.AddItem(S, S2, SortWeight);
	return;
}

function InsertItem(string S, optional string S2, optional int SortWeight)
{
	List.InsertItem(S, S2, SortWeight);
	return;
}

// get an item, none if not exist
function UWindowComboListItem GetItem(string S)
{
	return List.GetItem(S);
	return;
}

// Disable all the item on the list, still displaying
function DisableAllItems()
{
	List.DisableAllItems();
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	super.BeforePaint(C, X, Y);
	LookAndFeel.Combo_SetupSizes(self, C);
	List.bLeaveOnscreen = (bListVisible && bLeaveOnscreen);
	return;
}

function CloseUp()
{
	bListVisible = false;
	EditBox.SetEditable(bCanEdit);
	EditBox.SelectAll();
	List.HideWindow();
	List.CancelAcceptsFocus();
	return;
}

function DropDown()
{
	bListVisible = true;
	EditBox.SetEditable(false);
	// End:0x57
	if((List.Selected != none))
	{
		// End:0x57
		if(List.Selected.bDisabled)
		{
			List.Selected = none;
		}
	}
	List.ShowWindow();
	List.SetAcceptsFocus();
	return;
}

function Sort()
{
	List.Sort();
	return;
}

function ClearValue()
{
	EditBox.Clear();
	return;
}

function Clear()
{
	List.Clear();
	EditBox.Clear();
	return;
}

function FocusOtherWindow(UWindowWindow W)
{
	super(UWindowWindow).FocusOtherWindow(W);
	// End:0x5B
	if((((bListVisible && (W.ParentWindow != self)) && (W != List)) && (W.ParentWindow != List)))
	{
		CloseUp();
	}
	return;
}

defaultproperties
{
	ListClass=Class'UWindow.UWindowComboList'
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var Y
