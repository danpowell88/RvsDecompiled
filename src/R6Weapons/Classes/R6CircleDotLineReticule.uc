//=============================================================================
// R6CircleDotLineReticule - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6CircleDotReticule.uc : Circular reticule with a dot
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/27 * Eric Begin				- Creation
//=============================================================================
class R6CircleDotLineReticule extends R6CircleDotReticule
    config(User)
    notplaceable;

// Speed gives us the current speed.
simulated function PostRender(Canvas C)
{
	super.PostRender(C);
	C.Style = 5;
	C.SetPos((m_fReticuleOffsetX - 1.0000000), (m_fReticuleOffsetY + 1.0000000));
	C.DrawRect(m_LineTexture, (float(c_iLineWidth) * m_fZoomScale), (float(c_iLineHeight) * m_fZoomScale));
	return;
}

