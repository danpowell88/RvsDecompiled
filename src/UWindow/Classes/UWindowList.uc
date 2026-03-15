//=============================================================================
// UWindowList - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// UWindowList - a generic linked list class
//
// Every list has exactly one sentinel object that acts as the list head.
// The sentinel is identified by (Sentinel == self).  Real data items sit
// between sentinel.Next (head) and sentinel.Last (tail).
//
// Two sort modes are available, selected at SetupSentinel() time:
//   bTreeSort=false  ->  selection sort  (O(n^2), simple, good for short lists)
//   bTreeSort=true   ->  BST-insertion sort (O(n log n) average, suspendable)
//=============================================================================
class UWindowList extends UWindowBase;

// Cached element count; maintained on every insert/remove so Count() is O(1).
var int InternalCount;
// Running tally of Compare() calls during the current sort pass; used to
// decide when to suspend a large sort and resume it next Tick.
var int CompareCount;
// Dirty flag: set to true whenever the list is structurally modified.
// UI consumers (list boxes, scroll bars) poll this to know when to redraw.
var bool bItemOrderChanged;
// When true, Sort() is allowed to pause mid-pass and resume across Ticks.
// Set this on the sentinel before sorting large lists to avoid frame hitches.
var bool bSuspendableSort;
// True while a suspendable sort is paused between Ticks.
// Tick() calls ContinueSort() to advance the pass until CompareCount hits 10000.
var bool bSortSuspended;
// Binary tree variables for sentinel
// Selects the sort algorithm.  Set via SetupSentinel(bInTreeSort).
// false = selection sort on the linked list (default, simple, O(n^2))
// true  = BST-insertion sort (faster for large/frequently-updated lists)
var bool bTreeSort;
// Per-item visibility flag used by listboxes; see ShowThisItem() / CountShown().
// Defaults to true so all items are visible unless a subclass overrides.
var bool m_bShowThisItem;
// Standard doubly-linked list forward pointer.  null on the sentinel means
// the list is empty; null on a data item means it is the tail.
var UWindowList Next;
var UWindowList Last;  // Only valid for sentinel -- tail pointer enabling O(1) appends
// Backward pointer.  On the sentinel, Prev is unused (null).
// On data items, Prev always points to the preceding node (or the sentinel).
var UWindowList Prev;
// Every element (including the sentinel itself) carries a reference back to
// the sentinel of its list.  This lets any node reach list-level state
// (InternalCount, Last, bTreeSort …) without passing the sentinel explicitly.
var UWindowList Sentinel;
// Bookmark used by suspendable BST sorts: the next item to re-insert when
// ContinueSort() is called.  Only meaningful when bSortSuspended is true.
var UWindowList CurrentSortItem;
// Binary tree variables for each element
// Left child in the BST (items that compare LESS THAN this node).
var UWindowList BranchLeft;
// Right child in the BST (items that compare GREATER THAN this node).
var UWindowList BranchRight;
// BST parent back-pointer.  null on the root and on non-BST-sorted items.
var UWindowList ParentNode;

// Factory: allocate a new list element of class C.
// Subclasses should override to perform any per-item initialisation.
function UWindowList CreateItem(Class<UWindowList> C)
{
	local UWindowList NewElement;

	NewElement = new C;
	return NewElement;
	return;
}

// BST helper: set BranchLeft and keep the child's ParentNode back-pointer
// consistent.  Only valid in bTreeSort mode (asserted).
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

// BST helper: set BranchRight and keep the child's ParentNode back-pointer
// consistent.  Only valid in bTreeSort mode (asserted).
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

	// Stitch neighbours together, removing this node from the doubly-linked chain.
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
		// If BST mode is active and this node has a parent, we must reattach
		// its subtrees to maintain BST integrity.
		// End:0x15F
		if((Sentinel.bTreeSort && (ParentNode != none)))
		{
			// End:0xFA
			if((BranchLeft != none))
			{
				// Replace this node in its parent with the left subtree.
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
				// Right subtree must not be lost; attach it to the rightmost
				// node of the left subtree so BST ordering is preserved.
				t = BranchLeft.RightMost();
				// End:0xF7
				if((t != none))
				{
					t.GraftRight(BranchRight);
				}				
			}
			else
			{
				// No left child; simply promote the right subtree.
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
			// Clear BST pointers on the removed node so it can be re-inserted later.
			ParentNode = none;
			BranchLeft = none;
			BranchRight = none;
		}
		(Sentinel.InternalCount--); // Keep O(1) count accurate.
		Sentinel.bItemOrderChanged = true;
		// Update tail pointer if we were the last real element.
		// End:0x1A8
		if((Sentinel.Last == self))
		{
			Sentinel.Last = Prev;
		}
		// Null our own pointers — prevents dangling references.
		Prev = none;
		Next = none;
		Sentinel = none;
	}
	return;
}

// Sort comparator: override in subclasses to define ordering.
// Return negative if T should appear before B, 0 if equal, positive if after.
// The base implementation treats everything as equal (stable, no reordering).
function int Compare(UWindowList t, UWindowList B)
{
	return 0;
	return;
}

// Inserts a new element before us.  DO NOT CALL on the sentinel.
// Convenience wrapper: allocates the item then calls InsertItemBefore.
function UWindowList InsertBefore(Class<UWindowList> C)
{
	local UWindowList NewElement;

	NewElement = CreateItem(C);
	InsertItemBefore(NewElement);
	return NewElement;
	return;
}

// Convenience wrapper: allocates the item then calls InsertItemAfter.
function UWindowList InsertAfter(Class<UWindowList> C)
{
	local UWindowList NewElement;

	NewElement = CreateItem(C);
	InsertItemAfter(NewElement);
	return NewElement;
	return;
}

// Inserts an element before us.  DO NOT CALL on the sentinel.
// Core doubly-linked-list splice-before operation.  After the call:
//   Prev  <->  NewElement  <->  self
// BST pointers on NewElement are cleared because BST position is
// determined separately in AppendItem, not here.
function InsertItemBefore(UWindowList NewElement)
{
	assert((Sentinel != self)); // Caller must not be the sentinel.
	NewElement.BranchLeft = none;
	NewElement.BranchRight = none;
	NewElement.ParentNode = none;
	NewElement.Sentinel = Sentinel; // Register with this list's sentinel.
	// The BranchLeft/Right/ParentNode assignments are intentionally
	// repeated here (matching the retail binary exactly).
	NewElement.BranchLeft = none;
	NewElement.BranchRight = none;
	NewElement.ParentNode = none;
	// Wire up the doubly-linked pointers.
	NewElement.Prev = Prev;
	Prev.Next = NewElement;
	Prev = NewElement;
	NewElement.Next = self;
	// If this was the first real element, update the sentinel's head pointer.
	// End:0xEA
	if((Sentinel.Next == self))
	{
		Sentinel.Next = NewElement;
	}
	(Sentinel.InternalCount++);
	Sentinel.bItemOrderChanged = true;
	return;
}

// Inserts NewElement after this node.
// bCheckShowItem: when true, skip over hidden items to find the next visible
// insertion point — used by listboxes that filter their display.
// Falls back to DoAppendItem (tail) if no suitable next node is found.
function InsertItemAfter(UWindowList NewElement, optional bool bCheckShowItem)
{
	local UWindowList N;

	N = Next;
	// End:0x4C
	if(bCheckShowItem)
	{
		J0x14:

		// Advance past invisible items so NewElement ends up after a visible one.
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
		N.InsertItemBefore(NewElement); // Splice before the found node.
	}
	else
	{
		Sentinel.DoAppendItem(NewElement); // No suitable node found — append to tail.
	}
	Sentinel.bItemOrderChanged = true;
	return;
}

// Advance a suspended BST sort by re-inserting items one at a time.
// Each re-insertion goes through AppendItem which walks the BST to find
// the correct sorted position.  CompareCount accumulates across calls;
// once it reaches 10000 the sort yields back to the caller (bSortSuspended=true)
// and Tick() will call us again next frame.
function ContinueSort()
{
	local UWindowList N;

	CompareCount = 0; // Reset per-pass counter (AppendItem increments this).
	bSortSuspended = false;
	J0x0F:

	// End:0x6B [Loop If]
	if((CurrentSortItem != none))
	{
		N = CurrentSortItem.Next; // Save Next before the item is re-linked.
		AppendItem(CurrentSortItem); // Re-insert into the now-empty BST-sorted list.
		CurrentSortItem = N;
		// End:0x68
		if(((CompareCount >= 10000) && bSuspendableSort)) // 10000 comparisons = yield threshold
		{
			bSortSuspended = true; // Signal that the sort is paused.
			return;
		}
		// [Loop Continue]
		goto J0x0F;
	}
	return;
}

// Called every game tick on the sentinel.  Drives suspended BST sorts to
// completion one batch at a time, preventing large sorts from hitching a frame.
function Tick(float Delta)
{
	// End:0x0F
	if(bSortSuspended)
	{
		ContinueSort();
	}
	return;
}

// Sort the list using one of two algorithms selected by bTreeSort:
//
//   bTreeSort=false  (default):  Selection sort on the linked list.
//     For each position i, scan the tail to find the minimum element (Best)
//     and splice it next to CurrentItem.  O(n^2) — fine for short lists.
//
//   bTreeSort=true:  BST-insertion sort.
//     Snap all items off into a temporary chain (DisconnectList), then
//     re-insert each one through AppendItem which uses the BST to maintain
//     sorted order.  O(n log n) average.  Supports mid-sort suspension via
//     bSuspendableSort so huge lists don't stall a frame.
//
// Returns Self (the sentinel) for chaining.
function UWindowList Sort()
{
	local UWindowList S, CurrentItem, Previous, Best, BestPrev;

	// End:0x33
	if(bTreeSort)
	{
		// If a previous sort was suspended, continue it first.
		// End:0x1A
		if(bSortSuspended)
		{
			ContinueSort();
			return self;
		}
		// Save the unsorted chain, then clear the list so AppendItem can
		// re-insert items in BST-sorted order.
		CurrentSortItem = Next;
		DisconnectList();
		ContinueSort();
		return self;
	}

	// --- Selection sort (bTreeSort=false) ---
	// CurrentItem is the "sorted boundary" node; everything before it is sorted.
	CurrentItem = self; // Start from sentinel so first pass covers the whole list.
	J0x3A:

	// End:0x218 [Loop If]
	if((CurrentItem != none))
	{
		// Scan from CurrentItem.Next onwards to find the minimum element (Best).
		S = CurrentItem.Next;
		Best = CurrentItem.Next; // Assume first unsorted element is best so far.
		Previous = CurrentItem;
		BestPrev = CurrentItem; // Track the node before Best so we can unlink it.
		J0x83:

		// End:0xE5 [Loop If]
		if((S != none))
		{
			// Compare(S, Best) <= 0 means S is at least as good as Best.
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
		// Only move Best if it isn't already the first unsorted element.
		// End:0x201
		if((Best != CurrentItem.Next))
		{
			// Unlink Best from its current position.
			BestPrev.Next = Best.Next;
			// End:0x14B
			if((BestPrev.Next != none))
			{
				BestPrev.Next.Prev = BestPrev;
			}
			// Splice Best right after CurrentItem.
			Best.Prev = CurrentItem;
			Best.Next = CurrentItem.Next;
			CurrentItem.Next.Prev = Best;
			CurrentItem.Next = Best;
			// Update sentinel.Last if Best was the tail (its old slot is now the tail).
			// End:0x201
			if((Sentinel.Last == Best))
			{
				Sentinel.Last = BestPrev;
				// Edge case: if BestPrev turned out to be the sentinel, Last must
				// point to the sentinel itself (empty-list invariant).
				// End:0x201
				if((Sentinel.Last == none))
				{
					Sentinel.Last = Sentinel;
				}
			}
		}
		CurrentItem = CurrentItem.Next; // Advance sorted boundary.
		// [Loop Continue]
		goto J0x3A;
	}
	return self;
	return;
}

// Reset the sentinel to an empty state without freeing any elements.
// Used at the start of a BST re-sort: all items are first saved to a
// temporary chain, then re-inserted in order via ContinueSort.
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

// Destroy the entire list: walks every element and calls DestroyListItem on
// each one (nulling all pointers), then calls DestroyListItem on the sentinel
// itself.  After this the list object is effectively dead.
// UnrealScript GC will collect the orphaned objects in due course.
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
		temp = L.Next; // Save Next before we null it.
		L.DestroyListItem();
		L = temp;
		// [Loop Continue]
		goto J0x2E;
	}
	DestroyListItem(); // Also destroy the sentinel (or this node if called on a member).
	return;
}

// Null all pointers on this single node, cutting it loose from its list.
// Does NOT free memory — UnrealScript GC handles that.
// Called by DestroyList on every element including the sentinel.
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

// Walk the list counting only visible items (ShowThisItem()==true).
// O(n).  Use Count() when you need the total including hidden items.
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

// Appends a new element of the same class as SourceItem.
// NOTE: data fields are NOT copied — only the class type is used.
// Subclasses should override to perform the actual field-by-field copy.
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

// O(1) accessor for the cached element count (both visible and hidden).
function int Count()
{
	return InternalCount;
	return;
}

// Re-position an existing list member into its correct sorted slot.
// Called when the data that drives Compare() changes on an already-inserted item.
//   bTreeSort=true:  Remove + re-insert through the BST (O(log n) average).
//   bTreeSort=false: Linear scan to find the correct insertion point, then
//                    splice the item there if it has moved (O(n)).
function MoveItemSorted(UWindowList Item)
{
	local UWindowList L;

	// End:0x26
	if(bTreeSort)
	{
		Item.Remove();
		AppendItem(Item); // AppendItem will walk the BST to find the right place.
	}
	else
	{
		// Scan forward to find the first node that Item should precede.
		L = Next;
		J0x31:

		// End:0x6C [Loop If]
		if((L != none))
		{
			// End:0x55
			if((Compare(Item, L) <= 0)) // Item belongs before L; stop scanning.
			{
				// [Explicit Break]
				goto J0x6C;
			}
			L = L.Next;
			// [Loop Continue]
			goto J0x31;
		}
		J0x6C:

		// Only move if Item isn't already in the right position.
		// End:0xB7
		if((L != Item))
		{
			Item.Remove();
			// End:0xA3
			if((L == none))
			{
				AppendItem(Item); // Item is larger than everything — goes to tail.
			}
			else
			{
				L.InsertItemBefore(Item); // Splice Item just before L.
			}
		}
	}
	return;
}

// Initialise this object as the sentinel of a new, empty list.
// Must be called exactly once before any other list operation.
// bInTreeSort=true enables BST-insertion sort; false uses selection sort.
// Sentinel=self is the invariant that identifies this node as the list head.
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

// Debug-only integrity check.  Walks the list and logs any broken invariants:
//   - Every element's Sentinel must point back to this sentinel.
//   - Every element's Prev must point to the preceding node.
//   - sentinel.Last must be the final element (Next==none).
// If called on a non-sentinel node, delegates to the sentinel automatically.
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
// Convenience: allocates a new item of class C and appends it to the tail.
// Returns the new element so the caller can populate its data fields.
function UWindowList Append(Class<UWindowList> C)
{
	local UWindowList NewElement;

	NewElement = CreateItem(C);
	AppendItem(NewElement);
	return NewElement;
	return;
}

// Insert NewElement into the list, maintaining sort order when bTreeSort=true.
//
// bTreeSort=false:  Calls DoAppendItem — unconditional O(1) tail append.
//
// bTreeSort=true:   BST-guided insertion.
//   Fast path: if NewElement is >= the current tail, append at end; if <=
//   the current head, prepend at front.  This makes already-sorted input O(1).
//   General path: walk the BST left/right until an empty child slot is found,
//   then splice into the doubly-linked list at the corresponding position AND
//   graft into the BST.  CompareCount is incremented each iteration so
//   ContinueSort can yield at the 10000-comparison threshold.
function AppendItem(UWindowList NewElement)
{
	local UWindowList Node, OldNode, temp;
	local int test;

	// End:0x225
	if(bTreeSort)
	{
		// Fast-path: only applicable when the list already has elements.
		// End:0xB8
		if(((Next != none) && (Last != self)))
		{
			// NewElement is >= tail — just append at the end (common for sorted input).
			// End:0x6D
			if((Compare(NewElement, Last) >= 0))
			{
				Node = Last;
				Node.InsertItemAfter(NewElement, false); // Link into doubly-linked list.
				Node.GraftRight(NewElement); // Also hang as BST right child.
				return;
			}
			// NewElement is <= head — prepend at the front.
			// End:0xB8
			if((Compare(NewElement, Next) <= 0))
			{
				Node = Next;
				Node.InsertItemBefore(NewElement);
				Node.GraftLeft(NewElement); // Hang as BST left child.
				return;
			}
		}
		// General BST traversal: start at the sentinel (treated as root).
		Node = self;
		J0xBF:

		// End:0x222 [Loop If]
		if(true)
		{
			// Sentinel is always the conceptual root; treat it as "greater" so
			// we always go right first (toward real elements).
			// End:0xD8
			if((Node == self))
			{
				test = 1; // Sentinel is treated as less than everything -> go right.
			}
			else
			{
				test = Compare(NewElement, Node);
			}
			// Equality: insert right after this node (stable for equal keys).
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
					// NewElement > Node: traverse right subtree.
					OldNode = Node;
					Node = Node.BranchRight;
					// End:0x1C8
					if((Node == none))
					{
						// Found an empty right slot.  Walk the linked list past any
						// equal-value nodes that share this slot (ParentNode==none
						// marks items inserted after equal-key nodes, not in the BST).
						temp = OldNode;
						J0x153:

						// End:0x19D [Loop If]
						if(((temp.Next != none) && (temp.Next.ParentNode == none)))
						{
							temp = temp.Next;
							// [Loop Continue]
							goto J0x153;
						}
						temp.InsertItemAfter(NewElement, false); // Splice into linked list.
						OldNode.GraftRight(NewElement); // Attach to BST.
						return;
					}					
				}
				else
				{
					// NewElement < Node: traverse left subtree.
					OldNode = Node;
					Node = Node.BranchLeft;
					// End:0x21F
					if((Node == none))
					{
						// Found an empty left slot; insert before OldNode in the list.
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
		DoAppendItem(NewElement); // Non-sorted mode: simple tail append.
	}
	return;
}

// Unconditional O(1) tail-append.  Does not consult the BST — always places
// NewElement at the end of the linked list.  Used by the non-sorted path and
// as the final step of BST insertion once the correct position is known.
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
// Convenience: allocates a new item of class C and inserts it at the HEAD
// of the list (immediately after the sentinel).
// Returns the new element so the caller can populate its data fields.
function UWindowList Insert(Class<UWindowList> C)
{
	local UWindowList NewElement;

	NewElement = CreateItem(C);
	InsertItem(NewElement);
	return NewElement;
	return;
}

// Insert NewElement at the head of the list (right after the sentinel).
// Used when items should be prepended rather than appended.
// Updates sentinel.Last if the list was previously empty.
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
// O(n) index-based lookup: walks from the head to return the element at
// position Index (0-based).  Returns None if Index is out of range.
// Prefer caching the result rather than calling this in a tight loop.
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

// Append shallow copies of every element in list L into this list.
// The sentinel of L is skipped (L.Next is the first real element).
// Note: data fields are not deep-copied; see CopyExistingListItem.
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

// Soft-clear: resets the sentinel state to "empty list" WITHOUT calling
// DestroyListItem on the existing elements.  The elements are orphaned in
// memory and will be GC'd by UnrealScript.
// Use DestroyList() when you need to explicitly clean up.
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
