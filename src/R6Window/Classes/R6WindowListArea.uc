//=============================================================================
//  R6WindowListArea.uc : List box that populates each row with an R6WindowArea panel widget.
//  Extends R6WindowTextListBox and uses a configurable area class for row content.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowListArea extends R6WindowTextListBox;

// --- Variables ---
var class<R6WindowArea> m_AreaClass;

// --- Functions ---
function Paint(Canvas C, float fMouseX, float fMouseY) {}
function BeforePaint(float fMouseY, float fMouseX, Canvas C) {}

defaultproperties
{
}
