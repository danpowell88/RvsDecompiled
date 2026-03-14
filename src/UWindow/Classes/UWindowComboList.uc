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
	VertSB = UWindowVScrollbar(CreateWindow(Class'UWindow.UWindowVScrollbar', __NFUN_175__(WinWidth, LookAndFeel.Size_ScrollbarWidth), 0.0000000, LookAndFeel.Size_ScrollbarWidth, WinHeight));
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
	if(__NFUN_119__(i, none))
	{
		// End:0x54
		if(__NFUN_130__(bIgnoreCase, __NFUN_124__(i.Value, Value)))
		{
			return Count;
		}
		// End:0x72
		if(__NFUN_122__(i.Value, Value))
		{
			return Count;
		}
		__NFUN_165__(Count);
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
	if(__NFUN_119__(i, none))
	{
		// End:0x54
		if(__NFUN_130__(bIgnoreCase, __NFUN_124__(i.Value2, Value2)))
		{
			return Count;
		}
		// End:0x72
		if(__NFUN_122__(i.Value2, Value2))
		{
			return Count;
		}
		__NFUN_165__(Count);
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
	if(__NFUN_119__(i, none))
	{
		// End:0x49
		if(__NFUN_154__(Count, Index))
		{
			return i.Value;
		}
		__NFUN_165__(Count);
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
	if(__NFUN_154__(Index, -1))
	{
		return;
	}
	i = UWindowComboListItem(Items.Next);
	Count = 0;
	J0x31:

	// End:0x7F [Loop If]
	if(__NFUN_119__(i, none))
	{
		// End:0x5C
		if(__NFUN_154__(Count, Index))
		{
			i.Remove();
			return;
		}
		__NFUN_165__(Count);
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
	if(__NFUN_119__(i, none))
	{
		// End:0x49
		if(__NFUN_154__(Count, Index))
		{
			return i.Value2;
		}
		__NFUN_165__(Count);
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
	if(__NFUN_119__(Item, none))
	{
		__NFUN_165__(Count);
		Item = UWindowComboListItem(Item.Next);
		// [Loop Continue]
		goto J0x20;
	}
	i = int(__NFUN_174__(float(__NFUN_145__(int(__NFUN_175__(Y, float(VBorder))), ItemHeight)), VertSB.pos));
	// End:0x91
	if(__NFUN_150__(i, 0))
	{
		i = 0;
	}
	// End:0xE6
	if(__NFUN_179__(float(i), __NFUN_174__(VertSB.pos, float(__NFUN_249__(Count, MaxVisible)))))
	{
		i = int(__NFUN_175__(__NFUN_174__(VertSB.pos, float(__NFUN_249__(Count, MaxVisible))), float(1)));
	}
	NewSelected = UWindowComboListItem(Items.FindEntry(i));
	// End:0x148
	if(__NFUN_119__(NewSelected, Selected))
	{
		// End:0x129
		if(__NFUN_114__(NewSelected, none))
		{
			Selected = none;			
		}
		else
		{
			// End:0x148
			if(__NFUN_129__(NewSelected.bDisabled))
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
	if(__NFUN_119__(i, none))
	{
		// End:0x49
		if(__NFUN_122__(i.Value, Value))
		{
			return i;
		}
		__NFUN_165__(Count);
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
	if(__NFUN_119__(i, none))
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
	if(__NFUN_177__(Y, WinHeight))
	{
		VertSB.Scroll(1.0000000);
	}
	// End:0x54
	if(__NFUN_176__(Y, float(0)))
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
	if(__NFUN_130__(__NFUN_130__(__NFUN_179__(Y, float(0)), __NFUN_178__(Y, WinHeight)), __NFUN_119__(Selected, none)))
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
	C.__NFUN_2623__(0.0000000, 0.0000000);
	MaxWidth = Owner.EditBoxWidth;
	ExtraWidth = __NFUN_171__(float(__NFUN_146__(HBorder, TextBorder)), float(2));
	Count = Items.Count();
	// End:0xC4
	if(__NFUN_151__(Count, MaxVisible))
	{
		__NFUN_184__(ExtraWidth, LookAndFeel.Size_ScrollbarWidth);
		WinHeight = __NFUN_174__(float(__NFUN_144__(ItemHeight, MaxVisible)), float(__NFUN_144__(VBorder, 2)));		
	}
	else
	{
		VertSB.pos = 0.0000000;
		WinHeight = __NFUN_174__(float(__NFUN_144__(ItemHeight, Count)), float(__NFUN_144__(VBorder, 2)));
	}
	i = UWindowComboListItem(Items.Next);
	J0x112:

	// End:0x18B [Loop If]
	if(__NFUN_119__(i, none))
	{
		TextSize(C, RemoveAmpersand(i.Value), W, H);
		// End:0x16F
		if(__NFUN_177__(__NFUN_174__(W, ExtraWidth), MaxWidth))
		{
			MaxWidth = __NFUN_174__(W, ExtraWidth);
		}
		i = UWindowComboListItem(i.Next);
		// [Loop Continue]
		goto J0x112;
	}
	WinWidth = MaxWidth;
	ListX = __NFUN_175__(__NFUN_174__(Owner.EditAreaDrawX, Owner.EditBoxWidth), WinWidth);
	ListY = __NFUN_174__(Owner.Button.WinTop, Owner.Button.WinHeight);
	// End:0x294
	if(__NFUN_151__(Count, MaxVisible))
	{
		VertSB.ShowWindow();
		VertSB.SetRange(0.0000000, float(Count), float(MaxVisible));
		VertSB.WinLeft = __NFUN_175__(WinWidth, LookAndFeel.Size_ScrollbarWidth);
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
	if(__NFUN_119__(i, none))
	{
		// End:0xCE
		if(VertSB.bWindowVisible)
		{
			// End:0xCB
			if(__NFUN_179__(float(Count), VertSB.pos))
			{
				DrawItem(C, i, float(HBorder), __NFUN_174__(float(VBorder), __NFUN_171__(float(ItemHeight), __NFUN_175__(float(Count), VertSB.pos))), __NFUN_175__(__NFUN_175__(WinWidth, float(__NFUN_144__(2, HBorder))), VertSB.WinWidth), float(ItemHeight));
			}			
		}
		else
		{
			DrawItem(C, i, float(HBorder), float(__NFUN_146__(VBorder, __NFUN_144__(ItemHeight, Count))), __NFUN_175__(WinWidth, float(__NFUN_144__(2, HBorder))), float(ItemHeight));
		}
		__NFUN_165__(Count);
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
	LookAndFeel.ComboList_DrawItem(self, C, X, Y, W, H, UWindowComboListItem(Item).Value, __NFUN_114__(Selected, Item));
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
	if(__NFUN_130__(__NFUN_130__(__NFUN_130__(bWindowVisible, __NFUN_119__(W.ParentWindow.ParentWindow, self)), __NFUN_119__(W.ParentWindow, self)), __NFUN_119__(W.ParentWindow, Owner)))
	{
		CloseUp();
	}
	return;
}

function SetBorderColor(Color _NewColor)
{
	m_BorderColor = _NewColor;
	// End:0x2A
	if(__NFUN_119__(VertSB, none))
	{
		VertSB.SetBorderColor(m_BorderColor);
	}
	return;
}

function MouseWheelDown(float X, float Y)
{
	// End:0x24
	if(__NFUN_119__(VertSB, none))
	{
		VertSB.MouseWheelDown(X, Y);
	}
	return;
}

function MouseWheelUp(float X, float Y)
{
	// End:0x24
	if(__NFUN_119__(VertSB, none))
	{
		VertSB.MouseWheelUp(X, Y);
	}
	return;
}

function KeyDown(int Key, float X, float Y)
{
	// End:0x26
	if(__NFUN_154__(Key, int(Root.Console.27)))
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
