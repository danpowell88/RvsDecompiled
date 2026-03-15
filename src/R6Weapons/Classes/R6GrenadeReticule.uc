//=============================================================================
// R6GrenadeReticule - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6GrenadeReticule.uc : Grenade reticule
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/06 * Eric Begin				- Creation
//=============================================================================
class R6GrenadeReticule extends R6Reticule
    config(User)
    notplaceable;

var(Textures) Texture m_Circle;
var(Textures) Texture m_Dot;

// Speed gives us the current speed.
simulated function PostRender(Canvas C)
{
	local int X, Y;
	local float fScale;

	C.UseVirtualSize(true, 640.0000000, 480.0000000);
	SetReticuleInfo(C);
	X = int(C.HalfClipX);
	Y = int(C.HalfClipY);
	C.Style = 5;
	fScale = ((64.0000000 / float(m_Circle.VSize)) * m_fZoomScale);
	C.SetPos(((float(X) - ((float(m_Circle.USize) * fScale) / float(2))) + float(1)), ((float(Y) - ((float(m_Circle.VSize) * fScale) / float(2))) + float(1)));
	C.DrawIcon(m_Circle, fScale);
	fScale = ((16.0000000 / float(m_Dot.VSize)) * m_fZoomScale);
	C.SetPos(((float(X) - ((float(m_Dot.USize) * fScale) / float(2))) + float(1)), ((float(Y) - ((float(m_Dot.VSize) * fScale) / float(2))) + float(1)));
	C.DrawIcon(m_Dot, fScale);
	return;
}

defaultproperties
{
	m_Circle=Texture'R6TexturesReticule.Small_Cercle'
	m_Dot=Texture'R6TexturesReticule.Dot'
}
