//=============================================================================
// R6InteractiveObjectActionLoopRandomAnim - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6InteractiveObjectActionLoopRandomAnim.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/23 * Created by Guillaume Borgia
//=============================================================================
class R6InteractiveObjectActionLoopRandomAnim extends R6InteractiveObjectAction
	editinlinenew;

var(PlayAnim) editinline array<editinline name> m_aAnimName;

function name GetNextAnim()
{
	return m_aAnimName[Rand(m_aAnimName.Length)];
	return;
}

defaultproperties
{
	m_eType=4
}
