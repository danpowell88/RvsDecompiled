//=============================================================================
// R6GlowLight - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6GlowLight.uc : Fading light depending on the view angle.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/01 * Created by Jean-Francois Dube
//    2001/10/30 * Added fading with distance (jfd)
//=============================================================================
class R6GlowLight extends Light
    native
    placeable;

var(R6Glow) bool m_bFadeWithDistance;
var(R6Glow) bool m_bInverseScale;
var(R6Glow) float m_fAngle;
var(R6Glow) float m_fFadeValue;
var(R6Glow) float m_fDistanceValue;
var Actor m_pOwnerNightVision;

defaultproperties
{
	m_fAngle=90.0000000
	m_fFadeValue=3.0000000
	m_fDistanceValue=1000.0000000
	LightType=0
	bStatic=false
	bCorona=true
	bDirectional=true
}
