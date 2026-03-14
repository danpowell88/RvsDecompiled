//=============================================================================
//  R6InteractiveObjectActionToggleDevice.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/16 * Creation - Jean-Francois Dube
//=============================================================================
class R6InteractiveObjectActionToggleDevice extends R6InteractiveObjectAction;

// --- Variables ---
var R6IODevice m_iodevice;
var array<array> m_aIOBombs;

defaultproperties
{
}
