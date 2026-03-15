//=============================================================================
// R6WindowListBoxItem - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6WindowListBoxItem.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/25 * Created by Alexandre Dionne
//=============================================================================
class R6WindowListBoxItem extends UWindowListBoxItem;

var int m_iSeparatorID;  // To help manage insertions and removal of
var bool m_IsSeparator;
                                                //items between Separators;
var bool m_addedToSubList;  // Item as been added to a sub List
var Texture m_Icon;
var R6WindowListBoxItem m_ParentListItem;  // Item from wich this one has been added to a sub list
var Object m_Object;  // Object or actor associated with this element
var Region m_IconRegion;
var Region m_IconSelectedRegion;  // To get icons to higlight when selected
var string m_szMisc;  // a misc purpose string

//If this functions returns None well it could'nt find the designated separator
function R6WindowListBoxItem AppendAfterSeparator(Class<R6WindowListBoxItem> C, int iSeparatorID)
{
	local UWindowList NewElement, TempItem;
	local R6WindowListBoxItem workItem;

	TempItem = Next;
	J0x0B:

	// End:0x9D [Loop If]
	if(((TempItem != none) && (NewElement == none)))
	{
		workItem = R6WindowListBoxItem(TempItem);
		// End:0x86
		if((((workItem != none) && workItem.m_IsSeparator) && (workItem.m_iSeparatorID == iSeparatorID)))
		{
			NewElement = workItem.InsertAfter(Class'R6Window.R6WindowListBoxItem');
		}
		TempItem = TempItem.Next;
		// [Loop Continue]
		goto J0x0B;
	}
	return R6WindowListBoxItem(NewElement);
	return;
}

//If this functions returns None well it could'nt find the designated separator
function R6WindowListBoxItem InsertLastAfterSeparator(Class<R6WindowListBoxItem> C, int iSeparatorID)
{
	local UWindowList NewElement, TempItem, LastItem;
	local R6WindowListBoxItem workItem, Separator;
	local bool bSeparatorFound;

	TempItem = Next;
	J0x0B:

	// End:0xA2 [Loop If]
	if(((TempItem != none) && (bSeparatorFound == false)))
	{
		workItem = R6WindowListBoxItem(TempItem);
		// End:0x80
		if((((workItem != none) && workItem.m_IsSeparator) && (workItem.m_iSeparatorID == iSeparatorID)))
		{
			Separator = workItem;
			bSeparatorFound = true;
		}
		LastItem = TempItem;
		TempItem = TempItem.Next;
		// [Loop Continue]
		goto J0x0B;
	}
	J0xA2:

	// End:0xEB [Loop If]
	if(((TempItem != none) && (R6WindowListBoxItem(TempItem).m_IsSeparator == false)))
	{
		LastItem = TempItem;
		TempItem = TempItem.Next;
		// [Loop Continue]
		goto J0xA2;
	}
	NewElement = LastItem.InsertAfter(Class'R6Window.R6WindowListBoxItem');
	return R6WindowListBoxItem(NewElement);
	return;
}

//Call this on the sentinel
function int FindItemIndex(UWindowList Item)
{
	local UWindowList L;
	local int i;

	L = Next;
	i = 0;
	J0x12:

	// End:0x55 [Loop If]
	if((i < Count()))
	{
		// End:0x37
		if((L == Item))
		{
			return i;
		}
		L = L.Next;
		(i++);
		// [Loop Continue]
		goto J0x12;
	}
	return -1;
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function Compare
