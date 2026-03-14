//=============================================================================
//  R6HostagePawn.uc : Abstract base pawn for all hostage characters; loads the shared hostage
//                     animation set.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/15 * Creation
//=============================================================================
class R6HostagePawn extends R6Hostage
    abstract;

#exec OBJ LOAD FILE=..\Animations\R6Hostage_UKX.ukx PACKAGE=R6Hostage_UKX

// --- Functions ---
simulated event PostBeginPlay() {}

defaultproperties
{
}
