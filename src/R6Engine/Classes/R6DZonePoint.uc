//=============================================================================
//  R6DZonePoint.uc : Single-point deployment zone with a specified stance.
//  Used for precise insertion/deployment positions where a pawn must start in a given stance.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/11 * Created by Guillaume Borgia
//=============================================================================
class R6DZonePoint extends R6DeploymentZone
    native;

// --- Variables ---
var EStance m_eStance;
var Vector m_vReactionZoneCenter;
var bool m_bUseReactionZone;
var float m_fReactionZoneX;
var float m_fReactionZoneY;

defaultproperties
{
}
