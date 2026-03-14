//=============================================================================
//  R6DZonePoint.uc : (add small description)
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
