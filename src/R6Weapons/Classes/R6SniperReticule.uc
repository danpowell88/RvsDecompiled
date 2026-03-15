//=============================================================================
// R6SniperReticule - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6SniperReticule.uc : Reticle for sniper rifle
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/30 * Joel Tremblay				- Creation
//=============================================================================
class R6SniperReticule extends R6CrossReticule
    config(User)
    notplaceable;

var(Textures) Texture m_FixedPart;

// Speed gives us the current speed.
simulated function PostRender(Canvas C)
{
	local float X, Y, fScale;

	super.PostRender(C);
	fScale = (C.ClipX / float(256));
	X = (m_fReticuleOffsetX * 0.2500000);
	Y = ((m_fReticuleOffsetY * 0.5000000) - X);
	C.Style = 5;
	C.SetPos(X, Y);
	C.DrawIcon(m_FixedPart, fScale);
	return;
}

defaultproperties
{
	m_FixedPart=Texture'R6TexturesReticule.SniperReticule'
}
