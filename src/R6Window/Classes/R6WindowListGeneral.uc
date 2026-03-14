//=============================================================================
// R6WindowListGeneral - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// UWindowListControl - Abstract class for list controls
//	- List boxes
//	- Dropdown Menus
//	- Combo Boxes, etc
//=============================================================================
class R6WindowListGeneral extends UWindowListControl;

var float m_fItemWidth;
var float m_fItemHeight;
var float m_fStepBetweenItem;

function Paint(Canvas C, float X, float Y)
{
	local float fX, fY;
	local UWindowList CurItem;

	// End:0x18
	if(__NFUN_180__(m_fItemWidth, float(0)))
	{
		m_fItemWidth = WinWidth;
	}
	fX = __NFUN_172__(__NFUN_175__(WinWidth, m_fItemWidth), float(2));
	CurItem = Items.Next;
	J0x44:

	// End:0xDC [Loop If]
	if(__NFUN_119__(CurItem, none))
	{
		// End:0x8C
		if(__NFUN_129__(R6WindowListGeneralItem(CurItem).m_bFakeItem))
		{
			DrawItem(C, CurItem, fX, fY, m_fItemWidth, m_fItemHeight);
		}
		__NFUN_184__(fY, __NFUN_174__(m_fItemHeight, m_fStepBetweenItem));
		// End:0xC5
		if(__NFUN_179__(fY, WinHeight))
		{
			fY = 0.0000000;
			__NFUN_184__(fX, WinWidth);
		}
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0x44;
	}
	return;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local R6WindowListGeneralItem pListGenItem;

	pListGenItem = R6WindowListGeneralItem(Item);
	// End:0x8C
	if(__NFUN_119__(pListGenItem.m_pR6WindowCounter, none))
	{
		pListGenItem.m_pR6WindowCounter.WinLeft = __NFUN_174__(WinLeft, X);
		pListGenItem.m_pR6WindowCounter.WinTop = __NFUN_174__(WinTop, Y);
		pListGenItem.m_pR6WindowCounter.WinHeight = H;		
	}
	else
	{
		// End:0x108
		if(__NFUN_119__(pListGenItem.m_pR6WindowButtonBox, none))
		{
			pListGenItem.m_pR6WindowButtonBox.WinLeft = __NFUN_174__(WinLeft, X);
			pListGenItem.m_pR6WindowButtonBox.WinTop = __NFUN_174__(WinTop, Y);
			pListGenItem.m_pR6WindowButtonBox.WinHeight = H;			
		}
		else
		{
			// End:0x181
			if(__NFUN_119__(pListGenItem.m_pR6WindowComboControl, none))
			{
				pListGenItem.m_pR6WindowComboControl.WinLeft = __NFUN_174__(WinLeft, X);
				pListGenItem.m_pR6WindowComboControl.WinTop = __NFUN_174__(WinTop, Y);
				pListGenItem.m_pR6WindowComboControl.WinHeight = H;
			}
		}
	}
	return;
}

function RemoveAllItems()
{
	local R6WindowListGeneralItem ItemIndex;

	ItemIndex = R6WindowListGeneralItem(Items.Next);
	J0x19:

	// End:0xD9 [Loop If]
	if(__NFUN_119__(ItemIndex, none))
	{
		// End:0x53
		if(__NFUN_119__(ItemIndex.m_pR6WindowCounter, none))
		{
			ItemIndex.m_pR6WindowCounter.HideWindow();			
		}
		else
		{
			// End:0x82
			if(__NFUN_119__(ItemIndex.m_pR6WindowButtonBox, none))
			{
				ItemIndex.m_pR6WindowButtonBox.HideWindow();				
			}
			else
			{
				// End:0xAE
				if(__NFUN_119__(ItemIndex.m_pR6WindowComboControl, none))
				{
					ItemIndex.m_pR6WindowComboControl.HideWindow();
				}
			}
		}
		ItemIndex.Remove();
		ItemIndex = R6WindowListGeneralItem(Items.Next);
		// [Loop Continue]
		goto J0x19;
	}
	return;
}

function ChangeVisualItems(bool _bVisible)
{
	local UWindowList i;

	// End:0x16D
	if(__NFUN_119__(Items.Next, none))
	{
		i = Items.Next;
		J0x28:

		// End:0x16D [Loop If]
		if(__NFUN_119__(i, none))
		{
			// End:0x95
			if(__NFUN_119__(R6WindowListGeneralItem(i).m_pR6WindowCounter, none))
			{
				// End:0x75
				if(_bVisible)
				{
					R6WindowListGeneralItem(i).m_pR6WindowCounter.ShowWindow();					
				}
				else
				{
					R6WindowListGeneralItem(i).m_pR6WindowCounter.HideWindow();
				}				
			}
			else
			{
				// End:0xF7
				if(__NFUN_119__(R6WindowListGeneralItem(i).m_pR6WindowButtonBox, none))
				{
					// End:0xD7
					if(_bVisible)
					{
						R6WindowListGeneralItem(i).m_pR6WindowButtonBox.ShowWindow();						
					}
					else
					{
						R6WindowListGeneralItem(i).m_pR6WindowButtonBox.HideWindow();
					}					
				}
				else
				{
					// End:0x156
					if(__NFUN_119__(R6WindowListGeneralItem(i).m_pR6WindowComboControl, none))
					{
						// End:0x139
						if(_bVisible)
						{
							R6WindowListGeneralItem(i).m_pR6WindowComboControl.ShowWindow();							
						}
						else
						{
							R6WindowListGeneralItem(i).m_pR6WindowComboControl.HideWindow();
						}
					}
				}
			}
			i = i.Next;
			// [Loop Continue]
			goto J0x28;
		}
	}
	return;
}

defaultproperties
{
	m_fItemHeight=15.0000000
	m_fStepBetweenItem=1.0000000
	ListClass=Class'R6Window.R6WindowListGeneralItem'
}
