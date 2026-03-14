//=============================================================================
//  R6WindowListBoxItem.uc : List-box row supporting separators, sub-lists, and associated objects.
//  Extends UWindowListBoxItem with extra metadata for grouped and hierarchical list layouts.
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/25 * Created by Alexandre Dionne
//=============================================================================
class R6WindowListBoxItem extends UWindowListBoxItem;

// --- Variables ---
var bool m_IsSeparator;
                                                //items between Separators;
//Item as been added to a sub List
var bool m_addedToSubList;
//Object or actor associated with this element
var Object m_Object;
//To help manage insertions and removal of
var int m_iSeparatorID;
var Texture m_Icon;
//To get icons to higlight when selected
var Region m_IconSelectedRegion;
var Region m_IconRegion;
//Item from wich this one has been added to a sub list
var R6WindowListBoxItem m_ParentListItem;
// a misc purpose string
var string m_szMisc;

// --- Functions ---
//If this functions returns None well it could'nt find the designated separator
function R6WindowListBoxItem InsertLastAfterSeparator(int iSeparatorID, class<R6WindowListBoxItem> C) {}
//If this functions returns None well it could'nt find the designated separator
function R6WindowListBoxItem AppendAfterSeparator(int iSeparatorID, class<R6WindowListBoxItem> C) {}
//Call this on the sentinel
function int FindItemIndex(UWindowList Item) {}

defaultproperties
{
}
