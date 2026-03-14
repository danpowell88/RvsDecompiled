//=============================================================================
//  R6DZoneRandomPointNode.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/26 * Created by Guillaume Borgia
//=============================================================================
class R6DZoneRandomPointNode extends Actor
    native;

// --- Variables ---
var bool m_bHighPriority;         // Prefer this node over normal-priority nodes during random selection
// ^ NEW IN 1.60
var EStance m_eStance;            // Required stance (stand/crouch/prone) when occupying this node
// ^ NEW IN 1.60
var int m_iGroupID;               // Group ID for coordinated multi-pawn positioning
// ^ NEW IN 1.60
var bool m_bAllowLeave;           // Allow AI to leave this node when reacting to threats
// ^ NEW IN 1.60
var R6DZoneRandomPoints m_pZone;

defaultproperties
{
}
