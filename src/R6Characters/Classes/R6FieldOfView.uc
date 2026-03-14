//=============================================================================
//  R6FieldOfView.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/04 * Created by Guillaume Borgia
//=============================================================================
class R6FieldOfView extends StaticMeshActor
	placeable;

#exec OBJ LOAD FILE=..\Textures\R6Engine_T.utx PACKAGE=R6Engine_T.Debug
#exec NEW StaticMesh File="models\FOV.ASE" Name="R6FieldOfView"  ROLL=16384
//YAW=-16384

defaultproperties
{
     bStatic=False
     bWorldGeometry=False
     bShadowCast=False
     bCollideActors=False
     bBlockActors=False
     bBlockPlayers=False
     bEdShouldSnap=False
     DrawScale=5.000000
     StaticMesh=StaticMesh'R6Characters.R6FieldOfView'
     Skins(0)=FinalBlend'R6Engine_T.Debug.FOVMaterial'
}
