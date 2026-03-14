//=============================================================================
//  R6DZoneRandomPoint.uc : Deployment zone that spawns pawns at randomly chosen DZoneRandomPointNodes.
//  m_bUseAllowLeave propagates the zone's AllowLeave flag to all child nodes.
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/25 * Created by Guillaume Borgia
//=============================================================================
class R6DZoneRandomPoints extends R6DeploymentZone
    native;

// --- Variables ---
var bool m_bUseAllowLeave;        // Propagate AllowLeave setting from zone to child nodes
// ^ NEW IN 1.60
var array<array> m_aNode;         // List of random point nodes available in this zone
// ^ NEW IN 1.60
var bool m_bSelectNodeInEditor;   // Preview node selection in the Unreal Editor
// ^ NEW IN 1.60
var bool m_bInInit;
var const array<array> m_aTempHighPriorityNode;
var const array<array> m_aTempNode;

defaultproperties
{
}
