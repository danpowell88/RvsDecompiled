//=============================================================================
//  R6TerroristPawn.uc : Abstract base pawn for all terrorist enemy characters; loads the shared
//                       terrorist animation package.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/15 * Creation 
//=============================================================================
class R6TerroristPawn extends R6Terrorist
    abstract;

#exec OBJ LOAD FILE=..\Animations\R6Terrorist_UKX.ukx PACKAGE=R6Terrorist_UKX

// --- Functions ---
function PostBeginPlay() {}

defaultproperties
{
}
