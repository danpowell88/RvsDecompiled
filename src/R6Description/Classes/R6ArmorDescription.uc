//=============================================================================
//  R6ArmorDescription.uc : This is mainly to accelerate the foreach search 
//                           when populating menu lists
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/22 * Created by Alexandre Dionne
//=============================================================================
class R6ArmorDescription extends R6Description;

// --- Variables ---
// If the armor can only be used by specific operative.
var name m_LimitedToClass;
var bool m_bHideFromMenu;

defaultproperties
{
}
