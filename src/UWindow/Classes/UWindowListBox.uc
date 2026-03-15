//=============================================================================
// UWindowListBox - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// UWindowListBox - a listbox
//=============================================================================
class UWindowListBox extends UWindowListControl;

var bool bCanDrag;
var bool bCanDragExternal;
var bool bDragging;
var float ItemHeight;
var float DragY;
var UWindowVScrollbar VertSB;
var UWindowListBoxItem SelectedItem;
var UWindowListBox DoubleClickList;  // list to send items to on double-click
var string DefaultHelpText;

function Created()
{
	super.Created();
	VertSB = UWindowVScrollbar(CreateWindow(Class'UWindow.UWindowVScrollbar', (WinWidth - LookAndFeel.Size_ScrollbarWidth), 0.0000000, LookAndFeel.Size_ScrollbarWidth, WinHeight));
	return;
}

function BeforePaint(Canvas C, float MouseX, float MouseY)
{
	local UWindowListBoxItem OverItem;
	local string NewHelpText;

	VertSB.SetRange(0.0000000, float(Items.CountShown()), float(int((WinHeight / ItemHeight))));
	NewHelpText = DefaultHelpText;
	// End:0x9B
	if((SelectedItem != none))
	{
		OverItem = GetItemAt(MouseX, MouseY);
		// End:0x9B
		if(((OverItem == SelectedItem) && (OverItem.HelpText != "")))
		{
			NewHelpText = OverItem.HelpText;
		}
	}
	// End:0xBD
	if((NewHelpText != HelpText))
	{
		HelpText = NewHelpText;
		Notify(13);
	}
	return;
}

function SetHelpText(string t)
{
	super(UWindowDialogControl).SetHelpText(t);
	DefaultHelpText = t;
	return;
}

function Sort()
{
	Items.Sort();
	return;
}

function Paint(Canvas C, float MouseX, float MouseY)
{
	local float Y;
	local UWindowList CurItem;
	local int i;

	CurItem = Items.Next;
	i = 0;
	J0x1B:

	// End:0x72 [Loop If]
	if(((CurItem != none) && (float(i) < VertSB.pos)))
	{
		// End:0x5B
		if(CurItem.ShowThisItem())
		{
			(i++);
		}
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0x1B;
	}
	Y = 0.0000000;
	J0x7D:

	// End:0x108 [Loop If]
	if(((Y < WinHeight) && (CurItem != none)))
	{
		// End:0xF1
		if(CurItem.ShowThisItem())
		{
			DrawItem(C, CurItem, 0.0000000, Y, (WinWidth - LookAndFeel.Size_ScrollbarWidth), ItemHeight);
			Y = (Y + ItemHeight);
		}
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0x7D;
	}
	return;
}

function Resized()
{
	super(UWindowWindow).Resized();
	VertSB.WinLeft = (WinWidth - LookAndFeel.Size_ScrollbarWidth);
	VertSB.WinTop = 0.0000000;
	VertSB.SetSize(LookAndFeel.Size_ScrollbarWidth, WinHeight);
	return;
}

function UWindowListBoxItem GetItemAt(float MouseX, float MouseY)
{
	local float Y;
	local UWindowList CurItem;
	local int i;

	// End:0x20
	if(((MouseX < float(0)) || (MouseX > WinWidth)))
	{
		return none;
	}
	CurItem = Items.Next;
	i = 0;
	J0x3B:

	// End:0x92 [Loop If]
	if(((CurItem != none) && (float(i) < VertSB.pos)))
	{
		// End:0x7B
		if(CurItem.ShowThisItem())
		{
			(i++);
		}
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0x3B;
	}
	Y = 0.0000000;
	J0x9D:

	// End:0x126 [Loop If]
	if(((Y < WinHeight) && (CurItem != none)))
	{
		// End:0x10F
		if(CurItem.ShowThisItem())
		{
			// End:0xFD
			if(((MouseY >= Y) && (MouseY <= (Y + ItemHeight))))
			{
				return UWindowListBoxItem(CurItem);
			}
			Y = (Y + ItemHeight);
		}
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0x9D;
	}
	return none;
	return;
}

function MakeSelectedVisible()
{
	local UWindowList CurItem;
	local int i;

	VertSB.SetRange(0.0000000, float(Items.CountShown()), float(int((WinHeight / ItemHeight))));
	// End:0x42
	if((SelectedItem == none))
	{
		return;
	}
	i = 0;
	CurItem = Items.Next;
	J0x5D:

	// End:0xAA [Loop If]
	if((CurItem != none))
	{
		// End:0x7A
		if((CurItem == SelectedItem))
		{
			// [Explicit Break]
			goto J0xAA;
		}
		// End:0x93
		if(CurItem.ShowThisItem())
		{
			(i++);
		}
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0x5D;
	}
	J0xAA:

	VertSB.Show(float(i));
	return;
}

function SetSelectedItem(UWindowListBoxItem NewSelected)
{
	// End:0x67
	if(((NewSelected != none) && (SelectedItem != NewSelected)))
	{
		// End:0x38
		if((SelectedItem != none))
		{
			SelectedItem.bSelected = false;
		}
		SelectedItem = NewSelected;
		// End:0x5F
		if((SelectedItem != none))
		{
			SelectedItem.bSelected = true;
		}
		Notify(2);
	}
	return;
}

function SetSelected(float X, float Y)
{
	local UWindowListBoxItem NewSelected;

	NewSelected = GetItemAt(X, Y);
	// End:0x30
	if((NewSelected != SelectedItem))
	{
		ClickTime = 0.0000000;
	}
	SetSelectedItem(NewSelected);
	return;
}

function LMouseDown(float X, float Y)
{
	super(UWindowWindow).LMouseDown(X, Y);
	SetSelected(X, Y);
	// End:0x56
	if((bCanDrag || bCanDragExternal))
	{
		bDragging = true;
		Root.CaptureMouse();
		DragY = Y;
	}
	return;
}

function DoubleClick(float X, float Y)
{
	super(UWindowWindow).DoubleClick(X, Y);
	// End:0x35
	if((GetItemAt(X, Y) == SelectedItem))
	{
		DoubleClickItem(SelectedItem);
	}
	return;
}

function ReceiveDoubleClickItem(UWindowListBox L, UWindowListBoxItem i)
{
	i.Remove();
	Items.AppendItem(i);
	SetSelectedItem(i);
	L.SelectedItem = none;
	L.Notify(1);
	Notify(1);
	return;
}

function DoubleClickItem(UWindowListBoxItem i)
{
	// End:0x2D
	if(((DoubleClickList != none) && (i != none)))
	{
		DoubleClickList.ReceiveDoubleClickItem(self, i);
	}
	return;
}

function MouseMove(float X, float Y)
{
	local UWindowListBoxItem OverItem;

	super(UWindowDialogControl).MouseMove(X, Y);
	// End:0xFA
	if((bDragging && bMouseDown))
	{
		OverItem = GetItemAt(X, Y);
		// End:0xCE
		if((((bCanDrag && (OverItem != SelectedItem)) && (OverItem != none)) && (SelectedItem != none)))
		{
			SelectedItem.Remove();
			// End:0xA3
			if((Y < DragY))
			{
				OverItem.InsertItemBefore(SelectedItem);				
			}
			else
			{
				OverItem.InsertItemAfter(SelectedItem, true);
			}
			Notify(1);
			DragY = Y;			
		}
		else
		{
			// End:0xF7
			if((bCanDragExternal && (CheckExternalDrag(X, Y) != none)))
			{
				bDragging = false;
			}
		}		
	}
	else
	{
		bDragging = false;
	}
	return;
}

function bool ExternalDragOver(UWindowDialogControl ExternalControl, float X, float Y)
{
	local UWindowListBox B;
	local UWindowListBoxItem OverItem;

	B = UWindowListBox(ExternalControl);
	// End:0x134
	if(((B != none) && (B.SelectedItem != none)))
	{
		OverItem = GetItemAt(X, Y);
		B.SelectedItem.Remove();
		// End:0x8A
		if((OverItem != none))
		{
			OverItem.InsertItemBefore(B.SelectedItem);			
		}
		else
		{
			Items.AppendItem(B.SelectedItem);
		}
		SetSelectedItem(B.SelectedItem);
		B.SelectedItem = none;
		B.Notify(1);
		Notify(1);
		// End:0x132
		if((bCanDrag || bCanDragExternal))
		{
			Root.CancelCapture();
			bDragging = true;
			bMouseDown = true;
			Root.CaptureMouse(self);
			DragY = Y;
		}
		return true;
	}
	return false;
	return;
}

defaultproperties
{
	ItemHeight=10.0000000
}
