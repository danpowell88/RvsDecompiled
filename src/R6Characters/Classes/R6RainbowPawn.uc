//=============================================================================
//  R6RainbowPawn.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/15 * Created by Rima Brek
//=============================================================================
class R6RainbowPawn extends R6Rainbow
    abstract;

#exec OBJ LOAD FILE=..\Animations\R6Rainbow_UKX.ukx PACKAGE=R6Rainbow_UKX
#exec OBJ LOAD FILE="..\textures\R61stWeapons_T.utx" Package="R61stWeapons_T"

// --- Functions ---
simulated event PostBeginPlay() {}
simulated function SetRainbowFaceTexture() {}
simulated event PostNetBeginPlay() {}
simulated function SetFemaleParameters() {}

defaultproperties
{
}
