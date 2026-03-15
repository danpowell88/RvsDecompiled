//=============================================================================
// R6RHelmet - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6RHelmet.uc : rainbow helmet base class
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//		2001/10/03 * Created by Rima Brek
//=============================================================================
class R6RHelmet extends R6
    AbstractHelmet
    abstract;

defaultproperties
{
	RemoteRole=0
	bStatic=false
	bWorldGeometry=false
	m_bDrawFromBase=true
	bShadowCast=false
	bCollideActors=false
	bBlockActors=false
	bBlockPlayers=false
	bEdShouldSnap=false
	DrawScale3D=(X=-1.0000000,Y=-1.0000000,Z=1.0000000)
}
