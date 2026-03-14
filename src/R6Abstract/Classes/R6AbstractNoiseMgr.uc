//=============================================================================
//  R6AbstractNoiseMgr.uc : Store value for sound loudness of MakeNoise
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/15 * Created by Guillaume Borgia
//=============================================================================
class R6AbstractNoiseMgr extends Object
    native
    abstract
    config(sound);

// --- Functions ---
event R6MakeNoise(ESoundType eType, Actor Source) {}
function R6MakePawnMovementNoise(R6AbstractPawn Pawn) {}
function Init() {}

defaultproperties
{
}
