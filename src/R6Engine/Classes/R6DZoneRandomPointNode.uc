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
var bool m_bHighPriority;
// ^ NEW IN 1.60
var EStance m_eStance;
// ^ NEW IN 1.60
var int m_iGroupID;
// ^ NEW IN 1.60
var bool m_bAllowLeave;
// ^ NEW IN 1.60
var R6DZoneRandomPoints m_pZone;

defaultproperties
{
}
