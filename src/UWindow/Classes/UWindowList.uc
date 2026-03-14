//=============================================================================
// UWindowList - a generic linked list class
//=============================================================================
class UWindowList extends UWindowBase;

// --- Variables ---
var UWindowList Next;
var UWindowList Sentinel;
var UWindowList Prev;
// Only valid for sentinel
var UWindowList Last;
var UWindowList ParentNode;
// Binary tree variables for each element
var UWindowList BranchLeft;
var UWindowList BranchRight;
var bool bItemOrderChanged;
var int InternalCount;
// Binary tree variables for sentinel
var bool bTreeSort;
var UWindowList CurrentSortItem;
var bool m_bShowThisItem;
var bool bSortSuspended;
var int CompareCount;
var bool bSuspendableSort;

// --- Functions ---
function int Compare(UWindowList t, UWindowList B) {}
// ^ NEW IN 1.60
//=====================================================================================
// ClearItem: clear the appropriate item values except the link with the list
//=====================================================================================
function ClearItem() {}
function SetupSentinel(optional bool bInTreeSort) {}
function UWindowList CopyExistingListItem(class<UWindowList> ItemClass, UWindowList SourceItem) {}
// ^ NEW IN 1.60
function ContinueSort() {}
function UWindowList CreateItem(class<UWindowList> C) {}
// ^ NEW IN 1.60
function AppendItem(UWindowList NewElement) {}
function UWindowList Sort() {}
// ^ NEW IN 1.60
// Inserts an element before us.  DO NOT CALL on the sentinel.
function InsertItemBefore(UWindowList NewElement) {}
function Validate() {}
// For sentinel only
function UWindowList Insert(class<UWindowList> C) {}
// ^ NEW IN 1.60
function MoveItemSorted(UWindowList Item) {}
// For sentinel only
function UWindowList Append(class<UWindowList> C) {}
// ^ NEW IN 1.60
function DoAppendItem(UWindowList NewElement) {}
function InsertItem(UWindowList NewElement) {}
function AppendListCopy(UWindowList L) {}
function UWindowList InsertAfter(class<UWindowList> C) {}
// ^ NEW IN 1.60
// Inserts a new element before us.  DO NOT CALL on the sentinel.
function UWindowList InsertBefore(class<UWindowList> C) {}
// ^ NEW IN 1.60
function Remove() {}
function GraftRight(UWindowList NewRight) {}
function GraftLeft(UWindowList NewLeft) {}
function InsertItemAfter(UWindowList NewElement, optional bool bCheckShowItem) {}
// Return rightmost child of subtree
function UWindowList RightMost() {}
// ^ NEW IN 1.60
// Return leftmost child of subtree
function UWindowList LeftMost() {}
// ^ NEW IN 1.60
function DestroyList() {}
function int CountShown() {}
// ^ NEW IN 1.60
// For sentinel only
function UWindowList FindEntry(int Index) {}
// ^ NEW IN 1.60
function Tick(float Delta) {}
function DisconnectList() {}
function DestroyListItem() {}
// for Listboxes only (so far)
function bool ShowThisItem() {}
// ^ NEW IN 1.60
function int Count() {}
// ^ NEW IN 1.60
function Clear() {}

defaultproperties
{
}
