//=============================================================================
//  R6NightVision.uc : Night-vision goggle variant for the pilot character model.
//  Extends R6NightVision with a pilot-specific mesh (R6RPilotNightVision).
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/21 * Created by Rima Brek
//=============================================================================
class R6PilotNightVision extends R6NightVision;

#exec NEW StaticMesh File="models\R6RPilotNightVision.ASE" Name="R6RPilotNightVision"

defaultproperties
{
}
