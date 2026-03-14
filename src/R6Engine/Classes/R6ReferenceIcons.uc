//=============================================================================
// R6ReferenceIcons - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6ReferenceIcons.uc : icons in the maps for planning only.
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Joel Tremblay
//=============================================================================
class R6ReferenceIcons extends Actor
    abstract
    notplaceable;

defaultproperties
{
	RemoteRole=0
	m_eDisplayFlag=0
	m_bUseR6Availability=true
	m_bSkipHitDetection=true
	bAlwaysRelevant=true
	m_bSpriteShowFlatInPlanning=true
}
