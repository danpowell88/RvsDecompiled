//============================================================================//
//  R6Pistol.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class R6Pistol extends R6Weapons;

#exec OBJ LOAD FILE="..\Textures\Color.utx" PACKAGE=Color
#exec NEW StaticMesh FILE="models\RedPistol.ASE" NAME="RedPistolStaticMesh" Yaw=32678

defaultproperties
{
}
