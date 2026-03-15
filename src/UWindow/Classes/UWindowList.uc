//=============================================================================
// UWindowList - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// UWindowList - a generic linked list class
//=============================================================================
class UWindowList extends UWindowBase;

var int InternalCount;
var int CompareCount;
var bool bItemOrderChanged;
var bool bSuspendableSort;
var bool bSortSuspended;
// Binary tree variables for sentinel
var bool bTreeSort;
var bool m_bShowThisItem;
var UWindowList Next;
var UWindowList Last;  // Only valid for sentinel
var UWindowList Prev;
var UWindowList Sentinel;
var UWindowList CurrentSortItem;
// Binary tree variables for each element
var UWindowList BranchLeft;
var UWindowList BranchRight;
var UWindowList ParentNode;

function UWindowList CreateItem(Class<UWindowList> C)
{
	local UWindowList NewElement;

	NewElement = new C;
	return NewElement;
	return;
}

function GraftLeft(UWindowList NewLeft)
{
	assert(Sentinel.bTreeSort);
	BranchLeft = NewLeft;
	// End:0x38
	if((NewLeft != none))
	{
		NewLeft.ParentNode = self;
	}
	return;
}

function GraftRight(UWindowList NewRight)
{
	assert(Sentinel.bTreeSort);
	BranchRight = NewRight;
	// End:0x38
	if((NewRight != none))
	{
		NewRight.ParentNode = self;
	}
	return;
}

// Return rightmost child of subtree
function UWindowList RightMost()
{
	local UWindowList L;

	assert(Sentinel.bTreeSort);
	// End:0x1F
	if((BranchRight == none))
	{
		return none;
	}
	L = self;
	J0x26:

	// End:0x51 [Loop If]
	if((L.BranchRight != none))
	{
		L = L.BranchRight;
		// [Loop Continue]
		goto J0x26;
	}
	return L;
	return;
}

// Return leftmost child of subtree
function UWindowList LeftMost()
{
	local UWindowList L;

	assert(Sentinel.bTreeSort);
	// End:0x1F
	if((BranchLeft == none))
	{
		return none;
	}
	L = self;
	J0x26:

	// End:0x51 [Loop If]
	if((L.BranchLeft != none))
	{
		L = L.BranchLeft;
		// [Loop Continue]
		goto J0x26;
	}
	return L;
	return;
}

function Remove()
{
	local UWindowList t;

	// End:0x1F
	if((Next != none))
	{
		Next.Prev = Prev;
	}
	// End:0x3E
	if((Prev != none))
	{
		Prev.Next = Next;
	}
	// End:0x1BD
	if((Sentinel != none))
	{
		// End:0x15F
		if((Sentinel.bTreeSort && (ParentNode != none)))
		{
			// End:0xFA
			if((BranchLeft != none))
			{
				// End:0x9B
				if((ParentNode.BranchLeft == self))
				{
					ParentNode.GraftLeft(BranchLeft);
				}
				// End:0xC3
				if((ParentNode.BranchRight == self))
				{
					ParentNode.GraftRight(BranchLeft);
				}
				t = BranchLeft.RightMost();
				// End:0xF7
				if((t != none))
				{
					t.GraftRight(BranchRight);
				}				
			}
			else
			{
				// End:0x122
				if((ParentNode.BranchLeft == self))
				{
					ParentNode.GraftLeft(BranchRight);
				}
				// End:0x14A
				if((ParentNode.BranchRight == self))
				{
					ParentNode.GraftRight(BranchRight);
				}
			}
			ParentNode = none;
			BranchLeft = none;
			BranchRight = none;
		}
		(Sentinel.InternalCount--);
		Sentinel.bItemOrderChanged = true;
		// End:0x1A8
		if((Sentinel.Last == self))
		{
			Sentinel.Last = Prev;
		}
		Prev = none;
		Next = none;
		Sentinel = none;
	}
	return;
}

function int Compare(UWindowList t, UWindowList B)
{
	return 0;
	return;
}

// Inserts a new element before us.  DO NOT CALL on the sentinel.
function UWindowList InsertBefore(Class<UWindowList> C)
{
	local UWindowList NewElement;

	NewElement = CreateItem(C);
	InsertItemBefore(NewElement);
	return NewElement;
	return;
}

function UWindowList InsertAfter(Class<UWindowList> C)
{
	local UWindowList NewElement;

	NewElement = CreateItem(C);
	InsertItemAfter(NewElement);
	return NewElement;
	return;
}

// Inserts an element before us.  DO NOT CALL on the sentinel.
function InsertItemBefore(UWindowList NewElement)
{
	assert((Sentinel != self));
	NewElement.BranchLeft = none;
	NewElement.BranchRight = none;
	NewElement.ParentNode = none;
	NewElement.Sentinel = Sentinel;
	NewElement.BranchLeft = none;
	NewElement.BranchRight = none;
	NewElement.ParentNode = none;
	NewElement.Prev = Prev;
	Prev.Next = NewElement;
	Prev = NewElement;
	NewElement.Next = self;
	// End:0xEA
	if((Sentinel.Next == self))
	{
		Sentinel.Next = NewElement;
	}
	(Sentinel.InternalCount++);
	Sentinel.bItemOrderChanged = true;
	return;
}

function InsertItemAfter(UWindowList NewElement, optional bool bCheckShowItem)
{
	local UWindowList N;

	N = Next;
	// End:0x4C
	if(bCheckShowItem)
	{
		J0x14:

		// End:0x4C [Loop If]
		if(((N != none) && (!N.ShowThisItem())))
		{
			N = N.Next;
			// [Loop Continue]
			goto J0x14;
		}
	}
	// End:0x6E
	if((N != none))
	{
		N.InsertItemBefore(NewElement);		
	}
	else
	{
		Sentinel.DoAppendItem(NewElement);
	}
	Sentinel.bItemOrderChanged = true;
	return;
}

function ContinueSort()
{
	local UWindowList N;

	CompareCount = 0;
	bSortSuspended = false;
	J0x0F:

	// End:0x6B [Loop If]
	if((CurrentSortItem != none))
	{
		N = CurrentSortItem.Next;
		AppendItem(CurrentSortItem);
		CurrentSortItem = N;
		// End:0x68
		if(((CompareCount >= 10000) && bSuspendableSort))
		{
			bSortSuspended = true;
			return;
		}
		// [Loop Continue]
		goto J0x0F;
	}
	return;
}

function Tick(float Delta)
{
	// End:0x0F
	if(bSortSuspended)
	{
		ContinueSort();
	}
	return;
}

function UWindowList Sort()
{
	local UWindowList S, CurrentItem, Previous, Best, BestPrev;

	// End:0x33
	if(bTreeSort)
	{
		// End:0x1A
		if(bSortSuspended)
		{
			ContinueSort();
			return self;
		}
		CurrentSortItem = Next;
		DisconnectList();
		ContinueSort();
		return self;
	}
	CurrentItem = self;
	J0x3A:

	// End:0x218 [Loop If]
	if((CurrentItem != none))
	{
		S = CurrentItem.Next;
		Best = CurrentItem.Next;
		Previous = CurrentItem;
		BestPrev = CurrentItem;
		J0x83:

		// End:0xE5 [Loop If]
		if((S != none))
		{
			// End:0xC3
			if((CurrentItem.Compare(S, Best) <= 0))
			{
				Best = S;
				BestPrev = Previous;
			}
			Previous = S;
			S = S.Next;
			// [Loop Continue]
			goto J0x83;
		}
		// End:0x201
		if((Best != CurrentItem.Next))
		{
			BestPrev.Next = Best.Next;
			// End:0x14B
			if((BestPrev.Next != none))
			{
				BestPrev.Next.Prev = BestPrev;
			}
			Best.Prev = CurrentItem;
			Best.Next = CurrentItem.Next;
			CurrentItem.Next.Prev = Best;
			CurrentItem.Next = Best;
			// End:0x201
			if((Sentinel.Last == Best))
			{
				Sentinel.Last = BestPrev;
				// End:0x201
				if((Sentinel.Last == none))
				{
					Sentinel.Last = Sentinel;
				}
			}
		}
		CurrentItem = CurrentItem.Next;
		// [Loop Continue]
		goto J0x3A;
	}
	return self;
	return;
}

function DisconnectList()
{
	Next = none;
	Last = self;
	Prev = none;
	BranchLeft = none;
	BranchRight = none;
	ParentNode = none;
	InternalCount = 0;
	Sentinel.bItemOrderChanged = true;
	return;
}

function DestroyList()
{
	local UWindowList L, temp;

	L = Next;
	InternalCount = 0;
	// End:0x2E
	if((Sentinel != none))
	{
		Sentinel.bItemOrderChanged = true;
	}
	J0x2E:

	// End:0x6A [Loop If]
	if((L != none))
	{
		temp = L.Next;
		L.DestroyListItem();
		L = temp;
		// [Loop Continue]
		goto J0x2E;
	}
	DestroyListItem();
	return;
}

function DestroyListItem()
{
	Next = none;
	Last = self;
	Sentinel = none;
	Prev = none;
	BranchLeft = none;
	BranchRight = none;
	ParentNode = none;
	return;
}

function int CountShown()
{
	local int C;
	local UWindowList i;

	i = Next;
	J0x0B:

	// End:0x46 [Loop If]
	if((i != none))
	{
		// End:0x2F
		if(i.ShowThisItem())
		{
			(C++);
		}
		i = i.Next;
		// [Loop Continue]
		goto J0x0B;
	}
	return C;
	return;
}

function UWindowList CopyExistingListItem(Class<UWindowList> ItemClass, UWindowList SourceItem)
{
	local UWindowList i;

	i = Append(ItemClass);
	Sentinel.bItemOrderChanged = true;
	return i;
	return;
}

// for Listboxes only (so far)
function bool ShowThisItem()
{
	return m_bShowThisItem;
	return;
}

function int Count()
{
	return InternalCount;
	return;
}

function MoveItemSorted(UWindowList Item)
{
	local UWindowList L;

	// End:0x26
	if(bTreeSort)
	{
		Item.Remove();
		AppendItem(Item);		
	}
	else
	{
		L = Next;
		J0x31:

		// End:0x6C [Loop If]
		if((L != none))
		{
			// End:0x55
			if((Compare(Item, L) <= 0))
			{
				// [Explicit Break]
				goto J0x6C;
			}
			L = L.Next;
			// [Loop Continue]
			goto J0x31;
		}
		J0x6C:

		// End:0xB7
		if((L != Item))
		{
			Item.Remove();
			// End:0xA3
			if((L == none))
			{
				AppendItem(Item);				
			}
			else
			{
				L.InsertItemBefore(Item);
			}
		}
	}
	return;
}

function SetupSentinel(optional bool bInTreeSort)
{
	Last = self;
	Next = none;
	Prev = none;
	BranchLeft = none;
	BranchRight = none;
	ParentNode = none;
	Sentinel = self;
	InternalCount = 0;
	bItemOrderChanged = true;
	bTreeSort = bInTreeSort;
	return;
}

function Validate()
{
	local UWindowList i, Previous;
	local int Count;

	// End:0x46
	if((Sentinel != self))
	{
		Log(("Calling Sentinel.Validate() from " $ string(self)));
		Sentinel.Validate();
		return;
	}
	Log(("BEGIN Validate(): " $ string(Class)));
	Count = 0;
	Previous = self;
	i = Next;
	J0x7E:

	// End:0x1FD [Loop If]
	if((i != none))
	{
		Log(("Checking item: " $ string(Count)));
		// End:0xDE
		if((i.Sentinel != self))
		{
			Log("   I.Sentinel reference is broken");
		}
		// End:0x117
		if((i.Prev != Previous))
		{
			Log("   I.Prev reference is broken");
		}
		// End:0x170
		if(((Last == i) && (i.Next != none)))
		{
			Log("   Item is Sentinel.Last but Item has valid Next");
		}
		// End:0x1D4
		if(((i.Next == none) && (Last != i)))
		{
			Log("   Item is Item.Next is none, but Item is not Sentinel.Last");
		}
		Previous = i;
		(Count++);
		i = i.Next;
		// [Loop Continue]
		goto J0x7E;
	}
	Log(("END Validate(): " $ string(Class)));
	return;
}

// For sentinel only
function UWindowList Append(Class<UWindowList> C)
{
	local UWindowList NewElement;

	NewElement = CreateItem(C);
	AppendItem(NewElement);
	return NewElement;
	return;
}

function AppendItem(UWindowList NewElement)
{
	local UWindowList Node, OldNode, temp;
	local int test;

	// End:0x225
	if(bTreeSort)
	{
		// End:0xB8
		if(((Next != none) && (Last != self)))
		{
			// End:0x6D
			if((Compare(NewElement, Last) >= 0))
			{
				Node = Last;
				Node.InsertItemAfter(NewElement, false);
				Node.GraftRight(NewElement);
				return;
			}
			// End:0xB8
			if((Compare(NewElement, Next) <= 0))
			{
				Node = Next;
				Node.InsertItemBefore(NewElement);
				Node.GraftLeft(NewElement);
				return;
			}
		}
		Node = self;
		J0xBF:

		// End:0x222 [Loop If]
		if(true)
		{
			// End:0xD8
			if((Node == self))
			{
				test = 1;				
			}
			else
			{
				test = Compare(NewElement, Node);
			}
			// End:0x113
			if((test == 0))
			{
				Node.InsertItemAfter(NewElement, false);
				return;				
			}
			else
			{
				// End:0x1CB
				if((test > 0))
				{
					OldNode = Node;
					Node = Node.BranchRight;
					// End:0x1C8
					if((Node == none))
					{
						temp = OldNode;
						J0x153:

						// End:0x19D [Loop If]
						if(((temp.Next != none) && (temp.Next.ParentNode == none)))
						{
							temp = temp.Next;
							// [Loop Continue]
							goto J0x153;
						}
						temp.InsertItemAfter(NewElement, false);
						OldNode.GraftRight(NewElement);
						return;
					}					
				}
				else
				{
					OldNode = Node;
					Node = Node.BranchLeft;
					// End:0x21F
					if((Node == none))
					{
						OldNode.InsertItemBefore(NewElement);
						OldNode.GraftLeft(NewElement);
						return;
					}
				}
			}
			// [Loop Continue]
			goto J0xBF;
		}		
	}
	else
	{
		DoAppendItem(NewElement);
	}
	return;
}

function DoAppendItem(UWindowList NewElement)
{
	NewElement.Next = none;
	Last.Next = NewElement;
	NewElement.Prev = Last;
	NewElement.Sentinel = self;
	NewElement.BranchLeft = none;
	NewElement.BranchRight = none;
	NewElement.ParentNode = none;
	Last = NewElement;
	(Sentinel.InternalCount++);
	Sentinel.bItemOrderChanged = true;
	return;
}

// For sentinel only
function UWindowList Insert(Class<UWindowList> C)
{
	local UWindowList NewElement;

	NewElement = CreateItem(C);
	InsertItem(NewElement);
	return NewElement;
	return;
}

function InsertItem(UWindowList NewElement)
{
	NewElement.Next = Next;
	// End:0x33
	if((Next != none))
	{
		Next.Prev = NewElement;
	}
	Next = NewElement;
	// End:0x54
	if((Last == self))
	{
		Last = Next;
	}
	NewElement.Prev = self;
	NewElement.Sentinel = self;
	NewElement.BranchLeft = none;
	NewElement.BranchRight = none;
	NewElement.ParentNode = none;
	(Sentinel.InternalCount++);
	Sentinel.bItemOrderChanged = true;
	return;
}

// For sentinel only
function UWindowList FindEntry(int Index)
{
	local UWindowList L;
	local int i;

	L = Next;
	i = 0;
	J0x12:

	// End:0x4C [Loop If]
	if((i < Index))
	{
		L = L.Next;
		// End:0x42
		if((L == none))
		{
			return none;
		}
		(i++);
		// [Loop Continue]
		goto J0x12;
	}
	return L;
	return;
}

function AppendListCopy(UWindowList L)
{
	// End:0x0D
	if((L == none))
	{
		return;
	}
	L = L.Next;
	J0x21:

	// End:0x5C [Loop If]
	if((L != none))
	{
		CopyExistingListItem(L.Class, L);
		L = L.Next;
		// [Loop Continue]
		goto J0x21;
	}
	return;
}

function Clear()
{
	InternalCount = 0;
	ParentNode = none;
	BranchLeft = none;
	BranchRight = none;
	bItemOrderChanged = true;
	Next = none;
	Last = self;
	return;
}

//=====================================================================================
// ClearItem: clear the appropriate item values except the link with the list
//=====================================================================================
function ClearItem()
{
	return;
}

defaultproperties
{
	m_bShowThisItem=true
}
