//=============================================================================
// R6DotReticule - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6DotReticule.uc : Basic Dot reticule
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/12/18 * Rima Brek				- Creation
//=============================================================================
class R6DotReticule extends R6Reticule
    config(User)
    notplaceable;

var(Textures) Texture m_Dot;

simulated function PostRender(Canvas C)
{
	local int X, Y;
	local float fScale;

	C.UseVirtualSize(true, 640.0000000, 480.0000000);
	SetReticuleInfo(C);
	X = 320;
	Y = 240;
	C.Style = 5;
	fScale = ((16.0000000 / float(m_Dot.VSize)) * m_fZoomScale);
	C.SetPos(((float(X) - ((float(m_Dot.USize) * fScale) / float(2))) + float(1)), ((float(Y) - ((float(m_Dot.VSize) * fScale) / float(2))) + float(1)));
	C.DrawIcon(m_Dot, fScale);
	C.UseVirtualSize(false);
	return;
}

defaultproperties
{
	m_Dot=Texture'R6TexturesReticule.Dot'
}
