//=============================================================================
// R6WindowListMODS - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowListMODS.uc : List of all MODS
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/05/20 * Created by Yannick Joly
//=============================================================================
class R6WindowListMODS extends R6WindowTextListBox;

enum eItemState
{
	eIS_Normal,                     // 0
	eIS_Disable,                    // 1
	eIS_Selected,                   // 2
	eIS_CurrentChoice               // 3
};

var Color m_CurrentChoiceColor;  // color for current choice text (item)

function Created()
{
	super.Created();
	m_CurrentChoiceColor = Root.Colors.Yellow;
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
	// End:0x10B
	if(((m_VertSB == none) || m_VertSB.isHidden()))
	{
		fdrawWidth = (WinWidth - (float(2) * m_fXItemOffset));		
	}
	else
	{
		fdrawWidth = ((WinWidth - m_VertSB.WinWidth) - (float(2) * m_fXItemOffset));
	}
	m_iTotItemsDisplayed = 0;
	Y = 0.0000000;
	J0x145:

	// End:0x1CE [Loop If]
	if((((Y + fItemHeight) <= fListHeight) && (CurItem != none)))
	{
		// End:0x1B7
		if(CurItem.ShowThisItem())
		{
			DrawItem(C, CurItem, m_fXItemOffset, Y, fdrawWidth, fItemHeight);
			Y = (Y + fItemHeight);
			(m_iTotItemsDisplayed++);
		}
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0x145;
	}
	return;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local UWindowListBoxItem pIt;
	local string szToDisplay;
	local float tW, tH, fYPos;
	local int i, j;
	local stItemProperties pCurrentItem;

	pIt = UWindowListBoxItem(Item);
	// End:0x34
	if(((pIt != none) && (pIt.m_AItemProperties.Length == 0)))
	{
		return;
	}
	// End:0xE3
	if(pIt.bSelected)
	{
		// End:0xE3
		if((m_BGSelTexture != none))
		{
			C.Style = m_BGRenderStyle;
			C.SetDrawColor(m_BGSelColor.R, m_BGSelColor.G, m_BGSelColor.B);
			DrawStretchedTextureSegment(C, X, Y, W, H, float(m_BGSelRegion.X), float(m_BGSelRegion.Y), float(m_BGSelRegion.W), float(m_BGSelRegion.H), m_BGSelTexture);
		}
	}
	i = 0;
	J0xEA:

	// End:0x3AE [Loop If]
	if((i < pIt.m_AItemProperties.Length))
	{
		pCurrentItem = pIt.m_AItemProperties[i];
		C.Font = pCurrentItem.TextFont;
		C.SpaceX = m_fFontSpacing;
		// End:0x189
		if(m_bForceCaps)
		{
			szToDisplay = TextSize(C, Caps(pCurrentItem.szText), tW, tH, int(pCurrentItem.fWidth));			
		}
		else
		{
			szToDisplay = TextSize(C, pCurrentItem.szText, tW, tH, int(pCurrentItem.fWidth));
		}
		// End:0x1F9
		if(pIt.m_bDisabled)
		{
			C.SetDrawColor(m_DisableTextColor.R, m_DisableTextColor.G, m_DisableTextColor.B);			
		}
		else
		{
			// End:0x23D
			if((pIt.m_iItemID == int(3)))
			{
				C.SetDrawColor(m_CurrentChoiceColor.R, m_CurrentChoiceColor.G, m_CurrentChoiceColor.B);				
			}
			else
			{
				C.SetDrawColor(TextColor.R, TextColor.G, TextColor.B);
			}
		}
		fYPos = ((pCurrentItem.fHeigth - tH) / float(2));
		fYPos = float(int((fYPos + 0.5000000)));
		(fYPos += pCurrentItem.fYPos);
		// End:0x2F1
		if((pCurrentItem.iLineNumber != 0))
		{
			j = 0;
			J0x2C2:

			// End:0x2F1 [Loop If]
			if((j < pCurrentItem.iLineNumber))
			{
				(fYPos += pCurrentItem.fHeigth);
				(j++);
				// [Loop Continue]
				goto J0x2C2;
			}
		}
		switch(pCurrentItem.eAlignment)
		{
			// End:0x32E
			case 1:
				C.SetPos((pCurrentItem.fXPos - tW), (Y + fYPos));
				// End:0x393
				break;
			// End:0x358
			case 0:
				C.SetPos(pCurrentItem.fXPos, (Y + fYPos));
				// End:0x393
				break;
			// End:0x390
			case 2:
				C.SetPos((pCurrentItem.fXPos - (tW / 2.0000000)), (Y + fYPos));
				// End:0x393
				break;
			// End:0xFFFF
			default:
				break;
		}
		C.DrawText(szToDisplay);
		(i++);
		// [Loop Continue]
		goto J0xEA;
	}
	return;
}

// For not rewrite the class R6WindowListBox with the new system of item properties, hack the value
// over here
function float GetSizeOfAnItem(UWindowList _pItem)
{
	local float fTotalHeight;
	local int i, iLineNumber;

	iLineNumber = 0;
	i = 0;
	J0x0E:

	// End:0x8A [Loop If]
	if((i < UWindowListBoxItem(_pItem).m_AItemProperties.Length))
	{
		// End:0x80
		if((UWindowListBoxItem(_pItem).m_AItemProperties[i].iLineNumber == iLineNumber))
		{
			(iLineNumber++);
			(fTotalHeight += UWindowListBoxItem(_pItem).m_AItemProperties[i].fHeigth);
		}
		(i++);
		// [Loop Continue]
		goto J0x0E;
	}
	return fTotalHeight;
	return;
}

function SetSelectedItem(UWindowListBoxItem NewSelected)
{
	local bool bNotify;

	// End:0x10D
	if(((NewSelected != none) && (m_SelectedItem != NewSelected)))
	{
		// End:0x30
		if(NewSelected.m_bDisabled)
		{
			return;
		}
		bNotify = true;
		// End:0x65
		if((R6WindowListBoxItem(NewSelected) != none))
		{
			bNotify = (!R6WindowListBoxItem(NewSelected).m_IsSeparator);
		}
		// End:0x10D
		if(bNotify)
		{
			// End:0xB4
			if((m_SelectedItem != none))
			{
				m_SelectedItem.bSelected = false;
				// End:0xB4
				if((m_SelectedItem.m_iItemID != int(3)))
				{
					m_SelectedItem.m_iItemID = int(0);
				}
			}
			m_SelectedItem = NewSelected;
			// End:0x105
			if((m_SelectedItem != none))
			{
				m_SelectedItem.bSelected = true;
				// End:0x105
				if((m_SelectedItem.m_iItemID != int(3)))
				{
					m_SelectedItem.m_iItemID = int(2);
				}
			}
			Notify(2);
		}
	}
	return;
}

//=====================================================================================
// SetItemState: Set the item state, return true when succeed operation 
//=====================================================================================
function bool SetItemState(UWindowListBoxItem _NewItem, R6WindowListMODS.eItemState _eISState, optional bool _bForceSelection)
{
	// End:0x0D
	if((_NewItem == none))
	{
		return false;
	}
	_NewItem.m_bDisabled = false;
	switch(_eISState)
	{
		// End:0x40
		case 0:
			_NewItem.m_iItemID = int(0);
			// End:0xE6
			break;
		// End:0x6C
		case 1:
			_NewItem.m_iItemID = int(1);
			_NewItem.m_bDisabled = true;
			// End:0xE6
			break;
		// End:0xA3
		case 2:
			_NewItem.m_iItemID = int(2);
			_NewItem.bSelected = true;
			m_SelectedItem = _NewItem;
			// End:0xE6
			break;
		// End:0xE3
		case 3:
			_NewItem.m_iItemID = int(3);
			// End:0xE0
			if(_bForceSelection)
			{
				_NewItem.bSelected = true;
				m_SelectedItem = _NewItem;
			}
			// End:0xE6
			break;
		// End:0xFFFF
		default:
			break;
	}
	return true;
	return;
}

//=====================================================================================
// ActivateMOD: Activate the current selection to be the current choice 
//=====================================================================================
function ActivateMOD()
{
	local array<UWindowRootWindow.eGameWidgetID> AWIDList;
	local UWindowListBoxItem pListBoxItem;

	pListBoxItem = UWindowListBoxItem(FindCurrentMOD());
	// End:0xFE
	if((pListBoxItem != none))
	{
		// End:0x2D
		if((pListBoxItem == m_SelectedItem))
		{
			return;
		}
		pListBoxItem.m_iItemID = int(0);
		// End:0xFE
		if((m_SelectedItem != none))
		{
			m_SelectedItem.m_iItemID = int(3);
			Class'Engine.Actor'.static.GetModMgr().SetCurrentMod(m_SelectedItem.HelpText, GetLevel(), true, Root.Console, GetPlayerOwner().XLevel);
			Class'Engine.Actor'.static.NativeRegServerServerClose();
			AWIDList[AWIDList.Length] = Root.m_ePrevWidgetInUse;
			AWIDList[AWIDList.Length] = 16;
			R6Console(Root.Console).CleanAndChangeMod(AWIDList);
		}
	}
	return;
}

//=====================================================================================
// FindCurrentMOD: Find item of the current MOD 
//=====================================================================================
function UWindowList FindCurrentMOD()
{
	local UWindowList CurItem;

	CurItem = Items.Next;
	J0x14:

	// End:0x6E [Loop If]
	if(__NFUN_119__(CurItem, none))
	{
		// End:0x57
		if(__NFUN_129__(R6WindowListBoxItem(CurItem).m_IsSeparator))
		{
			// End:0x57
			if(__NFUN_154__(R6WindowListBoxItem(CurItem).m_iItemID, int(3)))
			{
				// [Explicit Break]
				goto J0x6E;
			}
		}
		CurItem = CurItem.Next;
		// [Loop Continue]
		goto J0x14;
	}
	J0x6E:

	return CurItem;
	return;
}

defaultproperties
{
	m_fXItemOffset=2.0000000
	ListClass=Class'UWindow.UWindowListBoxItem'
}
