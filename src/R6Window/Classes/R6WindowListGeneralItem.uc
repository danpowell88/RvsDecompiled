//=============================================================================
// R6WindowListGeneralItem - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowListBoxItem.uc : Class used to hold the values for the entries
//  in the list of servers in the multi player menu.
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/28 * Created by Yannick Joly
//=============================================================================
class R6WindowListGeneralItem extends UWindowListBoxItem;

// NEW IN 1.60
var bool m_bFakeItem;
//type of button to create?
var R6WindowCounter m_pR6WindowCounter;
var R6WindowButtonBox m_pR6WindowButtonBox;
var R6WindowComboControl m_pR6WindowComboControl;

