//=============================================================================
// UWindowListControl - extracted from retail RavenShield 1.60
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
class UWindowListControl extends UWindowDialogControl;

var UWindowList Items;
var Class<UWindowList> ListClass;

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	return;
}

function Created()
{
	super.Created();
	Items = new ListClass;
	Items.Last = Items;
	Items.Next = none;
	Items.Prev = none;
	Items.Sentinel = Items;
	return;
}

function UWindowList GetItemAtIndex(int _iIndex)
{
	local UWindowList CurItem;
	local int i;

	// End:0x39
	if(__NFUN_114__(Items.Next, none))
	{
		// End:0x37
		if(__NFUN_154__(_iIndex, 0))
		{
			return Items.Append(ListClass);			
		}
		else
		{
			return none;
		}
	}
	CurItem = Items.Next;
	i = 0;
	J0x54:

	// End:0xA0 [Loop If]
	if(__NFUN_119__(CurItem, none))
	{
		// End:0x82
		if(__NFUN_154__(i, _iIndex))
		{
			CurItem.m_bShowThisItem = true;
			// [Explicit Break]
			goto J0xA0;
		}
		CurItem = CurItem.Next;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x54;
	}
	J0xA0:

	// End:0xC3
	if(__NFUN_114__(CurItem, none))
	{
		return Items.Append(ListClass);		
	}
	else
	{
		return CurItem;
	}
	return;
}

function UWindowList GetNextItem(int _iIndex, UWindowList prevItem)
{
	local UWindowList CurItem;
	local int i;

	// End:0x39
	if(__NFUN_114__(Items.Next, none))
	{
		// End:0x37
		if(__NFUN_154__(_iIndex, 0))
		{
			return Items.Append(ListClass);			
		}
		else
		{
			return none;
		}
	}
	// End:0x5B
	if(__NFUN_154__(_iIndex, 0))
	{
		CurItem = Items.Next;		
	}
	else
	{
		// End:0x7A
		if(__NFUN_119__(prevItem, none))
		{
			CurItem = prevItem.Next;
		}
	}
	// End:0x9A
	if(__NFUN_114__(CurItem, none))
	{
		return Items.Append(ListClass);
	}
	CurItem.m_bShowThisItem = true;
	return CurItem;
	return;
}

function ClearListOfItems()
{
	local UWindowList CurItem;
	local int i, iListLength;

	// End:0x16
	if(__NFUN_114__(Items.Next, none))
	{
		return;
	}
	CurItem = Items.Next;
	iListLength = Items.Count();
	i = 0;
	J0x46:

	// End:0x93 [Loop If]
	if(__NFUN_150__(i, iListLength))
	{
		// End:0x86
		if(__NFUN_119__(CurItem, none))
		{
			CurItem.ClearItem();
			CurItem = CurItem.Next;
			// [Explicit Continue]
			goto J0x89;
		}
		// [Explicit Break]
		goto J0x93;
		J0x89:

		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x46;
	}
	J0x93:

	return;
}

