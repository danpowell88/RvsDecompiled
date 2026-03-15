//=============================================================================
// UWindowPulldownMenu - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// UWindowPulldownMenu
//=============================================================================
class UWindowPulldownMenu extends UWindowListControl;

var int ItemHeight;
var int VBorder;
var int HBorder;
var int TextBorder;
var UWindowPulldownMenuItem Selected;
// Owner is either a UWindowMenuBarItem or UWindowPulldownMenuItem
var UWindowList Owner;

// External functions
function UWindowPulldownMenuItem AddMenuItem(string C, Texture G)
{
	local UWindowPulldownMenuItem i;

	i = UWindowPulldownMenuItem(Items.Append(Class'UWindow.UWindowPulldownMenuItem'));
	i.Owner = self;
	i.SetCaption(C);
	i.Graphic = G;
	return i;
	return;
}

function Created()
{
	ListClass = Class'UWindow.UWindowPulldownMenuItem';
	SetAcceptsFocus();
	super.Created();
	ItemHeight = int(LookAndFeel.Pulldown_ItemHeight);
	VBorder = int(LookAndFeel.Pulldown_VBorder);
	HBorder = int(LookAndFeel.Pulldown_HBorder);
	TextBorder = int(LookAndFeel.Pulldown_TextBorder);
	return;
}

function Clear()
{
	Items.Clear();
	Selected = none;
	return;
}

function DeSelect()
{
	// End:0x21
	if((Selected != none))
	{
		Selected.DeSelect();
		Selected = none;
	}
	return;
}

function Select(UWindowPulldownMenuItem i)
{
	return;
}

function PerformSelect(UWindowPulldownMenuItem NewSelected)
{
	// End:0x2B
	if(((Selected != none) && (NewSelected != Selected)))
	{
		Selected.DeSelect();
	}
	// End:0x40
	if((NewSelected == none))
	{
		Selected = none;		
	}
	else
	{
		// End:0x8F
		if((((Selected != NewSelected) && (NewSelected.Caption != "-")) && (!NewSelected.bDisabled)))
		{
			LookAndFeel.PlayMenuSound(self, 2);
		}
		Selected = NewSelected;
		// End:0xBF
		if((Selected != none))
		{
			Selected.Select();
			Select(Selected);
		}
	}
	return;
}

function SetSelected(float X, float Y)
{
	local UWindowPulldownMenuItem NewSelected;

	NewSelected = UWindowPulldownMenuItem(Items.FindEntry((int((Y - float(VBorder))) / ItemHeight)));
	PerformSelect(NewSelected);
	return;
}

function ShowWindow()
{
	local UWindowPulldownMenuItem i;

	super(UWindowWindow).ShowWindow();
	PerformSelect(none);
	FocusWindow();
	return;
}

function MouseMove(float X, float Y)
{
	super(UWindowDialogControl).MouseMove(X, Y);
	SetSelected(X, Y);
	FocusWindow();
	return;
}

function LMouseUp(float X, float Y)
{
	// End:0x4F
	if((((Selected != none) && (Selected.Caption != "-")) && (!Selected.bDisabled)))
	{
		BeforeExecuteItem(Selected);
		ExecuteItem(Selected);
	}
	super(UWindowWindow).LMouseUp(X, Y);
	return;
}

function LMouseDown(float X, float Y)
{
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H, MaxWidth;
	local int Count;
	local UWindowPulldownMenuItem i;

	MaxWidth = 100.0000000;
	Count = 0;
	C.Font = Root.Fonts[0];
	C.SetPos(0.0000000, 0.0000000);
	i = UWindowPulldownMenuItem(Items.Next);
	J0x60:

	// End:0xD2 [Loop If]
	if((i != none))
	{
		(Count++);
		TextSize(C, RemoveAmpersand(i.Caption), W, H);
		// End:0xB6
		if((W > MaxWidth))
		{
			MaxWidth = W;
		}
		i = UWindowPulldownMenuItem(i.Next);
		// [Loop Continue]
		goto J0x60;
	}
	WinWidth = (MaxWidth + float(((HBorder + TextBorder) * 2)));
	WinHeight = (float((ItemHeight * Count)) + float((VBorder * 2)));
	// End:0x177
	if((((UWindowMenuBarItem(Owner) != none) && UWindowMenuBarItem(Owner).bHelp) || ((WinLeft + WinWidth) > ParentWindow.WinWidth)))
	{
		WinLeft = (ParentWindow.WinWidth - WinWidth);
	}
	// End:0x1F5
	if((UWindowPulldownMenuItem(Owner) != none))
	{
		i = UWindowPulldownMenuItem(Owner);
		// End:0x1F5
		if(((WinWidth + WinLeft) > ParentWindow.WinWidth))
		{
			WinLeft = ((i.Owner.WinLeft + float(i.Owner.HBorder)) - WinWidth);
		}
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local int Count;
	local UWindowPulldownMenuItem i;

	DrawMenuBackground(C);
	Count = 0;
	i = UWindowPulldownMenuItem(Items.Next);
	J0x2B:

	// End:0x9E [Loop If]
	if((i != none))
	{
		DrawItem(C, i, float(HBorder), float((VBorder + (ItemHeight * Count))), (WinWidth - float((2 * HBorder))), float(ItemHeight));
		(Count++);
		i = UWindowPulldownMenuItem(i.Next);
		// [Loop Continue]
		goto J0x2B;
	}
	return;
}

function DrawMenuBackground(Canvas C)
{
	LookAndFeel.Menu_DrawPulldownMenuBackground(self, C);
	return;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	LookAndFeel.Menu_DrawPulldownMenuItem(self, UWindowPulldownMenuItem(Item), C, X, Y, W, H, (Selected == Item));
	return;
}

function BeforeExecuteItem(UWindowPulldownMenuItem i)
{
	LookAndFeel.PlayMenuSound(self, 3);
	return;
}

function ExecuteItem(UWindowPulldownMenuItem i)
{
	CloseUp();
	return;
}

function CloseUp(optional bool bByOwner)
{
	local UWindowPulldownMenuItem i;

	// End:0x53
	if((!bByOwner))
	{
		// End:0x2F
		if((UWindowPulldownMenuItem(Owner) != none))
		{
			UWindowPulldownMenuItem(Owner).CloseUp();
		}
		// End:0x53
		if((UWindowMenuBarItem(Owner) != none))
		{
			UWindowMenuBarItem(Owner).CloseUp();
		}
	}
	i = UWindowPulldownMenuItem(Items.Next);
	J0x6C:

	// End:0xC0 [Loop If]
	if((i != none))
	{
		// End:0xA4
		if((i.SubMenu != none))
		{
			i.SubMenu.CloseUp(true);
		}
		i = UWindowPulldownMenuItem(i.Next);
		// [Loop Continue]
		goto J0x6C;
	}
	return;
}

function UWindowMenuBar GetMenuBar()
{
	// End:0x25
	if((UWindowPulldownMenuItem(Owner) != none))
	{
		return UWindowPulldownMenuItem(Owner).GetMenuBar();
	}
	// End:0x4A
	if((UWindowMenuBarItem(Owner) != none))
	{
		return UWindowMenuBarItem(Owner).GetMenuBar();
	}
	return;
}

function FocusOtherWindow(UWindowWindow W)
{
	super(UWindowWindow).FocusOtherWindow(W);
	// End:0x30
	if((Selected != none))
	{
		// End:0x30
		if((W == Selected.SubMenu))
		{
			return;
		}
	}
	// End:0x5F
	if((UWindowPulldownMenuItem(Owner) != none))
	{
		// End:0x5F
		if((UWindowPulldownMenuItem(Owner).Owner == W))
		{
			return;
		}
	}
	// End:0x6E
	if(bWindowVisible)
	{
		CloseUp();
	}
	return;
}

function KeyDown(int Key, float X, float Y)
{
	local UWindowPulldownMenuItem i;

	i = Selected;
	switch(Key)
	{
		// End:0x11B
		case 38:
			// End:0x58
			if(((i == none) || (i == Items.Next)))
			{
				i = UWindowPulldownMenuItem(Items.Last);				
			}
			else
			{
				i = UWindowPulldownMenuItem(i.Prev);
			}
			// End:0x98
			if((i == none))
			{
				i = UWindowPulldownMenuItem(Items.Last);				
			}
			else
			{
				// End:0xC7
				if((i.Caption == "-"))
				{
					i = UWindowPulldownMenuItem(i.Prev);
				}
			}
			// End:0xEB
			if((i == none))
			{
				i = UWindowPulldownMenuItem(Items.Last);
			}
			// End:0x10D
			if((i.SubMenu == none))
			{
				PerformSelect(i);				
			}
			else
			{
				Selected = i;
			}
			// End:0x437
			break;
		// End:0x20A
		case 40:
			// End:0x147
			if((i == none))
			{
				i = UWindowPulldownMenuItem(Items.Next);				
			}
			else
			{
				i = UWindowPulldownMenuItem(i.Next);
			}
			// End:0x187
			if((i == none))
			{
				i = UWindowPulldownMenuItem(Items.Next);				
			}
			else
			{
				// End:0x1B6
				if((i.Caption == "-"))
				{
					i = UWindowPulldownMenuItem(i.Next);
				}
			}
			// End:0x1DA
			if((i == none))
			{
				i = UWindowPulldownMenuItem(Items.Next);
			}
			// End:0x1FC
			if((i.SubMenu == none))
			{
				PerformSelect(i);				
			}
			else
			{
				Selected = i;
			}
			// End:0x437
			break;
		// End:0x2A3
		case 37:
			// End:0x264
			if((UWindowPulldownMenuItem(Owner) != none))
			{
				UWindowPulldownMenuItem(Owner).Owner.PerformSelect(none);
				UWindowPulldownMenuItem(Owner).Owner.Selected = UWindowPulldownMenuItem(Owner);
			}
			// End:0x2A0
			if((UWindowMenuBarItem(Owner) != none))
			{
				UWindowMenuBarItem(Owner).Owner.KeyDown(Key, X, Y);
			}
			// End:0x437
			break;
		// End:0x3B4
		case 39:
			// End:0x31B
			if(((i != none) && (i.SubMenu != none)))
			{
				Selected = none;
				PerformSelect(i);
				i.SubMenu.Selected = UWindowPulldownMenuItem(i.SubMenu.Items.Next);				
			}
			else
			{
				// End:0x375
				if((UWindowPulldownMenuItem(Owner) != none))
				{
					UWindowPulldownMenuItem(Owner).Owner.PerformSelect(none);
					UWindowPulldownMenuItem(Owner).Owner.KeyDown(Key, X, Y);
				}
				// End:0x3B1
				if((UWindowMenuBarItem(Owner) != none))
				{
					UWindowMenuBarItem(Owner).Owner.KeyDown(Key, X, Y);
				}
			}
			// End:0x437
			break;
		// End:0x434
		case 13:
			// End:0x3E2
			if((i.SubMenu != none))
			{
				Selected = none;
				PerformSelect(i);				
			}
			else
			{
				// End:0x431
				if((((Selected != none) && (Selected.Caption != "-")) && (!Selected.bDisabled)))
				{
					BeforeExecuteItem(Selected);
					ExecuteItem(Selected);
				}
			}
			// End:0x437
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

function KeyUp(int Key, float X, float Y)
{
	local UWindowPulldownMenuItem i;

	// End:0xCE
	if(((Key >= 65) && (Key <= 96)))
	{
		i = UWindowPulldownMenuItem(Items.Next);
		J0x33:

		// End:0xCE [Loop If]
		if((i != none))
		{
			// End:0xB2
			if((Key == int(i.HotKey)))
			{
				PerformSelect(i);
				// End:0xB2
				if((((i != none) && (i.Caption != "-")) && (!i.bDisabled)))
				{
					BeforeExecuteItem(i);
					ExecuteItem(i);
				}
			}
			i = UWindowPulldownMenuItem(i.Next);
			// [Loop Continue]
			goto J0x33;
		}
	}
	return;
}

function MenuCmd(int Item)
{
	local int j;
	local UWindowPulldownMenuItem i;

	i = UWindowPulldownMenuItem(Items.Next);
	J0x19:

	// End:0xA5 [Loop If]
	if((i != none))
	{
		// End:0x82
		if((j == Item))
		{
			PerformSelect(i);
			// End:0x80
			if(((i.Caption != "-") && (!i.bDisabled)))
			{
				BeforeExecuteItem(i);
				ExecuteItem(i);
			}
			return;
		}
		(j++);
		i = UWindowPulldownMenuItem(i.Next);
		// [Loop Continue]
		goto J0x19;
	}
	return;
}

defaultproperties
{
	bAlwaysOnTop=true
}
