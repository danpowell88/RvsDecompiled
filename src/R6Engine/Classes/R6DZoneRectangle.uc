//=============================================================================
//  R6DZoneRectangle.uc : Axis-aligned rectangular deployment zone for inserting/spawning pawns.
//  Dimensions are set by m_fX and m_fY (width and depth of the rectangle).
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/11 * Created by Guillaume Borgia
//=============================================================================
class R6DZoneRectangle extends R6DeploymentZone
    native;

// --- Variables ---
var float m_fX;
var float m_fY;

defaultproperties
{
}
