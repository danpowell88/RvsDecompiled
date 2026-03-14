//=============================================================================
// R6InteractiveObjectActionLookAt - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6InteractiveObjectActionLookAt.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/19 * Creation - Jean-Francois Dube
//=============================================================================
class R6InteractiveObjectActionLookAt extends R6InteractiveObjectAction
	editinlinenew;

var(LookAt) Actor m_Target;

defaultproperties
{
	m_eType=2
}
