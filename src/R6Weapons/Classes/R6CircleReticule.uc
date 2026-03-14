//=============================================================================
// R6CircleReticule - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6CircleReticule.uc : Simple circular reticule
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/27 * Eric Begin				- Creation
//=============================================================================
class R6CircleReticule extends R6CrossReticule
	config(User)
 notplaceable;

var(temp) float m_fBaseReticuleHeight;  // This is the size that we want the texture has when we are at the best accuracy
var(Textures) Texture m_Circle;

// Speed gives us the current speed.
simulated function PostRender(Canvas C)
{
	local float X, Y, fScale;

	super.PostRender(C);
	fScale = __NFUN_171__(__NFUN_172__(64.0000000, float(m_Circle.VSize)), m_fZoomScale);
	X = __NFUN_175__(m_fReticuleOffsetX, __NFUN_171__(__NFUN_171__(float(m_Circle.USize), 0.5000000), fScale));
	Y = __NFUN_175__(m_fReticuleOffsetY, __NFUN_171__(__NFUN_171__(float(m_Circle.VSize), 0.5000000), fScale));
	C.Style = 5;
	C.__NFUN_2623__(X, Y);
	C.DrawIcon(m_Circle, fScale);
	return;
}

defaultproperties
{
	m_fBaseReticuleHeight=5.0000000
	m_Circle=Texture'R6TexturesReticule.Small_Cercle'
}
