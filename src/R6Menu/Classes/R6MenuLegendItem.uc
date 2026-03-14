//=============================================================================
//  R6MenuLegendItem.uc : List item entry in the legend panel; holds an icon texture and label for a single legend entry.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6MenuLegendItem extends R6WindowListButtonItem;

// --- Variables ---
var Texture m_pObjectIcon;
var bool m_bOtherTextureHeight;

defaultproperties
{
}
