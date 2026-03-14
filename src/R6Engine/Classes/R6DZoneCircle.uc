//=============================================================================
//  R6DZoneCircle.uc : Circular deployment zone; spawns/inserts pawns within a radius.
//  m_fRadius defines the circle's size in world units.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/11 * Created by Guillaume Borgia
//=============================================================================
class R6DZoneCircle extends R6DeploymentZone
    native;

// --- Variables ---
var float m_fRadius;

defaultproperties
{
}
