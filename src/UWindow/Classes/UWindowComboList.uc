//=============================================================================
// UWindowComboList - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowComboList extends UWindowListControl;

var int ItemHeight;
var int VBorder;
var int HBorder;
var int TextBorder;
var int MaxVisible;
var UWindowComboControl Owner;
var UWindowVScrollbar VertSB;
var UWindowComboListItem Selected;

function Sort()
{
	Items.Sort();
	return;
}

function WindowShown()
{
	super(UWindowWindow).WindowShown();
	FocusWindow();
	return;
}

function Clear()
{
	Items.Clear();
	return;
}

function Texture GetLookAndFeelTexture()
{
	return LookAndFeel.Active;
	return;
}

function Setup()
{
	VertSB = UWindowVScrollbar(CreateWindow(Class'UWindow.UWindowVScrollbar', (WinWidth - LookAndFeel.Size_ScrollbarWidth), 0.0000000, LookAndFeel.Size_ScrollbarWidth, WinHeight));
	return;
}

function Created()
{
	ListClass = Class'UWindow.UWindowComboListItem';
	bAlwaysOnTop = true;
	bTransient = true;
	super.Created();
	ItemHeight = 15;
	VBorder = 3;
	HBorder = 3;
	TextBorder = 9;
	super.Created();
	return;
}

function int FindItemIndex(string Value, optional bool bIgnoreCase)
{
	local UWindowComboListItem i;
	local int Count;

	i = UWindowComboListItem(Items.Next);
	Count = 0;
	J0x20:

	// End:0x95 [Loop If]
	if((i != none))
	{
		// End:0x54
		if((bIgnoreCase && (i.Value ~= Value)))
		{
			return Count;
		}
		// End:0x72
		if((i.Value == Value))
		{
			return Count;
		}
		(Count++);
		i = UWindowComboListItem(i.Next);
		// [Loop Continue]
		goto J0x20;
	}
	return -1;
	return;
}

function int FindItemIndex2(string Value2, optional bool bIgnoreCase)
{
	local UWindowComboListItem i;
	local int Count;

	i = UWindowComboListItem(Items.Next);
	Count = 0;
	J0x20:

	// End:0x95 [Loop If]
	if((i != none))
	{
		// End:0x54
		if((bIgnoreCase && (i.Value2 ~= Value2)))
		{
			return Count;
		}
		// End:0x72
		if((i.Value2 == Value2))
		{
			return Count;
		}
		(Count++);
		i = UWindowComboListItem(i.Next);
		// [Loop Continue]
		goto J0x20;
	}
	return -1;
	return;
}

function string GetItemValue(int Index)
{
	local UWindowComboListItem i;
	local int Count;

	i = UWindowComboListItem(Items.Next);
	Count = 0;
	J0x20:

	// End:0x6C [Loop If]
	if((i != none))
	{
		// End:0x49
		if((Count == Index))
		{
			return i.Value;
		}
		(Count++);
		i = UWindowComboListItem(i.Next);
		// [Loop Continue]
		goto J0x20;
	}
	return "";
	return;
}

function RemoveItem(int Index)
{
	local UWindowComboListItem i;
	local int Count;

	// End:0x11
	if((Index == -1))
	{
		return;
	}
	i = UWindowComboListItem(Items.Next);
	Count = 0;
	J0x31:

	// End:0x7F [Loop If]
	if((i != none))
	{
		// End:0x5C
		if((Count == Index))
		{
			i.Remove();
			return;
		}
		(Count++);
		i = UWindowComboListItem(i.Next);
		// [Loop Continue]
		goto J0x31;
	}
	return;
}

function string GetItemValue2(int Index)
{
	local UWindowComboListItem i;
	local int Count;

	i = UWindowComboListItem(Items.Next);
	Count = 0;
	J0x20:

	// End:0x6C [Loop If]
	if((i != none))
	{
		// End:0x49
		if((Count == Index))
		{
			return i.Value2;
		}
		(Count++);
		i = UWindowComboListItem(i.Next);
		// [Loop Continue]
		goto J0x20;
	}
	return "";
	return;
}

function AddItem(string Value, optional string Value2, optional int SortWeight)
{
	local UWindowComboListItem i;

	i = UWindowComboListItem(Items.Append(Class'UWindow.UWindowComboListItem'));
	i.Value = Value;
	i.Value2 = Value2;
	i.SortWeight = SortWeight;
	return;
}

function InsertItem(string Value, optional string Value2, optional int SortWeight)
{
	local UWindowComboListItem i;

	i = UWindowComboListItem(Items.Insert(Class'UWindow.UWindowComboListItem'));
	i.Value = Value;
	i.Value2 = Value2;
	i.SortWeight = SortWeight;
	return;
}

function SetSelected(float X, float Y)
{
	local UWindowComboListItem NewSelected, Item;
	local int i, Count;

	Count = 0;
	Item = UWindowComboListItem(Items.Next);
	J0x20:

	// End:0x4E [Loop If]
	if((Item != none))
	{
		(Count++);
		Item = UWindowComboListItem(Item.Next);
		// [Loop Continue]
		goto J0x20;
	}
	i = int((float((int((Y - float(VBorder))) / ItemHeight)) + VertSB.pos));
	// End:0x91
	if((i < 0))
	{
		i = 0;
	}
	// End:0xE6
	if((float(i) >= (VertSB.pos + float(Min(Count, MaxVisible)))))
	{
		i = int(((VertSB.pos + float(Min(Count, MaxVisible))) - float(1)));
	}
	NewSelected = UWindowComboListItem(Items.FindEntry(i));
	// End:0x148
	if((NewSelected != Selected))
	{
		// End:0x129
		if((NewSelected == none))
		{
			Selected = none;			
		}
		else
		{
			// End:0x148
			if((!NewSelected.bDisabled))
			{
				Selected = NewSelected;
			}
		}
	}
	return;
}

//=================================================================================
// GetItem: Get the item with is Value
//=================================================================================
function UWindowComboListItem GetItem(string Value)
{
	local UWindowComboListItem i;
	local int Count;

	i = UWindowComboListItem(Items.Next);
	Count = 0;
	J0x20:

	// End:0x6C [Loop If]
	if((i != none))
	{
		// End:0x49
		if((i.Value == Value))
		{
			return i;
		}
		(Count++);
		i = UWindowComboListItem(i.Next);
		// [Loop Continue]
		goto J0x20;
	}
	return none;
	return;
}

//=================================================================================
// DisableAllItem: This fct disable all the items, but there still displaying
//=================================================================================
function DisableAllItems()
{
	local UWindowComboListItem i;
	local int Count;

	i = UWindowComboListItem(Items.Next);
	Count = 0;
	J0x20:

	// End:0x58 [Loop If]
	if((i != none))
	{
		i.bDisabled = true;
		i = UWindowComboListItem(i.Next);
		// [Loop Continue]
		goto J0x20;
	}
	return;
}

function MouseMove(float X, float Y)
{
	super(UWindowDialogControl).MouseMove(X, Y);
	// End:0x33
	if((Y > WinHeight))
	{
		VertSB.Scroll(1.0000000);
	}
	// End:0x54
	if((Y < float(0)))
	{
		VertSB.Scroll(-1.0000000);
	}
	SetSelected(X, Y);
	FocusWindow();
	return;
}

function LMouseUp(float X, float Y)
{
	// End:0x36
	if((((Y >= float(0)) && (Y <= WinHeight)) && (Selected != none)))
	{
		ExecuteItem(Selected);
	}
	super(UWindowWindow).LMouseUp(X, Y);
	return;
}

function LMouseDown(float X, float Y)
{
	Root.CaptureMouse();
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H, MaxWidth;
	local int Count;
	local UWindowComboListItem i;
	local float ListX, ListY, ExtraWidth;

	C.Font = Root.Fonts[Font];
	C.SetPos(0.0000000, 0.0000000);
	MaxWidth = Owner.EditBoxWidth;
	ExtraWidth = (float((HBorder + TextBorder)) * float(2));
	Count = Items.Count();
	// End:0xC4
	if((Count > MaxVisible))
	{
		(ExtraWidth += LookAndFeel.Size_ScrollbarWidth);
		WinHeight = (float((ItemHeight * MaxVisible)) + float((VBorder * 2)));		
	}
	else
	{
		VertSB.pos = 0.0000000;
		WinHeight = (float((ItemHeight * Count)) + float((VBorder * 2)));
	}
	i = UWindowComboListItem(Items.Next);
	J0x112:

	// End:0x18B [Loop If]
	if((i != none))
	{
		TextSize(C, RemoveAmpersand(i.Value), W, H);
		// End:0x16F
		if(((W + ExtraWidth) > MaxWidth))
		{
			MaxWidth = (W + ExtraWidth);
		}
		i = UWindowComboListItem(i.Next);
		// [Loop Continue]
		goto J0x112;
	}
	WinWidth = MaxWidth;
	ListX = ((Owner.EditAreaDrawX + Owner.EditBoxWidth) - WinWidth);
	ListY = (Owner.Button.WinTop + Owner.Button.WinHeight);
	// End:0x294
	if((Count > MaxVisible))
	{
		VertSB.ShowWindow();
		VertSB.SetRange(0.0000000, float(Count), float(MaxVisible));
		VertSB.WinLeft = (WinWidth - LookAndFeel.Size_ScrollbarWidth);
		VertSB.WinTop = 0.0000000;
		VertSB.SetSize(LookAndFeel.Size_ScrollbarWidth, WinHeight);		
	}
	else
	{
		VertSB.HideWindow();
	}
	Owner.WindowToGlobal(ListX, ListY, WinLeft, WinTop);
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local int Count;
	local UWindowComboListItem i;

	DrawMenuBackground(C);
	Count = 0;
	i = UWindowComboListItem(Items.Next);
	J0x2B:

	// End:0x136 [Loop If]
	if((i != none))
	{
		// End:0xCE
		if(VertSB.bWindowVisible)
		{
			// End:0xCB
			if((float(Count) >= VertSB.pos))
			{
				DrawItem(C, i, float(HBorder), (float(VBorder) + (float(ItemHeight) * (float(Count) - VertSB.pos))), ((WinWidth - float((2 * HBorder))) - VertSB.WinWidth), float(ItemHeight));
			}			
		}
		else
		{
			DrawItem(C, i, float(HBorder), float((VBorder + (ItemHeight * Count))), (WinWidth - float((2 * HBorder))), float(ItemHeight));
		}
		(Count++);
		i = UWindowComboListItem(i.Next);
		// [Loop Continue]
		goto J0x2B;
	}
	return;
}

function DrawMenuBackground(Canvas C)
{
	LookAndFeel.ComboList_DrawBackground(self, C);
	return;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	LookAndFeel.ComboList_DrawItem(self, C, X, Y, W, H, UWindowComboListItem(Item).Value, (Selected == Item));
	return;
}

function ExecuteItem(UWindowComboListItem i)
{
	Owner.m_bSelectedByUser = true;
	Owner.SetValue(i.Value, i.Value2);
	Owner.m_bSelectedByUser = false;
	CloseUp();
	return;
}

function CloseUp()
{
	Owner.CloseUp();
	return;
}

function FocusOtherWindow(UWindowWindow W)
{
	super(UWindowWindow).FocusOtherWindow(W);
	// End:0x69
	if((((bWindowVisible && (W.ParentWindow.ParentWindow != self)) && (W.ParentWindow != self)) && (W.ParentWindow != Owner)))
	{
		CloseUp();
	}
	return;
}

function SetBorderColor(Color _NewColor)
{
	m_BorderColor = _NewColor;
	// End:0x2A
	if((VertSB != none))
	{
		VertSB.SetBorderColor(m_BorderColor);
	}
	return;
}

function MouseWheelDown(float X, float Y)
{
	// End:0x24
	if((VertSB != none))
	{
		VertSB.MouseWheelDown(X, Y);
	}
	return;
}

function MouseWheelUp(float X, float Y)
{
	// End:0x24
	if((VertSB != none))
	{
		VertSB.MouseWheelUp(X, Y);
	}
	return;
}

function KeyDown(int Key, float X, float Y)
{
	// End:0x26
	if((Key == int(Root.Console.27)))
	{
		CloseUp();
	}
	return;
}

defaultproperties
{
	MaxVisible=10
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function SetupScrollBar
