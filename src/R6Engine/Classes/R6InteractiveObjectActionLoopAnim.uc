//=============================================================================
// R6InteractiveObjectActionLoopAnim - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6InteractiveObjectActionLoopAnim.uc
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/29 * Creation - Jean-Francois Dube
//=============================================================================
class R6InteractiveObjectActionLoopAnim extends R6InteractiveObjectActionPlayAnim
	editinlinenew;

var(LoopAnim) Range m_LoopTime;

defaultproperties
{
	m_eType=3
}
