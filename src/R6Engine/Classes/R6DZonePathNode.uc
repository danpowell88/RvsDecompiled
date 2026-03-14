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
var Sound m_SoundToPlay;          // Sound played when a pawn reaches this patrol node
// ^ NEW IN 1.60
var name m_AnimToPlay;            // Animation name played when a pawn reaches this patrol node
// ^ NEW IN 1.60
var bool m_bWait;                 // If true, pawn pauses and plays the animation at this node
// ^ NEW IN 1.60
var float m_fRadius;              // Arrival radius; pawn considered at node when within this distance
// ^ NEW IN 1.60
var int m_AnimChance;             // Percentage chance (0-100) the animation is played on arrival
// ^ NEW IN 1.60
var R6DZonePath m_pPath;
var Sound m_SoundToPlayStop;      // Sound played when the pawn leaves this patrol node
// ^ NEW IN 1.60

// --- Functions ---
event Destroyed() {}

defaultproperties
{
}
