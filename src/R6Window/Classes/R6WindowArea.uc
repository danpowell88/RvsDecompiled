//=============================================================================
//  R6WindowArea.uc : Generic selectable panel used as a dialog client area.
//  Extends UWindowDialogClientWindow and tracks its own selection state.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowArea extends UWindowDialogClientWindow;

// --- Variables ---
var bool m_bSelected;

defaultproperties
{
}
