//=============================================================================
//  R6WindowButtonOptions.uc : This is button for options menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/11 * Created by Yannick Joly
//=============================================================================
class R6WindowButtonOptions extends R6WindowButton;

// --- Enums ---
enum eButtonActionType
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
var eButtonActionType m_eButton_Action;
// ^ NEW IN 1.60
var Region m_ROverButton;
var Region m_ROverButtonFade;
var Texture m_TOverButton;

// --- Functions ---
simulated function Click(float Y, float X) {}

defaultproperties
{
}
