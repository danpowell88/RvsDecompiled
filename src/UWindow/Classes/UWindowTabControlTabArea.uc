//=============================================================================
// UWindowTabControlTabArea - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowTabControlTabArea extends UWindowWindow
    config;

enum eTabCase
{
	eTab_Left,                      // 0
	eTab_Middle,                    // 1
	eTab_Right,                     // 2
	eTab_Left_RightCut,             // 3
	eTab_Middle_RightCut            // 4
};

var UWindowTabControlTabArea.eTabCase m_eTabCase;
var int TabOffset;
var int TabRows;
var int m_iTotalTab;
var globalconfig bool bArrangeRowsLikeTimHates;
var bool bShowSelected;
var bool bDragging;
var bool bFlashShown;
var bool m_bDisplayToolTip;  // display a tool tip for a item
var float UnFlashTime;
var UWindowTabControlItem FirstShown;
var UWindowTabControlItem DragTab;
var Color m_vEffectColor;

function Created()
{
	TabOffset = 0;
	return;
}

function SizeTabsSingleLine(Canvas C)
{
	local UWindowTabControlItem i, Selected, LastHidden;
	local int Count, TabCount;
	local float ItemX, W, H, fTotalTabsWidth;
	local bool bHaveMore;

	ItemX = LookAndFeel.Size_TabXOffset;
	TabCount = 0;
	i = UWindowTabControlItem(UWindowTabControl(ParentWindow).Items.Next);
	J0x42:

	// End:0x172 [Loop If]
	if((i != none))
	{
		LookAndFeel.Tab_GetTabSize(self, C, RemoveAmpersand(i.Caption), W, H);
		i.TabWidth = W;
		// End:0xC7
		if((i.m_fFixWidth != float(0)))
		{
			i.TabWidth = i.m_fFixWidth;
		}
		(fTotalTabsWidth += i.TabWidth);
		// End:0x112
		if((fTotalTabsWidth > WinWidth))
		{
			(i.TabWidth -= (fTotalTabsWidth - WinWidth));
			fTotalTabsWidth = WinWidth;
		}
		i.TabHeight = (H + float(1));
		i.TabTop = 0.0000000;
		i.RowNumber = 0;
		(TabCount++);
		i = UWindowTabControlItem(i.Next);
		// [Loop Continue]
		goto J0x42;
	}
	m_iTotalTab = TabCount;
	Selected = UWindowTabControl(ParentWindow).SelectedTab;
	J0x196:

	// End:0x38D [Loop If]
	if(true)
	{
		ItemX = LookAndFeel.Size_TabXOffset;
		Count = 0;
		LastHidden = none;
		FirstShown = none;
		i = UWindowTabControlItem(UWindowTabControl(ParentWindow).Items.Next);
		J0x1EA:

		// End:0x2C9 [Loop If]
		if((i != none))
		{
			// End:0x226
			if((Count < TabOffset))
			{
				i.TabLeft = -1.0000000;
				LastHidden = i;				
			}
			else
			{
				// End:0x23C
				if((FirstShown == none))
				{
					FirstShown = i;
				}
				i.TabLeft = ItemX;
				// End:0x286
				if(((i.TabLeft + i.TabWidth) >= (WinWidth + float(5))))
				{
					bHaveMore = true;
				}
				(ItemX += i.TabWidth);
				(ItemX -= float(15));
			}
			(Count++);
			i = UWindowTabControlItem(i.Next);
			// [Loop Continue]
			goto J0x1EA;
		}
		// End:0x312
		if((((TabOffset > 0) && (LastHidden != none)) && ((LastHidden.TabWidth + float(5)) < (WinWidth - ItemX))))
		{
			(TabOffset--);			
		}
		else
		{
			// End:0x387
			if(((((bShowSelected && (TabOffset < (TabCount - 1))) && (Selected != none)) && (Selected != FirstShown)) && ((Selected.TabLeft + Selected.TabWidth) > (WinWidth - float(5)))))
			{
				(TabOffset++);				
			}
			else
			{
				// [Explicit Break]
				goto J0x38D;
			}
		}
		// [Loop Continue]
		goto J0x196;
	}
	J0x38D:

	bShowSelected = false;
	// End:0x3F8
	if(UWindowTabControl(ParentWindow).m_bTabButton)
	{
		UWindowTabControl(ParentWindow).LeftButton.bDisabled = (TabOffset <= 0);
		UWindowTabControl(ParentWindow).RightButton.bDisabled = (!bHaveMore);
	}
	TabRows = 1;
	return;
}

function SizeTabsMultiLine(Canvas C)
{
	local UWindowTabControlItem i, Selected;
	local float W, H;
	local int MinRow;
	local float RowWidths[10];
	local int TabCounts[10], j;
	local bool bTryAnotherRow;

	TabOffset = 0;
	FirstShown = none;
	TabRows = 1;
	bTryAnotherRow = true;
	J0x1D:

	// End:0x1D7 [Loop If]
	if((bTryAnotherRow && (TabRows <= 10)))
	{
		bTryAnotherRow = false;
		j = 0;
		J0x43:

		// End:0x7A [Loop If]
		if((j < TabRows))
		{
			RowWidths[j] = 0.0000000;
			TabCounts[j] = 0;
			(j++);
			// [Loop Continue]
			goto J0x43;
		}
		i = UWindowTabControlItem(UWindowTabControl(ParentWindow).Items.Next);
		J0xA1:

		// End:0x1D4 [Loop If]
		if((i != none))
		{
			LookAndFeel.Tab_GetTabSize(self, C, RemoveAmpersand(i.Caption), W, H);
			i.TabWidth = W;
			i.TabHeight = H;
			MinRow = 0;
			j = 1;
			J0x115:

			// End:0x154 [Loop If]
			if((j < TabRows))
			{
				// End:0x14A
				if((RowWidths[j] < RowWidths[MinRow]))
				{
					MinRow = j;
				}
				(j++);
				// [Loop Continue]
				goto J0x115;
			}
			// End:0x185
			if(((RowWidths[MinRow] + W) > WinWidth))
			{
				(TabRows++);
				bTryAnotherRow = true;
				// [Explicit Break]
				goto J0x1D4;				
			}
			else
			{
				(RowWidths[MinRow] += W);
				(TabCounts[MinRow]++);
				i.RowNumber = MinRow;
			}
			i = UWindowTabControlItem(i.Next);
			// [Loop Continue]
			goto J0xA1;
		}
		J0x1D4:

		// [Loop Continue]
		goto J0x1D;
	}
	Selected = UWindowTabControl(ParentWindow).SelectedTab;
	// End:0x28C
	if((TabRows > 1))
	{
		i = UWindowTabControlItem(UWindowTabControl(ParentWindow).Items.Next);
		J0x222:

		// End:0x28C [Loop If]
		if((i != none))
		{
			(i.TabWidth += ((WinWidth - RowWidths[i.RowNumber]) / float(TabCounts[i.RowNumber])));
			i = UWindowTabControlItem(i.Next);
			// [Loop Continue]
			goto J0x222;
		}
	}
	j = 0;
	J0x293:

	// End:0x2BD [Loop If]
	if((j < TabRows))
	{
		RowWidths[j] = 0.0000000;
		(j++);
		// [Loop Continue]
		goto J0x293;
	}
	i = UWindowTabControlItem(UWindowTabControl(ParentWindow).Items.Next);
	J0x2E4:

	// End:0x3DF [Loop If]
	if((i != none))
	{
		i.TabLeft = RowWidths[i.RowNumber];
		// End:0x370
		if(bArrangeRowsLikeTimHates)
		{
			i.TabTop = ((float((i.RowNumber + ((TabRows - 1) - Selected.RowNumber))) % float(TabRows)) * i.TabHeight);			
		}
		else
		{
			i.TabTop = (float(i.RowNumber) * i.TabHeight);
		}
		(RowWidths[i.RowNumber] += i.TabWidth);
		i = UWindowTabControlItem(i.Next);
		// [Loop Continue]
		goto J0x2E4;
	}
	return;
}

function LayoutTabs(Canvas C)
{
	// End:0x25
	if(UWindowTabControl(ParentWindow).bMultiLine)
	{
		SizeTabsMultiLine(C);		
	}
	else
	{
		SizeTabsSingleLine(C);
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local UWindowTabControlItem i, ITemp;
	local int Count, Row, iTabNumber;
	local float t;
	local bool bNextTabSelected, bPrevTabSelected;

	t = GetEntryLevel().TimeSeconds;
	// End:0x63
	if((UnFlashTime < t))
	{
		bFlashShown = (!bFlashShown);
		// End:0x51
		if(bFlashShown)
		{
			UnFlashTime = (t + 0.5000000);			
		}
		else
		{
			UnFlashTime = (t + 0.3000000);
		}
	}
	Row = 0;
	J0x6A:

	// End:0x246 [Loop If]
	if((Row < TabRows))
	{
		Count = 0;
		iTabNumber = 0;
		m_eTabCase = 0;
		i = UWindowTabControlItem(UWindowTabControl(ParentWindow).Items.Next);
		J0xB6:

		// End:0x23C [Loop If]
		if((i != none))
		{
			// End:0xDA
			if((Count < TabOffset))
			{
				(Count++);				
			}
			else
			{
				// End:0x220
				if((i.RowNumber == Row))
				{
					bNextTabSelected = false;
					// End:0x12D
					if((UWindowTabControlItem(i.Next) == UWindowTabControl(ParentWindow).SelectedTab))
					{
						bNextTabSelected = true;
					}
					// End:0x160
					if(__NFUN_114__(UWindowTabControlItem(i.Prev), UWindowTabControl(ParentWindow).SelectedTab))
					{
						bPrevTabSelected = true;
					}
					// End:0x1A4
					if(__NFUN_151__(iTabNumber, 0))
					{
						// End:0x188
						if(__NFUN_154__(iTabNumber, __NFUN_147__(m_iTotalTab, 1)))
						{
							m_eTabCase = 2;							
						}
						else
						{
							m_eTabCase = 1;
							// End:0x1A1
							if(bNextTabSelected)
							{
								m_eTabCase = 4;
							}
						}						
					}
					else
					{
						// End:0x1B5
						if(bNextTabSelected)
						{
							m_eTabCase = 3;
						}
					}
					DrawItem(C, i, i.TabLeft, i.TabTop, i.TabWidth, i.TabHeight, __NFUN_132__(__NFUN_129__(i.bFlash), bFlashShown));
					__NFUN_165__(iTabNumber);
				}
			}
			i = UWindowTabControlItem(i.Next);
			// [Loop Continue]
			goto J0xB6;
		}
		__NFUN_165__(Row);
		// [Loop Continue]
		goto J0x6A;
	}
	return;
}

function LMouseDown(float X, float Y)
{
	local UWindowTabControlItem i;
	local int Count;

	super.LMouseDown(X, Y);
	Count = 0;
	i = UWindowTabControlItem(UWindowTabControl(ParentWindow).Items.Next);
	J0x3E:

	// End:0x166 [Loop If]
	if(__NFUN_119__(i, none))
	{
		// End:0x62
		if(__NFUN_150__(Count, TabOffset))
		{
			__NFUN_165__(Count);			
		}
		else
		{
			// End:0x14A
			if(__NFUN_130__(__NFUN_130__(__NFUN_179__(X, i.TabLeft), __NFUN_178__(X, __NFUN_174__(i.TabLeft, i.TabWidth))), __NFUN_132__(__NFUN_154__(TabRows, 1), __NFUN_130__(__NFUN_179__(Y, i.TabTop), __NFUN_178__(Y, __NFUN_174__(i.TabTop, i.TabHeight))))))
			{
				// End:0x130
				if(__NFUN_129__(UWindowTabControl(ParentWindow).bMultiLine))
				{
					bDragging = true;
					DragTab = i;
					Root.CaptureMouse();
				}
				UWindowTabControl(ParentWindow).GotoTab(i, true);
			}
		}
		i = UWindowTabControlItem(i.Next);
		// [Loop Continue]
		goto J0x3E;
	}
	return;
}

function MouseLeave()
{
	super.MouseLeave();
	ResetMouseOverOnItem();
	return;
}

function MouseMove(float X, float Y)
{
	CheckToolTip(X, Y);
	// End:0x82
	if(__NFUN_130__(bDragging, bMouseDown))
	{
		// End:0x43
		if(__NFUN_176__(X, DragTab.TabLeft))
		{
			__NFUN_165__(TabOffset);
		}
		// End:0x7F
		if(__NFUN_130__(__NFUN_177__(X, __NFUN_174__(DragTab.TabLeft, DragTab.TabWidth)), __NFUN_151__(TabOffset, 0)))
		{
			__NFUN_166__(TabOffset);
		}		
	}
	else
	{
		bDragging = false;
	}
	return;
}

function RMouseDown(float X, float Y)
{
	local UWindowTabControlItem i;
	local int Count;

	LMouseDown(X, Y);
	Count = 0;
	i = UWindowTabControlItem(UWindowTabControl(ParentWindow).Items.Next);
	J0x3E:

	// End:0xCF [Loop If]
	if(__NFUN_119__(i, none))
	{
		// End:0x62
		if(__NFUN_150__(Count, TabOffset))
		{
			__NFUN_165__(Count);			
		}
		else
		{
			// End:0xB3
			if(__NFUN_130__(__NFUN_179__(X, i.TabLeft), __NFUN_178__(X, __NFUN_174__(i.TabLeft, i.TabWidth))))
			{
				i.RightClickTab();
			}
		}
		i = UWindowTabControlItem(i.Next);
		// [Loop Continue]
		goto J0x3E;
	}
	return;
}

//===================================================================
// draw the tab-item
//===================================================================
function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H, bool bShowText)
{
	local UWindowTabControlItem pTabControlItem;

	pTabControlItem = UWindowTabControlItem(Item);
	m_bDisplayToolTip = pTabControlItem.m_bMouseOverItem;
	// End:0xA4
	if(__NFUN_114__(Item, UWindowTabControl(ParentWindow).SelectedTab))
	{
		m_vEffectColor = pTabControlItem.m_vSelectedColor;
		LookAndFeel.Tab_DrawTab(self, C, true, __NFUN_114__(FirstShown, Item), X, Y, W, H, pTabControlItem.Caption, bShowText);		
	}
	else
	{
		m_vEffectColor = pTabControlItem.m_vNormalColor;
		LookAndFeel.Tab_DrawTab(self, C, false, __NFUN_114__(FirstShown, Item), X, Y, W, H, pTabControlItem.Caption, bShowText);
	}
	return;
}

function bool CheckMousePassThrough(float X, float Y)
{
	return __NFUN_179__(Y, __NFUN_171__(LookAndFeel.Size_TabAreaHeight, float(TabRows)));
	return;
}

//===================================================================
// check if the mouse is over an item
//===================================================================
function UWindowTabControlItem CheckMouseOverOnItem(float _fX, float _fY)
{
	local UWindowTabControlItem i, ItemTemp;
	local int Count;
	local float fXMin, fXMax;

	ItemTemp = none;
	Count = 0;
	i = UWindowTabControlItem(UWindowTabControl(ParentWindow).Items.Next);
	J0x35:

	// End:0x15A [Loop If]
	if(__NFUN_119__(i, none))
	{
		// End:0x59
		if(__NFUN_150__(Count, TabOffset))
		{
			__NFUN_165__(Count);			
		}
		else
		{
			fXMin = __NFUN_174__(i.TabLeft, float(10));
			fXMax = __NFUN_175__(__NFUN_174__(i.TabLeft, i.TabWidth), float(18));
			// End:0x12D
			if(__NFUN_130__(__NFUN_130__(__NFUN_179__(_fX, fXMin), __NFUN_178__(_fX, fXMax)), __NFUN_132__(__NFUN_154__(TabRows, 1), __NFUN_130__(__NFUN_179__(_fY, i.TabTop), __NFUN_178__(_fY, __NFUN_174__(i.TabTop, i.TabHeight))))))
			{
				ItemTemp = i;
				i.m_bMouseOverItem = true;				
			}
			else
			{
				i.m_bMouseOverItem = false;
			}
		}
		i = UWindowTabControlItem(i.Next);
		// [Loop Continue]
		goto J0x35;
	}
	return ItemTemp;
	return;
}

//===================================================================
// put all the mouseoveritem bool at false
//===================================================================
function ResetMouseOverOnItem()
{
	local UWindowTabControlItem i;
	local int Count;

	Count = 0;
	i = UWindowTabControlItem(UWindowTabControl(ParentWindow).Items.Next);
	J0x2E:

	// End:0x7F [Loop If]
	if(__NFUN_119__(i, none))
	{
		// End:0x52
		if(__NFUN_150__(Count, TabOffset))
		{
			__NFUN_165__(Count);			
		}
		else
		{
			i.m_bMouseOverItem = false;
		}
		i = UWindowTabControlItem(i.Next);
		// [Loop Continue]
		goto J0x2E;
	}
	ParentWindow.ToolTip("");
	return;
}

//===================================================================
// check if the mouse is over an item and display a tool tip when is required
//===================================================================
function CheckToolTip(float _fX, float _fY)
{
	local UWindowTabControlItem Item;

	Item = CheckMouseOverOnItem(_fX, _fY);
	// End:0x6A
	if(__NFUN_119__(Item, none))
	{
		// End:0x67
		if(__NFUN_130__(Item.m_bMouseOverItem, __NFUN_123__(Item.HelpText, "")))
		{
			ParentWindow.ToolTip(Item.HelpText);
		}		
	}
	else
	{
		ParentWindow.ToolTip("");
	}
	return;
}

