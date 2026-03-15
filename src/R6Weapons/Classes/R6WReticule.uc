//=============================================================================
// R6WReticule - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6CircleReticule.uc : Simple circular reticule
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/27 * Eric Begin				- Creation
//=============================================================================
class R6WReticule extends R6CrossReticule
    config(User)
    notplaceable;

var(temp) float m_fBaseReticuleHeight;  // This is the size that we want the texture has when we are at the best accuracy
var(Textures) Texture m_FixedPart;

// Speed gives us the current speed.
simulated function PostRender(Canvas C)
{
	local float X, Y, fScale;

	super.PostRender(C);
	fScale = ((32.0000000 / float(m_FixedPart.VSize)) * m_fZoomScale);
	X = (m_fReticuleOffsetX - (float((m_FixedPart.USize / 2)) * fScale));
	Y = m_fReticuleOffsetY;
	C.Style = 5;
	C.SetPos(X, (Y + float(1)));
	C.DrawIcon(m_FixedPart, fScale);
	return;
}

defaultproperties
{
	m_fBaseReticuleHeight=5.0000000
	m_FixedPart=Texture'R6TexturesReticule.Machine_Gun'
}
