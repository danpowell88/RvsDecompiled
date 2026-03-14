//=============================================================================
//  R6DZoneRandomPoint.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/25 * Created by Guillaume Borgia
//=============================================================================
class R6DZoneRandomPoints extends R6DeploymentZone
    native;

// --- Variables ---
var bool m_bUseAllowLeave;
// ^ NEW IN 1.60
var array<array> m_aNode;
// ^ NEW IN 1.60
var bool m_bSelectNodeInEditor;
// ^ NEW IN 1.60
var bool m_bInInit;
var const array<array> m_aTempHighPriorityNode;
var const array<array> m_aTempNode;

defaultproperties
{
}
