//=============================================================================
// R6BipodMeshes - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
//  R6BipodMeshes.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class R6BipodMeshes extends R6WeaponGadgetMesh
	abstract
 notplaceable;

var(R6Meshes) StaticMesh CloseSM;
var(R6Meshes) StaticMesh OpenSM;

defaultproperties
{
	DrawType=8
}
