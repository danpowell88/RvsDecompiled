//=============================================================================
// R6GasMask - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6GasMask.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/14 * Created by Rima Brek
//=============================================================================
class R6GasMask extends StaticMeshActor;

defaultproperties
{
	RemoteRole=0
	bStatic=false
	bWorldGeometry=false
	m_bDeleteOnReset=true
	m_bDrawFromBase=true
	bShadowCast=false
	bCollideActors=false
	bBlockActors=false
	bBlockPlayers=false
	bEdShouldSnap=false
	DrawScale=1.1000000
	StaticMesh=StaticMesh'R6Engine.R6GasMask'
	Skins=/* Array type was not detected. */
	DrawScale3D=(X=-1.0000000,Y=-1.0000000,Z=1.0000000)
}
