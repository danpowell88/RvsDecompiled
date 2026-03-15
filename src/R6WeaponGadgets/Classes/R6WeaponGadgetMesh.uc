//=============================================================================
// R6WeaponGadgetMesh - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  R6WeaponGadgetMesh.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Class used to regoup the WeaponGadgets in the editor.
//
//============================================================================//

#exec OBJ LOAD FILE=..\StaticMeshes\R63rdWeapons_SM.usx PACKAGE=R63rdWeapons_SM
class R6WeaponGadgetMesh extends Actor
    abstract
    notplaceable;

defaultproperties
{
	RemoteRole=0
	DrawScale3D=(X=-1.0000000,Y=-1.0000000,Z=1.0000000)
}
