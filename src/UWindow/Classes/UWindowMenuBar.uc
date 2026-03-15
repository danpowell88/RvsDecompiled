//=============================================================================
// UWindowMenuBar - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// UWindowMenuBar - A menu bar
//=============================================================================
class UWindowMenuBar extends UWindowListControl;

var int Spacing;
var bool bAltDown;
var UWindowMenuBarItem Selected;
var UWindowMenuBarItem Over;

function Created()
{
	ListClass = Class'UWindow.UWindowMenuBarItem';
	SetAcceptsHotKeys(true);
	super.Created();
	Spacing = 10;
	return;
}

function UWindowMenuBarItem AddHelpItem(string Caption)
{
	local UWindowMenuBarItem i;

	i = AddItem(Caption);
	i.SetHelp(true);
	return i;
	return;
}

function UWindowMenuBarItem AddItem(string Caption)
{
	local UWindowMenuBarItem i;

	i = UWindowMenuBarItem(Items.Append(Class'UWindow.UWindowMenuBarItem'));
	i.Owner = self;
	i.SetCaption(Caption);
	return i;
	return;
}

function ResolutionChanged(float W, float H)
{
	local UWindowMenuBarItem i;

	i = UWindowMenuBarItem(Items.Next);
	J0x19:

	// End:0x76 [Loop If]
	if((i != none))
	{
		// End:0x5A
		if((i.Menu != none))
		{
			i.Menu.ResolutionChanged(W, H);
		}
		i = UWindowMenuBarItem(i.Next);
		// [Loop Continue]
		goto J0x19;
	}
	super(UWindowWindow).ResolutionChanged(W, H);
	return;
}

function Paint(Canvas C, float MouseX, float MouseY)
{
	local float X, W, H;
	local UWindowMenuBarItem i;

	DrawMenuBar(C);
	i = UWindowMenuBarItem(Items.Next);
	J0x24:

	// End:0x12E [Loop If]
	if((i != none))
	{
		C.Font = Root.Fonts[0];
		TextSize(C, RemoveAmpersand(i.Caption), W, H);
		// End:0xCA
		if(i.bHelp)
		{
			DrawItem(C, i, (WinWidth - (W + float(Spacing))), 1.0000000, (W + float(Spacing)), 14.0000000);			
		}
		else
		{
			DrawItem(C, i, X, 1.0000000, (W + float(Spacing)), 14.0000000);
			X = ((X + W) + float(Spacing));
		}
		i = UWindowMenuBarItem(i.Next);
		// [Loop Continue]
		goto J0x24;
	}
	return;
}

function MouseMove(float X, float Y)
{
	local UWindowMenuBarItem i;

	super(UWindowDialogControl).MouseMove(X, Y);
	Over = none;
	i = UWindowMenuBarItem(Items.Next);
	J0x30:

	// End:0xF5 [Loop If]
	if((i != none))
	{
		// End:0xD9
		if(((X >= i.ItemLeft) && (X <= (i.ItemLeft + i.ItemWidth))))
		{
			// End:0xCE
			if((Selected != none))
			{
				// End:0xCB
				if((Selected != i))
				{
					Selected.DeSelect();
					Selected = i;
					Selected.Select();
					Select(Selected);
				}				
			}
			else
			{
				Over = i;
			}
		}
		i = UWindowMenuBarItem(i.Next);
		// [Loop Continue]
		goto J0x30;
	}
	return;
}

function MouseLeave()
{
	super(UWindowDialogControl).MouseLeave();
	Over = none;
	return;
}

function Select(UWindowMenuBarItem i)
{
	return;
}

function LMouseDown(float X, float Y)
{
	local UWindowMenuBarItem i;

	i = UWindowMenuBarItem(Items.Next);
	J0x19:

	// End:0xE7 [Loop If]
	if((i != none))
	{
		// End:0xCB
		if(((X >= i.ItemLeft) && (X <= (i.ItemLeft + i.ItemWidth))))
		{
			// End:0x80
			if((Selected != none))
			{
				Selected.DeSelect();
			}
			// End:0xA4
			if((Selected == i))
			{
				Selected = none;
				Over = i;				
			}
			else
			{
				Selected = i;
				Selected.Select();
			}
			Select(Selected);
			return;
		}
		i = UWindowMenuBarItem(i.Next);
		// [Loop Continue]
		goto J0x19;
	}
	// End:0x101
	if((Selected != none))
	{
		Selected.DeSelect();
	}
	Selected = none;
	Select(Selected);
	return;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local string Text, Underline;
	local UWindowMenuBarItem pMenuBarItem;

	pMenuBarItem = UWindowMenuBarItem(Item);
	C.SetDrawColor(byte(255), byte(255), byte(255));
	pMenuBarItem.ItemLeft = X;
	pMenuBarItem.ItemWidth = W;
	LookAndFeel.Menu_DrawMenuBarItem(self, pMenuBarItem, X, Y, W, H, C);
	return;
}

function DrawMenuBar(Canvas C)
{
	DrawStretchedTexture(C, 0.0000000, 0.0000000, WinWidth, 16.0000000, Texture'UWindow.Icons.MenuBar');
	return;
}

function CloseUp()
{
	// End:0x21
	if((Selected != none))
	{
		Selected.DeSelect();
		Selected = none;
	}
	return;
}

function Close(optional bool bByParent)
{
	Root.Console.CloseUWindow();
	return;
}

function UWindowMenuBar GetMenuBar()
{
	return self;
	return;
}

function bool HotKeyDown(int Key, float X, float Y)
{
	local UWindowMenuBarItem i;

	// End:0x14
	if((Key == 18))
	{
		bAltDown = true;
	}
	// End:0xC0
	if(bAltDown)
	{
		i = UWindowMenuBarItem(Items.Next);
		J0x36:

		// End:0xC0 [Loop If]
		if((i != none))
		{
			// End:0xA4
			if((Key == int(i.HotKey)))
			{
				// End:0x75
				if((Selected != none))
				{
					Selected.DeSelect();
				}
				Selected = i;
				Selected.Select();
				Select(Selected);
				bAltDown = false;
				return true;
			}
			i = UWindowMenuBarItem(i.Next);
			// [Loop Continue]
			goto J0x36;
		}
	}
	return false;
	return;
}

function bool HotKeyUp(int Key, float X, float Y)
{
	// End:0x14
	if((Key == 18))
	{
		bAltDown = false;
	}
	return false;
	return;
}

function KeyDown(int Key, float X, float Y)
{
	local UWindowMenuBarItem i;

	switch(Key)
	{
		// End:0x9C
		case 37:
			i = UWindowMenuBarItem(Selected.Prev);
			// End:0x5A
			if(((i == none) || (i == Items)))
			{
				i = UWindowMenuBarItem(Items.Last);
			}
			// End:0x74
			if((Selected != none))
			{
				Selected.DeSelect();
			}
			Selected = i;
			Selected.Select();
			Select(Selected);
			// End:0x123
			break;
		// End:0x120
		case 39:
			i = UWindowMenuBarItem(Selected.Next);
			// End:0xDE
			if((i == none))
			{
				i = UWindowMenuBarItem(Items.Next);
			}
			// End:0xF8
			if((Selected != none))
			{
				Selected.DeSelect();
			}
			Selected = i;
			Selected.Select();
			Select(Selected);
			// End:0x123
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

function MenuCmd(int Menu, int Item)
{
	local UWindowMenuBarItem i;
	local int j;

	j = 0;
	i = UWindowMenuBarItem(Items.Next);
	J0x20:

	// End:0xD1 [Loop If]
	if((i != none))
	{
		// End:0xAE
		if(((j == Menu) && (i.Menu != none)))
		{
			// End:0x6A
			if((Selected != none))
			{
				Selected.DeSelect();
			}
			Selected = i;
			Selected.Select();
			Select(Selected);
			i.Menu.MenuCmd(Item);
			return;
		}
		(j++);
		i = UWindowMenuBarItem(i.Next);
		// [Loop Continue]
		goto J0x20;
	}
	return;
}

