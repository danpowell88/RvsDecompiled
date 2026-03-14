//=============================================================================
//  R6FieldOfView.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/04 * Created by Guillaume Borgia
//=============================================================================
class R6FieldOfView extends StaticMeshActor;

#exec OBJ LOAD FILE=..\Textures\R6Engine_T.utx PACKAGE=R6Engine_T.Debug
#exec NEW StaticMesh File="models\FOV.ASE" Name="R6FieldOfView"  ROLL=16384

defaultproperties
{
}
