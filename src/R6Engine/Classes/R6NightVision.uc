//=============================================================================
// R6NightVision - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6NightVision.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/21 * Created by Rima Brek
//=============================================================================
class R6NightVision extends StaticMeshActor;

defaultproperties
{
	bStatic=false
	bWorldGeometry=false
	bSkipActorPropertyReplication=true
	m_bDeleteOnReset=true
	m_bDrawFromBase=true
	bShadowCast=false
	bCollideActors=false
	bBlockActors=false
	bBlockPlayers=false
	bEdShouldSnap=false
	DrawScale=1.1000000
	StaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdNightVision'
	DrawScale3D=(X=-1.0000000,Y=-1.0000000,Z=1.0000000)
}
