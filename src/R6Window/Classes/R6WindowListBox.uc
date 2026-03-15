//=============================================================================
// R6WindowListBox - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowListBox.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowListBox extends UWindowListControl;

enum eCornerType
{
	No_Corners,                     // 0
	No_Borders,                     // 1
	Top_Corners,                    // 2
	Bottom_Corners,                 // 3
	All_Corners                     // 4
};

// NEW IN 1.60
var R6WindowListBox.eCornerType m_eCornerType;
var int m_iTotItemsDisplayed;  // the number of items displayed on the window
var bool m_bDragging;
var bool m_bCanDrag;
var bool m_bCanDragExternal;
var bool m_bActiveOverEffect;
var bool m_bIgnoreUserClicks;  // If you only want the code to determine selected elements
var bool m_bForceCaps;  // force to capital letter in draw item
var bool m_bSkipDrawBorders;
var float m_fItemHeight;  // the size of each item
var float m_fSpaceBetItem;  // the space in between item
var float m_fDragY;
var float m_fXItemOffset;  // the item X offset pos
var float m_fXItemRightPadding;  // Padding on the right of an item
var R6WindowVScrollbar m_VertSB;
var UWindowListBoxItem m_SelectedItem;
var Texture m_TIcon;  // where are the icon tex
var R6WindowListBox m_DoubleClickList;  // list to send items to on double-click
var UWindowWindow m_DoubleClickClient;  // on double click send info to this specific client
var Class<R6WindowVScrollbar> m_SBClass;
var Color m_vMouseOverWindow;  // the mouseover window border color
var Color m_vInitBorderColor;  // the initial border color (use setbordercolor fct)
var string m_szDefaultHelpText;

function Created()
{
	super.Created();
	m_VertSB = R6WindowVScrollbar(CreateWindow(m_SBClass, (WinWidth - LookAndFeel.Size_ScrollbarWidth), 0.0000000, LookAndFeel.Size_ScrollbarWidth, WinHeight));
	return;
}

function SetHelpText(string t)
{
	super(UWindowDialogControl).SetHelpText(t);
	m_szDefaultHelpText = t;
	return;
}

function Sort()
{
	Items.Sort();
	return;
}

function Paint(Canvas C, float fMouseX, float fMouseY)
{
	local R6WindowLookAndFeel LAF;
	local UWindowList CurItem;
	local float Y, fdrawWidth, fListHeight, fItemHeight;
	local int i;

	LAF = R6WindowLookAndFeel(LookAndFeel);
	CurItem = Items.Next;
	// End:0x40
	if((CurItem != none))
	{
		fItemHeight = GetSizeOfAnItem(CurItem);
	}
	fListHeight = GetSizeOfList();
	// End:0xD1
	if((m_VertSB != none))
	{
		m_VertSB.SetRange(0.0000000, float(Items.CountShown()), float(int((fListHeight / fItemHeight))));
		J0x8C:

		// End:0xD1 [Loop If]
		if(((CurItem != none) && (float(i) < m_VertSB.pos)))
		{
			(i++);
			CurItem = CurItem.Next;
			// [Loop Continue]
			goto J0x8C;
		}
	}
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
	Y = float(LAF.m_SBHBorder.H);
	J0x157:

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

function float GetSizeOfAnItem(UWindowList _pItem)
{
	local float fTotalItemHeigth;

	fTotalItemHeigth = (m_fItemHeight + m_fSpaceBetItem);
	// End:0x48
	if(UWindowListBoxItem(_pItem).m_bUseSubText)
	{
		(fTotalItemHeigth += UWindowListBoxItem(_pItem).m_stSubText.fHeight);
	}
	return fTotalItemHeigth;
	return;
}

function float GetSizeOfList()
{
	return (WinHeight - float((2 * R6WindowLookAndFeel(LookAndFeel).m_SBHBorder.H)));
	return;
}

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
				m_VertSB.WinLeft = (WinWidth - LookAndFeel.Size_ScrollbarWidth);
				// End:0x99
				break;
			// End:0x4E
			case 2:
			// End:0x53
			case 3:
			// End:0x96
			case 4:
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

function SetCornerType(R6WindowListBox.eCornerType _NewCornerType)
{
	m_eCornerType = _NewCornerType;
	Resized();
	return;
}

function UWindowListBoxItem GetItemAt(float fMouseX, float fMouseY)
{
	local R6WindowLookAndFeel LAF;
	local UWindowList CurItem;
	local float Y, fdrawWidth, fListHeight, fItemHeight;
	local int i;

	LAF = R6WindowLookAndFeel(LookAndFeel);
	// End:0x3D
	if(((m_VertSB == none) || m_VertSB.isHidden()))
	{
		fdrawWidth = WinWidth;		
	}
	else
	{
		fdrawWidth = (WinWidth - m_VertSB.WinWidth);
	}
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
	Y = float(LAF.m_SBHBorder.H);
	J0x131:

	// End:0x1DF [Loop If]
	if((((Y + fItemHeight) <= (fListHeight + float(LAF.m_SBHBorder.H))) && (CurItem != none)))
	{
		// End:0x1C8
		if(CurItem.ShowThisItem())
		{
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

function MakeSelectedVisible()
{
	local UWindowList CurItem;
	local int i;

	// End:0x0D
	if((m_VertSB == none))
	{
		return;
	}
	m_VertSB.SetRange(0.0000000, float(Items.CountShown()), float(int((GetSizeOfList() / GetSizeOfAnItem(Items.Next)))));
	// End:0x5F
	if((m_SelectedItem == none))
	{
		return;
	}
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

	m_VertSB.Show(float(i));
	return;
}

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
		Notify(2);
	}
	return;
}

function SetSelected(float X, float Y)
{
	local UWindowListBoxItem NewSelected;

	NewSelected = GetItemAt(X, Y);
	// End:0x30
	if((NewSelected != m_SelectedItem))
	{
		ClickTime = 0.0000000;
	}
	SetSelectedItem(NewSelected);
	return;
}

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
		m_bDragging = true;
		Root.CaptureMouse();
		m_fDragY = Y;
	}
	return;
}

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

function ReceiveDoubleClickItem(R6WindowListBox L, UWindowListBoxItem i)
{
	i.Remove();
	Items.AppendItem(i);
	SetSelectedItem(i);
	L.m_SelectedItem = none;
	L.Notify(1);
	Notify(1);
	return;
}

function DoubleClickItem(UWindowListBoxItem i)
{
	// End:0x0B
	if(m_bIgnoreUserClicks)
	{
		return;
	}
	Notify(11);
	// End:0x30
	if((m_DoubleClickClient != none))
	{
		m_DoubleClickClient.NotifyWindow(self, 11);
	}
	// End:0x5D
	if(((m_DoubleClickList != none) && (i != none)))
	{
		m_DoubleClickList.ReceiveDoubleClickItem(self, i);
	}
	return;
}

// overwrite UWindowWindow Mouse Enter
function MouseEnter()
{
	super(UWindowDialogControl).MouseEnter();
	// End:0x1A
	if(m_bActiveOverEffect)
	{
		m_BorderColor = m_vMouseOverWindow;
	}
	return;
}

// overwrite UWindowWindow Mouse Leave
function MouseLeave()
{
	super(UWindowDialogControl).MouseLeave();
	// End:0x1A
	if(m_bActiveOverEffect)
	{
		m_BorderColor = m_vInitBorderColor;
	}
	return;
}

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
			m_SelectedItem.Remove();
			// End:0xA3
			if((Y < m_fDragY))
			{
				OverItem.InsertItemBefore(m_SelectedItem);				
			}
			else
			{
				OverItem.InsertItemAfter(m_SelectedItem, true);
			}
			Notify(1);
			m_fDragY = Y;			
		}
		else
		{
			// End:0xF7
			if((m_bCanDragExternal && (CheckExternalDrag(X, Y) != none)))
			{
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

function MouseWheelDown(float X, float Y)
{
	// End:0x24
	if((m_VertSB != none))
	{
		m_VertSB.MouseWheelDown(X, Y);
	}
	return;
}

function MouseWheelUp(float X, float Y)
{
	// End:0x24
	if((m_VertSB != none))
	{
		m_VertSB.MouseWheelUp(X, Y);
	}
	return;
}

function bool ExternalDragOver(UWindowDialogControl ExternalControl, float X, float Y)
{
	local R6WindowListBox B;
	local UWindowListBoxItem OverItem;

	B = R6WindowListBox(ExternalControl);
	// End:0x134
	if(((B != none) && (B.m_SelectedItem != none)))
	{
		OverItem = GetItemAt(X, Y);
		B.m_SelectedItem.Remove();
		// End:0x8A
		if(__NFUN_119__(OverItem, none))
		{
			OverItem.InsertItemBefore(B.m_SelectedItem);			
		}
		else
		{
			Items.AppendItem(B.m_SelectedItem);
		}
		SetSelectedItem(B.m_SelectedItem);
		B.m_SelectedItem = none;
		B.Notify(1);
		Notify(1);
		// End:0x132
		if(__NFUN_132__(m_bCanDrag, m_bCanDragExternal))
		{
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

function DropSelection()
{
	// End:0x1C
	if(__NFUN_119__(m_SelectedItem, none))
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
function SetOverBorderColorEffect(Color _vBorderColor)
{
	m_BorderColor = _vBorderColor;
	m_vInitBorderColor = _vBorderColor;
	m_bActiveOverEffect = true;
	return;
}

//=======================================================================================================
// This function return the region where to draw the icon X and Y depending of window region
// (W and H are 0)
//=======================================================================================================
function Region CenterIconInBox(float _fX, float _fY, float _fWidth, float _fHeight, Region _RIconRegion)
{
	local Region RTemp;
	local float fTemp;

	fTemp = __NFUN_172__(__NFUN_175__(_fWidth, float(_RIconRegion.W)), float(2));
	RTemp.X = int(__NFUN_174__(_fX, float(int(__NFUN_174__(fTemp, 0.5000000)))));
	fTemp = __NFUN_172__(__NFUN_175__(_fHeight, float(_RIconRegion.H)), float(2));
	RTemp.Y = int(float(int(__NFUN_174__(fTemp, 0.5000000))));
	__NFUN_161__(RTemp.Y, int(_fY));
	return RTemp;
	return;
}

//=======================================================================================================
// GetCenterXPos: return the center pos of the region according the text size
//=======================================================================================================
function int GetCenterXPos(float _fTagWidth, float _fTextWidth)
{
	return int(__NFUN_174__(__NFUN_171__(__NFUN_175__(_fTagWidth, _fTextWidth), 0.5000000), 0.5000000));
	return;
}

function Clear()
{
	m_VertSB.pos = 0.0000000;
	m_SelectedItem = none;
	Items.Clear();
	return;
}

//=======================================================================================================
// KeyDown: manage key down for list (movements in the list...)
//=======================================================================================================
function KeyDown(int Key, float X, float Y)
{
	local UWindowListBoxItem TempItem, OldSelection;

	// End:0x57
	if(__NFUN_114__(m_SelectedItem, none))
	{
		// End:0x55
		if(__NFUN_151__(Items.Count(), 0))
		{
			TempItem = CheckForNextItem(UWindowListBoxItem(Items.Next));
			// End:0x55
			if(__NFUN_119__(TempItem, none))
			{
				SetSelectedItem(TempItem);
			}
		}
		return;
	}
	OldSelection = m_SelectedItem;
	switch(Key)
	{
		// End:0xAC
		case int(Root.Console.38):
			TempItem = CheckForPrevItem(m_SelectedItem);
			// End:0xA9
			if(__NFUN_119__(TempItem, none))
			{
				SetSelectedItem(TempItem);
			}
			// End:0x268
			break;
		// End:0xEF
		case int(Root.Console.40):
			TempItem = CheckForNextItem(m_SelectedItem);
			// End:0xEC
			if(__NFUN_119__(TempItem, none))
			{
				SetSelectedItem(TempItem);
			}
			// End:0x268
			break;
		// End:0x137
		case int(Root.Console.36):
			TempItem = CheckForNextItem(UWindowListBoxItem(Items));
			// End:0x134
			if(__NFUN_119__(TempItem, none))
			{
				SetSelectedItem(TempItem);
			}
			// End:0x268
			break;
		// End:0x188
		case int(Root.Console.35):
			TempItem = CheckForLastItem(UWindowListBoxItem(Items.Last));
			// End:0x185
			if(__NFUN_119__(TempItem, none))
			{
				SetSelectedItem(TempItem);
			}
			// End:0x268
			break;
		// End:0x1BA
		case int(Root.Console.13):
			// End:0x1B7
			if(__NFUN_129__(m_bIgnoreUserClicks))
			{
				DoubleClickItem(m_SelectedItem);
			}
			// End:0x268
			break;
		// End:0x1FD
		case int(Root.Console.34):
			TempItem = CheckForPageDown(m_SelectedItem);
			// End:0x1FA
			if(__NFUN_119__(TempItem, none))
			{
				SetSelectedItem(TempItem);
			}
			// End:0x268
			break;
		// End:0x240
		case int(Root.Console.33):
			TempItem = CheckForPageUp(m_SelectedItem);
			// End:0x23D
			if(__NFUN_119__(TempItem, none))
			{
				SetSelectedItem(TempItem);
			}
			// End:0x268
			break;
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
	// End:0x27D
	if(__NFUN_119__(OldSelection, m_SelectedItem))
	{
		MakeSelectedVisible();
	}
	super(UWindowDialogControl).KeyDown(Key, X, Y);
	return;
}

//===================================================================================
// CheckForNextItem: check for the next valid item on the list
//===================================================================================
function UWindowListBoxItem CheckForNextItem(UWindowListBoxItem _StartItem)
{
	local UWindowListBoxItem TempItem;
	local bool bIsASeparator;

	// End:0x0D
	if(__NFUN_114__(_StartItem, none))
	{
		return none;
	}
	TempItem = UWindowListBoxItem(_StartItem.Next);
	// End:0x49
	if(__NFUN_132__(__NFUN_114__(TempItem, none), __NFUN_129__(TempItem.ShowThisItem())))
	{
		return none;
	}
	// End:0x6D
	if(IsASeparatorItem())
	{
		bIsASeparator = R6WindowListBoxItem(TempItem).m_IsSeparator;
	}
	J0x6D:

	// End:0xED [Loop If]
	if(__NFUN_132__(TempItem.m_bDisabled, bIsASeparator))
	{
		TempItem = UWindowListBoxItem(TempItem.Next);
		// End:0xC6
		if(__NFUN_132__(__NFUN_114__(TempItem, none), __NFUN_129__(TempItem.ShowThisItem())))
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
//===================================================================================
function UWindowListBoxItem CheckForPrevItem(UWindowListBoxItem _StartItem)
{
	local UWindowListBoxItem TempItem;
	local bool bIsASeparator;

	// End:0x0D
	if(__NFUN_114__(_StartItem, none))
	{
		return none;
	}
	TempItem = UWindowListBoxItem(_StartItem.Prev);
	// End:0x4D
	if(__NFUN_132__(__NFUN_114__(TempItem, Items.Sentinel), __NFUN_114__(TempItem, none)))
	{
		return none;
	}
	// End:0x71
	if(IsASeparatorItem())
	{
		bIsASeparator = R6WindowListBoxItem(TempItem).m_IsSeparator;
	}
	J0x71:

	// End:0xF1 [Loop If]
	if(__NFUN_132__(TempItem.m_bDisabled, bIsASeparator))
	{
		TempItem = UWindowListBoxItem(TempItem.Prev);
		// End:0xCA
		if(__NFUN_132__(__NFUN_114__(TempItem, none), __NFUN_114__(TempItem, UWindowListBoxItem(Items))))
		{
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
//===================================================================================
function UWindowListBoxItem CheckForLastItem(UWindowListBoxItem _LastItem)
{
	local bool bIsASeparator;

	// End:0x0D
	if(__NFUN_114__(_LastItem, none))
	{
		return none;
	}
	// End:0x31
	if(IsASeparatorItem())
	{
		bIsASeparator = R6WindowListBoxItem(_LastItem).m_IsSeparator;
	}
	// End:0x5A
	if(__NFUN_132__(_LastItem.m_bDisabled, bIsASeparator))
	{
		return CheckForPrevItem(_LastItem);
	}
	return _LastItem;
	return;
}

//===================================================================================
// CheckForPageDown: check for the next page down valid item on the list
//===================================================================================
function UWindowListBoxItem CheckForPageDown(UWindowListBoxItem _StartItem)
{
	local UWindowListBoxItem TempItem, ValidItem;
	local int i, iMaxItemsDisplayed;
	local bool bIsASeparator;

	// End:0x0D
	if(__NFUN_114__(_StartItem, none))
	{
		return none;
	}
	TempItem = _StartItem;
	i = 1;
	ValidItem = TempItem;
	iMaxItemsDisplayed = int(__NFUN_172__(GetSizeOfList(), GetSizeOfAnItem(TempItem)));
	J0x45:

	// End:0xB6 [Loop If]
	if(__NFUN_150__(i, iMaxItemsDisplayed))
	{
		TempItem = UWindowListBoxItem(TempItem.Next);
		// End:0x8F
		if(__NFUN_132__(__NFUN_114__(TempItem, none), __NFUN_154__(i, m_iTotItemsDisplayed)))
		{
			return ValidItem;
		}
		// End:0xB3
		if(TempItem.ShowThisItem())
		{
			__NFUN_165__(i);
			ValidItem = TempItem;
		}
		// [Loop Continue]
		goto J0x45;
	}
	return CheckForNextItem(TempItem);
	return;
}

//===================================================================================
// CheckForPageUp: check for the next page up valid item on the list
//===================================================================================
function UWindowListBoxItem CheckForPageUp(UWindowListBoxItem _StartItem)
{
	local UWindowListBoxItem TempItem, ValidItem;
	local int i, iMaxItemsDisplayed;
	local bool bIsASeparator;

	// End:0x0D
	if(__NFUN_114__(_StartItem, none))
	{
		return none;
	}
	TempItem = _StartItem;
	i = 1;
	ValidItem = TempItem;
	iMaxItemsDisplayed = int(__NFUN_172__(GetSizeOfList(), GetSizeOfAnItem(TempItem)));
	J0x45:

	// End:0xCC [Loop If]
	if(__NFUN_150__(i, iMaxItemsDisplayed))
	{
		TempItem = UWindowListBoxItem(TempItem.Prev);
		// End:0xA5
		if(__NFUN_132__(__NFUN_132__(__NFUN_114__(TempItem, none), __NFUN_154__(i, m_iTotItemsDisplayed)), __NFUN_114__(TempItem, UWindowListBoxItem(Items))))
		{
			return ValidItem;
		}
		// End:0xC9
		if(TempItem.ShowThisItem())
		{
			__NFUN_165__(i);
			ValidItem = TempItem;
		}
		// [Loop Continue]
		goto J0x45;
	}
	return CheckForPrevItem(TempItem);
	return;
}

//===================================================================================
// SwapItem: Move an item in the list, by default is to the next element.
//			 Restrictions: Can apply swap on disable/separator item
//===================================================================================
function bool SwapItem(UWindowListBoxItem _pItem, bool _bUp)
{
	local UWindowListBoxItem TempItem, BkpItem;

	// End:0x0D
	if(__NFUN_114__(_pItem, none))
	{
		return false;
	}
	TempItem = _pItem;
	// End:0x8E
	if(_bUp)
	{
		TempItem = UWindowListBoxItem(TempItem.Prev);
		// End:0x5D
		if(__NFUN_132__(__NFUN_114__(TempItem, none), __NFUN_114__(TempItem, UWindowListBoxItem(Items))))
		{
			return false;
		}
		BkpItem = _pItem;
		_pItem.Remove();
		TempItem.InsertItemBefore(BkpItem);		
	}
	else
	{
		TempItem = UWindowListBoxItem(TempItem.Next);
		// End:0xB4
		if(__NFUN_114__(TempItem, none))
		{
			return false;
		}
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
//===================================================================================
function bool IsASeparatorItem()
{
	return __NFUN_114__(ListClass, Class'R6Window.R6WindowListBoxItem');
	return;
}

function KeyFocusEnter()
{
	SetAcceptsFocus();
	return;
}

function KeyFocusExit()
{
	CancelAcceptsFocus();
	return;
}

defaultproperties
{
	m_fItemHeight=10.0000000
	m_fSpaceBetItem=4.0000000
	m_fXItemOffset=2.0000000
	m_TIcon=Texture'R6MenuTextures.Credits.TeamBarIcon'
	m_SBClass=Class'R6Window.R6WindowVScrollbar'
	m_vMouseOverWindow=(R=129,G=209,B=239,A=0)
	ListClass=Class'UWindow.UWindowListBoxItem'
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var eCornerType
