//=============================================================================
// R6DZoneRandomPoints - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6DZoneRandomPoint.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/25 * Created by Guillaume Borgia
//=============================================================================
class R6DZoneRandomPoints extends R6DeploymentZone
    native
    placeable;

var(R6DZone) bool m_bSelectNodeInEditor;
// NEW IN 1.60
var(R6DZone) bool m_bUseAllowLeave;
var bool m_bInInit;
var(R6DZone) /*0x00000000-0x80000000*/ editinline array</*0x00000000-0x80000000*/ editinline R6DZoneRandomPointNode> m_aNode;
var const array<R6DZoneRandomPointNode> m_aTempHighPriorityNode;
var const array<R6DZoneRandomPointNode> m_aTempNode;

