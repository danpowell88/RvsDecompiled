//=============================================================================
// R6CircleDotReticule - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6CircleDotReticule.uc : Circular reticule with a dot
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/27 * Eric Begin				- Creation
//=============================================================================
class R6CircleDotReticule extends R6CircleReticule
    config(User)
    notplaceable;

var(Textures) Texture m_Dot;

simulated function PostRender(Canvas C)
{
	local float fScale;

	super.PostRender(C);
	C.Style = 5;
	fScale = ((16.0000000 / float(m_Dot.VSize)) * m_fZoomScale);
	C.SetPos((m_fReticuleOffsetX - ((float(m_Dot.USize) * fScale) * 0.5000000)), (m_fReticuleOffsetY - ((float(m_Dot.VSize) * fScale) * 0.5000000)));
	C.DrawIcon(m_Dot, fScale);
	return;
}

defaultproperties
{
	m_Dot=Texture'R6TexturesReticule.Dot'
}
