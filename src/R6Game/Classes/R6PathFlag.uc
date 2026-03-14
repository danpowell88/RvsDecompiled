//=============================================================================
//  R6PathFlag.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/30 * Created by Chaouky Garram
//=============================================================================
class R6PathFlag extends R6ReferenceIcons
    notplaceable;

// --- Variables ---
// EMovementSpeed
var Texture m_pIconTex[3];

// --- Functions ---
// Refresh my location to be between previous and next ActionPoint
function RefreshLocation() {}
// Set Movement line texture
function SetModeDisplay(EMovementMode eMode) {}
// Set texture color
function SetDrawColor(Color NewColor) {}

defaultproperties
{
}
