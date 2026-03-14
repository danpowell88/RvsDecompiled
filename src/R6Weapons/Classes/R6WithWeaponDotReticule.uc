//=============================================================================
// R6WithWeaponDotReticule - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WithWeaponDotReticule.uc : Simple cross reticule with dot in the middle when zooming
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/27 * Eric Begin				- Creation
//=============================================================================
class R6WithWeaponDotReticule extends R6WithWeaponReticule
	config(User)
 notplaceable;

simulated function PostRender(Canvas C)
{
	local R6PlayerController Player;
	local Pawn pawnOwner;
	local float fCenterOffsetX, fCenterOffsetY;

	super.PostRender(C);
	pawnOwner = Pawn(Owner);
	// End:0x3E
	if(__NFUN_132__(__NFUN_114__(pawnOwner, none), __NFUN_114__(pawnOwner.Controller, none)))
	{
		return;
	}
	Player = R6PlayerController(pawnOwner.Controller);
	// End:0x1BC
	if(__NFUN_130__(__NFUN_119__(Player, none), Player.m_bHelmetCameraOn))
	{
		SetReticuleInfo(C);
		C.Style = 1;
		fCenterOffsetX = __NFUN_172__(float(C.SizeX), 640.0000000);
		fCenterOffsetY = __NFUN_172__(float(C.SizeY), 480.0000000);
		C.__NFUN_2623__(__NFUN_174__(__NFUN_175__(m_fReticuleOffsetX, 1.0000000), fCenterOffsetX), __NFUN_174__(__NFUN_175__(m_fReticuleOffsetY, 2.0000000), fCenterOffsetY));
		C.DrawRect(m_LineTexture, 3.0000000, 1.0000000);
		C.__NFUN_2623__(__NFUN_174__(__NFUN_175__(m_fReticuleOffsetX, 2.0000000), fCenterOffsetX), __NFUN_174__(__NFUN_175__(m_fReticuleOffsetY, 1.0000000), fCenterOffsetY));
		C.DrawRect(m_LineTexture, 5.0000000, 3.0000000);
		C.__NFUN_2623__(__NFUN_174__(__NFUN_175__(m_fReticuleOffsetX, 1.0000000), fCenterOffsetX), __NFUN_174__(__NFUN_174__(m_fReticuleOffsetY, 2.0000000), fCenterOffsetY));
		C.DrawRect(m_LineTexture, 3.0000000, 1.0000000);
	}
	return;
}

