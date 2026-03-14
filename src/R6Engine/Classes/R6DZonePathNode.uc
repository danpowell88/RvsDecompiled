//=============================================================================
//  R6DZonePathNode.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/11 * Created by Guillaume Borgia
//=============================================================================
class R6DZonePathNode extends Actor
    native;

// --- Variables ---
var Sound m_SoundToPlay;
// ^ NEW IN 1.60
var name m_AnimToPlay;
// ^ NEW IN 1.60
var bool m_bWait;
// ^ NEW IN 1.60
var float m_fRadius;
// ^ NEW IN 1.60
var int m_AnimChance;
// ^ NEW IN 1.60
var R6DZonePath m_pPath;
var Sound m_SoundToPlayStop;
// ^ NEW IN 1.60

// --- Functions ---
event Destroyed() {}

defaultproperties
{
}
