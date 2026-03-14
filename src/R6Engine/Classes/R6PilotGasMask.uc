//=============================================================================
//  R6PilotGasMask.uc : Gas mask variant for the pilot character model; uses a different mesh.
//  Extends R6GasMask with the R6RPilotGMask static mesh.
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/12/13 * Created by Rima Brek
//=============================================================================
class R6PilotGasMask extends R6GasMask;

#exec NEW StaticMesh File="models\R6RPilotGMask.ASE" Name="R6RPilotGMask"

defaultproperties
{
}
