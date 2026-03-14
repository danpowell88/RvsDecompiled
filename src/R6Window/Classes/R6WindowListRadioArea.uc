//=============================================================================
//  R6WindowListRadioArea.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowListRadioArea extends R6WindowTextListRadio;

// --- Variables ---
var class<R6WindowArea> AreaClass;

// --- Functions ---
function SetDefaultButton(UWindowList Item) {}
function Paint(Canvas C, float fMouseX, float fMouseY) {}
//**************************
function SetSelectedItem(UWindowListBoxItem NewSelected) {}

defaultproperties
{
}
