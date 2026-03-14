//=============================================================================
//  R6MenuViewCamBar.uc : Toolbar providing camera view selection buttons for the mission planning 3D viewport.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/03 * Created by Chaouky Garram
//=============================================================================
class R6MenuViewCamBar extends UWindowWindow;

// --- Constants ---
const XPos; // value unavailable in binary
const ButtonSize = 33;

// --- Variables ---
var R6WindowButton m_Button[6];

// --- Functions ---
function Created() {}
function KeepActive(int iActive) {}
function Paint(Canvas C, float X, float Y) {}

defaultproperties
{
}
