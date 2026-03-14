//=============================================================================
// R6InteractiveObjectActionToggleDevice - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6InteractiveObjectActionToggleDevice.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/16 * Creation - Jean-Francois Dube
//=============================================================================
class R6InteractiveObjectActionToggleDevice extends R6InteractiveObjectAction
	editinlinenew;

var(ToggleDevice) R6IODevice m_iodevice;
var(ToggleDevice) editinline array<editinline R6IOBomb> m_aIOBombs;

defaultproperties
{
	m_eType=5
}
