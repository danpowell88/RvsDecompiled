//=============================================================================
//  R6WindowPopUpButton.uc : PopUp button with specific border texture
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowPopUpButton extends UWindowButton;

// --- Variables ---
var Region m_RButBorder;
var bool m_bDrawGreenBG;
var bool m_bDrawRedBG;
var Texture m_TButBorderTex;

// --- Functions ---
function Paint(Canvas C, float Y, float X) {}

defaultproperties
{
}
