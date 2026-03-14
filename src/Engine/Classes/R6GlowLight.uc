//=============================================================================
//  R6GlowLight.uc : Fading light depending on the view angle.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/01 * Created by Jean-Francois Dube
//    2001/10/30 * Added fading with distance (jfd)
//=============================================================================
class R6GlowLight extends Light
    native;

// --- Variables ---
var float m_fAngle;
// ^ NEW IN 1.60
var float m_fFadeValue;
// ^ NEW IN 1.60
var bool m_bFadeWithDistance;
// ^ NEW IN 1.60
var bool m_bInverseScale;
// ^ NEW IN 1.60
var float m_fDistanceValue;
// ^ NEW IN 1.60
var Actor m_pOwnerNightVision;

defaultproperties
{
}
